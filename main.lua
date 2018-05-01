log('Got IP: ', wifi.sta.getip())

foreach(file.list(), function(filename, size)
	local suf_start, suf_end = filename:find('.lua', 1, true)
	
	if suf_end ~= filename:len() then
		return
	end
	
	local pref_start, pref_end = filename:find('sensor_', 1, true)
	
	if pref_start == 1 then
		log('dofile sensor ' .. filename)
		dofile(filename)
	end
	
	local pref_start, pref_end = filename:find('provider_', 1, true)
	
	if pref_start == 1 then
		log('dofile provider ' .. filename)
		dofile(filename)
	end
end)

if not sensor_get_data then
    log('no sensor module loaded')
    return
end

if not provider_submit_data then
    log('no provider module loaded')
    return
end

function main_next_call(resp)
    log('scheduling next call')
	if cfg.debug then
		log('free ram', node.heap())
	end
    tmr.alarm(0, cfg.submit_interval or 15000, 1, main)
end

function main_got_data(data)
	if not data then
        log('no data received')
		main_next_call()
		return
	end

    log('got data')
    foreach(data, function(k, v)
		foreach(v, function(k1, v1)
			print(k, k1, v1)
		end)
    end)
	
	provider_submit_data(data, main_next_call)
end

function main()
	sensor_get_data(main_got_data)
end

sntp.sync(nil, function(sec, usec, server, info)
	log('time sync successful, ts=', sec, 'us=', usec, 'server=', server, 'stratum=', info.stratum)
	main()
end, function(code, err)
	log('time sync error, code=', code, 'error=', err)
	log('operation without correct time is not possible, stopping program')
end)
