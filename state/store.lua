local store = {}

local cur = 1
local bgpos = 0
local Store = {}
local numstore = 0
local numcompl = 0
local gamesinstore = {}
local loadedtitlelist = false
local listdl
local repo = "http://ds84182.github.io/mist/"
local http = require "socket.http"
local uielements = {}

local width, height

local function startDownload(url,port)
	local progress, result = love.thread.newChannel(), love.thread.newChannel()
	download(progress, result, url, port)
	return result, progress
end

local function formatVersion(ver)
	return ver == nil and "nil" or table.concat(ver,".")
end

local function isUpdated(oldver,ver)
	if oldver == nil and ver == nil then
		return false
	elseif oldver == nil then
		return true
	else
		--turn version numbers into real numbers
		local ovn, vn = tonumber(table.concat(oldver,"")), tonumber(table.concat(ver,""))
		if ovn<vn then
			return true
		end
	end
end

local function install()
	--start cron
	local game = Store[cur]
	if Games[game.id] and (not isUpdated(Games[game.id].version, game.version)) then
		notification.add("You already have this game installed")
		return
	end
	local dl, dlp = startDownload(repo.."archive/"..game.id..".zip")
	Downloads = Downloads or {}
	Downloads[game.id] = {dl, dlp}
	local dlcron
	dlcron = cron.every(1, function(c)
		if dl:peek() then
			notification.add("Hi. Your "..game.name.." download is finished")
			
			--install game--
			love.filesystem.createDirectory("games/"..game.id)
			love.filesystem.write("games/"..game.id.."/game.zip",dl:pop())
			love.filesystem.write("games/"..game.id.."/conf.json",game.rawj)
			--love.filesystem.write("games/"..game.id.."/banner.png",game.bd)
			--save all banner assets--
			--if you want all your assets downloaded for your custom banner, you should preload all of the assets!!!--
			for name, val in pairs(game.banner.assets) do
				print(name)
				if type(val) == "string" then
					love.filesystem.write("games/"..game.id.."/"..name, val)
				elseif val:typeOf("Image") then
					val:getData():encode("games/"..game.id.."/"..name)
				elseif val:typeOf("Source") then
					error("TODO: Reformat asset system to allow sound sources to be saved")
				end
			end
			
			cron.add(cron.after(2,function()
				Games = {}
				--loadingstr = {}
				loadGames(true)
			end))
			
			Downloads[game.id] = nil
			cron.remove(dlcron)
		end
	end)
	cron.add(dlcron)
end

function store:enter()
	--load store from the internet--
	cur = 1
	uielements = {}
	numstore = 0
	numcompl = 0
	gamesinstore = {}
	Store = {}
	loadedtitlelist = false
	print("Store entered")
	listdl = startDownload(repo.."games.txt")
	
	width, height = love.graphics.getDimensions()
	
	uielements.install = newButton(0,height-100,width/2,100,"Install")
	uielements.install.bl = 5
	uielements.install.tr = 0
	uielements.install.br = 0
	function uielements.install:click(x,y,b)
		install()
	end
	
	uielements.exit = newButton(width/2,height-100,width/2,100,"Exit")
	uielements.exit.tl = 0
	uielements.exit.bl = 0
	uielements.exit.tr = 5
	uielements.exit.br = 5
	function uielements.exit:click(x,y,b)
		Gamestate.pop()
	end
end

function store:update(dt)
	if Store[cur] then
		Store[cur].banner:update(dt)
	end
	if not loadedtitlelist then
		if listdl:peek() then
			local games = listdl:pop()
			for n in games:gmatch("([^\n]+)") do
				print(n)
				gamesinstore[#gamesinstore+1] = {n,"config",dlchan=startDownload(repo.."meta/"..n.."/conf.json")}
				numstore = numstore+1
			end
			loadedtitlelist = true
		end
	else
		for _,game in pairs(gamesinstore) do
			if (not game.finish) and game.dlchan:peek() then
				if game[2] == "config" then
					local rjconf = game.dlchan:pop()
					local conf = JSON:decode(rjconf)
					conf.id = game[1]
					game.conf = conf
					Store[#Store+1] = conf
					Store[game[1]] = conf
					conf.rawj = rjconf
					game.finish = true
					local assetDownloads = {}
					conf.banner = newBanner(conf.banner_type,function(asset)
						if assetDownloads[asset] then
							if assetDownloads[asset]:peek() then
								local ext = asset:sub(-3,-1)
								if ext == "png" then
									return love.graphics.newImage(love.image.newImageData(love.filesystem.newFileData(assetDownloads[asset]:pop(),asset)))
								elseif ext == "ogg" then
									return love.audio.newSource(love.filesystem.newFileData(assetDownloads[asset]:pop(),asset))
								else
									return assetDownloads[asset]:pop()
								end
							end
						else
							--start the async download of the asset
							assetDownloads[asset] = startDownload(repo.."meta/"..game[1].."/"..asset)
						end
					end)
					conf.banner.speed = conf.banner_speed or 1
					numcompl = numcompl+1
					--game.dlchan=startDownload(repo.."meta/"..game[1].."/banner.png")
				--[[else
					--we have banner
					local d = game.dlchan:pop()
					local bid = love.image.newImageData(love.filesystem.newFileData(d,"banner.png"))
					local banner = love.graphics.newImage(bid)
					banner:setFilter("nearest")
					game.conf.banner = banner
					game.conf.bd = d
					game.finish = true
					numcompl = numcompl+1]]
				end
			end
		end
	end
	
	for i, v in pairs(uielements) do
		v:update(dt)
	end
end

function store:draw()
	love.graphics.setColor(255,255,255)
	local game = Store[cur]
	if game then
		if game.banner then
			game.banner:draw()
		end
		
		love.graphics.setColor(0,0,0,255)
		if Store[cur-1] then
			love.graphics.draw(fade,0,0,0,1,height)
		end
		if Store[cur+1] then
			love.graphics.draw(fade,width,0,0,-1,height)
		end
		
		love.graphics.setColor(255,255,255)
		love.graphics.setFont(Subtitle)
		love.graphics.print(game.name,0,0)
		love.graphics.setFont(Caption)
		love.graphics.print(game.desc,0,Subtitle:getHeight())
		love.graphics.print(Games[game.id] and (isUpdated(Games[game.id].version, game.version) and "Game has an update (installed version: "..formatVersion(Games[game.id].version)..")" or "Game already installed") or "Game is avaliable for download",0,Subtitle:getHeight()+Caption:getHeight())
		
		love.graphics.printf("Version: "..formatVersion(game.version),width-200,0,200,"right")
		
		if Downloads and Downloads[game.id] then
			local prg = Downloads[game.id][2]
			local progress = prg:pop() or (game.dl or {0,0})
			game.dl = progress
			love.graphics.printf("Download Progress: "..progress[1].."/"..progress[2],width/2,100,width/2,"right")
		end
	end
	
	for i, v in pairs(uielements) do
		v:draw()
	end
end

function store:keyreleased(key)
	if key == " " and Store[cur] then
		install()
	elseif key == "escape" then
		Gamestate.pop()
	elseif key == "left" and cur > 1 then
		cur = cur-1
	elseif key == "right" and cur < #Store then
		cur = cur+1
	end
end

function store:mousereleased(x,y,b)
	for i, v in pairs(uielements) do
		v:mousereleased(x,y,b)
	end
end

function store:threaderror(...)
	print(...)
end

function store:leave()
	
end

return store
