# OPA Kong Plugin
summary: Custom Kong plugin to allow for fine grained Authorization through Open Policy Agent

_Created to work with Kong >= 2.0.x

Inspired by https://github.com/TravelNest/kong-authorization-opa  
Connection based on https://github.com/Kong/kong-plugin-aws-lambda

Custom Kong plugin to allow for fine grained Authorization through [Open Policy Agent](https://www.openpolicyagent.org/).

Plugin will continue the request to the upstream target if OPA responds with `true`, else the plugin will return a `403 Forbidden`.

Rsponses will add the header `X-Kong-Authz-Latency` to requests which have been impacted by the plugin and the header `X-Kong-Authz-Cache` when cache is enabled.

Plugin priority: `799`

## Setup

### Config
|Parameter                    | Usage                                                                                                       | Type    | Default |
|-----------------------------|-------------------------------------------------------------------------------------------------------------|---------|---------|
|`opa_method`                 |request method to OPA endpoint                                                                               |`string` | POST    |
|`opa_scheme`                 |OPA scheme endpoint                                                                                          |`string` | http    |
|`opa_host`                   |OPA hostname (FQDN) (e.g. `authz.example.com`)                                                               |`string` |         |
|`opa_port`                   |OPA port to the endpoint                                                                                     |`number` | 80      |
|`policy_uri`                 |OPA target policy (e.g. `/v1/data/my_policy`)                                                                |`string` |         |
|`opa_result_boolean_key`     |OPA result boolean key to evaluate                                                                           |`string` | allow   |
|`opa_result_boolean_value`   |OPA result boolean value expected to allow request                                                           |`boolean`| true    |
|`timeout`                    |timeout in ms for request to OPA                                                                             |`number` | 60000   |
|`keepalive`                  |keepalive in ms for request to OPA                                                                           |`number` | 60000   |
|`forward_request_method`     |flag to forward request method                                                                               |`boolean`| true    |
|`forward_request_path`       |flag to forward request path                                                                                 |`boolean`| true    |
|`forward_splitted_request_path`|flag to forward request path as array (e.g. `/path/to/my/endpoint` becomes `["path", "to", "my", "endpoint"]`) |`boolean`| true    |
|`forward_request_querystrings` |flag to control which request querystrings to forward to OPA                                                      |`string` ("`ALL`", "`SOME`" or "`NONE`")| ALL    |
|`forward_request_querystrings_names`|**list** of querystrings to forward to OPA (when `forward_request_querystrings` is set to  `SOME`)                       |`set`    |         |
|`forward_request_headers`    |flag to control which request headers to forward to OPA                                                      |`string` ("`ALL`", "`SOME`" or "`NONE`")| ALL    |
|`forward_request_headers_names`|**list** of headers to forward to OPA (when `forward_request_headers` is set to  `SOME`)                       |`set`    |         |
|`forward_request_cookies` |flag to control which request cookies to forward to OPA                                                      |`string` ("`ALL`", "`SOME`" or "`NONE`")| ALL    |
|`forward_request_cookies_names`|**list** of cookies to forward to OPA (when `forward_request_cookies` is set to  `SOME`)                       |`set`    |         |
|`forward_request_body`       |flag to forward request body                                                                                 |`boolean`| true    |

|`debug`                      |flag to return the request/response to/from OPA - not the upstream target (used for testing purposes)        |`boolean`| false   |
|`proxy_url`           |An optional value that defines whether the plugin should connect through the given proxy server URL. This value is required if `proxy_scheme` is defined. | `string` | |
|`proxy_scheme` |An optional value that defines which HTTP protocol scheme to use in order to connect through the proxy server. The schemes supported are: `http` and `https`. This value is required if `proxy_url` is defined. | `string` | |
|`use_redis_cache`            |flag to cache OPA response in Redis   |`boolean`| false   |
|`redis_cache_ttl`            |Redis Key TTL (in seconds)   |`integer`| 15   |
|`redis_host`                 |Redis Host to connect   |`string`|   |
|`redis_port`                 |Redis Port to connect   |`integer`| 6379 |
|`redis_password`             |Redis Password to connect   |`string`| |
|`redis_timeout_in_ms`        |Redis Timeout (in miliseconds)   |`integer`| 500 |
|`redis_database`             |Redis Database to Use   |`integer`| 0 |

#### YAMLs

```yaml
name: kong-authorization-opa
config:
  opa_method: POST
  opa_scheme: http
  opa_host: opa_server
  opa_port: 8181
  policy_uri: /v1/data/carneiro/policy1
  opa_result_boolean_key: deny
  opa_result_boolean_value: false
  timeout: 60000
  keepalive: 60000
  forward_request_method: true
  forward_request_path: true
  forward_splitted_request_path: true
  forward_request_querystrings: NONE
  forward_request_querystrings_names: null
  forward_request_headers: SOME
  forward_request_headers_names:
    - content-type
  forward_request_cookies: ALL
  forward_request_cookies_names: null
  forward_request_body: true
  debug: false
  proxy_scheme: null
  proxy_url: null
  use_redis_cache: true
  redis_cache_ttl: 15
  redis_host: redis
  redis_port: 6379
  redis_password: null
  redis_timeout_in_ms: 500
  redis_database: 0
```

#### Example

```
$ curl -i -X POST \
  --url http://localhost:8001/services/my-service/plugins \
  --data 'name=kong-authorization-opa' \
  --data 'config.opa_host=authz.example.com' \
  --data 'config.policy_uri=/v1/data/my_policy'
```

#### Request example

`curl -X POST -s http://localhost:8000/foo/bar/baz?foo=bar -H content-type:application/json -d '{"a": "baaa"}' --cookie "oauth_jwt=eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwicm9sZXMiOlsiREJBIl19.T2Fm7a-Ojs21jvDd58pew-8OtFpyRTTCz8epNQ0FICEwza5KoFUIgYxv_Ft4eWXvL-UQ_xU6Og3ND6wlzyGBjsMZkLtoHuo0RQsW3ZCYqCbnZqLkvrjhgFKZljeLJVHW6emJpuGUSRxFlVNYPp_nLhwf20d37_sbAPXZmW3Goh61v0uwk9gq8YQxITRSh7YoYzifrFaIUB0M8ePeZn5N6UwDp-Ozi1oRNippqB53CcI_aj87UwsFRUnBsQ7-AT5WXU26B8C1ccJKcPjQ7pg8i7gjurHG_i36afSDHu46xhVi5qVd0NK50YR9vyNySSS0RPLTf46wQ8p2YloMjvmYIA"`

```json
{
  "input": {
    "request_body_args": {
      "a": "baaa"
    },
    "request_body": "{\"a\": \"baaa\"}",
    "querystrings": {
      "foo": "bar"
    },
    "cookies": {
      "oauth_jwt": "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwicm9sZXMiOlsiREJBIl19.T2Fm7a-Ojs21jvDd58pew-8OtFpyRTTCz8epNQ0FICEwza5KoFUIgYxv_Ft4eWXvL-UQ_xU6Og3ND6wlzyGBjsMZkLtoHuo0RQsW3ZCYqCbnZqLkvrjhgFKZljeLJVHW6emJpuGUSRxFlVNYPp_nLhwf20d37_sbAPXZmW3Goh61v0uwk9gq8YQxITRSh7YoYzifrFaIUB0M8ePeZn5N6UwDp-Ozi1oRNippqB53CcI_aj87UwsFRUnBsQ7-AT5WXU26B8C1ccJKcPjQ7pg8i7gjurHG_i36afSDHu46xhVi5qVd0NK50YR9vyNySSS0RPLTf46wQ8p2YloMjvmYIA"
    },
    "method": "POST",
    "headers": {
      "host": "localhost:8000",
      "user-agent": "curl/7.59.0",
      "accept": "*/*",
      "content-length": "13",
      "content-type": "application/json"
    },
    "splitted_path": [
      "foo",
      "bar",
      "baz"
    ],
    "path": "/foo/bar/baz"
  }
}
```

## Roadmap

- Recreate the connection part based on the AWS Lambda plugin (OK)
- Implement toggle to use distributed cache (OK)
- Toggle to select which headers, querystrings and cookies to forward (ok)
- Use pongo to create a test suit
