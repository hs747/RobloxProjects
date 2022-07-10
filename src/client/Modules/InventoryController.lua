local inventoryController = {}
-- dependencies
local ContextActionService = game:GetService("ContextActionService")
local Networking = require(game.ReplicatedStorage.Source.Shared.Networking)
local Inventory = require(game.ReplicatedStorage.Source.Client.Classes.Inventory)
local InventoryMenu = require(game.ReplicatedStorage.Source.Client.Components.Inventory.InventoryMenu)
local Interface
local CharacterController
-- private
local OPEN_INVENTORY_BIND = "OpenInventoryMenu"

local remoteCharacterInventorySet = Networking.getEvent("Inventory/Character/Set")
local remoteCharacterInventoryAdded = Networking.getEvent("Inventory/Character/Added")
local remoteCharacterInventoryRemoved = Networking.getEvent("Inventory/Character/Removed")
local remoteCharacterInventoryRequestMove
local remoteCharacterInventoryRequestPickup

local characterInventory

local function onSpawn()
    InventoryMenu:onContainerAdded("Hands", {
        id = "Hands",
        width = 6,
        height = 2,
    })
    InventoryMenu:onItemAdded("UniqueItemId", {
        id = "UniqueItemId",
        item = "TestItem",
        container = "Hands",
        x = 0,
        y = 0,
    })
    ContextActionService:BindAction(OPEN_INVENTORY_BIND, function(_, inputState, inputAction) 
        InventoryMenu:toggle()
    end, false, Enum.KeyCode.Tab)
end

local function onDespawn()
    ContextActionService:UnbindAction(OPEN_INVENTORY_BIND)
end

function inventoryController:init()
    Interface = require(game.ReplicatedStorage.Source.Client.Modules.InterfaceController)
    CharacterController = require(game.ReplicatedStorage.Source.Client.Modules.CharacterController)

	characterInventory = Inventory.new()
    -- networking
    remoteCharacterInventorySet.OnClientEvent:Connect(function(data) 
        characterInventory:_onSet(data)
    end)
    remoteCharacterInventoryAdded.OnClientEvent:Connect(function() 
    
    end)
    remoteCharacterInventoryRemoved.OnClientEvent:Connect(function() 
    
    end)
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
