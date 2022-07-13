local RunService = game:GetService("RunService")

local framework = {}

local moduleHash: {[ModuleScript]: boolean} = {}
local moduleList: {any} = {}

local function callModuleMethod(module: {[any]: any}, methodName: string, ...)
	local method = module[methodName]
	if method and type(method) == "function" then
		method(module, ...) -- call as module:methodName(...) with input variadic args
	end
end

local function loadModules(): boolean
	for moduleScript, _ in pairs(moduleHash) do
		local succ, ret = pcall(require, moduleScript)
		if not succ then
			warn(string.format("\nFramework: Error requiring module [%s]. Framework start cancelled.", moduleScript.Name))
			return false
		end
		table.insert(moduleList, ret)
	end
	return true
end

-- adds a module script to the list
function framework:addModule(moduleScript: ModuleScript)
	-- ignore any module scripts that are already set to be loaded
	--[[if moduleHash[moduleScript] then
		return
	end	
	local succ, ret = pcall(require, moduleScript)
	if not succ then
		warn(string.format("\nFramework: Error requiring module [%s]. Framework start cancelled.", moduleScript.Name))
		return false
	end
	moduleHash[moduleScript] = ret
	table.insert(moduleList, ret)
	return true]]
	if moduleHash[moduleScript] then
		return
	end
	moduleHash[moduleScript] = true
end

-- adds all module scripts that are children of the given instance
function framework:addContainer(instance: Instance)
	for moduleScript, child in ipairs(instance:GetChildren()) do
		if child:IsA("ModuleScript") then
			framework:addModule(child)
		end
	end
	return true
end

-- calls all modules with the init and start methods
function framework:run()
	print(string.format("%s framework starting.", RunService:IsClient() and "Client" or "Server"))
	local start = os.clock()
	local loaded = loadModules()
	if not loaded then
		return
	end
	for _, module in ipairs(moduleList) do
		callModuleMethod(module, "init")
	end
	for _, module in ipairs(moduleList) do
		callModuleMethod(module, "start")
	end
	print(string.format("%s framework start complete. Time: %3.3f", RunService:IsClient() and "Client" or "Server",os.clock() - start))
end

function framework:call(methodName, ...)
	for _, module in ipairs(moduleList) do
		callModuleMethod(module, methodName, ...)
	end
end

return framework