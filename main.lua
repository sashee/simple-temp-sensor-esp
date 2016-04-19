local WIFI_SSID = "SSID"
local WIFI_PASSWORD = "PASS"

return function()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(WIFI_SSID, WIFI_PASSWORD)

    tmr.alarm(1, 60000, tmr.ALARM_AUTO, function()
        require("sendtemp")()
    end)
end
