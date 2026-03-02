-- Auto-build weaponsmith crafts from loaded item types.
-- This overrides static data/scripts/crafting/weaponsmith.lua on startup.

if not Crafting then
    Crafting = {}
end

local MAX_ITEM_ID = 30000

local function itemExists(itemId)
    local it = ItemType(itemId)
    return it and it:getId() ~= 0 and it:getClientId() > 0
end

-- Manual axe filters/recipes.
-- Rules:
-- 1) Remove from crafting every axe obtainable via monster loot or quest reward.
-- 2) Keep craft-only axes with custom recipes and costs.
local axeOverrides = {
    [2378] = {disabled = true}, -- battle axe (loot/quest)
    [2380] = {disabled = true}, -- hand axe (loot)
    [2381] = {disabled = true}, -- halberd (loot/quest)
    [2386] = {disabled = true}, -- axe (loot)
    [2387] = {disabled = true}, -- double axe (loot)
    [2388] = {disabled = true}, -- hatchet (loot/quest)
    [2405] = {disabled = true}, -- sickle (loot)
    [2414] = {disabled = true}, -- dragon lance (loot/quest)
    [2415] = {
        cost = 5000000,
        materials = {
            {id = 2112, count = 1}, -- teddy bear
            {id = 2208, count = 100}, -- axe ring
            {id = 2348, count = 50}, -- ancient rune
            {id = 2193, count = 50}, -- ankh
            {id = 3956, count = 50}, -- elephant tusk
            {id = 2230, count = 200} -- bone
        }
    }, -- great axe
    [2418] = {disabled = true}, -- golden sickle (loot)
    [2425] = {disabled = true}, -- obsidian lance (loot/quest)
    [2426] = {
        cost = 4000,
        materials = {
            {id = 2381, count = 5}, -- halberd
            {id = 2230, count = 6}, -- bone
            {id = 2208, count = 2} -- axe ring
        }
    }, -- naginata
    [2427] = {disabled = true}, -- guardian halberd (quest)
    [2428] = {disabled = true}, -- orcish axe (loot/quest)
    [2429] = {disabled = true}, -- barbarian axe (loot/quest)
    [2430] = {disabled = true}, -- knight axe (loot/quest)
    [2431] = {cost = 500000, materials = {
        {id = 2208, count = 100},
    }}, -- stonecutter axe
    [2432] = {disabled = true}, -- fire axe (loot/quest)
    [2435] = {disabled = true}, -- dwarven axe (quest)
    [2440] = {disabled = true}, -- daramanian waraxe (loot)
    [2441] = {
        cost = 500,
        materials = {}
    }, -- daramanian axe
    [2443] = {
        cost = 250000,
        materials = {
            {id = 5904, count = 1}, -- royal axe
            {id = 2208, count = 15}, -- axe ring
            {id = 2348, count = 20}, -- ancient rune
            {id = 2193, count = 20}, -- ankh
            {id = 3956, count = 20}, -- elephant tusk
            {id = 2230, count = 20} -- bone
        }
    }, -- ravager's axe
    [2447] = {
        cost = 45000,
        materials = {
            {id = 5903, count = 1}, -- thornfang axe
            {id = 2208, count = 8}, -- axe ring
            {id = 2348, count = 7}, -- ancient rune
            {id = 2193, count = 7} -- ankh
        }
    }, -- twin axe
    [2454] = {
        cost = 150000,
        materials = {
            {id = 2447, count = 1}, -- twin axe
            {id = 2208, count = 12}, -- axe ring
            {id = 2348, count = 10}, -- ancient rune
            {id = 2193, count = 10}, -- ankh
            {id = 3956, count = 10}, -- elephant tusk
            {id = 2230, count = 10} -- bone
        }
    }, -- war axe
    [2550] = {disabled = true}, -- scythe
    [3962] = {
        cost = 5000,
        materials = {
            {id = 2430, count = 1}, -- knight axe
            {id = 2230, count = 5}, -- bone
            {id = 2208, count = 2} -- axe ring
        }
    }, -- beastslayer axe
    [3964] = {disabled = true}, -- ripper lance (loot)
    [3965] = {disabled = true}, -- hunting spear (loot)
    [5537] = {
        cost = 30000,
        materials = {
            {id = 3962, count = 1}, -- beastslayer axe
            {id = 2208, count = 5}, -- axe ring
            {id = 3956, count = 10} -- elephant tusk
        }
    }, -- axe of donarion
    [5890] = {
        cost = 1000000,
        materials = {
            {id = 2431, count = 1}, -- stonecutter axe
            {id = 2208, count = 25}, -- axe ring
            {id = 2348, count = 30}, -- ancient rune
            {id = 2193, count = 30}, -- ankh
            {id = 3956, count = 30}, -- elephant tusk
            {id = 2230, count = 30} -- bone
        }
    }, -- phonic axe
    [5893] = {disabled = true}, -- vampiric axe
    [5903] = {
        cost = 28000,
        materials = {
            {id = 2426, count = 1}, -- naginata
            {id = 2208, count = 4}, -- axe ring
            {id = 2230, count = 12} -- bone
        }
    }, -- thornfang axe
    [5904] = {
        cost = 50000,
        materials = {
            {id = 3962, count = 1}, -- beastslayer axe
            {id = 2208, count = 10}, -- axe ring
            {id = 2348, count = 10}, -- ancient rune
            {id = 2193, count = 10} -- ankh
        }
    }, -- royal axe
    [5923] = {disabled = true} -- thornfang axe (variant)
}

