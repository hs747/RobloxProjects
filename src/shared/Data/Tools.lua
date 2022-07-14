export type ToolInfo = {
	toolType: string,
	model: Model, -- may not be universal
}

export type ConsumableInfo = ToolInfo & {
	fpAnimations: {
		idle: Animation,
		consume: Animation,
	},
	tpAnimations: {
		idle: Animation,
		consume: Animation,
	},
}

local AnimationProvider = require(game.ReplicatedStorage.Source.Client.AnimationProvider)

local assetsItems = game.ReplicatedStorage.Assets.Items
local assetsWeapons = game.ReplicatedStorage.Assets.Weapons

local tools: {[string]: ToolInfo} = {
	["Beans"] = {
		toolType = "Consumable",
		model = assetsItems.Beans.Model,
		animations = {
			idle = AnimationProvider:getAnimationFromAsset(assetsItems.Beans.Animations.Idle),
			consume = AnimationProvider:getAnimationFromAsset(assetsItems.Beans.Animations.Consume),
			idleCharacter = AnimationProvider:getAnimationFromAsset(assetsItems.Beans.Animations.Idle_Character)
		},
	}
}

return tools