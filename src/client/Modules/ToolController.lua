local toolController = {}

-- dependencies
local RunService = game:GetService("RunService")
local CamController

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
	toolController.firstPersonRig.PrimaryPart.CFrame = camera.CFrame  * CFrame.new(0, 0, -5) -- < debug to confirm location
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


-- public
toolController.equipped = nil
toolController.equippedModel = nil
toolController.firstPersonRig = nil

function toolController:equip()
	
end

function toolController:unequip()
	
end

function toolController:init()
	CamController = require(game.ReplicatedStorage.Source.Client.Modules.CamController)
end

function toolController:start()
	camera = CamController:getCamera()
	
	if player.Character then
		onCharacterAdded(player)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
	player.CharacterRemoving:Connect(onCharacterRemoving)
end

return toolController