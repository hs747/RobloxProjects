-- server inventory classes --

local inventoryContainer = {}
inventoryContainer.__index = inventoryContainer

function inventoryContainer.new()
	local self = setmetatable({}, inventoryContainer)
	return self
end

-- base class for an inventory (does not handle networking)
local inventory = {}
inventory.__index = inventory

function inventory.new()
	local self = setmetatable({}, inventory)
	-- data
	self.items = {}
	self.containers = {}
	self.slots = {}
	
	-- networking
	self.listeners = {}
	return self
end

-- outputs into data for sending to clients, possibly storage?
function inventory:serialize()
	local data = {}
	-- items
	data[1] = {}
	for id, item in pairs(self.items) do
		table.insert(data[1], {
			[1] = id,
			[2] = item.x,
			[3] = item.y,
			[4] = item.container,
		})
	end
	-- containers
	data[2] = {}
	for id, container in pairs(self.containers) do
		table.insert(data[2], id)
	end
	-- slots
	data[3] = {}
	for id, slot in pairs(self.slots) do
		table.insert(data[3], id)
	end

	return data
end

function inventory:addListener(player: Player)
	table.insert(self.listeners, player)
end

function inventory:addItem(id, itemData)
	self.items[id] = itemData
end

function inventory:addContainer(containerId)
	self.containers[containerId] = {
		id = containerId,
	}
end

function inventory:addSlot(slotId)
	self.slots[slotId] = {
		id = slotId
	}
end

return inventory