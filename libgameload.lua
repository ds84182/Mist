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
		t.window.color = {255,255,255,255}

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
	
	--we have config, use it--
	function env.love.window.getIcon()
		return tConf.window.icon
	end
	function env.love.window.getTitle()
		return tConf.window.title
	end
	function env.love.window.setIcon(id)
		tConf.window.icon = id
	end
	
	function env.love.window.setTitle(t)
		tConf.window.title = t
	end
	
	love.window.setMode(tConf.window.width, tConf.window.height, 
	{
		fullscreen = tConf.window.fullscreen,
		vsync = tConf.window.vsync,
		fsaa = tConf.window.fsaa,
		resizeable = tConf.window.resizeable,
		borderless = tConf.window.borderless,
		centered = tConf.window.centered
	})
	
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
		local oldes = love.graphics.emulatedScreen
		love.graphics.emulatedScreen = tConf.window.canvas
		love.graphics.setCanvas()
		love.graphics.setColor(tConf.window.color)
		callIfNotNil(env.love.draw,...)
		love.graphics.emulatedScreen = nil
		love.graphics.setCanvas()
		tConf.window.color = {love.graphics.getColor()}
		love.graphics.setColor(255,255,255)
		love.graphics.draw(tConf.window.canvas,0,0)
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
