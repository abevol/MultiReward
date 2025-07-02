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
        local sv = v[lootName]
        if type(sv) == "number" then
            v = sv
		else
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

local function getSignalName(signalName, objectId)
	local prefixedSignalName = SignalPrefix.."_"..signalName
	if objectId then
		prefixedSignalName = prefixedSignalName.."_"..objectId
	end
	return prefixedSignalName
end

local function getTagName(tagName, objectId)
	return getSignalName(tagName, objectId)
end

local function waitForRewardUse(reward)
	if reward == nil then return end
	waitUntil(getSignalName("OnUseStarted", reward.ObjectId), getTagName("RewardSpawner"))
end

local function waitForRewardUseCompleted(reward)
	if reward == nil then return end
	waitUntil(getSignalName("OnUseCompleted", reward.ObjectId), getTagName("RewardSpawner"))
end

local function waitForStoreRemoval(reward)
    if reward == nil then return end
	waitUntil(getSignalName("OnRemovedFromStore", reward.ObjectId), getTagName("RewardSpawner"))
end

---Repeats an item spawning callback a given number of times based on some conditions
---@param initialId number
---@param fromShop boolean
---@param spawnInit function
---@param amount number
---@param blocking? boolean
local function chainSpawn(initialId, fromShop, spawnInit, amount, blocking)
    blocking = blocking == nil or blocking
    printMsg("Spawn chain started "..(blocking and "(blocking)" or "(not blocking)")..", initial: "..initialId..(fromShop and ", from Shop" or ""))
	if blocking then
        ActiveRewardSpawners = ActiveRewardSpawners + 1
    end

    if fromShop then
        waitForStoreRemoval({ ObjectId = initialId })
    else
        waitForRewardUse({ ObjectId = initialId })
    end

    ---@type function
    local spawner = spawnInit()

    for i = 1, amount do
        InSpawnerContext = true
        local reward = spawner()
        InSpawnerContext = false
        if reward == nil then
            break
        end
        if i == amount then
            waitForRewardUseCompleted({ ObjectId = reward.ObjectId })
        else
            waitForRewardUse({ ObjectId = reward.ObjectId })
        end
    end

	if blocking then
        ActiveRewardSpawners = ActiveRewardSpawners - 1
    end
    notifyExistingWaiters(getSignalName("AllRewardsAcquired"))
    if CheckRoomExitsReady(Game.CurrentRun.CurrentRoom) then
		UnlockRoomExits(Game.CurrentRun, Game.CurrentRun.CurrentRoom)
	end
    printMsg("Spawn chain completed "..(blocking and "(blocking)" or "(not blocking)")..", "..ActiveRewardSpawners.." left")
end

---Spawns an item with the given name
---@param type string
---@param name string
---@param args? table
---@return table|unknown|nil
local function itemRepeater(type, name, args)
    printMsg("Chain spawning type: "..type..", name: "..name)
    args = args or {}
    args.ResourceCosts = nil
    local reward = nil
    local spawnTarget = args.ChainSpawnTarget
    
    printMsg("Chosen spawn point: "..spawnTarget)
    if spawnTarget <= 0 then
        return nil
    end

    if type == "Consumable" then
        if name == "SpellDrop" then name = "TalentDrop" end
        local consumablePoint = SpawnObstacle({ Name = name, DestinationId = spawnTarget, Group = "Standing", OffsetX = args.ChainSpawnOffset.X, OffsetY = args.ChainSpawnOffset.Y })
        reward = CreateConsumableItem( consumablePoint, name, 0, { IgnoreSounds = true, RunProgressUpgradeEligible = true } )
        reward.CanDuplicate = false
        if reward.ExtractValues ~= nil then
            ExtractValues( CurrentRun.Hero, reward, reward )
        end
    elseif string.find(name, "WeaponUpgrade") then
        reward = CreateWeaponLoot(MergeTables(args, { SpawnPoint = spawnTarget, SuppressSpawnSounds = true, OffsetX = args.ChainSpawnOffset.X, OffsetY = args.ChainSpawnOffset.Y }))
    elseif string.find(name, "HermesUpgrade") then
        reward = CreateHermesLoot(MergeTables(args, { SpawnPoint = spawnTarget, SuppressSpawnSounds = true, OffsetX = args.ChainSpawnOffset.X, OffsetY = args.ChainSpawnOffset.Y }))
    else
        reward = GiveLoot(MergeTables(args, { ForceLootName = name, SpawnPoint = spawnTarget, SuppressSpawnSounds = true, SuppressFlares = true, OffsetX = args.ChainSpawnOffset.X, OffsetY = args.ChainSpawnOffset.Y }))
    end
    SetObstacleProperty({ Property = "MagnetismWhileBlocked", Value = 0, DestinationId = reward.ObjectId })
    return reward
