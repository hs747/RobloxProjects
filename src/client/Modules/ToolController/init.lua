local toolController = {}

-- dependencies
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local AnimationProvider = require(game.ReplicatedStorage.Source.Client.AnimationProvider)
local Networking = require(game.ReplicatedStorage.Source.Shared.Networking)
local Tools = require(game.ReplicatedStorage.Source.Shared.Data.Tools)
local Toolbar = require(game.ReplicatedStorage.Source.Client.Components.Toolbar.Toolbar)
local Interface
local CamController
local CharacterController

-- private

-- sub controllers
local itemSubController = require(script.Item)

local typeSubControllerMap = {
	["Consumable"] = itemSubController
}

local slotPositionMap = {
	[Enum.KeyCode.One]   = 1,
	[Enum.KeyCode.Two]   = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four]  = 4,
}

local equipToolRemote = Networking.getEvent("Tools/Equip")
local unequipToolRemote = Networking.getEvent("Tools/Unequip")

local player = game:GetService("Players").LocalPlayer
local camera
local character
local firstPersonRig

local function onCharacterAdded(char)
	character = char
	firstPersonRig = CharacterController.firstPersonRig
	
	-- input
	ContextActionService:BindAction("ToolbarKeyboardInput", function(_, inputState, inputObj)
		if inputState == Enum.UserInputState.Begin then
			local position = slotPositionMap[inputObj.KeyCode]
			local tool = position and toolController.slots[position]
			if tool and tool == toolController.equipped then
				toolController:unequip(tool)
			elseif tool then
				toolController:equip(tool)
			end
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.UserInputType.Keyboard)

	-- test
	local beanTool= toolController:addTool("TestBeans", Tools.Beans, 1)
end

local function onCharacterRemoving()
	firstPersonRig = nil
	character = nil
	ContextActionService:UnbindAction("ToolbarKeyboardInput")
end

-- public
toolController.tools = {}
toolController.slots = {}
toolController.equipped = nil

function toolController:equip(tool)
	if self.equipped then
		return
	end
	tool:equip(character, firstPersonRig)
	self.equipped = tool
	Toolbar:setEquipped(tool.slotPosition)
	equipToolRemote:FireServer(tool.id)
end

function toolController:unequip(tool)
	if self.equipped == tool then
		self.equipped = nil
	end
	tool:unequip()
	Toolbar:setUnequipped(tool.slotPosition)
	unequipToolRemote:FireServer(tool.id)
end

function toolController:addTool(itemId, toolInfo, slotPosition)
	if not character then
		return
	end
	-- fetch tool controller
	local subController = typeSubControllerMap[toolInfo.toolType] -- fetch based on tool info later
	-- tool controller loads up stuff (animations, etc)
	local tool = subController.load(itemId, toolInfo, {
		id = itemId,
		toolInfo = toolInfo,
		slotPosition = slotPosition,
	})
	-- add tool data to tool list
	toolController.slots[slotPosition] = tool
	toolController.tools[itemId] = tool
	return tool
end

function toolController:removeTool(itemId)
	-- fetch tool controller
	-- tell it to cleanup
	-- controller:unload()
	local tool = self.tools[itemId]
	if tool then
		tool:unload()
		self.tools[itemId] = nil
		if tool.slotPosition then
			self.slots[tool.slotPosition] = nil
		end
	end
end

function toolController:init()
	Interface = require(game.ReplicatedStorage.Source.Client.Modules.InterfaceController)
	CamController = require(game.ReplicatedStorage.Source.Client.Modules.CamController)
	CharacterController = require(game.ReplicatedStorage.Source.Client.Modules.CharacterController)
	itemSubController.init()
	CharacterController.spawned:Connect(onCharacterAdded)
	CharacterController.despawned:Connect(onCharacterRemoving)
end

function toolController:start()
	camera = CamController:getCamera()
	Toolbar:mount(Interface.screenGui)
end

return toolController