local TEMP_PIN = 1

--'
-- ds18b20 one wire example for NODEMCU (Integer firmware only)
-- NODEMCU TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Vowstar <vowstar@nodemcu.com>
--' 

return function (callback)
    ow.setup(TEMP_PIN)
    ow.reset_search(TEMP_PIN)
    local addr = ow.search(TEMP_PIN)
    if(addr == nil) then
        callback(nil)
        return
    end
    local addressCrc = ow.crc8(string.sub(addr,1,7))
    if (addressCrc == addr:byte(8)) then
        if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
            ow.reset(TEMP_PIN)
            ow.select(TEMP_PIN, addr)
            ow.write(TEMP_PIN, 0x44, 1)
            tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function()
                ow.reset(TEMP_PIN)
                ow.select(TEMP_PIN, addr)
                ow.write(TEMP_PIN,0xBE,1)
                local data = nil
                data = string.char(ow.read(TEMP_PIN))
                for i = 1, 8 do
                    data = data .. string.char(ow.read(TEMP_PIN))
                end
                local crc = ow.crc8(string.sub(data,1,8))
                if (crc == data:byte(9)) then
                    local t = (data:byte(1) + data:byte(2) * 256)
                    
                    -- handle negative temperatures
                    if (t > 0x7fff) then
                        t = t - 0x10000
                    end
                    
                    if (addr:byte(1) == 0x28) then
                        t = t * 625  -- DS18B20, 4 fractional bits
                    else
                        t = t * 5000 -- DS18S20, 1 fractional bit
                    end
                    
                    local sign = ""
                    if (t < 0) then
                        sign = "-"
                        t = -1 * t
                    end
                    
                    -- Separate integral and decimal portions, for integer firmware only
                    local t1 = string.format("%d", t / 10000)
                    local t2 = string.format("%04u", t % 10000)
                    local temp = sign .. t1 .. "." .. t2
                    callback(temp)
                else
                    print("Data CRC error")
                    callback(nil)
                end
            end)
            
        else
            print("Device family is not recognized.")
            callback(nil)
        end
    else
        print("CRC is not valid!")
        callback(nil)
    end
end
