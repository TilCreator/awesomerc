-- aweswt.lua
-- Application switcher using dmenu
--

local M = {}

local dmenu = "dmenu -nf '#888888' -nb '#222222' -sf '#ffffff' -sb '#285577' -p 'switch to application:' -fn 'Terminus 8'  -i"

local get_out, get_input, _switch

-- switch with window titles
M.switch = function()
	_switch(true)
end

-- switch with client instance and class
M.switch_class = function()
	_switch(false)
end

get_out = function (a)
	local  f = io.popen(a)
	t = {}
	for line in f:lines() do
		table.insert(t, line)
	end
	return t
end

get_input = function (a)
	s1 = 'echo "' .. a .. '" | ' .. dmenu
	return get_out(s1)
end

_switch = function(use_name)
	local clients = client.get()

	if table.getn(clients) == 0 then 
		return
	end

	local client_list_table = {}
	local apps = {}

	for key, client in pairs(clients) do
		local app

		if use_name then
			app = client['name']
		else
			app = key .. ':' .. client['instance'] .. '.' .. client['class']
		end

		table.insert(client_list_table, app)
		apps[app] = client
	end

	table.sort(client_list_table, function(a, b)
		return string.lower(a) < string.lower(b)
	end)
	local client_list = table.concat(client_list_table, "\n")

	local client_selected = apps[get_input(client_list)[1]]
	if client_selected then
		local ctags = client_selected:tags()
		awful.tag.viewonly(ctags[1])
		client.focus = client_selected
		client_selected:raise()
	end
end

return M
