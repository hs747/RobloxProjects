local characterController = {}
-- dependencies
local Players = game:GetService("Players")
local Signal = require(game.ReplicatedStorage.Source.Shared.Signal)

-- private
local player = Players.LocalPlayer

local function onCharacterAdded(character)
    characterController.character = character
    characterController.spawned:Fire(character)
end

local function onCharacterRemoving()
    characterController.character = nil
    characterController.despawned:Fire()
end
-- public
characterController.despawned = Signal.new()
characterController.spawned = Signal.new()
characterController.character = nil

function characterController:start()
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(onCharacterRemoving)
end

return characterController