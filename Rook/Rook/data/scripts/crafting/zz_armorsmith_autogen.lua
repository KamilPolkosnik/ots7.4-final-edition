-- Auto-build armorsmith crafts from loaded item types.
-- This overrides static data/scripts/crafting/armorsmith.lua on startup.

if not Crafting then
    Crafting = {}
end

local MAX_ITEM_ID = 30000

local function itemExists(itemId)
    local it = ItemType(itemId)
    return it and it:getId() ~= 0 and it:getClientId() > 0
end

local materialSets = {
    helmet = {5890, 5880, 2147},
    chest = {5880, 5890, 2146},
    legs = {5880, 5885, 2149},
    boots = {5890, 5887, 2147},
    shield = {5880, 5890, 2146},
    others = {5881, 5887, 2149}
}

-- Manual helmet recipes/costs.
local helmetOverrides = {
    [2458] = {cost = 50, materials = {}}, -- chain helmet
    [3971] = {cost = 100, materials = {}}, -- charmer tiara
    [3970] = {disabled = true}, -- feather headdress
    [6480] = {cost = 10000000, materials = {{id = 2662, count = 1}}}, -- ferumbras' hat
    [2323] = {cost = 1000, materials = {{id = 2663, count = 1}}}, -- hat of the mad
    [2660] = {cost = 50, materials = {}}, -- hidden turbant
    [2461] = {cost = 50, materials = {}}, -- leather helmet
    [2662] = {cost = 100000, materials = {{id = 2323, count = 10}}}, -- magician hat
    [2663] = { -- mystic turban
        cost = 500,
        recipes = {
            {cost = 500, materials = {{id = 2457, count = 1}}, count = 1}, -- steel helmet
            {cost = 500, materials = {{id = 2490, count = 1}}, count = 1}, -- dark helmet
            {cost = 0, materials = {{id = 5871, count = 1}}, count = 1}, -- glacier mask
            {cost = 0, materials = {{id = 5867, count = 1}}, count = 1}, -- lightning headband
            {cost = 0, materials = {{id = 5866, count = 1}}, count = 1}, -- magma monocle
            {cost = 0, materials = {{id = 5882, count = 1}}, count = 1}, -- terra hood
            {cost = 5000, materials = {{id = 5809, count = 1}}, count = 100} -- yalahari mask -> 100 mystic turban
        }
    },
    [2665] = {disabled = true}, -- post officers hat
    [2482] = {cost = 50, materials = {{id = 2461, count = 1}}}, -- studded helmet
    [3967] = {cost = 50, materials = {{id = 2482, count = 1}}}, -- tribal mask
    [2460] = {cost = 50, materials = {{id = 2229, count = 10}}}, -- brass helmet
    [2480] = {cost = 50, materials = {{id = 2376, count = 3}}}, -- legion helmet
    [2473] = {cost = 100, materials = {{id = 2230, count = 10}}}, -- viking helmet
    [5871] = {cost = 5000, materials = {{id = 2146, count = 30}}}, -- glacier mask
    [2459] = {cost = 500, materials = {{id = 2473, count = 3}}}, -- iron helmet
    [5867] = {cost = 5000, materials = {{id = 2150, count = 30}}}, -- lightning headband
    [5866] = {cost = 5000, materials = {{id = 2147, count = 30}}}, -- magma monocle
    [2481] = {cost = 500, materials = {{id = 2480, count = 3}}}, -- soldier helmet
    [2490] = {cost = 500, materials = {{id = 2144, count = 1}}}, -- dark helmet
    [2502] = {cost = 10000, materials = {{id = 2525, count = 100}}}, -- dwarven helmet
    [3969] = {cost = 100000, materials = {{id = 2348, count = 10}, {id = 2339, count = 1}}}, -- horseman helmet
    [2457] = {cost = 500, materials = {{id = 2647, count = 1}}}, -- steel helmet
    [2479] = {cost = 500, materials = {{id = 2144, count = 2}}}, -- strange helmet
    [3972] = {cost = 1000, materials = {{id = 2516, count = 30}}}, -- beholder helmet
    [2491] = {cost = 3000, materials = {{id = 2457, count = 10}}}, -- crown helmet
    [2462] = {cost = 3000, materials = {{id = 2479, count = 10}}}, -- devil helmet
    [5809] = {cost = 100000, materials = {{id = 2663, count = 100}}}, -- yalahari mask
    [2497] = {cost = 10000, materials = {{id = 2475, count = 2}}}, -- crusader helmet
    [2498] = {cost = 10000, materials = {{id = 2497, count = 3}}}, -- royal helmet
    [5827] = {cost = 5000, materials = {{id = 2498, count = 1}, {id = 2377, count = 2}}}, -- zaoan helmet
    [2493] = {cost = 50000, materials = {{id = 2472, count = 5}}}, -- demon helmet
    [2506] = {cost = 1000000, materials = {{id = 2493, count = 30}, {id = 7870, count = 30}, {id = 2492, count = 30}}}, -- dragon scale helmet
    [2474] = {cost = 1000000, materials = {{id = 2493, count = 30}, {id = 7870, count = 30}, {id = 2470, count = 30}}}, -- winged helmet
    [2499] = {cost = 10000, materials = {{id = 2457, count = 25}}}, -- amazon helmet
    [5882] = {cost = 5000, materials = {{id = 2149, count = 30}}}, -- terra hood
    [2342] = {disabled = true}, -- helmet of the ancients
    [2343] = {disabled = true}, -- helmet of the ancients
    [2501] = {disabled = true}, -- ceremonial mask
    [2475] = { -- warrior helmet
        cost = 5000,
        recipes = {
            {cost = 5000, materials = {{id = 2457, count = 10}, {id = 2491, count = 2}}, count = 1},
            {cost = 3000, materials = {{id = 2490, count = 10}, {id = 2462, count = 2}}, count = 1}
        }
    },
    [2496] = { -- horned helmet
        cost = 2000000,
        recipes = {
            {cost = 2000000, materials = {{id = 2474, count = 1}, {id = 2472, count = 5}}, count = 1},
            {cost = 2000000, materials = {{id = 2506, count = 1}, {id = 2492, count = 5}}, count = 1}
        }
    },
    [2471] = { -- golden helmet (two recipes)
        cost = 10000000,
        recipes = {
            {
                cost = 10000000,
                materials = {
                    {id = 2474, count = 1}, -- winged helmet
                    {id = 2466, count = 100}, -- golden armor
                    {id = 2470, count = 100}, -- golden legs
                    {id = 7879, count = 10}, -- void crystal
                    {id = 2033, count = 100}, -- golden mug
                    {id = 2112, count = 1} -- teddy bear
                }
            },
            {
                cost = 10000000,
                materials = {
                    {id = 2506, count = 1}, -- dragon scale helmet
                    {id = 2492, count = 80}, -- dragon scale mail
                    {id = 2195, count = 100}, -- boots of haste
                    {id = 7879, count = 10}, -- void crystal
                    {id = 2033, count = 100}, -- golden mug
                    {id = 2112, count = 1} -- teddy bear
                }
            }
        }
    }
}