-- Manual sword filters/recipes.
-- Rules:
-- 1) Remove from crafting every sword obtainable via monster loot or quest reward.
-- 2) Keep craft-only swords with custom recipes and costs.
local swordOverrides = {
    [2376] = {disabled = true}, -- sword (loot)
    [2377] = {disabled = true}, -- two handed sword (loot/quest)
    [2379] = {disabled = true}, -- dagger (loot)
    [2383] = {disabled = true}, -- spike sword (loot/quest)
    [2384] = {disabled = true}, -- rapier (loot/quest)
    [2385] = {disabled = true}, -- sabre (loot)
    [2390] = {
        cost = 5000000,
        materials = {
            {id = 2112, count = 1}, -- teddy bear
            {id = 2408, count = 1} -- warlord sword
        }
    }, -- magic longsword
    [2392] = {disabled = true}, -- fire sword (loot/quest)
    [2393] = {disabled = true}, -- giant sword (loot/quest)
    [2395] = {disabled = true}, -- carlin sword (loot/quest)
    [2396] = {disabled = true}, -- ice rapier (loot)
    [2397] = {disabled = true}, -- longsword (loot/quest)
    [2400] = {
        cost = 500000,
        materials = {
            {id = 2207, count = 100} -- sword ring
        }
    }, -- magic sword
    [2402] = {disabled = true}, -- silver dagger (loot/quest)
    [2403] = {disabled = true}, -- knife (loot)
    [2404] = {disabled = true}, -- combat knife (loot/quest)
    [2406] = {disabled = true}, -- short sword (loot)
    [2407] = {disabled = true}, -- bright sword (quest)
    [2408] = {
        cost = 800000,
        materials = {
            {id = 5755, count = 1}, -- avenger
            {id = 2207, count = 20}, -- sword ring
            {id = 2231, count = 50}, -- big bone
            {id = 2349, count = 50}, -- blue note
            {id = 2745, count = 50}, -- blue rose
            {id = 1950, count = 200} -- book
        }
    }, -- warlord sword
    [2409] = {disabled = true}, -- serpent sword (loot/quest)
    [2411] = {disabled = true}, -- poison dagger (loot/quest)
    [2412] = {disabled = true}, -- katana (loot/quest)
    [2413] = {disabled = true}, -- broad sword (loot/quest)
    [2419] = {disabled = true}, -- scimitar (loot/quest)
    [2420] = {disabled = true}, -- machete (loot)
    [2438] = {
        cost = 8000,
        materials = {
            {id = 5739, count = 1}, -- ice sword
            {id = 2231, count = 3}, -- big bone
            {id = 2349, count = 3}, -- blue note
            {id = 2207, count = 2} -- sword ring
        }
    }, -- epee
    [2442] = {disabled = true}, -- heavy machete (loot)
    [2446] = {
        cost = 30000,
        materials = {
            {id = 2451, count = 1}, -- djinn blade
            {id = 2231, count = 6}, -- big bone
            {id = 2349, count = 6}, -- blue note
            {id = 2207, count = 8} -- sword ring
        }
    }, -- pharaoh sword
    [2450] = {disabled = true}, -- bone sword (loot)
    [2451] = {
        cost = 16000,
        materials = {
            {id = 5905, count = 2}, -- wyvern fang
            {id = 2231, count = 3}, -- big bone
            {id = 2349, count = 3}, -- blue note
            {id = 2207, count = 4} -- sword ring
        }
    }, -- djinn blade (djin sword)
    [3963] = {disabled = true}, -- templar scytheblade (loot)
    [5535] = {
        cost = 1000000,
        materials = {
            {id = 2400, count = 1}, -- magic sword
            {id = 2207, count = 25}, -- sword ring
            {id = 2231, count = 30}, -- big bone
            {id = 2349, count = 30}, -- blue note
            {id = 2745, count = 30}, -- blue rose
            {id = 1950, count = 30} -- book
        }
    }, -- sword of furion
    [5739] = {
        cost = 4000,
        materials = {
            {id = 2231, count = 5}, -- big bone
            {id = 2207, count = 2} -- sword ring
        }
    }, -- ice sword
    [5755] = {
        cost = 200000,
        materials = {
            {id = 5906, count = 1}, -- blacksteel sword
            {id = 2207, count = 12}, -- sword ring
            {id = 2231, count = 11}, -- big bone
            {id = 2349, count = 12}, -- blue note
            {id = 2745, count = 11}, -- blue rose
            {id = 1950, count = 11} -- book
        }
    }, -- avenger
    [5898] = {
        cost = 16000,
        materials = {
            {id = 5739, count = 1}, -- ice sword
            {id = 2231, count = 3}, -- big bone
            {id = 2349, count = 3}, -- blue note
            {id = 2207, count = 4} -- sword ring
        }
    }, -- ice blade
    [5899] = {
        cost = 40000,
        materials = {
            {id = 2446, count = 1}, -- pharaoh sword
            {id = 2231, count = 7}, -- big bone
            {id = 2349, count = 7}, -- blue note
            {id = 2745, count = 7}, -- blue rose
            {id = 2207, count = 12} -- sword ring
        }
    }, -- rune sword
    [5905] = {
        cost = 3500,
        materials = {
            {id = 2409, count = 2} -- serpent sword
        }
    }, -- wyvern fang
    [5906] = {
        cost = 27000,
        materials = {
            {id = 2377, count = 5}, -- two handed sword
            {id = 2207, count = 8}, -- sword ring
            {id = 2231, count = 5}, -- big bone
            {id = 2349, count = 5} -- blue note
        }
    } -- blacksteel sword
}

