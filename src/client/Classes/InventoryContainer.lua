local invContainer = {}
invContainer.__index = invContainer

function invContainer.new()
	local self = setmetatable({}, invContainer)
	self.items = {}
	return self	
end

function invContainer:add(item)
	local index = #self.items + 1
	item._containerIndex = index
	self.items[index] = item 
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