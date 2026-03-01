TaskSystem = {
    monsters = {
        "Amazon", "Ancient Scarab", "Assassin", "Badger", "Bandit", "Banshee", "Bat", "Bear", "Behemoth", "Beholder",
        "Black Knight", "Black Sheep", "Blue Djinn", "Bonebeast", "Bug", "Butterfly", "Butterfly Purple",
        "Butterfly Yellow", "Butterfly Red", "Butterfly Blue", "Carniphila", "Cave Rat", "Centipede", "Chicken",
        "Cobra", "Crab", "Crocodile", "Crypt Shambler", "Cyclops", "Dark Monk", "Deer", "Demon Skeleton", "Demon",
        "Dog", "Dragon Lord", "Dragon", "Dwarf Geomancer", "Dwarf Guard", "Dwarf Soldier", "Dwarf",
        "Dworc Fleshhunter", "Dworc Venomsniper", "Dworc Voodoomaster", "Efreet", "Elder Beholder", "Elephant",
        "Elf Arcanist", "Elf Scout", "Elf", "Fire Devil", "Fire Elemental", "Flamingo", "Frost Troll", "Gargoyle",
        "Gazer", "Ghost", "Ghoul", "Giant Spider", "Goblin", "Green Djinn", "Hero", "Hunter", "Hyaena", "Hydra",
        "Kongra", "Larva", "Lich", "Lion", "Lizard Sentinel", "Lizard Snakecharmer", "Lizard Templar", "Marid",
        "Merlkin", "Minotaur Archer", "Minotaur Guard", "Minotaur Mage", "Minotaur", "Monk", "Mummy",
        "Necromancer", "Orc Berserker", "Orc Leader", "Orc Rider", "Orc Shaman", "Orc Spearman", "Orc Warlord",
        "Orc Warrior", "Orc", "Panda", "Parrot", "Pig", "Poison Spider", "Polar Bear", "Priestess", "Rabbit", "Rat",
        "Rotworm", "Scarab", "Scorpion", "Serpent Spawn", "Sheep", "Sibang", "Skeleton", "Skunk", "Slime2", "Slime",
        "Smuggler", "Snake", "Spider", "Spit Nettle", "Stalker", "Stone Golem", "Swamp Troll", "Tarantula",
        "Terror Bird", "Tiger", "Troll", "Valkyrie", "Vampire", "War Wolf", "Warlock", "Wasp", "Wild Warrior",
        "Winter Wolf", "Witch", "Wolf", "Yeti"
    }
}

TaskSystem.OPCODE_V2 = 110
TaskSystem.activeStorageBase = 1012000
TaskSystem.pointsStorage = 1019000
TaskSystem.config = {
    kills = {Min = 100, Max = 500},
    bonus = 100,
    points = 10,
    exp = 5,
    gold = 5,
    range = 20,
    maxActive = 5,
    rewardPoints = 1
}