-- Manual club filters/recipes.
-- Rules:
-- 1) Remove from crafting every club obtainable via monster loot or quest reward.
-- 2) Keep craft-only clubs with custom recipes and costs.
local clubOverrides = {
    [2321] = {disabled = true}, -- giant smithhammer (quest)
    [2382] = {disabled = true}, -- club (loot)
    [2391] = {disabled = true}, -- war hammer (loot/quest)
    [2394] = {disabled = true}, -- morning star (loot/quest)
    [2398] = {disabled = true}, -- mace (loot)
    [2401] = {disabled = true}, -- staff (loot)
    [2416] = {disabled = true}, -- crowbar (loot)
    [2417] = {disabled = true}, -- battle hammer (loot/quest)
    [2421] = {
        cost = 500000,
        materials = {
            {id = 2209, count = 100} -- club ring
        }
    }, -- thunder hammer
    [2422] = {cost = 500, materials = {}}, -- iron hammer (quest)
    [2423] = {disabled = true}, -- clerical mace (loot)
    [2424] = {
        cost = 25000,
        materials = {
            {id = 5536, count = 1}, -- club of dorion
            {id = 2209, count = 5}, -- club ring
            {id = 2678, count = 10} -- coconut
        }
    }, -- silver mace
    [2433] = {disabled = true}, -- enchanted staff
    [2434] = {disabled = true}, -- dragon hammer (loot/quest)
    [2436] = {disabled = true}, -- skull staff (loot/quest)
    [2437] = {
        recipes = {
            {
                cost = 70000,
                materials = {
                    {id = 2424, count = 1}, -- silver mace
                    {id = 2678, count = 10}, -- coconut
                    {id = 2237, count = 10}, -- dirty cape
                    {id = 2220, count = 10}, -- dirty fur
                    {id = 2209, count = 12} -- club ring
                }
            },
            {
                cost = 70000,
                materials = {
                    {id = 5894, count = 1}, -- sapphire axe
                    {id = 2678, count = 12}, -- coconut
                    {id = 2237, count = 12}, -- dirty cape
                    {id = 2220, count = 12}, -- dirty fur
                    {id = 2209, count = 12} -- club ring
                }
            }
        }
    }, -- golden mace
    [2439] = {disabled = true}, -- daramanian mace (loot)
    [2444] = {disabled = true}, -- hammer of wrath (loot/quest)
    [2445] = {disabled = true}, -- crystal mace (loot)
    [2448] = {disabled = true}, -- studded club (loot)
    [2449] = {disabled = true}, -- bone club (loot)
    [2452] = {
        cost = 180000,
        materials = {
            {id = 2391, count = 20}, -- war hammer
            {id = 2209, count = 12}, -- club ring
            {id = 2678, count = 12}, -- coconut
            {id = 2237, count = 15}, -- dirty cape
            {id = 2220, count = 15} -- dirty fur
        }
    }, -- heavy mace
    [2453] = {
        cost = 200000,
        materials = {
            {id = 2452, count = 1}, -- heavy mace
            {id = 2209, count = 12}, -- club ring
            {id = 2678, count = 15}, -- coconut
            {id = 2237, count = 15}, -- dirty cape
            {id = 2220, count = 15} -- dirty fur
        }
    }, -- arcane staff
    [3966] = {
        cost = 1500,
        materials = {
            {id = 2209, count = 1} -- club ring
        }
    }, -- banana staff
    [4846] = {disabled = true}, -- iron hammer (variant)
    [5536] = {
        cost = 30000,
        materials = {
            {id = 5892, count = 1}, -- hadge hammer
            {id = 2209, count = 5}, -- club ring
            {id = 2678, count = 10} -- coconut
        }
    }, -- club of dorion
    [5799] = {disabled = true}, -- terra wand
    [5800] = {disabled = true}, -- fire wand
    [5801] = {disabled = true}, -- icy wand
    [5802] = {disabled = true}, -- electric wand (quest)
    [5885] = {disabled = true}, -- ice flail
    [5886] = {disabled = true}, -- abyss club
    [5888] = {disabled = true}, -- death star
    [5889] = {
        cost = 1000000,
        materials = {
            {id = 2421, count = 1}, -- thunder hammer
            {id = 2209, count = 25}, -- club ring
            {id = 2678, count = 30}, -- coconut
            {id = 2237, count = 30}, -- dirty cape
            {id = 2220, count = 30}, -- dirty fur
            {id = 2110, count = 30} -- doll
        }
    }, -- Spark Hammer
    [5892] = {
        cost = 5000,
        materials = {
            {id = 2434, count = 1}, -- dragon hammer
            {id = 2678, count = 5}, -- coconut
            {id = 2209, count = 2} -- club ring
        }
    }, -- hadge hammer
    [5894] = {
        cost = 25000,
        materials = {
            {id = 5536, count = 1}, -- club of dorion
            {id = 2209, count = 5}, -- club ring
            {id = 2678, count = 10} -- coconut
        }
    }, -- Sapphire Axe
    [5897] = {
        cost = 70000,
        materials = {
            {id = 2209, count = 12}, -- club ring
            {id = 2678, count = 7}, -- coconut
            {id = 2237, count = 7}, -- dirty cape
            {id = 2220, count = 7} -- dirty fur
        }
    }, -- squarearth hammer
    [5901] = {
        cost = 1800,
        materials = {
            {id = 2209, count = 1}, -- club ring
            {id = 2678, count = 2} -- coconut
        }
    }, -- Quara Sceptre
    [5902] = {disabled = true}, -- Destroyer Club
    [7916] = {
        cost = 5000000,
        materials = {
            {id = 2112, count = 1}, -- teddy bear
            {id = 2209, count = 100}, -- club ring
            {id = 2678, count = 50}, -- coconut
            {id = 2237, count = 50}, -- dirty cape
            {id = 2220, count = 50}, -- dirty fur
            {id = 2110, count = 200} -- doll
        }
    } -- golden war hammer
}

