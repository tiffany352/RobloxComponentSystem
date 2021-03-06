local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)
local RoactStudioWidgets = require(Source.RoactStudioWidgets)
local ComponentData = require(script.Parent.ComponentData)
local EditWidget = require(script.Parent.EditWidget)
local PluginGui = require(script.Parent.PluginGui)

local function Section(props)
	local children = {}
	children.UIListLayout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local keys = {}
	for key, value in pairs(props.defaultProps or {}) do
		keys[#keys+1] = key
	end
	table.sort(keys)
	for i = 1, #keys do
		local key = keys[i]
		local value = props.defaultProps[key]
		children[key] = Roact.createElement(RoactStudioWidgets.Property, {
			propertyName = key,
		}, {
			Control = Roact.createElement(RoactStudioWidgets.FitChildren.Frame, {
				BackgroundTransparency = 1.0,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 4),
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
				}),
				UIListLayout = Roact.createElement("UIListLayout"),
				EditWidget = Roact.createElement(EditWidget, {
					type = typeof(value),
					value = value,
					setValue = function(newValue)
						props.setProperty(key, newValue)
					end,
				}),
			})
		})
	end

	return Roact.createElement(RoactStudioWidgets.Section, {
		LayoutOrder = props.LayoutOrder,
		titleText = props.name,
	}, children)
end

local function Properties(props)
	return Roact.createElement(ComponentData, {
		render = function(state, manager)
			local sections = {}
			sections.UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
			for i,selected in pairs(state.selected or {}) do
				local component = state.components[selected.componentIndex]
				sections['Component'..i] = Roact.createElement(Section, {
					name = component.name,
					defaultProps = selected.properties,
					LayoutOrder = i,
					setProperty = function(property, value)
						manager:setComponentProperty(component.name, property, value)
					end
				})
			end

			local title
			local enabled
			do
				local numSel = state.instances and #state.instances or 0
				local prefix = "Component Properties"
				title = prefix
				if numSel == 1 then
					local inst = state.instances[1]
					title = string.format("%s - %s %q", prefix, inst.class, inst.name)
				elseif numSel >= 2 then
					title = string.format("%s - %i items", prefix, numSel)
				end
				enabled = numSel > 0
			end

			return Roact.createElement(PluginGui, {
				plugin = props.plugin,
				Name = "ComponentVisualizer.Properties",
				Title = title,
				Enabled = enabled,
				InitialDockState = Enum.InitialDockState.Right,
			}, {
				render = function(toggleEnabled)
					toggleEnabled(enabled)

					return Roact.createElement(RoactStudioWidgets.FitChildren.ScrollingFrame, {
						Size = UDim2.new(1, 0, 1, 0),
						CanvasSize = UDim2.new(1, 0, 0, 0),
						BackgroundColor3 = Color3.fromRGB(20, 20, 20),
						BackgroundTransparency = 1.0,
					}, sections)
				end,
			})
		end,
	})
end

return Properties
