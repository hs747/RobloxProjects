-- dependencies
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local CharacterController

-- public --
local gunController = {}
gunController.__index = gunController

function gunController.init()
	CharacterController = require(game.ReplicatedStorage.Source.Client.Modules.CharacterController)
end

function gunController.load(id, toolInfo, toolData)
	local self = setmetatable(toolData, gunController)
	self.firstPersonTracks = {}
	self.thirdPersonTracks = {}
	self.gunState = "unequipped"
	self.gunOffsetGoal = CFrame.identity
	self.gunOffsetTime = 0
	self.gunOffsetDuration = 0
	return self
end

function gunController:unload()

end

function gunController:equip(character, firstPersonRig)
	self.model = self.toolInfo.model:Clone()
	self.handle = self.model:WaitForChild("Handle")
	self.aimPart = self.model:WaitForChild("AimPart")
	self.aimOffset = self.aimPart.CFrame:ToObjectSpace(self.handle.CFrame)

	-- join the gun
	for _, part in ipairs(self.model:GetChildren()) do
		if not (part == self.handle)  and part:IsA("BasePart") then
			local weld = Instance.new("Weld")
			weld.Part0 = self.handle
			weld.Part1 = part
			weld.C0 = self.handle.CFrame:ToObjectSpace(part.CFrame)
			weld.Parent = part
		end
	end

	-- joint the gun to the camera part
	local grip = Instance.new("Motor6D")
	grip.Name = "Grip"
	grip.Part0 = firstPersonRig.Head
	grip.Part1 = self.handle
	grip.C0 = CFrame.identity
	grip.C1 = CFrame.identity
	grip.Parent = firstPersonRig
	self.grip = grip

	-- initial pose tweens
	self:tweenGunOffset(self.toolInfo.offsets.idle, 0)

	-- parent the model after the next animation step
	self.gunState = "equipping"
	task.spawn(function()
		print("parenting")
		RunService.Stepped:Wait()
		self.model.Parent = firstPersonRig
		self.gunState = "idle"
	end)

	-- bind/connect events
	RunService:BindToRenderStep("GunRenderStep", Enum.RenderPriority.Camera.Value - 1, function(dT)
		self:onRenderStep(dT)
	end)
	ContextActionService:BindAction("GunAim", function(_, userInputState)
		if userInputState == Enum.UserInputState.Begin then
			self:onAimingChanged(true)
		elseif userInputState == Enum.UserInputState.End then
			self:onAimingChanged(false)
		end
	end, false, Enum.UserInputType.MouseButton2)
	self.sprintConn = CharacterController.sprintingChanged:Connect(function(isSprinting) 
		self:onSprintingChanged(isSprinting)
	end)
end

function gunController:unequip()
	self.model:Destroy()
	-- disconnect
	RunService:UnbindFromRenderStep("GunRenderStep")
	ContextActionService:UnbindAction("GunAim")
	self.sprintConn:Disconnect()
end

function gunController:onRenderStep(dT)
	-- update the root offset lerp
	self.gunOffsetTime = math.clamp(self.gunOffsetTime + dT, 0, self.gunOffsetDuration)
	self.grip.C0 = self.grip.C0:Lerp(self.gunOffsetGoal, self.gunOffsetTime/self.gunOffsetDuration)
end

function gunController:tweenGunOffset(offsetCF, time)
	self.gunOffsetGoal = offsetCF
	if time == 0 then
		self.gunOffsetTime = 1
		self.gunOffsetDuration = 1
		return
	end
	self.gunOffsetTime = 0
	self.gunOffsetDuration = time
end

function gunController:onSprintingChanged(isSprinting)
	if isSprinting then
		if self.state == "aiming" then
			self:onAimingChanged(false)
		end
		self:tweenGunOffset(self.toolInfo.offsets.sprint, 0.6)
	else
		self:tweenGunOffset(self.toolInfo.offsets.idle, 0.6)
	end
end

function gunController:onAimingChanged(isAiming)
	if not (self.gunState == "aiming") and isAiming then
		CharacterController:setSprinting(false)
		CharacterController.bobScale = 0.1
		self.gunState = "aiming"
		self:tweenGunOffset(self.aimOffset, 0.2)
	elseif self.gunState == "aiming" and not isAiming then
		CharacterController.bobScale = 1
		self.gunState = "idle"
		self:tweenGunOffset(self.toolInfo.offsets.idle, 0.2)
	end
end

return gunController