local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)
local RoactStudioWidgets = require(Source.RoactStudioWidgets)

local function EditWidget(props)
	if props.type == 'string' then
		return Roact.createElement(RoactStudioWidgets.Textbox, {
			LayoutOrder = props.LayoutOrder,
			value = props.value,
			setValue = props.setValue,
		})
	elseif props.type == 'number' then
		return Roact.createElement(RoactStudioWidgets.Textbox, {
			LayoutOrder = props.LayoutOrder,
			value = tostring(props.value),
			setValue = function(str)
				local num = tonumber(str)
				if num then
					props.setValue(num)
				end
			end,
		})
	elseif props.type == 'boolean' then
		return Roact.createElement(RoactStudioWidgets.Checkbox, {
			LayoutOrder = props.LayoutOrder,
			value = props.value,
			setValue = props.setValue,
		})
	elseif props.type == 'Vector3' then
		return Roact.createElement(RoactStudioWidgets.Textbox, {
			LayoutOrder = props.LayoutOrder,
			value = tostring(props.value),
			setValue = function(str)
			end,
		})
	elseif props.type == 'Vector2' then
		return Roact.createElement(RoactStudioWidgets.Textbox, {
			LayoutOrder = props.LayoutOrder,
			value = tostring(props.value),
			setValue = function(str)
			end,
		})
	elseif props.type == 'Color3' then
		return Roact.createElement(RoactStudioWidgets.Textbox, {
			LayoutOrder = props.LayoutOrder,
			value = string.format("%i, %i, %i", props.value.r * 255, props.value.g * 255, props.value.b * 255),
			setValue = function(str)
			end,
		})
	elseif props.type == 'table' and #props.value > 0 then
		local entries = {}
		entries.UIListLayout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		})
		for i = 1, #props.value do
			entries['Entry'..i] = Roact.createElement(EditWidget, {
				LayoutOrder = i,
				type = typeof(props.value[i]),
				value = props.value[i],
				setValue = function(entry)
					local newArray = {}
					for k,v in pairs(props.value) do
						newArray[k] = v
					end
					newArray[i] = entry
					props.setValue(newArray)
				end,
			})
		end
		entries.AddNew = Roact.createElement(RoactStudioWidgets.Button, {
			LayoutOrder = 99999,
			labelText = "Add entry",

			onClick = function()
				local newArray = {}
				for k,v in pairs(props.value) do
					newArray[k] = v
				end
				newArray[#newArray+1] = newArray[#newArray]
				props.setValue(newArray)
			end,
		})
		return Roact.createElement(RoactStudioWidgets.FitChildren.Frame, {
			LayoutOrder = props.LayoutOrder,
			BackgroundTransparency = 1.0,
		}, entries)
	else
		return Roact.createElement(RoactStudioWidgets.Label, {
			LayoutOrder = props.LayoutOrder,
			labelText = string.format("Unrecognized type: %s", props.type),
		})
	end
end

return EditWidget