-- Manual distance filters/recipes.
-- Rules:
-- 1) Remove from crafting every distance weapon obtainable via monster loot or quest reward.
-- 2) Keep craft-only distance weapons with custom recipes and costs.
local distanceOverrides = {
    [1294] = {disabled = true}, -- small stone (loot)
    [2111] = {disabled = true}, -- snowball (loot)
    [2350] = {disabled = true}, -- royal crossbow (loot)
    [2389] = {disabled = true}, -- spear (loot/quest)
    [2399] = {disabled = true}, -- throwing star (loot/quest)
    [2410] = {disabled = true}, -- throwing knife (loot)
    [2455] = {disabled = true}, -- crossbow (loot/quest)
    [2456] = {disabled = true}, -- bow (loot/quest)
    [5754] = {
        cost = 100000,
        materials = {
            {id = 2455, count = 10}, -- crossbow
            {id = 2070, count = 2}, -- flute
            {id = 1976, count = 2} -- gemmed book
        }
    }, -- arbalest
    [5836] = {
        cost = 100,
        materials = {
            {id = 2399, count = 50} -- throwing star
        }
    }, -- assassin star
    [5912] = {
        cost = 1000000,
        materials = {
            {id = 5754, count = 1}, -- arbalest
            {id = 2455, count = 20}, -- crossbow
            {id = 2070, count = 5}, -- flute
            {id = 1976, count = 5}, -- gemmed book
            {id = 2760, count = 5} -- goat grass
        }
    }, -- modified crossbow
    [5913] = {cost = 2100}, -- royal crossbow
    [5914] = {
        cost = 4000000,
        materials = {
            {id = 5912, count = 1}, -- modified crossbow
            {id = 2455, count = 50}, -- crossbow
            {id = 2070, count = 50}, -- flute
            {id = 1976, count = 50}, -- gemmed book
            {id = 2760, count = 50}, -- goat grass
            {id = 2033, count = 200} -- golden mug
        }
    }, -- death crossbow
    [5915] = {
        cost = 100000,
        materials = {
            {id = 2456, count = 10}, -- bow
            {id = 2070, count = 2}, -- flute
            {id = 1976, count = 2} -- gemmed book
        }
    }, -- composite hornbow
    [5916] = {
        cost = 3000000,
        materials = {
            {id = 5917, count = 1}, -- ice bow
            {id = 2456, count = 50}, -- bow
            {id = 2070, count = 25}, -- flute
            {id = 1976, count = 25}, -- gemmed book
            {id = 2760, count = 25}, -- goat grass
            {id = 2033, count = 25} -- golden mug
        }
    }, -- earth bow
    [5917] = {
        cost = 1000000,
        materials = {
            {id = 5915, count = 1}, -- composite hornbow
            {id = 2456, count = 20}, -- bow
            {id = 2070, count = 5}, -- flute
            {id = 1976, count = 5}, -- gemmed book
            {id = 2760, count = 5} -- goat grass
        }
    } -- ice bow
}

