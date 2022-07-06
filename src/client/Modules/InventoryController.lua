local inventoryController = {}
-- dependencies
local Networking = require(game.ReplicatedStorage.Source.Shared.Networking)
local Inventory = require(game.ReplicatedStorage.Source.Client.Classes.Inventory)

-- private
local remoteCharacterInventorySet = Networking.getEvent("Inventory/Character/Set")
local remoteCharacterInventoryAdded = Networking.getEvent("Inventory/Character/Added")
local remoteCharacterInventoryRemoved = Networking.getEvent("Inventory/Character/Removed")
local remoteCharacterInventoryRequestMove
local remoteCharacterInventoryRequestPickup

local characterInventory

function inventoryController:init()
	characterInventory = Inventory.new()

    -- networking
    remoteCharacterInventorySet.OnClientEvent:Connect(function(data) 
        characterInventory:_onSet(data)
        print("Got Character Inventory Set.")
        print(characterInventory)
    end)
    remoteCharacterInventoryAdded.OnClientEvent:Connect(function() 
    
    end)
    remoteCharacterInventoryRemoved.OnClientEvent:Connect(function() 
    
    end)
end

function inventoryController:start()
	
end

return inventoryController
