local CollectionService = game:GetService("CollectionService")

local Maid = require(script.Parent.Maid)
local ComponentManager = require(script.Parent.ComponentManager)

local Core = {}
Core.__index = Core

function Core.new(args)
	local self = {
		componentManagers = {},
		componentsByName = {},
		plugins = args.plugins or {},
		mixins = {},
		maid = Maid.new()
	}
	setmetatable(self, Core)

	for _,plug in pairs(args.plugins or {}) do
		if plug.init then
			plug.init(self, args)
		end
		if plug.ComponentMixins then
			self.mixins[#self.mixins+1] = plug.ComponentMixins
		end
	end

	return self
end

function Core:registerComponent(componentDesc)
	if self.componentsByName[componentDesc.className] then
		error(string.format("Component name conflict for %q", componentDesc.className))
	end
	self.componentsByName[componentDesc.className] = componentDesc
	self.componentManagers[componentDesc] = ComponentManager.new(componentDesc, self, self.mixins)
end

function Core:getComponentFromInstance(componentDesc, instance)
	local manager = self.componentManagers[componentDesc]
	if not manager then
		error(string.format("Attempt to get component %s that isn't registered to core", componentDesc.className))
	end

	local object = manager.instances[instance]
	if not object and CollectionService:HasTag(instance, componentDesc.className) then
		object = manager:createObject(instance)
	end

	return object
end

function Core.addComponentToInstance(component, instance)
	CollectionService:AddTag(instance, component.className)

	return Core.getComponentFromInstance(component, instance)
end

return Core
