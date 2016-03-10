

-- I/O pins
pinDHT=2    --DHT data
pinRelay=3  --Relay
pinLED=4    --onboard LED
pinSwitch=5 --Manual Switch

-- System Time
sec=-1  
min=-1  
hour=-1 

-- motor poert
avgPower=0      --global
maxPower=0      --global    
minPower=0      --global

-- SQL Server
sqlServer="220.133.170.200"

-- Timer resource allocation
flashLedTimerID=0
reportTimerID=1
systemTimerID=2

--
--
--
local lighton=0
--
-- flashLED()
--
function flashLED()
    if (wifi.sta.getip()~=nil) then
        if (lighton==1) then
            gpio.write(pinLED,gpio.HIGH)            
            lighton = 0
        else
            gpio.write(pinLED,gpio.LOW)                
            lighton = 1
        end    
    else
        gpio.write(pinLED,gpio.LOW) 
    end
end

--
-- checkWifi()
--
function checkWifi()
    if (wifi.sta.getip()==nil) then  -- connected?
        print("Connecting...")
    else
        tmr.stop(flashLedTimerID)
        print("Connected to AP!")
        print(wifi.sta.getip())
        tmr.alarm(flashLedTimerID, 500, tmr.ALARM_AUTO, flashLED)
        
        -- start user file
        dofile("Start.lua")
    end 
end

--
-- main()
--

-- init I/O pin
gpio.mode(pinSwitch, gpio.INPUT, gpio.PULLUP)
gpio.mode(pinLED, gpio.OUTPUT)  
gpio.write(pinLED,gpio.LOW)         --Turn off LED
gpio.mode(pinRelay, gpio.OUTPUT)  
gpio.write(pinRelay,gpio.LOW)       --Turn off relay
-- connect Wifi
dofile("ConnectWifi.lua")
--
tmr.stop(flashLedTimerID) -- stop previous timer
tmr.unregister(flashLedTimerID)
tmr.register(flashLedTimerID, 5000, tmr.ALARM_AUTO,checkWifi)
if not tmr.start(flashLedTimerID) then 
    print("tmr.start("..flashLedTimerID..") failed!") 
end






