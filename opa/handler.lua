local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")
local access = require("kong.plugins." .. plugin_name .. ".access")

local plugin = {
  PRIORITY = 799,
  VERSION = "0.0.4-1"
}

function plugin:access(plugin_conf)
  access.execute(plugin_conf)  
end

return plugin
