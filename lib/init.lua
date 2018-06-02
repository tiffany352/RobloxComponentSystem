local CollectionService = game:GetService("CollectionService")

local Symbol = require(script.Symbol)
local Component = require(script.Component)

local EntitySystem = {}
EntitySystem.Component = Component
Component._entitySystem = EntitySystem

EntitySystem._components = {}
EntitySystem._queued = {}
EntitySystem.AddedFlag = Symbol.new("wasAdded")

function EntitySystem.getComponentFromInstance(component, instance)
	return component._instances[instance]
end

function EntitySystem.addComponentToInstance(component, instance)
	CollectionService:AddTag(instance, component.className)

	if component._instances[instance] then
		return component._instances[instance]
	end

	local object = component.new(instance)
	object[EntitySystem.AddedFlag] = false
	component._instances[instance] = object
	EntitySystem._queued[#EntitySystem._queued+1] = object

	return object
end

function EntitySystem.setup(args)
	for _,plug in pairs(Component._plugins) do
		if plug.init then
			plug.init(EntitySystem, args)
		end
	end
	for _,component in pairs(EntitySystem._components) do
		local function attach(instance)
			if component._instances[instance] then
				return
			end
			local object = component.new(instance)
			object[EntitySystem.AddedFlag] = false
			component._instances[instance] = object
			EntitySystem._queued[#EntitySystem._queued+1] = object

			return component
		end

		local function detach(instance)
			local object = component._instances[instance]
			if not object then
				return
			end
			if object[EntitySystem.AddedFlag] then
				object:removed()
			end
			object:destroy()
			component._instances[instance] = nil
		end

		for _,instance in pairs(CollectionService:GetTagged(component.className)) do
			attach(instance)
		end
		CollectionService:GetInstanceAddedSignal(component.className):Connect(attach)
		CollectionService:GetInstanceRemovedSignal(component.className):Connect(detach)
	end
end

function EntitySystem.doStepped(dt)
	for _,component in pairs(EntitySystem._components) do
		-- only step components that have a stepped method
		if component.stepped then
			debug.profilebegin(string.format("Stepping %s components", component.className))
			for _, object in pairs(component._instances) do
				object:stepped(dt)
			end
			debug.profileend()
		end
	end
end

-- call this as late as possible, or at least after _doStepped
function EntitySystem.processQueue()
	local queue = EntitySystem._queued
	if #queue == 0 then
		return
	end
	local bindable = Instance.new("BindableEvent")
	EntitySystem._queued = {}
	for i = 1, #queue do
		local comp = queue[i]
		if not comp[EntitySystem.AddedFlag] then
			bindable.Event:Connect(function()
				comp[EntitySystem.AddedFlag] = true
				queue[i]:added()
			end)
		end
	end
	bindable:Fire()
	bindable:Destroy()
end

return EntitySystem
