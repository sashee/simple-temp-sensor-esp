local WRITE_KEY = "WRITE_KEY"

local function sendToThingSpeak(temp)
    print("Sending temperature: "..temp);
    
    local connout = nil
    connout = net.createConnection(net.TCP, 0)
 
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Posted OK");
        end
    end)
 
    connout:on("connection", function(connout, payloadout)
 
        connout:send("GET /update?api_key="..WRITE_KEY.."&field1=" .. temp
        .. " HTTP/1.1\r\n"
        .. "Host: api.thingspeak.com\r\n"
        .. "Connection: close\r\n"
        .. "Accept: */*\r\n"
        .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
        .. "\r\n")
    end)
 
    connout:on("disconnection", function(connout, payloadout)
        connout:close();
        collectgarbage();
    end)
 
    connout:connect(80,'api.thingspeak.com')
end

return function()
    require("gettemp")(function(temp)
        if (temp ~= nil) then
            sendToThingSpeak(temp)
        else
            print("Failed to get temperature")
        end
    end)
end
