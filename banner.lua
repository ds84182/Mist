local _banner = {}
function _banner:update(dt)
	if self.type == "custom" then
		local s,e = pcall(self.env.update,dt)
		if not s then self.err = e end
	else
		self.pos = (self.pos+(dt*self.speed))%1
	end
end
function _banner:draw()
	if self.err then
		love.graphics.print(self.err)
		return
	end
	if self.type == "custom" then
		local s,e = pcall(self.env.draw)
		if not s then self.err = e end
	elseif self.type == "scroll_hor" then
		local banner = self.getAsset("banner.png")
		if not banner then return end
		local scale = love.graphics.getHeight()/banner:getHeight()
		local iw, ih = banner:getDimensions()
		iw = iw*scale
		ih = ih*scale
		local nbg = math.ceil(love.graphics.getWidth()/iw)+1
		for i=0, nbg-1 do
			love.graphics.draw(banner,(i*iw)-(self.pos*iw),0,0,scale,scale)
		end
	end
end

function newBanner(bannerType,assetProvider)
	local banner = {}
	banner.type = bannerType
	banner.assets = {}
	banner.assetProvider = assetProvider
	banner.pos = 0
	banner.speed = 1
	banner.getAsset = function(asset)
		if not banner.assets[asset] then
			banner.assets[asset] = assetProvider(asset)
		end
		return banner.assets[asset]
	end
	
	if banner.type == "custom" then
		local f = banner.getAsset("banner.lua")
		while not f do
			f = banner.getAsset("banner.lua")
		end
		local func = assert(loadstring(f))
		banner.env = setmetatable({
			getAsset = banner.getAsset,
		},{__index=_G})
		setfenv(func,banner.env)
		func()
	end
	
	return setmetatable(banner,{__index=_banner})
end
