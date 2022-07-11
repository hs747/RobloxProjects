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

local function onCharacterInventoryRequestMove(player, inventory, itemId, targetContainerId, targetX, targetY, targetR)
	local itemData = inventory.items[itemId]
	if not itemData then
		return
	end
	if not (targetContainerId == itemData.container) then
		-- TODO: validate container ids
		-- TODO: possibly relocate this to the inventory class
		local currentContainer = inventory.containers[itemData.container]
		local targetContainer = inventory.containers[targetContainerId]
		currentContainer:removeItem(itemId, itemData)
		targetContainer:addItem(itemId, itemData)
	end
	itemData.x = targetX
	itemData.y = targetY
	itemData.r = targetR
	-- this would be better implemented via remote functions but eh
	remoteCharacterInventoryMoved:FireClient(player, itemId, targetContainerId, targetX, targetY, targetR)
end

-- public
function invManager:init()
	
end

function invManager:start()
	remoteCharacterInventoryRequestMove.OnServerEvent:Connect(eventWrapInventoryContext(onCharacterInventoryRequestMove))
end

function invManager:onPlayerAdded(player)
	-- give character inventory to player
	local inv = Inventory.new()
	inv:addContainer("Hands", {
		width = 6,
		height = 2,
	})
	inv:addContainer("Test", {
		width = 8,
		height = 3,
	})
	inv:addItem("0001", {
		id = "0001",
		item = "TestItemLong",
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