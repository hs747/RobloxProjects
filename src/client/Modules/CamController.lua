-- dependencies
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local camController = {}
-- private
local DEBUG_TOGGLE_THIRD

local CAMERA_BASE_FOV = 70
local CAMERA_FOV_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local debugIsThirdPerson = false

-- public
function camController:setFovScale(scalar)
	TweenService:Create(camera, CAMERA_FOV_TWEEN_INFO, {FieldOfView = CAMERA_BASE_FOV * scalar}):Play()
end

function camController:getCamera()
	return camera
end

function camController:init()
	
end

function camController:start()
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	camera.FieldOfView = CAMERA_BASE_FOV

	ContextActionService:BindAction("DebugCameraMode", function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			debugIsThirdPerson = not debugIsThirdPerson
			player.CameraMode = debugIsThirdPerson and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
		end
	end, false, Enum.KeyCode.J)
end

return camController