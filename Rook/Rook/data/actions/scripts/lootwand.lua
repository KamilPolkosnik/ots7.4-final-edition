
local lootTable = {
    { "axe", 2386, 7 },
    { "battle axe", 2378, 80 },
    { "battle hammer", 2417, 120 },
    { "battle shield", 2513, 95 },
    { "bone club", 2449, 5 },
    { "bone sword", 2450, 20 },
    { "brass armor", 2465, 150 },
    { "brass helmet", 2460, 30 },
    { "brass legs", 2478, 49 },
    { "brass shield", 2511, 25 },
    { "carlin sword", 2395, 118 },
    { "chain armor", 2464, 70 },
    { "chain helmet", 2458, 17 },
    { "chain legs", 2648, 25 },
    { "club", 2382, 1 },
    { "coat", 2651, 1 },
    { "copper shield", 2530, 50 },
    { "crowbar", 2416, 50 },
    { "dagger", 2379, 2 },
    { "double axe", 2387, 260 },
    { "doublet", 2485, 3 },
    { "dwarven shield", 2525, 100 },
    { "fire sword", 2392, 1000 },
    { "halberd", 2381, 400 },
    { "hand axe", 2380, 4 },
    { "hatchet", 2388, 25 },
    { "iron helmet", 2459, 150 },
    { "jacket", 2650, 1 },
    { "katana", 2412, 35 },
    { "leather armor", 2467, 12 },
    { "leather boots", 2643, 2 },
    { "leather helmet", 2461, 4 },
    { "leather legs", 2649, 9 },
    { "legion helmet", 2480, 22 },
    { "longsword", 2397, 51 },
    { "mace", 2398, 30 },
    { "morning star", 2394, 100 },
    { "orcish axe", 2428, 350 },
    { "plate armor", 2463, 400 },
    { "plate legs", 2647, 115 },
    { "plate shield", 2510, 45 },
    { "rapier", 2384, 5 },
    { "sabre", 2385, 12 },
    { "scale armor", 2483, 75 },
    { "short sword", 2406, 10 },
    { "sickle", 2405, 3 },
    { "small axe", 2559, 5 },
    { "soldier helmet", 2481, 16 },
    { "spike sword", 2383, 240 },
    { "steel helmet", 2457, 293 },
    { "steel shield", 2509, 80 },
    { "studded armor", 2484, 25 },
    { "studded club", 2448, 10 },
    { "studded helmet", 2482, 20 },
    { "studded legs", 2468, 15 },
    { "studded shield", 2526, 16 },
    { "sword", 2376, 25 },
    { "throwing knife", 2410, 2 },
    { "two handed sword", 2377, 450 },
    { "viking helmet", 2473, 66 },
    { "viking shield", 2531, 85 },
    { "war hammer", 2391, 470 },
    { "wooden shield", 2512, 5 },
	{ "spellbook", 2175, 75},
	{ "beholder shield", 2518, 500},
	{ "moonlight rod", 7095, 250},
	{ "wand of dragonbreath", 7100, 250}
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Get the item id of the target
    local targetItemId = target.itemid
    
    -- Check if the target item id is in the loot table
    local isInLootTable = false
    local itemPrice = 0
    local itemName = ""
    for _, lootItem in ipairs(lootTable) do
        if lootItem[2] == targetItemId then
            isInLootTable = true
            itemPrice = lootItem[3]
            itemName = lootItem[1]
            break
        end
    end
    
    -- If the target item is not found in the loot table, return false
    if not isInLootTable then
        print("Item with item id " .. targetItemId .. " is not in the loot table.")
        return false
    end
    
    -- Calculate the amount of money to give to the player
    local moneyToAdd = math.floor(itemPrice / 2)
    
    -- Check if the item sells for full price (1 in 10 chance)
    if math.random(10) == 1 then
        moneyToAdd = itemPrice
        player:say("[LWS] Sold " .. itemName .. " for " .. moneyToAdd .. " gold.", TALKTYPE_ORANGE_1)
        print("[DEBUG] [LWS] Sold " .. itemName .. " for " .. moneyToAdd .. " gold.")
    else
        player:say("You sold " .. itemName .. " for " .. moneyToAdd .. " gold.", TALKTYPE_ORANGE_1)
        print("[DEBUG] Sold " .. itemName .. " for " .. moneyToAdd .. " gold.")
    end
    
    target:remove(1)
	player:addMoney(moneyToAdd)
    
    -- Debug print of the item used on what
    print("[DEBUG] Item with item id " .. targetItemId .. " was used on " .. itemName)
    
    return true -- Return true if the item usage is successful
end