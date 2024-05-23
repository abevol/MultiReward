---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- 	so only assign to values or define things here.

-- local function getRewardCount(config, rewardType, lootName)
--     local v = config[rewardType] or config["Others"]
--     if type(v) == "table" then
--         v = v[lootName] or v["Others"]
--     end
--     return v or 1
-- end

local function getRewardCount(config, rewardType, lootName)
    if not rewardType then
        return 1
    end
    local v = config[rewardType]
    if type(v) == "table" then
        v = v[lootName]
        if v and type(v) ~= "number" then
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

    local debugMsg = string.format("RewardCount: %d, RewardType: %s", rewardCount, rewardType)
    if lootName then
        debugMsg = debugMsg .. ", LootName: " .. lootName
    end
    printMsg("%s", debugMsg)
    -- ModUtil.mod.Hades.PrintOverhead(debugMsg, 6)

    for _ = 1,  rewardCount do
        reward = base(eventSource, args)
    end
    return reward
end

function patch_ReachedMaxGods(base, excludedGods)
    if Config.RemoveMaxGodsLimits then
        return false
    end
    return base(excludedGods)
end

function patch_HandleUpgradeChoiceSelection(base, screen, button, args)
	args = args or {}
	local upgradeData = button.Data

    if Config.AvoidReplacingTraits and upgradeData.TraitToReplace then
        upgradeData.TraitToReplace = nil
    end

    base(screen, button, args)
end
