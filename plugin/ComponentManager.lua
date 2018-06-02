local Selection = game:GetService("Selection")
local CollectionService = game:GetService("CollectionService")

local Source = script.Parent.Parent
local Maid = require(Source.EntitySystem.Maid)
local SandboxEnv = require(script.Parent.SandboxEnv)
local Signal = require(script.Parent.Signal)

local ComponentManager = {}
ComponentManager.__index = ComponentManager

function ComponentManager.new()
	local self = {
		maid = Maid.new(),
		components = {},
		updated = Signal.new(),
		state = {},
	}
	setmetatable(self, ComponentManager)

	self.maid.selectionChangedConn = Selection.SelectionChanged:Connect(function()
		self:selectionChanged()
	end)

	local servicesToCheck = {
		game:GetService("ServerScriptService"),
		game:GetService("ReplicatedStorage"),
		game:GetService("ReplicatedFirst"),
		game:GetService("StarterPlayer"),
	}

	for _,service in pairs(servicesToCheck) do
		for _,instance in pairs(service:GetDescendants()) do
			self:scriptAdded(instance)
		end
		self.maid:give(service.DescendantAdded:Connect(function(inst)
			self:scriptAdded(inst)
			self:update()
		end))
	end

	self:update()

	return self
end

function ComponentManager:destroy()
	self.maid:destroy()
end

function ComponentManager:doUpdate()
	local oldState = self.state

	local components = {}
	local componentsByName = {}
	for _,component in pairs(self.components) do
		components[#components+1] = {
			name = component.className,
			defaultProps = component.defaultProps,
		}
		componentsByName[component.className] = true
	end

	local componentsSelected = {}
	local instances = {}
	for _,selected in pairs(Selection:Get()) do
		local hasAny = false
		for _,tag in pairs(CollectionService:GetTags(selected)) do
			if componentsByName[tag] then
				componentsSelected[tag] = true
				hasAny = true
			end
		end
		if hasAny then
			instances[#instances+1] = {
				name = selected.Name,
				class = selected.ClassName,
			}
		end
	end

	local selected = {}
	for i, component in pairs(components) do
		if componentsSelected[component.name] then
			selected[#selected+1] = {
				componentIndex = i,
				properties = {}, -- todo
			}
		end
	end

	local newState = {
		components = components,
		selected = selected,
		instances = instances,
	}
	self.state = newState
	self.updated:fire(oldState, newState)
end

function ComponentManager:update()
	if not self.needsUpdate then
		self.needsUpdate = true
		spawn(function()
			self.needsUpdate = false
			self:doUpdate()
		end)
	end
end

function ComponentManager:selectionChanged()
	self:update()
end

function ComponentManager:tryLoad(module)
	local env = SandboxEnv.new(module)
	local ok, result = xpcall(function() return env.require(module) end, function(err) return err end)
	if ok and typeof(result) == 'table' and rawget(result, '_isEntityComponent') == true then
		self.components[#self.components+1] = result
		print("loaded", result.className)
	else
		--warn(string.format("Failed to load component-like ModuleScript %s: %s", module:GetFullName(), tostring(result)))
	end
end

function ComponentManager:scriptAdded(instance)
	local pattern = "%.Component%:extend%("
	if instance.ClassName == 'ModuleScript' and instance.Source:match(pattern) then
		self:tryLoad(instance)
	end
end

return ComponentManager