-- Manual chest/body recipes/costs.
local chestOverrides = {
    [2659] = {disabled = true}, -- ball gown
    [2651] = {cost = 50, materials = {}}, -- coat
    [2485] = {cost = 50, materials = {}}, -- doublet
    [2650] = {cost = 50, materials = {}}, -- jacket
    [2508] = {disabled = true}, -- native armor
    [2652] = {disabled = true}, -- green tunic
    [2655] = {cost = 100, materials = {}}, -- red robe
    [2653] = {cost = 100, materials = {{id = 2650, count = 2}}}, -- red tunic
    [2657] = {disabled = true}, -- simple dress
    [4847] = {disabled = true}, -- simple dress (duplicate id variant)
    [2658] = {disabled = true}, -- white dress
    [2654] = {cost = 300, materials = {{id = 2650, count = 3}}}, -- cape
    [2467] = {materials = {{id = 2650, count = 5}}}, -- leather armor
    [2484] = {cost = 100, materials = {{id = 2467, count = 1}}}, -- studded armor
    [2464] = {cost = 100, materials = {{id = 2484, count = 1}}}, -- chain armor
    [2465] = {cost = 500, materials = {{id = 2229, count = 10}, {id = 2464, count = 5}}}, -- brass armor
    [3968] = {cost = 5000, materials = {{id = 2410, count = 100}, {id = 5836, count = 10}}}, -- leopard armor
    [2483] = {cost = 400, materials = {{id = 2229, count = 10}, {id = 2465, count = 1}}}, -- scale armor
    [2489] = {cost = 1000, materials = {{id = 2490, count = 2}, {id = 2465, count = 1}}}, -- dark armor
    [2503] = {cost = 100000, materials = {{id = 2525, count = 100}}}, -- dwarven armor
    [2463] = {cost = 1000, materials = {{id = 2457, count = 2}, {id = 2465, count = 1}}}, -- plate armor
    [2656] = {cost = 10000, materials = {{id = 2654, count = 35}, {id = 2146, count = 2}}}, -- blue robe
    [5872] = {cost = 5000, materials = {{id = 2656, count = 1}, {id = 2146, count = 25}}}, -- glacier robe
    [5868] = {cost = 5000, materials = {{id = 2656, count = 1}, {id = 2150, count = 25}}}, -- lightning robe
    [5862] = {cost = 5000, materials = {{id = 2656, count = 1}, {id = 2147, count = 25}}}, -- magma coat
    [2486] = {cost = 3000, materials = {{id = 2463, count = 10}}}, -- noble armor
    [5881] = {cost = 5000, materials = {{id = 2656, count = 1}, {id = 2149, count = 25}}}, -- terra mantle
    [2476] = {cost = 5000, materials = {{id = 2463, count = 5}, {id = 2144, count = 5}}}, -- knight armor
    [5829] = { -- paladin armor
        cost = 25000,
        materials = {
            {id = 2486, count = 1},
            {id = 2455, count = 10},
            {id = 2456, count = 10},
            {id = 2547, count = 50},
            {id = 2546, count = 50}
        }
    },
    [2500] = {cost = 50000, materials = {{id = 2487, count = 10}, {id = 2488, count = 10}, {id = 5829, count = 1}}}, -- amazon armor
    [2487] = {cost = 10000, materials = {{id = 2476, count = 3}, {id = 2147, count = 5}}}, -- crown armor
    [5826] = {cost = 10000, materials = {{id = 2466, count = 1}, {id = 2393, count = 1}}}, -- zaoan armor
    [2466] = {cost = 10000, materials = {{id = 2487, count = 5}}}, -- golden armor
    [5784] = {cost = 50000, materials = {{id = 2466, count = 5}, {id = 2268, count = 100}}}, -- skullcracker armor
    [5816] = {cost = 50000, materials = {{id = 2466, count = 5}, {id = 2268, count = 100}}}, -- skullmaster armor
    [5807] = {cost = 50000, materials = {{id = 2466, count = 5}, {id = 2519, count = 5}, {id = 2293, count = 10}}}, -- yalahari armor
    [5828] = {cost = 50000, materials = {{id = 5829, count = 2}, {id = 2492, count = 3}}}, -- archer armor
    [2492] = {cost = 45000, materials = {{id = 2392, count = 3}, {id = 2466, count = 3}}}, -- dragon scale mail
    [2505] = {cost = 45000, materials = {{id = 2147, count = 30}, {id = 2492, count = 5}}}, -- firemasters armor
    [2664] = {cost = 45000, materials = {{id = 2147, count = 30}, {id = 2492, count = 5}}}, -- firemasters armor (duplicate id variant)
    [2494] = {cost = 100000, materials = {{id = 2472, count = 5}}}, -- demon armor
    [2472] = {cost = 80000, materials = {{id = 2393, count = 3}}} -- magic plate armor
}

