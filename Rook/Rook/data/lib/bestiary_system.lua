BestiarySystem = BestiarySystem or {}

BestiarySystem.OPCODE = 112
BestiarySystem.killStorageBase = 1320000
BestiarySystem.bonusStorageBase = 1330000
BestiarySystem.respecCost = 5000
BestiarySystem.thresholds = {1000, 2000, 3000, 5000, 8000}
BestiarySystem.tierPercents = {2, 4, 6, 8, 10}
BestiarySystem.thresholdsByMonsterName = {
    ["amazon"] = {200, 400, 800, 1600, 3200},
    ["ancient scarab"] = {450, 900, 1800, 3600, 7200},
    ["ancien scarab"] = {450, 900, 1800, 3600, 7200}, -- alias for typo
    ["assassin"] = {350, 700, 1400, 2800, 5600},
    ["bandit"] = {300, 600, 1200, 2400, 4800},
    ["banshee"] = {450, 900, 1800, 3600, 7200},
    ["bat"] = {15, 30, 60, 120, 240},
    ["bear"] = {20, 40, 80, 160, 320},
    ["behemoth"] = {600, 1200, 2400, 4800, 9600},
    ["beholder"] = {320, 640, 1280, 2560, 5120},
    ["black knight"] = {500, 1000, 2000, 4000, 8000},
    ["black sheep"] = {5, 10, 20, 40, 80},
    ["blue djinn"] = {400, 800, 1600, 3200, 6400},
    ["bonebeast"] = {450, 900, 1800, 3600, 7200},
    ["bug"] = {15, 30, 60, 120, 240},
    ["carniphila"] = {350, 700, 1400, 2800, 5600},
    ["cave rat"] = {15, 30, 60, 120, 240},
    ["centipede"] = {200, 400, 800, 1600, 3200},
    ["chicken"] = {5, 10, 20, 40, 80},
    ["cobra"] = {60, 120, 240, 480, 960},
    ["crab"] = {20, 40, 80, 160, 320},
    ["crocodile"] = {250, 500, 1000, 2000, 4000},
    ["crypt shambler"] = {350, 700, 1400, 2800, 5600},
    ["cyclops"] = {320, 640, 1280, 2560, 5120},
    ["dark monk"] = {350, 700, 1400, 2800, 5600},
    ["deer"] = {5, 10, 20, 40, 80},
    ["demon skeleton"] = {400, 800, 1600, 3200, 6400},
    ["demon"] = {625, 1250, 2500, 5000, 10000},
    ["dog"] = {5, 10, 20, 40, 80},
    ["dragon lord"] = {500, 1000, 2000, 4000, 8000},
    ["dragon"] = {450, 900, 1800, 3600, 7200},
    ["dwarf geomancer"] = {400, 800, 1600, 3200, 6400},
    ["dwarf guard"] = {350, 700, 1400, 2800, 5600},
    ["dwarf soldier"] = {300, 600, 1200, 2400, 4800},
    ["dwarf"] = {200, 400, 800, 1600, 3200},
    ["dworc fleshhunter"] = {200, 400, 800, 1600, 3200},
    ["dworc venomsniper"] = {80, 160, 320, 640, 1280},
    ["dworc voodoomaster"] = {200, 400, 800, 1600, 3200},
    ["efreet"] = {450, 900, 1800, 3600, 7200},
    ["elder beholder"] = {400, 800, 1600, 3200, 6400},
    ["elephant"] = {350, 700, 1400, 2800, 5600},
    ["elf arcanist"] = {350, 700, 1400, 2800, 5600},
    ["elf scout"] = {300, 600, 1200, 2400, 4800},
    ["elf"] = {200, 400, 800, 1600, 3200},
    ["fire devil"] = {300, 600, 1200, 2400, 4800},
    ["fire elemental"] = {350, 700, 1400, 2800, 5600},
    ["frost troll"] = {60, 120, 240, 480, 960},
    ["gargoyle"] = {350, 700, 1400, 2800, 5600},
    ["gazer"] = {250, 500, 1000, 2000, 4000},
    ["ghost"] = {300, 600, 1200, 2400, 4800},
    ["ghoul"] = {300, 600, 1200, 2400, 4800},
    ["giant spider"] = {450, 900, 1800, 3600, 7200},
    ["goblin"] = {60, 120, 240, 480, 960},
    ["green djinn"] = {400, 800, 1600, 3200, 6400},
    ["hero"] = {500, 1000, 2000, 4000, 8000},
    ["hunter"] = {300, 600, 1200, 2400, 4800},
    ["hyaena"] = {60, 120, 240, 480, 960},
    ["hayena"] = {60, 120, 240, 480, 960}, -- alias for typo
    ["hydra"] = {500, 1000, 2000, 4000, 8000},
    ["kongra"] = {320, 640, 1280, 2560, 5120},
    ["larva"] = {200, 400, 800, 1600, 3200},
    ["lich"] = {450, 900, 1800, 3600, 7200},
    ["lion"] = {20, 40, 80, 160, 320},
    ["lizard sentinel"] = {320, 640, 1280, 2560, 5120},
    ["lizard snakecharmer"] = {350, 700, 1400, 2800, 5600},
    ["lizard templar"] = {350, 700, 1400, 2800, 5600},
    ["marid"] = {450, 900, 1800, 3600, 7200},
    ["merlkin"] = {300, 600, 1200, 2400, 4800},
    ["minotaur archer"] = {300, 600, 1200, 2400, 4800},
    ["minotaur guard"] = {320, 640, 1280, 2560, 5120},
    ["minotaur mage"] = {300, 600, 1200, 2400, 4800},
    ["minotaur"] = {250, 500, 1000, 2000, 4000},
    ["monk"] = {350, 700, 1400, 2800, 5600},
    ["mummy"] = {350, 700, 1400, 2800, 5600},
    ["necromancer"] = {400, 800, 1600, 3200, 6400},
    ["orc berserker"] = {350, 700, 1400, 2800, 5600},
    ["orc leader"] = {400, 800, 1600, 3200, 6400},
    ["orc rider"] = {350, 700, 1400, 2800, 5600},
    ["orc shaman"] = {300, 600, 1200, 2400, 4800},
    ["orc spearman"] = {250, 500, 1000, 2000, 4000},
    ["orc warlord"] = {450, 900, 1800, 3600, 7200},
    ["orc warrior"] = {300, 600, 1200, 2400, 4800},
    ["orc"] = {80, 160, 320, 640, 1280},
    ["panda"] = {80, 160, 320, 640, 1280},
    ["parrot"] = {5, 10, 20, 40, 80},
    ["pig"] = {5, 10, 20, 40, 80},
    ["poison spider"] = {15, 30, 60, 120, 240},
    ["polar bear"] = {20, 40, 80, 160, 320},
    ["priestess"] = {400, 800, 1600, 3200, 6400},
    ["rabbit"] = {5, 10, 20, 40, 80},
    ["rat"] = {15, 30, 60, 120, 240},
    ["rotworm"] = {200, 400, 800, 1600, 3200},
    ["scarab"] = {350, 700, 1400, 2800, 5600},
    ["scorpion"] = {80, 160, 320, 640, 1280},
    ["serpent spawn"] = {500, 1000, 2000, 4000, 8000},
    ["sheep"] = {5, 10, 20, 40, 80},
    ["sibang"] = {320, 640, 1280, 2560, 5120},
    ["skeleton"] = {200, 400, 800, 1600, 3200},
    ["skunk"] = {5, 10, 20, 40, 80},
    ["slime"] = {300, 600, 1200, 2400, 4800},
    ["smuggler"] = {250, 500, 1000, 2000, 4000},
    ["snake"] = {15, 30, 60, 120, 240},
    ["spider"] = {15, 30, 60, 120, 240},
    ["stalker"] = {300, 600, 1200, 2400, 4800},
    ["stone golem"] = {350, 700, 1400, 2800, 5600},
    ["swamp troll"] = {60, 120, 240, 480, 960},
    ["tarantula"] = {350, 700, 1400, 2800, 5600},
    ["terror bird"] = {350, 700, 1400, 2800, 5600},
    ["tiger"] = {20, 40, 80, 160, 320},
    ["troll"] = {60, 120, 240, 480, 960},
    ["valkyrie"] = {300, 600, 1200, 2400, 4800},
    ["vampire"] = {400, 800, 1600, 3200, 6400},
    ["war wolf"] = {300, 600, 1200, 2400, 4800},
    ["warlock"] = {600, 1200, 2400, 4800, 9600},
    ["wasp"] = {60, 120, 240, 480, 960},
    ["wild warrior"] = {300, 600, 1200, 2400, 4800},
    ["winter wolf"] = {20, 40, 80, 160, 320},
    ["witch"] = {350, 700, 1400, 2800, 5600},
    ["wolf"] = {20, 40, 80, 160, 320}
}
BestiarySystem.thresholdsByIndex = nil