local materialSets = {
    sword = {2230, 2231, 2229},
    axe = {2230, 2151, 2747},
    club = {2230, 2231, 2229},
    distance = {2151, 2245, 2747},
    wand = {2231, 2245, 2747}
}

local function getWeaponGroup(itemType)
    local weaponType = itemType:getWeaponType()
    if weaponType == WEAPON_SWORD then
        return "sword"
    elseif weaponType == WEAPON_AXE then
        return "axe"
    elseif weaponType == WEAPON_CLUB then
        return "club"
    elseif weaponType == WEAPON_DISTANCE then
        return "distance"
    elseif weaponType == WEAPON_WAND then
        return "wand"
    end
    return nil
end

local function isMageRodOrWand(name)
    local n = (name or ""):lower()
    return n:find("%f[%a]wand%f[%A]") ~= nil or n:find("%f[%a]rod%f[%A]") ~= nil
end

local function computeLevel(itemType, group)
    local attack = math.max(0, itemType:getAttack())
    local defense = math.max(0, itemType:getDefense() + itemType:getExtraDefense())

    local power
    if group == "distance" then
        power = attack * 2.2 + defense * 1.0
    elseif group == "wand" then
        power = attack * 2.4 + defense * 0.8
    else
        power = attack * 2.0 + defense * 1.2
    end

    local level = math.floor(power * 1.15)
    if itemType:isTwoHanded() then
        level = level + 6
    end
    return math.max(8, math.min(120, level))
