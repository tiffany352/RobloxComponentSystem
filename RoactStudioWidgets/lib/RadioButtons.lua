local Roact = require(script.Parent.Parent.Roact)
local Button = require(script.Parent.Button)
local FitChildren = require(script.Parent.FitChildren)

local function RadioButtons(props)
	local children = {}
	children.UIGridLayout = Roact.createElement("UIGridLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		CellPadding = UDim2.new(0, 3, 0, 3),
		CellSize = UDim2.new(0, 140, 0, 24),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})
	children.UIPadding = Roact.createElement("UIPadding", {
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
	})
	for i = 1, #props.buttons do
		local button = props.buttons[i]
		children[button] = Roact.createElement(Button, {
			LayoutOrder = i,
			Size = UDim2.new(0, 150, 0, 24),

			labelText = button,
			pressed = props.selected == i,

			onClick = function()
				if props.onSelect then
					props.onSelect(i, button)
				end
			end,
		})
	end

	return Roact.createElement(FitChildren.Frame, {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1.0,
	}, children)
end

return RadioButtons
