---@meta _
-- grabbing our dependencies,
-- these funky (---@) comments are just there
--	 to help VS Code find the definitions of things

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'SGG_Modding-ENVY-auto'
mods['SGG_Modding-ENVY'].auto()
-- ^ this gives us `public` and `import`, among others
--	and makes all globals we define private to this plugin.

---@diagnostic disable-next-line: undefined-global
Rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = PLUGIN

---@module 'SGG_Modding-Hades2GameDef-Globals'
Game = rom.game

---@module 'SGG_Modding-SJSON'
SJSON = mods['SGG_Modding-SJSON']
---@module 'SGG_Modding-ModUtil'
ModUtil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
Chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
ReLoad = mods['SGG_Modding-ReLoad']

---@module 'config'
Config = Chalk.auto 'config.lua'
-- ^ this updates our `.cfg` file in the config folder!
public.config = Config -- so other mods can access our config

local function on_ready()
	-- what to do when we are ready, but not re-do on reload.
	if Config.Enabled == false then return end
	
	import 'ready.lua'
end

local function on_reload()
	-- what to do when we are ready, but also again on every reload.
	-- only do things that are safe to run over and over.
	
	import 'reload.lua'
end

-- this allows us to limit certain functions to not be reloaded.
local loader = ReLoad.auto_single()

-- this runs only when ModUtil and the game's lua is ready
ModUtil.on_ready_final(function()
	loader.load(on_ready, on_reload)
end)
