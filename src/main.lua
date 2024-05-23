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
_PLUGIN = _PLUGIN

-- get definitions for the game's globals
---@module 'game'
Game = rom.game
---@module 'game-import'
import_as_fallback(Game)

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

function printMsg(fmt, ...)
    if not Config.Debug then return end
    local text = string.format(fmt, ...)
    local green = "\x1b[32m"
    local reset = "\x1b[0m"
    print(green .. text .. reset)
end

function dumpTable(tbl, indent)
    local result = ""
    if not tbl then return result end
    if not indent then indent = 0 end

    local keys = {}
    for k in pairs(tbl) do
        keys[#keys + 1] = k
    end

    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)

    for _, k in ipairs(keys) do
        local v = tbl[k]
        local formatting = string.rep("  ", indent) .. tostring(k) .. ": "
        if type(v) == "table" then
            result = result .. formatting .. "\n" .. dumpTable(v, indent + 1)
        else
            result = result .. formatting .. tostring(v) .. "\n"
        end
    end
    return result
end

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
