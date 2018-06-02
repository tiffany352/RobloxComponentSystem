local CollectionService = game:GetService("CollectionService")

local Component = require(script.Parent.Component)
local Symbol = require(script.Parent.Symbol)

local ComponentManager = {}
ComponentManager.__index = ComponentManager

local AddedFlag = Symbol.new("wasAdded")

function ComponentManager.new(desc, core, mixins)
	local self = {
		instances = {},
		desc = desc,
		core = core,
		mixins = {},
	}
	setmetatable(self, ComponentManager)

	for _,instance in pairs(CollectionService:GetTagged(desc.className)) do
		self:tagAdded(instance)
	end
	self.instanceAddedConn = CollectionService:GetInstanceAddedSignal(desc.className):Connect(function(instance)
		self:tagAdded(instance)
	end)
	self.instanceRemovedConn = CollectionService:GetInstanceRemovedSignal(desc.className):Connect(function(instance)
		self:tagRemoved(instance)
	end)

	return self
end

function ComponentManager:destroy()
	self.instanceAddedConn:Disconnect()
	self.instanceRemovedConn:Disconnect()
end

function ComponentManager:tagAdded(instance)
	local object = self.instances[instance]
	if not object then
		object = self:createObject(instance)
		object[AddedFlag] = false
		self.instances[instance] = object
	end
	if not object[AddedFlag] then
		object:added()
		object[AddedFlag] = true
	end
end

function ComponentManager:tagRemoved(instance)
	local object = self.instances[instance]
	if not object then
		return
	end
	if object[AddedFlag] then
		object:removed()
	end
	object:destroy()
	self.instances[instance] = nil
end

function ComponentManager:createObject(instance)
	local object = Component.new(self.desc, self.core, self.mixins, instance)
	object[AddedFlag] = false
	self.instances[instance] = object
	return object
end

return ComponentManager
