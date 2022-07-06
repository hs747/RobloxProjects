-- type decls (move these to shared later)
type Item = {
	id: string, -- unique to the inventory for the item
	container: string,
	x: number, -- grid x pos of item (top right)
	y: number, -- grid y pos
}

type ClientItem = Item & {
	_containerIndex: number
}

-- dependencies
local InventoryContainer = require(game.ReplicatedStorage.Source.Client.Classes.InventoryContainer)

-- the class
local inventory = {}
inventory.__index = inventory

local function isContainer(item: Item) -- subject to change for compression reasons probably
	return item.isContainer
end

function inventory.new(networkGroup)
	local self = setmetatable({}, inventory)
	self.items = {}
	self.slots = {}
	self.containers = {}
	return self	
end

-- network event callbacks

function inventory:_onSet(data)
	for _, containerId in ipairs(data[2]) do
		self.containers[containerId] = InventoryContainer.new()
	end

	for _, slotId in ipairs(data[3]) do
		self.slots[slotId] = nil
	end

	for _, item in ipairs(data[1]) do
		self:_onAdded({
			id = item[1],
			x = item[2],
			y = item[3],
			container = item[4],
		})
	end
end

function inventory:_onAdded(item: Item)
	self.items[item.id] = item
	if item.container then
		local container = self.containers[item.container]
		container:add(item)
	elseif item.slot then
		self.slots[item.slot] = item
	end
end

function inventory:_onRemoved(item: Item)
	self.items[item.id] = nil
	-- remove item from container/slot
	if item.container then
		local container = self.containers[item.container]
		container:remove(item)
	elseif item.slot then
		self.slots[item.slot] = nil
	end
end

function inventory:addStaticContainer(containerName)
	
end

return inventory