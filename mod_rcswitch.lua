local module = {}  

RCSWITCH_MAX_CHANGES = 104

nReceivedValue = 0
nReceivedBitlength = 0
nReceivedDelay = 0
nReceivedProtocol = 0

--[RCSWITCH_MAX_CHANGES];
timings = {}
--60 default
nReceiveTolerance = 110

--HANDLE VARs
duration=0
changeCount=0
lastTime=0
repeatCount=0


local function rcswitch_start()
	
	for i=1,(RCSWITCH_MAX_CHANGES+1) do
		timings[i]=0
	end
	
 	nReceiverInterrupt = -1
	nTransmitterPin = -1
	nReceivedValue = 0
	nPulseLength = 350
	nRepeatTransmit = 10
	nReceiveTolerance = 60
	nProtocol = 1
end

local function diff(A, B)

	C = A-B
	if C < 0 then
		C=C*-1
	end
	
	return C
end


local function receiveProtocol1(fchangeCount)

	code = 0
	delay = timings[1] / 31
	delayTolerance = delay * nReceiveTolerance * 0.01

	--for (unsigned int i = 1; i<changeCount ; i=i+2)
	--fix fchangecount
	fchangeCount = fchangeCount+1
	for i = 2, fchangeCount, 2 do
		
--		va = timings[i]
--		vb = delay-delayTolerance
--		vc = delay+delayTolerance
		
--		print(va.." > ".. vb .. " < ".. vc)
		
--		vaa = timings[i+1]
--		vbb = delay*3-delayTolerance
--		vcc = delay*3+delayTolerance
		
--		print(vaa.." > ".. vbb .. " < ".. vcc)
		
		if (timings[i] > delay-delayTolerance and timings[i] < delay+delayTolerance and timings[i+1] > delay*3-delayTolerance and timings[i+1] < delay*3+delayTolerance) then
			
			--code = code << 1;
			code = bit.lshift(code, 1)
			-- print("pass 1")
			
			
		elseif (timings[i] > delay*3-delayTolerance and timings[i] < delay*3+delayTolerance and timings[i+1] > delay-delayTolerance and timings[i+1] < delay+delayTolerance) then

			code=code+1
			--code = code << 1;
			code = bit.lshift(code, 1)
						-- print("pass 2")
		else 
			-- Failed
			i = fchangeCount;
			code = 0;
						-- print("Fail 1")
		end
	end
	
	--code = code >> 1;
	code = bit.rshift(code, 1)
	
	-- fix fchangeCount
	fchangeCount=fchangeCount-1
	if (fchangeCount >47) then 
		if(code>0) then
			nReceivedValue = code
			nReceivedBitlength = fchangeCount / 2
			nReceivedDelay = delay
			nReceivedProtocol = 1
		end
	end

	if (code == 0) then
		return false
	else
		return true
	end
end

local function receiveWT450( fchangeCount)

	code = 0
	HighWidth = 2000
	LowWidth = 1000
	delayTolerance = 300
	bitLength=0

	--for (int i = 1; i<changeCount ; i++) 
	--fix table
	 fchangeCount= fchangeCount+1
	for i = 2, fchangeCount do 
		
		if (timings[i] > HighWidth-delayTolerance and timings[i] < HighWidth+delayTolerance ) then
			code = bit.lshift(code, 1)
			bitLength = bitLength+1
						-- print("pass 11")
		elseif ( timings[i] > LowWidth-delayTolerance and timings[i] < LowWidth+delayTolerance ) then
			if ( timings[i+1] > LowWidth-delayTolerance and timings[i+1] < LowWidth+delayTolerance) then
				code=code+1;
				code = bit.lshift(code, 1)
				i=i+1
				bitLength = bitLength+1
							-- print("pass 22")
			else
				-- Failed 
				i = fchangeCount
							-- print("fail 11")
			end
		else
			-- Failed
			i = fchangeCount
			if (i<50) then	
				code = 0
			end
		end

	end
		
