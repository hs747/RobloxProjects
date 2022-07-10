local InventoryMenu = require(game.ReplicatedStorage.Source.Client.Components.Inventory.InventoryMenu)
return function(parent)
	InventoryMenu:onContainerAdded("Hands", {
		width = 10,
		height = 3,
	})
	InventoryMenu:onItemAdded("SomeItem", {
		x = 0,
		y = 0,
		container = "Hands",
	})
	InventoryMenu:mount(parent)
	return function() 
		
	end
end