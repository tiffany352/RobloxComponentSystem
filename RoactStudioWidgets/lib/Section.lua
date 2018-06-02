local Roact = require(script.Parent.Parent.Roact)
local Constants = require(script.Parent.Constants)
local FitChildren = require(script.Parent.FitChildren)

local Section = Roact.PureComponent:extend("Section")

function Section:render()
	local props = self.props

	return Roact.createElement(FitChildren.Frame, {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1, 0, 0, 0),
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Titlebar = Roact.createElement("ImageButton", {
			LayoutOrder = 1,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, Constants.titlebarHeight),
			BackgroundColor3 = Constants.titlebarColor,

			[Roact.Event.Activated] = function(rbx)
				local now = tick()
				if now - (self.lastClickTime or 0) < 0.5 then
					self.lastClickTime = 0
					self:setState({
						minimized = not self.state.minimized,
					})
				else
					self.lastClickTime = now
				end
			end,
		}, {
			TitleLabel = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1.0,
				Font = Enum.Font.SourceSansBold,
				TextSize = 15,
				TextColor3 = Constants.black,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = props.titleText or "props.titleText",
				Position = UDim2.new(0, Constants.titlebarHeight, 0, 0),
				Size = UDim2.new(1, -Constants.titlebarHeight, 1, 0),
			}),
			Minimize = Roact.createElement("ImageButton", {
				Image = self.state.minimized and 'rbxasset://textures/TerrainTools/button_arrow.png' or 'rbxasset://textures/TerrainTools/button_arrow_down.png',
				Size = UDim2.new(0, 9, 0, 9),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, Constants.titlebarHeight * 0.5, 0, Constants.titlebarHeight * 0.5),
				BackgroundTransparency = 1.0,

				[Roact.Event.Activated] = function(rbx)
					self:setState({
						minimized = not self.state.minimized,
					})
				end,
			})
		}),
		Contents = Roact.createElement(FitChildren.Frame, {
			LayoutOrder = 2,
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1, 0, 0, 0),
			Visible = not self.state.minimized,
		}, props[Roact.Children]),
	})
end

return Section
