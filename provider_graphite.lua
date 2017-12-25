local deviceId = wifi.sta.getmac():gsub(':', '')
local client = net.createConnection(net.TCP, 0)
local message = ''
local callbackPtr = nil

function on_connect()
    log('connected to graphite, sending data')
    client:send(message)
end

function on_sent()
    log('data sent, disconnecting')
    client:close()

    if callbackPtr then
        callbackPtr()
    end
end

client:on('connection', on_connect)
client:on('sent', on_sent)

function provider_submit_data(data, callback)
    log('sending data to graphite')
	
	local ts = rtctime.get()
    message = ''
    
	foreach(data, function(sensorName, sensorData)
		foreach(sensorData, function(dataType, value)
			if value then
				local key = 'test.sensor.' .. deviceId .. '.' .. sensorName .. '.' .. dataType
				message = message .. key .. ' ' .. value .. ' ' .. ts .. '\n'
			end
		end)
    end)

    log('connecting to graphite')
    callbackPtr = callback
    client:connect(cfg.graphite_port or 2003, cfg.graphite_host)
end

log('graphite provider module loaded');
