--
--  MotorReport
--
--  Note: this module needs the float version firmware : 
--        nodemcu_float_0.9.6-dev_20150704.bin
--
local reportTimerID=2
local sqlServer="192.168.2.211"
local pinDHT=2
local pinRelay=7
local powerLimit=20

--
-- post()
--
function post(min,max,rms,t,h)
    local conn = nil

    -- receive()
    function receive(conn, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Posted OK");
        end
    end

    --connection()
    function connection(conn, payloadout)   
        local params = "&min="..min.."&max="..max.."&rms="..rms.."&temp="..t.."&hum="..h   --post paramaters
        -- Post        
        local httpString =  "POST /MotorReport.php HTTP/1.1\n" 
                        ..  "Host: "..sqlServer.."\n"
                        ..  "Content-Type: application/x-www-form-urlencoded\n"
                        ..  "Content-Length: "..string.len(params).."\n\n"
                        ..  params
        print("***post:\n"..httpString.."\n")
        conn:send(httpString)
    end

    -- 
    function disconnection(conn, payloadout)
        conn:close();
        collectgarbage();
    end
    
    -- create connection and register callback funciton
    conn = net.createConnection(net.TCP, 0) 
    conn:on("receive", receive) 
    conn:on("connection", connection) 
    conn:on("disconnection", disconnection)
    
    -- connect to server
    conn:connect(80,sqlServer)
end

-- variables
avgPower=0      --global
maxPower=0      --global    
minPower=0      --global
--
-- report() 
--
function report() 
    -- Motor
    local N=33
    local minP=1024    --10bit ADC
    local maxP=0
    for i=1,N do
        local sample = adc.read(0)
        if (sample>maxP) then
            maxP = sample
        end
        if (sample<minP) then
            minP = sample
        end
    end    
    local sumP=0
    local mean=(maxP+minP)/2 -- find the mean value
    for i=1,N do
        local amplitude=adc.read(0)-mean
        sumP=sumP+amplitude*amplitude
        tmr.delay(500) --sampling every 500us
    end
    avgPower = math.sqrt(sumP/N)
    maxPower=maxP
    minPower=minP
    -- DHT
    status, temp, humi, temp_dec, humi_dec = dht.read(pinDHT)
    local t=-999
    local h=-999
    if status == dht.OK then      
        t = temp + temp_dec/1000
        h = humi + humi_dec/1000        
        print(string.format("***DHT: Temperature : %.1f    Humidity : %.1f",t,h)) --debug
    elseif status == dht.ERROR_CHECKSUM then
        print( "***DHT: Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "***DHT: timed out." )
    end
    
    print("min="..minPower..", max="..maxPower..", rms="..avgPower.."temp="..t.."hum="..h)

    -- do works
    if (avgPower<powerLimit) then
        gpio.write(pinRelay, gpio.LOW) -- Pump motor is not running, turn the relay off
    end
    
    if(wifi.sta.getip()==nil) then
        print("***Motor: Wifi is not connected")
        --dofile("ConnectWifi.lua")
    else
        post(minPower,maxPower,avgPower, t, h)
    end 
end

--
-- main()
--
gpio.mode(pinRelay, gpio.OUTPUT) 
tmr.stop(reportTimerID) -- stop previous timer
tmr.unregister(reportTimerID)
tmr.register(reportTimerID, 10000, tmr.ALARM_AUTO, report)
--
if not tmr.start(reportTimerID) then 
     print("tmr.start("..reportTimerID..") failed!") 
end
--
print("start Motor Report")

