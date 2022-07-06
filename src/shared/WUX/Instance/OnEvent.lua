-- stolen from fusion lmao
local Source = script.Parent.Parent
local Dictionary = require(Source.Internal.Dictionary)

return function(eventName)
	-- that shit better gc
	return {
		propertySpecial = Dictionary.SpecialProperty.OnEvent,
		eventName = eventName,
	}
end