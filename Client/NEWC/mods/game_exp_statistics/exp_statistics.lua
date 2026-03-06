expStatsWindow = nil
expStatsButton = nil
lootValueWindow = nil
supplyValueWindow = nil

local OPCODE_EXP_STATS = 111

local refreshEvent = nil

local sessionStartMs = 0
local sessionStartExp = 0
local baselineReady = false
local fallbackGainedExp = 0
local cachedExpFromEvent = nil

local dealtDamageTotal = 0
local receivedDamageTotal = 0

local pendingCorpseMoves = {}
local pendingInventoryAdds = {}
local lootCountsById = {}
local totalLootValue = 0
local pendingSupplyRemovals = {}
local supplyUsedCountsById = {}
local supplyUsedIconByKey = {}
local supplySlotSnapshotBySlot = {}
local totalSupplyValue = 0

local expPerHourLabel = nil
local gainedExpLabel = nil
local expToLevelLabel = nil
local timeToLevelLabel = nil
local goldPerHourLabel = nil
local totalLootValueLabel = nil
local supplyPerHourLabel = nil
local totalSupplyValueLabel = nil
local profitSummaryLabel = nil
local sessionTimeLabel = nil
local dealtDamageLabel = nil
local dealtDamageHourLabel = nil
local receivedDamageLabel = nil
local receivedDamageHourLabel = nil
local lootSessionList = nil
local supplySessionList = nil
local lootSessionScroll = nil
local supplySessionScroll = nil

local lootValuesByAccount = {}
local lootValues = {}
local supplyValuesByAccount = {}
local supplyValues = {}
local accountScopeKey = "__default__"
local lootValueRows = {}
local supplyValueRows = {}
local allLootItems = {}
local allSupplyItems = {}
local lootItemNameById = {}
local lootItemRuntimeNameByClientId = {}
local lootClientIconIdByValueKey = {}
local lootClientIconIdByServerId = {}
local lootValueKeyByClientId = {}
local lootValueKeyByServerId = {}
local lootDisplayNameByClientId = {}
local supplyKeyByServerId = {}
local supplyIconIdByKey = {}
local supplyNameByKey = {}
local supplyDisplaySubTypeByKey = {}
local corpseIdSet = {}
local monsterMaxHealthByName = {}
local lootValueKeySet = {}
local isRefreshingLootEditor = false

local attackedCreatureId = nil
local attackedCreatureMaxHealth = 0
local attackedCreatureLastPercent = nil
local dealtFromTextSeen = false
local lastLocalHealth = nil
local lootTrackedViaContainers = false
local containerStates = {}
local rebuildLootValueRows
local rebuildSupplyValueRows
local onSupplyValueSearchChange
local refreshSupplySessionList

local LOOT_VALUES_NODE = "expStatisticsLootValuesByAccount"
local SUPPLY_VALUES_NODE = "expStatisticsSupplyValuesByAccount"
local SUPPLY_VALUES_LEGACY_NODE = "expStatisticsSupplyValues"
local PENDING_MOVE_TTL_MS = 1600
local SUPPLY_PENDING_TTL_MS = 800

local SUPPLY_CATALOG = {
  {name = "mana fluid", id = 2006, subType = 2},
  {name = "life fluid", id = 2006, subType = 11},
  {name = "light magic missile rune", id = 2287},
  {name = "heavy magic missile rune", id = 2311},
  {name = "poison field rune", id = 2285},
  {name = "fire field rune", id = 2301},
  {name = "intense healing rune", id = 2265},
  {name = "destroy field rune", id = 2261},
  {name = "energy field rune", id = 2277},
  {name = "ultimate healing rune", id = 2273},
  {name = "poison bomb rune", id = 2286},
  {name = "fireball rune", id = 2302},
  {name = "great fireball rune", id = 2304},
  {name = "fire bomb rune", id = 2305},
  {name = "poison wall rune", id = 2289},
  {name = "explosion rune", id = 2313},
  {name = "fire wall rune", id = 2303},
  {name = "magic wall rune", id = 2293},
  {name = "energy wall rune", id = 2279},
  {name = "energy bomb rune", id = 2262},
  {name = "sudden death rune", id = 2268},
  {name = "torch", id = 2050},
  {name = "magic light wand", id = 2162},
  {name = "bolt", id = 2543},
  {name = "arrow", id = 2544},
  {name = "poison arrow", id = 2545},
  {name = "burst arrow", id = 2546},
  {name = "power bolt", id = 2547},
  {name = "assassin star", id = 5836},
  {name = "infernal bolt", id = 5971},
  {name = "might ring", id = 2164},
  {name = "stealth ring", id = 2165},
  {name = "power ring", id = 2166},
  {name = "energy ring", id = 2167},
  {name = "life ring", id = 2168},
  {name = "time ring", id = 2169},
  {name = "sword ring", id = 2207},
  {name = "axe ring", id = 2208},
  {name = "club ring", id = 2209},
  {name = "distance ring", id = 7954},
  {name = "dwarven ring", id = 2213},
  {name = "ring of healing", id = 2214},
  {name = "silver amulet", id = 2170},
  {name = "bronze amulet", id = 2172},
  {name = "stone skin amulet", id = 2197},
  {name = "elven amulet", id = 2198},
  {name = "garlic necklace", id = 2199},
  {name = "dragon necklace", id = 2201},
  {name = "terra amulet", id = 5878},
  {name = "glacier amulet", id = 5877},
  {name = "magma amulet", id = 5875},
  {name = "lightning pendant", id = 5876}
}

local SUPPLY_NAME_ALIASES = {
  ["manafluid"] = "mana fluid",
  ["lifefluid"] = "life fluid",
  ["firebomb rune"] = "fire bomb rune",
  ["magic lightwand"] = "magic light wand",
  ["magic wand"] = "magic light wand",
  ["instense healing rune"] = "intense healing rune",
  ["enerby bomb rune"] = "energy bomb rune"
}

local FLUID_CLIENT_TO_SERVER_SUBTYPE = {
  [0] = 0,
  [1] = 1,
  [2] = 7,
  [3] = 3,
  [4] = 19,
  [5] = 2,
  [6] = 4,
  [7] = 27,
  [8] = 5,
  [9] = 6,
  [10] = 15,
  [11] = 10,
  [12] = 13,
  [13] = 11,
  [14] = 21,
  [15] = 14,
  [16] = 35,
  [17] = 43
}

local FLUID_SUPPLY_BY_CLIENT_SUBTYPE = {
  [2] = "mana fluid",
  [11] = "life fluid"
}

local FLUID_SUPPLY_BY_SERVER_SUBTYPE = {
  [7] = "mana fluid",
  [10] = "life fluid"
}

local FLUID_CONTAINER_ID_SET = {
  [2005] = true, [2006] = true, [2007] = true, [2008] = true, [2009] = true,
  [2010] = true, [2011] = true, [2012] = true, [2013] = true, [2014] = true,
  [2015] = true, [2873] = true, [2874] = true, [2875] = true, [2881] = true,
  [2901] = true
}

local SLOT_NECK = tonumber(rawget(_G, "InventorySlotNeck")) or 2
local SLOT_FINGER = tonumber(rawget(_G, "InventorySlotFinger")) or 9
local SLOT_AMMO = tonumber(rawget(_G, "InventorySlotAmmo")) or 10
local SLOT_FIRST = tonumber(rawget(_G, "InventorySlotFirst")) or 1
local SLOT_LAST = tonumber(rawget(_G, "InventorySlotLast")) or 10

local SUPPLY_RING_KEYS = {
  ["might ring"] = true,
  ["stealth ring"] = true,
  ["power ring"] = true,
  ["energy ring"] = true,
  ["life ring"] = true,
  ["time ring"] = true,
  ["sword ring"] = true,
  ["axe ring"] = true,
  ["club ring"] = true,
  ["distance ring"] = true,
  ["dwarven ring"] = true,
  ["ring of healing"] = true
}

local SUPPLY_AMULET_KEYS = {
  ["silver amulet"] = true,
  ["bronze amulet"] = true,
  ["stone skin amulet"] = true,
  ["elven amulet"] = true,
  ["garlic necklace"] = true,
  ["dragon necklace"] = true,
  ["terra amulet"] = true,
  ["glacier amulet"] = true,
  ["magma amulet"] = true,
  ["lightning pendant"] = true
}

local SUPPLY_AMMO_SLOT_KEYS = {
  ["torch"] = true,
  ["magic light wand"] = true,
  ["bolt"] = true,
  ["power bolt"] = true,
  ["infernal bolt"] = true,
  ["assassin star"] = true,
  ["arrow"] = true,
  ["poison arrow"] = true,
  ["burst arrow"] = true
}

local SUPPLY_QUIVER_AMMO_KEYS = {
  ["bolt"] = true,
  ["power bolt"] = true,
  ["infernal bolt"] = true,
  ["assassin star"] = true,
  ["arrow"] = true,
  ["poison arrow"] = true,
  ["burst arrow"] = true
}

local function safeCall(fn, ...)
  local ok, result = pcall(fn, ...)
  if ok then
    return result
  end
  return nil
end

local function commaValue(value)
  local n = tonumber(value) or 0
  local left, num, right = tostring(math.floor(n)):match("^([^%d]*%d)(%d*)(.-)$")
  return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end

local function formatDurationHMS(totalSeconds)
  local seconds = math.max(0, math.floor(tonumber(totalSeconds) or 0))
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds % 3600) / 60)
  local s = seconds % 60
  return string.format("%02d:%02d:%02d", h, m, s)
end

local function normalizeExp(value)
  local n = tonumber(value) or 0
  if n < 0 then
    n = 0
  end
  return math.floor(n)
end

local function getLocalPlayer()
  if not g_game.isOnline() then
    return nil
  end
  return g_game.getLocalPlayer()
end

local function getAbsoluteExp(player)
  local fromEvent = normalizeExp(cachedExpFromEvent)
  if fromEvent > 0 then
    return fromEvent, true
  end

  if not player then
    return 0, false
  end

  local fromApi = normalizeExp(player:getExperience())
  if fromApi > 0 then
    return fromApi, true
  end

  return 0, false
end

local function expForLevel(level)
  local lvl = math.max(1, math.floor(tonumber(level) or 1))
  return math.floor((50 * lvl * lvl * lvl) / 3 - 100 * lvl * lvl + (850 * lvl) / 3 - 200)
end

