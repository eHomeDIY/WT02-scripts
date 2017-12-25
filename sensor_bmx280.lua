local speed = i2c.setup(0, 3, 4, i2c.SLOW)

if speed == 0 then
    log('i2c setup error')
    return
end

log('i2c setup successful @', speed)

local sensorType = bme280.setup(nil, nil, nil, 0)

if not sensorType then
    log('bme280 setup error (no sensor?)')
    return
end

local sensorTypes = {'BMP280', 'BME280'}

log('found sensor ' .. sensorTypes[sensorType])

function sensor_get_data(callback)
    bme280.startreadout(0, function ()
        local T, P, H = bme280.read()

        if not T or not P or not H then
            log('bme280 read failed')
            return callback()
        end
		
		local result = {}
		local model = sensorTypes[sensorType]:lower()
		result[model] = {
			temperature = T / 100,
			pressure = P / 1000,
			humidity = H / 1000,
			updated = rtctime.get() * 1000,
		}
		
        callback(result)
    end)
end

log('bmx280 sensor module loaded');
