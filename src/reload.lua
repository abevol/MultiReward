---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- 	so only assign to values or define things here.

function sjson_ShellText(data)
	for _,v in ipairs(data.Texts) do
		if v.Id == 'MainMenuScreen_PlayGame' then
			v.DisplayName = 'Test ' .. _PLUGIN.guid
			break
		end
	end
end

function wrap_SetupMap(base)
	print('Map is loading, here we might load some packages.')
	-- game.LoadPackages({Name = package_name_string})
	return base()
end

function trigger_Gift()
	ModUtil.mod.Hades.PrintOverhead(Config.message)
end

local function printMsg(text)
    if not Config.Debug then return end
    local green = "\x1b[32m"
    local reset = "\x1b[0m"
    print(green .. "[MultiReward] " .. text .. reset)
end

-- local function getRewardCount(config, rewardType, lootName)
--     local v = config[rewardType] or config["Others"]
--     if type(v) == "table" then
--         v = v[lootName] or v["Others"]
--     end
--     return v or 1
-- end

local function getRewardCount(config, rewardType, lootName)
    local v = config[rewardType]
    if type(v) == "table" then
        v = v[lootName]
        if type(v) ~= "number" then
            v = v["Others"]
        end
    end
    if type(v) ~= "number" then
        v = config["Others"]
    end
    if type(v) ~= "number" then
        v = 1
    end
    return v
end

function patch_SpawnRoomReward(base, eventSource, args)
	args = args or {}
    local reward = nil
    local currentRoom = Game.CurrentRun.CurrentRoom
    local currentEncounter = Game.CurrentRun.CurrentRoom.Encounter
    local rewardType = args.RewardOverride or currentEncounter.EncounterRoomRewardOverride or currentRoom.ChangeReward or currentRoom.ChosenRewardType
    local lootName = args.LootName or currentRoom.ForceLootName
    local rewardCount = getRewardCount(Config.RewardCount, rewardType, lootName)

    printMsg(string.format("RewardCount: %d, RewardType: %s, LootName: %s", rewardCount, rewardType, lootName))

    for _ = 1,  rewardCount do
        reward = base(eventSource, args)
    end
    return reward
end

function patch_GetReplacementTraits(base, traitNames, onlyFromLootName)
	return {}
end
