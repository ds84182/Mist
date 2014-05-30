local loading = {}

Fonts = {}
Sizes = {
Title = 80,
Subtitle = 50,
Caption = 18}

Games = {}

loadingstr = {}

love.window.setTitle("Mist")

local function refreshLoadingScreen()
	love.graphics.clear()
	--flush events
	love.event.pump()
	for e,a,b,c,d in love.event.poll() do
		if e == "quit" then
			if not love.quit or not love.quit() then
				if love.audio then
					love.audio.stop()
				end
				os.exit()
			end
		end
		love.handlers[e](a,b,c,d)
	end
	
	love.graphics.setFont(Title)
	love.graphics.print("Mist")
	love.graphics.setFont(Subtitle)
	love.graphics.print("\tloading...",0,80)
	
	love.graphics.setFont(Caption)
	local start = 600-(Caption:getHeight()*#loadingstr)
	for i=1, #loadingstr do
		love.graphics.printf(loadingstr[i],0,start,800,"right")
		start = start+Caption:getHeight()
	end
	
	love.graphics.present()
end

function loadGames(nps)
	for _,game in pairs(love.filesystem.getDirectoryItems("games")) do
		local conf = JSON:decode(love.filesystem.read("games/"..game.."/conf.json"))
		conf.id = game
		
		if not nps then
			table.insert(loadingstr, "load metadata for "..game)
			refreshLoadingScreen()
		end
		
		conf.banner = newBanner(conf.banner_type,function(asset)
			local ext = asset:sub(-3,-1)
			if ext == "png" then
				return love.graphics.newImage("games/"..game.."/"..asset)
			elseif ext == "ogg" then
				return love.audio.newSource("games/"..game.."/"..asset)
			else
				return love.filesystem.read("games/"..game.."/"..asset)
			end
		end)
		conf.banner.speed = conf.banner_speed or 1
		--love.graphics.newImage("games/"..game.."/banner.png")
		--conf.banner:setFilter("nearest")
		
		Games[game] = conf
		Games[#Games+1] = conf
	end
end

function loading:enter()
	for i, v in pairs(Sizes) do
		Fonts[i] = {}
	end
	for _,v in pairs(love.filesystem.getDirectoryItems("font")) do
		local name = v:match("(.+)%..-")
		for i, s in pairs(Sizes) do
			Fonts[i][name] = love.graphics.newFont("font/"..v,s)
		end
	end
	Title = Fonts.Title["ClearSans-Medium"]
	Subtitle = Fonts.Subtitle["ClearSans-Medium"]
	Caption = Fonts.Caption["ClearSans-Light"]
	
	refreshLoadingScreen()
	
	table.insert(loadingstr, "checking installed games")
	refreshLoadingScreen()
	
	loadGames()
	
	Gamestate.switch(require "state.menu")
end

return loading