-- Manual legs recipes/costs.
local legsOverrides = {
    [3983] = {disabled = true}, -- bast skirt
    [2649] = {cost = 50, materials = {}}, -- leather legs
    [2468] = {cost = 100, materials = {}}, -- studded legs
    [2648] = {cost = 150, materials = {}}, -- chain legs
    [2478] = {cost = 500, materials = {{id = 2648, count = 5}, {id = 2229, count = 10}}}, -- brass legs
    [2504] = {cost = 100000, materials = {{id = 2525, count = 100}}}, -- dwarven legs
    [2647] = {cost = 1000, materials = {{id = 2478, count = 1}, {id = 2457, count = 2}}}, -- plate legs
    [5808] = {cost = 50000, materials = {{id = 2470, count = 5}, {id = 2519, count = 5}, {id = 2293, count = 10}}}, -- yalahari leg piece
    [5728] = {cost = 10000, materials = {{id = 2654, count = 35}, {id = 2146, count = 2}}}, -- blue legs
    [2488] = {cost = 10000, materials = {{id = 2476, count = 3}}}, -- crown legs
    [5873] = {cost = 5000, materials = {{id = 5728, count = 1}, {id = 2146, count = 25}}}, -- glacier kilt
    [2507] = {disabled = true}, -- green legs
    [2477] = {cost = 5000, materials = {{id = 2647, count = 5}, {id = 2144, count = 5}}}, -- knight legs
    [5869] = {cost = 5000, materials = {{id = 5728, count = 1}, {id = 2150, count = 25}}}, -- lightning legs
    [5863] = {cost = 5000, materials = {{id = 5728, count = 1}, {id = 2147, count = 25}}}, -- magma legs
    [5880] = {cost = 5000, materials = {{id = 5728, count = 1}, {id = 2149, count = 25}}}, -- terra legs
    [5839] = {cost = 10000, materials = {{id = 2470, count = 1}, {id = 2393, count = 1}}}, -- zaoan legs
    [2470] = {cost = 10000, materials = {{id = 2033, count = 100}, {id = 2488, count = 1}, {id = 2393, count = 1}}}, -- golden legs
    [2495] = { -- demon legs
        cost = 100000,
        materials = {
            {id = 2493, count = 10},
            {id = 2494, count = 1},
            {id = 2472, count = 1},
            {id = 2112, count = 1},
            {id = 2147, count = 50},
            {id = 2470, count = 5}
        }
    },
    [2469] = {cost = 1000000, materials = {{id = 2495, count = 1}, {id = 2494, count = 1}, {id = 2112, count = 1}, {id = 2492, count = 30}}} -- dragon scale legs
}

