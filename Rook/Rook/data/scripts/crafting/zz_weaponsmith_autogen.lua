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

-- Manual axe recipes from weapon_recipe_source_report.txt (lines 1-118).
-- Only these axe ids are overridden; all other weapons keep auto-generated data.
local axeOverrides = {
    [2405] = {cost = 500, materials = {}}, -- sickle
    [2550] = {cost = 100, materials = {{id = 2405, count = 1}}}, -- scythe
    [2380] = {cost = 50, materials = {{id = 2666, count = 5}, {id = 2512, count = 1}}}, -- hand axe
    [2386] = {cost = 100, materials = {{id = 2511, count = 1}}}, -- axe
    [2418] = {materials = {{id = 2405, count = 1}, {id = 2033, count = 100}}}, -- golden sickle
    [2388] = {materials = {{id = 2386, count = 1}, {id = 2230, count = 10}}}, -- hatchet
    [2441] = {cost = 1000, materials = {{id = 2388, count = 1}, {id = 2512, count = 1}, {id = 2230, count = 10}}}, -- daramanian axe
    [2428] = {cost = 1000, materials = {{id = 2441, count = 1}}}, -- orcish axe
    [2378] = {cost = 1000, materials = {{id = 2428, count = 1}}}, -- battle axe
    [2429] = {cost = 1000, materials = {{id = 2378, count = 3}, {id = 2482, count = 5}}}, -- barbarian axe (studded helmet)
    [3964] = {cost = 1000, materials = {{id = 3965, count = 10}}}, -- ripper lance
    [2435] = {cost = 10000, materials = {{id = 2525, count = 100}}}, -- dwarven axe
    [3965] = {cost = 200, materials = {{id = 2389, count = 1}, {id = 2411, count = 1}}}, -- hunting spear
    [2430] = {cost = 5000, materials = {{id = 2144, count = 10}, {id = 2463, count = 2}, {id = 2429, count = 5}}}, -- knight axe
    [2432] = {cost = 10000, materials = {{id = 2147, count = 50}, {id = 2430, count = 1}}}, -- fire axe
    [2425] = {cost = 3000, materials = {{id = 2429, count = 1}}}, -- obsidian lance
    [2387] = {materials = {{id = 2378, count = 5}, {id = 2513, count = 1}}}, -- double axe
    [2381] = {materials = {{id = 2387, count = 5}, {id = 2513, count = 2}}}, -- halberd
    [2440] = {cost = 3000, materials = {{id = 2381, count = 5}}}, -- daramanian waraxe
    [2426] = {cost = 3000, materials = {{id = 2425, count = 5}}}, -- naginata
    [2427] = {cost = 20000, materials = {{id = 2381, count = 20}, {id = 2426, count = 20}}}, -- guardian halberd
    [2431] = {materials = {{id = 2400, count = 1}}}, -- stonecutter axe
    [2414] = {materials = {{id = 2427, count = 5}, {id = 2426, count = 5}}}, -- dragon lance
    [5923] = {cost = 10000, materials = {{id = 2151, count = 20}}}, -- Thornfang Axe
    [3962] = {materials = {{id = 2378, count = 30}}}, -- beastslayer axe
    [5537] = {cost = 20000, materials = {{id = 2435, count = 5}}}, -- axe of donarion
    [5904] = {cost = 50000, materials = {{id = 5537, count = 10}}}, -- royal axe
    [2443] = {cost = 55000, materials = {{id = 5904, count = 5}}}, -- ravager's axe
    [2447] = {cost = 10000, materials = {{id = 2427, count = 2}}}, -- twin axe
    [5893] = { -- Vampiric Axe
        cost = 1000000,
        materials = {
            {id = 2443, count = 5},
            {id = 2431, count = 1},
            {id = 2144, count = 100},
            {id = 2147, count = 100},
            {id = 2149, count = 100},
            {id = 2466, count = 20}
        }
    },
    [2454] = { -- war axe
        cost = 200000,
        materials = {
            {id = 2441, count = 100},
            {id = 2472, count = 5},
            {id = 2151, count = 100}
        }
    },
    [2415] = { -- great axe
        cost = 2000000,
        materials = {
            {id = 2431, count = 5}, -- stonecutter axe
            {id = 5893, count = 1}, -- vampiric axe
            {id = 7879, count = 5}, -- void crystal
            {id = 7872, count = 5}, -- alter crystal
            {id = 2348, count = 5}, -- ancient rune
            {id = 2158, count = 100} -- blue gem
        }
    },
    [5890] = { -- Phonic Axe
        cost = 2000000,
        materials = {
            {id = 2431, count = 5}, -- stonecutter axe
            {id = 5893, count = 1}, -- vampiric axe
            {id = 7879, count = 5}, -- void crystal
            {id = 7872, count = 5}, -- alter crystal
            {id = 2348, count = 5}, -- ancient rune
            {id = 2158, count = 100} -- blue gem
        }
    }
}

