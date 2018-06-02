local Component = {}
Component.__index = Component

function Component:extend(name, defaultProps)
	local component = {
		className = name,
		defaultProps = defaultProps,
		-- special flag used for auto-detection
		_isEntityComponent = true,
	}
	setmetatable(component, self)

	return component
end

return Component
