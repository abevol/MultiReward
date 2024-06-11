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

function patch_StartNewRun(base, prevRun, args)
	local currentRun = base(prevRun, args)

	if GameState ~= nil and CurrentRun.Hero ~= nil and Config.LowerShopPrices then
		local storeCostMultiplier = 1 / Config.ShopItemCount.Others
		local discountConfig = Config.ShopDiscountPercent
		if discountConfig and discountConfig >= 0 and discountConfig <= 100 then
			storeCostMultiplier = (100 - discountConfig) / 100
		end

		OverwriteTableKeys(TraitData, {
			MultiTraitCostReduction = {
				Hidden = true,
				Icon = "Boon_Poseidon_33",
				InheritFrom = { "BaseTrait" },
				BlockInRunRarify = true,
				StoreCostMultiplier = storeCostMultiplier
			}
		})
		ProcessDataInheritance(TraitData.MultiTraitCostReduction, TraitData)
		AddTrait(CurrentRun.Hero, "MultiTraitCostReduction", "Common")

		printMsg("Added shop price reduction by %s%%", tostring(storeCostMultiplier * 100))
	end

	return currentRun
end

function patch_SpawnRoomReward(base, eventSource, args)
	args = args or {}
    local reward = nil
    local currentRoom = Game.CurrentRun.CurrentRoom
    local currentEncounter = Game.CurrentRun.CurrentRoom.Encounter
    local rewardType = args.RewardOverride or currentEncounter.EncounterRoomRewardOverride or currentRoom.ChangeReward or currentRoom.ChosenRewardType
    local lootName = args.LootName or currentRoom.ForceLootName
    local rewardCount = getRewardCount(Config.RewardCount, rewardType, lootName)

    local debugMsg = string.format("RewardCount: %d, RewardType: %s%s", rewardCount, rewardType, lootName and ", LootName: " .. lootName or "")
    printMsg("%s", debugMsg)
    if Config.Debug then ModUtil.mod.Hades.PrintOverhead(debugMsg, 5) end

	local waitForLast = args.WaitUntilPickup
	args.WaitUntilPickup = false
	if Config.UpgradesOptional then
		args.NotRequiredPickup = true
	end

	reward = base(eventSource, args)
	thread(SpawnRewardCopies, base, reward, rewardCount - 1, eventSource, args)

	if waitForLast then
		waitUntil("MultiTrait_AllRewardsAcquired")
	end
    return reward
end

-- Does the reward spawning in another thread to allow the player to leave the room before picking up all rewards while still spawning the rewards one at a time
function SpawnRewardCopies(base, originalReward, rewardCount, eventSource, args)
    local reward = originalReward
	args.WaitUntilPickup = false
	ActiveRewardSpawners = ActiveRewardSpawners + 1

	for i = 1, rewardCount do
		if reward ~= nil then
			if reward.MenuNotify ~= nil then
				waitUntil(UIData.BoonMenuId, "MultiTrait_RewardSpawner")
			else
				reward.NotifyName = "OnUsed"..reward.ObjectId
				waitUntil(reward.NotifyName, "MultiTrait_RewardSpawner")
			end
		end

        reward = base(eventSource, args)
    end
	
	if reward ~= nil then
		if reward.MenuNotify ~= nil then
			waitUntil(UIData.BoonMenuId, "MultiTrait_RewardSpawner")
		else
			reward.NotifyName = "OnUsed"..reward.ObjectId
			waitUntil(reward.NotifyName, "MultiTrait_RewardSpawner")
		end
	end
	notifyExistingWaiters("MultiTrait_AllRewardsAcquired")
	ActiveRewardSpawners = ActiveRewardSpawners - 1
end

function patch_SpawnStoreItemInWorld(base, itemData, kitId)
	local spawnedItem = nil
	local shopItemCount = getRewardCount(Config.ShopItemCount, itemData.Type, itemData.Name)

    local debugMsg = string.format("ShopItemCount: %d, Type: %s%s", shopItemCount, itemData.Type, itemData.Name and ", Name: " .. itemData.Name or "")
    printMsg("%s", debugMsg)
    if Config.Debug then ModUtil.mod.Hades.PrintOverhead(debugMsg, 5) end

	
	spawnedItem = base(itemData, kitId)
	thread(SpawnStoreItemCopies, base, reward, rewardCount - 1, itemData, kitId)

	return spawnedItem
