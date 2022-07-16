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
	grip.C0 = self.toolInfo.offsets.idle
	grip.C1 = CFrame.identity
	grip.Parent = firstPersonRig
	self.grip = grip

	-- parent the model after the next animation step
	self.gunState = "equipping"
	task.spawn(function()
		print("parenting")
		RunService.Stepped:Wait()
		self.model.Parent = firstPersonRig
		self.gunState = "idle"
	end)

	-- handle input
	ContextActionService:BindAction("GunAim", function(_, userInputState)
		if userInputState == Enum.UserInputState.Begin then
			self:onAimingChanged(true)
		elseif userInputState == Enum.UserInputState.End then
			self:onAimingChanged(false)
		end
	end, false, Enum.UserInputType.MouseButton2)
	CharacterController.sprintingChanged:Connect(function(isSprinting) 
		self:onSprintingChanged(isSprinting)
	end)
end

function gunController:unequip()
	self.model:Destroy()
	-- disconnect
	ContextActionService:UnbindAction("GunAim")
end

function gunController:onSprintingChanged(isSprinting)
	if isSprinting then
		print("is sprinting")
		if self.state == "aiming" then
			self:onAimingChanged(false)
		end
		self.grip.C0 = self.toolInfo.offsets.sprint
	else
		self.grip.C0 = self.toolInfo.offsets.idle
	end
end

function gunController:onAimingChanged(isAiming)
	if not (self.gunState == "aiming") and isAiming then
		CharacterController:setSprinting(false)
		self.gunState = "aiming"
		self.grip.C0 = self.aimOffset
	elseif self.gunState == "aiming" and not isAiming then
		self.gunState = "idle"
		self.grip.C0 = self.toolInfo.offsets.idle
	end
end

return gunController