BestiarySystem.bonusTypes = {
    physical = {id = 1, label = "Physical", combatType = COMBAT_PHYSICALDAMAGE},
    fire = {id = 2, label = "Fire", combatType = COMBAT_FIREDAMAGE},
    poison = {id = 3, label = "Poison", combatType = COMBAT_EARTHDAMAGE},
    energy = {id = 4, label = "Energy", combatType = COMBAT_ENERGYDAMAGE},
    death = {id = 5, label = "Death", combatType = COMBAT_DEATHDAMAGE}
}

BestiarySystem.bonusById = {}
for key, info in pairs(BestiarySystem.bonusTypes) do
    BestiarySystem.bonusById[info.id] = {key = key, label = info.label, combatType = info.combatType}
end

BestiarySystem.lowerIndexByName = nil

function BestiarySystem.ensureLowerIndex()
    if BestiarySystem.lowerIndexByName then
        return
    end

    BestiarySystem.lowerIndexByName = {}
    if not TaskSystem or not TaskSystem.monsters then
        return
    end

    for index, name in ipairs(TaskSystem.monsters) do
        BestiarySystem.lowerIndexByName[name:lower()] = index
    end
end

function BestiarySystem.resolveMonsterIndex(monsterName)
    if type(monsterName) ~= "string" or monsterName == "" then
        return nil
    end

    monsterName = monsterName:gsub("^%s+", ""):gsub("%s+$", "")
    if monsterName == "" then
        return nil
    end

    if TaskSystem and TaskSystem.getIndexByName then
        local direct = TaskSystem.getIndexByName(monsterName)
        if direct then
            return direct
        end

        local lower = monsterName:lower()
        if lower ~= monsterName then
            direct = TaskSystem.getIndexByName(lower)
            if direct then
                return direct
            end
        end
    end

    BestiarySystem.ensureLowerIndex()
    if not BestiarySystem.lowerIndexByName then
        return nil
    end

    return BestiarySystem.lowerIndexByName[monsterName:lower()]
