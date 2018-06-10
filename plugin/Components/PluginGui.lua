local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)

local PluginGui = Roact.PureComponent:extend("PluginGui")

--[[
	props: {
		createPluginGui: function,
		Name: string,
		Title: string,
		InitialDockState: InitialDockState,
		Enabled: boolean = false,
		OverrideRestore: boolean = false,
		FloatingSize: Vector2 = Vector2.new(0, 0),
		MinSize: Vector2 = Vector2.new(0, 0),
	}
]]

function PluginGui:init()
	local props = self.props
	local info = DockWidgetPluginGuiInfo.new(
		props.InitialDockState,
		props.Enabled or false,
		props.OverrideRestore or false,
		props.FloatingSize and props.FloatingSize.X or 0,
		props.FloatingSize and props.FloatingSize.Y or 0,
		props.MinSize and props.MinSize.X or 0,
		props.MinSize and props.MinSize.Y or 0
	)
	self.rbx = props.createPluginGui(props.Name, info)
	self.rbx.Name = props.Name
	self.rbx.Title = props.Title
	if props.Enabled ~= nil then
		self.rbx.Enabled = props.Enabled
	end
end

function PluginGui:willUnmount()
	self.enabledChangedConn:Disconnect()
end

function PluginGui:render()
	self.rbx.Name = self.props.Name
	self.rbx.Title = self.props.Title
	if self.props.Enabled ~= nil then
		self.rbx.Enabled = self.props.Enabled
	end
	return Roact.createElement(Roact.Portal, {
		target = self.rbx,
	}, self.props[Roact.Children])
end

return PluginGui
