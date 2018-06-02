local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)
local RoactStudioWidgets = require(Source.RoactStudioWidgets)
local ComponentData = require(script.Parent.ComponentData)

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
			Control = Roact.createElement(RoactStudioWidgets.Button, {

			}),
		})
	end

	return Roact.createElement(RoactStudioWidgets.Section, {
		LayoutOrder = props.LayoutOrder,
		titleText = props.name,
	}, children)
end

local function Properties(props)
	return Roact.createElement(ComponentData, {
		render = function(state)
			local sections = {}
			sections.UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
			for i,selected in pairs(state.selected or {}) do
				local component = state.components[selected.componentIndex]
				sections['Component'..i] = Roact.createElement(Section, {
					name = component.name,
					defaultProps = component.defaultProps,
					LayoutOrder = i,
				})
			end
			return Roact.createElement(RoactStudioWidgets.FitChildren.ScrollingFrame, {
				Size = UDim2.new(1, 0, 1, 0),
				CanvasSize = UDim2.new(1, 0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),
				BackgroundTransparency = 1.0,
			}, sections)
		end,
	})
end

return Properties
