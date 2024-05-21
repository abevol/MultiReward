---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

ModUtil.mod.Path.Wrap("SpawnRoomReward", function(base, eventSource, args)
	return patch_SpawnRoomReward(base, eventSource, args)
end)

ModUtil.mod.Path.Wrap("ReachedMaxGods", function(base, excludedGods)
	return false
end)

ModUtil.mod.Path.Wrap("GetReplacementTraits", function(base, traitNames, onlyFromLootName)
	return patch_GetReplacementTraits(base, traitNames, onlyFromLootName)
end)
