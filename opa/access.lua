local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")
local http  = require("kong.plugins." .. plugin_name .. ".connect-better")
local redis = require("kong.plugins." .. plugin_name .. ".redis")

local kong              = kong
local cjson             = require("cjson.safe").new()
local resty_cookie      = require('resty.cookie')
local table_insert      = table.insert
local string_find       = string.find
local pairs             = pairs
local ngx_encode_base64 = ngx.encode_base64

cjson.decode_array_with_array_mt(true)

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
  local payload        = {["input"] = {}}
  local cookies        = resty_cookie:new()
  local path           = kong.request.get_path()

  if conf.forward_request_method then
    payload.input.method = kong.request.get_method()
  end

  if conf.forward_request_path then
    payload.input.path = path
  end

  if conf.forward_splitted_request_path then
    local raw_split_path = split(path, "/")
    payload.input.splitted_path = slice(raw_split_path, 2, #raw_split_path)
  end

  if not (conf.forward_request_querystrings == "NONE") then
    if conf.forward_request_querystrings == "SOME" then
      payload.input.querystrings = {}
      for _,header_name in ipairs(conf.forward_request_querystrings_names) do
        payload.input.querystrings[header_name] = kong.request.get_query_arg(header_name)
      end
    else
      payload.input.querystrings = kong.request.get_query(1000)
    end
  end

  if not (conf.forward_request_headers == "NONE") then
    if conf.forward_request_headers == "SOME" then
      payload.input.headers = {}
      for _,header_name in ipairs(conf.forward_request_headers_names) do
        payload.input.headers[header_name] = kong.request.get_header(header_name)
      end
    else
      -- ngx.req.get_headers(0)
      payload.input.headers = kong.request.get_headers(1000)
    end
  end

  if not (conf.forward_request_cookies == "NONE") then
    if conf.forward_request_cookies == "SOME" then
      payload.input.cookies = {}
      for _,cookie_name in ipairs(conf.forward_request_cookies_names) do
        local cookie_value, err = cookies:get(cookie_name)
        if not err then
          payload.input.cookies[cookie_name] = cookie_value
        end
      end
    else
      payload.input.cookies = cookies:get_all()
    end
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
        payload.input.request_body_base64 = true
      end
    end
    payload.input.request_body      = body_raw
    payload.input.request_body_args = body_args
  end

  return payload
end

local function request_to_opa(conf, opa_body_json)
  kong.log.debug(" => Request to OPA")
  local method = conf.opa_method
  local scheme = conf.opa_scheme
  local host   = conf.opa_host
  local port   = conf.opa_port
  local path   = conf.policy_uri

  -- Trigger request
  local client = http.new()
  client:set_timeout(conf.timeout)

  local ok, err
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
    return nil, err
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
    return nil, err
  end

  local content = res:read_body()

  ok, err = client:set_keepalive(conf.keepalive)
  if not ok then
    kong.log.err(err)
    return nil, err
  end

  return content, nil
end

--- access
function _M.execute(conf)
  local start_time = ngx.now()
  local opa_body   = {}
  opa_body         = prepare_payload(conf)

  local opa_body_json, err = cjson.encode(opa_body)
  if not opa_body_json then
    kong.log.err("[opa] could not JSON encode upstream body",
    " to forward request values: ", err)
  end

  local body, err
  if (conf.use_redis_cache) then
    local red = redis:connection(conf)
    body, err = redis:get(red, opa_body_json, conf.redis_cache_ttl, request_to_opa, conf, opa_body_json)
  else
    body, err = request_to_opa(conf, opa_body_json)
  end
  if (not body) or (err) then
    if conf.fault_tolerant then
      kong.response.set_header("X-Kong-Authz-Latency", (ngx.now() - start_time))
      kong.response.set_header("X-Kong-Authz-Skipped", "true")
      kong.service.request.set_header("X-Kong-Authz-Skipped", "true")
      return true
    else
      return kong.response.exit(500, { message = "An unexpected error occurred", error = err })
    end
  end
  body = cjson.decode(body)

  if conf.debug then
    kong.response.exit(200, { request = opa_body, response = body }, {["X-Kong-Authz-Latency"] = (ngx.now() - start_time)} )
  end

  local result = body.result
  if not result then
    if conf.fault_tolerant then
      kong.response.set_header("X-Kong-Authz-Latency", (ngx.now() - start_time))
      kong.response.set_header("X-Kong-Authz-Skip", "true")
      return true
    else
      return kong.response.exit(500, { message = "Could not get result from OPA", opa_response = body } , {["X-Kong-Authz-Latency"] = (ngx.now() - start_time)})
    end
  end
  
  local evaluation_result_key_value = result[conf.opa_result_boolean_key]
  if not (type(evaluation_result_key_value) == "boolean") then
    return kong.response.exit(400, { message = "OPA response body does not contains boolean key: " .. conf.opa_result_boolean_key, opa_response_result = result } , {["X-Kong-Authz-Latency"] = (ngx.now() - start_time)})
  end

  if not (evaluation_result_key_value == conf.opa_result_boolean_value) then
    return kong.response.exit(403, { message = "Unauthorized by OPA", opa_result = result }, {["X-Kong-Authz-Latency"] = (ngx.now() - start_time)})
  end

  kong.response.set_header("X-Kong-Authz-Latency", (ngx.now() - start_time))
end

return _M
