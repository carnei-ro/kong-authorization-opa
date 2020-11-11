
local typedefs = require "kong.db.schema.typedefs"
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

return {
  name = plugin_name,
  fields = {
    { protocols = typedefs.protocols_http },
    {
      config = {
        type = "record",
        fields = {
          { opa_method = {
            type = "string",
            one_of = { "GET", "HEAD", "POST", "PUT", "DELETE", "CONNECT", "OPTIONS", "TRACE", "PATCH" },
            default = "POST",
            required = true
          } },
          { opa_scheme = {
            type = "string",
            one_of = { "http", "https" },
            default = "http",
            required = true
          } },
          { opa_host = typedefs.host {
            required = true
          } },
          { opa_port = typedefs.port {
            default = 80,
            required = true
          } },
          { policy_uri = {
            type = "string",
            required = true
          } },
          { opa_result_boolean_key = {
            type = "string",
            default = "allow",
            required = true
          } },
          { opa_result_boolean_value = {
            type = "boolean",
            default = true,
            required = true
          } },
          { timeout = {
            type = "number",
            required = true,
            default = 60000,
          } },
          { keepalive = {
            type = "number",
            required = true,
            default = 60000,
          } },
          { forward_request_method = {
            type = "boolean",
            default = true,
            required = true
          } },
          { forward_request_path = {
            type = "boolean",
            default = true,
            required = true
          } },
          { forward_splitted_request_path = {
            type = "boolean",
            default = true,
            required = true
          } },
          { forward_request_querystrings = {
            type = "string",
            default = "ALL",
            required = true,
            one_of = { "ALL", "SOME", "NONE" },
          } },
          { forward_request_querystrings_names = {
            type = "set",
            required = false,
            elements = { type = "string" },
          } },
          { forward_request_headers = {
            type = "string",
            default = "ALL",
            required = true,
            one_of = { "ALL", "SOME", "NONE" },
          } },
          { forward_request_headers_names = {
            type = "set",
            required = false,
            elements = { type = "string" },
          } },
          { forward_request_cookies = {
            type = "string",
            default = "ALL",
            required = true,
            one_of = { "ALL", "SOME", "NONE" },
          } },
          { forward_request_cookies_names = {
            type = "set",
            required = false,
            elements = { type = "string" },
          } },
          { forward_request_body = {
            type = "boolean",
            default = true,
            required = true
          } },
          { debug = {
            type = "boolean",
            default = false,
            required = true
          } },
          { proxy_scheme = {
            type = "string",
            one_of = { "http", "https" }
          } },
          { proxy_url = typedefs.url },
          { use_redis_cache = {
            type = "boolean",
            required = true,
            default = false,
          } },
          { redis_cache_ttl = {
            type = "integer",
            default = 15,
            required = true,
            gt = -1
          } },
          { redis_host = typedefs.host {
            required = true
          } },
          { redis_port = typedefs.port {
            default = 6379,
            required = true
          } },
          { redis_timeout_in_ms = {
            type = "number",
            default = 500,
            required = true,
            gt = 0
          } },
          { redis_database = {
            type = "integer",
            default = 0,
            required = true,
            gt = -1
          } },
          { redis_password = {
            type = "string",
            len_min = 1,
          } },
        },
      },
    },
  },
  entity_checks = {
    { mutually_required = { "config.proxy_scheme", "config.proxy_url" } },
    { conditional = {
      if_field = "config.forward_request_headers", if_match = { eq = "SOME" },
      then_field = "config.forward_request_headers_names", then_match = { required = true },
    } },
    { conditional = {
      if_field = "config.forward_request_cookies", if_match = { eq = "SOME" },
      then_field = "config.forward_request_cookies_names", then_match = { required = true },
    } },
    { conditional = {
      if_field = "config.forward_request_querystrings", if_match = { eq = "SOME" },
      then_field = "config.forward_request_querystrings_names", then_match = { required = true },
    } },
  }
}
