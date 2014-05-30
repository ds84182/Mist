function protect(dir,env)
	local function proxyFile(dir,file)
		return dir.."/"..file
	end
	local function createFSOverride(func)
		return function(f,...)
			if type(f) == "string" then
				f = proxyFile(dir,f)
			end
			return func(f,...)
		end
	end
	local fsOverrideList = {
		audio =
		{
			"newSource"
		},
		filesystem =
		{
			"append",
			"createDirectory",
			"exists",
			"getDirectoryItems",
			"getLastModified",
			"getSize",
			"isDirectory",
			"isFile",
			"lines",
			"newFile",
			"read",
			"remove",
			"unmount",
			"write",
		},
		graphics =
		{
			"newFont",
			"newImage",
			"newImageFont",
			"setNewFont",
		},
		image =
		{
			"newImageData",
			"newCompressedData",
		},
		sound =
		{
			"newDecoder",
			"newSoundData",
		},
		timer = {},
		thread = {},
	}

	for i, v in pairs(fsOverrideList) do
		local e = env.love[i]
		if not e then
			require("love."..i)
			env.love[i] = deepcopy(love[i])
			e = env.love[i]
		end
		for ri, rv in pairs(v) do
			print("replace love."..i.."."..rv)
			e[rv] = createFSOverride(e[rv])
		end
	end

	env.love.filesystem.mount = function(m,d,...)
		m = proxyFile(dir,m)
		d = proxyFile(dir,d)
		return love.filesystem.mount(m,d,...)
	end

	env.love.filesystem.load = function(n)
		n = proxyFile(dir,n)
		local f = love.filesystem.load(n)
		setfenv(f,proxy)
		return f
	end
	
	local _thread = {}
	function _thread:getError()
		return self.thread:getError()
	end
	function _thread:isRunning()
		return self.thread:isRunning()
	end
	function _thread:start(...)
		return self.thread:start(self.file,dir,...)
	end
	function _thread:wait()
		return self.thread:wait()
	end
	
	env.love.thread.newThread = function(file)
		local rfile = proxyFile(dir,file)
		--create thread with libgameload_thread.lua as the source file
		local rthread = love.thread.newThread("libgameload_thread.lua")
		local th = {thread = rthread, file = rfile}
		return setmetatable(th,{__index=_thread})
	end
	
	env.love.thread.getChannel = function(chan)
		return love.thread.getChannel("game_"..chan)
	end

	env.require = function(s)
		local fd = dir.."/"..(s:gsub("%.", "/"))..".lua"
		print(fd)
		if love.filesystem.exists(fd) then
			local f = love.filesystem.load(fd)
			setfenv(f,env)
			local t = {pcall(f)}
			if t[1] then
				table.remove(t,1)
				return unpack(t)
			else
				error(t[2],2)
			end
		end
		fd = dir.."/"..(s:gsub("%.", "/")).."/init.lua"
		print(fd)
		if love.filesystem.exists(fd) then
			local f = love.filesystem.load(fd)
			setfenv(f,env)
			local t = {pcall(f)}
			if t[1] then
				table.remove(t,1)
				return unpack(t)
			else
				error(t[2],2)
			end
		end
		local t = {pcall(require,s)}
		if t[1] then
			table.remove(t,1)
			return unpack(t)
		else
			error(t[2],2)
		end
	end

	env.love.filesystem.setIdentity = function() end --STUBIT, Game is able to mess with this

	env.string = string --compat with flappybirddeluxe, and other games who attempt to modify the string metatable via the string lib

	env._G = env
end
