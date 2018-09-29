--[[

This plugin provides access to a provided rodux store to components.

	void storeChanged(table new, table old)

	Rodux.Store roduxStore
]]

local RoduxPlugin = {}

function RoduxPlugin:init(args)
	if not args.roduxStore then
		error("args.store must be specified when using RoduxPlugin")
	end

	self.roduxStore = args.roduxStore

	self.maid.storeChangedConn = self.roduxStore.changed:connect(function (new, old)
		for _,manager in pairs(self.componentManagers) do
			-- only fire components that have a onStoreChanged method
			if manager.desc.onStoreChanged then
				for _, object in pairs(manager.instances) do
					object:onStoreChanged(new, old)
				end
			end
		end
	end)
end

RoduxPlugin.ComponentMixins = {}

function RoduxPlugin.ComponentMixins:init()
	self.roduxStore = self._core.roduxStore
end

return RoduxPlugin
