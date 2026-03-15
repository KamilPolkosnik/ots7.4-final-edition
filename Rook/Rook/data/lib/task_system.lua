TaskSystem = {
    monsters = {
        "Amazon", "Ancient Scarab", "Assassin", "Bandit", "Banshee", "Bat", "Bear", "Behemoth", "Beholder",
        "Black Knight", "Black Sheep", "Blue Djinn", "Bonebeast", "Bug", "Carniphila", "Cave Rat", "Centipede",
        "Chicken", "Cobra", "Crab", "Crocodile", "Crypt Shambler", "Cyclops", "Dark Monk", "Deer", "Demon Skeleton",
        "Demon", "Dog", "Dragon Lord", "Dragon", "Dwarf Geomancer", "Dwarf Guard", "Dwarf Soldier", "Dwarf",
        "Dworc Fleshhunter", "Dworc Venomsniper", "Dworc Voodoomaster", "Efreet", "Elder Beholder", "Elephant",
        "Elf Arcanist", "Elf Scout", "Elf", "Fire Devil", "Fire Elemental", "Frost Troll", "Gargoyle", "Gazer",
        "Ghost", "Ghoul", "Giant Spider", "Goblin", "Green Djinn", "Hero", "Hunter", "Hyaena", "Hydra", "Kongra",
        "Larva", "Lich", "Lion", "Lizard Sentinel", "Lizard Snakecharmer", "Lizard Templar", "Marid", "Merlkin",
        "Minotaur Archer", "Minotaur Guard", "Minotaur Mage", "Minotaur", "Monk", "Mummy", "Necromancer",
        "Orc Berserker", "Orc Leader", "Orc Rider", "Orc Shaman", "Orc Spearman", "Orc Warlord", "Orc Warrior",
        "Orc", "Panda", "Parrot", "Pig", "Poison Spider", "Polar Bear", "Priestess", "Rabbit", "Rat", "Rotworm",
        "Scarab", "Scorpion", "Serpent Spawn", "Sheep", "Sibang", "Skeleton", "Skunk", "Slime", "Smuggler", "Snake",
        "Spider", "Stalker", "Stone Golem", "Swamp Troll", "Tarantula", "Terror Bird", "Tiger", "Troll", "Valkyrie",
        "Vampire", "War Wolf", "Warlock", "Wasp", "Wild Warrior", "Winter Wolf", "Witch", "Wolf"
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
    maxActive = 2,
    rewardPoints = 1,
    daily = {
        count = 3,
        maxActive = 1,
        kills = {Min = 50, Max = 150, Step = 25},
        rewardMultiplier = 2
    },
    weekly = {
        count = 2,
        maxActive = 1,
        kills = {Min = 300, Max = 700, Step = 50},
        rewardMultiplier = 5
    }
}

TaskSystem.taskKinds = {
    normal = "normal",
    daily = "daily",
    weekly = "weekly"
}

TaskSystem.virtualTaskBase = {
    daily = 100000,
    weekly = 200000
}

TaskSystem.rotating = {
    daily = {
        assignmentBase = 1020000,
        progressBase = 1020100,
        requiredBase = 1020200,
        activeBase = 1020300,
        completedBase = 1020400,
        resetStorage = 1020500
    },
    weekly = {
        assignmentBase = 1021000,
        progressBase = 1021100,
        requiredBase = 1021200,
        activeBase = 1021300,
        completedBase = 1021400,
        resetStorage = 1021500
    }
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
    {name = "Life Fluid", id = 2006, count = 8, cost = 5, fluidType = 10, previewFluidType = 11, description = "Consumable fluid that restores health when used."},
    {name = "Life Fluid", id = 2006, count = 16, cost = 10, fluidType = 10, previewFluidType = 11, description = "Consumable fluid that restores health when used."},
    {name = "Life Fluid", id = 2006, count = 20, cost = 16, fluidType = 10, previewFluidType = 11, bundleContainerId = 2001, bundleCount = 20, description = "Consumable fluid that restores health when used."},

    -- Rune rewards
    {name = "blank rune", id = 2260, count = 20, cost = 2, category = "runes", bundleContainerId = 1988, bundleCount = 20, bundleItemCount = 0, description = "20 blank runes packed in a backpack."},
    {name = "heavy magic missile rune", id = 2311, count = 20, cost = 12, category = "runes", bundleContainerId = 1988, bundleCount = 20, bundleItemCount = 0, description = "20 heavy magic missile runes packed in a backpack."},
    {name = "great fireball rune", id = 2304, count = 20, cost = 18, category = "runes", bundleContainerId = 1988, bundleCount = 20, bundleItemCount = 0, description = "20 great fireball runes packed in a backpack."},
    {name = "explosion rune", id = 2313, count = 20, cost = 26, category = "runes", bundleContainerId = 1988, bundleCount = 20, bundleItemCount = 0, description = "20 explosion runes packed in a backpack."},
    {name = "sudden death rune", id = 2268, count = 20, cost = 39, category = "runes", bundleContainerId = 1988, bundleCount = 20, bundleItemCount = 0, description = "20 sudden death runes packed in a backpack."},
    {name = "ultimate healing rune", id = 2273, count = 20, cost = 16, category = "runes", bundleContainerId = 1988, bundleCount = 20, bundleItemCount = 0, description = "20 ultimate healing runes packed in a backpack."},
    {name = "intense healing rune", id = 2265, count = 20, cost = 7, category = "runes", bundleContainerId = 1988, bundleCount = 20, bundleItemCount = 0, description = "20 intense healing runes packed in a backpack."},
    {name = "fireball rune", id = 2302, count = 20, cost = 7, category = "runes", bundleContainerId = 1988, bundleCount = 20, bundleItemCount = 0, description = "20 fireball runes packed in a backpack."},

    -- Others rewards
    {name = "gem bag", id = 6512, count = 1, cost = 190, category = "others", description = "Special bag used for storing gem-type resources."},
    {name = "amulet of loss", id = 2173, count = 1, cost = 490, category = "others", description = "Protects equipped items from dropping on death."},
    {name = "blessing scroll", id = 5542, count = 1, cost = 490, category = "others", description = "Grants all 5 blessings immediately."},
    {name = "stone skin amulet", id = 2197, count = 1, cost = 240, category = "others", description = "Defensive amulet that helps absorb incoming damage."},
    {name = "experience booster", id = 5540, count = 1, cost = 1000, category = "others", description = "Grants 30% extra experience for 1 hour when used."},

    -- Game rewards (from task_rewards_game_list.txt)
    {name = "backpack", id = 1988, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "green backpack", id = 1998, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "yellow backpack", id = 1999, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "red backpack", id = 2000, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "purple backpack", id = 2001, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "blue backpack", id = 2002, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "grey backpack", id = 2003, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "golden backpack", id = 2004, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "backpack of holding", id = 2365, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "old and used backpack", id = 3960, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "explo backpack", id = 5776, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "gfb backpack", id = 5777, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "hmm backpack", id = 5778, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "ih backpack", id = 5779, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "lmm backpack", id = 5780, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "mw backpack", id = 5781, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "sd backpack", id = 5782, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "uh backpack", id = 5783, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "werewolf backpack", id = 5797, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "demon backpack", id = 5813, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "heart backpack", id = 5817, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "crown backpack", id = 5818, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "frosty backpack", id = 5842, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "energy backpack", id = 5843, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "goldenruby backpack", id = 5859, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "War backpack", id = 5954, count = 1, cost = 1, category = "game", description = "Container reward that increases inventory capacity."},
    {name = "torch", id = 2050, count = 1, cost = 1, category = "game", description = "Portable light source for dark areas."},
    {name = "magic lightwand", id = 2162, count = 1, cost = 2, category = "game", description = "Portable light source for dark areas."},
    {name = "watch", id = 2036, count = 1, cost = 1, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "rope", id = 2120, count = 1, cost = 1, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "sickle", id = 2405, count = 1, cost = 1, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "machete", id = 2420, count = 1, cost = 1, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "scythe", id = 2550, count = 1, cost = 1, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "pick", id = 2553, count = 1, cost = 1, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "shovel", id = 2554, count = 1, cost = 1, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "saw", id = 2558, count = 1, cost = 1, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "fishing rod", id = 2580, count = 1, cost = 1, category = "game", description = "Utility tool used for world interactions and exploration."},
    {name = "life ring", id = 2168, count = 1, cost = 8, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "ring of healing", id = 2214, count = 1, cost = 19, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "stealth ring", id = 2165, count = 1, cost = 49, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "dwarven ring", id = 2213, count = 1, cost = 19, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "time ring", id = 2169, count = 1, cost = 19, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "might ring", id = 2164, count = 1, cost = 240, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "power ring", id = 2166, count = 1, cost = 1, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "energy ring", id = 2167, count = 1, cost = 19, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "sword ring", id = 2207, count = 1, cost = 4, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "axe ring", id = 2208, count = 1, cost = 4, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "club ring", id = 2209, count = 1, cost = 4, category = "game", description = "Ring equipment with temporary or passive bonuses."},
    {name = "distance ring", id = 7954, count = 1, cost = 4, category = "game", description = "Ring equipment with temporary or passive bonuses."},

    -- End game rewards

    -- Creature rewards not currently dropped by any monster
    {name = "flute", id = 2070, count = 1, cost = 5, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "parchment", id = 1967, count = 1, cost = 10, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    {name = "soul ankh", id = 2354, count = 1, cost = 20, category = "creature", description = "Creature loot material used for trade, tasks, or crafting."},
    -- End creature rewards

    -- Craft rewards (upgrade/crafting system items)
    {name = "upgrade crystal", id = 7870, count = 1, cost = 140, category = "craft", description = "You can use this on an item to upgrade its level"},
    {name = "enchant crystal", id = 7871, count = 1, cost = 50, category = "craft", description = "Can be used on a piece of equipment to add random attribute."},
    {name = "alter crystal", id = 7872, count = 1, cost = 50, category = "craft", description = "Can be used on a piece of equipment to remove last attribute."},
    {name = "cleanse crystal", id = 7873, count = 1, cost = 70, category = "craft", description = "Can be used on a piece of equipment to remove all attributes."},
    {name = "fortune crystal", id = 7874, count = 1, cost = 50, category = "craft", description = "Can be used on a piece of equipment to change value of last attribute."},
    {name = "faith crystal", id = 7875, count = 1, cost = 100, category = "craft", description = "Can be used on a piece of equipment to change values of all attributes."},
    {name = "mind crystal", id = 7876, count = 1, cost = 100, category = "craft", description = "Can be used to extract all attributes and values and store in that crystal. Can be used again to place these attributes to a new item. Lower item rarity will remove exceeded attributes."},
    {name = "limitless crystal", id = 7877, count = 1, cost = 500, category = "craft", description = "Can be used to remove Item Level requirement to equip given item."},
    {name = "void crystal", id = 7879, count = 1, cost = 100, category = "craft", description = "Can be used to transform item into random Unique type."},
    {name = "crystal extractor", id = 7882, count = 1, cost = 500, category = "craft", description = "Can be used to extract rare crystals from crystal fossil."},
    {name = "crystal fossil", id = 7883, count = 1, cost = 50, category = "craft", description = "There is unknown crystal inside, try to use crystal extractor."},
    {name = "identification scroll", id = 7953, count = 1, cost = 20, category = "craft", description = "Can be used to identify an item, revealing its attributes and values."},
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

function TaskSystem.encodeTaskId(kind, reference)
    if kind == TaskSystem.taskKinds.daily or kind == TaskSystem.taskKinds.weekly then
        return (TaskSystem.virtualTaskBase[kind] or 0) + reference
    end
    return TaskSystem.toDisplayTaskId(reference) or reference
end

function TaskSystem.decodeTaskId(taskId)
    taskId = tonumber(taskId)
    if not taskId then
        return nil
    end

    if taskId >= TaskSystem.virtualTaskBase.weekly then
        return TaskSystem.taskKinds.weekly, taskId - TaskSystem.virtualTaskBase.weekly
    end

    if taskId >= TaskSystem.virtualTaskBase.daily then
        return TaskSystem.taskKinds.daily, taskId - TaskSystem.virtualTaskBase.daily
    end

    return TaskSystem.taskKinds.normal, TaskSystem.toRealTaskId(taskId)
end

function TaskSystem.getRotatingStorageKey(kind, storageName, slot)
    local cfg = TaskSystem.rotating[kind]
    if not cfg or not cfg[storageName] then
        return nil
    end
    if storageName == "resetStorage" then
        return cfg.resetStorage
    end
    return cfg[storageName] + slot
end

function TaskSystem.getRotatingValue(player, kind, storageName, slot)
    local key = TaskSystem.getRotatingStorageKey(kind, storageName, slot)
    if not key then
        return -1
    end
    local value = player:getStorageValue(key)
    if value < 0 then
        return -1
    end
    return value
end

function TaskSystem.setRotatingValue(player, kind, storageName, slot, value)
    local key = TaskSystem.getRotatingStorageKey(kind, storageName, slot)
    if key then
        player:setStorageValue(key, value)
    end
end

function TaskSystem.getPeriodWindow(kind, now)
    local date = os.date("*t", now or os.time())
    date.hour = 0
    date.min = 0
    date.sec = 0

    if kind == TaskSystem.taskKinds.weekly then
        local daysSinceMonday = (date.wday + 5) % 7
        date.day = date.day - daysSinceMonday
        local startAt = os.time(date)
        return startAt, startAt + (7 * 24 * 60 * 60)
    end

    local startAt = os.time(date)
    return startAt, startAt + (24 * 60 * 60)
end

function TaskSystem.getRotatingConfig(kind)
    return TaskSystem.config[kind]
end

local function roundToStep(value, minimum, maximum, step)
    step = math.max(1, tonumber(step) or 1)
    minimum = tonumber(minimum) or step
    maximum = tonumber(maximum) or minimum
    value = tonumber(value) or minimum
    value = minimum + math.floor(((value - minimum) / step) + 0.5) * step
    if value < minimum then
        value = minimum
    elseif value > maximum then
        value = maximum
    end
    return value
end

local function buildTaskPayload(taskId, name, rewardPoints, kind, extra)
    local task = {
        taskId = taskId,
        kind = kind or TaskSystem.taskKinds.normal,
        name = name,
        lvl = TaskSystem.getTaskLevel(name),
        hp = TaskSystem.getTaskHp(name),
        mobs = {name},
        outfits = {TaskSystem.getTaskOutfit(name)},
        rewards = {
            {type = 1, value = rewardPoints}
        }
    }

    if extra then
        for key, value in pairs(extra) do
            task[key] = value
        end
    end

    return task
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

local function resolveMonsterType(monsterName)
    if not monsterName or monsterName == "" then
        return nil
    end

    local monsterType = MonsterType(monsterName)
    if monsterType then
        return monsterType
    end

    local lower = monsterName:lower()
    if lower ~= monsterName then
        monsterType = MonsterType(lower)
        if monsterType then
            return monsterType
        end
    end

    local title = monsterName:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
    if title ~= monsterName then
        monsterType = MonsterType(title)
        if monsterType then
            return monsterType
        end
    end

    return nil
end

local function trimString(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalizeMonsterKey(value)
    return trimString(value):lower()
end

local function buildOutfitTable(lookType, lookTypeEx, lookHead, lookBody, lookLegs, lookFeet, lookAddons, lookMount)
    lookType = tonumber(lookType) or 0
    lookTypeEx = tonumber(lookTypeEx) or 0
    lookHead = tonumber(lookHead) or 0
    lookBody = tonumber(lookBody) or 0
    lookLegs = tonumber(lookLegs) or 0
    lookFeet = tonumber(lookFeet) or 0
    lookAddons = tonumber(lookAddons) or 0
    lookMount = tonumber(lookMount) or 0

    return {
        type = lookType,
        typeEx = lookTypeEx,
        head = lookHead,
        body = lookBody,
        legs = lookLegs,
        feet = lookFeet,
        addons = lookAddons,
        mount = lookMount,
        lookType = lookType,
        lookTypeEx = lookTypeEx,
        lookHead = lookHead,
        lookBody = lookBody,
        lookLegs = lookLegs,
        lookFeet = lookFeet,
        lookAddons = lookAddons,
        lookMount = lookMount
    }
end

local function cloneOutfit(outfit)
    if not outfit then
        return nil
    end

    local copy = {}
    for key, value in pairs(outfit) do
        copy[key] = value
    end
    return copy
end

local function parseOutfitFromLookAttributes(lookAttributes)
    if type(lookAttributes) ~= "string" or lookAttributes == "" then
        return nil
    end

    local attrs = {}
    for key, value in lookAttributes:gmatch("([%w_]+)%s*=%s*\"([^\"]*)\"") do
        attrs[key] = value
    end

    local lookType = tonumber(attrs.type) or tonumber(attrs.lookType) or 0
    local lookTypeEx = tonumber(attrs.typeEx) or tonumber(attrs.lookTypeEx) or 0
    if lookType == 0 and lookTypeEx == 0 then
        return nil
    end

    return buildOutfitTable(
        lookType,
        lookTypeEx,
        attrs.head or attrs.lookHead,
        attrs.body or attrs.lookBody,
        attrs.legs or attrs.lookLegs,
        attrs.feet or attrs.lookFeet,
        attrs.addons or attrs.lookAddons,
        attrs.mount or attrs.lookMount
    )
end

local monsterFileByName = nil
local monsterOutfitByFile = {}
local monsterOutfitByName = {}

local function ensureMonsterFileIndex()
    if monsterFileByName then
        return
    end

    monsterFileByName = {}

    local file = io.open("data/monster/monsters.xml", "r")
    if not file then
        return
    end

    local content = file:read("*a") or ""
    file:close()

    for name, path in content:gmatch("<monster%s+name=\"([^\"]+)\"%s+file=\"([^\"]+)\"%s*/>") do
        local key = normalizeMonsterKey(name)
        if key ~= "" and path ~= "" then
            monsterFileByName[key] = path
        end
    end

    for path, name in content:gmatch("<monster%s+file=\"([^\"]+)\"%s+name=\"([^\"]+)\"%s*/>") do
        local key = normalizeMonsterKey(name)
        if key ~= "" and path ~= "" and not monsterFileByName[key] then
            monsterFileByName[key] = path
        end
    end
end

local function getTaskOutfitFromXml(monsterName)
    local key = normalizeMonsterKey(monsterName)
    if key == "" then
        return nil
    end

    local cached = monsterOutfitByName[key]
    if cached ~= nil then
        return cached ~= false and cloneOutfit(cached) or nil
    end

    ensureMonsterFileIndex()
    local relativePath = monsterFileByName and monsterFileByName[key] or nil
    if not relativePath then
        monsterOutfitByName[key] = false
        return nil
    end

    local fileKey = normalizeMonsterKey(relativePath)
    local fileCached = monsterOutfitByFile[fileKey]
    if fileCached == nil then
        local path = "data/monster/" .. relativePath
        local monsterFile = io.open(path, "r")
        local parsedOutfit = nil

        if monsterFile then
            local xml = monsterFile:read("*a") or ""
            monsterFile:close()
            local lookAttributes = xml:match("<look%s+([^>]-)/>")
            if not lookAttributes then
                lookAttributes = xml:match("<look%s+([^>]-)>")
            end
            parsedOutfit = parseOutfitFromLookAttributes(lookAttributes)
        end

        monsterOutfitByFile[fileKey] = parsedOutfit or false
        fileCached = monsterOutfitByFile[fileKey]
    end

    if fileCached and fileCached ~= false then
        monsterOutfitByName[key] = fileCached
        return cloneOutfit(fileCached)
    end

    monsterOutfitByName[key] = false
    return nil
end

function TaskSystem.getTaskOutfit(monsterName)
    local xmlOutfit = getTaskOutfitFromXml(monsterName)
    if xmlOutfit then
        return xmlOutfit
    end

    local monsterType = resolveMonsterType(monsterName)
    if monsterType then
        local outfit = monsterType:outfit()
        if type(outfit) == "table" then
            return buildOutfitTable(
                outfit.lookType or outfit.type,
                outfit.lookTypeEx or outfit.typeEx,
                outfit.lookHead or outfit.head,
                outfit.lookBody or outfit.body,
                outfit.lookLegs or outfit.legs,
                outfit.lookFeet or outfit.feet,
                outfit.lookAddons or outfit.addons,
                outfit.lookMount or outfit.mount
            )
        end
    end
    return {
        type = 128,
        lookType = 128
    }
end

function TaskSystem.getTaskHp(monsterName)
    local monsterType = resolveMonsterType(monsterName)
    if monsterType then
        local hp = monsterType:maxHealth()
        if not hp or hp <= 0 then
            hp = monsterType:health()
        end
        return hp or 0
    end
    return 0
end

function TaskSystem.getTaskExp(monsterName)
    local monsterType = resolveMonsterType(monsterName)
    if not monsterType then
        return 0
    end

    local exp = 0
    if monsterType.getExperience then
        exp = monsterType:getExperience() or 0
    elseif monsterType.experience then
        exp = monsterType:experience() or 0
    end

    exp = math.floor(tonumber(exp) or 0)
    if exp < 0 then
        exp = 0
    end
    return exp
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

function TaskSystem.getRotatingTaskReward(kind, taskId, required)
    local multiplier = 1
    local kindConfig = TaskSystem.getRotatingConfig(kind)
    if kindConfig and kindConfig.rewardMultiplier then
        multiplier = kindConfig.rewardMultiplier
    end

    local total = TaskSystem.getTaskPoints(taskId, required)
    total = math.floor((tonumber(total) or 1) * multiplier + 0.5)
    if total < 1 then
        total = 1
    end
    return total
end

local function buildRandomTaskCandidates(player, exclude)
    local candidates = {}
    local playerLevel = player:getLevel()
    local allowedRange = math.max(10, (TaskSystem.config.range or 20) * 2)

    for realTaskId = 1, #TaskSystem.monsters do
        if not exclude[realTaskId] then
            local monsterName = TaskSystem.monsters[realTaskId]
            local taskLevel = TaskSystem.getTaskLevel(monsterName)
            if math.abs(taskLevel - playerLevel) <= allowedRange then
                table.insert(candidates, realTaskId)
            end
        end
    end

    if #candidates == 0 then
        for realTaskId = 1, #TaskSystem.monsters do
            if not exclude[realTaskId] then
                table.insert(candidates, realTaskId)
            end
        end
    end

    return candidates
end

function TaskSystem.generateRotatingAssignments(player, kind)
    local kindConfig = TaskSystem.getRotatingConfig(kind)
    if not kindConfig then
        return
    end

    local periodStart = TaskSystem.getPeriodWindow(kind)
    TaskSystem.setRotatingValue(player, kind, "resetStorage", nil, periodStart)

    local exclude = {}
    local otherKind = kind == TaskSystem.taskKinds.daily and TaskSystem.taskKinds.weekly or TaskSystem.taskKinds.daily
    local otherConfig = TaskSystem.getRotatingConfig(otherKind)
    if otherConfig then
        for slot = 1, otherConfig.count do
            local otherTaskId = TaskSystem.getRotatingValue(player, otherKind, "assignmentBase", slot)
            if otherTaskId and otherTaskId > 0 then
                exclude[otherTaskId] = true
            end
        end
    end

    local candidates = buildRandomTaskCandidates(player, exclude)
    for i = #candidates, 2, -1 do
        local j = math.random(i)
        candidates[i], candidates[j] = candidates[j], candidates[i]
    end

    for slot = 1, kindConfig.count do
        local realTaskId = candidates[slot] or -1
        TaskSystem.setRotatingValue(player, kind, "assignmentBase", slot, realTaskId)
        TaskSystem.setRotatingValue(player, kind, "progressBase", slot, 0)
        TaskSystem.setRotatingValue(player, kind, "activeBase", slot, -1)
        TaskSystem.setRotatingValue(player, kind, "completedBase", slot, -1)

        if realTaskId > 0 then
            local required = roundToStep(
                math.random(kindConfig.kills.Min, kindConfig.kills.Max),
                kindConfig.kills.Min,
                kindConfig.kills.Max,
                kindConfig.kills.Step
            )
            TaskSystem.setRotatingValue(player, kind, "requiredBase", slot, required)
        else
            TaskSystem.setRotatingValue(player, kind, "requiredBase", slot, -1)
        end
    end
end

function TaskSystem.ensureRotatingTasks(player, kind)
    local kindConfig = TaskSystem.getRotatingConfig(kind)
    if not kindConfig then
        return
    end

    local currentPeriodStart = TaskSystem.getPeriodWindow(kind)
    local storedPeriodStart = TaskSystem.getRotatingValue(player, kind, "resetStorage")
    if storedPeriodStart ~= currentPeriodStart then
        TaskSystem.generateRotatingAssignments(player, kind)
    end
end

function TaskSystem.buildRotatingTasks(player, kind)
    TaskSystem.ensureRotatingTasks(player, kind)

    local kindConfig = TaskSystem.getRotatingConfig(kind)
    if not kindConfig then
        return {}
    end

    local _, resetAt = TaskSystem.getPeriodWindow(kind)
    local tasks = {}

    for slot = 1, kindConfig.count do
        local realTaskId = TaskSystem.getRotatingValue(player, kind, "assignmentBase", slot)
        if realTaskId and realTaskId > 0 then
            local required = math.max(1, TaskSystem.getRotatingValue(player, kind, "requiredBase", slot))
            local progress = math.max(0, TaskSystem.getRotatingValue(player, kind, "progressBase", slot))
            local active = TaskSystem.getRotatingValue(player, kind, "activeBase", slot) > 0
            local completed = TaskSystem.getRotatingValue(player, kind, "completedBase", slot) > 0
            local name = TaskSystem.monsters[realTaskId]
            local rewardPoints = TaskSystem.getRotatingTaskReward(kind, realTaskId, required)

            table.insert(tasks, buildTaskPayload(TaskSystem.encodeTaskId(kind, slot), name, rewardPoints, kind, {
                fixedKills = true,
                required = required,
                progress = progress,
                active = active,
                completed = completed,
                resetAt = resetAt
            }))
        end
    end

    return tasks
end

function TaskSystem.buildTasksCache()
    local tasks = {}
    for displayTaskId, realTaskId in ipairs(TaskSystem.displayOrder) do
        local name = TaskSystem.monsters[realTaskId]
        local rewardPoints = TaskSystem.getTaskPoints(realTaskId, TaskSystem.config.kills.Min)
        table.insert(tasks, buildTaskPayload(displayTaskId, name, rewardPoints, TaskSystem.taskKinds.normal))
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
            table.insert(active, {taskId = displayTaskId, kills = kills, required = required, kind = TaskSystem.taskKinds.normal})
        end
    end

    for _, kind in ipairs({TaskSystem.taskKinds.daily, TaskSystem.taskKinds.weekly}) do
        TaskSystem.ensureRotatingTasks(player, kind)
        local kindConfig = TaskSystem.getRotatingConfig(kind)
        for slot = 1, kindConfig.count do
            local activeFlag = TaskSystem.getRotatingValue(player, kind, "activeBase", slot)
            if activeFlag > 0 then
                local required = math.max(1, TaskSystem.getRotatingValue(player, kind, "requiredBase", slot))
                local kills = math.max(0, TaskSystem.getRotatingValue(player, kind, "progressBase", slot))
                table.insert(active, {
                    taskId = TaskSystem.encodeTaskId(kind, slot),
                    kills = kills,
                    required = required,
                    kind = kind
                })
            end
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

function TaskSystem.countActiveTasksByKind(player, kind)
    if kind == TaskSystem.taskKinds.normal then
        return TaskSystem.countActiveTasks(player)
    end

    TaskSystem.ensureRotatingTasks(player, kind)
    local kindConfig = TaskSystem.getRotatingConfig(kind)
    local count = 0
    for slot = 1, kindConfig.count do
        if TaskSystem.getRotatingValue(player, kind, "activeBase", slot) > 0 then
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
    local daily = TaskSystem.buildRotatingTasks(player, TaskSystem.taskKinds.daily)
    local weekly = TaskSystem.buildRotatingTasks(player, TaskSystem.taskKinds.weekly)
    for _, entry in ipairs(daily) do
        table.insert(list, entry)
    end
    for _, entry in ipairs(weekly) do
        table.insert(list, entry)
    end
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
    local encodedTaskId = taskId
    local kind = TaskSystem.taskKinds.normal
    if type(taskId) == "table" then
        kind = taskId.kind or TaskSystem.taskKinds.normal
        encodedTaskId = taskId.taskId
    elseif type(taskId) == "number" then
        encodedTaskId = TaskSystem.toDisplayTaskId(taskId) or taskId
    end
    player:sendExtendedOpcode(
        TaskSystem.OPCODE_V2,
        json.encode({action = "update", data = {taskId = encodedTaskId, kills = kills, required = required, status = status, kind = kind}})
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

function TaskSystem.startRotatingTask(player, kind, slot)
    TaskSystem.ensureRotatingTasks(player, kind)

    local realTaskId = TaskSystem.getRotatingValue(player, kind, "assignmentBase", slot)
    local required = TaskSystem.getRotatingValue(player, kind, "requiredBase", slot)
    if realTaskId < 1 or required < 1 then
        return false
    end

    if TaskSystem.getRotatingValue(player, kind, "completedBase", slot) > 0 then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "This task has already been completed for the current period.")
        return false
    end

    if TaskSystem.getRotatingValue(player, kind, "activeBase", slot) > 0 then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "This task is already active.")
        return false
    end

    TaskSystem.setRotatingValue(player, kind, "activeBase", slot, 1)
    TaskSystem.setRotatingValue(player, kind, "progressBase", slot, 0)
    TaskSystem.sendTaskUpdate(player, {taskId = TaskSystem.encodeTaskId(kind, slot), kind = kind}, 0, required, 1)
    return true
end

function TaskSystem.cancelTask(player, taskId)
    player:setStorageValue(TaskSystem.getActiveStorageKey(taskId), -1)
    player:setStorageValue(TaskSystem.getStorageKey(taskId), 0)
    TaskSystem.sendTaskUpdate(player, taskId, 0, 0, 2)
end

function TaskSystem.cancelRotatingTask(player, kind, slot)
    TaskSystem.ensureRotatingTasks(player, kind)
    TaskSystem.setRotatingValue(player, kind, "activeBase", slot, -1)
    TaskSystem.setRotatingValue(player, kind, "progressBase", slot, 0)
    TaskSystem.sendTaskUpdate(player, {taskId = TaskSystem.encodeTaskId(kind, slot), kind = kind}, 0, 0, 2)
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

function TaskSystem.finishRotatingTask(player, kind, slot, realTaskId, required)
    local gained = TaskSystem.getRotatingTaskReward(kind, realTaskId, required)
    TaskSystem.addPoints(player, gained)
    TaskSystem.setRotatingValue(player, kind, "activeBase", slot, -1)
    TaskSystem.setRotatingValue(player, kind, "completedBase", slot, 1)
    TaskSystem.setRotatingValue(player, kind, "progressBase", slot, required)
    TaskSystem.sendTaskUpdate(player, {taskId = TaskSystem.encodeTaskId(kind, slot), kind = kind}, required, required, 2)
    TaskSystem.sendTaskList(player)
    TaskSystem.sendTaskPoints(player)
    player:sendTextMessage(
        MESSAGE_STATUS_CONSOLE_ORANGE,
        string.format("[%s Tasks] Reward: %d points.", kind:gsub("^%l", string.upper), gained)
    )
end

function TaskSystem.handleKill(player, targetName)
    local monsterIndex = TaskSystem.getIndexByName(targetName)
    if not monsterIndex then
        return
    end

    local required = player:getStorageValue(TaskSystem.getActiveStorageKey(monsterIndex))
    if required and required > 0 then
        local key = TaskSystem.getStorageKey(monsterIndex)
        local killCount = player:getStorageValue(key)
        if killCount < 0 then
            killCount = 0
        end

        killCount = killCount + 1
        player:setStorageValue(key, killCount)
        TaskSystem.sendTaskUpdate(player, monsterIndex, killCount, required, 1)

        if killCount >= required then
            TaskSystem.finishTask(player, monsterIndex, required)
        end
    end

    for _, kind in ipairs({TaskSystem.taskKinds.daily, TaskSystem.taskKinds.weekly}) do
        TaskSystem.ensureRotatingTasks(player, kind)
        local kindConfig = TaskSystem.getRotatingConfig(kind)
        for slot = 1, kindConfig.count do
            if TaskSystem.getRotatingValue(player, kind, "activeBase", slot) > 0 then
                local realTaskId = TaskSystem.getRotatingValue(player, kind, "assignmentBase", slot)
                if realTaskId == monsterIndex then
                    local progress = math.max(0, TaskSystem.getRotatingValue(player, kind, "progressBase", slot)) + 1
                    local rotatingRequired = math.max(1, TaskSystem.getRotatingValue(player, kind, "requiredBase", slot))
                    TaskSystem.setRotatingValue(player, kind, "progressBase", slot, progress)
                    TaskSystem.sendTaskUpdate(player, {taskId = TaskSystem.encodeTaskId(kind, slot), kind = kind}, progress, rotatingRequired, 1)
                    if progress >= rotatingRequired then
                        TaskSystem.finishRotatingTask(player, kind, slot, realTaskId, rotatingRequired)
                    end
                end
            end
        end
    end
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
        if entry.bundleContainerId then
            if backpack and backpack:isContainer() and backpack:getEmptySlots(true) < amount then
                player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You don't have enough space in backpack.")
                return false
            end

            local createdBundles = {}
            local bundleCount = math.max(1, tonumber(entry.bundleCount) or tonumber(entry.count) or 1)
            local bundleItemCount = nil
            if entry.bundleItemCount ~= nil then
                bundleItemCount = tonumber(entry.bundleItemCount)
                if bundleItemCount == nil then
                    bundleItemCount = 1
                end
            end

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
                for _ = 1, bundleCount do
                    local bundledItem
                    if bundleItemCount ~= nil then
                        bundledItem = bundle:addItem(entry.id, bundleItemCount)
                    else
                        bundledItem = bundle:addItem(entry.id, 1)
                    end
                    if not bundledItem then
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
            if backpack and backpack:isContainer() then
                local slots = backpack:getEmptySlots(true)
                if slots <= 0 then
                    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You don't have enough space in backpack.")
                    return false
                end
            end

            local perPurchaseCount = entry.count or 1
            local itemType = ItemType(entry.id)
            local isStackable = itemType and itemType:isStackable() or false

            if isStackable then
                local remaining = perPurchaseCount * amount
                local requiredStacks = math.max(1, math.ceil(remaining / 100))
                if backpack and backpack:isContainer() and backpack:getEmptySlots(true) < requiredStacks then
                    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You don't have enough space in backpack.")
                    return false
                end

                local added = {}
                while remaining > 0 do
                    local stackCount = math.min(100, remaining)
                    local item
                    if backpack and backpack:isContainer() then
                        item = backpack:addItem(entry.id, stackCount)
                    else
                        item = player:addItem(entry.id, stackCount, true)
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
                    remaining = remaining - stackCount
                end
            else
                for _ = 1, amount do
                    local item
                    if backpack and backpack:isContainer() then
                        item = backpack:addItem(entry.id, perPurchaseCount)
                    else
                        item = player:addItem(entry.id, perPurchaseCount, true)
                    end

                    if not item then
                        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Not enough capacity or space.")
                        return false
                    end
                end
            end
        end
    end

    TaskSystem.setPoints(player, points - cost)
    TaskSystem.sendTaskPoints(player)
    return true
end

