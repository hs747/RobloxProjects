local Framework = require(game.ReplicatedStorage.Framework)

return function()
	Framework.New "Folder" {
		Parent = workspace,
		Name = "Empty Folder",
	}
	Framework.New "Folder" {
		Parent = workspace,
		Name = "Not Empty Folder",	
		[Framework.Children] = {
			Framework.New "Part" {
				Name = "CoolPart"
			}
		}
	}
end