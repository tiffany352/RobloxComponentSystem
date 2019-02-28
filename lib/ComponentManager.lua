local CollectionService = game:GetService("CollectionService")

local Component = require(script.Parent.Component)
local Symbol = require(script.Parent.Symbol)
local Maid = require(script.Parent.Maid)

local ComponentManager = {}
ComponentManager.__index = ComponentManager

local AddedFlag = Symbol.new("wasAdded")

function ComponentManager.new(desc, core, mixins)
	local self = {
		instances = {},
		desc = desc,
		class = Component:extend(desc, core, mixins),
		descendantAddedConns = Maid.new(),
		descendantRemovedConns = Maid.new(),
		enabled = false,
	}
	setmetatable(self, ComponentManager)

	return self
end

function ComponentManager:enable()
	if self.enabled then return end
	self.enabled = true


	local function tagAdded(instance)
		self:tagAdded(instance)
	end

	local function tagRemoved(instance)
		self:tagRemoved(instance)
	end

	for _,instance in pairs(CollectionService:GetTagged(self.desc.className)) do
		self:tagAdded(instance)
	end
	self.instanceAddedConn = CollectionService:GetInstanceAddedSignal(self.desc.className):Connect(tagAdded)
	self.instanceRemovedConn = CollectionService:GetInstanceRemovedSignal(self.desc.className):Connect(tagRemoved)

	for _,ancestor in pairs(self.desc.ancestorWhitelist) do
		self.descendantAddedConns[ancestor] = ancestor.DescendantAdded:Connect(tagAdded)
		self.descendantRemovedConns[ancestor] = ancestor.DescendantRemoving:Connect(function(instance)
			local conn
			conn = instance:GetPropertyChangedSignal("Parent"):Connect(function()
				conn:Disconnect()
				self:tagRemoved(instance)
			end)
		end)
	end

	for _,ancestor in pairs(self.desc.ancestorBlacklist) do
		self.descendantAddedConns[ancestor] = ancestor.DescendantAdded:Connect(tagRemoved)
		self.descendantRemovedConns[ancestor] = ancestor.DescendantRemoving:Connect(function(instance)
			local conn
			conn = instance:GetPropertyChangedSignal("Parent"):Connect(function()
				conn:Disconnect()
				self:tagAdded(instance)
			end)
		end)
	end
end

function ComponentManager:disable()
	if not self.enabled then return end
	self.enabled = false

	self.instanceAddedConn:Disconnect()
	self.instanceRemovedConn:Disconnect()
	self.descendantAddedConns:clean()
	self.descendantRemovedConns:clean()
end

function ComponentManager:destroy()
	self:disable()
end

function ComponentManager:shouldHaveComponent(instance)
	if not CollectionService:HasTag(instance, self.desc.className) then
		return false
	end

	if #self.desc.ancestorWhitelist > 0 then
		for _,ancestor in pairs(self.desc.ancestorWhitelist) do
			if instance:IsDescendantOf(ancestor) then
				return true
			end
		end
		return false
	elseif self.desc.ancestorBlacklist then
		for _,ancestor in pairs(self.desc.ancestorBlacklist) do
			if instance:IsDescendantOf(ancestor) then
				return false
			end
		end
		-- fall through
	end

	return instance:IsDescendantOf(game) or instance == game
end

function ComponentManager:tagAdded(instance)
	if not self:shouldHaveComponent(instance) then
		return
	end
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
	if self:shouldHaveComponent(instance) then
		return
	end
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
	local object = self.class:new(instance)
	object[AddedFlag] = false
	self.instances[instance] = object
	return object
end

return ComponentManager
