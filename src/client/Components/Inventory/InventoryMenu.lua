local inventoryMenu = {}

-- dependencies
local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)
local Container = require(game.ReplicatedStorage.Source.Client.Components.Inventory.Container)
local Item = require(game.ReplicatedStorage.Source.Client.Components.Inventory.Item)

-- private
local GRID_SECTION_PADDING = 10

local function containerSection(parent, anchorPoint, position, size) 
	return WUX.New "Frame" {
		Parent = parent,
		AnchorPoint = anchorPoint,
		Position = position,
		Size = size,

		BorderSizePixel = 0,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),

		[WUX.Children] = {
			WUX.New "UIPadding" {
				PaddingTop = UDim.new(0, GRID_SECTION_PADDING),
				PaddingBottom = UDim.new(0, GRID_SECTION_PADDING),
				PaddingLeft = UDim.new(0, GRID_SECTION_PADDING),
				PaddingRight = UDim.new(0, GRID_SECTION_PADDING),
			},
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
	BackgroundTransparency = 1,
}

local inventorySection = containerSection(parentFrame, Vector2.new(0.5, 0.5), UDim2.new(3/6, 0, 0.5, 0), UDim2.new(1/3, -20, 1, 0))
local externalSection = containerSection(parentFrame, Vector2.new(0.5, 0.5), UDim2.new(5/6, 0, 0.5, 0), UDim2.new(1/3, -20, 1, 0))

local containerObjects = {}
local itemObjects = {}
local isOpen = false

-- public
function inventoryMenu:toggle()
	if isOpen then
		self:close()
	else
		self:open()
	end
end

function inventoryMenu:open()
	parentFrame.Visible = true
	isOpen = true
end

function inventoryMenu:close()
	parentFrame.Visible = false
	isOpen = false
end

function inventoryMenu:onContainerRemoved()

end

function inventoryMenu:onContainerAdded(containerId, containerData)
	local containerObj = Container(inventorySection, containerData.width, containerData.height, containerId)
	containerObjects[containerId] = containerObj
end

function inventoryMenu:onItemAdded(itemId, itemData)
	local containerObj = itemData.container and containerObjects[itemData.container]
	if not containerObj then
		warn("InvMenu: Can't find container for item.")
		return
	end
	local itemFrame = Item(itemId, itemData)
	containerObj:addItem(itemData, itemFrame)
end

function inventoryMenu:onInventorySet()

end

function inventoryMenu:mount(parent)
	parentFrame.Parent = parent
end

return inventoryMenu