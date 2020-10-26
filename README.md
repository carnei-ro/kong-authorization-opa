# OPA Kong Plugin
summary: Custom Kong plugin to allow for fine grained Authorization through Open Policy Agent

_Created to work with Kong >= 2.0.x

Inspired by https://github.com/TravelNest/kong-authorization-opa  
Connection based on https://github.com/Kong/kong-plugin-aws-lambda

Custom Kong plugin to allow for fine grained Authorization through [Open Policy Agent](https://www.openpolicyagent.org/).

Plugin will continue the request to the upstream target if OPA responds with `true`, else the plugin will return a `403 Forbidden`.

Requests will add the header `X-Kong-Authz-Latency` to requests which have been impacted by the plugin.

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
|`forward_request_headers`    |flag to forward request headers                                                                              |`boolean`| true    |
|`forward_upstream_split_path`|flag to forward split upstream path (e.g. `/path/to/my/endpoint` becomes `["path", "to", "my", "endpoint"]`) |`boolean`| true    |
|`forward_request_uri`        |flag to forward request uri                                                                                  |`boolean`| true    |
|`forward_request_body`       |flag to forward request body                                                                                 |`boolean`| true    |
|`forward_request_cookies`    |flag to forward request cookies (will remove headers.cookie)                                                 |`boolean`| true    |
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


#### Example

```
$ curl -i -X POST \
  --url http://localhost:8001/services/my-service/plugins \
  --data 'name=kong-authorization-opa' \
  --data 'config.opa_host=authz.example.com' \
  --data 'config.policy_uri=/v1/data/my_policy'
```

#### Request example

`curl -X POST -s http://localhost:8000/foo/bar/baz?foo=bar -H content-type:application/json -d '{"a": "baaa"}' --cookie "jwt=eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.JlX3gXGyClTBFciHhknWrjo7SKqyJ5iBO0n-3S2_I7cIgfaZAeRDJ3SQEbaPxVC7X8aqGCOM-pQOjZPKUJN8DMFrlHTOdqMs0TwQ2PRBmVAxXTSOZOoEhD4ZNCHohYoyfoDhJDP4Qye_FCqu6POJzg0Jcun4d3KW04QTiGxv2PkYqmB7nHxYuJdnqE3704hIS56pc_8q6AW0WIT0W-nIvwzaSbtBU9RgaC7ZpBD2LiNE265UBIFraMDF8IAFw9itZSUCTKg1Q-q27NwwBZNGYStMdIBDor2Bsq5ge51EkWajzZ7ALisVp-bskzUsqUf77ejqX_CBAqkNdH1Zebn93A"`

```json
{
    "request_body_args": {
      "a": "baaa"
    },
    "query": {
      "foo": "bar"
    },
    "path": "/foo/bar/baz",
    "cookies": {
      "jwt": "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.JlX3gXGyClTBFciHhknWrjo7SKqyJ5iBO0n-3S2_I7cIgfaZAeRDJ3SQEbaPxVC7X8aqGCOM-pQOjZPKUJN8DMFrlHTOdqMs0TwQ2PRBmVAxXTSOZOoEhD4ZNCHohYoyfoDhJDP4Qye_FCqu6POJzg0Jcun4d3KW04QTiGxv2PkYqmB7nHxYuJdnqE3704hIS56pc_8q6AW0WIT0W-nIvwzaSbtBU9RgaC7ZpBD2LiNE265UBIFraMDF8IAFw9itZSUCTKg1Q-q27NwwBZNGYStMdIBDor2Bsq5ge51EkWajzZ7ALisVp-bskzUsqUf77ejqX_CBAqkNdH1Zebn93A"
    },
    "method": "POST",
    "headers": {
      "host": "localhost:8000",
      "user-agent": "curl/7.59.0",
      "accept": "*/*",
      "content-length": "13",
      "content-type": "application/json"
    },
    "request_body": "{\"a\": \"baaa\"}",
    "path_split": [
      "foo",
      "bar",
      "baz"
    ]
}
```

## Roadmap

- Recreate the connection part based on the AWS Lambda plugin (OK)
- Implement toggle to use distributed cache (OK)
- Use pongo to create a test suit