-- Manual sword recipes from weapon_recipe_source_report.txt (up to line 148).
local swordOverrides = {
    [2403] = {cost = 500, materials = {}}, -- knife
    [2404] = {cost = 100, materials = {{id = 2403, count = 1}}}, -- combat knife
    [2379] = {cost = 50, materials = {{id = 2512, count = 1}}}, -- dagger
    [2402] = {cost = 6400, materials = {{id = 2379, count = 1}, {id = 2033, count = 100}}}, -- silver dagger
    [2384] = {cost = 50, materials = {{id = 2671, count = 5}, {id = 2512, count = 1}}}, -- rapier
    [2406] = {cost = 100, materials = {{id = 2511, count = 1}}}, -- short sword
    [2420] = {disabled = true}, -- machete
    [2385] = {cost = 100, materials = {{id = 2406, count = 1}}}, -- sabre
    [2450] = {cost = 500, materials = {{id = 2385, count = 3}, {id = 2230, count = 10}}}, -- bone sword
    [2376] = {cost = 10, materials = {{id = 2230, count = 10}}}, -- sword
    [2395] = {disabled = true}, -- carlin sword
    [2442] = {cost = 500, materials = {{id = 2420, count = 1}, {id = 2230, count = 10}}}, -- heavy machete
    [2412] = {cost = 500}, -- katana
    [2397] = {cost = 1000, materials = {{id = 2412, count = 1}, {id = 2512, count = 1}, {id = 2230, count = 10}}}, -- longsword
    [2411] = {materials = {{id = 2379, count = 1}, {id = 2149, count = 5}}}, -- poison dagger
    [2419] = {cost = 1000, materials = {{id = 2397, count = 1}}}, -- scimitar
    [3963] = {cost = 1000, materials = {{id = 2419, count = 1}}}, -- templar scytheblade
    [2383] = {cost = 1000, materials = {{id = 2412, count = 1}, {id = 2419, count = 2}}}, -- spike sword
    [2409] = {cost = 1000, materials = {{id = 2412, count = 1}, {id = 2419, count = 2}}}, -- serpent sword
    [2413] = {cost = 500}, -- broad sword
    [5905] = {cost = 10000, materials = {{id = 2525, count = 100}}}, -- wyvern fang
    [2377] = {cost = 1000, materials = {{id = 2385, count = 10}}}, -- two handed sword
    [2392] = {cost = 10000, materials = {{id = 2409, count = 2}, {id = 2383, count = 2}, {id = 2147, count = 45}}}, -- fire sword
    [5739] = {disabled = true}, -- ice sword (quest)
    [2407] = {cost = 20000, materials = {{id = 5905, count = 5}}}, -- bright sword
    [2438] = {cost = 30000, materials = {{id = 2392, count = 1}, {id = 2144, count = 10}}}, -- epee
    [2451] = {cost = 30000, materials = {{id = 2392, count = 1}, {id = 2144, count = 10}, {id = 2147, count = 5}, {id = 2149, count = 5}, {id = 2146, count = 5}}}, -- djinn blade
    [2446] = {cost = 3000, materials = {{id = 2451, count = 1}, {id = 2229, count = 50}, {id = 2147, count = 10}, {id = 2149, count = 10}, {id = 2146, count = 10}}}, -- pharaoh sword
    [5899] = {cost = 20000, materials = {{id = 2407, count = 10}}}, -- rune sword
    [2400] = {cost = 51000, materials = {{id = 2431, count = 1}}}, -- magic sword
    [2393] = {cost = 200000, materials = {{id = 2151, count = 100}, {id = 2472, count = 5}, {id = 2420, count = 100}}}, -- giant sword
    [5535] = {cost = 50000, materials = {{id = 5899, count = 10}}}, -- sword of furion
    [5755] = {disabled = true}, -- avenger
    [2396] = {cost = 5000, materials = {{id = 2384, count = 1}}}, -- ice rapier
    [5898] = {cost = 5000, materials = {{id = 2396, count = 10}}}, -- Ice Blade
    [5906] = {cost = 20000, materials = {{id = 5898, count = 5}, {id = 2396, count = 10}}}, -- Blacksteel sword
    [2390] = { -- magic longsword = great axe recipe
        cost = 2000000,
        materials = {
            {id = 2400, count = 5},
            {id = 2408, count = 1},
            {id = 7879, count = 5},
            {id = 7872, count = 5},
            {id = 2348, count = 5},
            {id = 2158, count = 100}
        }
    },
    [2408] = { -- warlord sword = vampiric axe recipe
        cost = 1000000,
        materials = {
            {id = 5535, count = 5},
            {id = 2400, count = 1},
            {id = 2144, count = 100},
            {id = 2147, count = 100},
            {id = 2149, count = 100},
            {id = 2466, count = 20}
        }
    }
}

