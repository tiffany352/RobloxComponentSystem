local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)
local Properties = require(script.Parent.Properties)

local function App(props)
	return Roact.createElement("Folder", {}, {
		Properties = Roact.createElement(Properties, {
			createPluginGui = props.createPluginGui,
		}),
	})
end

return App