-- Manual boots/feet recipes/costs.
local bootsOverrides = {
    [2195] = {cost = 10000, materials = {{id = 2169, count = 6}}}, -- boots of haste
    [2644] = {disabled = true}, -- bunny slippers
    [3982] = {cost = 1000, materials = {{id = 2643, count = 1}, {id = 2674, count = 10}}}, -- crocodile boots
    [5874] = {cost = 5000, materials = {{id = 2643, count = 1}, {id = 2146, count = 35}}}, -- glacier shoes
    [2643] = {cost = 100, materials = {}}, -- leather boots
    [5870] = {cost = 5000, materials = {{id = 2643, count = 1}, {id = 2150, count = 35}}}, -- lightning boots
    [5864] = {cost = 5000, materials = {{id = 2643, count = 1}, {id = 2147, count = 35}}}, -- magma boots
    [5798] = {disabled = true}, -- oriental shoes
    [2358] = {disabled = true}, -- pair of soft boots
    [2640] = {disabled = true}, -- pair of soft boots
    [5879] = {cost = 5000, materials = {{id = 2643, count = 1}, {id = 2149, count = 35}}}, -- terra boots
    [2641] = {disabled = true}, -- worn soft boots
    [5729] = {disabled = true}, -- worn soft boots
    [2645] = {cost = 30000, materials = {{id = 2393, count = 2}}}, -- steel boots
    [2646] = { -- golden boots
        cost = 10000000,
        materials = {
            {id = 2466, count = 100}, -- golden armor
            {id = 2470, count = 100}, -- golden legs
            {id = 7879, count = 10}, -- void crystal
            {id = 2033, count = 100}, -- golden mug
            {id = 2112, count = 1} -- teddy bear
        }
    },
    [5838] = {cost = 10000, materials = {{id = 2195, count = 1}, {id = 5827, count = 1}, {id = 5839, count = 1}, {id = 5826, count = 1}}} -- zaoan shoes
}

