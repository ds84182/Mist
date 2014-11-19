--Mist: Love2D 0.9.0 Game Client (With 0.8.0 backwards compatibility support... soon...)--
Gamestate = require "hump.gamestate"
require "libgameload"
JSON = require "json"
sha1 = require "sha1"
cron = require "cron"
require "notification"
flux = require "flux"
require "banner"
require "ui.button"
require "log"

--install safe draw that doesn't complain over null drawables--
local lgd = love.graphics.draw
function love.graphics.draw(i,...)
	if i then
		lgd(i,...)
	end
end

function roundrect(mode,x,y,w,h,tl,tr,bl,br)
	tl = tl or 0
	tr = tr or tl
	bl = bl or tl
	br = br or bl
	
	love.graphics.push()
	love.graphics.translate(x,y)
	love.graphics.arc(mode,tl,tl,tl,math.pi,math.pi*1.5)
	love.graphics.arc(mode,w-tr,tr,tr,math.pi*2,math.pi*1.5)
	love.graphics.arc(mode,bl,h-bl,bl,math.pi,math.pi*.5)
	love.graphics.arc(mode,w-br,h-br,br,math.pi*.5,0)
	love.graphics.polygon(mode,tl,0,w-tr,0,w-tr,tr,tl,tl)
	love.graphics.polygon(mode,bl,h,w-br,h,w-br,h-br,bl,h-bl)
	love.graphics.polygon(mode,0,tl,tl,tl,bl,h-bl,0,h-bl)
	love.graphics.polygon(mode,w-tr,tr,w,tr,w,h-br,w-br,h-br)
	love.graphics.polygon(mode,tl,tl,w-tr,tr,w-br,h-br,bl,h-bl)
	love.graphics.pop()
end

--downloader!--
download_thread = love.thread.newThread("thread/download.lua")
download_thread:start()
download_channel = love.thread.getChannel("download")
function download(progress, reply, url, port)
	download_channel:push {progress, reply, url, port}
end

function love.load()
	log "-- MIST SUPER UBER AWESOME BETA LOG --"
	local fadeid = love.image.newImageData(64,1)
	local a = 64
	for i=0,63 do
		fadeid:setPixel(i,0,255,255,255,math.floor(a))
		a = a-1
	end
	
	fade = love.graphics.newImage(fadeid)
	
	--[[modes = love.window.getFullscreenModes()
	table.sort(modes, function(a, b) return a.width*a.height > b.width*b.height end)   -- sort from smallest to largest
	love.window.setMode(modes[1].width,modes[1].height,{vsync=true})
	love.window.setFullscreen(true)]]
	
	Gamestate.registerEvents()
	Gamestate.switch(require "state.loading")
	cron.add(cron.every(5,function()
		notification.add("Periodic notification")
	end))
end

function love.update(dt)
	cron.update(dt)
	flux.update(dt)
end

function love.post_draw()
	notification.draw()
end
