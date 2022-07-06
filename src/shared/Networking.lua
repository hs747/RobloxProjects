-- shared network module
-- product of waffle's magnificent brain at 1:00 am

local RunService = game:GetService("RunService")
local Signal = require(game.ReplicatedStorage.Source.Shared.Lib.Signal)

local NETWORK_FOLDER_NAME = "Network"
local NETWORK_FOLDER_PARENT = game.ReplicatedStorage
local NETWORK_PATH_SEPERATOR = "/"
local NETWORK_PATH_PATTERN = string.format("[^%s]+", NETWORK_PATH_SEPERATOR)
local THROW_YIELD_WARNING = true
local THROW_YIELD_WARNING_AFTER = 3 -- seconds

local networkFolder
local remoteEvents = {}
local remoteFuncs = {}

local function findFirstFolder(parent: Instance, name: string): Folder?
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name == name and child:IsA("Folder") then
			return child
		end
	end
end

local function getFromPath(parent: Instance, path: string): Instance?
	local pathComponents = {}
	for s in path:gmatch(NETWORK_PATH_PATTERN) do
		table.insert(pathComponents, s)
	end
	for i = 1, #pathComponents - 1 do
		parent = findFirstFolder(parent, pathComponents[i])
	end
	return parent:FindFirstChild(pathComponents[#pathComponents])
end

-- the module interface
local networking = {}
if RunService:IsClient() then
	local eventAdded = Signal.new()
	local funcAdded = Signal.new()

	local function getPath(child: Instance): string
		local parent = child.Parent
		local path = child.Name
		while parent and not (parent == networkFolder) do
			path = parent.Name .. path
			parent = parent.Parent
		end
		return path
	end
	
	local function yieldWarning(resolved: boolean, path: string)
		if not resolved then
			warn(string.format("Possible infinite yield fetching remote. Path: %s. Please verify this remote is being created on the server.", path))
		end
	end

	local function waitForEvent(path: string): Instance
		local latestPath
		local latestEvent
		if THROW_YIELD_WARNING then task.delay(THROW_YIELD_WARNING_AFTER, yieldWarning, latestPath == path, path) end
		repeat
			latestPath, latestEvent = eventAdded:Wait()
		until latestPath == path
		return latestEvent
	end
	
	local function waitForFunc(path: string): Instance
		local latestPath
		local latestFunc
		if THROW_YIELD_WARNING then task.delay(THROW_YIELD_WARNING_AFTER, yieldWarning, latestPath == path, path) end
		repeat
			latestPath, latestFunc = funcAdded:Wait()
		until latestPath == path
		return latestFunc
	end
	
	local function newChild(child: Instance, parentPath: string)
		local path = parentPath and parentPath .. child.Name
		-- only call getPath in ifstatements to avoid calling it in excess
		if child:IsA("Folder") then
			for _, c in ipairs(child:GetChildren()) do
				newChild(c, path or getPath(child))
			end
		elseif child:IsA("RemoteEvent") then
			path = path or getPath(child)
			eventAdded:Fire(child, path)
		elseif child:IsA("RemoteFunction") then
			path = path or getPath(child)
			funcAdded:Fire(child, path)
		end
	end

	function networking.getEvent(path: string): Instance?
		local event = remoteEvents[path]
		if event then
			return event
		end
		if networkFolder then
			event = getFromPath(networkFolder, path)
			if event then
				remoteEvents[path] = event
				return event
			end
		end
		-- otherwise we wait for the object to be created
		local event = waitForEvent(path)
		remoteEvents[path] = event
		return event
	end
	
	function networking.getFunction(path: string): Instance?
		local func = remoteFuncs[path]
		if func then
			return func
		end
		if networkFolder then
			func = getFromPath(networkFolder, path)
			if func then
				remoteFuncs[path] = func
				return func
			end
		end
		-- otherwise we wait for the object to be created
		local func = waitForFunc(path)
		remoteFuncs[path] = func
		return func
	end
	
	task.spawn(function() 
		networkFolder = NETWORK_FOLDER_PARENT:WaitForChild(NETWORK_FOLDER_NAME)
		for _, child in pairs(networkFolder:GetChildren()) do
			newChild(child)
		end
		networkFolder.ChildAdded:Connect(newChild)
	end)
else -- assume we are server
	-- we make the network folder on the server at runtime
	local networkFolder = Instance.new("Folder")
	networkFolder.Name = NETWORK_FOLDER_NAME
	networkFolder.Parent = NETWORK_FOLDER_PARENT

	local function createPath(parent: Instance, path: string, lastIsDir: boolean): string?
		local pathComponents = {}
		for name in path:gmatch(NETWORK_PATH_PATTERN) do
			table.insert(pathComponents, name)
		end
		if #pathComponents < 1 then
			error("Could not process path string.")
		end
		for i = 1, (lastIsDir and #pathComponents or #pathComponents - 1) do
			local name = pathComponents[i]
			local newParent = findFirstFolder(parent, name)
			if not newParent then
				local folder = Instance.new("Folder")
				folder.Name = name
				folder.Parent = parent
				newParent = folder
			end
			parent = newParent
		end
		if not lastIsDir then
			return parent, pathComponents[#pathComponents]
		end
		return parent
	end

	function registerEvent(path: string): RemoteEvent
		if remoteEvents[path] then
			error(string.format("Attempted to register an event with a path that already exists. Path: %s", path))
		end
		local parent, name = createPath(networkFolder, path, false)
		local event = Instance.new("RemoteEvent")
		event.Name = name
		remoteEvents[path] = event
		event.Parent = parent
		return event
	end
	
	function registerFunction(path): RemoteFunction
		if remoteFuncs[path] then
			error(string.format("Attempted to register a function with a path that already exists. Path: %s", path))
		end
		local parent, name = createPath(networkFolder, path, false)
		local func = Instance.new("RemoteEvent")
		func.Name = name
		remoteFuncs[path] = func
		func.Parent = parent
		return func
	end
	
	function networking.getEvent(name: string): RemoteEvent
		local succ, ret = pcall(function()
			local event = remoteEvents[name]
			if event then
				return event
			end
			return registerEvent(name)
		end)
		if succ then
			return ret
		end
		error(ret, 2)
	end
	
	function networking.getFunction(name: string): RemoteFunction
		local succ, ret = pcall(function()
			local func = remoteFuncs[name]
			if func then
				return func
			end
			return registerFunction(name)
		end)
		if succ then
			return ret
		end
		error(ret, 2)
	end
end

return networking