local Component = {}
Component.__index = Component

function Component:extend(name, defaultProps)
	local component = {
		className = name,
		defaultProps = defaultProps,
		ancestorWhitelist = {},
		ancestorBlacklist = {},
		-- special flag used for auto-detection
		_isEntityComponent = true,
	}
	setmetatable(component, self)

	return component
end

function Component:init()
end

function Component:added()
end

function Component:removed()
end

return Component
