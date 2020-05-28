local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")
local http = require("kong.plugins." .. plugin_name .. ".connect-better")

local kong              = kong
local cjson             = require "cjson.safe"
local resty_cookie      = require('resty.cookie')
local table_insert      = table.insert
local string_find       = string.find
local pairs             = pairs
local ngx_encode_base64 = ngx.encode_base64


local _M = {}

local raw_content_types = {
  ["text/plain"] = true,
  ["text/html"] = true,
  ["application/xml"] = true,
  ["text/xml"] = true,
  ["application/soap+xml"] = true,
}

local function slice(list, from, to)
  local sliced_results = {};
  for i=from, to do
    table_insert(sliced_results, list[i]);
  end;
  return sliced_results;
end

local function split(s, delimiter)
  local result = {};
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
      table_insert(result, match);
  end
  return result
end

local function prepare_payload(conf)
  local payload        = {}
  local cookies        = resty_cookie:new()
  local path           = kong.request.get_path()
  local raw_split_path = split(path, "/")

  if conf.forward_request_method then
    payload.method = kong.request.get_method()
  end

  if conf.forward_request_headers then
    payload.headers = kong.request.get_headers(1000)
  end

  if conf.forward_upstream_split_path then
    payload.path_split = slice(raw_split_path, 2, #raw_split_path)
  end

  if conf.forward_request_uri then
    payload.path  = path
    payload.query = kong.request.get_query(1000)
  end

  if conf.forward_request_body then
    local content_type = kong.request.get_header("content-type")
    local body_raw = kong.request.get_raw_body()
    local body_args, err = kong.request.get_body()
    if err and err:match("content type") then
      body_args = {}
      if not raw_content_types[content_type] then
        -- don't know what this body MIME type is, base64 it just in case
        body_raw = ngx_encode_base64(body_raw)
        payload.request_body_base64 = true
      end
    end

    payload.request_body      = body_raw
    payload.request_body_args = body_args
  end

  if conf.forward_request_cookies then
    payload.cookies = cookies:get_all()
    if payload.headers then
      payload.headers.cookie = nil
    end
  end
  return payload
end

--- access
function _M.execute(conf)
  local start_time = ngx.now()
  local opa_body   = prepare_payload(conf)

  local opa_body_json, err = cjson.encode(opa_body)
  if not opa_body_json then
    kong.log.err("[opa] could not JSON encode upstream body",
    " to forward request values: ", err)
  end

  local method = conf.opa_method
  local scheme = conf.opa_scheme
  local host   = conf.opa_host
  local port   = conf.opa_port
  local path   = conf.policy_uri

  -- Trigger request
  local client = http.new()
  client:set_timeout(conf.timeout)

  local ok
  ok, err = client:connect_better {
    scheme = scheme,
    host = host,
    port = port,
    ssl = { verify = false },
    proxy = conf.proxy_url and {
      uri = conf.proxy_url,
    }
  }
  if not ok then
    kong.log.err(err)
    return kong.response.exit(500, { message = "An unexpected error occurred", error = err })
  end

  local res, err = client:request {
    method = method,
    path = path,
    body = opa_body_json,
    headers = {
      ["Content-Type"] = "application/json",
    },
  }
  if not res then
    kong.log.err(err)
    return kong.response.exit(500, { message = "An unexpected error occurred", error = err })
  end

  local content = res:read_body()

  ok, err = client:set_keepalive(conf.keepalive)
  if not ok then
    kong.log.err(err)
    return kong.response.exit(500, { message = "An unexpected error occurred", error = err })
  end

  local body, err = cjson.decode(content)
  if not body then
    return kong.response.exit(500, { message = "An unexpected error occurred", error = err })
  end

  kong.response.set_header("X-Kong-Authz-Latency", (ngx.now() - start_time) )

  if conf.debug then
    kong.response.exit(200, { request = opa_body, response = body } )
  end

  local deny = body[conf.response_body_key]
  if not deny then
    return kong.response.exit(400, { message = "OPA response body does not contains key: " .. conf.response_body_key })
  end

  if (deny == "true" or deny == true) then
    return kong.response.exit(403, { message = "Unauthorized by OPA", opa_response_body = body })
  end

end

return _M
