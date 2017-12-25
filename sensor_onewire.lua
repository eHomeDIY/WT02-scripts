local pins = cfg.onewire_pins or {3, 4}

local families = {
    [0x26] = 'DS2438',
    [0x28] = 'DS18B20',
}

local function onewire_get_devices()
    local devs = {}
    
	foreach(pins, function(idx, pin)
        ow.setup(pin)
        log('pin', pin)
        
        if ow.reset(pin) == 1 then
            log('has devices')
            ow.reset_search(pin)
            
            local addr = ow.search(pin)
            while addr do
                local crc = ow.crc8(addr)
                local revAddr = addr:reverse()
                local hexAddr = crypto.toHex(revAddr)
                if crc == 0 then
                    local sn = revAddr:sub(2, 7)
                    local family = revAddr:byte(8)
                    log(hexAddr, families[family], crypto.toHex(sn))
                    if family == 0x28 then
                        table.insert(devs, {
                            pin = pin,
                            addr = addr,
							sn = sn,
							family = family,
                        })
                    end
                else
                    log(hexAddr, 'crc error')
                end
                tmr.wdclr()
                addr = ow.search(pin)
            end
        else
            log('no devices')
            gpio.mode(pin, gpio.INPUT, gpio.FLOAT)
        end
    end)

    return devs
end

local function onewire_measure(devs)
    local result = {}
    
	foreach(devs, function(idx, dev)
        log('READ', dev.pin, crypto.toHex(dev.addr))
        
        local pin = dev.pin

        ow.reset(pin)
        ow.select(pin, dev.addr)
        ow.write(pin, 0x44, 1)
        
        tmr.delay(750000)
        
        ow.reset(pin)
        ow.select(pin, dev.addr)
        ow.write(pin, 0xBE, 1)
        
        local data = ''
        
        for i = 1, 9 do
            data = data .. string.char(ow.read(pin))
        end
        
        if (ow.crc8(data) == 0) then
            --log('CRC OK')

            local t = data:byte(2) * 256 + data:byte(1)

            if t > 32767 then
                t = t - 65536
            end
            
            local temperature = t * 625 / 10000

            if temperature ~= 85 then
				local model = families[dev.family]:lower()
				local sn = crypto.toHex(dev.sn)
                result[model .. '-' .. sn] = {
					temperature = temperature,
					updated = rtctime.get() * 1000,
				}
            end
        else
            log('CRC error')
        end

        tmr.wdclr()
	end)

    return result
end

function sensor_get_data(callback)
	callback(onewire_measure(onewire_get_devices()));
end

log('onewire sensor module loaded');
