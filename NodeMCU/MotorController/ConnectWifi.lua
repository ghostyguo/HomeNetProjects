-- connect Wifi
wifi.setmode(wifi.STATION)
wifi.sta.disconnect()
wifi.sta.config("SSID","password")
wifi.sta.autoconnect(1)
