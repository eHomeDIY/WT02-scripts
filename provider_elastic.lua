local deviceId = 'esp8266-' .. wifi.sta.getmac():gsub(':', '')

function provider_submit_data(data, callback)
    log('sending data to elastic')
    
    local ts = rtctime.get()
    local body = ''
    
    foreach(data, function(sensorName, sensorData)
        local indexLine = {
            index = {
                _index = cfg.elastic_index,
                _type = deviceId .. '-' .. sensorName,
            }
        }

        local ok, indexJson = pcall(sjson.encode, indexLine)
        if not ok then
            log('error encoding index json')
            return
        end

        local dataLine = {
            data = sensorData
        }
        
        local ok, dataJson = pcall(sjson.encode, dataLine)
        if not ok then
            log('error encoding data json')
            return
        end

        body = body .. indexJson .. '\n' .. dataJson .. '\n'
    end)
	
	if body.len() == 0 then
		callback()
		return
	end

    http.post(
        cfg.elastic_url .. '_bulk',
        'Authorization: ' .. cfg.elastic_auth .. '\r\nContent-Type: application/x-ndjson',
        body,
        function(status_code, body, headers)
            -- TODO: detect error, if any
            if cfg.debug then
                log(status_code, body)
                if headers then
                    foreach(headers, log)
                end
            end
            callback()
        end
    )
end

log('elastic provider module loaded');
