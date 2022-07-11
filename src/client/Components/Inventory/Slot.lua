-- component that visualizes the inventory "slots"
-- things that can be set/held but aren't for general inventory storage such as gun equip slots/etcs

-- dependencies --
local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)

-- constants --
local SLOT_SIZE = UDim2.new(0, 64, 0, 64)
local SLOT_BACK_COLOR = Color3.fromRGB(43, 43, 43)
local SLOT_BORDER_COLOR = Color3.fromRGB(124, 124, 124)

-- public --
local slot = WUX.Component(function(self, props)
	self.frame = WUX.New "Frame" {
		Name = "InventorySlot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = props.Position,
		Size = SLOT_SIZE,
		BackgroundColor3 = SLOT_BACK_COLOR,
		BorderColor3 = SLOT_BORDER_COLOR,
		BorderSizePixel = 1
	}
	return self
end)

function slot:addTempHighlight(highlight)
	highlight.Position = UDim2.new(0, 0, 0, 0)
	highlight.Size = UDim2.new(1, 0, 1, 0)
	highlight.Parent = self.frame
end

function slot:isPointIn(point: Vector2)
	local pos, size = self.frame.AbsolutePosition, self.frame.AbsoluteSize
	point -= pos
	return point.X >= 0 and point.X <= size.X and point.Y >= 0 and point.Y <= size.Y
end

function slot:addItem(itemData, itemObj)
	itemObj.Position = UDim2.new(0, 0, 0, 0)
	itemObj.Size = UDim2.new(1, 0, 1, 0)
	itemObj.Parent = self.frame
end

function slot:mount(parent)
	self.frame.Parent = parent
end

return slot