end

function spawnerInit(type, name, args)
    local allPoints = GetIdsByType ({ Names = {"SecretPoint", "EnemyPoint", "LootPoint" }})
    local spawnTarget = GetClosest({ Id = Game.CurrentRun.Hero.ObjectId, DestinationIds = allPoints, Distance = 2000 })
    local conventionalRewardTarget = SelectRoomRewardSpawnPoint(Game.CurrentRun.CurrentRoom)
    args.ChainSpawnTarget = GetClosest({ Id = Game.CurrentRun.Hero.ObjectId, DestinationIds = { spawnTarget, conventionalRewardTarget } })
    -- To account for Hermes' Travel Deal
    if args.SeparateFromSlot and not args.ChainSpawnOffset then
        angle = GetAngleBetween({ Id = Game.CurrentRun.Hero.ObjectId, DestinationId = spawnTarget })
        args.ChainSpawnOffset = CalcOffset( math.rad(angle) + math.pi, 220 )
        printMsg("Offsetting from spawn point: X="..args.ChainSpawnOffset.X..", Y="..args.ChainSpawnOffset.Y)
    else
        args.ChainSpawnOffset = { X = 0, Y = 0 }
    end
    return function ()
        return itemRepeater(type, name, args)
    end
end

function patch_RemoveStoreItem(base, args)
    printMsg("RemoveStoreItem hook triggered")
    InShopContext = true
    if args.Id then
        local customSignalName = getSignalName("OnRemovedFromStore", args.Id)
        notifyExistingWaiters(customSignalName)
        printMsg("Triggered %s", customSignalName)
    end
    base(args)
    InShopContext = false
end

-- Currently Hades and Artemis in the Fields use this function for story rewards
function patch_UseLoot(base, usee, args, user)
    if usee.ObjectId then
        local customSignalName = getSignalName("OnUseStarted", usee.ObjectId)
        notifyExistingWaiters(customSignalName)
        printMsg("Triggered %s", customSignalName)
    end

	if not usee or not usee.SpeakerName or (usee.SpeakerName ~= "Hades" and usee.SpeakerName ~= "Artemis") then
		base(usee, args, user)

        if usee.ObjectId then
            local customSignalName = getSignalName("OnUseCompleted", usee.ObjectId)
            notifyExistingWaiters(customSignalName)
        end
		return
	end

	local rewardCount = getRewardCount(Config.RewardCount.Story, usee.SpeakerName)

	base(usee, args, user)
	if ActiveRewardSpawners == 0 then
		thread(RefreshNPC, rewardCount - 1, usee)
	else 
		notifyExistingWaiters(getSignalName("NPCUsed"))
	end
end

function patch_OpenSpellScreen(base, spellItem, args, user)
    if spellItem.ObjectId then
        local customSignalName = getSignalName("OnUseStarted", spellItem.ObjectId)
        notifyExistingWaiters(customSignalName)
        printMsg("Triggered %s", customSignalName)
    end
    base(spellItem, args, user)
    if spellItem.ObjectId then
        local customSignalName = getSignalName("OnUseCompleted", spellItem.ObjectId)
        notifyExistingWaiters(customSignalName)
    end
end

function patch_UnwrapRandomLoot(base, source)
    InSpawnerContext = true
    base(source)
    InSpawnerContext = false
end

function patch_UseConsumableItem(base, consumableItem, args, user)
    if consumableItem.ObjectId then
        local customSignalName = getSignalName("OnUseStarted", consumableItem.ObjectId)
        notifyExistingWaiters(customSignalName)
        printMsg("Triggered %s", customSignalName)
    end
    base(consumableItem, args, user)
    if consumableItem.ObjectId then
        local customSignalName = getSignalName("OnUseCompleted", consumableItem.ObjectId)
        notifyExistingWaiters(customSignalName)
    end
end

function roomHasChaosTrialReward()
	local currentRoom = Game.CurrentRun.CurrentRoom
	local bountyName = Game.CurrentRun.ActiveBounty
	local bountyData = Game.BountyData[bountyName]
	if bountyData ~= nil then
        for _, name in ipairs(bountyData.Encounters) do
            if name == currentRoom.Encounter.Name and bountyData.EndRunOnCompletion then
                printMsg("This is the final room of a Chaos trial!")
                return true
            end
        end
	end
	return false
end

