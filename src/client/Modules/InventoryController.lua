local inventoryController = {}
-- dependencies
local Inventory = require(game.ReplicatedStorage.Source.Client.Classes.Inventory)

-- private
local characterInvNetworkGroup = game.ReplicatedStorage.Networking.Inventory.Character
local characterInventory

function inventoryController:init()
	characterInventory = Inventory.new(characterInvNetworkGroup)
    characterInventory:networkGet()
    characterInventory:networkListen()
end

function inventoryController:start()
	
end

return inventoryController
