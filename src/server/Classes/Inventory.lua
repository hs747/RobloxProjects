-- server inventory classes --
local Items = require(game.ReplicatedStorage.Source.Shared.Data.Items)
local InventoryTypes = require(game.ReplicatedStorage.Source.Shared.Data.Types.Inventory)
local InventoryDict = require(game.ReplicatedStorage.Source.Shared.Data.Dictionary).inventory

local inventorySlot = {}
inventorySlot.__index = inventorySlot

function inventorySlot.new()
	local self = setmetatable({}, inventorySlot)
	self.item = nil
	return self
end

function inventorySlot:setItem(item: InventoryTypes.Item)
	self.item = item --id
end

function inventorySlot:removeItem()
	self.item = nil
end

local inventoryContainer = {}
inventoryContainer.__index = inventoryContainer

function inventoryContainer.new(containerData: InventoryTypes.Container)
	local self = setmetatable({}, inventoryContainer)
	self.width = containerData.width
	self.height = containerData.height
	self.volume = 0 -- weakly implemented way to check for space overfilling
	return self
end

function inventoryContainer:addItem(itemId, itemData)
	local itemInfo = Items[itemData.item]
	self.volume += itemInfo.size.X * itemInfo.size.Y
end

function inventoryContainer:removeItem(itemId, itemData)
	local itemInfo = Items[itemData.item]
	self.volume -= itemInfo.size.X * itemInfo.size.Y
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
			id,
			item.item,
			item.x,
			item.y,
			item.r,
			item.container,
		})
	end
	-- containers
	data[2] = {}
	for id, container in pairs(self.containers) do
		table.insert(data[2], {
			id,
			container.width,
			container.height,
		})
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

function inventory:addItem(id: string, itemData: InventoryTypes.Item)
	self.items[id] = itemData
end

function inventory:addContainer(containerId, containerData: InventoryTypes.Container)
	self.containers[containerId] = inventoryContainer.new(containerData)
end

function inventory:addSlot(slotId)
	self.slots[slotId] = inventorySlot.new()
end

function inventory:moveItem(itemId, targetType, targetId, x, y, r)
	local itemData = self.items[itemId]
	if not itemData then
		return
	end
	if targetType == InventoryDict.moveTargetType.slot and itemData.slot == targetId then
		-- moved into same slot, do nothing
		return
	end
	if targetType == InventoryDict.moveTargetType.container and itemData.container == targetId then
		-- moved in the same container
		itemData.x = x
		itemData.y = y
		itemData.r = r
		return
	end
	if itemData.container then
		local currentContainer = self.containers[itemData.container]
		currentContainer:removeItem(itemId, itemData)
		itemData.container = nil
	elseif itemData.slot then
		local currentSlot = self.slots[itemData.slot]
		currentSlot:removeItem()
		itemData.slot = nil
	end
	if targetType == InventoryDict.moveTargetType.container then
		itemData.x = x
		itemData.y = y
		itemData.r = r
		itemData.container = targetId
		local targetContainer = self.containers[targetId]
		targetContainer:addItem(itemData)
	elseif targetType == InventoryDict.moveTargetType.slot then
		itemData.x = 1
		itemData.y = 1
		itemData.r = 0
		itemData.slot = targetId
		local targetSlot = self.slots[targetId]
		targetSlot:setItem(itemData)
	end
end

return inventory