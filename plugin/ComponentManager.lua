local Selection = game:GetService("Selection")
local CollectionService = game:GetService("CollectionService")

local Source = script.Parent.Parent
local Maid = require(Source.EntitySystem.Maid)
local SandboxEnv = require(script.Parent.SandboxEnv)
local Signal = require(script.Parent.Signal)
local Serial = require(script.Parent.Serial)

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

function ComponentManager:setComponentProperty(componentName, propertyName, value)
	assert(componentName, "componentName must not be nil")
	assert(propertyName, "propertyName must not be nil")
	for _,selected in pairs(Selection:Get()) do
		if CollectionService:HasTag(selected, componentName) then
			local module = selected:FindFirstChild("ComponentProperties")
			local data = module and Serial.Deserialize(module.Source)
			data = data or {}
			data[componentName] = data[componentName] or {}
			local component
			for i = 1, #self.components do
				if self.components[i].className == componentName then
					component = self.components[i]
				end
			end
			local default = nil
			if component and component.defaultProps then
				default = component.defaultProps[propertyName]
			end
			if default ~= value then
				data[componentName][propertyName] = value
			else
				data[componentName][propertyName] = nil
			end
			if not module then
				module = Instance.new("ModuleScript")
				module.Name = "ComponentProperties"
			end
			module.Source = Serial.Serialize(data)
			module.Parent = selected
		end
	end
	self:update()
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
				local cstag = componentsSelected[tag]
				if not cstag then
					cstag = {}
					componentsSelected[tag] = cstag
				end
				cstag[#cstag+1] = selected
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
		local instances = componentsSelected[component.name]
		if instances then
			local commonProps = {}
			for key, default in pairs(component.defaultProps or {}) do
				local common
				local pass = true
				for i = 1, #instances do
					local instance = instances[i]
					local module = instance:FindFirstChild("ComponentProperties")
					local data = module and Serial.Deserialize(module.Source)
					data = data and data[component.name]
					local instValue = default
					if data and data[key] ~= nil then
						instValue = data[key]
					end
					if i == 1 then
						common = instValue
					end
					if instValue ~= common then
						pass = false
						break
					end
				end
				if pass then
					commonProps[key] = common
				end
			end
			selected[#selected+1] = {
				componentIndex = i,
				properties = commonProps,
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
	local selConns = Maid.new()
	self.maid.selectedConns = selConns
	for i,sel in pairs(Selection:Get()) do
		selConns['childAdded'..i] = sel.ChildAdded:Connect(function() self:update() end)
		local module = sel:FindFirstChild("ComponentProperties")
		if module then
			selConns['moduleChanged'..i] = module:GetPropertyChangedSignal("Source"):Connect(function() self:update() end)
		end
	end
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