-- Manual club recipes from weapon_recipe_source_report.txt (up to line 168).
local clubOverrides = {
    [2416] = {cost = 500, materials = {}}, -- crowbar
    [2382] = {cost = 100, materials = {{id = 2416, count = 1}}}, -- club
    [2448] = {cost = 50, materials = {{id = 2512, count = 1}}}, -- studded club
    [2401] = {cost = 50, materials = {{id = 2674, count = 5}, {id = 2512, count = 1}}}, -- staff
    [2449] = {cost = 500, materials = {{id = 2448, count = 1}, {id = 2230, count = 10}}}, -- bone club
    [5888] = {cost = 5000, materials = {{id = 2434, count = 5}}}, -- death star
    [5892] = {cost = 10000, materials = {{id = 2525, count = 100}}}, -- hadge hammer
    [5901] = {cost = 30000, materials = {{id = 2417, count = 30}}}, -- Quara Sceptre
    [5889] = { -- Spark Hammer = magic longsword recipe
        cost = 2000000,
        materials = {
            {id = 2452, count = 5},
            {id = 2421, count = 1},
            {id = 7879, count = 5},
            {id = 7872, count = 5},
            {id = 2348, count = 5},
            {id = 2158, count = 100}
        }
    },
    [5897] = {cost = 50000, materials = {{id = 5536, count = 10}}}, -- squarearth hammer
    [2398] = {cost = 10, materials = {{id = 2230, count = 10}}}, -- mace
    [2422] = {disabled = true}, -- iron hammer (remove from craft)
    [2439] = {cost = 1000, materials = {{id = 2398, count = 2}, {id = 2512, count = 1}, {id = 2230, count = 10}}}, -- daramanian mace
    [2417] = {cost = 1000, materials = {{id = 2394, count = 1}}}, -- battle hammer
    [2321] = {disabled = true}, -- giant smithhammer (remove from craft)
    [3966] = {materials = {{id = 2676, count = 100}, {id = 2394, count = 1}}}, -- banana staff
    [2394] = {cost = 1000, materials = {{id = 2439, count = 1}, {id = 2512, count = 10}, {id = 2230, count = 10}}}, -- morning star
    [2423] = {cost = 1000, materials = {{id = 2417, count = 2}, {id = 2439, count = 1}}}, -- clerical mace
    [2434] = {cost = 5000, materials = {{id = 2423, count = 4}}}, -- dragon hammer
    [5902] = {cost = 5000, materials = {{id = 2434, count = 5}}}, -- Destroyer Club
    [2436] = {cost = 10000, materials = {{id = 2229, count = 20}, {id = 2230, count = 10}, {id = 2434, count = 1}}}, -- skull staff
    [2445] = {cost = 10000, materials = {{id = 2436, count = 1}, {id = 2158, count = 2}}}, -- crystal mace
    [5536] = {cost = 20000, materials = {{id = 5892, count = 5}}}, -- club of dorion
    [5885] = {cost = 30000, materials = {{id = 2434, count = 1}, {id = 2391, count = 1}, {id = 2144, count = 10}, {id = 2147, count = 5}, {id = 2149, count = 5}, {id = 2146, count = 20}}}, -- ice flail
    [5894] = {disabled = true}, -- Sapphire Ace (remove from craft)
    [2424] = {materials = {{id = 2401, count = 1}, {id = 2391, count = 1}}}, -- silver mace
    [2433] = {cost = 5000, materials = {{id = 2401, count = 10}, {id = 2417, count = 10}}}, -- enchanted staff
    [5886] = {cost = 200000, materials = {{id = 2151, count = 100}, {id = 2472, count = 5}, {id = 2398, count = 100}}}, -- abyss club
    [2444] = {cost = 100000, materials = {{id = 5886, count = 1}, {id = 2151, count = 100}}}, -- hammer of wrath
    [2421] = { -- thunder hammer = warlord sword recipe
        cost = 1000000,
        materials = {
            {id = 5897, count = 5},
            {id = 2452, count = 1},
            {id = 2144, count = 100},
            {id = 2147, count = 100},
            {id = 2149, count = 100},
            {id = 2466, count = 20}
        }
    },
    [2391] = {cost = 5000, materials = {{id = 2229, count = 30}, {id = 2434, count = 1}}}, -- war hammer
    [2452] = {cost = 200000, materials = {{id = 2444, count = 1}, {id = 2149, count = 10}, {id = 2472, count = 5}}}, -- heavy mace
    [2453] = {disabled = true}, -- arcane staff (remove from craft)
    [7916] = {cost = 100000, materials = {{id = 2391, count = 5}, {id = 7876, count = 1}}} -- golden war hammer
}

