-- Ensure Black Knight quest trees match TVP (AID-based rewards).
local FIXES = {
    {pos = Position(32868, 31955, 11), aid = 1050, itemid = 2720}, -- crown shield
    {pos = Position(32880, 31955, 11), aid = 1154, itemid = 2720}, -- crown armor
    {pos = Position(32800, 31959, 7), aid = 1208, itemid = 2720},  -- silver key 5010
    {pos = Position(32813, 31964, 7), aid = 1208, itemid = 2720},  -- silver key 5010
    {pos = Position(33315, 32277, 11), aid = 1111, itemid = 1410}, -- protection amulet (coffin)
    {pos = Position(33315, 32282, 11), aid = 1112, itemid = 1410}, -- stealth ring (coffin)
}

function onStartup()
    local applied, missing = 0, 0
    for _, fix in ipairs(FIXES) do
        local tile = Tile(fix.pos)
        if tile then
            local tree = tile:getItemById(fix.itemid)
            if not tree then
                tree = Game.createItem(fix.itemid, 1, fix.pos)
            end
            if tree then
                tree:setActionId(fix.aid)
                applied = applied + 1
            else
                missing = missing + 1
            end
        else
            missing = missing + 1
        end
    end
    print(string.format('[BlackKnightQuestFixups] applied=%d missing=%d', applied, missing))
end
