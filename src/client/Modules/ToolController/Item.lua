-- dependencies
local ContextActionService = game:GetService("ContextActionService")
local CharacterController
local ToolController

-- public
local itemController = {}
itemController.__index = itemController

-- gets depdencies
function itemController.init()
	-- get other module dependencies here
	CharacterController = require(game.ReplicatedStorage.Source.Client.Modules.CharacterController)
	ToolController = require(game.ReplicatedStorage.Source.Client.Modules.ToolController)
end

-- constructs the item controller
function itemController.load(id, toolInfo)
	local self = setmetatable({
		id = id,
		toolInfo = toolInfo,
		model = nil,
		state = "idle",
		rigTracks = {
			idle = CharacterController:loadFirstPersonAnim(toolInfo.animations.idleRig),
		consume = CharacterController:loadFirstPersonAnim(toolInfo.animations.consumeRig),
		},
		characterTracks = {
			idle = CharacterController:loadCharacterAnim(toolInfo.animations.idleCharacter),
		},
	}, itemController)
	return self
end

function itemController:unload()
	-- cleanup the tracks
	for _, track in pairs(self.rigTracks) do
		track:Destroy()
	end
	for _, track in pairs(self.characterTracks) do
		track:Destroy()
	end
end

function itemController:equip(character, firstPersonRig)
	local model = self.toolInfo.model:Clone()
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
	self.model = model

	-- handle input
	self.state = "idle"
	if self.toolInfo.toolType == "Consumable" then
		ContextActionService:BindAction("ConsumeItem", function(_, inputState, inputObj)
			if inputState == Enum.UserInputState.Begin then
				self:consume(self)
			end 
		end, false, Enum.UserInputType.MouseButton1)
	end

	self.rigTracks.idle:Play()
	self.characterTracks.idle:Play()
end

function itemController:unequip()
	for _, track in pairs(self.rigTracks) do
		track:Stop()	
	end
	for _, track in pairs(self.characterTracks) do
		track:Stop()
	end
end

function itemController:consume()
	if self.state == "idle" then
		self.state = "consuming"
		self.rigTracks.consume:Play()
		task.wait(self.rigTracks.consume.Length)
		ToolController:unequip(self, true)
		self.state = "consumed"
	end
end

return itemController