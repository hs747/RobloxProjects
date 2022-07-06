local Players = game:GetService("Players")
local Framework = require(game.ReplicatedStorage.Source.Shared.Framework.Framework)

local function main()
	Framework:addContainer(game.ServerStorage.Server.Modules)
	Framework:run()

	-- call some framework wide items
	for _, player in ipairs(Players:GetPlayers()) do
		Framework:call("onPlayerAdded", player)
	end
	Players.PlayerAdded:Connect(function(player) 
		Framework:call("onPlayerAdded", player)
	end)
	Players.PlayerRemoving:Connect(function(player) 
		Framework:call("onPlayerRemoving", player)
	end)
end

main()