-- dependencies
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local camController = {}
-- private
local CAMERA_BASE_FOV = 70
local CAMERA_FOV_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- public
function camController:setFovScale(scalar)
	print("here pog")
	TweenService:Create(camera, CAMERA_FOV_TWEEN_INFO, {FieldOfView = CAMERA_BASE_FOV * scalar}):Play()
end

function camController:getCamera()
	return camera
end

function camController:init()
	--player.CameraMode = Enum.CameraMode.LockFirstPerson
	camera.FieldOfView = CAMERA_BASE_FOV
end

function camController:start()
	
end

return camController