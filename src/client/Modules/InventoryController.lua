local inventoryController = {}

-- dependencies --
local ContextActionService = game:GetService("ContextActionService")
local Networking = require(game.ReplicatedStorage.Source.Shared.Networking)
local Items = require(game.ReplicatedStorage.Source.Shared.Data.Items)
local Inventory = require(game.ReplicatedStorage.Source.Client.Classes.Inventory)
local InventoryMenu = require(game.ReplicatedStorage.Source.Client.Components.Inventory.InventoryMenu)
local Interface
local CharacterController

-- private --
local OPEN_INVENTORY_BIND = "OpenInventoryMenu"

local remoteCharacterInventorySet = Networking.getEvent("Inventory/Character/Set")
local remoteCharacterInventoryAdded = Networking.getEvent("Inventory/Character/Added")
local remoteCharacterInventoryRemoved = Networking.getEvent("Inventory/Character/Removed")
local remoteCharacterInventoryRequestMove
local remoteCharacterInventoryRequestPickup

local characterInventory

local function itemDragCallback(movingItemId, movingItemData, targetContainerId, targetX, targetY, targetR) 
    local container = characterInventory:getContainer(targetContainerId) --todo: system for switching between "inventories" of containers
    if not container then
        return false
    end
    local itemInfo = Items[movingItemData.item]
    local isValid
    if targetContainerId == movingItemData.container then
        isValid = container:isValidPlace(itemInfo, targetX, targetY, targetR, movingItemId)
    else
        isValid = container:isValidPlace(itemInfo, targetX, targetY, targetR)
    end
    return isValid
end

local function onCharacterItemAdded(itemId, itemData)
    local guiObject = InventoryMenu:onItemAdded(itemId, itemData, itemDragCallback)
    return guiObject
end

local function onCharacterContainerAdded(containerId, containerData)
    characterInventory:_onContainerAdded(containerId, containerData)
    InventoryMenu:onContainerAdded(containerId, containerData)
end

local function onCharacterItemRemoved()

end

local function onSpawn()
    onCharacterContainerAdded("Hands", {
        id = "Hands",
        width = 6,
        height = 2,
    })
    onCharacterContainerAdded("Backpack", {
        id = "Backpack",
        width = 8,
        height = 3,
    })
    onCharacterItemAdded("UniqueItemId", {
        id = "UniqueItemId",
        item = "TestItemLong",
        container = "Hands",
        x = 1,
        y = 1,
        r = 1,
    })
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
    --[[remoteCharacterInventorySet.OnClientEvent:Connect(function(data) 
        characterInventory:_onSet(data)
    end)
    remoteCharacterInventoryAdded.OnClientEvent:Connect(function() 
    
    end)
    remoteCharacterInventoryRemoved.OnClientEvent:Connect(function() 
    
    end)]]
end

function inventoryController:start()
	-- handle interface controls
    InventoryMenu:close()
    InventoryMenu:mount(Interface.screenGui)
    if CharacterController.character then
        onSpawn()
    end
    CharacterController.spawned:Connect(onSpawn)
    CharacterController.despawned:Connect(onDespawn)
end

return inventoryController
