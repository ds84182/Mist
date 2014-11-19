local twelvefoot = {}
--TwelveFoot, Wii like interface for Mist--
--TODO: Add Mist effects--
local channels = {}
function newPage()
	--creates a new page for the channels
	local page = {}
	channels[#channels+1] = page
	for x=1, 4 do
		page[x] = {}
		for y=1, 3 do
			page[x][y] = nil
		end
	end
	return page
end

function twelvefoot:enter()
	local fp = newPage()
	fp[1][1] = require "twelvefoot.channel.store"
end

function twelvefoot:update(dt)
	channels[1][1][1].update(dt)
end

function twelvefoot:draw()
	channels[1][1][1].draw()
end

return twelvefoot
