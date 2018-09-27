--[[
	This plugin will automatically populate the component's properties
	from a ModuleScript named moduleName. It's set up
	like this:

	```lua
	return {
		SomeComponent = {
			SomeProperty = 4,
			SomeOtherProp = Vector3.new(),
		},
	}
	```

	This plugin has no API.
]]

local Symbol = require(script.Parent.Parent.Symbol)
local Maid = require(script.Parent.Parent.Maid)

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

local ModuleLoaderPlugin = {}

ModuleLoaderPlugin.ComponentMixins = {}

local LoaderMaidSymbol = Symbol.new("LoaderMaid")
local moduleName = "ComponentProperties"

function ModuleLoaderPlugin.ComponentMixins:init()
	local module = self.instance:FindFirstChild(moduleName)

	local maid = Maid.new()
	self[LoaderMaidSymbol] = maid

	local function reload()
		local props = require(module:Clone())
		merge(self, props[self.className])
	end

	local function moduleAdded(module)
		maid.sourceChangedConn = module.Changed:Connect(function(prop)
			if prop == 'Source' then
				merge(self, self.desc.defaultProps)
				reload()
			end
		end)

		reload()
	end

	maid.childAddedConn = self.instance.ChildAdded:Connect(function(child)
		if not module and child.Name == moduleName then
			module = child
			moduleAdded(module)
		end
	end)

	maid.childRemovedConn = self.instance.ChildRemoved:Connect(function(child)
		if module == child then
			maid.childAddedConn = nil
			module = self.instance:FindFirstChild(moduleName)
			if module then
				moduleAdded(module)
			end
		end
	end)

	if module then
		moduleAdded(module)
	end
end

function ModuleLoaderPlugin.ComponentMixins:destroy()
	local maid = self[LoaderMaidSymbol]
	maid:cleanup()
end

return ModuleLoaderPlugin