end

local function computeCost(itemType, level)
    local attack = math.max(0, itemType:getAttack())
    local defense = math.max(0, itemType:getDefense() + itemType:getExtraDefense())

    local cost = 200 + (level * level * 3) + (attack * 110) + (defense * 70)
    if itemType:isTwoHanded() then
        cost = math.floor(cost * 1.2)
    end

    -- Round to 50 for cleaner prices.
    return math.max(250, math.floor((cost + 25) / 50) * 50)
end

local function buildMaterials(group, level)
    local base = materialSets[group] or materialSets.sword
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

local function generateWeaponsmithCrafts()
    local crafts = {}
    local seen = {}

    for itemId = 100, MAX_ITEM_ID do
        local it = ItemType(itemId)
        if it and it:getId() ~= 0 and it:getClientId() > 0 and it:isWeapon() then
            local group = getWeaponGroup(it)
            local name = it:getName()
            if group and name and name ~= "" then
                -- Do not include mage rods/wands in crafting.
                if group ~= "wand" and not isMageRodOrWand(name) then
                    -- Many servers have duplicate weapon states with same name.
                    local key = group .. ":" .. name:lower()
                    if not seen[key] then
                        seen[key] = true
                        local level = computeLevel(it, group)
                        table.insert(
                            crafts,
                            {
                                id = itemId,
                                name = name,
                                weaponType = group,
                                level = level,
                                cost = computeCost(it, level),
                                count = 1,
                                materials = buildMaterials(group, level)
                            }
                        )
                    end
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
                    if override.cost ~= nil then
                        craft.cost = math.max(0, tonumber(override.cost) or craft.cost)
                    end

                    if override.recipes ~= nil then
                        local recipes = {}
                        for recipeIndex = 1, #override.recipes do
                            local recipe = override.recipes[recipeIndex]
                            if type(recipe) == "table" then
                                local recipeData = {
                                    cost = math.max(0, tonumber(recipe.cost) or tonumber(override.cost) or tonumber(craft.cost) or 0),
                                    count = math.max(1, tonumber(recipe.count) or tonumber(craft.count) or 1),
                                    materials = {}
                                }

                                for materialIndex = 1, #(recipe.materials or {}) do
                                    local mat = recipe.materials[materialIndex]
                                    local matId = tonumber(mat.id)
                                    local matCount = tonumber(mat.count)
                                    if matId and matId > 0 and matCount and matCount > 0 and itemExists(matId) then
                                        recipeData.materials[#recipeData.materials + 1] = {id = matId, count = matCount}
                                    end
                                end

                                recipes[#recipes + 1] = recipeData
                            end
                        end

                        if #recipes > 0 then
                            craft.recipes = recipes
                            craft.cost = recipes[1].cost
                            craft.count = recipes[1].count
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
    applyOverrideSet(crafts, axeOverrides)
    applyOverrideSet(crafts, swordOverrides)
    applyOverrideSet(crafts, clubOverrides)
    applyOverrideSet(crafts, distanceOverrides)

    local filtered = {}
    for i = 1, #crafts do
        if crafts[i] then
            filtered[#filtered + 1] = crafts[i]
        end
    end
    return filtered
end

local generated = generateWeaponsmithCrafts()
generated = applyManualOverrides(generated)
if #generated > 0 then
    Crafting.weaponsmith = generated
    print(string.format("[CraftingWeaponsmithAuto] generated=%d", #generated))
else
    print("[CraftingWeaponsmithAuto] generated=0 (kept existing weaponsmith list)")
end
