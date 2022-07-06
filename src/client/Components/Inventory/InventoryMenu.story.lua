local InventoryMenu = require(game.ReplicatedStorage.Source.Client.Components.Inventory.InventoryMenu)
return function(parent)
	InventoryMenu:mount(parent)
	return function() 
	
	end
end