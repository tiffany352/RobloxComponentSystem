local Source = script.Parent.Parent.Parent
local Roact = require(Source.Roact)

local ComponentProvider = Roact.PureComponent:extend("ComponentProvider")

function ComponentProvider:init(props)
	local manager = props.manager
	assert(manager, "Expected manager to be passed as props to ComponentProvider")
	self._context[ComponentProvider] = manager
end

function ComponentProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

return ComponentProvider