-- Manual shield/spellbook recipes/costs.
local shieldOverrides = {
    [5918] = {disabled = true}, -- spellscroll of prophecies
    [2512] = {cost = 40, materials = {{id = 2671, count = 4}}}, -- wooden shield
    [2526] = {cost = 50, materials = {{id = 2512, count = 1}}}, -- studded shield
    [2511] = {cost = 10, materials = {{id = 2526, count = 1}, {id = 2230, count = 5}}}, -- brass shield
    [5920] = {cost = 5000, materials = {{id = 2175, count = 1}, {id = 2311, count = 50}}}, -- spellbook of mind control
    [2510] = {cost = 30, materials = {{id = 2511, count = 1}, {id = 2376, count = 3}, {id = 2398, count = 2}}}, -- plate shield
    [2529] = {cost = 100, materials = {{id = 2510, count = 1}}}, -- black shield
    [5789] = {cost = 1000, materials = {{id = 2436, count = 1}, {id = 5920, count = 1}}}, -- necromantic spellbook
    [2530] = {cost = 0, materials = {{id = 2412, count = 1}, {id = 2230, count = 10}, {id = 2229, count = 10}}}, -- copper shield
    [2175] = {cost = 0, materials = {{id = 2260, count = 35}}}, -- spellbook
    [2509] = {cost = 1000, materials = {{id = 2530, count = 1}}}, -- steel shield
    [2524] = {cost = 1000000, materials = {{id = 2503, count = 1}}}, -- ornamented shield
    [3974] = {disabled = true}, -- sentinel shield
    [2531] = {cost = 1000, materials = {{id = 2473, count = 20}}}, -- viking shield
    [5791] = {cost = 3000, materials = {{id = 5789, count = 1}, {id = 2313, count = 30}}}, -- warlocks spellbook
    [2513] = {cost = 300, materials = {{id = 2509, count = 3}}}, -- battle shield
    [5812] = {cost = 5000, materials = {{id = 5791, count = 1}, {id = 2286, count = 10}}}, -- lizard knowledge spellbook
    [2537] = {cost = 100000, materials = {{id = 2499, count = 100}}}, -- amazon shield
    [2532] = {cost = 50000, materials = {{id = 2348, count = 10}}}, -- ancient shield
    [2518] = {cost = 1000, materials = {{id = 2516, count = 30}}}, -- beholder shield
    [2535] = {disabled = true}, -- castle shield
    [2519] = {cost = 5000, materials = {{id = 2516, count = 5}}}, -- crown shield
    [2521] = {cost = 500, materials = {{id = 2144, count = 5}}}, -- dark shield
    [2520] = {cost = 15000, materials = {{id = 2519, count = 10}, {id = 2147, count = 5}}}, -- demon shield
    [2516] = {cost = 3000, materials = {{id = 2463, count = 3}, {id = 2457, count = 5}, {id = 2647, count = 2}}}, -- dragon shield
    [2538] = {disabled = true}, -- eagle shield
    [2522] = {cost = 1000000, materials = {{id = 2492, count = 30}, {id = 7870, count = 30}, {id = 2514, count = 30}}}, -- great shield
    [2515] = {cost = 3000, materials = {{id = 2525, count = 5}}}, -- guardian shield
    [5865] = {cost = 10000, materials = {{id = 2520, count = 4}, {id = 2147, count = 50}, {id = 5862, count = 1}, {id = 5864, count = 1}, {id = 5866, count = 1}}}, -- magma shield
    [2514] = {cost = 30000, materials = {{id = 2393, count = 2}}}, -- mastermind shield
    [2536] = {cost = 3000, materials = {{id = 2515, count = 2}}}, -- medusa shield
    [2533] = {disabled = true}, -- mercenary shield
    [3975] = {disabled = true}, -- salamander shield
    [2540] = {cost = 1000, materials = {{id = 2525, count = 1}, {id = 2193, count = 10}}}, -- scarab shield
    [5539] = {cost = 30000, materials = {{id = 2147, count = 100}, {id = 2516, count = 3}, {id = 2519, count = 2}, {id = 2514, count = 1}}}, -- shield of dorion
    [2517] = {disabled = true}, -- shield of honour
    [2542] = {cost = 30000, materials = {{id = 2528, count = 1}, {id = 2519, count = 1}, {id = 2146, count = 100}}}, -- tempest shield
    [2528] = {cost = 3000, materials = {{id = 2516, count = 3}, {id = 2430, count = 1}}}, -- tower shield
    [3973] = {disabled = true}, -- tusk shield
    [2534] = {cost = 5000, materials = {{id = 2656, count = 2}, {id = 2519, count = 1}}}, -- vampire shield
    [5732] = {cost = 5000, materials = {{id = 2656, count = 2}, {id = 2519, count = 1}}}, -- vampire shield (alt id)
    [2539] = {materials = {{id = 2393, count = 1}, {id = 2536, count = 3}}}, -- phoenix shield
    [2527] = {materials = {{id = 2744, count = 100}, {id = 2745, count = 100}}}, -- rose shield
    [2541] = {cost = 600, materials = {{id = 2230, count = 10}}}, -- bone shield
    [2523] = {cost = 10000000, materials = {{id = 2466, count = 100}, {id = 2470, count = 100}, {id = 7879, count = 10}, {id = 2112, count = 1}, {id = 2033, count = 1}}} -- blessed shield
}

