cfg = {}

doifexists('_cfg.lua')

foreach(file.list(), function(filename, size)
    if filename == '_cfg.lua' then
		return
	end

	local pref_start, pref_end = filename:find('_cfg.', 1, true)
	local suf_start, suf_end = filename:find('.lua', 1, true)

	if pref_start == 1 and suf_end == filename:len() then
		log('load config', filename)
		dofile(filename)
	end
end)
