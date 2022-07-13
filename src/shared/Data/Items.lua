--!strict
export type ItemInfo = {
    name: string, -- full length name
    nameShort: string, -- name to be displayed in inventory contexts
    size: Vector2, -- dimensions item displaces in inventory grids
    isTool: boolean?,
}

local items: {[string]: ItemInfo} = {
    ["TestItem"] = {
        name = "Test Item",
        nameShort = "TestItem",
        size = Vector2.new(2, 2),
    },
    ["TestItemLong"] = {
        name = "Test Item Long",
        nameShort = "TstItmLng",
        size = Vector2.new(2, 1),
    },
    ["Beans"] = {
        name = "Beans",
        nameShort = "Beans",
        size = Vector2.new(1, 2),
    },
}

return items