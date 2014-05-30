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
		return current_game[v](...)
	end
end

local oldcfg = {love.window.getMode()}

game.enter = function(st)
	love.graphics.clear()
	love.graphics.present()
	current_game.load()
end

game.quit = function(st)
	--exit state
	love.window.setMode(unpack(oldcfg))
	love.window.setTitle("Mist")
	love.graphics.setBackgroundColor(0,0,0)
	Gamestate.pop()
	current_game.quit()
	return true
end

return game