end

function BestiarySystem.getKillStorage(index)
    return BestiarySystem.killStorageBase + index
end

function BestiarySystem.getBonusStorage(index)
    return BestiarySystem.bonusStorageBase + index
end

function BestiarySystem.getKills(player, index)
    local value = player:getStorageValue(BestiarySystem.getKillStorage(index))
    if value < 0 then
        return 0
    end
    return value
end

function BestiarySystem.setKills(player, index, value)
    player:setStorageValue(BestiarySystem.getKillStorage(index), math.max(0, math.floor(tonumber(value) or 0)))
end

local function normalizeMonsterName(value)
    local name = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then
        return ""
    end
    return name:lower()
end

local function stripArticles(nameLower)
    if nameLower:sub(1, 2) == "a " then
        return nameLower:sub(3)
    end
    if nameLower:sub(1, 3) == "an " then
        return nameLower:sub(4)
    end
    if nameLower:sub(1, 4) == "the " then
        return nameLower:sub(5)
    end
    return nameLower
end

function BestiarySystem.ensureThresholdIndex()
    if BestiarySystem.thresholdsByIndex then
        return
    end

    BestiarySystem.thresholdsByIndex = {}
    if not TaskSystem or not TaskSystem.monsters then
        return
    end

    for index, monsterName in ipairs(TaskSystem.monsters) do
        local key = normalizeMonsterName(monsterName)
        local custom = BestiarySystem.thresholdsByMonsterName[key]
        if type(custom) == "table" and #custom > 0 then
            BestiarySystem.thresholdsByIndex[index] = custom
        end
    end
