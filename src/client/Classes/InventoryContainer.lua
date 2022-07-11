-- dependencies
local Array2D = require(game.ReplicatedStorage.Source.Shared.Util.Array2D)
local Items = require(game.ReplicatedStorage.Source.Shared.Data.Items)
local InventoryTypes = require(game.ReplicatedStorage.Source.Shared.Data.Types.Inventory)

-- public
local invContainer = {}
invContainer.__index = invContainer

function invContainer.new(containerData: InventoryTypes.Container)
	local self = setmetatable({}, invContainer)
	self.items = {}
	self.width = containerData.width
	self.height = containerData.height
	self.grid = Array2D.create(self.width, self.height, nil)
	return self
end

function invContainer:isValidPlace(itemInfo: Items.ItemInfo, itemX, itemY, itemR, ignoreId: string?)
	local dX, dY = Array2D.rotateDimension(itemInfo.size.X, itemInfo.size.Y, itemR)
	for y = itemY, itemY + dY - 1 do
		if y < 1 or y > self.height then
			return false
		end
		for x = itemX, itemX + dX - 1 do
			if x < 1 or x > self.width then
				return false
			end
			if ignoreId and ignoreId == Array2D.get(self.grid, self.width, self.height, x, y) then
				continue
			end
			if Array2D.get(self.grid, self.width, self.height, x, y) then
				return false
			end
		end
	end
	return true
end

function invContainer:add(item: InventoryTypes.Item)
	local index = #self.items + 1
	item._containerIndex = index
	self.items[index] = item
	-- fetch item info
	local itemInfo = Items[item.item]
	if not itemInfo then
		warn("InventoryContainer: can't get item info for item: ", item.item)
	end
	-- add item to grid
	local dX, dY = Array2D.rotateDimension(itemInfo.size.X, itemInfo.size.Y, 0)
	for y = item.y, item.y + dY - 1 do
		for x = item.x, item.x + dX - 1 do
			Array2D.set(self.grid, self.width, self.height, x, y, item.id) -- todo: potentially change this to a direct ref to the item
		end
	end
end

-- assumes item is in this container
function invContainer:remove(item)
	table.remove(self.items, item._containerIndex)
	-- o(1) method below: might enable if this becomes a bottleneck
	--[[
	local i1, i2 = item._containerIndex, #self.items
	local last = self.items[i2]
	self.items[i1] = last
	self.items[i2] = nil
	]]
end

return invContainer