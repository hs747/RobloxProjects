local toolController = {}

-- dependencies
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local AnimationProvider = require(game.ReplicatedStorage.Source.Client.AnimationProvider)
local Networking = require(game.ReplicatedStorage.Source.Shared.Networking)
local CamController
local CharacterController

-- constants

-- private
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
	local beanToolData = toolController:addTool("TestBeans", {
		toolType = "Consumable",
		model = game.ReplicatedStorage.Assets.Items.Beans.Model,
		animations = {
			idleRig = AnimationProvider:getAnimationFromAsset(game.ReplicatedStorage.Assets.Items.Beans.Animations.Idle),
			idleCharacter = AnimationProvider:getAnimationFromAsset(game.ReplicatedStorage.Assets.Items.Beans.Animations.Idle_Character),
			consumeRig = AnimationProvider:getAnimationFromAsset(game.ReplicatedStorage.Assets.Items.Beans.Animations.Consume),
		}
	})
	task.wait(0.5)
	toolController:equip(beanToolData)
end

local function onCharacterRemoving()
	firstPersonRig = nil
	character = nil
end

-- grr no OOP
local itemToolController = {}

function itemToolController:init(id, toolInfo)
	local toolData = {
		id = id,
		toolInfo = toolInfo,
		tracksRig = {},
		tracksCharacter = {},
		model = nil,
	}
	return toolData
end

function itemToolController:load(toolData)
	-- load animation tracks
	toolData.tracksRig = {
		idle = CharacterController:loadFirstPersonAnim(toolData.toolInfo.animations.idleRig),
		consume = CharacterController:loadFirstPersonAnim(toolData.toolInfo.animations.consumeRig),
	}
	toolData.tracksCharacter = {
		idle = CharacterController:loadCharacterAnim(toolData.toolInfo.animations.idleCharacter),
	}
end

function itemToolController:unload(toolData)
	-- unload animation tracks
end

function itemToolController:equip(toolData)
	local model = toolData.toolInfo.model:Clone()
	local modelHandle = model.PrimaryPart

	-- joint the tool
	for _, part in ipairs(model:GetChildren()) do
		if not (part == modelHandle)  and part:IsA("BasePart") then
			local weld = Instance.new("Weld")
			weld.Part0 = modelHandle
			weld.Part1 = part
			weld.C0 = modelHandle.CFrame:ToObjectSpace(part.CFrame)
			weld.Parent = part
		end
	end

	-- joint the tool to the arm
	local grip = Instance.new("Motor6D")
	grip.Name = "Grip"
	grip.Part0 = firstPersonRig.RightArm
	grip.Part1 = modelHandle
	grip.C0 = CFrame.identity
	grip.C1 = CFrame.identity
	grip.Parent = firstPersonRig.RightArm

	model.Parent = firstPersonRig
	toolData.model = model

	-- handle input
	toolData.state = "idle"
	if toolData.toolInfo.toolType == "Consumable" then
		ContextActionService:BindAction("ConsumeItem", function(_, inputState, inputObj)
			if inputState == Enum.UserInputState.Begin then
				itemToolController:consume(toolData)
			end 
		end, false, Enum.UserInputType.MouseButton1)
	end

	toolData.tracksRig.idle:Play()
	toolData.tracksCharacter.idle:Play()
end

function itemToolController:unequip(toolData, force)
	if force then
		toolController.equipped = nil
	end
	-- stop tracks
	for _, track in pairs(toolData.tracksRig) do
		track:Stop()
	end
	for _, track in pairs(toolData.tracksCharacter) do
		track:Stop()
	end
	-- clear events n shit
	ContextActionService:UnbindAction("ConsumeItem")
end

function itemToolController:consume(toolData)
	if toolData.state == "idle" then
		toolData.state = "consuming"
		toolData.tracksRig.consume:Play()
		task.wait(toolData.tracksRig.consume.Length)
		itemToolController:unequip(toolData, true)
		toolData.state = "consumed"
	end
end

-- public
toolController.tools = {}
toolController.equipped = nil

-- TODO: implement keybindings for equipping & unequipping tools

function toolController:equip(toolData)
	if self.equipped then
		return
	end
	local controller = itemToolController -- fetch later
	controller:equip(toolData)
	self.equipped = toolData
	equipToolRemote:FireServer(toolData.id)
end

function toolController:unequip(toolData)
	local controller = itemToolController -- fetch later
	controller:unequip(toolData)
	self.equipped = nil
	unequipToolRemote:FireServer(toolData.id)
end

function toolController:addTool(itemId, toolInfo)
	if not character then
		return
	end
	-- fetch tool controller
	local controller = itemToolController -- fetch based on tool info later
	-- tool controller loads up stuff (animations, etc)
	local toolData = controller:init(itemId, toolInfo)
	controller:load(toolData)
	-- add tool data to tool list
	toolController.tools[itemId] = toolData
	return toolData
end

function toolController:removeTool(itemId)
	-- fetch tool controller
	-- tell it to cleanup
	-- controller:unload()
	toolController.tools[itemId] = nil
end

function toolController:init()
	CamController = require(game.ReplicatedStorage.Source.Client.Modules.CamController)
	CharacterController = require(game.ReplicatedStorage.Source.Client.Modules.CharacterController)
	CharacterController.spawned:Connect(onCharacterAdded)
	CharacterController.despawned:Connect(onCharacterRemoving)
end

function toolController:start()
	camera = CamController:getCamera()
end

return toolController