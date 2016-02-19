local module = {}  

local function setup()
gpio.mode(5, gpio.OUTPUT)
gpio.mode(6, gpio.OUTPUT)
gpio.mode(7, gpio.OUTPUT)
gpio.mode(8, gpio.OUTPUT)

gpio.write(5,gpio.LOW)
gpio.write(6,gpio.LOW)
gpio.write(7,gpio.LOW)
gpio.write(8,gpio.LOW)
end

-- return relay mapping for relay 1 to 4
local function getPin(relay)

    if relay == 1 then
        return 5
    elseif relay == 2 then
        return 6
    elseif relay == 3 then
        return 7
    elseif relay == 4 then
        return 8        
    end

    -- return Default Pin (Relay 1)
    return 12
end

-- return Relay Status
function module.getStatus(relay)
    return gpio.read(getPin(relay))
end

-- turn Relay ON
function module.turnOn(relay)
    gpio.write(getPin(relay),gpio.HIGH)        
end

-- turn Relay OFF
function module.turnOff(relay)
    gpio.write(getPin(relay),gpio.LOW)
end


function module.start()  
    setup()
end

return module 