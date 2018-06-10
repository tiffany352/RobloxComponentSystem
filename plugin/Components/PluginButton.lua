local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)

local PluginButton = Roact.PureComponent:extend("PluginButton")

--[[
	props: {
		plugin: object,
		Name: string,
		Tooltip: string,
		Icon: string,
		Toolbar: string,
		Enabled: boolean = true,
		ClickableWhenViewportHidden = true,
	}
]]

function PluginButton:init(props)
	local toolbar = props.plugin:toolbar(props.Toolbar)
	local button = props.plugin:button(toolbar, props.Name, props.Tooltip, props.Icon)
	self.rbx = button

	self.clickConn = button.Click:Connect(function()
		if props.onClick then
			props.onClick()
		end
	end)
end

function PluginButton:willUnmount()
	self.clickConn:Disconnect()
end

function PluginButton:render()
	local props = self.props
	local button = self.rbx

	button.Name = props.Name
	button.Icon = props.Icon
	if props.Enabled ~= nil then
		button.Enabled = props.Enabled
	end
	if props.ClickableWhenViewportHidden ~= false then
		button.ClickableWhenViewportHidden = props.ClickableWhenViewportHidden
	end

	return nil
end

return PluginButton
