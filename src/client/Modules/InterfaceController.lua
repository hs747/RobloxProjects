local interfaceController = {}

-- dependencies
local Players = game:GetService("Players")
local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)

-- private
local function mainScreenGui()
	return WUX.New "ScreenGui" {
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		Name = "MainScreenGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}
end

-- public
function interfaceController:init()
	interfaceController.screenGui = mainScreenGui()
end