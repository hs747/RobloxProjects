local InventoryTypes = require(game.ReplicatedStorage.Source.Shared.Data.Types.Inventory)

local InventorySlot = {}
InventorySlot.__index = InventorySlot

function InventorySlot.new()
	local self = setmetatable({}, InventorySlot)
	self.item = nil
	return self
end

function InventorySlot:canMoveInto(item)
	if self.item and not (self.item == item) then
		return false
	end
	return true
end

function InventorySlot:set(item: InventoryTypes.Item)
	self.item = item
end

function InventorySlot:remove()
	self.item = nil
end

return InventorySlot