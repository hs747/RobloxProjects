local Slot = require(script.Parent.Slot)

return function(parent)
	local slot = Slot {
		Parent = parent,
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}
	slot:mount(parent)
end