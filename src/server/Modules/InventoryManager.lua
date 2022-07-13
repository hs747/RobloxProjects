local invManager = {}

-- dependencies --
local Networking = require(game.ReplicatedStorage.Source.Shared.Networking)
local Inventory = require(game.ServerStorage.Server.Classes.Inventory)

-- private --
local remoteCharacterInventorySet = Networking.getEvent("Inventory/Character/Set")
local remoteCharacterInventoryAdded = Networking.getEvent("Inventory/Character/Added")
local remoteCharacterInventoryRemoved = Networking.getEvent("Inventory/Character/Removed")
local remoteCharacterInventoryMoved = Networking.getEvent("Inventory/Character/Moved")

local remoteCharacterInventoryRequestMove = Networking.getEvent("Inventory/Character/Move")
local remoteCharacterInventoryRequestPickup

local playerInventories = {}

local function getPlayerInventory(player: Player)
	return playerInventories[player]
end

-- when connected to in an event, 
-- it fetches the inventory of the player for the interior callback function
local function eventWrapInventoryContext(callback)
	return function(player, ...)
		local inventory = playerInventories[player]
		if not inventory then
			warn("Inventory Network: Can't get inventory for player", player.Name)
		end
		callback(player, inventory, ...)
	end
end

local function onCharacterInventoryRequestMove(player, inventory, itemId, targetType, targetId, x, y, r)
	inventory:moveItem(itemId, targetId, targetType, x, y, r)
	-- this would be better implemented via remote functions but eh
	remoteCharacterInventoryMoved:FireClient(player, itemId, targetType, targetId, x, y, r)
end

-- public
function invManager:start()
	remoteCharacterInventoryRequestMove.OnServerEvent:Connect(eventWrapInventoryContext(onCharacterInventoryRequestMove))
end

function invManager:getPlayerInventory(...)
	return getPlayerInventory(...)
end

function invManager:onPlayerAdded(player)
	-- give character inventory to player
	local inv = Inventory.new()
	inv:addContainer("Hands", {
		width = 6,
		height = 2,
	})
	inv:addSlot("Equipment")
	inv:addItem("0001", {
		id = "0001",
		item = "Beans",
		x = 1,
		y = 1,
		r = 0,
		container = "Hands",
	})
	playerInventories[player] = inv
	remoteCharacterInventorySet:FireClient(player, inv:serialize())
end

function invManager:onPlayerRemoving(player)
	-- remove inventory data for player
end

return invManager