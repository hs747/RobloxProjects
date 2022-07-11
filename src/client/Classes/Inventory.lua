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
	for _, container in ipairs(data[2]) do
		self.containers[container[1]] = InventoryContainer.new({
			width = container[2],
			height = container[3],
		})
	end

	for _, slotId in ipairs(data[3]) do
		self.slots[slotId] = nil
	end

	for _, item in ipairs(data[1]) do
		self:_onAdded({
			id = item[1],
			item = item[2],
			x = item[3],
			y = item[4],
			r = item[5],
			container = item[6],
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

function inventory:_onMoved(itemId, containerId, x, y, r)
	local item: Item = self.items[itemId]
	if not (containerId == item.container) then
		-- swap containers
		local oldContainer, newContainer = self.containers[item.container], self.containers[containerId]
		oldContainer:remove(item)
		item.x = x
		item.y = y
		item.r = r
		item.container = containerId
		newContainer:add(item)
	else
		local container = self.containers[containerId] -- either containerId or item.container index works
		container:move(item, x, y, r)
	end
	return item
end

function inventory:getContainer(containerId)
	return self.containers[containerId]
end

function inventory:_onContainerAdded(containerId, containerData)
	self.containers[containerId] = InventoryContainer.new(containerData)
end

return inventory