local function parseExperienceGain(message)
  if type(message) ~= "string" or message == "" then
    return 0
  end

  local lower = message:lower()
  if not lower:find("experience", 1, true) and not lower:find(" exp", 1, true) then
    return 0
  end

  local numberChunk = lower:match("(%d[%d%,%.%s]*)%s+experience")
  if not numberChunk then
    numberChunk = lower:match("(%d[%d%,%.%s]*)%s+exp")
  end
  if not numberChunk then
    return 0
  end

  local digits = numberChunk:gsub("[^%d]", "")
  if digits == "" then
    return 0
  end

  return normalizeExp(digits)
end

local function parseFirstNumber(message)
  if type(message) ~= "string" or message == "" then
    return 0
  end
  local chunk = message:match("(%d[%d%,%.%s]*)")
  if not chunk then
    return 0
  end
  local digits = chunk:gsub("[^%d]", "")
  if digits == "" then
    return 0
  end
  return normalizeExp(digits)
end

local function parseLootEntriesFromMessage(message)
  if type(message) ~= "string" then
    return nil
  end

  local lootPart = message:match(":%s*(.+)$")
  if not lootPart or lootPart == "" then
    return nil
  end

  lootPart = lootPart:gsub("%.$", "")
  local lower = lootPart:lower()
  if lower == "nothing" or lower == "nothing to loot" then
    return {}
  end

  lootPart = lootPart:gsub("%s+and%s+", ", ")

  local entries = {}
  for token in lootPart:gmatch("[^,]+") do
    local part = token:gsub("^%s+", ""):gsub("%s+$", "")
    if part ~= "" then
      local countText, name = part:match("^(%d+)%s+(.+)$")
      local count = tonumber(countText)
      if not count then
        name = part:gsub("^an%s+", ""):gsub("^a%s+", ""):gsub("^some%s+", "")
        count = 1
      end

      name = (name or ""):gsub("^%s+", ""):gsub("%s+$", "")
      if name ~= "" and count > 0 then
        table.insert(entries, { name = name, count = count })
      end
    end
  end

  return entries
end

local function normalizeName(name)
  if type(name) ~= "string" then
    return ""
  end
  local s = name:lower():gsub("^%s+", ""):gsub("%s+$", "")
  s = s:gsub("^an%s+", "")
  s = s:gsub("^a%s+", "")
  s = s:gsub("^the%s+", "")
  return s
end

local function normalizeSupplyName(name)
  local key = normalizeName(name)
  key = key:gsub("^an%s+", ""):gsub("^a%s+", "")
  key = key:gsub("%s+", " ")
  local alias = SUPPLY_NAME_ALIASES[key]
  if alias then
    key = normalizeName(alias)
  end
  return key
end

local function getFluidDisplaySubType(subType)
  local value = tonumber(subType) or 0
  if g_game.getFeature and g_game.getFeature(GameNewFluids) then
    return value
  end
  return FLUID_CLIENT_TO_SERVER_SUBTYPE[value] or value
end

local function resolveFluidSupplyKeyFromSubType(subType)
  local value = tonumber(subType) or 0
  if value <= 0 then
    return nil
  end

  local byClient = FLUID_SUPPLY_BY_CLIENT_SUBTYPE[value]
  if byClient then
    return byClient
  end

  local byServer = FLUID_SUPPLY_BY_SERVER_SUBTYPE[value]
  if byServer then
    return byServer
  end

  local mappedServer = FLUID_CLIENT_TO_SERVER_SUBTYPE[value]
  if mappedServer then
    return FLUID_SUPPLY_BY_SERVER_SUBTYPE[mappedServer]
  end

  return nil
end

local function looksLikeCorpseName(name)
  local s = normalizeName(name)
  if s == "" then
    return false
  end
  return s:find("dead ", 1, true) == 1
    or s:find("slain ", 1, true) == 1
    or s:find("remains of ", 1, true) == 1
    or s:find("dissolved ", 1, true) == 1
    or s:find("deceased ", 1, true) == 1
    or s:find("bones of ", 1, true) == 1
    or s:find("carcass ", 1, true) == 1
    or s:find("lifeless ", 1, true) == 1
end

local function looksLikeGenericContainerName(name)
  local s = normalizeName(name)
  if s == "" then
    return false
  end

  return s:find("backpack", 1, true) ~= nil
    or s:find("bag", 1, true) ~= nil
    or s:find("chest", 1, true) ~= nil
    or s:find("box", 1, true) ~= nil
    or s:find("crate", 1, true) ~= nil
    or s:find("barrel", 1, true) ~= nil
    or s:find("basket", 1, true) ~= nil
    or s:find("sack", 1, true) ~= nil
    or s:find("locker", 1, true) ~= nil
    or s:find("depot", 1, true) ~= nil
    or s:find("parcel", 1, true) ~= nil
    or s:find("present", 1, true) ~= nil
end

local function getItemCount(item)
  if not item then
    return 0
  end
  local count = tonumber(safeCall(item.getCount, item)) or 1
  if count < 1 then
    count = 1
  end
  return math.floor(count)
end

local function getItemSubType(item)
  if not item then
    return 0
  end
  return tonumber(safeCall(item.getSubType, item)) or 0
end

local function makeSupplySlotSnapshot(item)
  if not item then
    return nil
  end

  local id = tonumber(safeCall(item.getId, item)) or 0
  if id <= 0 then
    return nil
  end

  return {
    id = id,
    name = getItemNameFromItem(item),
    subType = getItemSubType(item),
    count = getItemCount(item)
  }
end

local function refreshSupplySlotSnapshots()
  supplySlotSnapshotBySlot = {}

  local player = getLocalPlayer()
  if not player then
    return
  end

  for slot = SLOT_FIRST, SLOT_LAST do
    local item = safeCall(player.getInventoryItem, player, slot)
    local snapshot = makeSupplySlotSnapshot(item)
    if snapshot then
      supplySlotSnapshotBySlot[slot] = snapshot
    end
  end
end

local function getItemNameFromItem(item)
  if not item then
    return nil
  end

  local marketData = safeCall(item.getMarketData, item)
  if type(marketData) == "table" and type(marketData.name) == "string" and marketData.name ~= "" then
    return marketData.name
  end

  local name = safeCall(item.getName, item)
  if type(name) == "string" and name ~= "" then
    return name
  end

  return nil
end

local function isCorpseContainer(container)
  if not container then
    return false
  end

  local name = safeCall(container.getName, container) or ""
  if looksLikeCorpseName(name) then
    return true
  end

  local containerItem = safeCall(container.getContainerItem, container)
  if not containerItem then
    return false
  end

  local pos = safeCall(containerItem.getPosition, containerItem)
  if pos and pos.x ~= 65535 then
    local itemName = safeCall(containerItem.getName, containerItem) or ""
    if looksLikeCorpseName(itemName) then
      return true
    end
    if not looksLikeGenericContainerName(name) and not looksLikeGenericContainerName(itemName) then
      return true
    end
  end

  local itemId = tonumber(safeCall(containerItem.getId, containerItem))
  if itemId and corpseIdSet[itemId] then
    return true
  end

  local itemName = safeCall(containerItem.getName, containerItem) or ""
  if looksLikeCorpseName(itemName) then
    return true
  end

  return false
end

local function isPlayerInventoryContainer(container)
  if not container then
    return false
  end
  local containerItem = safeCall(container.getContainerItem, container)
  if not containerItem then
    return false
  end
  local pos = safeCall(containerItem.getPosition, containerItem)
  return pos and pos.x == 65535
end

local function isLikelyInventoryItem(item)
  if not item then
    return false
  end
  local pos = safeCall(item.getPosition, item)
  return pos and pos.x == 65535
end

local function hasOpenCorpseContainer()
  for _, container in pairs(g_game.getContainers()) do
    if isCorpseContainer(container) then
      return true
    end
  end
  return false
end

local function getLootItemName(itemId)
  return lootItemRuntimeNameByClientId[itemId] or lootDisplayNameByClientId[itemId] or lootItemNameById[itemId] or ("Item #" .. tostring(itemId))
end

local function getLootValueKeyFromName(name)
  local key = normalizeName(name)
  if key == "" then
    return nil
  end
  return key
end

local function resolveLootValueKey(name)
  local key = getLootValueKeyFromName(name)
  if not key then
    return nil
  end

  if lootValueKeySet[key] or lootValues[key] ~= nil then
    return key
  end

  local candidates = {}
  if key:sub(-3) == "ies" and #key > 3 then
    table.insert(candidates, key:sub(1, -4) .. "y")
  end
  if key:sub(-2) == "es" and #key > 2 then
    table.insert(candidates, key:sub(1, -3))
  end
  if key:sub(-1) == "s" and #key > 1 then
    table.insert(candidates, key:sub(1, -2))
  end

  for _, candidate in ipairs(candidates) do
    if candidate ~= "" and (lootValueKeySet[candidate] or lootValues[candidate] ~= nil) then
      return candidate
    end
  end

  return key
end

local function getMonsterMaxHealth(monsterName)
  if type(monsterName) ~= "string" or monsterName == "" then
    return 0
  end
  return tonumber(monsterMaxHealthByName[monsterName:lower()]) or 0
end

local function normalizePercent(value)
  local p = tonumber(value)
  if not p then
    return nil
  end
  if p < 0 then
    p = 0
  elseif p > 100 then
    p = 100
  end
  return p
end

local function getItemDisplayName(itemId)
  local item = safeCall(Item.create, itemId, 1)
  if not item then
    item = safeCall(Item.create, itemId)
  end
  if not item then
    return "Item #" .. tostring(itemId)
  end

  local marketData = safeCall(item.getMarketData, item)
  if type(marketData) == "table" and type(marketData.name) == "string" and marketData.name ~= "" then
    return marketData.name
  end

  local name = safeCall(item.getName, item)
  if type(name) == "string" and name ~= "" then
    return name
  end

  return "Item #" .. tostring(itemId)
end

