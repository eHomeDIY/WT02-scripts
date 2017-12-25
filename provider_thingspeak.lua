function provider_submit_data(data, callback)
	local fields = ''
	local index = 1
	
	foreach(data, function(sensorName, sensorData)
		foreach(sensorData, function(dataType, value)
			if value and index < 9 then
				fields = fields .. '&field' .. index .. '=' .. value
				index = index + 1
			end
		end)
	end)

    log('sending data to thingspeak')
	
	http.get('http://api.thingspeak.com/update?api_key=' ..
	    cfg.thingspeak_api_key .. fields, nil, callback)
end

log('thingspeak provider module loaded');
