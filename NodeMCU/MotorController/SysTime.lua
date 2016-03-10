-- retrieve the current time from Google
-- tested on NodeMCU 0.9.5 build 20150108

local systemTimerID=_G["systemTimerID"] 
--
-- syncSystemTime()
--
function syncSystemTime()
    
    local actionFlag=false  --set to true if timer action in going
    local actionPeriod = 5 --within 5 seconds    
    local conn=net.createConnection(net.TCP, 0) 
    
    conn:on("connection",
        function(conn, payload)
            conn:send("HEAD / HTTP/1.1\r\n".. 
                "Host: google.com\r\n"..
                "Accept: */*\r\n"..
                "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
                "\r\n\r\n") 
        end)
            
    conn:on("receive", 
        function(conn, payload)
            pos =  string.find(payload,"Date: ")      
            googleTimeString = string.sub(payload,pos+6,pos+30)
            dateString=string.sub(googleTimeString,0,16)
            timeString=string.sub(googleTimeString,18,30)
            hour = (tonumber(string.sub(timeString,1,2))+8)%24  -- Taipei GMT+8
            min = tonumber(string.sub(timeString,4,5))
            sec = tonumber(string.sub(timeString,7,8))
            --print("googleTimeStringg="..googleTimeString)    
            --print("dateString="..dateString..'#')
            --print("timeString="..timeString..'#') 
            conn:close()
        end) 

    -- Adjust system time
    sec=sec+1
    if (sec>=60) then
        sec = 0
        min = min + 1
    end
    if (min>=60) then
        min = 0
        hour = hour + 1
    end
    if (hour>=24) then
        hour = 0
    end

    -- do works
    if (hour==7 and min==0 and sec<actionPeriod and actionFlag==false) then
        gpio.write(pinRelay, gpio.HIGH) -- turn on the pump motor relay
        actionFlag=true
    end         
    if (hour==7 and min==30 and sec<actionPeriod and actionFlag==false) then
        gpio.write(pinRelay, gpio.LOW) -- turn off the pump motor relay
        actionFlag=true
    end
    if (hour==11 and min==0 and sec<actionPeriod and actionFlag==false) then
        gpio.write(pinRelay, gpio.HIGH) -- turn on the pump motor relay
        actionFlag=true
    end
    if (hour==11 and min==20 and sec<actionPeriod and actionFlag==false) then
        gpio.write(pinRelay, gpio.LOW) -- turn off the pump motor relay
        actionFlag=true
    end
    if (hour==17 and min==0 and sec<actionPeriod and actionFlag==false) then
        gpio.write(pinRelay, gpio.HIGH) -- turn on the pump motor relay
        actionFlag=true
    end               
    if (hour==17 and min==20 and sec<actionPeriod and actionFlag==false) then
        gpio.write(pinRelay, gpio.LOW) -- turn off the pump motor relay
        actionFlag=true
    end

    if (hour==0 and min==0 and sec<actionPeriod) then 
        dofile("Stop.lua")
        tmr.delay(1000000)
        node.restart() --restart to rejoin the network everyday
    end

    if (sec>=actionPeriod) then
        actionFlag=false -- not in the action period
    end    
    
    --
    -- switch ON
    if (gpio.read(pinSwitch)==0) then --Switch Pressed?
        gpio.write(pinRelay, gpio.HIGH)
    end

    -- NTP sync every minutes
    if (sec==0) then
        if (wifi.sta.getip()~=nil) then  -- Wifi connected?
            conn:connect(80,'google.com.tw') 
        else    
            print("Network not connected...")
            dofile("ConnectWifi.lua")
        end
    end    
    print(hour..":"..min..":"..sec)  -- report time
end

--
-- main()
--
tmr.stop(systemTimerID) -- stop previous timer
tmr.unregister(systemTimerID)
tmr.register(systemTimerID, 1000, tmr.ALARM_AUTO,syncSystemTime)
if not tmr.start(systemTimerID) then 
    print("tmr.start("..systemTimerID..") failed!") 
end
--
print("start SysTime Service")