function patch_CreateLoot(base, args)
	if Config.UpgradesOptional then
        printMsg("[Loot] Blocking Exit disabled")
		args.DoesNotBlockExit = true
	end
	if ActiveRewardSpawners > 0 then
		args.SuppressSpawnSounds = true
	end

	local reward = base(args)
	
	-- Make reward accessible for the bow indicators in the fields of mourning
	if Config.UpgradesOptional then
		if Game.CurrentRun.CurrentRoom.Using and Game.CurrentRun.CurrentRoom.Using.Spawn and Game.CurrentRun.CurrentRoom.Using.Spawn == "FieldsRewardCage" then
			MapState.OptionalRewards[reward.ObjectId] = reward
		end
	end

    if not InSpawnerContext then
        local amount = getRewardCount(InShopContext and Config.ShopItemCount or Config.RewardCount, (string.find(reward.Name, "StackUpgrade") or string.find(reward.Name, "WeaponUpgrade")) and reward.Name or "Boon", reward.Name)

        local debugMsg = string.format("RewardCount: %d, RewardType: %s%s", amount, "Loot", reward.Name and ", LootName: " .. reward.Name or "")
        printMsg("%s", debugMsg)
        if Config.Debug then ModUtil.mod.Hades.PrintOverhead(debugMsg, 5) end

        args.SeparateFromSlot = InShopContext
        thread(chainSpawn, reward.ObjectId, InShopContext, function()
            return spawnerInit("Loot", reward.Name, args)
        end, amount - 1, ShouldBeBlocking)
    end

	return reward
end

function patch_CreateConsumableItemFromData(base, consumableId, consumableItem, costOverride, args)
    local reward = base(consumableId, consumableItem, costOverride, args)

    if not InSpawnerContext then
        args = args or {}
        local amount = getRewardCount(InShopContext and Config.ShopItemCount or Config.RewardCount, InShopContext and "Consumable" or reward.Name, reward.Name)

        local debugMsg = string.format("RewardCount: %d, RewardType: %s%s", amount, "Consumable", reward.Name and ", LootName: " .. reward.Name or "")
        printMsg("%s", debugMsg)
        if Config.Debug then ModUtil.mod.Hades.PrintOverhead(debugMsg, 5) end

        if not ShouldBeBlocking or string.find(reward.Name, "HealDrop") then
            printMsg(reward.Name.." will not block exits")
        end
        args.SeparateFromSlot = InShopContext
        thread(chainSpawn, reward.ObjectId, InShopContext, function()
            return spawnerInit("Consumable", reward.Name, args)
        end, amount - 1, ShouldBeBlocking and not string.find(reward.Name, "HealDrop"))
    end

    return reward
end

function patch_SpawnRoomReward(base, eventSource, args)
	args = args or {}
    local reward = nil
    local currentRoom = Game.CurrentRun.CurrentRoom

	-- First room of run uses this
	local waitForLast = args.WaitUntilPickup
	args.WaitUntilPickup = false
	-- Rooms blocking gift boons indicate that it is not possible to collect the dropped items (for example Asphodel anomaly)
	if Config.UpgradesOptional and not currentRoom.BlockGiftBoons and not roomHasChaosTrialReward() then
		args.NotRequiredPickup = true
    else
        ShouldBeBlocking = true
	end

	reward = base(eventSource, args)
    ShouldBeBlocking = false

	if reward ~= nil and waitForLast then
		waitUntil(getSignalName("AllRewardsAcquired"))
	end
    return reward
end

function patch_SpawnStoreItemsInWorld(base, room, args)
	InShopContext = true
    base(room, args)
    InShopContext = false
end

function patch_StartDevotionTest(base, currentEncounter, args)
    base(currentEncounter, args)
    -- Devotions just despawn the boon that doesn't get taken, so we need to discard the chain spawner as well
    ActiveRewardSpawners = ActiveRewardSpawners - 1
end

function patch_UseNPC(base, npc, args, user)
	local NPCsWithRewards = { Arachne = true, Narcissus = true, Echo = true, Medea = true, Icarus = true, Circe = true, Eris = true } --Nemesis, Artemis and Hades are special cases (see patch_UseLoot)
	if not NPCsWithRewards[npc.SpeakerName] then
		base(npc, args, user)
		return
	end

	local rewardCount = getRewardCount(Config.RewardCount.Story, npc.SpeakerName)

	base(npc, args, user)
	if ActiveRewardSpawners == 0 then
		thread(RefreshNPC, rewardCount - 1, npc)
	else 
		notifyExistingWaiters(getSignalName("NPCUsed"))
	end
end

