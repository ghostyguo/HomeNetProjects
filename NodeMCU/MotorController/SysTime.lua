-- retrieve the current time from Google
-- tested on NodeMCU 0.9.5 build 20150108

local timerID=3
local poolTick=0
local pinRelay=7

min=0   --global
sec=0   --global
hour=0  --global

--
-- syncGoogleTime()
--
function syncGoogleTime()
    conn=net.createConnection(net.TCP, 0) 
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
    if (hour==7 and min==0 and sec<10) then
        gpio.write(pinRelay, gpio.HIGH) -- turn on the pump motor relay
    end
    if (hour==11 and min==0 and sec<10) then
        gpio.write(pinRelay, gpio.HIGH) -- turn on the pump motor relay
    end
    if (hour==17 and min==0 and sec<10) then
        gpio.write(pinRelay, gpio.HIGH) -- turn on the pump motor relay
    end
               
    if (poolTick<10) then
        poolTick = poolTick+1
    else
        poolTick = 0
        if (wifi.sta.getip()==nil) then
            print("Network not connected...")
        else
            conn:connect(80,'google.com.tw') 
        end
    end    
    print(hour..":"..min..":"..sec)  -- report time
end

--
-- main()
--
gpio.mode(pinRelay, gpio.OUTPUT) 
tmr.stop(timerID) -- stop previous timer
tmr.unregister(timerID)
tmr.register(timerID, 1000, tmr.ALARM_AUTO,syncGoogleTime)
if not tmr.start(timerID) then 
    print("tmr.start("..timerID..") failed!") 
end
--
print("start SysTime Service")