-- Manual overrides for "others" category.
local othersOverrides = {
    [7088] = {disabled = true}, -- regeneration amulet
    [2661] = {cost = 500, materials = {}}, -- scarf
    [2171] = {cost = 3000, materials = {{id = 2661, count = 5}}}, -- platinum amulet
    [2339] = {disabled = true} -- damaged helmet
}

local function getArmorGroup(itemType)
    if itemType:isHelmet() then
        return "helmet"
    elseif itemType:isArmor() then
        return "chest"
    elseif itemType:isLegs() then
        return "legs"
    elseif itemType:isBoots() then
        return "boots"
    elseif itemType:isShield() then
        return "shield"
    end
    return "others"
end

local function isArmorCandidate(itemType)
    if not itemType or itemType:getId() == 0 or itemType:getClientId() <= 0 then
        return false
    end

    if not itemType:isMovable() then
        return false
    end

    local weaponType = itemType:getWeaponType()
    if weaponType == WEAPON_SWORD or weaponType == WEAPON_AXE or weaponType == WEAPON_CLUB or weaponType == WEAPON_DISTANCE or
        weaponType == WEAPON_WAND or weaponType == WEAPON_AMMO then
        return false
    end

    if itemType:isHelmet() or itemType:isArmor() or itemType:isLegs() or itemType:isBoots() or itemType:isShield() then
        return true
    end

    local armor = math.max(0, itemType:getArmor())
    local defense = math.max(0, itemType:getDefense() + itemType:getExtraDefense())
    return armor > 0 or defense > 0
end

local function computeLevel(itemType, group)
    local armor = math.max(0, itemType:getArmor())
    local defense = math.max(0, itemType:getDefense() + itemType:getExtraDefense())

    local power = armor * 2.0 + defense * 1.5
    if group == "shield" then
        power = armor * 1.5 + defense * 2.2
    elseif group == "boots" then
        power = armor * 1.8 + defense * 1.2
    end

    local level = math.floor(power * 2.2)
    return math.max(8, math.min(120, level))
end

local function computeCost(itemType, level, group)
    local armor = math.max(0, itemType:getArmor())
    local defense = math.max(0, itemType:getDefense() + itemType:getExtraDefense())

    local cost = 250 + (level * level * 3) + (armor * 140) + (defense * 90)
    if group == "shield" then
        cost = math.floor(cost * 1.15)
    end

    return math.max(250, math.floor((cost + 25) / 50) * 50)
end

local function buildMaterials(group, level)
    local base = materialSets[group] or materialSets.others
    local mats = {}

    local c1 = math.max(2, math.floor(level / 10) + 2)
    local c2 = math.max(1, math.floor(level / 20) + 1)
    local c3 = math.max(1, math.floor(level / 35) + 1)

    if itemExists(base[1]) then
        table.insert(mats, {id = base[1], count = c1})
    end
    if itemExists(base[2]) then
        table.insert(mats, {id = base[2], count = c2})
    end
    if level >= 45 and itemExists(base[3]) then
        table.insert(mats, {id = base[3], count = c3})
    end

    if #mats == 0 then
        mats[1] = {id = 2148, count = math.max(5, math.floor(level / 4))}
    end

    return mats