function RefreshNPC(amount, npc)
	ActiveRewardSpawners = ActiveRewardSpawners + 1
	for _ = 1, amount do
		-- For normal NPCs the NextInteractLines have to be set in order for them to be easily refreshable
		npc.NextInteractLines = GetRandomEligibleTextLines( npc, npc.InteractTextLineSets, GetNarrativeDataValue( npc, npc.InteractTextLinePriorities or "InteractTextLinePriorities" ), args )
		if npc.NextInteractLines ~= nil then
			if npc.NextInteractLines.Partner ~= nil then
				CheckPartnerConversations( npc )
			end
			SetNextInteractLines( npc, npc.NextInteractLines )
        else
            ActiveRewardSpawners = ActiveRewardSpawners - 1
            notifyExistingWaiters(getSignalName("AllNPCRewardsAcquired"))
            if CheckRoomExitsReady(Game.CurrentRun.CurrentRoom) then
                UnlockRoomExits(Game.CurrentRun, Game.CurrentRun.CurrentRoom)
            end
            return
		end
		SetAvailableUseText(npc)
		-- Refill upgrade options
		npc.UpgradeOptions = nil
		printMsg("NPC refreshed")
		waitUntil(getSignalName("NPCUsed"), getTagName("RewardSpawner"))
	end
	ActiveRewardSpawners = ActiveRewardSpawners - 1
	notifyExistingWaiters(getSignalName("AllNPCRewardsAcquired"))
    if CheckRoomExitsReady(Game.CurrentRun.CurrentRoom) then
        UnlockRoomExits(Game.CurrentRun, Game.CurrentRun.CurrentRoom)
    end
end

function patch_ErisTakeOff(base, eris)
	if ActiveRewardSpawners > 0 or getRewardCount(Config.RewardCount.Story, "Eris") > 1 then
		waitUntil(getSignalName("AllNPCRewardsAcquired"), getTagName("NPCHandler"))
	end
	base(eris)
end

function patch_ArtemisExitPresentation(base, source, args)
	if ActiveRewardSpawners == 0 and getRewardCount(Config.RewardCount.Story, "Artemis") < 2 then
		base(source, args)
		return
	end
	thread(ArtemisThreadedExit, base, source, args)
end

function ArtemisThreadedExit(base, source, args)
	waitUntil(getSignalName("AllNPCRewardsAcquired"), getTagName("NPCHandler"))
	base(source, args)
end

function patch_IcarusExitPresentation(base, source, args)
	if ActiveRewardSpawners > 0 or getRewardCount(Config.RewardCount.Story, "Icarus") > 1 then
		waitUntil(getSignalName("AllNPCRewardsAcquired"), getTagName("NPCHandler"))
	end
	base(source, args)
end

function patch_NemesisTakeRoomExit(base, eventSource, args)

	local nemesis = SessionMapState.Nemesis
	if nemesis.Exiting then
		return
	end

	if (not Config.CagesOptional) and ActiveCages > 0 then
		NemesisTeleportExitPresentation( nemesis, args )
		return
	end
	base(eventSource, args)
end

function patch_SetTraitTextData(base, traitData, args)
	if HeroHasTrait(traitData.Name) and (traitData.OldLevel == nil or traitData.NewLevel == nil) then
		traitData.OldLevel = GetTraitCount(Game.CurrentRun.Hero, { TraitData = traitData })
		traitData.NewLevel = traitData.OldLevel + 1
		printMsg("Patched level indicators for story reward")
	end
	base(traitData, args)
end

function patch_SpawnRewardCages(base, room, args)
	if room.CageRewards ~= nil then
		ActiveCages = #room.CageRewards
	end
	base(room, args)
	if CheckRoomExitsReady( room ) then
		room.ExitsUnlocked = true -- At this point exits ar not initialized, that's why we can just use DoUnlockRoomExits
		DoUnlockRoomExits( Game.CurrentRun, room )
	end
end

function patch_StartFieldsEncounter(base, rewardCage, args)
	base(rewardCage, args)
	ActiveCages = ActiveCages - 1
	if CheckRoomExitsReady(Game.CurrentRun.CurrentRoom) then
		UnlockRoomExits(Game.CurrentRun, Game.CurrentRun.CurrentRoom)
	end
end

function patch_LeaveRoom(base, currentRun, door)
	killTaggedThreads(getTagName("RewardSpawner"))
	killTaggedThreads(getTagName("NPCHandler"))
	ActiveCages = 0
	ActiveRewardSpawners = 0
	base(currentRun, door)
end

