local timerID=0
local pinLED=4
local lighton=0
--
-- flashLED()
--
function flashLED()
    if (wifi.sta.getip()==nil) then
        gpio.write(pinLED,gpio.LOW)      
    else
        if (lighton==1) then
            gpio.write(pinLED,gpio.HIGH)            
            lighton = 0
        else
            gpio.write(pinLED,gpio.LOW)                
            lighton = 1
        end    

    end
end

--
-- checkWifi()
--
function checkWifi()
    local ip = wifi.sta.getip()

    if(ip==nil) then
        print("Connecting...")
    else
        tmr.stop(timerID)
        print("Connected to AP!")
        print(ip)
        tmr.alarm(timerID, 500, tmr.ALARM_AUTO, flashLED)
        
        -- start user file
        dofile("Start.lua")
    end 
end

--
-- main()
--

-- init LED status
gpio.mode(pinLED, gpio.OUTPUT)  
gpio.write(pinLED,gpio.LOW)      
-- connect Wifi
dofile("ConnectWifi.lua")
--
tmr.stop(timerID) -- stop previous timer
tmr.unregister(timerID)
tmr.register(timerID, 5000, tmr.ALARM_AUTO,checkWifi)
if not tmr.start(timerID) then 
    print("tmr.start("..timerID..") failed!") 
end






