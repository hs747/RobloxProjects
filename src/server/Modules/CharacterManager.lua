local characterManager = {}

-- dependencies --
local RunService = game:GetService("RunService")

-- private --
local MAX_HUNGER = 100
local MAX_THIRST = 100
local THIRST_DECLINE_BASE = 1 -- unit/second
local HUNGER_DECLINE_BASE = 1
local HEALTH_STARVING_DECLINE = 2 
local HEALTH_DEHYDRATED_DECLINE = 2

local STAT_UPDATE_RATE = 0.5 -- interval between stat updates
local lastStatUpdate

local characters = {}
-- public --
local function addCharacterStat(statFolder, statName, initialValue)
	local stat = Instance.new("NumberValue")
	stat.Name = statName
	stat.Value = initialValue
	stat.Parent = statFolder
	return stat
end

function characterManager:getStat(character, statName)
	local statFolder = character:FindFirstChild("Stats")
	local stat = statFolder:FindFirstChild(statName)
	return stat
end

function characterManager:setStat(character, statName, value)
	local stat = self:getStat(character, statName)
	stat.Value = value
end

function characterManager:modifyStat(character, statName, modifyCallback)
	local stat = self:getStat(character, statName)
	return modifyCallback(stat)
end

function characterManager:getHealth(character)
	local humanoid = character:FindFirstChild("Humanoid")
	return humanoid.Health
end

function characterManager:setHealth(character, health)
	local humanoid = character:FindFirstChild("Humanoid")
	humanoid.health = health
end

function characterManager:modifyHealth(character, modifyCallback)
	local humanoid = character:FindFirstChild("Humanoid")
	humanoid.Health = modifyCallback(humanoid.Health)
end

function characterManager:start()
	lastStatUpdate = os.clock()
	RunService.Heartbeat:Connect(function() 
		if os.clock() < lastStatUpdate + STAT_UPDATE_RATE then
			return
		end
		local timeDelta = os.clock() - lastStatUpdate
		lastStatUpdate = os.clock()
		-- update stats
		for _, character in ipairs(characters) do
			local isDehydrated = self:modifyStat(character, "Thirst", function(thirst)
				thirst.Value = math.max(thirst.Value - THIRST_DECLINE_BASE * timeDelta, 0)
				return thirst.Value <= 0
			end)
			local isStarving = self:modifyStat(character, "Hunger", function(hunger)
				hunger.Value = math.max(hunger.Value - HUNGER_DECLINE_BASE * timeDelta, 0)
				return hunger.Value <= 0
			end)
			if isDehydrated then
				self:modifyHealth(character, function(health)
					return health - HEALTH_DEHYDRATED_DECLINE
				end)
			end
			if isStarving then
				self:modifyHealth(character, function(health)
					return health - HEALTH_STARVING_DECLINE
				end)
			end
		end
	end)
end

function characterManager:onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(function(character)
		-- create stat objects
		local stats = Instance.new("Folder")
		stats.Name = "Stats"
		addCharacterStat(stats, "Hunger", MAX_HUNGER)
		addCharacterStat(stats, "Thirst", MAX_THIRST)
		stats.Parent = character
		-- insert into characters list
		table.insert(characters, character)
	end)
	player.CharacterRemoving:Connect(function(character)
		for i, char in ipairs(characters) do
			if char == character then
				table.remove(characters, i)
				break
			end
		end
	end)
end

return characterManager