local function buildGeneratedLootCache()
  allLootItems = {}
  lootItemNameById = {}
  lootItemRuntimeNameByClientId = {}
  lootClientIconIdByValueKey = {}
  lootClientIconIdByServerId = {}
  lootValueKeyByClientId = {}
  lootValueKeyByServerId = {}
  lootDisplayNameByClientId = {}
  corpseIdSet = {}
  monsterMaxHealthByName = {}
  lootValueKeySet = {}

  local marketClientIdByNameKey = {}
  if g_things and type(g_things.findThingTypeByAttr) == "function" then
    local types = g_things.findThingTypeByAttr(ThingAttrMarket, 0) or {}
    for _, itemType in ipairs(types) do
      local clientId = tonumber(safeCall(itemType.getId, itemType))
      if clientId and clientId > 0 then
        local marketData = safeCall(itemType.getMarketData, itemType)
        local tradeAs = type(marketData) == "table" and tonumber(marketData.tradeAs) or nil
        local showAs = type(marketData) == "table" and tonumber(marketData.showAs) or nil
        local iconId = showAs or clientId
        if tradeAs and tradeAs > 0 and iconId and iconId > 0 and not lootClientIconIdByServerId[tradeAs] then
          lootClientIconIdByServerId[tradeAs] = iconId
        end
        local marketName = (type(marketData) == "table" and marketData.name) or nil
        if (not marketName or marketName == "") then
          local iconItem = safeCall(Item.create, clientId)
          if iconItem then
            local md = safeCall(iconItem.getMarketData, iconItem)
            if type(md) == "table" and type(md.name) == "string" and md.name ~= "" then
              marketName = md.name
            else
              marketName = safeCall(iconItem.getName, iconItem)
            end
          end
        end

        local key = getLootValueKeyFromName(marketName or "")
        if key and key ~= "" and not marketClientIdByNameKey[key] then
          marketClientIdByNameKey[key] = iconId
        end
      end
    end
  end

  if type(MonsterCorpseIdsGenerated) == "table" then
    for _, rawCorpseId in ipairs(MonsterCorpseIdsGenerated) do
      local corpseId = tonumber(rawCorpseId)
      if corpseId and corpseId > 0 then
        corpseIdSet[corpseId] = true
      end
    end
  end

  if type(MonsterMaxHealthByNameGenerated) == "table" then
    for rawName, rawMaxHp in pairs(MonsterMaxHealthByNameGenerated) do
      if type(rawName) == "string" then
        local key = rawName:lower()
        local maxHp = tonumber(rawMaxHp) or 0
        if maxHp > 0 then
          monsterMaxHealthByName[key] = math.floor(maxHp)
        end
      end
    end
  end

  local seenById = {}
  local seenByValueKey = {}
  if type(LootItemsGenerated) == "table" then
    for _, raw in ipairs(LootItemsGenerated) do
      local itemId = nil
      local providedName = nil
      if type(raw) == "table" then
        itemId = tonumber(raw.id)
        if type(raw.name) == "string" and raw.name ~= "" then
          providedName = raw.name
        end
      else
        itemId = tonumber(raw)
      end

      if itemId and itemId > 0 and not seenById[itemId] then
        seenById[itemId] = true
        local name = providedName or getItemDisplayName(itemId)
        lootItemNameById[itemId] = name

        local valueKey = getLootValueKeyFromName(name) or ("id:" .. tostring(itemId))
        if not seenByValueKey[valueKey] then
          seenByValueKey[valueKey] = true
          lootValueKeySet[valueKey] = true
          lootValueKeyByServerId[itemId] = valueKey
          local mappedIconId = lootClientIconIdByServerId[itemId] or marketClientIdByNameKey[valueKey] or itemId
          lootClientIconIdByValueKey[valueKey] = mappedIconId
          if mappedIconId and mappedIconId > 0 then
            lootValueKeyByClientId[mappedIconId] = valueKey
            lootDisplayNameByClientId[mappedIconId] = name
          end
          local entry = {
            id = itemId,
            name = name,
            nameLower = name:lower(),
            valueKey = valueKey,
            iconId = mappedIconId
          }
          table.insert(allLootItems, entry)
        end
      end
    end
  end

  table.sort(allLootItems, function(a, b)
    if a.nameLower == b.nameLower then
      return a.id < b.id
    end
    return a.nameLower < b.nameLower
  end)
end

local function buildSupplyCache()
  allSupplyItems = {}
  supplyKeyByServerId = {}
  supplyIconIdByKey = {}
  supplyNameByKey = {}
  supplyDisplaySubTypeByKey = {}

  for _, entry in ipairs(SUPPLY_CATALOG) do
    local serverId = tonumber(entry.id) or 0
    local displayName = tostring(entry.name or "")
    local key = normalizeSupplyName(displayName)
    if key ~= "" and serverId > 0 and not supplyNameByKey[key] then
      supplyNameByKey[key] = displayName
      if entry.subType == nil then
        supplyKeyByServerId[serverId] = key
      end
      local iconId = tonumber(entry.iconId) or tonumber(lootClientIconIdByServerId[serverId]) or serverId
      local displaySubType = nil
      if entry.subType ~= nil then
        displaySubType = getFluidDisplaySubType(entry.subType)
      end
      supplyIconIdByKey[key] = iconId
      if displaySubType then
        supplyDisplaySubTypeByKey[key] = displaySubType
      end
      table.insert(allSupplyItems, {
        key = key,
        id = serverId,
        iconId = iconId,
        fixedIcon = entry.fixedIcon == true,
        subType = displaySubType,
        name = displayName,
        nameLower = displayName:lower()
      })
    end
  end

  table.sort(allSupplyItems, function(a, b)
    if a.nameLower == b.nameLower then
      return a.id < b.id
    end
    return a.nameLower < b.nameLower
  end)
end

local function applyLootClientIdsMap(idMap)
  if type(idMap) ~= "table" then
    return
  end

  for _, entry in ipairs(allLootItems) do
    local serverId = tonumber(entry.id)
    local clientId = tonumber(idMap[tostring(serverId)]) or tonumber(idMap[serverId])
    if clientId and clientId > 0 then
      entry.iconId = clientId
      lootClientIconIdByServerId[serverId] = clientId
      lootClientIconIdByValueKey[entry.valueKey] = clientId
      lootValueKeyByClientId[clientId] = entry.valueKey
      lootDisplayNameByClientId[clientId] = entry.name
    end
  end

  for _, supply in ipairs(allSupplyItems) do
    local serverId = tonumber(supply.id)
    local clientId = tonumber(idMap[tostring(serverId)]) or tonumber(idMap[serverId])
    if clientId and clientId > 0 then
      if supply.subType then
        FLUID_CONTAINER_ID_SET[clientId] = true
      else
        supplyKeyByServerId[clientId] = supply.key
      end
      if not supply.fixedIcon then
        supply.iconId = clientId
        supplyIconIdByKey[supply.key] = clientId
      end
    end
  end

  if lootValueWindow and lootValueWindow:isVisible() then
    rebuildLootValueRows()
    onLootValueSearchChange()
  end

  if supplyValueWindow and supplyValueWindow:isVisible() then
    rebuildSupplyValueRows()
    onSupplyValueSearchChange()
  end

  refreshSupplySessionList()
end

