local Core = require(script.Core)
local ComponentDesc = require(script.ComponentDesc)

local EntitySystem = {}

EntitySystem.Component = ComponentDesc
EntitySystem.Core = Core

for _,plug in pairs(script.Plugins:GetChildren()) do
	EntitySystem[plug.Name] = require(plug)
end

return EntitySystem
