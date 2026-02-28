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

-- Manual axe filters/costs.
-- Rules:
-- 1) Remove from crafting every axe obtainable via monster loot or quest reward.
-- 2) Keep craft-only axes with cost only (recipes will be added later).
local axeOverrides = {
    [2378] = {disabled = true}, -- battle axe (loot/quest)
    [2380] = {disabled = true}, -- hand axe (loot)
    [2381] = {disabled = true}, -- halberd (loot/quest)
    [2386] = {disabled = true}, -- axe (loot)
    [2387] = {disabled = true}, -- double axe (loot)
    [2388] = {disabled = true}, -- hatchet (loot/quest)
    [2405] = {disabled = true}, -- sickle (loot)
    [2414] = {disabled = true}, -- dragon lance (loot/quest)
    [2415] = {cost = 30300}, -- great axe
    [2418] = {disabled = true}, -- golden sickle (loot)
    [2425] = {disabled = true}, -- obsidian lance (loot/quest)
    [2426] = {cost = 30300}, -- naginata (loot/quest)
    [2427] = {disabled = true}, -- guardian halberd (quest)
    [2428] = {disabled = true}, -- orcish axe (loot/quest)
    [2429] = {disabled = true}, -- barbarian axe (loot/quest)
    [2430] = {disabled = true}, -- knight axe (loot/quest)
    [2431] = {cost = 30300}, -- stonecutter axe (quest)
    [2432] = {disabled = true}, -- fire axe (loot/quest)
    [2435] = {disabled = true}, -- dwarven axe (quest)
    [2440] = {disabled = true}, -- daramanian waraxe (loot)
    [2441] = {cost = 6700}, -- daramanian axe
    [2443] = {cost = 30300}, -- ravager's axe (loot/quest)
    [2447] = {cost = 30300}, -- twin axe (loot)
    [2454] = {cost = 25100}, -- war axe
    [2550] = {disabled = true}, -- scythe
    [3962] = {cost = 14100}, -- beastslayer axe
    [3964] = {disabled = true}, -- ripper lance (loot)
    [3965] = {disabled = true}, -- hunting spear (loot)
    [5537] = {cost = 16000}, -- axe of donarion
    [5890] = {cost = 23600}, -- phonic axe
    [5893] = {disabled = true}, -- vampiric axe
    [5903] = {cost = 5700}, -- thornfang axe
    [5904] = {cost = 19900}, -- royal axe
    [5923] = {cost = 4350} -- thornfang axe (variant)
}

-- Manual sword filters/costs.
-- Rules:
-- 1) Remove from crafting every sword obtainable via monster loot or quest reward.
-- 2) Keep craft-only swords with cost only (recipes will be added later).
local swordOverrides = {
    [2376] = {disabled = true}, -- sword (loot)
    [2377] = {disabled = true}, -- two handed sword (loot/quest)
    [2379] = {disabled = true}, -- dagger (loot)
    [2383] = {disabled = true}, -- spike sword (loot/quest)
    [2384] = {disabled = true}, -- rapier (loot/quest)
    [2385] = {disabled = true}, -- sabre (loot)
    [2390] = {cost = 29500}, -- magic longsword
    [2392] = {disabled = true}, -- fire sword (loot/quest)
    [2393] = {disabled = true}, -- giant sword (loot/quest)
    [2395] = {disabled = true}, -- carlin sword (loot/quest)
    [2396] = {disabled = true}, -- ice rapier (loot)
    [2397] = {disabled = true}, -- longsword (loot/quest)
    [2400] = {cost = 29500}, -- magic sword (quest)
    [2402] = {disabled = true}, -- silver dagger (loot/quest)
    [2403] = {disabled = true}, -- knife (loot)
    [2404] = {disabled = true}, -- combat knife (loot/quest)
    [2406] = {disabled = true}, -- short sword (loot)
    [2407] = {disabled = true}, -- bright sword (quest)
    [2408] = {cost = 28300}, -- warlord sword
    [2409] = {disabled = true}, -- serpent sword (loot/quest)
    [2411] = {disabled = true}, -- poison dagger (loot/quest)
    [2412] = {disabled = true}, -- katana (loot/quest)
    [2413] = {disabled = true}, -- broad sword (loot/quest)
    [2419] = {disabled = true}, -- scimitar (loot/quest)
    [2420] = {disabled = true}, -- machete (loot)
    [2438] = {cost = 15050}, -- epee
    [2442] = {disabled = true}, -- heavy machete (loot)
    [2446] = {cost = 15050}, -- pharaoh sword (loot/quest)
    [2450] = {disabled = true}, -- bone sword (loot)
    [2451] = {cost = 15050}, -- djinn blade (loot)
    [3963] = {disabled = true}, -- templar scytheblade (loot)
    [5535] = {cost = 21500}, -- sword of furion
    [5739] = {cost = 15050}, -- ice sword (quest)
    [5755] = {cost = 29500}, -- avenger
    [5898] = {cost = 4350}, -- ice blade
    [5899] = {cost = 17950}, -- rune sword
    [5905] = {cost = 12700}, -- wyvern fang
    [5906] = {cost = 5700} -- blacksteel sword
}

