local Framework = require(game.ReplicatedStorage.Source.Shared.Framework.Framework)

local function main()
	Framework:addContainer(game.ServerStorage.Server.Modules)
	Framework:run()
end

main()