local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)
local Array2D = require(game.ReplicatedStorage.Source.Shared.Util.Array2D)
local Items = require(game.ReplicatedStorage.Source.Shared.Data.Items)
local InventoryTypes = require(game.ReplicatedStorage.Source.Shared.Data.Types.Inventory)

local SECTION_GRID_WIDTH = 8 -- how many gris in a section
local CONTAINER_HEADER_PIXEL_SIZE = 16
local COLOR_GRID_LINE = Color3.fromRGB(124, 124, 124)

local container = WUX.Component(function(self, section, id, gridWidth, gridHeight, title)
	self.id = id
    self.gridWidth = gridWidth
    self.gridHeight = gridHeight

    self.frame = WUX.New "Frame" {
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		Size = UDim2.new(gridWidth * 1/SECTION_GRID_WIDTH, 0, gridHeight * 1/SECTION_GRID_WIDTH, CONTAINER_HEADER_PIXEL_SIZE),
		BackgroundTransparency = 1,
	}

	self.header = WUX.New "Frame" {
		Parent = self.frame,
		Size = UDim2.new(1, 0, 0, CONTAINER_HEADER_PIXEL_SIZE),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 10,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(14, 14, 14),
		[WUX.Children] = {
			WUX.New "TextLabel" {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.9, 0, 0.8, 0),
				BackgroundTransparency = 1,

				Font = Enum.Font.FredokaOne,
				TextColor3 = Color3.fromRGB(214, 214, 214),
				TextScaled = true,
				Text = title or "Container",
			}
		}
	}

	self.content = WUX.New "Frame" {
		Parent = self.frame,
		Position = UDim2.new(0, 0, 0, CONTAINER_HEADER_PIXEL_SIZE),
		Size = UDim2.new(1, 0, 1, -CONTAINER_HEADER_PIXEL_SIZE),

		BackgroundTransparency = 1,
	}
	for x = 0, gridWidth do
		WUX.New "Frame" {
			Parent = self.content,
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(x/gridWidth, 0, 0, 0),
			ZIndex = -5,
			BorderSizePixel = 0,
			BackgroundColor3 = COLOR_GRID_LINE
		}
    end
    for y = 1, gridHeight do
		WUX.New "Frame" {
			Parent = self.content,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, y/gridHeight, 0),
			ZIndex = -5,
			BorderSizePixel = 0,
			BackgroundColor3 = COLOR_GRID_LINE
		}
	end

    self.frame.Parent = section
	return self
end)

function container:addItem(itemData: InventoryTypes.Item, itemFrame)
	local itemInfo = Items[itemData.item]
	if not itemInfo then
		warn("Container component: no item info for item: ", itemData.item)
	end
	local dX, dY = Array2D.rotateDimension(itemInfo.size.X, itemInfo.size.Y, itemData.r)
    local x = (itemData.x - 1)/self.gridWidth
    local y = (itemData.y - 1)/self.gridHeight
    itemFrame.Position = UDim2.new(x, 0, y, 0)
	itemFrame.Size = UDim2.new(dX/self.gridWidth, 0, dY/self.gridHeight, 0)
	itemFrame.Parent = self.content
end

function container:getDragGridPos(cornerPos)
	local cornerPosLocal = cornerPos - self.content.AbsolutePosition
	local pW = (self.content.AbsoluteSize.X/self.gridWidth)
	local pH = (self.content.AbsoluteSize.Y/self.gridHeight)
	return math.floor(0.5 + cornerPosLocal.X/pW) + 1, math.floor(0.5 + cornerPosLocal.Y/pH) + 1
end

function container:addTempHighlight(highlight, itemData, x, y, r)
	local itemInfo = Items[itemData.item]
	local dX, dY = Array2D.rotateDimension(itemInfo.size.X, itemInfo.size.Y, r)
	highlight.Size = UDim2.new(dX/self.gridWidth, 0, dY/self.gridHeight, 0)
	highlight.Position = UDim2.new((x - 1)/self.gridWidth, 0, (y - 1)/self.gridHeight, 0)
	highlight.Parent = self.content
end

function container:isPointIn(point: Vector2)
	local contentPos, contentSize = self.content.AbsolutePosition, self.content.AbsoluteSize
	point -= contentPos
	return point.X >= 0 and point.X <= contentSize.X and point.Y >= 0 and point.Y <= contentSize.Y
end

-- returns pixels/grid cell for this specific container
function container:getGridPixelSize()
	return self.frame.AbsoluteSize.X/self.gridWidth
end

function container:destroy()
	self.frame:Destroy()
end

return container