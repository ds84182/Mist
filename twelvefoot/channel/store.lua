local store = {}

local part = love.graphics.newParticleSystem(love.graphics.newImage("twelvefoot/gfx/steam.png"),10000)
part:start()
part:setPosition(400,600)
part:setEmitterLifetime(-1)
part:setLinearAcceleration(-64,-64,64,-32)
part:setEmissionRate(100)
part:setParticleLifetime(5)
part:setColors(128,128,128,128,0,0,0,0)
part:setSizes(0,1,1,2)
part:setSizeVariation(1)

function store.draw()
	--totally not a goddamn wii shop channel ripoff--
	
	love.graphics.setFont(Title)
	love.graphics.setColor(255,255,255)
	love.graphics.printf("Store",-1,299,800,"center")
	love.graphics.setColor(64,64,64)
	love.graphics.printf("Store",1,301,800,"center")
	love.graphics.setColor(196,196,196)
	love.graphics.printf("Store",0,300,800,"center")
	
	love.graphics.setColor(255,255,255)
	love.graphics.setBlendMode("subtractive")
	love.graphics.draw(part)
	love.graphics.setBlendMode("alpha")
end

function store.update(dt)
	part:update(dt)
end

return store
