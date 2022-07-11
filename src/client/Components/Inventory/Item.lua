local TextService = game:GetService("TextService")
local WUX = require(game.ReplicatedStorage.Source.Shared.WUX)
local Items = require(game.ReplicatedStorage.Source.Shared.Data.Items)
local InventoryTypes = require(game.ReplicatedStorage.Source.Shared.Data.Types.Inventory)

local ITEM_LABEL_COLOR = Color3.fromRGB(214, 214, 214)
local ITEM_LABEL_OFFSET = 5 -- pixels
local ITEM_LABEL_HEIGHT = 12 -- pixels
local ITEM_LABEL_FONT = Enum.Font.FredokaOne 

return function(itemId, itemData: InventoryTypes.Item)
    local itemInfo = Items[itemData.item]
    if not itemInfo then
        warn("Item Component: Can't get item info from item: ", itemData.item)
    end
    return WUX.New "Frame" {
        Name = "Item",
        BackgroundTransparency = 0.35,
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderColor3 = Color3.fromRGB(200, 200, 200),

        [WUX.Children] = {
            WUX.New "TextLabel" {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, ITEM_LABEL_OFFSET, 1, -ITEM_LABEL_OFFSET),
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Bottom,
                TextScaled = false,
                TextSize = ITEM_LABEL_HEIGHT - 2,
                TextColor3 = Color3.fromRGB(214, 214, 214),
                Font = ITEM_LABEL_FONT,
                Text = itemInfo.nameShort,
            }
        }
    }
end