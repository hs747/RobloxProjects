local invManager = {}
-- dependencies
local Networking = require(game.ReplicatedStorage.Source.Shared.Networking)
local Inventory = require(game.ServerStorage.Server.Classes.Inventory)

-- private

local remoteCharacterInventorySet = Networking.getEvent("Inventory/Character/Set")
local remoteCharacterInventoryAdded = Networking.getEvent("Inventory/Character/Added")
local remoteCharacterInventoryRemoved = Networking.getEvent("Inventory/Character/Removed")
local remoteCharacterInventoryRequestMove
local remoteCharacterInventoryRequestPickup

local playerInventories = {}

local function getPlayerInventory(player: Player)
	return playerInventories[player]
end

-- public
function invManager:init()
	
end

function invManager:start()

end

function invManager:onPlayerAdded(player)
	-- give character inventory to player
	local inv = Inventory.new()
	inv:addContainer("Hands")
	inv:addItem("0001", {
		id = "0001",
		x = 0,
		y = 0,
		container = "Hands",
	})

	remoteCharacterInventorySet:FireClient(player, inv:serialize())
end

function invManager:onPlayerRemoving(player)
	-- remove inventory data for player
end

return invManager