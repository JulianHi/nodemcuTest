-- file : config.lua
local module = {}

module.SSID = {}  
module.SSID["WLAN SSID"] = "WLAN PASSWORD"


module.HOST = "broker.mqttdashboard.com"  
module.PORT = 1883  
module.ID = node.chipid()

module.ENDPOINT = "nodemcu/"  
return module 