local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)

local PluginGui = Roact.PureComponent:extend("PluginGui")

--[[
	props: {
		plugin: object,
		Name: string,
		Title: string,
		InitialDockState: InitialDockState,
		InitialEnabled: boolean = false,
		OverrideRestore: boolean = false,
		FloatingSize: Vector2 = Vector2.new(0, 0),
		MinSize: Vector2 = Vector2.new(0, 0),
	}
]]

function PluginGui:init()
	local props = self.props
	local info = DockWidgetPluginGuiInfo.new(
		props.InitialDockState,
		props.InitialEnabled or false,
		props.OverrideRestore or false,
		props.FloatingSize and props.FloatingSize.X or 0,
		props.FloatingSize and props.FloatingSize.Y or 0,
		props.MinSize and props.MinSize.X or 0,
		props.MinSize and props.MinSize.Y or 0
	)
	self.rbx = props.plugin:createDockWidgetPluginGui(props.Name, info)
	self.rbx.Name = props.Name
	self.rbx.Title = props.Title

	self.toggleEnabled = function(value)
		if value ~= nil then
			self.rbx.Enabled = value
		else
			self.rbx.Enabled = not self.rbx.Enabled
		end
	end
end

function PluginGui:willUnmount()
	self.enabledChangedConn:Disconnect()
end

function PluginGui:render()
	self.rbx.Name = self.props.Name
	self.rbx.Title = self.props.Title
	local render = Roact.oneChild(self.props[Roact.Children])
	return Roact.createElement(Roact.Portal, {
		target = self.rbx,
	}, {
		[self.props.Name] = render(self.toggleEnabled)
	})
end

return PluginGui