local function requestLootClientIds()
  local protocolGame = g_game.getProtocolGame()
  if not protocolGame then
    return
  end

  local ids = {}
  for _, entry in ipairs(allLootItems) do
    ids[#ids + 1] = tonumber(entry.id)
  end
  for _, entry in ipairs(allSupplyItems) do
    ids[#ids + 1] = tonumber(entry.id)
  end

  protocolGame:sendExtendedOpcode(OPCODE_EXP_STATS, json.encode({action = "fetchClientIds", data = {ids = ids}}))
end

local function onExpStatsExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_EXP_STATS then
    return
  end

  local ok, packet = pcall(function()
    return json.decode(buffer)
  end)
  if not ok or type(packet) ~= "table" then
    return
  end

  if packet.action == "clientIds" and type(packet.data) == "table" then
    applyLootClientIdsMap(packet.data.map)
  end
end

local function resolveAccountScopeKey()
  if type(G) == "table" and type(G.account) == "string" and G.account ~= "" then
    return tostring(G.account)
  end

  local storedAccount = g_settings.get("account")
  if type(storedAccount) == "string" and storedAccount ~= "" then
    return storedAccount
  end

  return "__default__"
end

local function loadLootValuesStorage()
  local node = g_settings.getNode(LOOT_VALUES_NODE)
  if type(node) ~= "table" then
    node = {}
  end
  lootValuesByAccount = node
end

local function saveLootValuesStorage()
  lootValuesByAccount[accountScopeKey] = lootValues
  g_settings.setNode(LOOT_VALUES_NODE, lootValuesByAccount)
end

local function activateAccountLootValues()
  accountScopeKey = resolveAccountScopeKey()
  local node = lootValuesByAccount[accountScopeKey]
  if type(node) ~= "table" then
    node = {}
    lootValuesByAccount[accountScopeKey] = node
  end
  lootValues = node
end

local function loadSupplyValuesStorage()
  local node = g_settings.getNode(SUPPLY_VALUES_NODE)
  if type(node) ~= "table" then
    node = {}
  end

  local legacyNode = g_settings.getNode(SUPPLY_VALUES_LEGACY_NODE)
  if type(legacyNode) == "table" and next(node) == nil then
    node["__default__"] = legacyNode
  end

  supplyValuesByAccount = node
end

local function saveSupplyValuesStorage()
  supplyValuesByAccount[accountScopeKey] = supplyValues
  supplyValuesByAccount["__default__"] = supplyValues
  g_settings.setNode(SUPPLY_VALUES_NODE, supplyValuesByAccount)
  g_settings.setNode(SUPPLY_VALUES_LEGACY_NODE, supplyValues)
end

local function activateAccountSupplyValues()
  accountScopeKey = resolveAccountScopeKey()
  local node = supplyValuesByAccount[accountScopeKey]
  if type(node) ~= "table" then
    local fallbackNode = nil
    local defaultNode = supplyValuesByAccount["__default__"]
    if type(defaultNode) == "table" and next(defaultNode) ~= nil then
      fallbackNode = defaultNode
    else
      for _, candidate in pairs(supplyValuesByAccount) do
        if type(candidate) == "table" and next(candidate) ~= nil then
          fallbackNode = candidate
          break
        end
      end
    end

    if type(fallbackNode) == "table" then
      node = table.copy(fallbackNode)
    else
      node = {}
    end
    supplyValuesByAccount[accountScopeKey] = node
    g_settings.setNode(SUPPLY_VALUES_NODE, supplyValuesByAccount)
  end
  supplyValues = node
end

local function getLootValueByKey(valueKey)
  if not valueKey or valueKey == "" then
    return 0
  end
  local value = tonumber(lootValues[valueKey]) or 0
  if value < 0 then
    value = 0
  end
  return math.floor(value)
end

local function getLootValueForItem(itemId)
  local clientKey = lootValueKeyByClientId[itemId]
  if clientKey and clientKey ~= "" then
    return getLootValueByKey(clientKey)
  end
  local name = getLootItemName(itemId)
  local key = resolveLootValueKey(name)
  return getLootValueByKey(key)
end

local function recalculateTotalLootValue()
  local total = 0
  for itemId, count in pairs(lootCountsById) do
    total = total + (getLootValueForItem(itemId) * count)
  end
  totalLootValue = total
end

local function refreshLootSessionList()
  if not lootSessionList then
    return
  end

  lootSessionList:destroyChildren()

  local entries = {}
  for itemId, count in pairs(lootCountsById) do
    table.insert(entries, {
      id = itemId,
      count = count,
      name = getLootItemName(itemId)
    })
  end

  table.sort(entries, function(a, b)
    local nameA = a.name:lower()
    local nameB = b.name:lower()
    if nameA == nameB then
      return a.id < b.id
    end
    return nameA < nameB
  end)

  if #entries == 0 then
    local emptyLabel = g_ui.createWidget("Label", lootSessionList)
    emptyLabel:setText("No looted items in this hunt yet.")
    emptyLabel:setColor("#b8b8b8")
    return
  end

  for _, entry in ipairs(entries) do
    local row = g_ui.createWidget("LootSessionRow", lootSessionList)
    row.icon:setItemId(entry.id)
    if row.name then
      row.name:setText("")
      row.name:setVisible(false)
    end
    row.count:setText("x" .. commaValue(entry.count))
    row.value:setText(commaValue(entry.count * getLootValueForItem(entry.id)) .. " gold")
  end
end

local function getSupplyValueByKey(supplyKey)
  if not supplyKey or supplyKey == "" then
    return 0
  end
  local value = tonumber(supplyValues[supplyKey]) or 0
  if value < 0 then
    value = 0
  end
  return math.floor(value)
end

local function recalculateTotalSupplyValue()
  local total = 0
  for supplyKey, count in pairs(supplyUsedCountsById) do
    total = total + (getSupplyValueByKey(supplyKey) * count)
  end
  totalSupplyValue = total
end

refreshSupplySessionList = function()
  if not supplySessionList then
    return
  end

  supplySessionList:destroyChildren()

  local entries = {}
  for supplyKey, count in pairs(supplyUsedCountsById) do
    if count > 0 then
      table.insert(entries, {
        key = supplyKey,
        count = count,
        name = supplyNameByKey[supplyKey] or supplyKey,
        iconId = tonumber(supplyUsedIconByKey[supplyKey]) or tonumber(supplyIconIdByKey[supplyKey]) or 0
      })
    end
  end

  table.sort(entries, function(a, b)
    local nameA = a.name:lower()
    local nameB = b.name:lower()
    if nameA == nameB then
      return a.key < b.key
    end
    return nameA < nameB
  end)

  if #entries == 0 then
    local emptyLabel = g_ui.createWidget("Label", supplySessionList)
    emptyLabel:setText("No supplies used in this hunt yet.")
    emptyLabel:setColor("#b8b8b8")
    return
  end

  for _, entry in ipairs(entries) do
    local row = g_ui.createWidget("LootSessionRow", supplySessionList)
    local iconId = tonumber(entry.iconId) or 0
    if iconId > 0 then
      local subType = tonumber(supplyDisplaySubTypeByKey[entry.key]) or 1
      row.icon:setItem(Item.create(iconId, subType))
    else
      row.icon:setItemId(0)
    end
    if row.name then
      row.name:setText("")
      row.name:setVisible(false)
    end
    row.count:setText("x" .. commaValue(entry.count))
    row.value:setText(commaValue(entry.count * getSupplyValueByKey(entry.key)) .. " gold")
  end
end

local function setSupplyValue(supplyKey, value)
  if not supplyKey or supplyKey == "" then
    return
  end
  local normalized = math.max(0, math.floor(tonumber(value) or 0))
  supplyValues[supplyKey] = normalized
  saveSupplyValuesStorage()
  recalculateTotalSupplyValue()
  refreshSupplySessionList()
end

local function setLootValue(valueKey, value)
  if not valueKey or valueKey == "" then
    return
  end
  local normalized = math.max(0, math.floor(tonumber(value) or 0))
  lootValues[valueKey] = normalized
  saveLootValuesStorage()
  recalculateTotalLootValue()
  refreshLootSessionList()
end

local function resolveLootValueKeyForItem(itemId, itemName)
  local key = resolveLootValueKey(itemName or "")
  if key and key ~= "" then
    return key
  end

  local id = tonumber(itemId) or 0
  if id > 0 then
    key = lootValueKeyByClientId[id] or lootValueKeyByServerId[id]
    if key and key ~= "" then
      return key
    end

    local fallbackName = lootItemRuntimeNameByClientId[id] or lootDisplayNameByClientId[id] or lootItemNameById[id]
    key = resolveLootValueKey(fallbackName or "")
    if key and key ~= "" then
      return key
    end
  end

  return nil
end

local function resolveDisplayItemIdForLoot(valueKey, preferredItemId)
  local preferredId = tonumber(preferredItemId) or 0
  if preferredId > 0 and lootValueKeyByClientId[preferredId] == valueKey then
    return preferredId
  end

  local mapped = tonumber(lootClientIconIdByValueKey[valueKey]) or 0
  if mapped > 0 then
    return mapped
  end

  if preferredId > 0 then
    return preferredId
  end

  return 0
end

local function resolveSupplyKeyForItem(itemId, itemName, itemSubType)
  local id = tonumber(itemId) or 0

  if id > 0 then
    local directFluid = FLUID_SUPPLY_BY_SERVER_SUBTYPE[id] or FLUID_SUPPLY_BY_CLIENT_SUBTYPE[id]
    if directFluid then
      return directFluid
    end
  end

  if id > 0 and FLUID_CONTAINER_ID_SET[id] then
    local fluidKey = resolveFluidSupplyKeyFromSubType(itemSubType)
    if fluidKey then
      return fluidKey
    end

    local byName = normalizeSupplyName(itemName or "")
    if byName == "mana fluid" or byName == "life fluid" then
      return byName
    end

    return nil
  end

  if id > 0 then
    local keyById = supplyKeyByServerId[id]
    if keyById and keyById ~= "" then
      return keyById
    end
  end

  local fluidByName = resolveFluidSupplyKeyFromSubType(itemSubType)
  if fluidByName then
    return fluidByName
  end

  local keyByName = normalizeSupplyName(itemName or "")
  if keyByName ~= "" and (supplyNameByKey[keyByName] ~= nil or supplyValues[keyByName] ~= nil) then
    return keyByName
  end

  return nil
end

local function resolveDisplayItemIdForSupply(supplyKey, preferredItemId)
  local mapped = tonumber(supplyIconIdByKey[supplyKey]) or 0
  if mapped > 0 then
    return mapped
  end
  local preferred = tonumber(preferredItemId) or 0
  if preferred > 0 then
    return preferred
  end
  return 0
end

local function isSupplySlotAllowedForKey(supplyKey, slot)
  if not supplyKey or supplyKey == "" then
    return false
  end

  if slot == nil then
    if SUPPLY_RING_KEYS[supplyKey] or SUPPLY_AMULET_KEYS[supplyKey] then
      return false
    end

    if SUPPLY_AMMO_SLOT_KEYS[supplyKey] then
      return SUPPLY_QUIVER_AMMO_KEYS[supplyKey] == true
    end

    return true
  end

  local slotId = tonumber(slot)
  if not slotId then
    return false
  end

  if SUPPLY_RING_KEYS[supplyKey] then
    return slotId == SLOT_FINGER
  end

  if SUPPLY_AMULET_KEYS[supplyKey] then
    return slotId == SLOT_NECK
  end

  if SUPPLY_AMMO_SLOT_KEYS[supplyKey] then
    return slotId == SLOT_AMMO
  end

  return true
end

local function registerSupplyUsage(supplyKey, count, itemName, itemId)
  local amount = math.floor(tonumber(count) or 0)
  if not supplyKey or supplyKey == "" or amount <= 0 then
    return false
  end

  local displayId = resolveDisplayItemIdForSupply(supplyKey, itemId)
  if displayId <= 0 then
    return false
  end

  if type(itemName) == "string" and itemName ~= "" then
    supplyNameByKey[supplyKey] = itemName
  end

  supplyUsedIconByKey[supplyKey] = displayId
  supplyUsedCountsById[supplyKey] = (supplyUsedCountsById[supplyKey] or 0) + amount
  totalSupplyValue = totalSupplyValue + (getSupplyValueByKey(supplyKey) * amount)
  refreshSupplySessionList()
  return true
end

local function registerLootTransfer(valueKey, count, itemName, itemId)
  local amount = math.floor(tonumber(count) or 0)
  if not valueKey or valueKey == "" or amount <= 0 then
    return false
  end

  local displayId = resolveDisplayItemIdForLoot(valueKey, itemId)
  if displayId <= 0 then
    return false
  end

  local displayName = itemName
  if type(displayName) ~= "string" or displayName == "" then
    displayName = lootDisplayNameByClientId[displayId] or lootItemRuntimeNameByClientId[displayId] or lootItemNameById[tonumber(itemId) or 0] or ("Item #" .. tostring(displayId))
  end

  lootItemRuntimeNameByClientId[displayId] = displayName
  lootDisplayNameByClientId[displayId] = displayName
  lootValueKeyByClientId[displayId] = valueKey

  lootCountsById[displayId] = (lootCountsById[displayId] or 0) + amount
  totalLootValue = totalLootValue + (getLootValueByKey(valueKey) * amount)
  refreshLootSessionList()
  return true
end

local function cleanupPendingList(list)
  local now = g_clock.millis()
  for i = #list, 1, -1 do
    local entry = list[i]
    if not entry or entry.count <= 0 or (now - entry.time) > PENDING_MOVE_TTL_MS then
      table.remove(list, i)
    end
  end
end

local function cleanupPendingMoves()
  cleanupPendingList(pendingCorpseMoves)
  cleanupPendingList(pendingInventoryAdds)
end

local function cleanupPendingSupplyRemovals(flushExpired)
  local now = g_clock.millis()
  local changed = false
  for i = #pendingSupplyRemovals, 1, -1 do
    local entry = pendingSupplyRemovals[i]
    local remove = false
    if not entry or entry.count <= 0 then
      remove = true
    elseif (now - entry.time) > SUPPLY_PENDING_TTL_MS then
      if flushExpired then
        local consumed = math.max(0, math.floor(tonumber(entry.count) or 0))
        if consumed > 0 then
          if registerSupplyUsage(entry.key, consumed, entry.name, entry.itemId) then
            changed = true
          end
        end
      end
      remove = true
    end

    if remove then
      table.remove(pendingSupplyRemovals, i)
    end
  end
  return changed
end

local function pushPendingEntry(list, valueKey, count, itemName, itemId)
  if not valueKey or valueKey == "" then
    return
  end
  local amount = math.floor(tonumber(count) or 0)
  if amount <= 0 then
    return
  end
  table.insert(list, {
    key = valueKey,
    itemId = tonumber(itemId) or 0,
    count = amount,
    name = itemName,
    time = g_clock.millis()
  })
  cleanupPendingMoves()
end

local function consumePendingFromList(list, valueKey, count)
  if not valueKey or valueKey == "" then
    return 0
  end
  local amount = math.floor(tonumber(count) or 0)
  if amount <= 0 then
    return 0
  end

  cleanupPendingMoves()

  local matched = 0
  local remaining = amount

  for _, entry in ipairs(list) do
    if remaining <= 0 then
      break
    end
    if entry.key == valueKey and entry.count > 0 then
      local take = math.min(remaining, entry.count)
      if take > 0 then
        entry.count = entry.count - take
        remaining = remaining - take
        matched = matched + take
      end
    end
  end

  cleanupPendingMoves()
  return matched
end

local function pushPendingCorpseMove(itemId, count)
  local key = resolveLootValueKeyForItem(itemId, nil)
  pushPendingEntry(pendingCorpseMoves, key, count, nil, itemId)
end

local function pushPendingInventoryAdd(itemId, count, itemName)
  local key = resolveLootValueKeyForItem(itemId, itemName)
  pushPendingEntry(pendingInventoryAdds, key, count, itemName, itemId)
end

local function consumePendingCorpseMove(itemId, count)
  local key = resolveLootValueKeyForItem(itemId, nil)
  return consumePendingFromList(pendingCorpseMoves, key, count)
end

local function consumePendingInventoryAdd(itemId, count, itemName)
  local key = resolveLootValueKeyForItem(itemId, itemName)
  if not key or key == "" then
    return 0, {}
  end

  local amount = math.floor(tonumber(count) or 0)
  if amount <= 0 then
    return 0, {}
  end

  cleanupPendingMoves()

  local matched = 0
  local remaining = amount
  local chunks = {}

  for _, entry in ipairs(pendingInventoryAdds) do
    if remaining <= 0 then
      break
    end
    if entry.key == key and entry.count > 0 then
      local take = math.min(remaining, entry.count)
      if take > 0 then
        entry.count = entry.count - take
        remaining = remaining - take
        matched = matched + take
        table.insert(chunks, { count = take, name = entry.name, key = key, itemId = entry.itemId })
      end
    end
  end

  cleanupPendingMoves()
  return matched, chunks
end

local function pushPendingSupplyRemoval(itemId, count, itemName, itemSubType)
  local key = resolveSupplyKeyForItem(itemId, itemName, itemSubType)
  if not key or key == "" then
    return
  end

  local amount = math.max(0, math.floor(tonumber(count) or 0))
  if amount <= 0 then
    return
  end

  table.insert(pendingSupplyRemovals, {
    key = key,
    itemId = tonumber(itemId) or 0,
    count = amount,
    name = itemName,
    time = g_clock.millis()
  })
end

local function consumePendingSupplyRemoval(itemId, count, itemName, itemSubType)
  local key = resolveSupplyKeyForItem(itemId, itemName, itemSubType)
  if not key or key == "" then
    return 0
  end

  local amount = math.max(0, math.floor(tonumber(count) or 0))
  if amount <= 0 then
    return 0
  end

  local matched = 0
  local remaining = amount

  for _, entry in ipairs(pendingSupplyRemovals) do
    if remaining <= 0 then
      break
    end
    if entry.key == key and entry.count > 0 then
      local take = math.min(remaining, entry.count)
      if take > 0 then
        entry.count = entry.count - take
        remaining = remaining - take
        matched = matched + take
      end
    end
  end

  cleanupPendingSupplyRemovals(false)
  return matched
end

local function handleSupplyInventoryRemove(itemId, count, itemName, slot, itemSubType)
  local id = tonumber(itemId)
  local amount = math.floor(tonumber(count) or 0)
  if not id or id <= 0 or amount <= 0 then
    return 0
  end

  local key = resolveSupplyKeyForItem(id, itemName, itemSubType)
  if not key or not isSupplySlotAllowedForKey(key, slot) then
    return 0
  end

  pushPendingSupplyRemoval(id, amount, itemName, itemSubType)
  return amount
end

local function handleSupplyInventoryAdd(itemId, count, itemName, slot, itemSubType)
  local id = tonumber(itemId)
  local amount = math.floor(tonumber(count) or 0)
  if not id or id <= 0 or amount <= 0 then
    return 0
  end

  local key = resolveSupplyKeyForItem(id, itemName, itemSubType)
  if not key then
    return 0
  end

  local isContainerAdd = slot == nil
  if not isContainerAdd and not isSupplySlotAllowedForKey(key, slot) then
    return 0
  end

  return consumePendingSupplyRemoval(id, amount, itemName, itemSubType)
end

local function handleInventoryLootAdd(itemId, count, itemName)
  local id = tonumber(itemId)
  local amount = math.floor(tonumber(count) or 0)
  if not id or id <= 0 or amount <= 0 then
    return 0
  end
  local key = resolveLootValueKeyForItem(id, itemName)
  if not key then
    return 0
  end

  local matched = consumePendingFromList(pendingCorpseMoves, key, amount)
  if matched > 0 then
    registerLootTransfer(key, matched, itemName, id)
  end

  local remaining = amount - matched
  if remaining > 0 then
    pushPendingEntry(pendingInventoryAdds, key, remaining, itemName, id)
  end

  return matched
end

local function handleCorpseLootRemove(itemId, count, itemName)
  local id = tonumber(itemId)
  local amount = math.floor(tonumber(count) or 0)
  if not id or id <= 0 or amount <= 0 then
    return 0
  end
  local key = resolveLootValueKeyForItem(id, itemName)
  if not key then
    return 0
  end

  local matched, chunks = consumePendingInventoryAdd(id, amount, itemName)
  if matched > 0 then
    for _, chunk in ipairs(chunks) do
      registerLootTransfer(chunk.key or key, chunk.count, chunk.name or itemName, chunk.itemId or id)
    end
  end

  local remaining = amount - matched
  if remaining > 0 then
    pushPendingEntry(pendingCorpseMoves, key, remaining, itemName, id)
  end

  return matched
end

local function registerLootToSession(itemId, count, itemName)
  local id = tonumber(itemId)
  local amount = math.floor(tonumber(count) or 0)
  if not id or id <= 0 or amount <= 0 then
    return
  end
  if type(itemName) == "string" and itemName ~= "" then
    lootItemRuntimeNameByClientId[id] = itemName
  end
  lootCountsById[id] = (lootCountsById[id] or 0) + amount
  totalLootValue = totalLootValue + (getLootValueForItem(id) * amount)
  refreshLootSessionList()
end

local function registerLootToSessionByName(itemName, count)
  local amount = math.floor(tonumber(count) or 0)
  if type(itemName) ~= "string" or itemName == "" or amount <= 0 then
    return false
  end

  local valueKey = resolveLootValueKey(itemName)
  if not valueKey then
    return false
  end

  local iconId = tonumber(lootClientIconIdByValueKey[valueKey]) or 0
  if iconId > 0 then
    lootItemRuntimeNameByClientId[iconId] = itemName
    lootCountsById[iconId] = (lootCountsById[iconId] or 0) + amount
    totalLootValue = totalLootValue + (getLootValueByKey(valueKey) * amount)
    refreshLootSessionList()
    return true
  end

  totalLootValue = totalLootValue + (getLootValueByKey(valueKey) * amount)
  return true
end

local function updateStats()
  cleanupPendingMoves()
  local supplyChanged = cleanupPendingSupplyRemovals(true)

  if not expStatsWindow then
    return
  end

  local player = getLocalPlayer()
  if not player then
    if expPerHourLabel then
      expPerHourLabel:setText("Exp/h: 0")
    end
    if gainedExpLabel then
      gainedExpLabel:setText("Gained Exp: 0")
    end
    if expToLevelLabel then
      expToLevelLabel:setText("Exp to level: 0")
    end
    if timeToLevelLabel then
      timeToLevelLabel:setText("Time to level: --")
    end
    if goldPerHourLabel then
      goldPerHourLabel:setText("Gold/h: 0")
    end
    if totalLootValueLabel then
      totalLootValueLabel:setText("Loot Value: 0 gp")
    end
    if supplyPerHourLabel then
      supplyPerHourLabel:setText("Supply/h: 0")
    end
    if totalSupplyValueLabel then
      totalSupplyValueLabel:setText("Supply Value: 0 gp")
    end
    if profitSummaryLabel then
      profitSummaryLabel:setText("Profit 0 gp")
      profitSummaryLabel:setColor("#8fd78f")
    end
    if sessionTimeLabel then
      sessionTimeLabel:setText("Session: 00:00:00")
    end
    if dealtDamageLabel then
      dealtDamageLabel:setText("Dealt Damage: 0")
    end
    if dealtDamageHourLabel then
      dealtDamageHourLabel:setText("Dealt Damage/h: 0")
    end
    if receivedDamageLabel then
      receivedDamageLabel:setText("Received Damage: 0")
    end
    if receivedDamageHourLabel then
      receivedDamageHourLabel:setText("Received Damage/h: 0")
    end
    if supplyChanged then
      refreshSupplySessionList()
    end
    return
  end

  local currentExp, hasAbsolute = getAbsoluteExp(player)

  if hasAbsolute and not baselineReady then
    sessionStartExp = currentExp
    sessionStartMs = g_clock.millis()
    baselineReady = true
  end

  local gainedExp = 0
  if hasAbsolute then
    gainedExp = math.max(0, currentExp - sessionStartExp)
  else
    gainedExp = math.max(0, fallbackGainedExp)
  end

  local elapsedSeconds = math.max(1, math.floor((g_clock.millis() - sessionStartMs) / 1000))
  local expPerHour = math.floor((gainedExp * 3600) / elapsedSeconds)
  local expToLevel = 0
  local timeToLevelText = "--"
  local currentLevel = math.max(1, math.floor(tonumber(player:getLevel()) or 1))
  if hasAbsolute then
    local nextLevelExp = expForLevel(currentLevel + 1)
    expToLevel = math.max(0, nextLevelExp - currentExp)
    if expToLevel <= 0 then
      timeToLevelText = "00:00:00"
    elseif expPerHour > 0 then
      local secondsToLevel = math.max(0, math.floor((expToLevel * 3600) / expPerHour))
      timeToLevelText = formatDurationHMS(secondsToLevel)
    end
  end

  local goldPerHour = math.floor((totalLootValue * 3600) / elapsedSeconds)
  local supplyPerHour = math.floor((totalSupplyValue * 3600) / elapsedSeconds)
  local netProfit = totalLootValue - totalSupplyValue
  local dealtPerHour = math.floor((dealtDamageTotal * 3600) / elapsedSeconds)
  local receivedPerHour = math.floor((receivedDamageTotal * 3600) / elapsedSeconds)

  if expPerHourLabel then
    expPerHourLabel:setText("Exp/h: " .. commaValue(expPerHour))
  end
  if gainedExpLabel then
    gainedExpLabel:setText("Gained Exp: " .. commaValue(gainedExp))
  end
  if expToLevelLabel then
    expToLevelLabel:setText("Exp to level: " .. commaValue(expToLevel))
  end
  if timeToLevelLabel then
    timeToLevelLabel:setText("Time to level: " .. timeToLevelText)
  end
  if goldPerHourLabel then
    goldPerHourLabel:setText("Gold/h: " .. commaValue(goldPerHour))
  end
  if totalLootValueLabel then
    totalLootValueLabel:setText("Loot Value: " .. commaValue(totalLootValue) .. " gp")
  end
  if supplyPerHourLabel then
    supplyPerHourLabel:setText("Supply/h: " .. commaValue(supplyPerHour))
  end
  if totalSupplyValueLabel then
    totalSupplyValueLabel:setText("Supply Value: " .. commaValue(totalSupplyValue) .. " gp")
  end
  if profitSummaryLabel then
    if netProfit >= 0 then
      profitSummaryLabel:setText("Profit " .. commaValue(netProfit) .. " gp")
      profitSummaryLabel:setColor("#8fd78f")
    else
      profitSummaryLabel:setText("Waste " .. commaValue(math.abs(netProfit)) .. " gp")
      profitSummaryLabel:setColor("#e27272")
    end
  end
  if sessionTimeLabel then
    sessionTimeLabel:setText("Session: " .. formatDurationHMS(elapsedSeconds))
  end
  if dealtDamageLabel then
    dealtDamageLabel:setText("Dealt Damage: " .. commaValue(dealtDamageTotal))
  end
  if dealtDamageHourLabel then
    dealtDamageHourLabel:setText("Dealt Damage/h: " .. commaValue(dealtPerHour))
  end
  if receivedDamageLabel then
    receivedDamageLabel:setText("Received Damage: " .. commaValue(receivedDamageTotal))
  end
  if receivedDamageHourLabel then
    receivedDamageHourLabel:setText("Received Damage/h: " .. commaValue(receivedPerHour))
  end

  if supplyChanged then
    refreshSupplySessionList()
  end
end

local function startRefresh()
  if refreshEvent then
    refreshEvent:cancel()
    refreshEvent = nil
  end
  refreshEvent = cycleEvent(updateStats, 1000)
end

local function stopRefresh()
  if refreshEvent then
    refreshEvent:cancel()
    refreshEvent = nil
  end
end

local function resetSession()
  local player = getLocalPlayer()
  local currentExp, hasAbsolute = getAbsoluteExp(player)
  sessionStartExp = currentExp
  sessionStartMs = g_clock.millis()
  baselineReady = hasAbsolute
  fallbackGainedExp = 0
  dealtDamageTotal = 0
  receivedDamageTotal = 0
  dealtFromTextSeen = false
  attackedCreatureId = nil
  attackedCreatureMaxHealth = 0
  attackedCreatureLastPercent = nil
  pendingCorpseMoves = {}
  pendingInventoryAdds = {}
  lootCountsById = {}
  lootItemRuntimeNameByClientId = {}
  totalLootValue = 0
  pendingSupplyRemovals = {}
  supplyUsedCountsById = {}
  supplyUsedIconByKey = {}
  totalSupplyValue = 0
  lootTrackedViaContainers = false
  containerStates = {}
  lastLocalHealth = nil
  if player then
    lastLocalHealth = tonumber(safeCall(player.getHealth, player))
  end
  refreshSupplySlotSnapshots()
  refreshLootSessionList()
  refreshSupplySessionList()
  updateStats()
end

rebuildLootValueRows = function()
  if not lootValueWindow then
    return
  end

  local list = lootValueWindow:recursiveGetChildById("lootValuesList")
  if not list then
    return
  end

  list:destroyChildren()
  lootValueRows = {}
  isRefreshingLootEditor = true

  for _, entry in ipairs(allLootItems) do
    local itemId = entry.id
    local valueKey = entry.valueKey
    local row = g_ui.createWidget("LootValueRow", list)
    local iconId = tonumber(entry.iconId) or tonumber(lootClientIconIdByValueKey[valueKey]) or tonumber(itemId) or 0
    row.icon:setItemId(iconId)
    row.itemName:setText(entry.name)
    row.itemId:setText("#" .. tostring(itemId))
    row.valueInput:setText(tostring(getLootValueByKey(valueKey)))

    row._nameLower = entry.nameLower
    row._idText = tostring(itemId)

    row.valueInput.onTextChange = function(widget, text)
      if isRefreshingLootEditor then
        return
      end
      local digits = (text or ""):gsub("[^%d]", "")
      local value = tonumber(digits) or 0
      local normalized = tostring(math.max(0, math.floor(value)))
      if widget:getText() ~= normalized then
        widget:setText(normalized)
      end
      setLootValue(valueKey, value)
      updateStats()
    end

    table.insert(lootValueRows, row)
  end

  isRefreshingLootEditor = false
end

function onLootValueSearchChange()
  if not lootValueWindow then
    return
  end

  local searchInput = lootValueWindow:recursiveGetChildById("searchInput")
  local query = ""
  if searchInput then
    query = (searchInput:getText() or ""):lower()
  end

  for _, row in ipairs(lootValueRows) do
    local visible = query == ""
      or row._nameLower:find(query, 1, true) ~= nil
      or row._idText:find(query, 1, true) ~= nil
    row:setVisible(visible)
  end
end

function openLootValueWindow()
  if not lootValueWindow then
    lootValueWindow = g_ui.loadUI("loot_values", rootWidget)
  end

  rebuildLootValueRows()
  onLootValueSearchChange()

  lootValueWindow:show()
  lootValueWindow:raise()
  lootValueWindow:focus()
end

function closeLootValueWindow()
  if lootValueWindow then
    lootValueWindow:hide()
  end
end

function onLootValueWindowClose()
  closeLootValueWindow()
end

rebuildSupplyValueRows = function()
  if not supplyValueWindow then
    return
  end

  local list = supplyValueWindow:recursiveGetChildById("supplyValuesList")
  if not list then
    return
  end

  list:destroyChildren()
  supplyValueRows = {}
  isRefreshingLootEditor = true

  for _, entry in ipairs(allSupplyItems) do
    local row = g_ui.createWidget("SupplyValueRow", list)
    local iconId = tonumber(entry.iconId) or tonumber(supplyIconIdByKey[entry.key]) or tonumber(entry.id) or 0
    if iconId > 0 then
      local subType = tonumber(entry.subType) or tonumber(supplyDisplaySubTypeByKey[entry.key]) or 1
      row.icon:setItem(Item.create(iconId, subType))
    else
      row.icon:setItemId(0)
    end
    row.itemName:setText(entry.name)
    row.itemId:setText("#" .. tostring(entry.id))
    row.valueInput:setText(tostring(getSupplyValueByKey(entry.key)))

    row._nameLower = entry.nameLower
    row._idText = tostring(entry.id)

    row.valueInput.onTextChange = function(widget, text)
      if isRefreshingLootEditor then
        return
      end
      local digits = (text or ""):gsub("[^%d]", "")
      local value = tonumber(digits) or 0
      local normalized = tostring(math.max(0, math.floor(value)))
      if widget:getText() ~= normalized then
        widget:setText(normalized)
      end
      setSupplyValue(entry.key, value)
      updateStats()
    end

    table.insert(supplyValueRows, row)
  end

  isRefreshingLootEditor = false
end

function onSupplyValueSearchChange()
  if not supplyValueWindow then
    return
  end

  local searchInput = supplyValueWindow:recursiveGetChildById("searchInput")
  local query = ""
  if searchInput then
    query = (searchInput:getText() or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  end

  local list = supplyValueWindow:recursiveGetChildById("supplyValuesList")
  for _, row in ipairs(supplyValueRows) do
    local visible = query == ""
      or (row._nameLower and row._nameLower:find(query, 1, true) ~= nil)
      or row._idText:find(query, 1, true) ~= nil
    row:setVisible(visible)
    row:setHeight(visible and 26 or 0)
  end

  if list then
    list:updateLayout()
  end
end

function openSupplyValueWindow()
  if not supplyValueWindow then
    supplyValueWindow = g_ui.loadUI("supply_values", rootWidget)
  end

  local searchInput = supplyValueWindow:recursiveGetChildById("searchInput")
  if searchInput then
    searchInput.onTextChange = function(widget, text)
      onSupplyValueSearchChange()
    end
  end

  rebuildSupplyValueRows()
  onSupplyValueSearchChange()

  supplyValueWindow:show()
  supplyValueWindow:raise()
  supplyValueWindow:focus()
end

function closeSupplyValueWindow()
  if supplyValueWindow then
    supplyValueWindow:hide()
  end
end

function onSupplyValueWindowClose()
  closeSupplyValueWindow()
end

local function bindExpStatsWindowRefs()
  if not expStatsWindow then
    return
  end

  expPerHourLabel = expStatsWindow:recursiveGetChildById("expPerHourLabel")
  gainedExpLabel = expStatsWindow:recursiveGetChildById("gainedExpLabel")
  expToLevelLabel = expStatsWindow:recursiveGetChildById("expToLevelLabel")
  timeToLevelLabel = expStatsWindow:recursiveGetChildById("timeToLevelLabel")
  goldPerHourLabel = expStatsWindow:recursiveGetChildById("goldPerHourLabel")
  totalLootValueLabel = expStatsWindow:recursiveGetChildById("totalLootValueLabel")
  supplyPerHourLabel = expStatsWindow:recursiveGetChildById("supplyPerHourLabel")
  totalSupplyValueLabel = expStatsWindow:recursiveGetChildById("totalSupplyValueLabel")
  profitSummaryLabel = expStatsWindow:recursiveGetChildById("profitSummaryLabel")
  sessionTimeLabel = expStatsWindow:recursiveGetChildById("sessionTimeLabel")
  dealtDamageLabel = expStatsWindow:recursiveGetChildById("dealtDamageLabel")
  dealtDamageHourLabel = expStatsWindow:recursiveGetChildById("dealtDamageHourLabel")
  receivedDamageLabel = expStatsWindow:recursiveGetChildById("receivedDamageLabel")
  receivedDamageHourLabel = expStatsWindow:recursiveGetChildById("receivedDamageHourLabel")
  lootSessionList = expStatsWindow:recursiveGetChildById("lootSessionList")
  supplySessionList = expStatsWindow:recursiveGetChildById("supplySessionList")
  lootSessionScroll = expStatsWindow:recursiveGetChildById("lootSessionScroll")
  supplySessionScroll = expStatsWindow:recursiveGetChildById("supplySessionScroll")
end

local function destroyWidgetsByIdRecursive(widget, targetId)
  if not widget then
    return
  end

  local children = widget:getChildren() or {}
  for _, child in ipairs(children) do
    destroyWidgetsByIdRecursive(child, targetId)
    if child:getId() == targetId then
      child:destroy()
    end
  end
end

local function captureExpStatsWindowState()
  if not expStatsWindow then
    return nil
  end

  local parent = expStatsWindow:getParent()
  local state = {
    width = tonumber(expStatsWindow:getWidth()) or 0,
    height = tonumber(expStatsWindow:getHeight()) or 0,
    position = expStatsWindow:getPosition(),
    parent = parent,
    parentClass = parent and parent:getClassName() or "",
    childIndex = nil
  }

  if parent and parent.getChildIndex then
    state.childIndex = tonumber(parent:getChildIndex(expStatsWindow)) or nil
  end

  return state
end

local function recreateExpStatsWindow(keepOpen, state)
  local root = (g_ui and g_ui.getRootWidget and g_ui.getRootWidget()) or rootWidget
  if root then
    destroyWidgetsByIdRecursive(root, "expStatisticsWindow")
  end

  local parent = nil
  if state and state.parent then
    parent = state.parent
  end
  if not parent then
    parent = modules.game_interface and modules.game_interface.getRightPanel and modules.game_interface.getRightPanel() or nil
  end

  expStatsWindow = g_ui.loadUI("exp_statistics", parent)
  expStatsWindow:enableResize()
  if state and state.height and state.height > 0 then
    expStatsWindow:setHeight(state.height)
  else
    expStatsWindow:setHeight(560)
  end
  expStatsWindow:setup()

  if state then
    if state.width and state.width > 0 then
      expStatsWindow:setWidth(state.width)
    end
    if state.height and state.height > 0 then
      expStatsWindow:setHeight(state.height)
    end
    if state.childIndex and parent and parent.moveChildToIndex then
      pcall(function()
        parent:moveChildToIndex(expStatsWindow, state.childIndex)
      end)
    end
    if state.position and state.parentClass ~= "UIMiniWindowContainer" then
      pcall(function()
        expStatsWindow:setPosition(state.position)
      end)
    end
  end

  bindExpStatsWindowRefs()

  if keepOpen then
    expStatsWindow:open()
  else
    expStatsWindow:close()
  end
end

function restartStatistics()
  local state = captureExpStatsWindowState()
  local keepOpen = expStatsWindow and expStatsWindow:isVisible() or false
  recreateExpStatsWindow(keepOpen, state)
  resetSession()

  if lootSessionList then
    lootSessionList:updateLayout()
  end
  if supplySessionList then
    supplySessionList:updateLayout()
  end
  if lootSessionScroll then
    pcall(function() lootSessionScroll:setValue(0) end)
  end
  if supplySessionScroll then
    pcall(function() supplySessionScroll:setValue(0) end)
  end
end

function toggle()
  if not expStatsWindow or not expStatsButton then
    return
  end

  if expStatsWindow:isVisible() then
    expStatsWindow:close()
    expStatsButton:setOn(false)
  else
    expStatsWindow:open()
    expStatsButton:setOn(true)
    updateStats()
  end
end

function onMiniWindowClose()
  if expStatsButton then
    expStatsButton:setOn(false)
  end
end

local function onGameStart()
  buildGeneratedLootCache()
  buildSupplyCache()
  requestLootClientIds()
  activateAccountLootValues()
  activateAccountSupplyValues()
  if lootValueWindow and lootValueWindow:isVisible() then
    rebuildLootValueRows()
    onLootValueSearchChange()
  end
  if supplyValueWindow and supplyValueWindow:isVisible() then
    rebuildSupplyValueRows()
    onSupplyValueSearchChange()
  end
  refreshSupplySlotSnapshots()
  resetSession()
end

local function onGameEnd()
  pcall(saveSupplyValuesStorage)
  supplySlotSnapshotBySlot = {}
  resetSession()
end

local function onExperienceChange(localPlayer, value)
  cachedExpFromEvent = normalizeExp(value)
end

local function onLocalHealthChange(localPlayer, health, maxHealth)
  local currentHealth = tonumber(health)
  if not currentHealth then
    return
  end

  if lastLocalHealth ~= nil and currentHealth < lastLocalHealth then
    receivedDamageTotal = receivedDamageTotal + (lastLocalHealth - currentHealth)
  end

  lastLocalHealth = currentHealth
end

local function onAttackingCreatureChange(creature, oldCreature)
  attackedCreatureId = nil
  attackedCreatureMaxHealth = 0
  attackedCreatureLastPercent = nil

  if not creature then
    return
  end

  local cid = tonumber(safeCall(creature.getId, creature))
  if not cid or cid <= 0 then
    return
  end

  local cname = safeCall(creature.getName, creature)
  local maxHp = getMonsterMaxHealth(cname or "")
  if maxHp <= 0 then
    return
  end

  attackedCreatureId = cid
  attackedCreatureMaxHealth = maxHp
  attackedCreatureLastPercent = normalizePercent(safeCall(creature.getHealthPercent, creature))
end

local function onCreatureHealthPercentChange(creature, healthPercent)
  if dealtFromTextSeen then
    return
  end
  if attackedCreatureMaxHealth <= 0 or not attackedCreatureId then
    return
  end

  local cid = tonumber(safeCall(creature.getId, creature))
  if not cid or cid ~= attackedCreatureId then
    return
  end

  local newPercent = normalizePercent(healthPercent)
  local oldPercent = attackedCreatureLastPercent
  attackedCreatureLastPercent = newPercent

  if not oldPercent or not newPercent then
    return
  end

  if newPercent >= oldPercent then
    return
  end

  local deltaPercent = oldPercent - newPercent
  local estimatedDamage = math.floor((attackedCreatureMaxHealth * deltaPercent / 100) + 0.5)
  if estimatedDamage <= 0 and deltaPercent > 0 then
    estimatedDamage = 1
  end

  if estimatedDamage > 0 then
    dealtDamageTotal = dealtDamageTotal + estimatedDamage
  end
end

local function getContainerState(container)
  local state = {
    isCorpse = isCorpseContainer(container),
    counts = {},
    names = {}
  }

  local items = safeCall(container.getItems, container) or {}
  for _, item in ipairs(items) do
    local itemId = tonumber(safeCall(item.getId, item))
    if itemId and itemId > 0 then
      local count = getItemCount(item)
      if count > 0 then
        state.counts[itemId] = (state.counts[itemId] or 0) + count
        state.names[itemId] = state.names[itemId] or getItemNameFromItem(item) or lootDisplayNameByClientId[itemId] or lootItemNameById[itemId]
      end
    end
  end

  return state
end

local function processContainerDelta(container)
  if not container then
    return
  end

  local containerId = tonumber(safeCall(container.getId, container))
  if not containerId then
    return
  end

  local previous = containerStates[containerId]
  local current = getContainerState(container)
  containerStates[containerId] = current

  if not previous then
    return
  end

  local changed = false
  local supplyChanged = false
  if previous.isCorpse then
    for itemId, oldCount in pairs(previous.counts) do
      local removed = oldCount - (current.counts[itemId] or 0)
      if removed > 0 then
        local matched = handleCorpseLootRemove(itemId, removed)
        if matched > 0 then
          changed = true
        end
      end
    end
  else
    for itemId, oldCount in pairs(previous.counts) do
      local removed = oldCount - (current.counts[itemId] or 0)
      if removed > 0 then
        local tracked = handleSupplyInventoryRemove(itemId, removed, previous.names[itemId], nil, nil)
        if tracked > 0 then
          supplyChanged = true
        end
      end
    end

    for itemId, newCount in pairs(current.counts) do
      local added = newCount - (previous.counts[itemId] or 0)
      if added > 0 then
        handleSupplyInventoryAdd(itemId, added, current.names[itemId], nil, nil)
        local matched = handleInventoryLootAdd(itemId, added, current.names[itemId])
        if matched > 0 then
          changed = true
        end
      end
    end
  end

  if changed then
    lootTrackedViaContainers = true
    updateStats()
    return
  end

  if supplyChanged then
    updateStats()
  end
end

local function onContainerOpen(container, previousContainer)
  if not container then
    return
  end
  local containerId = tonumber(safeCall(container.getId, container))
  if not containerId then
    return
  end
  containerStates[containerId] = getContainerState(container)
end

local function onContainerClose(container)
  if not container then
    return
  end
  local containerId = tonumber(safeCall(container.getId, container))
  if containerId then
    containerStates[containerId] = nil
  end
end

local function onContainerSizeChange(container, size)
  processContainerDelta(container)
end

local function onContainerRemoveItem(container, slot, item)
  if not container or not item then
    return
  end
  local corpse = isCorpseContainer(container)
  local itemId = tonumber(safeCall(item.getId, item))
  local count = getItemCount(item)
  local itemName = getItemNameFromItem(item)

  if corpse then
    local matched = handleCorpseLootRemove(itemId, count, itemName)
    if matched > 0 then
      lootTrackedViaContainers = true
      updateStats()
    end
    return
  end

  if isLikelyInventoryItem(item) or isPlayerInventoryContainer(container) then
    local removed = handleSupplyInventoryRemove(itemId, count, itemName, nil, getItemSubType(item))
    if removed > 0 then
      updateStats()
    end
  end
end

local function onContainerAddItem(container, slot, item, oldItem)
  if not container or not item then
    return
  end
  if isCorpseContainer(container) then
    return
  end
  if not (isLikelyInventoryItem(item) or isPlayerInventoryContainer(container)) then
    return
  end

  local itemId = tonumber(safeCall(item.getId, item))
  local count = getItemCount(item)
  local itemName = getItemNameFromItem(item)
  handleSupplyInventoryAdd(itemId, count, itemName, nil, getItemSubType(item))
  local matched = handleInventoryLootAdd(itemId, count, itemName)
  if matched > 0 then
    lootTrackedViaContainers = true
    updateStats()
  end
end

local function onContainerUpdateItem(container, slot, item, oldItem)
  if not container then
    return
  end

  local isCorpse = isCorpseContainer(container)
  local isInventory = not isCorpse and (isLikelyInventoryItem(item) or isLikelyInventoryItem(oldItem) or isPlayerInventoryContainer(container))

  if isCorpse then
    local oldCount = getItemCount(oldItem)
    local newCount = getItemCount(item)
    local removed = oldCount - newCount
    if removed > 0 then
      local sourceItem = item or oldItem
      local itemId = tonumber(sourceItem and safeCall(sourceItem.getId, sourceItem))
      local itemName = getItemNameFromItem(sourceItem)
      local matched = handleCorpseLootRemove(itemId, removed, itemName)
      if matched > 0 then
        lootTrackedViaContainers = true
        updateStats()
      end
    end
    return
  end

  if isInventory then
    local oldCount = getItemCount(oldItem)
    local newCount = getItemCount(item)
    local removed = oldCount - newCount
    local added = newCount - oldCount
    if removed > 0 then
      local sourceItem = oldItem or item
      local itemId = tonumber(sourceItem and safeCall(sourceItem.getId, sourceItem))
      local itemName = getItemNameFromItem(sourceItem)
      local tracked = handleSupplyInventoryRemove(itemId, removed, itemName, nil, getItemSubType(sourceItem))
      if tracked > 0 then
        updateStats()
      end
    end
    if added > 0 then
      local targetItem = item or oldItem
      local itemId = tonumber(targetItem and safeCall(targetItem.getId, targetItem))
      local itemName = getItemNameFromItem(targetItem)
      handleSupplyInventoryAdd(itemId, added, itemName, nil, getItemSubType(targetItem))
      local matched = handleInventoryLootAdd(itemId, added, itemName)
      if matched > 0 then
        lootTrackedViaContainers = true
        updateStats()
      end
    end

    if removed <= 0 and added <= 0 then
      local oldId = tonumber(oldItem and safeCall(oldItem.getId, oldItem))
      local newId = tonumber(item and safeCall(item.getId, item))
      local oldName = getItemNameFromItem(oldItem)
      local newName = getItemNameFromItem(item)
      local oldSubType = getItemSubType(oldItem)
      local newSubType = getItemSubType(item)
      local oldKey = resolveSupplyKeyForItem(oldId, oldName, oldSubType)
      local newKey = resolveSupplyKeyForItem(newId, newName, newSubType)
      if oldKey ~= newKey then
        local changed = false
        if oldKey then
          local tracked = handleSupplyInventoryRemove(oldId, 1, oldName, nil, oldSubType)
          if tracked > 0 then
            changed = true
          end
        end
        if newKey then
          local tracked = handleSupplyInventoryAdd(newId, 1, newName, nil, newSubType)
          if tracked > 0 then
            changed = true
          end
        end
        if changed then
          updateStats()
        end
      end
    end
  end
end

local function onTextMessage(mode, text)
  if type(text) ~= "string" then
    return
  end

  local lower = text:lower()

  if lower:find("you gained", 1, true) then
    if mode == MessageModes.Exp or mode == MessageModes.ExpOthers or lower:find("experience", 1, true) or lower:find(" exp", 1, true) then
      local gain = parseExperienceGain(text)
      if gain > 0 then
        fallbackGainedExp = fallbackGainedExp + gain
      end
    end
  end

  if mode == MessageModes.DamageDealed or mode == MessageModes.DamageOthers or mode == 21 or mode == 25 then
    local dealt = parseFirstNumber(text)
    if dealt > 0 then
      dealtFromTextSeen = true
      dealtDamageTotal = dealtDamageTotal + dealt
    end
  end

  if lastLocalHealth == nil then
    if mode == MessageModes.DamageReceived or mode == 22 then
      local received = parseFirstNumber(text)
      if received > 0 then
        receivedDamageTotal = receivedDamageTotal + received
      end
    elseif lower:find("you lose", 1, true) and lower:find("hitpoint", 1, true) then
      local received = parseFirstNumber(text)
      if received > 0 then
        receivedDamageTotal = receivedDamageTotal + received
      end
    end
  end

  -- Intentionally disabled: loot is counted only on actual corpse -> backpack transfer.
end

local function onPlayerInventoryChange(localPlayer, slot, item, oldItem)
  local slotId = tonumber(slot)
  if not slotId then
    return
  end

  local previousState = supplySlotSnapshotBySlot[slotId]

  local oldCount = getItemCount(oldItem)
  local newCount = getItemCount(item)

  local oldId = tonumber(oldItem and safeCall(oldItem.getId, oldItem))
  local newId = tonumber(item and safeCall(item.getId, item))
  local oldName = getItemNameFromItem(oldItem)
  local newName = getItemNameFromItem(item)
  local oldSubType = getItemSubType(oldItem)
  local newSubType = getItemSubType(item)

  if previousState then
    if (not oldId or oldId <= 0) and previousState.id then
      oldId = previousState.id
    end
    if (not oldName or oldName == "") and previousState.name then
      oldName = previousState.name
    end
    if oldSubType == 0 and oldId and previousState.id == oldId then
      oldSubType = tonumber(previousState.subType) or 0
    end
    if oldCount <= 0 and previousState.count then
      oldCount = tonumber(previousState.count) or oldCount
    end

    if oldId and newId and oldId == newId and oldCount == newCount and oldSubType == newSubType then
      local prevSubType = tonumber(previousState.subType) or 0
      if prevSubType ~= newSubType then
        oldSubType = prevSubType
        if previousState.name and previousState.name ~= "" then
          oldName = previousState.name
        end
      end
    end
  end

  local removed = oldCount - newCount
  local added = newCount - oldCount

  local changed = false

  if removed > 0 then
    local tracked = handleSupplyInventoryRemove(oldId, removed, oldName, slotId, oldSubType)
    if tracked > 0 then
      changed = true
    end
  end

  if added > 0 then
    local tracked = handleSupplyInventoryAdd(newId, added, newName, slotId, newSubType)
    if tracked > 0 then
      changed = true
    end
  end

  if removed <= 0 and added <= 0 and oldId and newId and oldId == newId then
    local oldKey = resolveSupplyKeyForItem(oldId, oldName, oldSubType)
    local newKey = resolveSupplyKeyForItem(newId, newName, newSubType)
    if oldKey ~= newKey then
      if oldKey then
        local tracked = handleSupplyInventoryRemove(oldId, 1, oldName, slotId, oldSubType)
        if tracked > 0 then
          changed = true
        end
      end
      if newKey then
        local tracked = handleSupplyInventoryAdd(newId, 1, newName, slotId, newSubType)
        if tracked > 0 then
          changed = true
        end
      end
    end
  end

  if changed then
    updateStats()
  end

  local snapshot = makeSupplySlotSnapshot(item)
  if snapshot then
    supplySlotSnapshotBySlot[slotId] = snapshot
  else
    supplySlotSnapshotBySlot[slotId] = nil
  end
end

function init()
  buildGeneratedLootCache()
  buildSupplyCache()
  loadLootValuesStorage()
  loadSupplyValuesStorage()
  activateAccountLootValues()
  activateAccountSupplyValues()
  ProtocolGame.registerExtendedOpcode(OPCODE_EXP_STATS, onExpStatsExtendedOpcode)

  connect(LocalPlayer, {
    onExperienceChange = onExperienceChange,
    onHealthChange = onLocalHealthChange,
    onInventoryChange = onPlayerInventoryChange
  })

  connect(Creature, {
    onHealthPercentChange = onCreatureHealthPercentChange
  })

  connect(Container, {
    onAddItem = onContainerAddItem,
    onRemoveItem = onContainerRemoveItem,
    onUpdateItem = onContainerUpdateItem
  })

  connect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
    onTextMessage = onTextMessage,
    onAttackingCreatureChange = onAttackingCreatureChange
  })

  expStatsButton =
    modules.client_topmenu.addRightGameToggleButton(
    "expStatsButton",
    tr("Exp Statistics"),
    "/images/topbuttons/analyzers",
    toggle,
    false,
    25
  )
  expStatsButton:setOn(false)

  recreateExpStatsWindow(false)

  refreshLootSessionList()
  resetSession()
  if g_game.isOnline() then
    requestLootClientIds()
  end
  startRefresh()
end

function terminate()
  stopRefresh()

  pcall(function() ProtocolGame.unregisterExtendedOpcode(OPCODE_EXP_STATS) end)

  disconnect(LocalPlayer, {
    onExperienceChange = onExperienceChange,
    onHealthChange = onLocalHealthChange,
    onInventoryChange = onPlayerInventoryChange
  })

  disconnect(Creature, {
    onHealthPercentChange = onCreatureHealthPercentChange
  })

  disconnect(Container, {
    onAddItem = onContainerAddItem,
    onRemoveItem = onContainerRemoveItem,
    onUpdateItem = onContainerUpdateItem
  })

  disconnect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
    onTextMessage = onTextMessage,
    onAttackingCreatureChange = onAttackingCreatureChange
  })

  if lootValueWindow then
    lootValueWindow:destroy()
    lootValueWindow = nil
  end

  if supplyValueWindow then
    supplyValueWindow:destroy()
    supplyValueWindow = nil
  end

  if expStatsWindow then
    expStatsWindow:destroy()
    expStatsWindow = nil
  end

  expPerHourLabel = nil
  gainedExpLabel = nil
  expToLevelLabel = nil
  timeToLevelLabel = nil
  goldPerHourLabel = nil
  totalLootValueLabel = nil
  supplyPerHourLabel = nil
  totalSupplyValueLabel = nil
  profitSummaryLabel = nil
  sessionTimeLabel = nil
  dealtDamageLabel = nil
  dealtDamageHourLabel = nil
  receivedDamageLabel = nil
  receivedDamageHourLabel = nil
  lootSessionList = nil
  supplySessionList = nil
  lootSessionScroll = nil
  supplySessionScroll = nil

  baselineReady = false
  fallbackGainedExp = 0
  cachedExpFromEvent = nil
  dealtDamageTotal = 0
  receivedDamageTotal = 0
  pendingCorpseMoves = {}
  pendingInventoryAdds = {}
  lootCountsById = {}
  totalLootValue = 0
  pendingSupplyRemovals = {}
  supplyUsedCountsById = {}
  supplyUsedIconByKey = {}
  supplySlotSnapshotBySlot = {}
  totalSupplyValue = 0
  lootValueRows = {}
  supplyValueRows = {}
  containerStates = {}

  if expStatsButton then
    expStatsButton:destroy()
    expStatsButton = nil
  end
end