function patch_CheckRoomExitsReady(base, currentRoom)
    local isShopOrEmpty = false
    for _, value in ipairs(Game.CurrentRun.CurrentRoom.LegalEncounters) do
        if value == "Shop" or value == "Empty" or value == "TyphonShop" then
            isShopOrEmpty = true
        end
    end
	if not Config.CagesOptional and ActiveCages > 0 then
		return false
	end
	if not Config.UpgradesOptional and ActiveRewardSpawners > 0 and not isShopOrEmpty then
		return false
	end
	return base(currentRoom)
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

-- 移除悬停固定
function RemoveHoverPins(screen)
    local buttons = {}
    for k, pin in pairs(screen.Pins) do
        buttons[pin.Button] = true
    end
    for button, _ in pairs(buttons) do
        if button.PinFromHover then
            Game.thread(Game.PinTraitDetails, screen, button, { Hover = true, RemoveOnly = true })
            break
        end
    end

    -- for k, pin in pairs(screen.Pins) do
    --     if pin.Button.PinFromHover then
    --         Game.PinTraitDetails(screen, pin.Button, { Hover = true, RemoveOnly = true })
    --         break
    --     end
    -- end
end

-- 切换固定状态
function TogglePinState(screen, button, args)
    if args.Hover and not button.PinFromHover then
        -- Pin was locked in, don't remove from hover off
        return
    end

    local fadeOutTime = 0.2

    if not args.Hover then
        if button.PinFromHover then
            -- Pin it
            button.PinFromHover = false
            local pinIndexs = button.PinIndexs or {button.PinIndex}
            for _, pinIndex in ipairs(pinIndexs) do
                do
                    local pin = screen.Pins[pinIndex]
                    if not pin then break end
                    local components = pin.Components
                    if components.PinIndicator == nil then
                        components.PinIndicator = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu_TraitTray_Overlay", Scale = 0.5 })
                        components.PinIndicatorDetails = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu_TraitTray_Overlay", })
                    end
                    Game.Attach({ Id = components.PinIndicator.Id, DestinationId = button.Id })
                    Game.SetAnimation({ DestinationId = components.PinIndicator.Id, Name = "TraitPinIn" })
                    Game.SetAnimation({ DestinationId = components.PinIndicatorDetails.Id, Name = button.HighlightAnim or "TraitTray_Highlight" })
                    Game.SetScale({ Id = components.PinIndicatorDetails.Id, Fraction = button.HighlightAnimScale })
                    Game.Attach({ Id = components.PinIndicatorDetails.Id, DestinationId = components.Icon.Id })
                end
            end
            Game.TraitTrayPinOnPresentation( screen, button )
            return
        else
            -- Unpin it
            button.PinFromHover = true
            local pinIndexs = button.PinIndexs or {button.PinIndex}
            for i = #pinIndexs, 1, -1 do
                do
                    local pinIndex = pinIndexs[i]
                    local pin = screen.Pins[pinIndex]
                    if not pin then break end
                    local components = pin.Components
                    Game.SetAnimation({ DestinationId = components.PinIndicator.Id, Name = "TraitPinOut" })
                    Game.SetAnimation({ DestinationId = components.PinIndicatorDetails.Id, Name = "Blank" })
                end
            end
            Game.TraitTrayPinOffPresentation( screen, button )
            if not args.RemoveCompletely then
                return
            end
        end
    end

    local pinIndexs = button.PinIndexs or {button.PinIndex}
    -- printMsg("[TogglePinState] pinIndexs:\n%s\n", dumpTable(pinIndexs))
    local componentIdsToDestroy = {}
    for i = #pinIndexs, 1, -1 do
        do
            local pinIndex = pinIndexs[i]
            -- printMsg("[TogglePinState] Toggle off, pinIndex: %s", tostring(pinIndex))
            -- Toggle off
            local pin = screen.Pins[pinIndex]
            if not pin then break end
            local componentIds = Game.GetAllIds( pin.Components )
            componentIdsToDestroy = Game.MergeTables(componentIdsToDestroy, componentIds)
            Game.SetAlpha({ Ids = componentIds, Fraction = 0, Duration = fadeOutTime })
            Game.ModifyTextBox({ Ids = componentIds, FadeTarget = 0, FadeDuration = fadeOutTime })

            -- Slide others up
            for index, pin in ipairs( screen.Pins ) do
                if pinIndex ~= nil and index > pinIndex and pin.Button ~= nil and pin.Button.PinIndex ~= nil and pin.Button ~= button then
                    -- printMsg("index: %d, pinIndex: %d, old: %d, new: %d", index, pinIndex, pin.Button.PinIndex, pin.Button.PinIndex - 1)
                    pin.Button.PinIndex = pin.Button.PinIndex - 1
                    if pin.Button.PinIndexs then
                        for j, v in ipairs(pin.Button.PinIndexs) do
                            pin.Button.PinIndexs[j] = v - 1
                        end
                    end
                end
            end
            Game.RemoveIndexAndCollapse( screen.Pins, pinIndex )

            if not args.RemoveCompletely then
                Game.TraitTrayUpdatePinLocations( screen, args )
            end
        end
    end

    Game.waitUnmodified( fadeOutTime )
    Game.Destroy({ Ids = componentIdsToDestroy })
    button.PinIndex = nil
    button.PinIndexs = nil
