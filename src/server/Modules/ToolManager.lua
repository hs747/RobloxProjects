local Players = game:GetService("Players")
local toolManager = {}

-- dependencies --
local Networking = require(game.ReplicatedStorage.Source.Shared.Networking)
local Items = require(game.ReplicatedStorage.Source.Shared.Data.Items)
local Tools = require(game.ReplicatedStorage.Source.Shared.Data.Tools)
local InventoryManager
local CharacterManager

-- private --
local equipToolRemote = Networking.getEvent("Tools/Equip")
local unequipToolRemote = Networking.getEvent("Tools/Unequip")

local function getToolInfo(item): Tools.ToolInfo
	local itemInfo = Items[item]
	if not itemInfo then
		return
	end
	return itemInfo.isTool and Tools[item]
end

-- public --
toolManager.tools = {}

function toolManager:init()
	InventoryManager = require(game.ServerStorage.Server.Modules.InventoryManager)
	CharacterManager = require(game.ServerStorage.Server.Modules.CharacterManager)
end

function toolManager:start()
	equipToolRemote.OnServerEvent:Connect(function(player, itemId)
		if player and player.Character then
			self:onEquipped(player, player.Character)
		end
	end)
	unequipToolRemote.OnServerEvent:Connect(function() 
		-- idk
	end)
	CharacterManager.characterRemoving:Connect(function(character, _)
		self.tools[character] = nil
	end)
end

function toolManager:onEquipped(player, character, itemId)
	-- if current tool, unequip

	-- validate the equipping tool can be equipped (is in inventory, is equippable)
	local inventory = InventoryManager:getPlayerInventory(player)
	if not inventory then
		return
	end
	local item = inventory.items[itemId]
	if not item then
		return
	end
	local toolInfo = getToolInfo(item)
	if not toolInfo then
		return
	end

	-- equip the tool
	local model = toolInfo.model:Clone()

	local handle = model.PrimaryPart
	for _, part in ipairs(model:GetChildren()) do
		if not (handle == part) and part:IsA("BasePart") then
			local weld = Instance.new("Weld")
			weld.Part0 = handle
			weld.Part1 = part
			weld.C0 = handle.CFrame:ToObjectSpace(part.CFrame)
			weld.Parent = part
		end
	end
	
	local grip = Instance.new("Motor6D")
	grip.Name = "Grip"
	grip.Part0 = character:WaitForChild("UpperTorso")
	grip.Part1 = handle
	grip.Parent = handle

	local tool = {
		itemId = itemId,
		toolInfo = toolInfo,
		model = model,
	}
	self.tools[character] = tool
end

function toolManager:onUnequipped(player, character)

end

return toolManager