end

function BestiarySystem.getThresholdsForIndex(index)
    local defaultThresholds = BestiarySystem.thresholds
    if not TaskSystem or not TaskSystem.monsters then
        return defaultThresholds
    end

    BestiarySystem.ensureThresholdIndex()
    local customByIndex = BestiarySystem.thresholdsByIndex and BestiarySystem.thresholdsByIndex[index] or nil
    if type(customByIndex) == "table" and #customByIndex > 0 then
        return customByIndex
    end

    local monsterName = TaskSystem.monsters[index]
    if type(monsterName) ~= "string" or monsterName == "" then
        return defaultThresholds
    end

    local custom = BestiarySystem.thresholdsByMonsterName[normalizeMonsterName(monsterName)]
    if type(custom) ~= "table" or #custom <= 0 then
        return defaultThresholds
    end

    return custom
end

function BestiarySystem.getFirstThreshold(index)
    local list = BestiarySystem.getThresholdsForIndex(index)
    return tonumber(list and list[1]) or 1000
end

function BestiarySystem.getTierPercentValue(tierIndex)
    tierIndex = math.max(0, math.floor(tonumber(tierIndex) or 0))
    if tierIndex <= 0 then
        return 0
    end

    local configured = BestiarySystem.tierPercents and BestiarySystem.tierPercents[tierIndex]
    if configured and configured > 0 then
        return math.floor(configured)
    end

    return tierIndex * 2
end

function BestiarySystem.getBonusTierPercent(kills, index)
    local count = math.floor(tonumber(kills) or 0)
    local thresholdList = BestiarySystem.getThresholdsForIndex(index)
    local tierIndex = 0
    for i = 1, #thresholdList do
        if count >= thresholdList[i] then
            tierIndex = i
        else
            break
        end
    end
    return BestiarySystem.getTierPercentValue(tierIndex)
end

