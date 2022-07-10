local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)

local ITEM_LABEL_COLOR = Color3.fromRGB(214, 214, 214)
local ITEM_LABEL_OFFSET = 5 -- pixels
local ITEM_LABEL_HEIGHT = 9 -- pixels

return function(itemId, itemData) 
    return WUX.New "Frame" {
        Name = "Item",
        BackgroundTransparency = 0.35,
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderColor3 = Color3.fromRGB(200, 200, 200),

        [WUX.Children] = {
            WUX.New "TextLabel" {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, ITEM_LABEL_OFFSET, 1, -ITEM_LABEL_OFFSET),
                Size = UDim2.new(1, 0, 0, ITEM_LABEL_HEIGHT),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(214, 214, 214),
                Text = "Item Lab"
            }
        }
    }
end