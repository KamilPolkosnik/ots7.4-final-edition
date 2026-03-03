local PULSE_INTERVAL_MS = 420
local BUILD_TAG = "corpse_pulse_spellflash_alt_v3"

-- New spell-like flash sequence (different from the previous pulse).
local PULSE_SEQUENCE = {
  "#3E3E3E",
  "#4A4A4A",
  "#555555",
  "#4A4A4A",
}

local trackedByKey = {}
local trackedByBaseKey = {}
local openedAtByKey = {}
local pulseEvent = nil
local pulseIndex = 1

local function safeCall(fn, ...)
  local ok, result = pcall(fn, ...)
  if ok then
    return result
  end
  return nil
end

local function clearMark(item)
  if item then
    safeCall(item.setMarked, item, "")
  end
end

local function setMark(item, color)
  if not item then
    return
  end
  safeCall(item.setMarked, item, color or "")
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

local function getItemKey(item, fallbackPos)
  if not item then
    return nil
  end

  local pos = safeCall(item.getPosition, item) or fallbackPos
  if not pos then
    return nil
  end

  local itemId = safeCall(item.getId, item)
  if not itemId then
    return nil
  end

  local stackPos = safeCall(item.getStackPos, item) or 0
  return string.format("%d:%d:%d:%d:%d", pos.x, pos.y, pos.z, itemId, stackPos)
end

local function getItemBaseKey(item, fallbackPos)
  if not item then
    return nil
  end

  local pos = safeCall(item.getPosition, item) or fallbackPos
  if not pos then
    return nil
  end

  local itemId = safeCall(item.getId, item)
  if not itemId then
    return nil
  end

  return string.format("%d:%d:%d:%d", pos.x, pos.y, pos.z, itemId)
end

local function isCorpseThing(thing)
  if not thing then
    return false
  end

  if not safeCall(thing.isItem, thing) then
    return false
  end

  if safeCall(thing.isFluidContainer, thing) then
    return false
  end

  if not safeCall(thing.isContainer, thing) then
    return false
  end

  local name = safeCall(thing.getName, thing)
  if type(name) == "string" and name ~= "" then
    return looksLikeCorpseName(name)
  end

  -- Fallback for client builds where corpse items don't expose a proper name.
  -- This is the original simple behavior: container on tile = likely corpse.
  return true
end

local function pickCorpseFromTile(tile)
  if not tile then
    return nil
  end

  local topUse = safeCall(tile.getTopUseThing, tile)
  if isCorpseThing(topUse) then
    return topUse
  end

  local topLook = safeCall(tile.getTopLookThing, tile)
  if isCorpseThing(topLook) then
    return topLook
  end

  local items = safeCall(tile.getItems, tile)
  if type(items) == "table" and #items > 0 then
    for _, item in ipairs(items) do
      if isCorpseThing(item) then
        return item
      end
    end
  end

  local things = safeCall(tile.getThings, tile)
  if type(things) == "table" and #things > 0 then
    for _, thing in ipairs(things) do
      if isCorpseThing(thing) then
        return thing
      end
    end
  end

  return nil
end

local function removeEntry(entry)
  if not entry then
    return
  end

  clearMark(entry.item)
  if entry.key and trackedByKey[entry.key] == entry then
    trackedByKey[entry.key] = nil
  end
  if entry.baseKey and trackedByBaseKey[entry.baseKey] == entry then
    trackedByBaseKey[entry.baseKey] = nil
  end
end

local function markOpenedByKey(key, now)
  if not key then
    return
  end

  openedAtByKey[key] = true

  local entry = trackedByKey[key]
  if entry then
    removeEntry(entry)
  end
end

local function markOpenedByBaseKey(baseKey, now)
  if not baseKey then
    return false
  end

  local entry = trackedByBaseKey[baseKey]
  if not entry then
    return false
  end

  markOpenedByKey(entry.key, now)
  return true
end

local function markOpenedFallbackByNearest(itemId, pos, now)
  local bestKey = nil
  local bestScore = math.huge
  now = now or g_clock.millis()

  for key, entry in pairs(trackedByKey) do
    local score = 0

    if itemId and entry.itemId == itemId then
      score = score - 10000
    end

    if pos and entry.x and entry.y and entry.z then
      local dz = math.abs(entry.z - pos.z)
      score = score + math.abs(entry.x - pos.x) + math.abs(entry.y - pos.y) + (dz * 10)
    end

    if score < bestScore then
      bestScore = score
      bestKey = key
    end
  end

  if bestKey then
    markOpenedByKey(bestKey, now)
  end
end

local function isRecentlyOpened(key)
  return openedAtByKey[key] == true
end

