-- file : application.lua
local module = {}  
m = nil

-- Sends a simple ping to the broker
local function send_registration()  
    m:publish(config.ENDPOINT .. "register", config.ID,0,0)
end

-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe(config.ENDPOINT .. config.ID,0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)
    
    m:subscribe(config.ENDPOINT .. config.ID..'/relay/#',0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)   
    
end

local function mqtt_start()  
    m = mqtt.Client(config.ID, 120)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        print(topic .. ": " .. data)
	
	if topic == config.ENDPOINT .. config.ID..'/relay/status' then
		pcall(function()
			t = cjson.decode(data)
			
			relay = t['relay']
			callback = t['callback']		
			if callback and relay and relay < 5 and relay > 0 then
				status = mod_relays.getStatus(relay)
		    		m:publish(callback, "Status: "..status,0,0)
			end
			
		end
		)

	elseif topic == config.ENDPOINT .. config.ID..'/relay/turnOn' then		
		t = cjson.decode(data)
		
		relay = t['relay']
		if relay and relay < 5 and relay > 0 then
			status = mod_relays.turnOn(relay)
		end
	elseif topic == config.ENDPOINT .. config.ID..'/relay/turnOff' then		
		t = cjson.decode(data)
		
		relay = t['relay']
		if relay and relay < 5 and relay > 0 then
			status = mod_relays.turnOff(relay)
		end
	end
	
	
        -- do something, we have received a message
      end
    end)
    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 1, function(con) 
        register_myself()
        -- And then pings each 1000 milliseconds
        --tmr.stop(6)
       -- tmr.alarm(6, 1000, 1, send_ping)
       send_registration()
    end) 

end


local function rcTimer()

	if mod_rcswitch.available() then
	
		value = mod_rcswitch.getReceivedValue()
		
		if value == 0 then
			print("\nUnknown encoding")
		else
			print("\n====================================")
			print("Received ")
			print( mod_rcswitch.getReceivedValue() )
			print(" / ")
			print( mod_rcswitch.getReceivedBitlength() )
			print("bit ")
			print("Protocol: ")
			println( mod_rcswitch.getReceivedProtocol() )
			print("\n====================================")	
		end	
		
		mod_rcswitch.resetAvailable();
	end
	
end

local function startRc() 
	mod_rcswitch.start() 
	-- Receiver on interrupt 0 => that is pin #2
	mod_rcswitch.enableReceive(4)
	
	-- And then pings each 500 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 1000, 1, rcTimer)	
        --tmr.alarm(6, 1000, 1, rcTimer)
		
end

function module.start()
	mod_relays.start() 
	mqtt_start()
	startRc()
end

return module 