if love.filesystem.exists("log") then
	love.filesystem.write("log-old",love.filesystem.read("log"))
end
love.filesystem.write("log","")

function log(...)
	local s = ""
	for i, v in ipairs({...}) do
		s = s..tostring(v).."\t"
	end
	s = s:sub(1,#s-1)
	love.filesystem.append("log",s.."\n")
end