local function pulseTick()
  pulseEvent = scheduleEvent(pulseTick, PULSE_INTERVAL_MS)

  if not g_game.isOnline() then
    return
  end

  pulseIndex = pulseIndex + 1
  if pulseIndex > #PULSE_SEQUENCE then
    pulseIndex = 1
  end
  local color = PULSE_SEQUENCE[pulseIndex]
  local now = g_clock.millis()

  local player = g_game.getLocalPlayer()
  if not player then
    return
  end

  local playerPos = player:getPosition()
  if not playerPos then
    return
  end

  local visibleKeys = {}
  local tiles = g_map.getTiles(playerPos.z) or {}
  for _, tile in ipairs(tiles) do
    local tilePos = safeCall(tile.getPosition, tile)
    local corpse = pickCorpseFromTile(tile)
    if corpse then
      local key = getItemKey(corpse, tilePos)
      if key then
        visibleKeys[key] = true

        if isRecentlyOpened(key) then
          clearMark(corpse)
          local existing = trackedByKey[key]
          if existing then
            removeEntry(existing)
          end
        else
          local entry = trackedByKey[key]
          if not entry then
            entry = { key = key }
            trackedByKey[key] = entry
          end
          if entry.key ~= key then
            trackedByKey[entry.key] = nil
            entry.key = key
            trackedByKey[key] = entry
          end
          entry.item = corpse
          local corpsePos = safeCall(corpse.getPosition, corpse)
          entry.itemId = safeCall(corpse.getId, corpse)
          entry.x = corpsePos and corpsePos.x or nil
          entry.y = corpsePos and corpsePos.y or nil
          entry.z = corpsePos and corpsePos.z or nil

          local baseKey = getItemBaseKey(corpse, tilePos)
          if entry.baseKey and entry.baseKey ~= baseKey and trackedByBaseKey[entry.baseKey] == entry then
            trackedByBaseKey[entry.baseKey] = nil
          end
          entry.baseKey = baseKey
          if baseKey then
            trackedByBaseKey[baseKey] = entry
          end

          setMark(corpse, color)
        end
      end
    end
  end

  -- Once corpse disappears from the map, allow future corpse on same tile/id key.
  for key in pairs(openedAtByKey) do
    if not visibleKeys[key] then
      openedAtByKey[key] = nil
    end
  end

  local toRemove = {}
  for key, entry in pairs(trackedByKey) do
    if not visibleKeys[key] then
      toRemove[#toRemove + 1] = entry
    else
      if isRecentlyOpened(key) then
        toRemove[#toRemove + 1] = entry
      else
        setMark(entry.item, color)
      end
    end
  end

  for _, entry in ipairs(toRemove) do
    removeEntry(entry)
  end
end

local function startPulse()
  if pulseEvent then
    return
  end
  pulseEvent = scheduleEvent(pulseTick, PULSE_INTERVAL_MS)
end

local function stopPulse()
  if pulseEvent then
    removeEvent(pulseEvent)
    pulseEvent = nil
  end
end

local function clearAll()
  for _, entry in pairs(trackedByKey) do
    clearMark(entry.item)
  end
  trackedByKey = {}
  trackedByBaseKey = {}
  openedAtByKey = {}
end

local function onContainerOpen(container, previousContainer)
  local containerItem = safeCall(container.getContainerItem, container)
  local containerName = safeCall(container.getName, container) or ""
  local itemPos = containerItem and safeCall(containerItem.getPosition, containerItem) or nil
  local isWorldItem = itemPos and itemPos.x and itemPos.x ~= 65535

  local isCorpseContainer = looksLikeCorpseName(containerName)
  if not isCorpseContainer and containerItem then
    isCorpseContainer = isCorpseThing(containerItem)
  end

  if not isCorpseContainer and not isWorldItem then
    return
  end

  if containerItem then
    clearMark(containerItem)
    local key = getItemKey(containerItem)
    local now = g_clock.millis()
    local baseKey = getItemBaseKey(containerItem)
    if markOpenedByBaseKey(baseKey, now) then
      return
    end
    if key then
      if trackedByKey[key] then
        markOpenedByKey(key, now)
        return
      end
    end

    local itemId = safeCall(containerItem.getId, containerItem)
    markOpenedFallbackByNearest(itemId, itemPos, now)
  end
end

local function onGameStart()
  startPulse()
end

local function onGameEnd()
  stopPulse()
  clearAll()
end

function init()
  connect(Container, {
    onOpen = onContainerOpen,
  })

  connect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
  })

  if g_game.isOnline() then
    onGameStart()
  end
end

function terminate()
  disconnect(Container, {
    onOpen = onContainerOpen,
  })

  disconnect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
  })

  onGameEnd()
end