end

-- Does the store item spawning in another thread to spawn the rewards one at a time for a better visual experience
function SpawnStoreItemCopies(base, originalReward, rewardCount, itemData, kitId)
    local reward = originalReward
	ActiveRewardSpawners = ActiveRewardSpawners + 1

	for i = 1, rewardCount do
		if reward ~= nil then
			if reward.MenuNotify ~= nil then
				waitUntil(UIData.BoonMenuId, "MultiTrait_RewardSpawner")
			else
				reward.NotifyName = "OnUsed"..reward.ObjectId
				waitUntil(reward.NotifyName, "MultiTrait_RewardSpawner")
			end
		end

        reward = base(itemData, kitId)
    end
	ActiveRewardSpawners = ActiveRewardSpawners - 1
end

function patch_UseNPC(base, npc, args, user)
	local rewardCount = 1
	if Config.RewardCount then
		if Config.RewardCount.Others then rewardCount = Config.RewardCount.Others end
		local story = Config.RewardCount.Story
		if story then
			if story.Others then rewardCount = story.Others end
			if story[npc.SpeakerName] then rewardCount = story[npc.SpeakerName] end
		end
	end

	base(npc, args, user)
	if ActiveRewardSpawners == 0 then
		thread(RefreshNPC, rewardCount - 1, npc)
	else 
		notifyExistingWaiters("MultiTrait_NPCUsed")
	end
end

function patch_UseLoot(base, usee, args, user)
	if not usee or not usee.SpeakerName or (usee.SpeakerName ~= "Hades" and usee.SpeakerName ~= "Artemis") then
		base(usee, args, user)
		return
	end

	local rewardCount = 1
	if Config.RewardCount then
		if Config.RewardCount.Others then rewardCount = Config.RewardCount.Others end
		local story = Config.RewardCount.Story
		if story then
			if story.Others then rewardCount = story.Others end
			if story[usee.SpeakerName] then rewardCount = story[usee.SpeakerName] end
		end
	end

	base(usee, args, user)
	if ActiveRewardSpawners == 0 then
		thread(RefreshNPC, rewardCount - 1, usee)
	else 
		notifyExistingWaiters("MultiTrait_NPCUsed")
	end
end

function RefreshNPC(amount, npc)
	ActiveRewardSpawners = ActiveRewardSpawners + 1
	for _ = 1, amount do
		npc.NextInteractLines = GetRandomEligibleTextLines( npc, npc.InteractTextLineSets, GetNarrativeDataValue( npc, npc.InteractTextLinePriorities or "InteractTextLinePriorities" ), args )
		if npc.NextInteractLines ~= nil then
			if npc.NextInteractLines.Partner ~= nil then
				CheckPartnerConversations( npc )
			end
			SetNextInteractLines( npc, npc.NextInteractLines )
		end
		SetAvailableUseText(npc)
		printMsg("Use Button refresh activated")
		waitUntil("MultiTrait_NPCUsed")
	end
	ActiveRewardSpawners = ActiveRewardSpawners - 1
end

function patch_LeaveRoom(base, currentRun, door)
	killTaggedThreads("MultiTrait_RewardSpawner")
	ActiveRewardSpawners = 0
	base(currentRun, door)
end

function patch_CreateLoot(base, args)
	if Config.UpgradesOptional then
		args.DoesNotBlockExit = true
	end
	if ActiveRewardSpawners > 0 then
		args.SuppressSpawnSounds = true
	end

	local reward = base(args)
	
	-- Make reward accessible for the bow indicators in the fields of mourning
	if Config.UpgradesOptional then
		if CurrentRun.CurrentRoom.Using and CurrentRun.CurrentRoom.Using.Spawn and CurrentRun.CurrentRoom.Using.Spawn == "FieldsRewardCage" then
			MapState.OptionalRewards[reward.ObjectId] = reward
		end
	end

	return reward
end

function patch_CreateConsumableItem(base, consumableId, consumableName, costOverride, args) 
	args = args or {}
	if ActiveRewardSpawners > 0 then
		args.IgnoreSounds = true
	end
	return base(consumableId, consumableName, costOverride, args)
end

function patch_CheckRoomExitsReady(base, currentRoom)
	if not Config.UpgradesOptional and ActiveRewardSpawners > 0 then
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
