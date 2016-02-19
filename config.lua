-- file : config.lua
local module = {}

module.SSID = {}  
module.SSID["waechter-netz"] = "wpprivat"
module.SSID["SurfBox"] = "jhintern"
module.SSID["HildemannT"] = "hildemannintern"


module.HOST = "broker.mqttdashboard.com"  
module.PORT = 1883  
module.ID = node.chipid()

module.ENDPOINT = "nodemcu/"  
return module 