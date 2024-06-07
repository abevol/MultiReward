---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

ModUtil.mod.Path.Wrap("StartNewRun", function(base, prevRun, args)
	return patch_StartNewRun(base, prevRun, args)
end)

ModUtil.mod.Path.Wrap("SpawnRoomReward", function(base, eventSource, args)
	return patch_SpawnRoomReward(base, eventSource, args)
end)

ModUtil.mod.Path.Wrap("SpawnStoreItemInWorld", function(base, itemData, kitId)
	return patch_SpawnStoreItemInWorld(base, itemData, kitId)
end)

ModUtil.mod.Path.Wrap("ReachedMaxGods", function(base, excludedGods)
	return patch_ReachedMaxGods(base, excludedGods)
end)

ModUtil.mod.Path.Wrap("HandleUpgradeChoiceSelection", function(base, screen, button, args)
	return patch_HandleUpgradeChoiceSelection(base, screen, button, args)
end)

ModUtil.mod.Path.Wrap("TraitTrayCalcPinSpacing", function(base, screen)
	return patch_TraitTrayCalcPinSpacing(base, screen)
end)

ModUtil.mod.Path.Wrap("TraitTrayUpdatePinLocations", function(base, screen, args)
	return patch_TraitTrayUpdatePinLocations(base, screen, args)
end)

ModUtil.mod.Path.Wrap("PinTraitDetails", function(base, screen, button, args)
	return patch_PinTraitDetails(base, screen, button, args)
end)