--	code = code >> 1;
	code = bit.rshift(code, 1)
	
	--fix  fchangeCount
	 fchangeCount =  fchangeCount-1
	if ((fchangeCount > 50) and (bitLength==36)) then

		print("JH - mod_rcswitch TODO FIXX line: 138")
		-- there is no checksum of this unit, so using preamble and 2 fixed bits to check
		-- Preamble= 1100 (first four bits)
		--if( code & 0xC03000000ull)
		--{
		--	RCSwitch::nReceivedValue = code;
		--		RCSwitch::nReceivedBitlength = bitLength;
		--	RCSwitch::nReceivedDelay = 1000;
		--	RCSwitch::nReceivedProtocol = 5;
		--	return true;
		--}
		--else 
			return false
	else
		return false
	end
end

local function receiveLaCrosse(fchangeCount)
	code = 0;
    delay = timings[1] / 3
	
	--unsigned long delayTolerance = delay * RCSwitch::nReceiveTolerance * 0.01;    

	HighWidth = 1500
	LowWidth = 500
	delayTolerance = 200

	--for (int i = 1; i<changeCount ; i=i+2) 
	--fix
	fchangeCount=fchangeCount+1
	
	for i = 2, fchangeCount, 2 do 
	
		if (timings[i] > HighWidth-delayTolerance and timings[i] < HighWidth+delayTolerance)  then
			--code = code << 1;
			code = bit.lshift(code, 1)
		elseif ( timings[i] > LowWidth-delayTolerance and timings[i] < LowWidth+delayTolerance ) then
			code=code+1;
			--code = code << 1;
			code = bit.lshift(code, 1)
		else
			-- Failed
			i = fchangeCount;
			code = 0
		end
	end

	--code = code >> 1;
	code = bit.rshift(code, 1)
	
	--fix  fchangeCount
	 fchangeCount =  fchangeCount-1
	 
	if (fchangeCount > 80) then
		if (code>0) then
			nReceivedValue = code
			nReceivedBitlength = fchangeCount / 2
			nReceivedDelay = 500
			if (fchangeCount<100) then
				nReceivedProtocol = 3
			elseif (fchangeCount==104) then
				nReceivedProtocol = 4
			else
				nReceivedProtocol = 0
			end
		end
	end

	if (code == 0) then
		return false
	else
		return true
	end
	
end

local function handleInterrupt()
	
	--print("\ninterrupt")
	
	time = tmr.now()
	duration = time -lastTime


	if duration > 5000 and timings[1]>5000 then 
		repeatCount = repeatCount+1

		if repeatCount == 1 then
			if changeCount>20 then
				if changeCount>80 then
					if receiveLaCrosse(changeCount) == false then
						--failed
						print("receiveLaCrosse failed")
					end
				elseif changeCount>50 then
						if receiveWT450(changeCount) == false then
							-- failed
							print("receiveWT450 failed")
						end
				else 
					changeCount = changeCount-1
					if receiveProtocol1(changeCount) == false then
						-- failed
							--print("receiveProtocol1 failed"..changeCount)
					end		
				end
			end
			repeatCount = 0
		end
		changeCount = 0
	elseif duration > 5000 then
		changeCount = 0
		repeatCount=0
	end

	if changeCount >= RCSWITCH_MAX_CHANGES then
		changeCount = 0
		repeatCount = 0
	end
	changeCount=changeCount+1
	--print(changeCount)
	timings[changeCount] = duration
	lastTime = time
	
end


function module.enableReceive(interrupt)
	nReceiverInterrupt= pin
	if nReceiverInterrupt == interrupt then
		 return	-- prevent multiple creation of ISR. 31st May 2012 JP Liew
	 end
	
	nReceiverInterrupt= interrupt
		
	if nReceiverInterrupt ~= -1 then
		nReceivedValue = 0
		nReceivedBitlength = 0
			
		gpio.mode(nReceiverInterrupt,gpio.INT)
		gpio.trig(nReceiverInterrupt, "both", handleInterrupt)
	end	
end

function module.disableReceive()
	gipo.mode(nReceiverInterrupt, gpio.FLOAT)
	nReceiverInterrupt = -1
end

function module.available()
    return nReceivedValue ~= 0
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