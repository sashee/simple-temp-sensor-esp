tmr.alarm(0, 5000, tmr.ALARM_SINGLE, function()
    require("main")()
end)
