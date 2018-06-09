--[[

This plugin allows components to run code during RenderStepped and Heartbeat.

	void heartbeat(number dt)

	void stepped(number dt)

]]

local RunService = game:GetService("RunService")

local SteppedPlugin = {}

function SteppedPlugin:init(args)
	if RunService:IsClient() then
		self.maid.steppedConn = RunService.RenderStepped:Connect(function(dt)
			for _,manager in pairs(self.componentManagers) do
				-- only step components that have a stepped method
				if manager.desc.stepped then
					debug.profilebegin(string.format("RenderStep `%s` components", manager.desc.className))
					for _, object in pairs(manager.instances) do
						object:stepped(dt)
					end
					debug.profileend()
				end
			end
		end)
	end

	self.maid.heartbeatConn = RunService.Heartbeat:Connect(function(dt)
		for _,manager in pairs(self.componentManagers) do
			-- only step components that have a stepped method
			if manager.desc.heartbeat then
				debug.profilebegin(string.format("Heartbeat `%s` components", manager.desc.className))
				for _, object in pairs(manager.instances) do
					object:heartbeat(dt)
				end
				debug.profileend()
			end
		end
	end)
end

return SteppedPlugin
