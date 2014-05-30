--Mist: Love2D 0.9.0 Game Client (With 0.8.0 backwards compatibility support)--
Gamestate = require "hump.gamestate"
require "libgameload"
JSON = require "json"
sha1 = require "sha1"
cron = require "cron"
require "notification"
flux = require "flux"
require "banner"

--install save draw that doesn't complain over null drawables--
local lgd = love.graphics.draw
function love.graphics.draw(i,...)
	if i then
		lgd(i,...)
	end
end

function love.load()
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
