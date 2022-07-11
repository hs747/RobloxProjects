local InventoryMenu = require(game.ReplicatedStorage.Source.Client.Components.Inventory.InventoryMenu)
return function(parent)
	InventoryMenu:onContainerAdded("Hands", {
		width = 8,
		height = 3,
	})
	InventoryMenu:onItemAdded("SomeItem", {
		x = 1,
		y = 1,
		r = 1,
		item = "TestItemLong",
		container = "Hands",
	})
	InventoryMenu:mount(parent)
	return function() 
		
	end
end