TaskSystem.shop = {
    {name = "Gold Coin", id = 2148, count = 100, cost = 1, description = "Currency reward in gold coins."},
    {name = "Platinum Coin", id = 2152, count = 10, cost = 10, description = "Currency reward in platinum coins."},
    {name = "Crystal Coin", id = 2160, count = 1, cost = 100, description = "High-value currency reward in crystal coins."},
    {name = "Mana Fluid", id = 2006, count = 1, cost = 1, fluidType = 7, previewFluidType = 2, description = "Consumable fluid that restores mana when used."},
    {name = "Mana Fluid", id = 2006, count = 5, cost = 5, fluidType = 7, previewFluidType = 2, description = "Consumable fluid that restores mana when used."},
    {name = "Mana Fluid", id = 2006, count = 10, cost = 10, fluidType = 7, previewFluidType = 2, description = "Consumable fluid that restores mana when used."},
    {name = "Mana Fluid", id = 2006, count = 20, cost = 20, fluidType = 7, previewFluidType = 2, bundleContainerId = 2001, bundleCount = 20, description = "Consumable fluid that restores mana when used."},
    {name = "Life Fluid", id = 2006, count = 1, cost = 1, fluidType = 10, previewFluidType = 11, description = "Consumable fluid that restores health when used."},
    {name = "Life Fluid", id = 2006, count = 5, cost = 5, fluidType = 10, previewFluidType = 11, description = "Consumable fluid that restores health when used."},
    {name = "Life Fluid", id = 2006, count = 10, cost = 10, fluidType = 10, previewFluidType = 11, description = "Consumable fluid that restores health when used."},
    {name = "Life Fluid", id = 2006, count = 20, cost = 20, fluidType = 10, previewFluidType = 11, bundleContainerId = 2000, bundleCount = 20, description = "Consumable fluid that restores health when used."},

    -- Others rewards
    {name = "gem bag", id = 6512, count = 1, cost = 5, category = "others", description = "Special bag used for storing gem-type resources."},
    {name = "amulet of loss", id = 2173, count = 1, cost = 5, category = "others", description = "Protects equipped items from dropping on death."},

    -- Game rewards (from task_rewards_game_list.txt)
    {name = "backpack", id = 1988, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "green backpack", id = 1998, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "yellow backpack", id = 1999, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "red backpack", id = 2000, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "purple backpack", id = 2001, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "blue backpack", id = 2002, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "grey backpack", id = 2003, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "golden backpack", id = 2004, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "backpack of holding", id = 2365, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "camouflage backpack", id = 3940, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "old and used backpack", id = 3960, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "explo backpack", id = 5776, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "gfb backpack", id = 5777, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "hmm backpack", id = 5778, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "ih backpack", id = 5779, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "lmm backpack", id = 5780, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "mw backpack", id = 5781, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "sd backpack", id = 5782, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "uh backpack", id = 5783, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "werewolf backpack", id = 5797, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "demon backpack", id = 5813, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "heart backpack", id = 5817, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "crown backpack", id = 5818, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "frosty backpack", id = 5842, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "energy backpack", id = 5843, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "goldenruby backpack", id = 5859, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "War backpack", id = 5954, count = 1, cost = 5, category = "game", description = "Container reward that increases inventory capacity."},

    {name = "torch", id = 2050, count = 1, cost = 5, category = "game", description = "Portable light source for dark areas."},
    {name = "magic lightwand", id = 2162, count = 1, cost = 5, category = "game", description = "Portable light source for dark areas."},

    {name = "pendulum clock", id = 1728, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "cuckoo clock", id = 1877, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "watch", id = 2036, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "rope", id = 2120, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "sickle", id = 2405, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "golden sickle", id = 2418, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "machete", id = 2420, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "scythe", id = 2550, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "pick", id = 2553, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "shovel", id = 2554, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "saw", id = 2558, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "fishing rod", id = 2580, count = 1, cost = 5, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "parchment", id = 4842, count = 1, cost = 5, category = "game", description = "Utility item used in quests or scripted interactions."},
    {name = "life ring", id = 2168, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "ring of healing", id = 2214, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "stealth ring", id = 2165, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "dwarven ring", id = 2213, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "time ring", id = 2169, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "might ring", id = 2164, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "power ring", id = 2166, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "energy ring", id = 2167, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "sword ring", id = 2207, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "axe ring", id = 2208, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "club ring", id = 2209, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "regeneration ring", id = 7089, count = 1, cost = 5, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    -- End game rewards

    -- Creature rewards (auto from task_rewards_creature_trash_loot_report.txt)
    {name = "skull", id = 2229, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "bone", id = 2230, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "grave flower", id = 2747, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "sling herb", id = 2802, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "golden mug", id = 2033, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "talon", id = 2151, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "ankh", id = 2193, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "big bone", id = 2231, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "gemmed book", id = 1976, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "silver brooch", id = 2134, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "strange symbol", id = 2174, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "orb", id = 2176, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "dirty cape", id = 2237, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "small oil lamp", id = 2359, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "shadow herb", id = 2804, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "book", id = 1977, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "purple tome", id = 1982, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "flute", id = 2070, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "scarab coin", id = 2159, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "dirty fur", id = 2220, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "voodoo doll", id = 3955, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "parchment", id = 1967, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "red tome", id = 1986, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "panpipes", id = 2074, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "doll", id = 2110, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "mysterious fetish", id = 2194, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "twigs", id = 2245, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "ancient rune", id = 2348, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "blue note", id = 2349, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "soul ankh", id = 2354, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "mirror", id = 2560, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "simple dress", id = 2657, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "coconut", id = 2678, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "blue rose", id = 2745, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "goat grass", id = 2760, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "powder herb", id = 2803, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "elephant tusk", id = 3956, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "soul orb", id = 6437, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    -- End creature rewards

    -- Craft rewards (upgrade/crafting system items)
    {name = "upgrade crystal", id = 7870, count = 1, cost = 10, category = "craft", description = "Used to upgrade item tier or quality."},
    {name = "enchant crystal", id = 7871, count = 1, cost = 10, category = "craft", description = "Adds or rerolls enchant effects on equipment."},
    {name = "alter crystal", id = 7872, count = 1, cost = 10, category = "craft", description = "Changes selected upgrade or enchant outcome."},
    {name = "cleanse crystal", id = 7873, count = 1, cost = 10, category = "craft", description = "Removes unstable or unwanted modifiers."},
    {name = "fortune crystal", id = 7874, count = 1, cost = 10, category = "craft", description = "Improves success chance during upgrades."},
    {name = "faith crystal", id = 7875, count = 1, cost = 10, category = "craft", description = "Reduces downgrade risk on failed upgrades."},
    {name = "mind crystal", id = 7876, count = 1, cost = 20, category = "craft", description = "High-tier crystal for advanced crafting rolls."},
    {name = "limitless crystal", id = 7877, count = 1, cost = 20, category = "craft", description = "Extends upgrade limits on supported items."},
    {name = "mirrored crystal", id = 7878, count = 1, cost = 20, category = "craft", description = "Copies or mirrors specific item properties."},
    {name = "void crystal", id = 7879, count = 1, cost = 20, category = "craft", description = "Rerolls with high variance and rare outcomes."},
    {name = "upgrade catalyst", id = 7881, count = 1, cost = 15, category = "craft", description = "Catalyst consumed to perform upgrade actions."},
    {name = "crystal extractor", id = 7882, count = 1, cost = 15, category = "craft", description = "Extracts crystal resources from valid items."},
    {name = "crystal fossil", id = 7883, count = 1, cost = 15, category = "craft", description = "Material used in crystal conversion recipes."},
    {name = "identification scroll", id = 7953, count = 1, cost = 15, category = "craft", description = "Identifies unknown rarity and hidden stats."},
    -- End craft rewards

}

TaskSystem.levels = TaskSystem.levels or {}
TaskSystem.levelsMax = TaskSystem.levelsMax or 1
do
    local ok, err = pcall(dofile, "data/lib/task_levels.lua")
    if not ok then
        print("[TaskSystem] task_levels.lua not loaded: " .. tostring(err))
    end
end

TaskSystem.chunkSize = 8000

function TaskSystem.sendChunked(player, opcode, payload)
    if #payload <= TaskSystem.chunkSize then
        player:sendExtendedOpcode(opcode, payload)
        return
    end

    local total = #payload
    local offset = 1
    local first = true
    while offset <= total do
        local chunk = payload:sub(offset, offset + TaskSystem.chunkSize - 1)
        offset = offset + TaskSystem.chunkSize
        local prefix
        if first then
            prefix = "S"
            first = false
        elseif offset > total then
            prefix = "E"
        else
            prefix = "P"
        end
        player:sendExtendedOpcode(opcode, prefix .. chunk)
    end
end

TaskSystem.indexByName = {}
for i, name in ipairs(TaskSystem.monsters) do
    TaskSystem.indexByName[name] = i
end

TaskSystem.displayOrder = {}
for i = 1, #TaskSystem.monsters do
    TaskSystem.displayOrder[i] = i
end

table.sort(TaskSystem.displayOrder, function(a, b)
    local nameA = TaskSystem.monsters[a]
    local nameB = TaskSystem.monsters[b]
    local levelA = TaskSystem.levels[nameA] or 1
    local levelB = TaskSystem.levels[nameB] or 1
    if levelA == levelB then
        return nameA < nameB
    end
    return levelA < levelB
end)

TaskSystem.realToDisplay = {}
for displayTaskId, realTaskId in ipairs(TaskSystem.displayOrder) do
    TaskSystem.realToDisplay[realTaskId] = displayTaskId
end

function TaskSystem.toRealTaskId(displayTaskId)
    return TaskSystem.displayOrder[displayTaskId]
end

function TaskSystem.toDisplayTaskId(realTaskId)
    return TaskSystem.realToDisplay[realTaskId]
end

function TaskSystem.getIndexByName(name)
    return TaskSystem.indexByName[name]
end

function TaskSystem.getStorageKey(index)
    return 1010000 + index
end

function TaskSystem.getActiveStorageKey(index)
    return TaskSystem.activeStorageBase + index
end

function TaskSystem.getPoints(player)
    local points = player:getStorageValue(TaskSystem.pointsStorage)
    if points < 0 then
        points = 0
    end
    return points
end

function TaskSystem.setPoints(player, points)
    player:setStorageValue(TaskSystem.pointsStorage, points)
end

function TaskSystem.addPoints(player, amount)
    TaskSystem.setPoints(player, TaskSystem.getPoints(player) + amount)
end

function TaskSystem.getTaskOutfit(monsterName)
    local monsterType = MonsterType(monsterName)
    if monsterType then
        local outfit = monsterType:outfit()
        if type(outfit) == "table" then
            return {
                type = outfit.lookType or 0,
                typeEx = outfit.lookTypeEx or 0,
                head = outfit.lookHead or 0,
                body = outfit.lookBody or 0,
                legs = outfit.lookLegs or 0,
                feet = outfit.lookFeet or 0,
                addons = outfit.lookAddons or 0,
                mount = outfit.lookMount or 0,
                lookType = outfit.lookType or 0,
                lookTypeEx = outfit.lookTypeEx or 0,
                lookHead = outfit.lookHead or 0,
                lookBody = outfit.lookBody or 0,
                lookLegs = outfit.lookLegs or 0,
                lookFeet = outfit.lookFeet or 0,
                lookAddons = outfit.lookAddons or 0,
                lookMount = outfit.lookMount or 0
            }
        end
    end
    return {
        type = 128,
        lookType = 128
    }
end

function TaskSystem.getTaskHp(monsterName)
    local monsterType = MonsterType(monsterName)
    if monsterType then
        local hp = monsterType:maxHealth()
        if not hp or hp <= 0 then
            hp = monsterType:health()
        end
        return hp or 0
    end
    return 0
end

function TaskSystem.getTaskLevel(monsterName)
    return TaskSystem.levels[monsterName] or 1
end

function TaskSystem.calculateTaskPointsByValues(level, required)
    level = math.max(1, tonumber(level) or 1)
    local minKills = TaskSystem.config.kills.Min or 100
    local maxKills = TaskSystem.config.kills.Max or 500
    local bonusStep = math.max(1, tonumber(TaskSystem.config.bonus) or 100)
    required = math.max(minKills, math.min(maxKills, tonumber(required) or minKills))

    local bonusSteps = math.floor(math.max(0, required - minKills) / bonusStep)
    local basePoints = level
    local total
    local lengthBonusPercent = 0

    if bonusSteps <= 0 then
        total = basePoints
    else
        local lengthMultiplier = 1.1 + (bonusSteps * 0.1) -- 200=>1.2, 300=>1.3, ... 500=>1.5
        local scaled = level * (required / minKills) * lengthMultiplier
        total = math.floor(scaled + 0.5)
        lengthBonusPercent = math.floor(((lengthMultiplier - 1) * 100) + 0.5)
    end

    if total < 1 then
        total = 1
    end

    local bonusPoints = math.max(0, total - basePoints)
    return total, basePoints, bonusPoints, bonusSteps, lengthBonusPercent
end

function TaskSystem.getTaskPoints(taskId, required)
    local name = TaskSystem.monsters[taskId]
    if not name then
        return TaskSystem.config.rewardPoints or 1
    end
    return TaskSystem.calculateTaskPointsByValues(TaskSystem.getTaskLevel(name), required)
end

function TaskSystem.buildTasksCache()
    local tasks = {}
    for displayTaskId, realTaskId in ipairs(TaskSystem.displayOrder) do
        local name = TaskSystem.monsters[realTaskId]
        local rewardPoints = TaskSystem.getTaskPoints(realTaskId, TaskSystem.config.kills.Min)
        local task = {
            taskId = displayTaskId,
            name = name,
            lvl = TaskSystem.getTaskLevel(name),
            hp = TaskSystem.getTaskHp(name),
            mobs = {name},
            outfits = {TaskSystem.getTaskOutfit(name)},
            rewards = {
                {type = 1, value = rewardPoints}
            }
        }
        table.insert(tasks, task)
    end
    return tasks
end

function TaskSystem.getActiveTasks(player)
    local active = {}
    for i = 1, #TaskSystem.monsters do
        local required = player:getStorageValue(TaskSystem.getActiveStorageKey(i))
        if required and required > 0 then
            local kills = player:getStorageValue(TaskSystem.getStorageKey(i))
            if kills < 0 then
                kills = 0
            end
            local displayTaskId = TaskSystem.toDisplayTaskId(i) or i
            table.insert(active, {taskId = displayTaskId, kills = kills, required = required})
        end
    end
    return active
end

function TaskSystem.countActiveTasks(player)
    local count = 0
    for i = 1, #TaskSystem.monsters do
        if player:getStorageValue(TaskSystem.getActiveStorageKey(i)) > 0 then
            count = count + 1
        end
    end
    return count
end

function TaskSystem.sendTaskConfig(player)
    print("[TasksV2] sendTaskConfig to " .. player:getName())
    player:sendExtendedOpcode(TaskSystem.OPCODE_V2, json.encode({action = "config", data = TaskSystem.config}))
end

function TaskSystem.sendTaskList(player)
    local list = TaskSystem.buildTasksCache()
    local ok, payload = pcall(function()
        return json.encode({action = "tasks", data = list})
    end)
    if not ok or type(payload) ~= "string" then
        print("[TasksV2] sendTaskList json error: " .. tostring(payload))
        return
    end
    print("[TasksV2] sendTaskList count=" .. tostring(#list) .. " bytes=" .. tostring(#payload) .. " to " .. player:getName())
    TaskSystem.sendChunked(player, TaskSystem.OPCODE_V2, payload)
end

function TaskSystem.sendTaskActive(player)
    print("[TasksV2] sendTaskActive to " .. player:getName())
    player:sendExtendedOpcode(TaskSystem.OPCODE_V2, json.encode({action = "active", data = TaskSystem.getActiveTasks(player)}))
end

function TaskSystem.sendTaskPoints(player)
    print("[TasksV2] sendTaskPoints to " .. player:getName())
    player:sendExtendedOpcode(TaskSystem.OPCODE_V2, json.encode({action = "points", data = TaskSystem.getPoints(player)}))
end

function TaskSystem.sendTaskShop(player)
    local shopView = {}
    for _, entry in ipairs(TaskSystem.shop) do
        local row = {}
        for k, v in pairs(entry) do
            row[k] = v
        end

        local itemType = ItemType(entry.id)
        local clientId = itemType and itemType:getClientId() or 0
        if clientId and clientId > 0 then
            row.clientId = clientId
        else
            row.clientId = entry.id
        end
        table.insert(shopView, row)
    end

    local ok, payload = pcall(function()
        return json.encode({action = "shop", data = shopView})
    end)
    if not ok or type(payload) ~= "string" then
        print("[TasksV2] sendTaskShop json error: " .. tostring(payload))
        return
    end
    TaskSystem.sendChunked(player, TaskSystem.OPCODE_V2, payload)
end

function TaskSystem.sendAll(player)
    TaskSystem.sendTaskConfig(player)
    TaskSystem.sendTaskList(player)
    TaskSystem.sendTaskShop(player)
    TaskSystem.sendTaskActive(player)
    TaskSystem.sendTaskPoints(player)
end

function TaskSystem.sendTaskUpdate(player, taskId, kills, required, status)
    local displayTaskId = TaskSystem.toDisplayTaskId(taskId) or taskId
    player:sendExtendedOpcode(
        TaskSystem.OPCODE_V2,
        json.encode({action = "update", data = {taskId = displayTaskId, kills = kills, required = required, status = status}})
    )
end

function TaskSystem.startTask(player, taskId, required)
    local minKills = TaskSystem.config.kills.Min or 100
    local maxKills = TaskSystem.config.kills.Max or 500
    local step = math.max(1, tonumber(TaskSystem.config.bonus) or 100)
    required = math.max(minKills, math.min(maxKills, tonumber(required) or minKills))
    required = minKills + math.floor(((required - minKills) / step) + 0.5) * step
    required = math.max(minKills, math.min(maxKills, required))

    player:setStorageValue(TaskSystem.getActiveStorageKey(taskId), required)
    player:setStorageValue(TaskSystem.getStorageKey(taskId), 0)
    TaskSystem.sendTaskUpdate(player, taskId, 0, required, 1)
end

function TaskSystem.cancelTask(player, taskId)
    player:setStorageValue(TaskSystem.getActiveStorageKey(taskId), -1)
    player:setStorageValue(TaskSystem.getStorageKey(taskId), 0)
    TaskSystem.sendTaskUpdate(player, taskId, 0, 0, 2)
end

function TaskSystem.finishTask(player, taskId, required)
    local gained, basePoints, bonusPoints, bonusSteps, lengthBonusPercent = TaskSystem.getTaskPoints(taskId, required)
    TaskSystem.addPoints(player, gained)
    player:setStorageValue(TaskSystem.getActiveStorageKey(taskId), -1)
    player:setStorageValue(TaskSystem.getStorageKey(taskId), 0)
    TaskSystem.sendTaskUpdate(player, taskId, required, required, 2)
    TaskSystem.sendTaskPoints(player)
    player:sendTextMessage(
        MESSAGE_STATUS_CONSOLE_ORANGE,
        string.format(
            "[Tasks] Reward: %d points (base %d + bonus %d, ticks %d, +%d%% chain).",
            gained,
            basePoints,
            bonusPoints,
            bonusSteps,
            lengthBonusPercent
        )
    )
end

function TaskSystem.buyShopItem(player, shopId, amount)
    local entry = TaskSystem.shop[shopId]
    if not entry then
        return false
    end

    amount = tonumber(amount) or 1
    if amount < 1 then
        amount = 1
    elseif amount > 100 then
        amount = 100
    end

    local cost = (entry.cost or 0) * amount
    if cost <= 0 then
        return false
    end

    local points = TaskSystem.getPoints(player)
    if points < cost then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Not enough task points.")
        return false
    end

    local totalCount = (entry.count or 1) * amount
    local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
    if entry.fluidType then
        if entry.bundleContainerId then
            if backpack and backpack:isContainer() and backpack:getEmptySlots(true) < amount then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You don't have enough space in backpack.")
                return false
            end

            local createdBundles = {}
            for _ = 1, amount do
                local bundle
                if backpack and backpack:isContainer() then
                    bundle = backpack:addItem(entry.bundleContainerId, 1)
                else
                    bundle = player:addItem(entry.bundleContainerId, 1, true)
                end

                if not bundle or not bundle:isContainer() then
                    for _, created in ipairs(createdBundles) do
                        if created and not created:isRemoved() then
                            created:remove()
                        end
                    end
                    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Not enough capacity or space.")
                    return false
                end

                local filled = true
                for _ = 1, (entry.bundleCount or 20) do
                    local fluid = bundle:addItem(entry.id, entry.fluidType)
                    if not fluid then
                        filled = false
                        break
                    end
                end

                if not filled then
                    bundle:remove()
                    for _, created in ipairs(createdBundles) do
                        if created and not created:isRemoved() then
                            created:remove()
                        end
                    end
                    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Not enough capacity or space.")
                    return false
                end

                table.insert(createdBundles, bundle)
            end
        else
        if backpack and backpack:isContainer() and backpack:getEmptySlots(true) < totalCount then
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You don't have enough space in backpack.")
            return false
        end

        local added = {}
        for i = 1, totalCount do
            local item
            if backpack and backpack:isContainer() then
                item = backpack:addItem(entry.id, entry.fluidType)
            else
                item = player:addItem(entry.id, entry.fluidType, true)
            end

            if not item then
                for _, created in ipairs(added) do
                    if created and not created:isRemoved() then
                        created:remove()
                    end
                end
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Not enough capacity or space.")
                return false
            end
            table.insert(added, item)
        end
        end
    else
        if backpack and backpack:isContainer() then
            local slots = backpack:getEmptySlots(true)
            if slots <= 0 then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You don't have enough space in backpack.")
                return false
            end
            local item = backpack:addItem(entry.id, totalCount)
            if not item then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Not enough capacity or space.")
                return false
            end
        else
            local item = player:addItem(entry.id, totalCount, true)
            if not item then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Not enough capacity or space.")
                return false
            end
        end
    end

    TaskSystem.setPoints(player, points - cost)
    TaskSystem.sendTaskPoints(player)
    return true
end
