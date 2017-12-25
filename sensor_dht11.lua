local pins = cfg.dht11_pins or {3, 4}

function sensor_get_data(callback)
	local result = {}
	
	foreach(pins, function(index, pin)
		local status, temperature, humidity = dht.read11(pin)
		
		if status == dht.OK then
			log('DHT11 pin', pin, 't=', temperature, '°C, h=', humidity, '%')
			
			result['dht11-' .. pin] = {
				temperature = temperature,
				humidity = humidity,
				updated = rtctime.get() * 1000,
			}
		end
	end)
	
	callback(result)
end

log('dht11 sensor module loaded');
