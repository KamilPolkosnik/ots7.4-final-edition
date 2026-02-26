Crafting.enchanter = {}

local enchantCrystalId = US_CONFIG[1][ITEM_ENCHANT_CRYSTAL]
for enchantId, attr in ipairs(US_ENCHANTMENTS) do
    if attr and attr.name then
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
