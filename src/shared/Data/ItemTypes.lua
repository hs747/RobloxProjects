-- enum of types
export type ItemTypeInfo = {
	
}

-- todo: enum compress this
local types: {[string]: string} = {
	Weapon = "Weapon",
	Consumable = "Consumable",
	Other = "Other",
}

local typesInfo: {[string]: ItemTypeInfo} = {
	[types.Weapon] = {
		
	},
	[types.Consumable] = {
		
	},
	[types.Other] = {
		
	},
}

return {
	types = {},
	infos = {},
}