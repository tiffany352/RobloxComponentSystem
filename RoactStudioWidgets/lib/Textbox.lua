local Roact = require(script.Parent.Parent.Roact)

local Textbox = Roact.PureComponent:extend("Textbox")

function Textbox:render()
	local props = self.props
	local value = props.value
	local setValue = props.setValue
	local focusLost = props.focusLost
	local onSubmit = props.onSubmit

	return Roact.createElement("Frame", {
		Size = props.Size or UDim2.new(0, 300, 0, 20),
		LayoutOrder = props.LayoutOrder,

		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(164, 164, 164),
	}, {
		TextInput = Roact.createElement("TextBox", {
			Font = Enum.Font.SourceSans,
			TextSize = 15,
			BackgroundTransparency = 1.0,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -4, 1, -2),
			Position = UDim2.new(0, 4, 0, 0),
			ClipsDescendants = true,
			ClearTextOnFocus = false,
			Text = tostring(value) or "",

			[Roact.Event.FocusLost] = function(rbx, enterPressed)
				if enterPressed then
					if onSubmit then
						onSubmit(rbx.Text)
					end
				else
					if focusLost then
						focusLost(rbx.Text)
					end
				end
			end,

			[Roact.Change.Text] = function(rbx, text)
				if self.debounce then
					return
				end
				self.debounce = true
				if setValue and text ~= value then
					rbx.Text = value
					setValue(text)
				end
				self.debounce = false
			end,
		})
	})
end

return Textbox
