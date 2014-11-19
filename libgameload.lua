--libgameload: Allows you to load another Love2D game within a Love2D game--
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

require "libgameload_env"

function loadgame(dir, mount, compat, nocustomwindow)
	local app = {}
	--create env proxy for fs--
	local env = deepcopy(_G)

	dir = dir or "game"
	if mount then
		love.filesystem.mount(mount,dir)
	end
	love.filesystem.createDirectory(dir) --creates a directory for this game's save files

	protect(dir,env)

	local dummy = function()end
	env.love.load = dummy
	env.love.update = dummy
	env.love.draw = dummy

	env.love.focus = dummy
	env.love.keypressed = dummy
	env.love.keyreleased = dummy
	env.love.mousefocus = dummy
	env.love.mousepressed = dummy
	env.love.mousereleased = dummy
	env.love.quit = dummy
	env.love.resize = dummy
	env.love.textinput = dummy
	env.love.threaderror = dummy
	env.love.visible = dummy

	print("Installed overrides")

	local conf = love.filesystem.exists(dir.."/conf.lua") and love.filesystem.load(dir.."/conf.lua")
	local tConf = {window={},modules={}}
	local function defConf(t)
		t.identity = nil                   -- The name of the save directory (string)
		t.version = "0.9.1"                -- The LÖVE version this game was made for (string)
		t.console = false                  -- Attach a console (boolean, Windows only)

		t.window.title = "Untitled"        -- The window title (string)
		t.window.icon = nil                -- Filepath to an image to use as the window's icon (string)
		t.window.width = 800               -- The window width (number)
		t.window.height = 600              -- The window height (number)
		t.window.borderless = false        -- Remove all border visuals from the window (boolean)
		t.window.resizable = false         -- Let the window be user-resizable (boolean)
		t.window.minwidth = 1              -- Minimum window width if the window is resizable (number)
		t.window.minheight = 1             -- Minimum window height if the window is resizable (number)
		t.window.fullscreen = false        -- Enable fullscreen (boolean)
		t.window.fullscreentype = "normal" -- Standard fullscreen or desktop fullscreen mode (string)
		t.window.vsync = true              -- Enable vertical sync (boolean)
		t.window.fsaa = 0                  -- The number of samples to use with multi-sampled antialiasing (number)
		t.window.display = 1               -- Index of the monitor to show the window in (number)
		t.window.highdpi = false           -- Enable high-dpi mode for the window on a Retina display (boolean). Added in 0.9.1
		t.window.srgb = false              -- Enable sRGB gamma correction when drawing to the screen (boolean). Added in 0.9.1
		t.window.canvas = love.graphics.newCanvas(800,600)

		t.modules.audio = true             -- Enable the audio module (boolean)
		t.modules.event = true             -- Enable the event module (boolean)
		t.modules.graphics = true          -- Enable the graphics module (boolean)
		t.modules.image = true             -- Enable the image module (boolean)
		t.modules.joystick = true          -- Enable the joystick module (boolean)
		t.modules.keyboard = true          -- Enable the keyboard module (boolean)
		t.modules.math = true              -- Enable the math module (boolean)
		t.modules.mouse = true             -- Enable the mouse module (boolean)
		t.modules.physics = true           -- Enable the physics module (boolean)
		t.modules.sound = true             -- Enable the sound module (boolean)
		t.modules.system = true            -- Enable the system module (boolean)
		t.modules.timer = true             -- Enable the timer module (boolean)
		t.modules.window = true            -- Enable the window module (boolean)
	end
	defConf(tConf)
	if conf then setfenv(conf, env) conf() env.love.conf(tConf) end
	print("CONF")
	local function getOffset()
		return 0,0
	end
	if not nocustomwindow then
		--we have config--
		--recreate love.window to use config values--
		function env.love.window.getDimensions()
			return tConf.window.width, tConf.window.height
		end
		function env.love.window.getFullscreen()
			return tConf.window.fullscreen, tConf.window.fullscreentype
		end
		function env.love.window.getWidth()
			return tConf.window.width
		end
		function env.love.window.getHeight()
			return tConf.window.height
		end
		function env.love.window.getIcon()
			return tConf.window.icon
		end
		function env.love.window.getMode()
			return tConf.window.width, tConf.window.height, tConf.window
		end
		function env.love.window.getTitle()
			return tConf.window.title
		end
		function env.love.window.setFullscreen(t,m)
			tConf.window.fullscreen = t
			tConf.window.fullscreentype = m or "normal"
		end
		function env.love.window.setIcon(id)
			tConf.window.icon = id
		end
		function env.love.window.setMode(w,h,flags)
			tConf.window.width = w
			tConf.window.height = h
			for i, v in pairs(flags or {}) do tConf.window[i] = v end
		end
		function env.love.window.setTitle(t)
			tConf.window.title = t
		end

		function env.love.graphics.setCanvas(c)
			love.graphics.setCanvas(c and c or tConf.window.canvas)
		end
		function env.love.graphics.clear()
			tConf.window.canvas:clear()
		end
		--[[function env.love.graphics.present()
			local oc = love.graphics.getCanvas()
			love.graphics.setCanvas()
			app.draw()
			love.graphics.present()
			love.graphics.setCanvas(oc)
		end]]
	
		local function getOffset()
			local w,h = love.window.getDimensions()
			return (w/2)-(tConf.window.width/2),(h/2)-(tConf.window.height/2)
		end
	
		function env.love.mouse.getPosition()
			local ox, oy = getOffset()
			local x, y = love.mouse.getPosition()
			return x-ox, y-oy
		end
	
		function env.love.mouse.getX()
			local ox, oy = getOffset()
			local x, y = love.mouse.getPosition()
			return x-ox
		end
	
		function env.love.mouse.getY()
			local ox, oy = getOffset()
			local x, y = love.mouse.getPosition()
			return y-oy
		end
	
		function env.love.mouse.setPosition(x,y)
			local ox, oy = getOffset()
			love.mouse.setPosition(ox+x,oy+y)
		end
	
		function env.love.mouse.setX(x)
			local ox, oy = getOffset()
			love.mouse.setX(ox+x)
		end
	
		function env.love.mouse.setY(y)
			local ox, oy = getOffset()
			love.mouse.setX(oy+y)
		end
	else
		love.window.setMode(tConf.window.width, tConf.window.height, 
		{
			fullscreen = tConf.window.fullscreen,
			vsync = tConf.window.vsync,
			fsaa = tConf.window.fsaa,
			resizeable = tConf.window.resizeable,
			borderless = tConf.window.borderless,
			centered = tConf.window.centered
		})
	end
	
	if compat then
		require("eightpointoh")(env)
	end

	local main = love.filesystem.load(dir.."/main.lua")
	-- we have main entry point --
	-- execute! --
	setfenv(main, env)
	print("Proxied main")
	main()
	print("Main ran.")
	
	local function callIfNotNil(func,...)
		if func then
			return func(...)
		end
	end

	function app.load(...)
		callIfNotNil(env.love.load,...)
	end

	function app.update(...)
		callIfNotNil(env.love.update,...)
	end

	function app.draw(...)
		if not nocustomwindow then
			if (not tConf.window.canvas) or (tConf.window.canvas:getWidth() ~= tConf.window.width or tConf.window.canvas:getHeight() ~= tConf.window.height) then
				tConf.window.canvas = love.graphics.newCanvas(tConf.window.width,tConf.window.height)
			end
			local obc = love.graphics.getCanvas()
			tConf.window.canvas:clear()
			tConf.window.canvas:renderTo(env.love.draw or function() end)
			local w,h = love.window.getDimensions()
	canvas:clear(old.bgcolor)
	canvas:renderTo(function() prev:draw() end)
			love.graphics.setCanvas(obc)
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("fill",0,0,w,h)
			love.graphics.setColor(love.graphics.getBackgroundColor())
			love.graphics.rectangle("fill",(w/2)-(tConf.window.width/2),(h/2)-(tConf.window.height/2),tConf.window.canvas:getDimensions())
			love.graphics.setColor(255,255,255)
			love.graphics.draw(tConf.window.canvas,(w/2)-(tConf.window.width/2),(h/2)-(tConf.window.height/2))
		else
			callIfNotNil(env.love.draw,...)
		end
	end

	function app.focus(...)
		callIfNotNil(env.love.focus,...)
	end

	function app.keypressed(...)
		callIfNotNil(env.love.keypressed,...)
	end
	function app.keyreleased(...)
		callIfNotNil(env.love.keyreleased,...)
	end

	function app.mousefocus(f)
		callIfNotNil(env.love.mousefocus,f)
	end
	function app.mousepressed(x,y,b)
		local ox, oy = getOffset()
		callIfNotNil(env.love.mousepressed,x-ox,y-oy,b)
	end
	function app.mousereleased(x,y,b)
		local ox, oy = getOffset()
		callIfNotNil(env.love.mousereleased,x-ox,y-oy,b)
	end

	function app.quit(...)
		callIfNotNil(env.love.quit,...)
		if mount then love.filesystem.unmount(dir) end
	end

	function app.resize(...)
		callIfNotNil(env.love.resize,...)
	end

	function app.textinput(...)
		callIfNotNil(env.love.textinput,...)
	end

	function app.threaderror(...)
		--TODO: Filter thread to see if it belongs to the game
		callIfNotNil(env.love.threaderror,...)
	end

	function app.visible(...)
		callIfNotNil(env.love.visible,...)
	end
	
	app.tConf = tConf
	
	return app
end
