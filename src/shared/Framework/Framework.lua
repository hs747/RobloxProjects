local framework = {}

local moduleHash = {}
local moduleList = {}

local function callModuleMethod(module: {[any]: any}, methodName: string, ...)
	local method = module[methodName]
	if method and type(method) == "function" then
		method(module, ...) -- call as module:methodName(...) with input variadic args
	end
end

-- adds a module script to the list
function framework:addModule(moduleScript: ModuleScript)
	-- ignore any module scripts that are already set to be loaded
	if moduleHash[moduleScript] then
		return
	end	
	local succ, ret = pcall(require, moduleScript)
	if not succ then
		error(string.format("\nFramework: Error requiring module [%s]. Error:\n%s", moduleScript.Name, ret))
	end
	moduleHash[moduleScript] = ret
	table.insert(moduleList, ret)
end

-- adds all module scripts that are children of the given instance
function framework:addContainer(instance: Instance)
	for moduleScript, child in ipairs(instance:GetChildren()) do
		if child:IsA("ModuleScript") then
			framework:addModule(child)			
		end
	end
end

-- calls all modules with the init and start methods
function framework:run()
	for _, module in pairs(moduleHash) do
		callModuleMethod(module, "init")
	end
	for _, module in pairs(moduleHash) do
		callModuleMethod(module, "start")
	end
end

function framework:call(methodName, ...)
	for _, module in ipairs(moduleList) do
		callModuleMethod(module, methodName, ...)
	end
end

return framework