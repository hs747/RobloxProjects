local inventoryMenu = {}

-- dependencies
local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)

-- private
local GRID_PIXEL_SIZE = 20
local GRID_SECTION_PADDING = 10
local CONTAINER_HEADER_PIXEL_SIZE = 10

local function container(containerSection, gridWidth, gridHeight)
	local frame = WUX.New "Frame" {
		Size = UDim2.new(0, GRID_PIXEL_SIZE * gridWidth, 0, CONTAINER_HEADER_PIXEL_SIZE + GRID_PIXEL_SIZE * gridHeight),
		BackgroundTransparency = 1,
	}

	local header = WUX.New "Frame" {
		Parent = frame,
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
				Text = "Container",
			}
		}
	}

	for x = 1, gridWidth - 1 do
		WUX.New "Frame" {
			Parent = frame,
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(0, GRID_PIXEL_SIZE * x, 0, 0),
			ZIndex = 5,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(185, 185, 185),
		}
	end

	for y = 1, gridHeight - 1 do
		WUX.New "Frame" {
			Parent = frame,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0, CONTAINER_HEADER_PIXEL_SIZE + GRID_PIXEL_SIZE * y),
			ZIndex = 5,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(185, 185, 185),
		}
	end

	frame.Parent = containerSection
	return frame
end

local function containerSection(parent, cornerPosition, gridWidth) 
	return WUX.New "Frame" {
		Parent = parent,
		Position = cornerPosition,
		Size = UDim2.new(0, GRID_PIXEL_SIZE * gridWidth + GRID_SECTION_PADDING * 2, 1, 0),

		BorderSizePixel = 0,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),

		[WUX.Children] = {
			WUX.New "UIListLayout" {
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}
		}
	}
end

local parentFrame = WUX.New "Frame" {
	Name = "InventoryMenu",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 0.5,
}

containerSection(parentFrame, UDim2.new(0, 0, 0, 0), 10)
container(parentFrame, 10, 4)

-- public
function inventoryMenu:mount(parent)
	parentFrame.Parent = parent
end

return inventoryMenu