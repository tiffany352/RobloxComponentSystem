local TextService = game:GetService("TextService")

local Roact = require(script.Parent.Parent.Roact)

local function Label(props)
	local text = props.labelText or "props.labelText"
	local size = props.textSize or 15
	local font = props.font or Enum.Font.SourceSans
	local maxSize = props.maxSize or Vector2.new(10000, 10000)
	local padding = props.padding or 0
	if typeof(padding) == 'number' then
		padding = Vector2.new(1, 1) * padding
	end

	local bounds = TextService:GetTextSize(text, size, font, maxSize)

	return Roact.createElement("TextLabel", {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(0, bounds.X + padding.X * 2, 0, bounds.Y + padding.Y * 2),

		Text = text,
		TextSize = size,
		Font = font,

		TextColor3 = props.textColor or Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1.0,
	})
end

return Label
