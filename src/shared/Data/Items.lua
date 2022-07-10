--!strict
export type ItemInfo = {
    name: string, -- full length name
    nameShort: string, -- name to be displayed in inventory contexts
    size: Vector2, -- dimensions item displaces in inventory grids 
}

local items: {[string]: ItemInfo} = {
    ["TestItem"] = {
        name = "Test Item",
        nameShort = "TestItem",
        size = Vector2.new(2, 3),
    },
}

return items