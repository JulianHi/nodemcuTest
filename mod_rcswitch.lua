local module = {}  



--static const RCSwitch::Protocol PROGMEM proto[] = {
--    { 350, {  1, 31 }, {  1,  3 }, {  3,  1 } },    // protocol 1
--    { 650, {  1, 10 }, {  1,  2 }, {  2,  1 } },    // protocol 2
--    { 100, {  1, 71 }, {  4, 11 }, {  9,  6 } },    // protocol 3
--    { 380, {  1,  6 }, {  1,  3 }, {  3,  1 } },    // protocol 4
--    { 500, {  6, 14 }, {  1,  2 }, {  2,  1 } },    // protocol 5
 --};

 proto = {
	 --    { 350, {  1, 31 }, {  1,  3 }, {  3,  1 } },    // protocol 1
	 {pulseLength = 350, syncFactor = {high=1, low=31}, zero = {high=1, low=3}, one = {high=3, low=1}},
	 --   { 650, {  1, 10 }, {  1,  2 }, {  2,  1 } },    // protocol 2
 	 {pulseLength = 650, syncFactor = {high=1, low=10}, zero = {high=1, low=2}, one = {high=2, low=1}},
	 --    { 100, {  1, 71 }, {  4, 11 }, {  9,  6 } },    // protocol 3
  	 {pulseLength = 100, syncFactor = {high=1, low=71}, zero = {high=4, low=11}, one = {high=9, low=6}}
 }



nTransmitterPin = -1
nRepeatTransmit = 10
protocol = 1
nReceiverInterrupt = -1
nReceiveTolerance = 60

nReceivedValue = 0
nReceivedBitlength=0



--MaxChanges
RCSWITCH_MAX_CHANGES=67
-- timings array
timings= {} 
nSeparationLimit = 4600;


-- handeInterrupt
duration=0;
changeCount=0;
lastTime=0;
repeatCount=0;

nReceivedValue=0;
nReceivedBitlength=0;
nReceivedDelay=0;
nReceivedProtocol=0;

local function rcswitch_start()
	
	for i=0,i<RCSWITCH_MAX_CHANGES, i=i+1 do
		timings[i]=0
	end
	
end

local function enableReceive(pin)
	nReceiverInterrupt= pin
	
	if nReceiverInterrupt != -1 then
		nReceivedValue=0
		nReceivedBitlength=0
		
		gpio.mode(nReceiverInterrupt,gpio.INT)
		gpio.trig(nReceiverInterrupt, "both", handleInterrupt)
	end
	
end

local function handleInterrupt()
	time = tmr.now()
	duration = time -lastTime
	
	if duration > nSeparationLimit and diff(duration, timings[0]) < 200 then
		repeatCount=repeatCount+1
		changeCount=changeCount-1
		
		if repeatCount == 2 then
			if receiveProtocol(1, changeCount) == false then
			        if receiveProtocol(2, changeCount) == false then
			        	if receiveProtocol(3, changeCount) == false then
					  --failed
				  	end
				end
			  end
			  repeatCount = 0
		end
		changeCount = 0
	elseif duration > nSeparationLimit then
		changeCount = 0
	end
	
	if changeCount >= RCSWITCH_MAX_CHANGES then
		changeCount = 0
		repeatCount =0
	end
	
	timings[changeCount] = duration
	changeCount = changeCount+1
	lastTime = time	
end

local function receiveProtocol(p, changeCount)
 	    pro = proto[p-1]

	    code = 0;
	    delay = timings[0] / pro.syncFactor.low;
	    delayTolerance = delay * nReceiveTolerance / 100;

	    for i = 1, i < changeCount, i = i + 2 do
	        --code <<=1;
		bit.lshift(code, 1)
	        if (diff(timings[i], delay * pro.zero.high) < delayTolerance and
	            diff(timings[i + 1], delay * pro.zero.low) < delayTolerance) then
	            -- zero
		elseif (diff(timings[i], delay * pro.one.high) < delayTolerance and
	                   diff(timings[i + 1], delay * pro.one.low) < delayTolerance) then
	            -- one
	            --code |= 1;
		    bit.bor(code, 1)
	        else
	            -- Failed
	            return false;
	    	end
	end

	    if changeCount > 6 then    -- ignore < 4bit values as there are no devices sending 4bit values => noise
	        nReceivedValue = code;
	        nReceivedBitlength = changeCount / 2;
	        nReceivedDelay = delay;
	        nReceivedProtocol = p;
	    end

	    return true;	
end

local function diff(A, B)

	C = A-B
	if C < 0 then
		C=C*-1
	end
	
	return C
end

function module.available()
    return nReceivedValue != 0;
end

function module.getReceivedValue()
    return nReceivedValue;
end

function module.getReceivedBitlength()
  return nReceivedBitlength
end

function module.getReceivedProtocol()
  return nReceivedProtocol
end

function module.resetAvailable()
  nReceivedValue = 0
end

function module.start()
	rcswitch_start()
end

return module 