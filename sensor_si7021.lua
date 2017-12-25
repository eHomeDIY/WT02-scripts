local speed = i2c.setup(0, 3, 4, i2c.SLOW)

if speed == 0 then
    log('i2c setup error')
    return
end

log('i2c setup successful @', speed)

if pcall(si7021.setup) then
    log('si7021 setup successful')
else
    log('si7021 setup failed - no device?')
    return
end

if cfg.debug then
	local sna, snb = si7021.serial()
	log(string.format("Device: Si70%d\nSN: 0x%08X 0x%08X", bit.rshift(snb, 24), sna, snb))
	
	local fwrev = si7021.firmware()
	log(string.format("FW: %1.1f", fwrev == 0x20 and 2 or 1))
end

function sensor_get_data(callback)
    local humidity, temperature = si7021.read()

    if not humidity or not temperature then
        log('si7021 data read failed')
        return callback()
    end
	
	local sna, snb = si7021.serial()
    
    if not sna or not snb then
        log('si7021 serial read failed')
        return callback()
    end
	
	result = {}
	local model = 'si70' .. string.format('%d', bit.rshift(snb, 24))
	local sn = string.format('%08x', sna)
	result[model .. '-' .. sn] = {
		temperature = temperature,
		humidity = humidity,
		updated = rtctime.get() * 1000,
	}
    
	callback(result)
end

log('si7021 sensor module loaded');
