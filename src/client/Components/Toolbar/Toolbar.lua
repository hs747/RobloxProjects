local ProximityPromptService = game:GetService("ProximityPromptService")
local toolbar = {}

-- dependencies --
local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)
local Items = require(game.ReplicatedStorage.Source.Shared.Data.Items)

-- private --
local TOOL_BAR_TEXT_FONT = Enum.Font.FredokaOne
local TOOL_BAR_TEXT_SIZE = 12
local TOOL_BAR_SIZE_YY = UDim.new(0.1, 0)
local SLOT_MAX_COUNT = 6
local SLOT_SIZE_YY = UDim2.new(0.9, 0, 0.9, 0)
local SLOT_SiZE_YY_BIG = UDim2.new(0.95, 0, 0.95, 0)

local SLOT_EQUIP_TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local SLOT_UNEQUIP_TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

-- components
local function toolbarSlot(props)
	return WUX.New "Frame" {
		Parent = props.Parent,
		Name = "ToolbarSlot",
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = SLOT_SIZE_YY,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1/SLOT_MAX_COUNT * (props.Number - 0.5), 0, 0.5, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 0.3,
		BackgroundColor3 = Color3.fromRGB(48, 48, 48),

		[WUX.Children] = {
			WUX.New "TextLabel" { -- todo: switch this to an image
				Name = "ItemLabel",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Font = TOOL_BAR_TEXT_FONT,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextSize = TOOL_BAR_TEXT_SIZE,
				TextColor3 = Color3.fromRGB(214, 214, 214),
				Text = ""
			},
			WUX.New "TextLabel" {
				Name = "NumberLabel",
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 5, 1, -3),
				Size = UDim2.new(0, TOOL_BAR_TEXT_SIZE, 0, TOOL_BAR_TEXT_SIZE),
				BackgroundTransparency = 1,
				Font = TOOL_BAR_TEXT_FONT,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				TextSize = TOOL_BAR_TEXT_SIZE,
				TextColor3 = Color3.fromRGB(214, 214, 214),
				Text = string.format("%i", props.Number)
			}
		}
	}
end

local function assignToolbarSlot(slot, itemData, itemInfo)
	slot.ItemLabel.Text = itemInfo.nameShort
end

local parentFrame = WUX.New "Frame" {
	Name = "ToolbarFrame",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
}

local toolbarFrame = WUX.New "Frame" {
	Parent = parentFrame,
	Name = "Toolbar",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -10),
	SizeConstraint = Enum.SizeConstraint.RelativeYY,
	Size = UDim2.new(TOOL_BAR_SIZE_YY.Scale * SLOT_MAX_COUNT, TOOL_BAR_SIZE_YY.Offset * SLOT_MAX_COUNT, TOOL_BAR_SIZE_YY.Scale, TOOL_BAR_SIZE_YY.Offset),
	BackgroundTransparency = 1,
}

local slots = {}

for i = 1, SLOT_MAX_COUNT do
	slots[i] = toolbarSlot {
		Parent = toolbarFrame,
		Number = i,
	}
end

-- public --
function toolbar:setEquipped(slotNumber)
	local slot = slots[slotNumber]
	if slot then
		WUX.Tween(slot, SLOT_EQUIP_TWEEN_INFO, {
			Size = SLOT_SiZE_YY_BIG,
			BackgroundTransparency = 0,
		}, true)
	end
end

function toolbar:setUnequipped(slotNumber)
	local slot = slots[slotNumber]
	if slot then
		WUX.Tween(slot, SLOT_UNEQUIP_TWEEN_INFO, {
			Size = SLOT_SIZE_YY,
			BackgroundTransparency = 0.3,
		}, true)
	end
end

function toolbar:mount(parent)
	parentFrame.Parent = parent
end

return toolbar