local inventoryMenu = {}

-- dependencies --
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Signal = require(game.ReplicatedStorage.Source.Shared.Signal)
local Cleaner = require(game.ReplicatedStorage.Source.Shared.Cleaner)
local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)
local Array2D = require(game.ReplicatedStorage.Source.Shared.Util.Array2D)
local Items = require(game.ReplicatedStorage.Source.Shared.Data.Items)
local InventoryDict = require(game.ReplicatedStorage.Source.Shared.Data.Dictionary).inventory

-- components
local Slot = require(game.ReplicatedStorage.Source.Client.Components.Inventory.Slot)
local Container = require(game.ReplicatedStorage.Source.Client.Components.Inventory.Container)
local Item = require(game.ReplicatedStorage.Source.Client.Components.Inventory.Item)

-- private --
local INV_MENU_SIZE = UDim2.new(1.75, 0, 0.9, 0) -- relative yy
local GRID_SECTION_PADDING = 10 -- pixels from inv menu edge to sections
local GRID_SECTION_BETWEEN_PADDING = 20 -- pixels between sections
local GRID_SECTION_VERTICAL_PADDING = 5 -- pixels between containers in the same section
local DRAG_GRID_SIZE_PIXEL = 25

local slotObjects = {}
local containerObjects = {}
local itemObjects = {}
local isOpen = false

-- components
local parentFrame = WUX.New "Frame" {
	Name = "InventoryMenu",
	Size = UDim2.new(1, 0, 1, 0),
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundTransparency = 1,
}

local sectionParentFrame = WUX.New "Frame" {
	Parent = parentFrame,
	Name = "Sections",
	SizeConstraint = Enum.SizeConstraint.RelativeYY,
	Size = INV_MENU_SIZE,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	BackgroundTransparency = 1,
}

local function section(parent, anchorPoint, position ,size)
	return WUX.New "Frame" {
		Parent = parent,
		AnchorPoint = anchorPoint,
		Position = position,
		Size = size,

		BorderSizePixel = 0,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
	}
end

local function containerSection(parent, anchorPoint, position, size)
	local sect = section(parent, anchorPoint, position, size)
	WUX.New "UIPadding" {
		Parent = sect,
		PaddingTop = UDim.new(0, GRID_SECTION_PADDING),
		PaddingBottom = UDim.new(0, GRID_SECTION_PADDING),
		PaddingLeft = UDim.new(0, GRID_SECTION_PADDING),
		PaddingRight = UDim.new(0, GRID_SECTION_PADDING),
	}
	WUX.New "UIListLayout" {
		Parent = sect,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, GRID_SECTION_VERTICAL_PADDING)
	}
	return sect
end

local function itemMoveGuiObject(itemData, gridAbsoluteSize)
	local itemInfo = Items[itemData.item]
	local dX, dY = Array2D.rotateDimension(itemInfo.size.X, itemInfo.size.Y, itemData.r)
	return WUX.New "Frame" {
		Parent = parentFrame,
		BackgroundTransparency = 0.5,
		Size = UDim2.new(0, dX * gridAbsoluteSize, 0, dY * gridAbsoluteSize),
		ZIndex = 10,
	}
end

local function itemMovePlaceHighlight()
	return WUX.New "ImageLabel" {
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(Vector2.new(4, 4), Vector2.new(60, 60)),
		Image = "rbxassetid://10182267725",
		ZIndex = 10,
	}
end

-- item movement
local itemMoveState

-- Using the provided vector 2, finds the destination container or slot.
-- Returns the container/slot id, an enum if it is a container or slot and the object.
local function getDragTargetFromPoint(point: Vector2)
	for id, containerObj in pairs(containerObjects) do
		if containerObj:isPointIn(point) then
			return id, InventoryDict.moveTargetType.container, containerObj
		end
	end
	for id, slotObj in pairs(slotObjects) do
		if slotObj:isPointIn(point) then
			return id, InventoryDict.moveTargetType.slot, slotObj
		end
	end