-- Manual club filters/costs.
-- Rules:
-- 1) Remove from crafting every club obtainable via monster loot or quest reward.
-- 2) Keep craft-only clubs with cost only (recipes will be added later).
local clubOverrides = {
    [2321] = {disabled = true}, -- giant smithhammer (quest)
    [2382] = {disabled = true}, -- club (loot)
    [2391] = {disabled = true}, -- war hammer (loot/quest)
    [2394] = {disabled = true}, -- morning star (loot/quest)
    [2398] = {disabled = true}, -- mace (loot)
    [2401] = {disabled = true}, -- staff (loot)
    [2416] = {disabled = true}, -- crowbar (loot)
    [2417] = {disabled = true}, -- battle hammer (loot/quest)
    [2421] = {cost = 16450}, -- thunder hammer (loot)
    [2422] = {disabled = true}, -- iron hammer (quest)
    [2423] = {disabled = true}, -- clerical mace (loot)
    [2424] = {cost = 16450}, -- silver mace
    [2433] = {disabled = true}, -- enchanted staff
    [2434] = {disabled = true}, -- dragon hammer (loot/quest)
    [2436] = {disabled = true}, -- skull staff (loot/quest)
    [2437] = {cost = 18950}, -- golden mace
    [2439] = {disabled = true}, -- daramanian mace (loot)
    [2444] = {disabled = true}, -- hammer of wrath (loot/quest)
    [2445] = {disabled = true}, -- crystal mace (loot)
    [2448] = {disabled = true}, -- studded club (loot)
    [2449] = {disabled = true}, -- bone club (loot)
    [2452] = {cost = 25700}, -- heavy mace
    [2453] = {cost = 26350}, -- arcane staff
    [3966] = {cost = 16450}, -- banana staff (loot)
    [4846] = {cost = 6700}, -- iron hammer (variant)
    [5536] = {cost = 16000}, -- club of dorion
    [5799] = {disabled = true}, -- terra wand
    [5800] = {disabled = true}, -- fire wand
    [5801] = {disabled = true}, -- icy wand
    [5802] = {disabled = true}, -- electric wand (quest)
    [5885] = {disabled = true}, -- ice flail
    [5886] = {disabled = true}, -- abyss club
    [5888] = {disabled = true}, -- death star
    [5889] = {cost = 4350}, -- Spark Hammer
    [5892] = {cost = 4350}, -- hadge hammer
    [5894] = {cost = 16450}, -- Sapphire Axe (loot)
    [5897] = {cost = 4350}, -- squarearth hammer
    [5901] = {cost = 4350}, -- Quara Sceptre
    [5902] = {disabled = true}, -- Destroyer Club
    [7916] = {cost = 16450} -- golden war hammer (loot)
}

-- Manual distance filters/costs.
-- Rules:
-- 1) Remove from crafting every distance weapon obtainable via monster loot or quest reward.
-- 2) Keep craft-only distance weapons with cost only (recipes will be added later).
local distanceOverrides = {
    [1294] = {disabled = true}, -- small stone (loot)
    [2111] = {disabled = true}, -- snowball (loot)
    [2350] = {disabled = true}, -- royal crossbow (loot)
    [2389] = {disabled = true}, -- spear (loot/quest)
    [2399] = {disabled = true}, -- throwing star (loot/quest)
    [2410] = {disabled = true}, -- throwing knife (loot)
    [2455] = {disabled = true}, -- crossbow (loot/quest)
    [2456] = {disabled = true}, -- bow (loot/quest)
    [5754] = {cost = 1250}, -- arbalest
    [5836] = {cost = 20800}, -- assassin star
    [5912] = {cost = 4750}, -- modified crossbow
    [5913] = {cost = 2100}, -- royal crossbow
    [5914] = {cost = 2550}, -- death crossbow
    [5915] = {cost = 1250}, -- composite hornbow
    [5916] = {cost = 2100}, -- earth bow
    [5917] = {cost = 1700} -- ice bow
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
