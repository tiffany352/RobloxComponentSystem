local plugins = {}
for _,module in pairs(script:GetChildren()) do
	plugins[#plugins+1] = require(module)
end

local Component = {}
Component.__index = Component

Component._plugins = plugins

function Component:added()
end

function Component:removed()
end

for _,plug in pairs(plugins) do
	for key, value in pairs(plug.ComponentMixins) do
		Component[key] = value
	end
end

return Component
