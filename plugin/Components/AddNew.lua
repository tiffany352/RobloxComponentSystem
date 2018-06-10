local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)
local RoactStudioWidgets = require(Source.RoactStudioWidgets)
local ComponentData = require(script.Parent.ComponentData)
local PluginGui = require(script.Parent.PluginGui)
local PluginButton = require(script.Parent.PluginButton)

local function Entry(props)
	return Roact.createElement(RoactStudioWidgets.Button, {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, 24),
		labelText = props.name,
		onClick = function()
			props.manager:addComponent(props.name)
			props.toggleEnabled(false)
		end,
	})
end

local function AddNew(props)
	return Roact.createElement(ComponentData, {
		render = function(state, manager)
			return Roact.createElement(PluginGui, {
				plugin = props.plugin,
				Name = "ComponentVisualizer.AddNew",
				Title = "Add new...",
				InitialDockState = Enum.InitialDockState.Float,
				OverrideRestore = true,
				FloatingSize = Vector2.new(200, 400),
			}, {
				render = function(toggleEnabled)
					local entries = {}
					entries.UIListLayout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
					})
					for i,component in pairs(state.components or {}) do
						entries['Component'..i] = Roact.createElement(Entry, {
							name = component.name,
							LayoutOrder = i,
							manager = manager,
							toggleEnabled = toggleEnabled,
						})
					end
					entries.Button = Roact.createElement(PluginButton, {
						plugin = props.plugin,
						Toolbar = "Components",
						Name = "Add new...",
						Tooltip = "Add a component to the selected instances",
						Icon = "",
						ClickableWhenViewportHidden = true,
						Enabled = state.rawSelection and #state.rawSelection > 0,

						onClick = function()
							toggleEnabled(true)
						end,
					})

					return Roact.createElement(RoactStudioWidgets.FitChildren.ScrollingFrame, {
						Size = UDim2.new(1, 0, 1, 0),
						CanvasSize = UDim2.new(1, 0, 0, 0),
						BackgroundColor3 = Color3.fromRGB(20, 20, 20),
						BackgroundTransparency = 1.0,
					}, entries)
				end,
			})
		end,
	})
end

return AddNew
