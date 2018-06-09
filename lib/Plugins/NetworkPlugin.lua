--[[

This plugin allows components to perform client-server communication easily.

## Server-only methods

	... sendClient(player, ...)

This method can be called to send a message to a component of the same name attached to the same instance, on a specific player's client.

	... sendBroadcast(...)

Similar to sendClient, but sends to all clients.

	void onServerEvent(player, ...)

Sent when a client calls sendServer().

## Client-only methods

	void sendServer(...)

Send a message to a component of the same name attached to the same instance, but on the server.

	void onClientEvent(...)

Sent when the server calls sendClient/sendBroadcast.

]]

local RunService = game:GetService("RunService")

local NetworkPlugin = {}

function NetworkPlugin:init(args)
	if not args.remoteEvent then
		error("args.remoteEvent must be specified when using NetworkPlugin")
	end
	if args.isServer == nil then
		error("args.isServer must be specified when using NetworkPlugin")
	end
	self.remoteEvent = args.remoteEvent
	self.isServer = args.isServer

	if args.isServer then
		self.maid.remoteEventConn = self.remoteEvent.OnServerEvent:Connect(function(player, instance, className, ...)
			NetworkPlugin.onServerEvent(self, player, instance, className, ...)
		end)
	else
		self.maid.remoteEventConn = self.remoteEvent.OnClientEvent:Connect(function(instance, className, ...)
			NetworkPlugin.onClientEvent(self, instance, className, ...)
		end)
	end
end

local function checkType(msg, value, ty)
	if typeof(value) ~= ty then
		error(string.format("%s: Expected %s, got %s", msg, ty, typeof(value)))
	end
end

function NetworkPlugin:onServerEvent(player, instance, className, ...)
	checkType("Argument #2", instance, 'Instance')
	checkType("Argument #3", className, 'string')
	local componentDesc = self.componentsByName[className]
	if not componentDesc then
		error(string.format("No such server component %q", className))
	end
	if not componentDesc.onServerEvent then
		error(string.format("Server component %q has no onServerEvent method", className))
	end
	local object = self:getComponentFromInstance(componentDesc, instance)
	if not object then
		error(string.format("Component %q is not present on the server's instance %q", className, instance:GetFullName()))
	end
	object:onServerEvent(player, ...)
end

function NetworkPlugin:onClientEvent(instance, className, ...)
	checkType("Argument #1", instance, 'Instance')
	checkType("Argument #2", className, 'string')
	local componentDesc = self.componentsByName[className]
	if not componentDesc then
		error(string.format("No such client component %q", className))
	end
	if not componentDesc.onClientEvent then
		error(string.format("Client component %q has no onClientEvent method", className))
	end
	local object = self:getComponentFromInstance(componentDesc, instance)
	if not object then
		error(string.format("Component %q is not present on the client's instance %q", className, instance:GetFullName()))
	end
	object:onClientEvent(...)
end

NetworkPlugin.ComponentMixins = {}

function NetworkPlugin.ComponentMixins:sendServer(...)
	assert(RunService:IsClient(), "sendServer can only be called from the client")
	self._core.remoteEvent:FireServer(self.instance, self.className, ...)
end

function NetworkPlugin.ComponentMixins:sendClient(player, ...)
	assert(RunService:IsServer(), "sendClient can only be called from the server")
	assert(typeof(player) == 'Instance' and player.ClassName == 'Player', "Expected player object to #1 for sendClient")
	self._core.remoteEvent:FireClient(player, self.instance, self.className, ...)
end

function NetworkPlugin.ComponentMixins:sendBroadcast(...)
	assert(RunService:IsServer(), "sendBroadcast can only be called from the server")
	self._core.remoteEvent:FireAllClients(self.instance, self.className, ...)
end

return NetworkPlugin
