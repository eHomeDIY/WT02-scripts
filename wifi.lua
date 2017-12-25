local was_in_setup = false

local function wifi_start_app()
    doifexists(cfg.main_script or 'main.lua')
end

local function wifi_connected()
    log('wifi connected')

    if was_in_setup then
        tmr.alarm(0, 10000, 0, function()
            wifi.setmode(wifi.STATION)
            wifi_start_app()
        end)
    else
        wifi_start_app()
    end
end

local function wifi_setup()
    log('wifi setup started')
    
    enduser_setup.start(function()
        log('wifi setup successful')
        was_in_setup = true
        wifi_check()
    end, function(err, str)
        log('enduser_setup: Err #' .. err .. ': ' .. str)
    end)
end

local function wifi_hasip()
    return wifi.sta.getip() ~= nil
end

function wifi_check()
    local count = 0
        
    log('wifi checking')
    
    if wifi_hasip() then
        wifi_connected()
    else
        tmr.alarm(0, cfg.wifi_check_interval or 1000, 1, function()
            log('wifi check', count)
            
            if wifi_hasip() then
                tmr.stop(0)
                log('wifi has ip')
                wifi_connected()
                return
            end

            if cfg.wifi_check_count ~= 0 and count >= (cfg.wifi_check_count or 60) then
                tmr.stop(0)
                log('wifi timeout waiting')
                wifi_setup()
                return
            end
            
            count = count + 1
        end)
    end
end

local function wifi_init()
    if wifi.getmode() == wifi.SOFTAP then
        log('wifi not set up')
        wifi_setup()
    else
        log('wifi set up')
        wifi_check()
    end
end

wifi_init()
