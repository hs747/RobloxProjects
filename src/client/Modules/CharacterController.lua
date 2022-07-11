local characterController = {}
-- dependencies
local Players = game:GetService("Players")
local Signal = require(game.ReplicatedStorage.Source.Shared.Signal)
local InterfaceController
local Overlay = require(game.ReplicatedStorage.Source.Client.Components.Overlay.Overlay)
-- private
local player = Players.LocalPlayer
local character

local function statChanged(statName, value)
    Overlay:onStatChanged(statName, value)
end

local function onCharacterAdded(char)
    character = char
    InterfaceController:enterFirstPersonMode()
    characterController.character = character
    characterController.spawned:Fire(character)

    local humanoid: Humanoid = character:WaitForChild("Humanoid")
    statChanged("Health", humanoid.Health)
    humanoid.HealthChanged:Connect(function()
        statChanged("Health", humanoid.Health)
    end)

    local stats = character:WaitForChild("Stats")
    for _, stat in ipairs(stats:GetChildren()) do
        statChanged(stat.Name, stat.Value)
        stat:GetPropertyChangedSignal("Value"):Connect(function()
            statChanged(stat.Name, stat.Value)
        end)
    end
end

local function onCharacterRemoving()
    characterController.character = nil
    characterController.despawned:Fire()
end

-- public
characterController.despawned = Signal.new()
characterController.spawned = Signal.new()
characterController.character = nil

function characterController:init()
    InterfaceController = require(game.ReplicatedStorage.Source.Client.Modules.InterfaceController)
end

function characterController:start()
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(onCharacterRemoving)

    Overlay:mount(InterfaceController.screenGui)
end

return characterController