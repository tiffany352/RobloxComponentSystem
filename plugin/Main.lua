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
			createPluginGui = function(...)
				return plugin:createDockWidgetPluginGui(...)
			end,
		}),
	})

	element = Roact.mount(element, nil, "Plugin")

	local toolbar = plugin:toolbar("Components")
	local addNewButton = plugin:button(toolbar, "Add new...", "Add a component to the selected objects.", "")
	addNewButton.Click:Connect(function()
		-- popup menu
		--addNewGui.Enabled = true
	end)

	plugin:beforeUnload(function()
		componentManager:destroy()
		Roact.unmount(element)
	end)
end
