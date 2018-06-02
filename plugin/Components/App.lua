local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)
local Properties = require(script.Parent.Properties)

local function App(props)
	return Roact.createElement(Properties)
end

return App
