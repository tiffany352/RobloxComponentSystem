local Roact = require(script.Parent.Parent.Roact)
local FitChildren = require(script.Parent.FitChildren)

local function Property(props)
	return Roact.createElement(FitChildren.Frame, {
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1.0,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Header = Roact.createElement("Frame", {
			LayoutOrder = -1,
			Size = UDim2.new(1, 0, 0, 20),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(230, 230, 230),
		}, {
			PropertyLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, -8, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),

				Text = props.propertyName or "props.propertyName",
				Font = Enum.Font.SourceSans,
				TextSize = 16,
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1.0,
			}),
		}),
		Contents = Roact.oneChild(props[Roact.Children]),
	})
end

return Property