end

local function generateArmorsmithCrafts()
    local crafts = {}
    local seen = {}

    for itemId = 100, MAX_ITEM_ID do
        local it = ItemType(itemId)
        if isArmorCandidate(it) then
            local name = it:getName()
            if name and name ~= "" then
                local group = getArmorGroup(it)
                local key = group .. ":" .. name:lower()
                if not seen[key] then
                    seen[key] = true
                    local level = computeLevel(it, group)
                    table.insert(
                        crafts,
                        {
                            id = itemId,
                            name = name,
                            armorType = group,
                            level = level,
                            cost = computeCost(it, level, group),
                            count = 1,
                            materials = buildMaterials(group, level)
                        }
                    )
                end
            end
        end
    end

    table.sort(
        crafts,
        function(a, b)
            if a.level ~= b.level then
                return a.level < b.level
            end
            return a.name:lower() < b.name:lower()
        end
    )

    return crafts
end

local function applyOverrideSet(crafts, overrides)
    local byId = {}
    for i = 1, #crafts do
        local craft = crafts[i]
        if type(craft) == "table" and craft.id then
            byId[craft.id] = i
        end
    end

    for itemId, override in pairs(overrides) do
        local idx = byId[itemId]
        if idx then
            local craft = crafts[idx]
            if type(craft) == "table" then
                if override.disabled then
                    crafts[idx] = false
                else
                    if override.count ~= nil then
                        craft.count = math.max(1, tonumber(override.count) or craft.count or 1)
                    end

                    if override.cost ~= nil then
                        craft.cost = math.max(0, tonumber(override.cost) or craft.cost)
                    end

                    if override.recipes ~= nil then
                        local recipes = {}
                        for i = 1, #override.recipes do
                            local recipe = override.recipes[i]
                            local recipeMats = {}
                            for x = 1, #(recipe.materials or {}) do
                                local mat = recipe.materials[x]
                                local matId = tonumber(mat.id)
                                local matCount = tonumber(mat.count)
                                if matId and matId > 0 and matCount and matCount > 0 and itemExists(matId) then
                                    recipeMats[#recipeMats + 1] = {id = matId, count = matCount}
                                end
                            end
                            recipes[#recipes + 1] = {
                                cost = math.max(0, tonumber(recipe.cost) or craft.cost),
                                count = math.max(1, tonumber(recipe.count) or craft.count or 1),
                                materials = recipeMats
                            }
                        end
                        craft.recipes = recipes
                        if recipes[1] then
                            craft.cost = recipes[1].cost
                            craft.count = recipes[1].count or craft.count
                            craft.materials = recipes[1].materials
                        end
                    elseif override.materials ~= nil then
                        local mats = {}
                        for i = 1, #override.materials do
                            local mat = override.materials[i]
                            local matId = tonumber(mat.id)
                            local matCount = tonumber(mat.count)
                            if matId and matId > 0 and matCount and matCount > 0 and itemExists(matId) then
                                mats[#mats + 1] = {id = matId, count = matCount}
                            end
                        end
                        craft.materials = mats
                        craft.recipes = nil
                    end
                end
            end
        end
    end
end

local function applyManualOverrides(crafts)
    applyOverrideSet(crafts, helmetOverrides)
    applyOverrideSet(crafts, chestOverrides)
    applyOverrideSet(crafts, legsOverrides)
    applyOverrideSet(crafts, bootsOverrides)
    applyOverrideSet(crafts, shieldOverrides)
    applyOverrideSet(crafts, othersOverrides)

    local filtered = {}
    for i = 1, #crafts do
        if crafts[i] then
            filtered[#filtered + 1] = crafts[i]
        end
    end
    return filtered
end

local generated = generateArmorsmithCrafts()
generated = applyManualOverrides(generated)
if #generated > 0 then
    Crafting.armorsmith = generated
    print(string.format("[CraftingArmorsmithAuto] generated=%d", #generated))
else
    print("[CraftingArmorsmithAuto] generated=0 (kept existing armorsmith list)")
end
