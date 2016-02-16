-- connect Wifi
wifi.setmode(wifi.STATION)
wifi.sta.config("MyStation","MyPasswd")
wifi.sta.autoconnect(1)
