-- handles replicating stuff
local replicator = {}

-- dependencies
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- private --
local CAM_ANGLE_ATTRIBUTE = "CameraAngle"
local CAM_ANGLE_LERP_F = 0.3

local characters = {}

local function updateCharacter(charData)
	local camAngle = charData.character:GetAttribute(CAM_ANGLE_ATTRIBUTE) or 0
	charData.rightShoulder.C0 = charData.rightShoulder.C0:Lerp(charData.rightShoulderOrig * CFrame.Angles(0, 0, camAngle), CAM_ANGLE_LERP_F)
	charData.leftShoulder.C0 = charData.leftShoulder.C0:Lerp(charData.leftShoulderOrig * CFrame.Angles(0, 0, -camAngle), CAM_ANGLE_LERP_F)
	charData.neck.C0 = charData.neck.C0:Lerp(charData.neckOrig * CFrame.Angles(-camAngle, 0, 0), CAM_ANGLE_LERP_F)
end

local function characterAdded(character)
	local torso = character:WaitForChild("Torso")
	local rightShoulder, leftShoulder, neck = torso:WaitForChild("Right Shoulder"), torso:WaitForChild("Left Shoulder"), torso:WaitForChild("Neck")

	local charData = {
		character = character,
		rightShoulder = rightShoulder,
		leftShoulder = leftShoulder,
		neck = neck,
		rightShoulderOrig = rightShoulder.C0,
		leftShoulderOrig =  leftShoulder.C0,
		neckOrig = neck.C0
	}
	table.insert(characters, charData)
end

local function characterRemoving(character)
	for index, charData in ipairs(characters) do
		if charData.character == character then
			characters[index] = characters[#characters]
			characters[#characters] = nil
		end
	end
end

-- public --
function replicator:start()
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		if player == Players.LocalPlayer then
			continue
		end
		if player.Character then
			characterAdded(player.Character)
		end
		player.CharacterAdded:Connect(characterAdded)
		player.CharacterRemoving:Connect(characterRemoving)
	end
	Players.PlayerAdded:Connect(function(player)
		if player == Players.LocalPlayer then
			return
		end
		if player.Character then
			characterAdded(player.Character)
		end
		player.CharacterAdded:Connect(characterAdded)
		player.CharacterRemoving:Connect(characterRemoving)
	end)

	RunService.Heartbeat:Connect(function(dT)
		for _, charData in ipairs(characters) do
			updateCharacter(charData)
		end
	end)
end

return replicator