local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)
local Properties = require(script.Parent.Properties)
local AddNew = require(script.Parent.AddNew)

local function App(props)
	return Roact.createElement("Folder", {}, {
		Properties = Roact.createElement(Properties, {
			plugin = props.plugin,
		}),
		AddNew = Roact.createElement(AddNew, {
			plugin = props.plugin,
		}),
	})
end

return App
