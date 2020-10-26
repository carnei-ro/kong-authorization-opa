local kong    = kong
local reports = require "kong.reports"
local redis   = require "resty.redis"
local cjson   = require("cjson.safe").new()
cjson.decode_array_with_array_mt(true)

local _M = {}
local sock_opts = {}

local function is_present(str)
  return str and str ~= "" and str ~= ngx.null
end

function _M:connection(conf)
  -- https://github.com/openresty/lua-resty-redis
  local redis = redis:new()
  redis:set_timeout(conf.redis_timeout_in_ms)
  -- use a special pool name only if redis_database is set to non-zero
  -- otherwise use the default pool name host:port
  sock_opts.pool = conf.redis_database and
          conf.redis_host .. ":" .. conf.redis_port ..
                  ":" .. conf.redis_database
  sock_opts.backlog = 10
  local ok, err = redis:connect(conf.redis_host, conf.redis_port, sock_opts)
  if not ok then
    kong.log.err("failed to connect to Redis: ", err)
    return nil, err
  end
  local times, err = redis:get_reused_times()
  if err then
    kong.log.err("failed to get connect reused times: ", err)
    return nil, err
  end
  if times == 0 then
    if is_present(conf.redis_password) then
        local ok, err = redis:auth(conf.redis_password)
        if not ok then
          kong.log.err("failed to auth Redis: ", err)
          return nil, err
        end
    end
    if conf.redis_database ~= 0 then
      -- only calls select first time, since we know the connection is shared
      -- between instances that use the same redis database
      local ok, err = redis:select(conf.redis_database)
      if not ok then
        kong.log.err("failed to change Redis database: ", err)
        return nil, err
      end
    end
  end
  return redis
end

function _M:get(redis, key, ttl, func, ...)
  reports.retrieve_redis_version(redis)
  local value, err = redis:get(key)
  if err then
    kong.log.err(" => Could not get key from Redis ... ", err)
    return nil, err, nil
  end

  if value and value ~= ngx.null then -- if retreive value from cache and it is not null
    ttl = redis:ttl(key) -- TTL -2 == key expired (the key may expire right just after the get)
  end

  if (value == ngx.null) or (ttl == -2) then
    kong.log.debug(" => Key does not exists on Redis")
    -- execute function and put it into the cache
    value = func(...)

    local ok, err = redis:set(key, value, "NX", "EX", ttl)
    if not ok then
      kong.log.err(" => Failed to set key in Redis ... ", err)
      return nil, err, nil
    end

    if ok == ngx.null then
      kong.log.err(" => Could not set key in Redis. ", err)
      return nil, err, nil
    end
  end

  local ok, err = redis:set_keepalive(10000, 100)
  if not ok then
    kong.log.err(" => Failed to set Redis keepalive: ", err)
  end

  return value, nil, ttl
end

return _M
