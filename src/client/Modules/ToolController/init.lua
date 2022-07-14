local toolController = {}

-- dependencies
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local AnimationProvider = require(game.ReplicatedStorage.Source.Client.AnimationProvider)
local Networking = require(game.ReplicatedStorage.Source.Shared.Networking)
local CamController
local CharacterController

-- private

-- sub controllers
local itemSubController = require(script.Item)

local typeSubControllerMap = {
	["Consumable"] = itemSubController
}

local equipToolRemote = Networking.getEvent("Tools/Equip")
local unequipToolRemote = Networking.getEvent("Tools/Unequip")

local player = game:GetService("Players").LocalPlayer
local camera
local character
local firstPersonRig

local function onCharacterAdded(char)
	character = char
	firstPersonRig = CharacterController.firstPersonRig
	-- test
	local beanTool= toolController:addTool("TestBeans", {
		toolType = "Consumable",
		model = game.ReplicatedStorage.Assets.Items.Beans.Model,
		animations = {
			idleRig = AnimationProvider:getAnimationFromAsset(game.ReplicatedStorage.Assets.Items.Beans.Animations.Idle),
			idleCharacter = AnimationProvider:getAnimationFromAsset(game.ReplicatedStorage.Assets.Items.Beans.Animations.Idle_Character),
			consumeRig = AnimationProvider:getAnimationFromAsset(game.ReplicatedStorage.Assets.Items.Beans.Animations.Consume),
		}
	})
	task.wait(0.5)
	toolController:equip(beanTool)
end

local function onCharacterRemoving()
	firstPersonRig = nil
	character = nil
end

-- public
toolController.tools = {}
toolController.equipped = nil

-- TODO: implement keybindings for equipping & unequipping tools

function toolController:equip(tool)
	if self.equipped then
		return
	end
	tool:equip(character, firstPersonRig)
	self.equipped = tool
	equipToolRemote:FireServer(tool.id)
end

function toolController:unequip(tool)
	if self.equipped == tool then
		self.equipped = nil
	end
	tool:unequip()
	unequipToolRemote:FireServer(tool.id)
end

function toolController:addTool(itemId, toolInfo)
	if not character then
		return
	end
	-- fetch tool controller
	local subController = typeSubControllerMap[toolInfo.toolType] -- fetch based on tool info later
	-- tool controller loads up stuff (animations, etc)
	local tool = subController.load(itemId, toolInfo)
	-- add tool data to tool list
	toolController.tools[itemId] = tool
	return tool
end

function toolController:removeTool(itemId)
	-- fetch tool controller
	-- tell it to cleanup
	-- controller:unload()
	local tool = self.tools[itemId]
	if tool then
		tool:unload()
		self.tools[itemId] = nil
	end
end

function toolController:init()
	CamController = require(game.ReplicatedStorage.Source.Client.Modules.CamController)
	CharacterController = require(game.ReplicatedStorage.Source.Client.Modules.CharacterController)

	itemSubController.init()

	CharacterController.spawned:Connect(onCharacterAdded)
	CharacterController.despawned:Connect(onCharacterRemoving)
end

function toolController:start()
	camera = CamController:getCamera()
end

return toolController