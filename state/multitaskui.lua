local multitaskui = {}

local old = {}
local canvas
local scale

function multitaskui:enter(prev)
	print("game suspension successful (except for threads)")
	old.bgcolor = {love.graphics.getBackgroundColor()}
	canvas = current_game.tConf.window.canvas
	love.graphics.setBackgroundColor(0,0,0)
	scale = {1}
	flux.to(scale,1,{0.5})
end

function multitaskui:leave()
	print("resuming game")
	love.graphics.setBackgroundColor(old.bgcolor)
end

function multitaskui:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(canvas,canvas:getWidth()/2,canvas:getHeight()/2,0,scale[1],scale[1],canvas:getWidth()/2,canvas:getHeight()/2)
end

function multitaskui:keyreleased(key)
	if key == "lgui" and scale[1] == 0.5 then
		flux.to(scale,1,{1}):oncomplete(function()
			Gamestate.pop()
		end)
	elseif key == " " then
		--go to the store--
		Gamestate.push(require "state.store")
	end
end

return multitaskui
