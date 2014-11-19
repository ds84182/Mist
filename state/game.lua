local all_callbacks = {
	'draw', 'errhand', 'focus', 'keypressed', 'keyreleased', 'mousefocus',
	'mousepressed', 'mousereleased', 'quit', 'resize', 'textinput',
	'threaderror', 'update', 'visible', 'gamepadaxis', 'gamepadpressed',
	'gamepadreleased', 'joystickadded', 'joystickaxis', 'joystickhat',
	'joystickpressed', 'joystickreleased', 'joystickremoved'
}

local game = {}
--current_game = nil

for i, v in pairs(all_callbacks) do
	game[v] = function(st, ...)
		if current_game[v] then
			return current_game[v](...)
		end
	end
end

local oldcfg = {love.window.getMode()}

function game.enter(st)
	love.graphics.clear()
	love.graphics.present()
	current_game.load()
end

function game.keypressed(st,key,a,b,c,d)
	if key == "lgui" then
		--do nothing.
	elseif current_game.keypressed then
		current_game.keypressed(key,a,b,c,d)
	end
end

function game.keyreleased(st,key,a,b,c,d)
	if key == "lgui" then
		Gamestate.push(require "state.multitaskui")
	elseif current_game.keyreleased then
		current_game.keyreleased(key,a,b,c,d)
	end
end

function game.quit(st)
	--exit state
	love.window.setMode(unpack(oldcfg))
	love.window.setTitle("Mist")
	love.graphics.setBackgroundColor(0,0,0)
	Gamestate.pop()
	current_game.quit()
	return true
end

return game
