local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)
local ComponentProvider = require(script.Parent.ComponentProvider)

local ComponentData = Roact.PureComponent:extend("ComponentData")

function ComponentData:init(props)
	local manager = self._context[ComponentProvider]
	self.manager = manager
	self.managerConn = manager.updated:connect(function(oldState, newState)
		self:setState({
			data = newState,
		})
	end)
	self.state = {
		data = manager.state,
	}
end

function ComponentData:willUnmount()
	self.managerConn:disconnect()
end

function ComponentData:render()
	return self.props.render(self.state.data, self.manager)
end

return ComponentData