end

local function onItemDragMove()
	local inset = GuiService:GetGuiInset()
	local mousePos = UserInputService:GetMouseLocation() - inset
	itemMoveState.moveGuiObject.Position = UDim2.new(0, mousePos.X - itemMoveState.moveGuiObjectOffset.X, 0, mousePos.Y - itemMoveState.moveGuiObjectOffset.Y)
	local center = itemMoveState.moveGuiObject.AbsolutePosition + itemMoveState.moveGuiObject.AbsoluteSize/2
	local targetId, targetType, target = getDragTargetFromPoint(center)
	if targetId then
		local valid
		local targetX, targetY
		if targetType == InventoryDict.moveTargetType.container then
			targetX, targetY = target:getDragGridPos(itemMoveState.moveGuiObject.AbsolutePosition)
			valid = itemMoveState.itemDragCallback(itemMoveState.itemId, itemMoveState.itemData, targetId, targetType, targetX, targetY, itemMoveState.r)
		elseif targetType == InventoryDict.moveTargetType.slot then
			valid = itemMoveState.itemDragCallback(itemMoveState.itemId, itemMoveState.itemData, targetId, targetType)
		end
		if valid then
			target:addTempHighlight(itemMoveState.moveHighlightObject, itemMoveState.itemData, targetX, targetY, itemMoveState.r)
			return true, targetId, targetType, targetX, targetY
		end
	end
	itemMoveState.moveHighlightObject.Parent = nil
	return false
end

local function onItemDragRotate()
	local itemInfo = Items[itemMoveState.itemData.item]
	local dX, dY = Array2D.rotateDimension(itemInfo.size.X, itemInfo.size.Y, itemMoveState.r)
	itemMoveState.moveGuiObject.Size = UDim2.new(0, dX * itemMoveState.gridSize, 0, dY * itemMoveState.gridSize)
	onItemDragMove()
end

local function onItemDragEnded()
	if not itemMoveState then
		return
	end
	-- report to higher level that something was dragged
	local validPlacement, targetId, targetType, x, y = onItemDragMove()
	if validPlacement then
		inventoryMenu.itemDragged:Fire(itemMoveState.itemId, targetId, targetType, x, y, itemMoveState.r)
	end
	-- clean
	itemMoveState.itemCleaner:clean()
	itemMoveState = nil
end

local function onItemInputBegan(inputObj, itemFrame, itemId, itemData, itemDragCallback)
	-- verify not already moving something
	if itemMoveState then
		return
	end
	if inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
		-- start movement
		--local container = containerObjects[itemData.container]
		local inset = GuiService:GetGuiInset()
		local mousePos = UserInputService:GetMouseLocation() - inset
		
		--local gridSize = container:getGridPixelSize()
		itemMoveState = {
			itemId = itemId,
			itemData = itemData,
			r = itemData.r or 0,
			itemDragCallback = itemDragCallback,
			itemGuiObject = itemFrame,
			gridSize = DRAG_GRID_SIZE_PIXEL,
			moveGuiObject = itemMoveGuiObject(itemData, DRAG_GRID_SIZE_PIXEL),
			moveHighlightObject = itemMovePlaceHighlight(),
			moveGuiObjectOffset = mousePos - itemFrame.AbsolutePosition,
			itemCleaner = Cleaner.new()
		}
		
		itemMoveState.itemCleaner
			:add(itemMoveState.moveGuiObject)
			:add(itemMoveState.moveHighlightObject)
			:add(UserInputService.InputEnded:Connect(function(inputObj, gp)
				if inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
					onItemDragEnded()
				elseif inputObj.UserInputType == Enum.UserInputType.Keyboard then
					if inputObj.KeyCode == Enum.KeyCode.R then
						itemMoveState.r = (itemMoveState.r + 1)%2
						itemMoveState.moveGuiObjectOffset = Vector2.new(itemMoveState.moveGuiObjectOffset.Y, itemMoveState.moveGuiObjectOffset.Y)
						onItemDragRotate()
					end
				end
			end))
			:add(UserInputService.InputChanged:Connect(function(inputObj, gp)
				if inputObj.UserInputType == Enum.UserInputType.MouseMovement then
					onItemDragMove()
				end
			end))
		
		onItemDragMove()
	end