function BestiarySystem.getProgressData(kills, index)
    local count = math.max(0, math.floor(tonumber(kills) or 0))
    local currentThreshold = 0
    local thresholdList = BestiarySystem.getThresholdsForIndex(index)

    for tierIndex, threshold in ipairs(thresholdList) do
        if count < threshold then
            local range = threshold - currentThreshold
            local progressPercent = 0
            if range > 0 then
                progressPercent = math.floor(((count - currentThreshold) * 100) / range)
            end
            if progressPercent < 0 then
                progressPercent = 0
            elseif progressPercent > 100 then
                progressPercent = 100
            end

            return {
                currentThreshold = currentThreshold,
                nextThreshold = threshold,
                nextBonusPercent = BestiarySystem.getTierPercentValue(tierIndex),
                progressPercent = progressPercent,
                isMaxTier = false
            }
        end
        currentThreshold = threshold
    end

    local maxThreshold = thresholdList[#thresholdList] or 0
    return {
        currentThreshold = maxThreshold,
        nextThreshold = maxThreshold,
        nextBonusPercent = BestiarySystem.getBonusTierPercent(count, index),
        progressPercent = 100,
        isMaxTier = true
    }
end

function BestiarySystem.getBestiaryLevel(kills, index)
    local count = math.max(0, math.floor(tonumber(kills) or 0))
    local thresholdList = BestiarySystem.getThresholdsForIndex(index)
    local level = 1

    for tierIndex, threshold in ipairs(thresholdList) do
        if count >= threshold then
            level = math.min(5, tierIndex + 1)
        else
            break
        end
    end

    if level < 1 then
        level = 1
    elseif level > 5 then
        level = 5
    end

    return level
end

function BestiarySystem.getSelectedBonusId(player, index)
    local value = tonumber(player:getStorageValue(BestiarySystem.getBonusStorage(index))) or -1
    if value < 1 then
        return 0
    end
    if not BestiarySystem.bonusById[value] then
        return 0
    end
    return value
end

function BestiarySystem.setSelectedBonusId(player, index, bonusId)
    bonusId = tonumber(bonusId) or 0
    if bonusId <= 0 then
        player:setStorageValue(BestiarySystem.getBonusStorage(index), -1)
        return
    end
    player:setStorageValue(BestiarySystem.getBonusStorage(index), bonusId)
end

function BestiarySystem.getSelectedBonusKey(player, index)
    local bonusId = BestiarySystem.getSelectedBonusId(player, index)
    local info = BestiarySystem.bonusById[bonusId]
    return info and info.key or ""
end

function BestiarySystem.getSelectedCombatType(player, index)
    local bonusId = BestiarySystem.getSelectedBonusId(player, index)
    local info = BestiarySystem.bonusById[bonusId]
    return info and info.combatType or nil
end

function BestiarySystem.toDisplayTaskId(realTaskId)
    if TaskSystem and TaskSystem.toDisplayTaskId then
        return TaskSystem.toDisplayTaskId(realTaskId) or realTaskId
    end
    return realTaskId
end

function BestiarySystem.toRealTaskId(displayTaskId)
    if TaskSystem and TaskSystem.toRealTaskId then
        return TaskSystem.toRealTaskId(displayTaskId)
    end
    return displayTaskId
end

function BestiarySystem.makeRow(player, realTaskId)
    local name = TaskSystem and TaskSystem.monsters and TaskSystem.monsters[realTaskId] or nil
    if not name then
        return nil
    end

    local kills = BestiarySystem.getKills(player, realTaskId)
    local tierPercent = BestiarySystem.getBonusTierPercent(kills, realTaskId)
    local bestiaryLevel = BestiarySystem.getBestiaryLevel(kills, realTaskId)
    local bonusType = BestiarySystem.getSelectedBonusKey(player, realTaskId)
    local progress = BestiarySystem.getProgressData(kills, realTaskId)

    return {
        taskId = BestiarySystem.toDisplayTaskId(realTaskId),
        name = name,
        kills = kills,
        bonusPercent = tierPercent,
        bonusType = bonusType,
        level = bestiaryLevel,
        hp = TaskSystem and TaskSystem.getTaskHp and TaskSystem.getTaskHp(name) or 0,
        exp = TaskSystem and TaskSystem.getTaskExp and TaskSystem.getTaskExp(name) or 0,
        outfit = TaskSystem and TaskSystem.getTaskOutfit and TaskSystem.getTaskOutfit(name) or nil,
        currentThreshold = progress.currentThreshold,
        nextThreshold = progress.nextThreshold,
        nextBonusPercent = progress.nextBonusPercent,
        progressPercent = progress.progressPercent,
        isMaxTier = progress.isMaxTier
    }
end

function BestiarySystem.buildSnapshot(player)
    local list = {}
    if not TaskSystem or not TaskSystem.monsters then
        return list
    end

    if TaskSystem.displayOrder then
        for _, realTaskId in ipairs(TaskSystem.displayOrder) do
            local row = BestiarySystem.makeRow(player, realTaskId)
            if row then
                table.insert(list, row)
            end
        end
    else
        for realTaskId = 1, #TaskSystem.monsters do
            local row = BestiarySystem.makeRow(player, realTaskId)
            if row then
                table.insert(list, row)
            end
        end
    end

    return list
end

function BestiarySystem.sendPayload(player, data)
    local payload = json.encode(data)
    if TaskSystem and TaskSystem.sendChunked then
        TaskSystem.sendChunked(player, BestiarySystem.OPCODE, payload)
    else
        player:sendExtendedOpcode(BestiarySystem.OPCODE, payload)
    end
end

function BestiarySystem.sendSnapshot(player)
    local list = BestiarySystem.buildSnapshot(player)
    print(string.format("[Bestiary] sendSnapshot to %s entries=%d", player:getName(), #list))
    for i = 1, #list do
        local row = list[i]
        if row and type(row.name) == "string" and row.name:lower() == "troll" then
            print(string.format("[Bestiary] snapshot troll kills=%d next=%d bonus=%d", tonumber(row.kills) or 0, tonumber(row.nextThreshold) or -1, tonumber(row.bonusPercent) or 0))
            break
        end
    end
    BestiarySystem.sendPayload(player, {
        action = "snapshot",
        data = {
            respecCost = BestiarySystem.respecCost,
            thresholds = BestiarySystem.thresholds,
            list = list
        }
    })
end

function BestiarySystem.sendUpdate(player, realTaskId)
    local row = BestiarySystem.makeRow(player, realTaskId)
    if not row then
        return
    end
    BestiarySystem.sendPayload(player, {action = "update", data = row})
end

function BestiarySystem.onKill(player, monsterName)
    local index = BestiarySystem.resolveMonsterIndex(monsterName)
    if not index then
        local normalized = normalizeMonsterName(monsterName)
        if normalized ~= "" then
            index = BestiarySystem.resolveMonsterIndex(stripArticles(normalized))
        end
    end
    if not index then
        local infoName = tostring(monsterName or "")
        print(string.format("[Bestiary] onKill unresolved monster='%s' player=%s", infoName, player and player:getName() or "unknown"))
        return
    end

    local previousKills = BestiarySystem.getKills(player, index)
    local previousTier = BestiarySystem.getBonusTierPercent(previousKills, index)
    local kills = previousKills + 1
    BestiarySystem.setKills(player, index, kills)
    print(string.format("[Bestiary] onKill player=%s monster=%s index=%d kills=%d", player:getName(), tostring(monsterName), index, kills))
    BestiarySystem.sendUpdate(player, index)

    local currentTier = BestiarySystem.getBonusTierPercent(kills, index)
    if previousTier ~= currentTier and player.sendExtraStatsSnapshot then
        player:sendExtraStatsSnapshot()
    end
end

local function removeRespecMoney(player)
    local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
    if not backpack then
        return false
    end

    if player:getMoney() < BestiarySystem.respecCost then
        return false
    end

    return player:removeMoney(BestiarySystem.respecCost)
end

function BestiarySystem.chooseBonus(player, displayTaskId, bonusTypeKey)
    local realTaskId = BestiarySystem.toRealTaskId(tonumber(displayTaskId))
    if not realTaskId or not TaskSystem.monsters or not TaskSystem.monsters[realTaskId] then
        return false
    end

    local selectedType = BestiarySystem.bonusTypes[tostring(bonusTypeKey or ""):lower()]
    if not selectedType then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "[Bestiary] Invalid bonus type.")
        return false
    end

    local kills = BestiarySystem.getKills(player, realTaskId)
    local tierPercent = BestiarySystem.getBonusTierPercent(kills, realTaskId)
    if tierPercent <= 0 then
        player:sendTextMessage(
            MESSAGE_STATUS_CONSOLE_ORANGE,
            string.format("[Bestiary] You need at least %d kills of this monster.", BestiarySystem.getFirstThreshold(realTaskId))
        )
        return false
    end

    local currentId = BestiarySystem.getSelectedBonusId(player, realTaskId)
    if currentId == selectedType.id then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "[Bestiary] This bonus is already selected.")
        return false
    end

    if currentId > 0 then
        if not removeRespecMoney(player) then
            player:sendTextMessage(
                MESSAGE_STATUS_CONSOLE_ORANGE,
                string.format("[Bestiary] You need %d gold in your backpack to change the bonus.", BestiarySystem.respecCost)
            )
            return false
        end
    end

    BestiarySystem.setSelectedBonusId(player, realTaskId, selectedType.id)
    BestiarySystem.sendUpdate(player, realTaskId)
    if player.sendExtraStatsSnapshot then
        player:sendExtraStatsSnapshot()
    end

    if currentId > 0 then
        player:sendTextMessage(
            MESSAGE_STATUS_CONSOLE_ORANGE,
            string.format("[Bestiary] Bonus changed to %s for %d gold.", selectedType.label, BestiarySystem.respecCost)
        )
    else
        player:sendTextMessage(
            MESSAGE_STATUS_CONSOLE_ORANGE,
            string.format("[Bestiary] Bonus selected: %s.", selectedType.label)
        )
    end
    return true
end

function BestiarySystem.getActiveBonuses(player)
    local results = {}
    if not player or not TaskSystem or not TaskSystem.monsters then
        return results
    end

    for realTaskId = 1, #TaskSystem.monsters do
        local monsterName = TaskSystem.monsters[realTaskId]
        local kills = BestiarySystem.getKills(player, realTaskId)
        local tierPercent = BestiarySystem.getBonusTierPercent(kills, realTaskId)
        if tierPercent > 0 then
            local bonusId = BestiarySystem.getSelectedBonusId(player, realTaskId)
            local bonusInfo = BestiarySystem.bonusById[bonusId]
            if bonusInfo and bonusInfo.key then
                table.insert(results, {
                    monster = monsterName,
                    bonusType = bonusInfo.key,
                    bonusLabel = bonusInfo.label,
                    percent = tierPercent
                })
            end
        end
    end

    table.sort(results, function(a, b)
        local an = (a.monster or ""):lower()
        local bn = (b.monster or ""):lower()
        if an == bn then
            return (a.bonusType or "") < (b.bonusType or "")
        end
        return an < bn
    end)
    return results
end

local function scaleDamageWithPercent(damage, percent)
    if damage >= 0 or percent <= 0 then
        return damage
    end

    local scaled = math.floor(((math.abs(damage) * (100 + percent)) / 100) + 0.5)
    if scaled < 1 then
        scaled = 1
    end
    return -scaled
end

function BestiarySystem.applyDamageBonus(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType)
    if not creature or not attacker then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if not creature:isMonster() then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local player = attacker:getPlayer()
    if not player and attacker:isMonster() then
        local master = attacker:getMaster()
        if master and master:isPlayer() then
            player = master
        end
    end

    if not player then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local index = BestiarySystem.resolveMonsterIndex(creature:getName())
    if not index then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local kills = BestiarySystem.getKills(player, index)
    local tierPercent = BestiarySystem.getBonusTierPercent(kills, index)
    if tierPercent <= 0 then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    local selectedCombatType = BestiarySystem.getSelectedCombatType(player, index)
    if not selectedCombatType then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if primaryType == selectedCombatType then
        primaryDamage = scaleDamageWithPercent(primaryDamage, tierPercent)
    end
    if secondaryType == selectedCombatType then
        secondaryDamage = scaleDamageWithPercent(secondaryDamage, tierPercent)
    end

    return primaryDamage, primaryType, secondaryDamage, secondaryType
end
