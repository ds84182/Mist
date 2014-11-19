local _button = {}
function _button:update(dt)
	local x, y = love.mouse.getPosition()
	self.hover = (x >= self.x and x <= self.x+self.width) and (y >= self.y and y <= self.y+self.height)
	flux.to(self.current_bgcolor, 0.25, self.hover and self.bgcolor_hover or self.bgcolor)
end
function _button:mousereleased(x,y,b)
	if (x >= self.x and x <= self.x+self.width) and (y >= self.y and y <= self.y+self.height) then
		self.current_bgcolor = {unpack(self.bgcolor_click)}
		if self.click then
			self:click(x,y,b)
		end
	end
end
function _button:draw()
	love.graphics.setColor(self.current_bgcolor)
	roundrect("fill",self.x,self.y,self.width,self.height,self.tl,self.tr,self.bl,self.br)
	
	love.graphics.setColor(self.fgcolor)
	love.graphics.setFont(self.font)
	if type(self.content) == "userdata" then
	
	else
		local yofs = self.font:getHeight()/4
		love.graphics.printf(tostring(self.content),self.x,self.y+yofs,self.width,"center")
	end
end

function newButton(x,y,width,height,content)
	local obj = {}
	obj.x = x or 0
	obj.y = y or 0
	obj.width = width or 24
	obj.height = height or 80
	obj.content = content or "This button has no content!"
	obj.tl = 5
	obj.tr = 5
	obj.bl = 5
	obj.br = 5
	obj.bgcolor = {225,225,225,225}
	obj.bgcolor_hover = {196,196,196,240}
	obj.bgcolor_click = {128,128,128,255}
	obj.current_bgcolor = {unpack(obj.bgcolor)}
	obj.hover = false
	obj.fgcolor = {0,0,0}
	obj.font = Subtitle
	return setmetatable(obj,{__index=_button})
end