end

-- sections
local loadoutSection = section(sectionParentFrame, Vector2.new(0.5, 0.5), UDim2.new(1/6, 0, 0.5, 0), UDim2.new(1/3, -GRID_SECTION_BETWEEN_PADDING, 1, 0))
local inventorySection = containerSection(sectionParentFrame, Vector2.new(0.5, 0.5), UDim2.new(3/6, 0, 0.5, 0), UDim2.new(1/3, -GRID_SECTION_BETWEEN_PADDING, 1, 0))
local externalSection = containerSection(sectionParentFrame, Vector2.new(0.5, 0.5), UDim2.new(5/6, 0, 0.5, 0), UDim2.new(1/3, -GRID_SECTION_BETWEEN_PADDING, 1, 0))

-- slots
local equipmentSlot = Slot {
	Position = UDim2.new(0.5, 0, 0.5, 0)
}
equipmentSlot:mount(loadoutSection)


-- public --
inventoryMenu.itemDragged = Signal.new() -- fires w/ item id & target container & target pos
inventoryMenu.itemClicked = Signal.new() -- fires w/ item id

function inventoryMenu:toggle(onOpenCallback, onCloseCallback)
	if isOpen then
		self:close()
		if onCloseCallback then
			onCloseCallback()
		end
	else
		self:open()
		if onOpenCallback then
			onOpenCallback()
		end
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
	local containerObj = Container(inventorySection, containerId, containerData.width, containerData.height, containerId)
	containerObjects[containerId] = containerObj
end

function inventoryMenu:onSlotRemoved(slotId)
	-- do nothing
end

function inventoryMenu:onSlotAdded(slotId)
	--slotObjects[slotId] = slotObj
	if slotId == "Equipment" then
		slotObjects[slotId] = equipmentSlot
	end
end

-- adds the item to the container in the gui
-- itemDragCallback param is a callback which allows the inventory controller
-- to control the dragging system
-- TODO: item drag callback can be implemented universally
function inventoryMenu:onItemAdded(itemId, itemData, itemDragCallback)
	local containerObj = itemData.container and containerObjects[itemData.container]
	if not containerObj then
		warn("InvMenu: Can't find container for item.")
		return
	end
	local itemObj: Frame = Item(itemId, itemData)
	containerObj:addItem(itemData, itemObj)
	itemObj.InputBegan:Connect(function(inputObj)
		onItemInputBegan(inputObj, itemObj, itemId, itemData, itemDragCallback)
	end)
	itemObjects[itemId] = itemObj
	return itemObj
end

function inventoryMenu:onItemMoved(itemId, itemData, itemDragCallback)
	local itemObj = itemObjects[itemId]
	if not itemObj then
		inventoryMenu:onItemAdded(itemId, itemData, itemDragCallback)
	end
	if itemData.container then
		local containerObj = containerObjects[itemData.container]
		if not containerObj then
			warn("InvMenu: Can't find container for item.")
			return
		end
		containerObj:addItem(itemData, itemObj)
	elseif itemData.slot then
		local slotObj = slotObjects[itemData.slot]
		if not slotObj then
			warn("InvMenu: Can't find slot for item.")
		end
		slotObj:addItem(itemData, itemObj)
	else
		warn("InvMenu: Item has no slot or container.")
	end
end

function inventoryMenu:onItemRemoved()

end

function inventoryMenu:onInventorySet()

end

function inventoryMenu:mount(parent)
	parentFrame.Parent = parent
end

return inventoryMenu