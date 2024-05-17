local mod = MultiReward

if not mod.Config.Enabled then return end

local function printMsg(text)
    if not mod.Config.Debug then return end
    local green = "\x1b[32m"
    local reset = "\x1b[0m"
    print(green .. "[MultiReward] " .. text .. reset)
end

local function getRewardCount(config, rewardType, lootName)
    local v = config[rewardType] or config["Others"]
    if type(v) == "table" then
        v = v[lootName] or v["Others"]
    end
    return v or 1
end

ModUtil.Path.Wrap("SpawnRoomReward", function(base, eventSource, args)
    args = args or {}
    local reward = nil
    local currentRoom = CurrentRun.CurrentRoom
    local currentEncounter = CurrentRun.CurrentRoom.Encounter
    local rewardType = args.RewardOverride or currentEncounter.EncounterRoomRewardOverride or currentRoom.ChangeReward or currentRoom.ChosenRewardType
    local lootName = args.LootName or currentRoom.ForceLootName
    local rewardCount = getRewardCount(mod.Config.RewardCount, rewardType, lootName)

    printMsg(string.format("RewardCount: %d, RewardType: %s, LootName: %s", rewardCount, rewardType, lootName))

    for _ = 1,  rewardCount do
        reward = base(eventSource, args)
    end
    return reward
end, mod)
