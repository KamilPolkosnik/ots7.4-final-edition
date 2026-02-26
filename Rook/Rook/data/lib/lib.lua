-- Core API functions implemented in Lua
dofile('data/lib/core/core.lua')

-- Compatibility library for our old Lua API
dofile('data/lib/compat/compat.lua')
dofile('data/lib/111-itemids.lua')

-- Action helper functions (e.g. doDecayItemTo / BridgeRelocate) used by quest levers
dofile('data/actions/lib/actions.lua')

-- Debugging helper function for Lua developers
dofile('data/lib/debugging/dump.lua')
dofile('data/lib/debugging/lua_version.lua')


--new

dofile('data/lib/core/json.lua')
dofile('data/lib/task_system.lua')
dofile('data/lib/monster_variants.lua')
