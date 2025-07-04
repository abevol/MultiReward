---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

ModUtil.mod.Path.Wrap("StartNewRun", function(base, prevRun, args)
    return base(prevRun, args)
end)

ModUtil.mod.Path.Wrap("RemoveStoreItem", function(base, args)
    return patch_RemoveStoreItem(base, args)
end)

ModUtil.mod.Path.Wrap("SpawnRoomReward", function(base, eventSource, args)
	return patch_SpawnRoomReward(base, eventSource, args)
end)

ModUtil.mod.Path.Wrap("SpawnStoreItemsInWorld", function(base, room, args)
	return patch_SpawnStoreItemsInWorld(base, room, args)
end)

ModUtil.mod.Path.Wrap("StartDevotionTest", function(base, currentEncounter, args)
    return patch_StartDevotionTest(base, currentEncounter, args)
end)

ModUtil.mod.Path.Wrap("UseNPC", function(base, npc, args, user)
	return patch_UseNPC(base, npc, args, user)
end)

ModUtil.mod.Path.Wrap("UseLoot", function(base, usee, args, user)
	return patch_UseLoot(base, usee, args, user)
end)

ModUtil.mod.Path.Wrap("OpenSpellScreen", function(base, spellItem, args, user)
    return patch_OpenSpellScreen(base, spellItem, args, user)
end)

ModUtil.mod.Path.Wrap("UnwrapRandomLoot", function(base, source)
    return patch_UnwrapRandomLoot(base, source)
end)

ModUtil.mod.Path.Wrap("UseConsumableItem", function(base, consumableItem, args, user)
	return patch_UseConsumableItem(base, consumableItem, args, user)
end)

ModUtil.mod.Path.Wrap("ErisTakeOff", function(base, eris)
	return patch_ErisTakeOff(base, eris)
end)

ModUtil.mod.Path.Wrap("ArtemisExitPresentation", function(base, source, args)
	return patch_ArtemisExitPresentation(base, source, args)
end)

ModUtil.mod.Path.Wrap("IcarusExitPresentation", function(base, source, args)
	return patch_IcarusExitPresentation(base, source, args)
end)

ModUtil.mod.Path.Wrap("NemesisTakeRoomExit", function(base, eventSource, args)
	return patch_NemesisTakeRoomExit(base, eventSource, args)
end)

ModUtil.mod.Path.Wrap("SetTraitTextData", function(base, traitData, args)
	return patch_SetTraitTextData(base, traitData, args)
end)

ModUtil.mod.Path.Wrap("SpawnRewardCages", function(base, room, args)
	return patch_SpawnRewardCages(base, room, args)
end)

ModUtil.mod.Path.Wrap("StartFieldsEncounter", function(base, rewardCage, args)
	return patch_StartFieldsEncounter(base, rewardCage, args)
end)

ModUtil.mod.Path.Wrap("LeaveRoom", function(base, currentRun, door)
	return patch_LeaveRoom(base, currentRun, door)
end)

ModUtil.mod.Path.Wrap("CreateLoot", function(base, args)
	return patch_CreateLoot(base, args)
end)

ModUtil.mod.Path.Wrap("CreateConsumableItemFromData", function(base, consumableId, consumableItem, costOverride, args)
	return patch_CreateConsumableItemFromData(base, consumableId, consumableItem, costOverride, args)
end)

ModUtil.mod.Path.Wrap("CheckRoomExitsReady", function(base, currentRoom)
	return patch_CheckRoomExitsReady(base, currentRoom)
end)

ModUtil.mod.Path.Wrap("ReachedMaxGods", function(base, excludedGods)
	return patch_ReachedMaxGods(base, excludedGods)
end)

ModUtil.mod.Path.Wrap("HandleUpgradeChoiceSelection", function(base, screen, button, args)
	return patch_HandleUpgradeChoiceSelection(base, screen, button, args)
end)

--[[ ModUtil.mod.Path.Wrap("TraitTrayCalcPinSpacing", function(base, screen)
	return patch_TraitTrayCalcPinSpacing(base, screen)
end)

ModUtil.mod.Path.Wrap("TraitTrayUpdatePinLocations", function(base, screen, args)
	return patch_TraitTrayUpdatePinLocations(base, screen, args)
end)

ModUtil.mod.Path.Wrap("PinTraitDetails", function(base, screen, button, args)
	return patch_PinTraitDetails(base, screen, button, args)
end) ]]
