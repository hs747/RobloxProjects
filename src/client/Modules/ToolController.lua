local toolController = {}

-- dependencies
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local CamController
local CharacterController

-- constants
local RIG_RENDER_BIND = "UpdateFPRig"
local RIG_MODEL_TEMPL = game.ReplicatedStorage.Assets.FirstPersonRig

-- private
local player = game:GetService("Players").LocalPlayer
local camera
local character

local function firstPersonRigJoint(part0, part0Att, part1, part1Att, name)
	local joint = Instance.new("Motor6D")
	joint.Name = name
	joint.Part0 = part0
	joint.Part1 = part1
	joint.C0 = part0Att.CFrame
	joint.C1 = part1Att.CFrame
	joint.Parent = part1
	return joint
end

local function getFirstPersonRig()
	local rig = RIG_MODEL_TEMPL:Clone()
	rig.Name = player.Name .. "_FirstPersonRig"
	-- create joints
	firstPersonRigJoint(
		rig:WaitForChild("Head"), rig.Head:WaitForChild("RightShoulderAtt"), 
		rig:WaitForChild("RightArm"), rig.RightArm:WaitForChild("RightShoulderAtt"),
		"RightShoulder")
	firstPersonRigJoint(
		rig:WaitForChild("Head"), rig.Head:WaitForChild("LeftShoulderAtt"), 
		rig:WaitForChild("LeftArm"), rig.LeftArm:WaitForChild("LeftShoulderAtt"),
		"LeftShoulder")
	rig.Parent = workspace
	return rig
end

local function updateFirstPersonRig()
	toolController.firstPersonRig.PrimaryPart.CFrame = camera.CFrame  --* CFrame.new(0, 0, -5) -- < debug to confirm location
end

local function onCharacterAdded(char)
	character = char
	toolController.firstPersonRig = getFirstPersonRig(character)
	RunService:BindToRenderStep(RIG_RENDER_BIND, Enum.RenderPriority.Camera.Value + 1, updateFirstPersonRig)
end

local function onCharacterRemoving()
	toolController.firstPersonRig:Destroy()
	RunService:UnbindFromRenderStep(RIG_RENDER_BIND)
	character = nil
end


-- grr no OOP
local itemToolController = {}

function itemToolController:init(id, toolInfo)
	local toolData = {
		id = id,
		toolInfo = toolInfo,
		animations = {},
	}
	return toolData
end

function itemToolController:load(toolData)
	-- load animation tracks
end

function itemToolController:unload(toolData)
	-- unload animation tracks
end

-- public
toolController.tools = {}
toolController.equipped = nil
toolController.equippedModel = nil
toolController.firstPersonRig = nil

-- TODO: implement keybindings for equipping & unequipping tools

function toolController:equip()
	
end

function toolController:unequip()
	
end

function toolController:addTool(itemId, toolInfo)
	if not character then
		return
	end
	-- fetch tool controller
	-- tool controller loads up stuff (animations, etc)
	local toolData = {} -- controller:load()
	-- add tool data to tool list
	toolController.tools[itemId] = toolData
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