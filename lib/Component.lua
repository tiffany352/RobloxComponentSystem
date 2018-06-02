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

function Component.new(desc, core, mixins, instance)
	local self = {
		className = desc.className,
		instance = instance,
		maid = Maid.new(),
		_core = core,
	}
	setmetatable(self, Component)

	local blacklist = {
		_isEntityComponent = true,
		className = true,
		defaultProps = true,
	}
	for key, value in pairs(desc) do
		if not blacklist[key] then
			self[key] = deepCopy(value)
		end
	end

	merge(self, desc.defaultProps)

	for _,mixin in pairs(mixins) do
		merge(self, mixin)
	end

	local module = instance:FindFirstChild("ComponentProperties")
	local function load()
		local props = require(module:Clone())
		merge(self, props[self.className])
	end

	local function connectChanged()
		self._serializedPropsChanged = module.Changed:Connect(function(prop)
			if prop == 'Source' then
				merge(self, desc.defaultProps)
				load()
			end
		end)
	end

	if module then
		connectChanged()
		load()
	else
		self._childAdded = instance.ChildAdded:Connect(function(child)
			if child.Name == "ComponentProperties" then
				module = child
				connectChanged()
				load()
			end
		end)
	end

	return self
end

function Component:destroy()
	self.maid:clean()
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
	return self._core:getComponentInParent(component, self.instance.Parent)
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

function Component:added()
end

function Component:removed()
end

return Component
