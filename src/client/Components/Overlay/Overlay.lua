local overlay = {}

-- dependencies --
local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)

-- private --
local STAT_WIDTH_PIXEL = 175
local STAT_BAR_HEIGHT_PIXEL = 15
local STAT_BAR_PADDING_PIXEL = 5
local STAT_BAR_TWEENINFO = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local overlayFrame = WUX.New "Frame" {
	Name = "OverlayFrame",
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = -10,
}

local statsFrame = WUX.New "Frame" {
	Parent = overlayFrame,
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 15, 1, -15),
	Size = UDim2.new(0, STAT_WIDTH_PIXEL, 0, 100),
	BackgroundTransparency = 1,
}

local function statFrame(props)
	return WUX.New "Frame" {
		Parent = statsFrame,
		Name = props.StatName .. "_StatFrame",
		Size = UDim2.new(1, 0, 0, STAT_BAR_HEIGHT_PIXEL),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -(STAT_BAR_HEIGHT_PIXEL + STAT_BAR_PADDING_PIXEL) * props.Order),
		BorderSizePixel = 0,
		BackgroundColor3 = props.BackBarColor,
		[WUX.Children] = {
			WUX.New "Frame" {
				Name = "ValueBar",
				Size = UDim2.new(1, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = props.TopBarColor,
			},
			WUX.New "TextLabel" {
				Name = "ValueLabel",
				Size = UDim2.new(1, 0, 1, 0),
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(1, STAT_BAR_PADDING_PIXEL, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.FredokaOne,
				TextColor3 = props.TopBarColor,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				Text = "100%",
			},
		}
	}
end

local statFrames = {
	Health = statFrame {
		StatName = "Health",
		BackBarColor = Color3.fromRGB(200, 0, 0),
		TopBarColor = Color3.fromRGB(255, 30, 30),
		Order = 0,
	},
	Thirst = statFrame {
		StatName = "Thirst",
		BackBarColor = Color3.fromRGB(0, 53, 167),
		TopBarColor = Color3.fromRGB(0, 117, 212),
		Order = 1,
	},
	Hunger = statFrame {
		StatName = "Hunger",
		BackBarColor = Color3.fromRGB(175, 126, 34),
		TopBarColor = Color3.fromRGB(255, 238, 0),
		Order = 2,
	},
}
-- public
function overlay:onStatChanged(statName, value)
	local frame = statFrames[statName]
	if not frame then
		return
	end
	-- for now, stats assumed to be values on scale of 0-100
	WUX.Tween(frame.ValueBar, STAT_BAR_TWEENINFO, {Size = UDim2.new(math.clamp(value/100, 0, 1), 0, 1, 0)}) --frame.ValueBar.Size = UDim2.new(math.clamp(value/100, 0, 1), 0, 1, 0)
	frame.ValueLabel.Text = string.format("%i%%", value)
end

function overlay:mount(parent)
	overlayFrame.Parent = parent
end

return overlay