end

-- 创建新的固定
function CreatePin(screen, button, traitData, args)
    local pinIndex = #screen.Pins + 1
    -- printMsg("[CreatePin] name: %s, pinIndex: %s", traitData.Name, tostring(pinIndex))
	button.PinIndex = pinIndex
    if not button.PinIndexs then
        button.PinIndexs = {}
    end
    table.insert(button.PinIndexs, pinIndex)
	button.PinFromHover = args.Hover
	local components = {}
	screen.Pins[pinIndex] = {}
	screen.Pins[pinIndex].Components = components
	screen.Pins[pinIndex].Button = button

	local offset =
	{
		X = screen.PinOffsetX,
		Y = screen.PinOffsetY + (Game.ScreenCenterNativeOffsetY * 2),
	}
	local pinSpacing = Game.TraitTrayCalcPinSpacing( screen )
	offset.Y = offset.Y + ((pinIndex - 1) * pinSpacing)
	screen.Pins[pinIndex].PinOffsetY = offset.Y
	local groupName = "TraitTrayHover"..pinIndex

	local titleBoxYOffset = -20
	local textOffset = -70 - 350

	local backingAnim = traitData.InfoBackingAnimation or Game.ScreenData.UpgradeChoice.RarityBackingAnimations[traitData.Rarity]
	--DebugPrint({ Text = "backignAnim = "..tostring(backignAnim) })
	components.DetailsBacking = Game.CreateScreenComponent({ Name = "BoonSlotBase", Group = groupName, X = offset.X, Y = offset.Y + 200, Animation = backingAnim })
	Game.SetInteractProperty({ DestinationId = components.DetailsBacking.Id, Property = "FreeFormSelectable", Value = false })
	local detailsData = Game.DeepCopyTable( Game.ScreenData.UpgradeChoice.DescriptionText )
	detailsData.Id = components.DetailsBacking.Id
	detailsData.BlockTooltip = true
	Game.CreateTextBoxWithFormat( detailsData )

	components.BlessingBacking = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = groupName, X = offset.X, Y = offset.Y + 200 })
	local blessingData = Game.DeepCopyTable( Game.ScreenData.UpgradeChoice.DescriptionText )
	blessingData.Id = components.BlessingBacking.Id
	blessingData.OffsetY =  screen.BlessingOffsetY
	blessingData.AppendToId = components.DetailsBacking.Id
	Game.CreateTextBoxWithFormat( blessingData )

	components.StatlineBackings = {}
	for lineNum = 1, 2 do

		screen.LineHeight = Game.ScreenData.UpgradeChoice.LineHeight

		local columnOffset = math.abs( (Game.ScreenData.UpgradeChoice.StatLineRight.OffsetX or 0) - (Game.ScreenData.UpgradeChoice.StatLineLeft.OffsetX or 0) )
		local offsetY = (lineNum - 1) * screen.LineHeight
		local statLineKey = "StatlineBackings"..lineNum
		components[statLineKey.."Left"] = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = groupName, X = offset.X + textOffset, Y = offset.Y + 200 })

		local statLineLeft = Game.ShallowCopyTable( Game.ScreenData.UpgradeChoice.StatLineLeft )
		statLineLeft.Id = components[statLineKey.."Left"].Id
		statLineLeft.OffsetX = 0
		statLineLeft.OffsetY = offsetY
		Game.CreateTextBoxWithFormat( statLineLeft )

		components[statLineKey.."Right"] = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = groupName, X = offset.X + textOffset, Y = offset.Y + 200 })
		local statLineRight = Game.ShallowCopyTable( Game.ScreenData.UpgradeChoice.StatLineRight )
		statLineRight.Id = components[statLineKey.."Right"].Id
		statLineRight.OffsetX = (statLineRight.OffsetX or 0) + columnOffset
		statLineRight.OffsetY = offsetY
		Game.CreateTextBoxWithFormat( statLineRight )
		table.insert( components.StatlineBackings, { components[statLineKey.."Left"].Id, components[statLineKey.."Right"].Id } )
	end
	components.TitleBox = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = groupName, X = offset.X + textOffset, Y = offset.Y + 170 })
	Game.CreateTextBox(Game.MergeTables({
		Id = components.TitleBox.Id,
		FontSize = 25,
		OffsetY = -17 + titleBoxYOffset,
		Color = Game.color,
		Font = "P22UndergroundSCMedium",
		ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
		Justification = "Left",
	}, Game.LocalizationData.TraitTrayScripts.TitleBox))

	components.RarityBox = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = groupName, X = offset.X, Y = offset.Y + 200 })
	local rarityTextBox = Game.ShallowCopyTable( Game.ScreenData.UpgradeChoice.RarityText )
	rarityTextBox.Id = components.RarityBox.Id
	Game.CreateTextBox( rarityTextBox )
	
	components.FlavorText = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = groupName, X = offset.X, Y = offset.Y})
	
	Game.CreateTextBox(
		Game.MergeTables(
		{
			Id = components.FlavorText.Id,
		},
		Game.ScreenData.UpgradeChoice.FlavorText ))
        Game.Attach({ Id = components.FlavorText.Id, DestinationId = components.DetailsBacking.Id })

	local iconOffsetX = Game.ScreenData.UpgradeChoice.IconoffsetX
	local iconOffsetY = Game.ScreenData.UpgradeChoice.IconoffsetX
	local iconOffset = { X = -447, Y = 135 }
	local overlayLayer = "Combat_Menu_Overlay_Backing"

	if traitData.MetaUpgrade then
		components.Frame = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = groupName, X = offset.X + iconOffset.X, Y = offset.Y + iconOffset.Y, Scale = button.PinIconFrameScale, Animation = "DevCard_EquippedHighlight" })
	end

	if button.Icon ~= nil or traitData.Icon ~= nil then
		components.Icon = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = groupName, X = offset.X + iconOffset.X, Y = offset.Y + iconOffset.Y, Scale = button.PinIconScale })
		Game.SetAnimation({ DestinationId = components.Icon.Id, Name = button.Icon or traitData.Icon })
	end

	if not traitData.MetaUpgrade then
		components.Frame = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = groupName, X = offset.X + iconOffset.X, Y = offset.Y + iconOffset.Y, Scale = button.PinIconFrameScale })
		local frameAnim = Game.GetTraitFrame( traitData )
		if frameAnim ~= nil then
			Game.SetAnimation({ DestinationId = components.Frame.Id, Name = frameAnim })
		end
	end

	local screenData = Game.ScreenData.UpgradeChoice

	if not Game.IsEmpty( traitData.Elements ) and Game.IsGameStateEligible( Game.CurrentRun, Game.TraitRarityData.ElementalGameStateRequirements ) then
		local elementName = Game.GetFirstValue( traitData.Elements )
		components.ElementalIcon = Game.CreateScreenComponent({ Name = Game.TraitElementData[elementName].Icon, Group = groupName, Scale = 0.5 })
		Game.Attach({ Id = components.ElementalIcon.Id, DestinationId = components.DetailsBacking.Id, OffsetX = screenData.ElementIcon.XShift - 320, OffsetY = screenData.ElementIcon.YShift + 14 })
	end

	if not args.Hover then
		-- Immediately Pin it
		if components.PinIndicator == nil then
			components.PinIndicator = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = groupName, Scale = 0.5 })
			components.PinIndicatorDetails = Game.CreateScreenComponent({ Name = "BlankObstacle", Group = groupName, Scale = 0.8 })
		end
		Game.Attach({ Id = components.PinIndicator.Id, DestinationId = button.Id })
		if traitData.Slot == "Assist" or traitData.Slot == "Keepsake" then
			Game.SetAnimation({ DestinationId = components.PinIndicator.Id, Name = "TraitPinIn_NoHighlight" })
		else
			Game.SetAnimation({ DestinationId = components.PinIndicator.Id, Name = "TraitPinIn" })
		end
		Game.Attach({ Id = components.PinIndicatorDetails.Id, DestinationId = components.Icon.Id })
		Game.SetAnimation({ DestinationId = components.PinIndicatorDetails.Id, Name = "Blank" })
		Game.TraitTrayPinOnPresentation( screen, button )
	end

	Game.SetTraitTextData( traitData, { OldOnly = true } )

	local showingTrait = nil
	local rarityValue = 0
	for s, existingTrait in pairs( Game.CurrentRun.Hero.Traits) do
		if (Game.AreTraitsIdentical(existingTrait, traitData) and rarityValue < Game.GetRarityValue( existingTrait.Rarity )) then
			showingTrait = existingTrait
			rarityValue = Game.GetRarityValue( showingTrait.Rarity )
		end
	end
	if showingTrait then
		button.OverrideRarity = showingTrait.Rarity
	end
	Game.SetTraitTrayDetails(
	{
		Button = button,
        TraitData = traitData,
		DetailsBox = components.DetailsBacking,
		BlessingsBox = components.BlessingBacking,
		DetailTextArgs = Game.textArgs,
		RarityBox = components.RarityBox,
		TitleBox = components.TitleBox,
		--Patch = components.Patch, 
		Icon = components.Icon,
		StatLines = components.StatlineBackings,
		ElementalIcon = components.ElementalIcon,
		FlavorText = components.FlavorText,
	})

	if button.ShrineDisabled then
		components.LockOverlay = Game.CreateScreenComponent({ Name = "BaseInteractableButton", Group = "Combat_Menu_TraitTray_Overlay", Animation = "ShrineSlotLocked" })
		Game.Attach({ Id = components.LockOverlay.Id, DestinationId = components.DetailsBacking.Id })
	end

	Game.TraitTrayUpdatePinLocations( screen, args )
