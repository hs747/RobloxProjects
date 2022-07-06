local Framework = require(game.ReplicatedStorage.Framework)
local Component = Framework.Component

local CoolFolder = Framework.Component(function(self) 
	self.instance = Framework.New "Folder" {
		[Framework.Children] = {
			Framework.New "Folder" {
				Name = "SubFolder"
			}
		}
	}
	return self
end)

function CoolFolder:setName(name: string)
	self.instance.Name = name
end

return function() 
	local coolFolder = CoolFolder()
	print(getmetatable(coolFolder))
	coolFolder:setName("Component Folder")
	coolFolder:mount(workspace)
end