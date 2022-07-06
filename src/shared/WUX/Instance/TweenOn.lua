--!strict

local Source = script.Parent.Parent
local Dictionary = require(Source.Internal.Dictionary)
local Types = require(Source.Internal.Types)
local Tween = require(Source.Util.Tween)

return function(tweenInfo: {}, tweenGoal: {}): Types.SpecialEventCallback
	return {
		onEventSpecial = Dictionary.SpecialProperty.OnEvent,
		tweenInfo = tweenInfo,
		tweenGoal = tweenGoal,
	}
end