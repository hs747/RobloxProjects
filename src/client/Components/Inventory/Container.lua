local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)

local SECTION_GRID_WIDTH = 10
local CONTAINER_HEADER_PIXEL_SIZE = 20
local COLOR_GRID_LINE = Color3.fromRGB(124, 124, 124)

local container = WUX.Component(function(self, section, gridWidth, gridHeight, title)
    print(self, section, gridWidth, gridHeight)
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

function container:addItem(itemData, itemFrame)
    local x = itemData.x/self.gridWidth
    local y = itemData.y/self.gridHeight
    itemFrame.Position = UDim2.new(x, 0, y, 0)
	itemFrame.Size = UDim2.new(2/self.gridWidth, 0, 2/self.gridHeight, 0)
	itemFrame.Parent = self.content
end

return container