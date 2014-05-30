--libgameload in a thread--
require "libgameload_env"

local args = {...}
local file, dir = table.remove(args,1), table.remove(args,1)

deepcopy = function(tab,cache)
	cache = cache or {}
	local nt = {}
	cache[tab] = nt
	for i, v in pairs(tab) do
		local ni, nv = i, v
		if type(i) == "table" then
			ni = cache[i] or deepcopy(i,cache)
		end
		if type(v) == "table" then
			nv = cache[v] or deepcopy(v,cache)
		end
		nt[ni] = nv
	end
	return nt
end
local env = deepcopy(_G)
protect(dir, env)

local f = love.filesystem.load(file)
setfenv(f,env)
f()
