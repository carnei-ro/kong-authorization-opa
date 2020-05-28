
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
          { response_body_key = {
            type = "string",
            default = "deny",
            required = true
          } },
          { forward_request_method = {
            type = "boolean",
            default = true,
            required = true
          } },
          { forward_request_headers = {
            type = "boolean",
            default = true,
            required = true
          } },
          { forward_upstream_split_path = {
            type = "boolean",
            default = true,
            required = true
          } },
          { forward_request_uri = {
            type = "boolean",
            default = true,
            required = true
          } },
          { forward_request_body = {
            type = "boolean",
            default = true,
            required = true
          } },
          { forward_request_cookies = {
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
        },
      },
    },
  },
  entity_checks = {
    { mutually_required = { "config.proxy_scheme", "config.proxy_url" } },
  }
}
