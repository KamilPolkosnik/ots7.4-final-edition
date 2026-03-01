Crafting.enchanter = {}

local ENCHANT_RECIPE_BLOCKLIST = {
    [45] = true -- Mana Steal
}

local enchantCrystalId = US_CONFIG[1][ITEM_ENCHANT_CRYSTAL]
for enchantId, attr in ipairs(US_ENCHANTMENTS) do
    local itemTypeMask = attr and tonumber(attr.itemType) or 0
    local hasAllowedIds = attr and type(attr.allowedItemIds) == "table" and #attr.allowedItemIds > 0
    if attr and attr.name and not ENCHANT_RECIPE_BLOCKLIST[enchantId] and (itemTypeMask > 0 or hasAllowedIds) then
        table.insert(Crafting.enchanter, {
            id = enchantCrystalId,
            name = attr.name,
            level = attr.minLevel or 1,
            cost = 0,
            count = 1,
            enchantId = enchantId,
            materials = {
                {id = enchantCrystalId, count = 1}
            }
        })
    end
end