-- Manual distance recipes.
local distanceOverrides = {
    [2456] = {cost = 600, materials = {{id = 2544, count = 100}}}, -- bow
    [2455] = {cost = 600, materials = {{id = 2543, count = 100}}}, -- crossbow
    [5912] = { -- modified crossbow
        cost = 10000,
        materials = {
            {id = 2455, count = 10},
            {id = 2456, count = 10},
            {id = 2151, count = 10},
            {id = 2389, count = 10},
            {id = 5836, count = 5},
            {id = 1294, count = 100}
        }
    },
    [5913] = {disabled = true}, -- royal crossbow
    [2350] = {disabled = true}, -- royal crossbow (duplicate name variant)
    [2111] = {disabled = true}, -- snowball
    [1294] = {disabled = true}, -- small stone
    [5754] = {disabled = true}, -- arbalest
    [5915] = {cost = 30000, materials = {{id = 2456, count = 10}}}, -- composite hornbow
    [5917] = {cost = 30000, materials = {{id = 5915, count = 1}, {id = 2456, count = 10}}}, -- ice bow
    [5916] = {cost = 30000, materials = {{id = 5917, count = 1}, {id = 5915, count = 1}, {id = 2456, count = 10}}}, -- earth bow
    [5914] = {cost = 100000, materials = {{id = 5912, count = 10}, {id = 2268, count = 100}, {id = 5836, count = 100}}}, -- death crossbow
    [2389] = {disabled = true}, -- spear
    [2410] = {cost = 500, materials = {{id = 2403, count = 1}}}, -- throwing knife
    [2399] = {cost = 500, materials = {{id = 2410, count = 1}, {id = 2380, count = 1}}}, -- throwing star
    [5836] = {cost = 1000, materials = {{id = 2399, count = 1}, {id = 2151, count = 5}, {id = 2033, count = 1}}} -- assassin star
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

                    if override.materials ~= nil then
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
