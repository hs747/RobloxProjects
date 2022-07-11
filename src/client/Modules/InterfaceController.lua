local interfaceController = {}

-- dependencies
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)

-- private
local SINK_RIGHT_CLICK_BIND = "SinkRightClick"
local SINK_RIGHT_CLICK_PRIORITY = Enum.ContextActionPriority.High.Value

local function mainScreenGui()
	return WUX.New "ScreenGui" {
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		Name = "MainScreenGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}
end

-- really hacky way to retain first person but
-- disable camera movement/lock when in first person
local function mouseLockDisruptor(screenGui)
	return WUX.New "TextButton" {
		Parent = screenGui,
		ZIndex = -1000,
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		Modal = true,
	}
end
local currentLockDisruptor

-- public
function interfaceController:init()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

	interfaceController.screenGui = mainScreenGui()
	currentLockDisruptor = mouseLockDisruptor(interfaceController.screenGui)
	print(currentLockDisruptor, currentLockDisruptor:GetFullName())
end

function interfaceController:enterFirstPersonMode()
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false
	ContextActionService:UnbindAction(SINK_RIGHT_CLICK_BIND)
	currentLockDisruptor.Visible = false
end

function interfaceController:enterMenuMode()
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
	ContextActionService:BindActionAtPriority(SINK_RIGHT_CLICK_BIND, function()
		print("sinking")
		return Enum.ContextActionResult.Sink
	end, false, SINK_RIGHT_CLICK_PRIORITY, Enum.UserInputType.MouseButton2)
	currentLockDisruptor.Visible = true
end

return interfaceController