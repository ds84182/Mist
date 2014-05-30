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

--install save draw that doesn't complain over null drawables--
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

function love.load()
	local fadeid = love.image.newImageData(64,1)
	local a = 255
	for i=0,63 do
		fadeid:setPixel(i,0,255,255,255,math.floor(a))
		a = a-(255/64)
		print(a)
	end
	
	fade = love.graphics.newImage(fadeid)
	
	Gamestate.registerEvents()
	Gamestate.switch(require "state.loading")
	--[[cron.add(cron.every(5,function()
		notification.add("Periodic notification")
	end))]]
	love.window.setMode(800,600,{vsync=true})
end

function love.update(dt)
	cron.update(dt)
	flux.update(dt)
end

function love.post_draw()
	notification.draw()
end
