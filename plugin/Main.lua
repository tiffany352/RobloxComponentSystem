local Source = script.Parent.Parent
local Roact = require(Source.Roact)
local App = require(script.Parent.Components.App)
local ComponentProvider = require(script.Parent.Components.ComponentProvider)
local ComponentManager = require(script.Parent.ComponentManager)

return function(plugin)
	local componentManager = ComponentManager.new()

	local element = Roact.createElement(ComponentProvider, {
		manager = componentManager,
	}, {
		App = Roact.createElement(App, {
			plugin = plugin,
		}),
	})

	element = Roact.mount(element, nil, "Plugin")

	plugin:beforeUnload(function()
		componentManager:destroy()
		Roact.unmount(element)
	end)
end