end

function patch_TraitTrayCalcPinSpacing(base, screen)
    if not Config.AvoidReplacingTraits then
        return base(screen)
    end
    if not screen.Pins then
        screen.Pins = {}
    end
    local numPins = #screen.Pins
	if numPins <= screen.DefaultPins then
		return screen.DefaultPinSpacing
	end
	local pinSpacing = screen.TotalPinSpace / numPins
	return pinSpacing
end

function patch_TraitTrayUpdatePinLocations(base, screen, args)
    if not Config.AvoidReplacingTraits then
        return base(screen, args)
    end
    args = args or {}
    if not screen.Pins then
        screen.Pins = {}
    end
	local pinSpacing = Game.TraitTrayCalcPinSpacing( screen )
	--DebugPrint({ Text = "pinSpacing = "..pinSpacing })
	for index, pin in ipairs( screen.Pins ) do
		local toSlideIds = Game.GetAllIds( pin.Components )
		if pin.Components.PinIndicator ~= nil then
			Game.RemoveValueAndCollapse( toSlideIds, pin.Components.PinIndicator.Id )
		end
		if pin.Components.LockOverlay ~= nil then
			Game.RemoveValueAndCollapse( toSlideIds, pin.Components.LockOverlay.Id )
		end
		local groupName = "TraitTrayHover"..index
		local newOffsetY = screen.PinOffsetY + (Game.ScreenCenterNativeOffsetY * 2) + ((index - 1) * pinSpacing)
		--DebugPrint({ Text = "index = "..index..", newOffsetY = "..newOffsetY })
		local prevOffsetY = pin.PinOffsetY
		local offsetYDelta = newOffsetY - prevOffsetY
		if offsetYDelta ~= 0 then
			--DebugPrint({ Text = "index = "..index.." - offsetYDelta = "..offsetYDelta })
			local angle = 270
			if offsetYDelta < 0 then
				angle = 90
			end
			Game.Move({ Ids = toSlideIds, Angle = angle, Distance = math.abs(offsetYDelta), Speed = args.PinCollapseSpeed or screen.PinCollapseSpeed, SmoothStep = true, Additive = true })
			pin.PinOffsetY = newOffsetY
			Game.AddToGroup({ Ids = toSlideIds, Name = groupName, DrawGroup = true })
		end
	end
end

function patch_PinTraitDetails( base, screen, button, args )
    if not Config.AvoidReplacingTraits then
        return base(screen, button, args)
    end

	args = args or {}

    if not screen.Pins then
        screen.Pins = {}
    end

	if args.RemoveHovers then
        -- Remove the previous hover
		RemoveHoverPins(screen)
	end

	if button == nil then
		return
	end

	if button.PinIndex ~= nil then
        -- 切换固定状态
        TogglePinState(screen, button, args)
		return
	end

	if args.RemoveOnly then
		return
	end

	if #screen.Pins >= screen.MaxPins then
		return
	end

    -- 添加新的固定

    local traitData = button.TraitData
    if not traitData then return end
    local traitDatas = {traitData}
    if traitData.Slot then
        traitDatas = {}
        for _, existingTrait in pairs( Game.CurrentRun.Hero.Traits) do
            if existingTrait.Slot == traitData.Slot then
                table.insert(traitDatas, existingTrait)
            end
        end
    end

    for _, v in ipairs(traitDatas) do
	    CreatePin(screen, button, v, args)
    end
end
