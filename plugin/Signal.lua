local Connection = {}
Connection.__index = Connection

function Connection.new(signal, func)
	local self = {
		signal = signal,
		func = func,
	}
	setmetatable(self, Connection)

	return self
end

function Connection:disconnect()
	if self.signal then
		self.signal.connections[self.func] = nil
		self.signal = nil
		self.func = nil
	end
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = {
		connections = {},
	}
	setmetatable(self, Signal)

	return self
end

function Signal:fire(...)
	for func,_ in pairs(self.connections) do
		func(...)
	end
end

function Signal:connect(func)
	self.connections[func] = true
	return Connection.new(self, func)
end

return Signal
