local Maid = require(script.Parent.Parent.Maid)

local CorePlugin = {}

CorePlugin.ComponentMixins = {}

function CorePlugin.ComponentMixins:getComponent(component)
	return component._instances[self.instance]
end

function CorePlugin.ComponentMixins:getComponentInParent(component)
	-- objects removed from the data model will have the instance removed signal fired on them, so the component will be detached
	assert(self.instance.Parent, "Component's instance has no parent")
	return component._instances[self.instance.Parent]
end

function CorePlugin.ComponentMixins:getComponentsInDescendants(component)
	local components = {}
	for _,instance in pairs(self.instance:GetDescendants()) do
		local object = component._instances[instance]
		if object then
			components[#components+1] = object
		end
	end
	return components
end

function CorePlugin.ComponentMixins:extend(name, defaultProps)
	local Class = {}
	Class.__index = Class
	setmetatable(Class, self)

	-- begin only magical part of :extend()
	Class.className = name
	Class.defaultProps = defaultProps
	Class._isEntityComponent = true
	Class._instances = {}
	local entitySystem = self._entitySystem
	if entitySystem._components[name] then
		warn(string.format("Name conflict for component %q", name))
	end
	entitySystem._components[name] = Class
	-- end magic

	function Class.new(instance)
		local component = {
			instance = instance,
			maid = Maid.new(),
		}
		for key, value in pairs(defaultProps or {}) do
			component[key] = value
		end
		setmetatable(component, Class)

		return component
	end

	function Class:destroy()
		self.maid:clean()
	end

	return Class
end

return CorePlugin
