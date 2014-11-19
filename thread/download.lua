--download thread. takes url as argument, and does an http.request--

local chan = love.thread.getChannel("download")
local socket = require "socket"
local http = require "socket.http"
local ltn12 = require "ltn12"

local function download(progress, result, url, port)
	local len
	local data = {}

	local function non_blocking_progress_tcp()
	  local sock = socket.tcp()
	  sock:settimeout(1)
	  local cur = 0

	  return setmetatable({
		sock = sock,

		-- don't allow timeout to be changed
		settimeout = function()
		  return true
		end,

		send = function(self, ...)
		  while true do
			local byte, err, partial = self.sock:send(...)
			if err == "timeout" then
			  -- TODO: this might lock up when using i,j args
			  if partial and partial > 0 then
				return partial
			  --else
				--coroutine.yield("timeout", sock)
			  end
			else
			  return byte, err, partial
			end
		  end
		end,

		connect = function(self, ...)
		  local status, err = self.sock:connect(...)
		  --if err == "timeout" then
			--coroutine.yield("timeout", sock)
		  --  return 1
		 -- end
		  return status, err
		end,

		receive = function(self, ...)
		  while true do
			local msg, err, partial = self.sock:receive(...)
			if err == "timeout" then
			  if partial and #partial > 0 then
				cur = cur+#partial
				progress:clear()
				progress:push({cur,len})
				return partial
			  end
			else
			  cur = cur+#msg
			  progress:clear()
			  progress:push({cur,len})
			  return msg, err, partial
			end
		  end
		end
	  }, {
		__index = function(self, name)
		  self[name] = function(self, ...)
			return self.sock[name](self.sock, ...)
		  end
		  return self[name]
		end
	  })
	end

	port = port or 80

	local _, __, h = http.request{url=url,
	method = "HEAD"}
	len = h["content-length"]

	local _, __, d = http.request{url=url,
		create = non_blocking_progress_tcp,
		sink = ltn12.sink.table(data),
		method = "GET"}
	progress:clear()
	progress:push({len,len})
	result:push(table.concat(data,""))
end

while true do
	local args = chan:demand()
	download(unpack(args))
end
