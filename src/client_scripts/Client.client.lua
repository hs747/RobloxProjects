local Framework = require(game.ReplicatedStorage.Source.Shared.Framework.Framework)

local function main()
	Framework:addContainer(game.ReplicatedStorage.Source.Client.Modules)
	Framework:run()
end

main()