-- dependencies
local Players = game:GetService("Players")

local camController = {}
-- private
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- public
function camController:getCamera()
	return camera
end

function camController:init()
	--player.CameraMode = Enum.CameraMode.LockFirstPerson
end

function camController:start()
	
end

return camController