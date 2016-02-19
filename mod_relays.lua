local module = {}  

local function setup()
gpio.mode(12, gpio.OUTPUT)
gpio.mode(13, gpio.OUTPUT)
gpio.mode(14, gpio.OUTPUT)
gpio.mode(15, gpio.OUTPUT)

gpio.write(12,gpio.LOW)
gpio.write(13,gpio.LOW)
gpio.write(14,gpio.LOW)
gpio.write(15,gpio.LOW)
end

-- return relay mapping for relay 1 to 4
local function getPin(relay)

    if relay == 1 then
        return 12
    elseif relay == 2 then
        return 13
    elseif relay == 3 then
        return 14
    elseif relay == 4 then
        return 15        
    end

    -- return Default Pin (Relay 1)
    return 12

end

-- return Relay Status
local function getStatus(relay)
    return gpio.read(getPin(relay))
end

-- turn Relay ON
local function turnOn(relay)
    gpio.write(getPin(relay),gpio.HIGH)        
end

-- turn Relay OFF
local function turnOff(relay)
    gpio.write(getPin(relay),gpio.LOW)
end


function module.start()  
    setup()
end

return module 