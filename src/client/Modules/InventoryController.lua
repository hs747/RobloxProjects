local inventoryController = {}

-- dependencies --
local ContextActionService = game:GetService("ContextActionService")
local Networking = require(game.ReplicatedStorage.Source.Shared.Networking)
local Items = require(game.ReplicatedStorage.Source.Shared.Data.Items)
local InventoryDict = require(game.ReplicatedStorage.Source.Shared.Data.Dictionary).inventory
local Inventory = require(game.ReplicatedStorage.Source.Client.Classes.Inventory)
local InventoryMenu = require(game.ReplicatedStorage.Source.Client.Components.Inventory.InventoryMenu)
local Interface
local CharacterController

-- private --
local OPEN_INVENTORY_BIND = "OpenInventoryMenu"

local remoteCharacterInventorySet = Networking.getEvent("Inventory/Character/Set")
local remoteCharacterInventoryAdded = Networking.getEvent("Inventory/Character/Added")
local remoteCharacterInventoryRemoved = Networking.getEvent("Inventory/Character/Removed")
local remoteCharacterInventoryMoved = Networking.getEvent("Inventory/Character/Moved")


local remoteCharacterInventoryRequestMove = Networking.getEvent("Inventory/Character/Move")
local remoteCharacterInventoryRequestPickup

local characterInventory

local function itemDragCallback(movingItemId, movingItemData, targetId, targetType, targetX, targetY, targetR)
    if targetType == InventoryDict.moveTargetType.container then 
        local container = characterInventory:getContainer(targetId) --todo: system for switching between "inventories" of containers
        if not container then
            return false
        end
        local itemInfo = Items[movingItemData.item]
        local isValid
        if targetId == movingItemData.container then
            isValid = container:isValidPlace(itemInfo, targetX, targetY, targetR, movingItemId)
        else
            isValid = container:isValidPlace(itemInfo, targetX, targetY, targetR)
        end
        return isValid
    elseif targetType == InventoryDict.moveTargetType.slot then
        local slot = characterInventory:getSlot(targetId)
        if not slot then
            return false
        end
        if targetId == movingItemData.slot then
            return true
        else
            return slot:canMoveInto(movingItemData)
        end
    end
end

local function onCharacterItemAdded(itemId, itemData)
    local guiObject = InventoryMenu:onItemAdded(itemId, itemData, itemDragCallback)
    return guiObject
end

local function onCharacterItemRemoved()

end

local function onCharacterContainerAdded(containerId, containerData)
    InventoryMenu:onContainerAdded(containerId, containerData)
end

local function onCharacterContainerRemoved(containerId)
    InventoryMenu:onContainerRemoved(containerId)
end

local function onCharacterSlotAdded(slotId)
   InventoryMenu:onSlotAdded(slotId)
end

local function onCharacterSlotRemoved(slotId)
    
end


local function onSpawn()
    ContextActionService:BindAction(OPEN_INVENTORY_BIND, function(_, inputState, inputAction)
        if inputState == Enum.UserInputState.Begin then
            InventoryMenu:toggle(function() 
                Interface:enterMenuMode()
            end)
        end
    end, false, Enum.KeyCode.Tab)
end

local function onDespawn()
    ContextActionService:UnbindAction(OPEN_INVENTORY_BIND)
end

-- public --
function inventoryController:init()
    Interface = require(game.ReplicatedStorage.Source.Client.Modules.InterfaceController)
    CharacterController = require(game.ReplicatedStorage.Source.Client.Modules.CharacterController)

	characterInventory = Inventory.new()
    -- networking
    remoteCharacterInventorySet.OnClientEvent:Connect(function(data) 
        characterInventory:_onSet(data)
        for id, container in pairs(characterInventory.containers) do
            onCharacterContainerAdded(id, container)
        end
        for id, slot in pairs(characterInventory.slots) do
            onCharacterSlotAdded(id)
        end
        for id, item in pairs(characterInventory.items) do
            onCharacterItemAdded(id, item)
        end
    end)
    remoteCharacterInventoryAdded.OnClientEvent:Connect(function() 
        
    end)
    remoteCharacterInventoryRemoved.OnClientEvent:Connect(function()
        
    end)
    remoteCharacterInventoryMoved.OnClientEvent:Connect(function(itemId, targetType, targetId, targetX, targetY, targetR)
        print("got move update")
        local itemData = characterInventory:_onMoved(itemId, targetType, targetId, targetX, targetY, targetR)
        InventoryMenu:onItemMoved(itemId, itemData, itemDragCallback)
    end)
end

function inventoryController:start()
	-- handle interface controls
    InventoryMenu:close()
    InventoryMenu:mount(Interface.screenGui)
    InventoryMenu.itemDragged:Connect(function(itemId, targetId, targetType, targetX, targetY, targetR) 
        -- request server to move item
        remoteCharacterInventoryRequestMove:FireServer(itemId, targetType, targetId, targetX, targetY, targetR)
    end)
    InventoryMenu.itemClicked:Connect(function()

    end)
    -- handle spawning events
    if CharacterController.character then
        onSpawn()
    end
    CharacterController.spawned:Connect(onSpawn)
    CharacterController.despawned:Connect(onDespawn)
end

return inventoryController
