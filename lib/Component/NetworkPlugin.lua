local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote

local NetworkPlugin = {}
NetworkPlugin.ComponentMixins = {}

function NetworkPlugin.ComponentMixins:sendServer(...)
	assert(RunService:IsClient(), "sendServer can only be called from the client")
	remote:FireServer(self.instance, self.className, ...)
end

function NetworkPlugin.ComponentMixins:sendClient(player, ...)
	assert(RunService:IsServer(), "sendClient can only be called from the server")
	assert(typeof(player) == 'Instance' and player.ClassName == 'Player', "Expected player object to #1 for sendClient")
	remote:FireClient(player, self.instance, self.className, ...)
end

function NetworkPlugin.ComponentMixins:sendBroadcast(...)
	assert(RunService:IsServer(), "sendBroadcast can only be called from the server")
	remote:FireAllClients(self.instance, self.className, ...)
end

function NetworkPlugin.init(Component, args)
	remote = ReplicatedStorage:FindFirstChild("ComponentMessage") or error("Failed to find ReplicatedStorage.ComponentMessage BindableEvent")
	if args.isServer then
		remote.OnServerEvent:Connect(function(player, instance, className, ...)
			local component = Component._components[className]
			if not component then
				error(string.format("No such server component %q", className))
			end
			if not component.onServerEvent then
				error(string.format("Server component %q has no onServerEvent method", className))
			end
			local object = component and component._instances[instance]
			if not object then
				error(string.format("Instance has no server version of component %q", className))
			end
			object:onServerEvent(player, ...)
		end)
	else
		remote.OnClientEvent:Connect(function(instance, className, ...)
			local component = Component._components[className]
			if not component then
				error(string.format("No such client component %q", className))
			end
			if not component.onClientEvent then
				error(string.format("Client component %q has no onClientEvent method", className))
			end
			local object = component and component._instances[instance]
			if not object then
				error(string.format("Instance has no client version of component %q", className))
			end
			object:onClientEvent(...)
		end)
	end
end

return NetworkPlugin
