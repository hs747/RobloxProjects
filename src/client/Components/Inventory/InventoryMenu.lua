local inventoryMenu = {}

-- dependencies
local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)
local Container = require(game.ReplicatedStorage.Source.Client.Components.Inventory.Container)
local Item = require(game.ReplicatedStorage.Source.Client.Components.Inventory.Item)

-- private
local INV_MENU_SIZE = UDim2.new(1.3, 0, 0.9, 0) -- relative yy
local GRID_SECTION_PADDING = 10 -- pixels from inv menu edge to sections
local GRID_SECTION_BETWEEN_PADDING = 20 -- pixels between sections

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
	SizeConstraint = Enum.SizeConstraint.RelativeYY,
	Size = INV_MENU_SIZE,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	BackgroundTransparency = 1,
}

local loadoutSection = containerSection(parentFrame, Vector2.new(0.5, 0.5), UDim2.new(1/6, 0, 0.5, 0), UDim2.new(1/3, -GRID_SECTION_BETWEEN_PADDING, 1, 0))
local inventorySection = containerSection(parentFrame, Vector2.new(0.5, 0.5), UDim2.new(3/6, 0, 0.5, 0), UDim2.new(1/3, -GRID_SECTION_BETWEEN_PADDING, 1, 0))
local externalSection = containerSection(parentFrame, Vector2.new(0.5, 0.5), UDim2.new(5/6, 0, 0.5, 0), UDim2.new(1/3, -GRID_SECTION_BETWEEN_PADDING, 1, 0))

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

function inventoryMenu:onContainerRemoved(containerId)
	local containerObj = containerObjects[containerId]
	if containerObj then
		containerObj:destroy()
	end
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