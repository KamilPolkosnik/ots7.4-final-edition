local CRAFT_ANVIL_ITEMID = 2555
local CRAFT_ANVIL_AID = 38820
local CRAFT_ANVIL_POSITIONS = {
    Position(32090, 32204, 7),
}

function onStartup()
    local applied = 0
    local created = 0
    local missingTile = 0

    for _, pos in ipairs(CRAFT_ANVIL_POSITIONS) do
        local tile = Tile(pos)
        if not tile then
            missingTile = missingTile + 1
        else
            local anvil = tile:getItemById(CRAFT_ANVIL_ITEMID)
            if not anvil then
                anvil = Game.createItem(CRAFT_ANVIL_ITEMID, 1, pos)
                if anvil then
                    created = created + 1
                end
            end

            if anvil then
                anvil:setActionId(CRAFT_ANVIL_AID)
                applied = applied + 1
            end
        end
    end

    print(string.format("[CraftAnvilFixup] applied=%d created=%d missingTile=%d", applied, created, missingTile))
end

