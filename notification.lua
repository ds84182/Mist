notification = {}

local notes = {}
local notew = 400
local noteh = 48

function notification.add(msg)
	notew = love.graphics.getWidth()/2
	local n = {x=-notew,y=love.graphics.getHeight()-((#notes+1)*noteh),msg=msg}
	table.insert(notes,n)
	flux.to(n,1,{x=0}):after(n,5,{}):after(n,1,{x=-notew}):oncomplete(function()
		--find our index in the notes--
		local i
		for ni=1, #notes do
			if notes[ni] == n then
				i = ni
				break
			end
		end
		if i == 1 then
			--tween all below
			for ni=2,#notes do
				local n = notes[ni]
				if n.downtween then flux.remove(n.downtween) end
				n.downtween = flux.to(n,0.25,{y=love.graphics.getHeight()-((ni-1)*noteh)})
			end
		end
		table.remove(notes,i)
	end)
end

function notification.draw()
	love.graphics.setFont(Caption)
	for _,n in ipairs(notes) do
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill",n.x,n.y,notew,noteh)
		love.graphics.setColor(255,255,255)
		local width, height = Caption:getWrap(n.msg,notew)
		height = height*Caption:getHeight()
		love.graphics.printf(n.msg,n.x,n.y+(height/4),notew,"right")
	end
end
