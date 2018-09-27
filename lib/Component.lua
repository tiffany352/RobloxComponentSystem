local Maid = require(script.Parent.Maid)

local function deepCopy(source)
	if typeof(source) == 'table' then
		local new = {}
		for key, value in pairs(source) do
			new[deepCopy(key)] = deepCopy(value)
		end
		return new
	end
	return source
end

local function merge(to, from)
	for key, value in pairs(from or {}) do
		to[deepCopy(key)] = deepCopy(value)
	end
end

local Component = {}
Component.__index = Component

function Component:extend(desc, core, mixins)
	local class = {
		className = desc.className,
		desc = desc,
		_core = core,
		_mixins = mixins,
	}
	class.__index = class
	setmetatable(class, self)

	local blacklist = {
		_isEntityComponent = true,
		className = true,
		defaultProps = true,
		ancestorWhitelist = true,
		ancestorBlacklist = true,
		init = true,
		added = true,
		removed = true,
	}
	for key, value in pairs(desc) do
		if not blacklist[key] then
			class[key] = deepCopy(value)
		end
	end

	for _,mixin in pairs(mixins) do
		merge(class, mixin)
	end

	return class
end

function Component:new(instance)
	local object = {
		instance = instance,
		maid = Maid.new(),
	}
	setmetatable(object, self)

	object:init()

	return object
end

function Component:init()
	merge(self, self.desc.defaultProps)

	for _,mixin in pairs(self._mixins) do
		if mixin.init then
			mixin.init(self)
		end
	end

	self.desc.init(self)

	local module = self.instance:FindFirstChild("ComponentProperties")
	local function load()
		local props = require(module:Clone())
		merge(self, props[self.className])
	end

	local function connectChanged()
		self._serializedPropsChanged = module.Changed:Connect(function(prop)
			if prop == 'Source' then
				merge(self, self.desc.defaultProps)
				load()
			end
		end)
	end

	if module then
		connectChanged()
		load()
	else
		self._childAdded = self.instance.ChildAdded:Connect(function(child)
			if child.Name == "ComponentProperties" then
				module = child
				connectChanged()
				load()
			end
		end)
	end
end

function Component:destroy()
	self.maid:clean()
	for _,mixin in pairs(self._mixins) do
		if mixin.destroy then
			mixin.destroy(self)
		end
	end
	if self._serializedPropsChanged then
		self._serializedPropsChanged:Disconnect()
	end
	if self._childAdded then
		self._childAdded:Disconnect()
	end
end

function Component:getComponent(component)
	return self._core:getComponentFromInstance(component, self.instance)
end

function Component:getComponentInParent(component)
	-- objects removed from the data model will have the instance removed signal fired on them, so the component will be detached
	assert(self.instance.Parent, "Component's instance has no parent")
	return self._core:getComponentFromInstance(component, self.instance.Parent)
end

function Component:getComponentInAncestor(component)
	local cur = self.instance.Parent
	while cur do
		local object = self._core:getComponentFromInstance(component, cur)
		if object then
			return object
		end
		cur = cur.Parent
	end
	return nil
end

function Component:getComponentsInDescendants(component)
	local components = {}
	for _,instance in pairs(self.instance:GetDescendants()) do
		local object = self._core:getComponentFromInstance(component, instance)
		if object then
			components[#components+1] = object
		end
	end
	return components
end

function Component:getComponentFromInstance(component, instance)
	return self._core:getComponentFromInstance(component, instance)
end

function Component:getComponentsOfType(component)
	return self._core:getComponentsOfType(component)
end

function Component:added()
	self.desc.added(self)

	for _,mixin in pairs(self._mixins) do
		if mixin.added then
			mixin.added(self)
		end
	end
end

function Component:removed()
	self.desc.removed(self)

	for _,mixin in pairs(self._mixins) do
		if mixin.removed then
			mixin.removed(self)
		end
	end
end

return Component
