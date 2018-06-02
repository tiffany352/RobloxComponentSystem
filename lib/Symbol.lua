local Symbol = {}

function Symbol.new(name)
	local self = {
		__name = name,
	}
	setmetatable(self, Symbol)
	return self
end

function Symbol:__index(key)
	error(string.format("Cannot index Symbol with key %q", tostring(key)))
end

function Symbol:__newindex(key, value)
	error(string.format("Cannot assign key %q on immutable Symbol", tostring(key)))
end

function Symbol:__tostring()
	return string.format("<Symbol:%s>", self.__name)
end

return Symbol
