local Instance = require(script.Instance)

local SandboxEnv = {}

function SandboxEnv.new(script, baseEnv)
	local env = {}

	env.script = Instance.new(script)

	local gameWhitelist = {
		ReplicatedStorage = true,
		ServerScriptService = true,
		ServerStorage = true,
	}
	env.game = Instance.new(game, {
		GetService = function(self, service)
			assert(typeof(service) == 'string')
			if gameWhitelist[service] then
				return Instance.new(game:GetService(service))
			end
		end,
		__childrenWhitelist = gameWhitelist
	})

	env._G = env
	env.assert = assert
	env.error = error
	env.pairs = pairs
	env.ipairs = ipairs
	env.next = next
	env.pcall = pcall
	env.print = print
	env.select = select
	env.tonumber = tonumber
	env.tostring = tostring
	env.type = type
	env.unpack = unpack
	env.xpcall = xpcall
	env.setmetatable = setmetatable

	-- libraries
	env.string = string
	env.math = math
	env.table = table
	env.utf8 = utf8

	function env.require(module)
		if typeof(module) ~= 'Instance' then
			module = module[Instance.InstanceKey]
		end
		local func = loadstring(module.Source, '@'..module:GetFullName())
		setfenv(func, SandboxEnv.new(module))
		return func()
	end

	return env
end

return SandboxEnv
