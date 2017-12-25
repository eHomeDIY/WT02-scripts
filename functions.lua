function log(...)
    if cfg.debug then
        print(unpack(arg))
    end
end

function foreach(tbl, cb)
    for k, v in pairs(tbl) do
        cb(k, v)
    end
end

function file_exists(filename)
    local check = file.open(filename)

    if check then
        file.close()
    end

    return check or false
end

function doifexists(filename)
	return file_exists(filename) and dofile(filename) or nil
end

function bit_force(value, pos, state)
    return bit[state and 'set' or 'clear'](value, pos)
end

function bytes2short(bytes)
    if bytes == nil then
        return nil
    end

    return bit.bor(bit.lshift(bytes:byte(1), 8), bytes:byte(2))
end
