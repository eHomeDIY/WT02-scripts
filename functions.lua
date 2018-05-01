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
