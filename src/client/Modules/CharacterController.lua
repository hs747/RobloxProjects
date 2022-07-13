local characterController = {}

-- dependencies --
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local VisualDebug = require(game.ReplicatedStorage.Source.Shared.VisualDebug)
local Signal = require(game.ReplicatedStorage.Source.Shared.Signal)
local Cleaner = require(game.ReplicatedStorage.Source.Shared.Cleaner)
local VectorUtil = require(game.ReplicatedStorage.Source.Shared.Util.VectorUtil)
local AnimationProvider = require(game.ReplicatedStorage.Source.Client.AnimationProvider)
local Overlay = require(game.ReplicatedStorage.Source.Client.Components.Overlay.Overlay)
local InterfaceController
local CamController

-- data dependencies --
local Tags = require(game.ReplicatedStorage.Source.Shared.Data.Tags)

-- private --
local VAULT_CAST_DISTANCE = 4.5
local VAULT_EDGE_BIAS = 5
local VAULT_PUSH_BIAS = 4

local characterAnimations = game.ReplicatedStorage.Assets.Animations.Character
local VAULT_ANIMATION = AnimationProvider:getAnimationFromAsset(characterAnimations.Vault)

local characterSounds = game.ReplicatedStorage.Assets.Sounds.Character
local VAULT_SOUND = characterSounds.Vault

local player = Players.LocalPlayer

local characterCleaner: Cleaner.Cleaner
local character: Model
local humanoid: Humanoid
local root: BasePart
local humanoidState: Enum.HumanoidStateType

local tracks: {[string]: AnimationTrack}

local vaultingTarget: BasePart
local vaultingPoints: {Vector3}
local vaultingClockStart: number = 0
local isVaulting = false

local isSprinting = false

local function playCharacterSound(sound: Sound)
    local s = sound:Clone()
    s.Parent = root
    s:Play()
    Debris:AddItem(s, s.TimeLength + 0.5)
end 

-- actions
local function vault()
    isVaulting = true
    vaultingTarget.CanCollide = false
    vaultingTarget.LocalTransparencyModifier = 0.5
    tracks.vault:Play()
    playCharacterSound(VAULT_SOUND)
    --[[for _, p in ipairs(vaultingPoints) do
        VisualDebug.drawSphere(p, 0.5, VisualDebug.color.purple, 3)
    end]]

    local vaultingBP = Instance.new("BodyPosition")
    vaultingBP.MaxForce = Vector3.new(1e10, 1e10, 1e10)
    vaultingBP.P = 10e3
    vaultingBP.D = 1e3
    vaultingBP.Parent = root

    local vaultingBG = Instance.new("BodyGyro")
    vaultingBG.MaxTorque = Vector3.new(1e4, 1e4, 1e4)
    vaultingBG.CFrame = root.CFrame
    vaultingBG.Parent = root

    task.spawn(function()
        for i = 1, #vaultingPoints do
            vaultingBP.Position = vaultingPoints[i]
            task.wait(0.2)
        end
       
        vaultingBP:Destroy()
        vaultingBG:Destroy()
        vaultingTarget.LocalTransparencyModifier = 0
        vaultingTarget.CanCollide = true
        isVaulting = false
    end)
end

local function sprint(start: boolean)
    if start then
        humanoid.WalkSpeed = 20
        CamController:setFovScale(1.3)
    else
        humanoid.WalkSpeed = 16
        CamController:setFovScale(1)
    end
end

-- event callbacks
local function statChanged(statName, value)
    Overlay:onStatChanged(statName, value)
end

local function onCharacterHeartbeat() 
    -- vaulting
   if not isVaulting then
        vaultingTarget = nil
        if humanoidState == Enum.HumanoidStateType.Running then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {character}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.IgnoreWater = true

            local moveDirection = humanoid.MoveDirection
            local result = workspace:Raycast(root.Position, moveDirection.Unit * VAULT_CAST_DISTANCE)
            --VisualDebug.drawRay(root.Position, moveDirection.Unit * VAULT_CAST_DISTANCE, VisualDebug.color.blue)

            if result and result.Instance and result.Instance:IsA("BasePart") and CollectionService:HasTag(result.Instance, Tags.Vaultable) then
                --VisualDebug.drawSphere(result.Position, 0.5, VisualDebug.color.green)
                vaultingTarget = result.Instance

                local invertedNormalId = VectorUtil.getNormalIdFromGlobalNormal(result.Instance.CFrame, -result.Normal * VectorUtil.transformVector.flattenToXZ)
                local edgeTop = (vaultingTarget.Position + vaultingTarget.Size/2) * Vector3.new(0, 1, 0) + result.Position * VectorUtil.transformVector.flattenToXZ
                local dimensionDirection = result.Instance.CFrame:VectorToWorldSpace(Vector3.fromNormalId(invertedNormalId) * result.Instance.Size)

                vaultingPoints = {
                    edgeTop + Vector3.new(0, VAULT_EDGE_BIAS, 0),
                    edgeTop + dimensionDirection + dimensionDirection.Unit * VAULT_PUSH_BIAS,
                }
            end
        end
    end
end

local function onCharacterStateChanged(_, new)
    humanoidState = new
end

local function onCharacterAdded(char)
    character = char
    --InterfaceController:enterFirstPersonMode()
    characterController.character = character
    characterController.spawned:Fire(character)

    characterCleaner = Cleaner.new()
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")

    humanoidState = humanoid:GetState()
    vaultingTarget = nil

    -- load animations
    local animator: Animator = humanoid:WaitForChild("Animator")
    tracks = {
        vault = animator:LoadAnimation(VAULT_ANIMATION),
    }

    -- update stats
    statChanged("Health", humanoid.Health)
    characterCleaner:add(humanoid.HealthChanged:Connect(function()
        statChanged("Health", humanoid.Health)
    end))
    local stats = character:WaitForChild("Stats")
    for _, stat in ipairs(stats:GetChildren()) do
        statChanged(stat.Name, stat.Value)
        characterCleaner:add(stat:GetPropertyChangedSignal("Value"):Connect(function()
            statChanged(stat.Name, stat.Value)
        end))
    end

    -- connect events
    characterCleaner:add(humanoid.StateChanged:Connect(onCharacterStateChanged))
    characterCleaner:add(RunService.Heartbeat:Connect(onCharacterHeartbeat))

    -- connect inputs
    ContextActionService:BindActionAtPriority("CharacterJump", function(_, inputState, inputObj)
        if inputState == Enum.UserInputState.Begin and humanoidState == Enum.HumanoidStateType.Running or humanoidState == Enum.HumanoidStateType.RunningNoPhysics then
            if isVaulting then
                return
            end
            if vaultingTarget then
                print("starting vault")
                vault()
                return
            end
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.ContextActionPriority.High.Value + 100, Enum.KeyCode.Space)
    ContextActionService:BindAction("CharacterSprint", function(_, inputState, inputObj) 
        if inputState == Enum.UserInputState.Begin then
            sprint(true)
        else
            sprint(false)
        end
    end, false, Enum.KeyCode.LeftShift)
end

local function onCharacterRemoving()
    characterController.character = nil
    characterController.despawned:Fire()
    characterCleaner:clean()
end

-- public --
characterController.despawned = Signal.new()
characterController.spawned = Signal.new()
characterController.character = nil

function characterController:init()
    InterfaceController = require(game.ReplicatedStorage.Source.Client.Modules.InterfaceController)
    CamController = require(game.ReplicatedStorage.Source.Client.Modules.CamController)
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