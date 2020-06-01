package carneiro.policy1

default deny = true

# Extracting roles from token
roles[r] {
    #[header, payload, signature] := io.jwt.decode(input.cookies.oauth_jwt)
    [_, payload, _] := io.jwt.decode(input.cookies.oauth_jwt)
    r:=payload.roles[_]
}

# Import portions of "data"
import data.routes.some_route_name_here
# Defining the variables outside, it can be used in all places. It also is echoed to the response
# statements := some_route_name_here.statements
# method := input.method

deny = false {
    # without the "some i" it could match input in other statement
    some i
    roles[_] == some_route_name_here.statements[i].roles[_]
    input.method == some_route_name_here.statements[i].methods[_]
}

# root can do anything. This could be other policy for this one extends
deny = false {
    roles[_] == "root"
}
