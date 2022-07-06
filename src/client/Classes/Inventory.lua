-- type decls (move these to shared later)
type Item = {
	id: string, -- unique to the inventory for the item
	container: string,
	isContainer: boolean,
	x: number, -- grid x pos of item (top right)
	y: number, -- grid y pos
}

type ClientItem = Item & {
	_containerIndex: number
}
--
local inventory = {}
inventory.__index = inventory

local function isContainer(item: Item) -- subject to change for compression reasons probably
	return item.isContainer
end

function inventory.new(networkGroup)
	local self = setmetatable({}, inventory)
	self.items = {}
	self.containers = {}
	
	self.getRemote = networkGroup:WaitForChild("Get")
	self.addedRemote = networkGroup:WaitForChild("Added")
	self.removedRemote = networkGroup:WaitForChild("Removed")
	return self	
end

-- fetch all data from the server about this inventory
function inventory:networkGet()
	local data = self.getRemote:InvokeServer()
	self.containers = {}
	for _, containerId in ipairs(data) do
		self.containers[containerId] = {}
	end
	self.items = {}
	for _, item: Item in ipairs(data) do
		self.items[item.id] = item
		local container = self.containers[item.container]
		if not container then
			container = {}
			self.containers[item.container] = container
		end
		table.insert(container, item) -- can do o(n) remove later
	end
end

-- listen for updates about this inventory
function inventory:networkListen()
	
end

function inventory:_onAdded(item: Item)
	self.items[item.id] = item
	table.insert(self.containers[item.container], item)
	if isContainer(item) then
		self.containers[item.id] = {}
	end
end

function inventory:_onRemoved(item: Item)
	self.items[item.id] = nil
	-- remove from container
	if isContainer(item) then
		self.containers[item.id] = {}
	end
end

function inventory:addStaticContainer(containerName)
	
end

return inventory