local OPCODE_CORPSE_PULSE = 112
local PULSE_INTERVAL_MS = 420
local TRACK_TTL_MS = 10 * 60 * 1000
local PULSE_SEQUENCE = {
  "yellow",
  "",
}

local trackedByKey = {}
local markedByObjectKey = {}
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
  if item then
    safeCall(item.setMarked, item, color or "")
  end
end

local function makeKey(x, y, z, itemId)
  return string.format("%d:%d:%d:%d", x, y, z, itemId)
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

local function isLikelyCorpseThing(thing)
  if not thing then
    return false
  end
  if not safeCall(thing.isItem, thing) then
    return false
  end
  if safeCall(thing.isFluidContainer, thing) then
    return false
  end

  local name = safeCall(thing.getName, thing)
  if type(name) ~= "string" or name == "" then
    return false
  end
  return looksLikeCorpseName(name)
end

local function getEntryFromData(data)
  if type(data) ~= "table" then
    return nil
  end

  local x = tonumber(data.x)
  local y = tonumber(data.y)
  local z = tonumber(data.z)
  local itemId = tonumber(data.id)
  local count = math.max(1, math.floor(tonumber(data.count) or 1))
  if not x or not y or not z or not itemId then
    return nil
  end

  return {
    x = x,
    y = y,
    z = z,
    itemId = itemId,
    count = count,
  }
end

local function getEntryFromThing(thing, fallbackPos)
  if not thing then
    return nil
  end

  local pos = safeCall(thing.getPosition, thing) or fallbackPos
  if not pos or not pos.x or pos.x == 65535 then
    return nil
  end

  local itemId = safeCall(thing.getId, thing)
  if not itemId then
    return nil
  end

  return {
    x = pos.x,
    y = pos.y,
    z = pos.z,
    itemId = itemId,
    count = 1,
  }
end

local function upsertTracked(entry, deltaCount)
  local key = makeKey(entry.x, entry.y, entry.z, entry.itemId)
  local now = g_clock.millis()
  local delta = math.floor(tonumber(deltaCount) or 0)
  if delta == 0 then
    delta = entry.count or 1
  end

  local tracked = trackedByKey[key]
  if not tracked then
    if delta <= 0 then
      return
    end
    tracked = {
      x = entry.x,
      y = entry.y,
      z = entry.z,
      itemId = entry.itemId,
      count = 0,
      expiresAt = now + TRACK_TTL_MS,
    }
    trackedByKey[key] = tracked
  end

  tracked.count = math.max(0, (tracked.count or 0) + delta)
  tracked.expiresAt = now + TRACK_TTL_MS
  if tracked.count <= 0 then
    trackedByKey[key] = nil
  end
end

local function collectMatchingCorpseItems(entry)
  local tile = g_map.getTile({ x = entry.x, y = entry.y, z = entry.z })
  if not tile then
    return {}
  end

  local items = {}
  local things = safeCall(tile.getThings, tile)
  if type(things) ~= "table" then
    return items
  end

  for _, thing in ipairs(things) do
    if safeCall(thing.isItem, thing)
      and not safeCall(thing.isFluidContainer, thing)
      and safeCall(thing.getId, thing) == entry.itemId then
      items[#items + 1] = thing
    end
  end

  return items
end

local function applyImmediateMark(entry)
  local matches = collectMatchingCorpseItems(entry)
  if #matches <= 0 then
    return
  end

  local limit = math.min(entry.count or 1, #matches)
  for i = 1, limit do
    local item = matches[i]
    local objectKey = tostring(item)
    setMark(item, "yellow")
    markedByObjectKey[objectKey] = item
  end
end

local function clearAllMarks()
  for _, item in pairs(markedByObjectKey) do
    clearMark(item)
  end
  markedByObjectKey = {}
end

local function clearAll()
  clearAllMarks()
  trackedByKey = {}
end

local function handleServerPayload(payload)
  if type(payload) ~= "table" then
    return
  end

  local action = tostring(payload.action or "")
  if action == "reset" then
    clearAll()
    return
  end

  local entry = getEntryFromData(payload.data)
  if not entry then
    return
  end

  if action == "clear" then
    upsertTracked(entry, -(entry.count or 1))
  elseif action == "spawn" then
    upsertTracked(entry, entry.count or 1)
    applyImmediateMark(entry)
  end
end

local function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_CORPSE_PULSE then
    return
  end

  if type(buffer) ~= "string" or buffer == "" then
    return
  end

  if buffer:sub(1, 1) == "{" then
    local payload = safeCall(json.decode, buffer)
    if type(payload) == "table" then
      handleServerPayload(payload)
    end
    return
  end

  local action, x, y, z, id, count = buffer:match("^([%a_]+)|(%-?%d+)|(%-?%d+)|(%-?%d+)|(%-?%d+)|(%-?%d+)$")
  if not action then
    action = buffer:match("^([%a_]+)$")
  end

  if not action then
    return
  end

  handleServerPayload({
    action = action,
    data = {
      x = tonumber(x),
      y = tonumber(y),
      z = tonumber(z),
      id = tonumber(id),
      count = tonumber(count) or 1,
    },
  })
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

  local visibleMarked = {}
  for key, entry in pairs(trackedByKey) do
    if not entry.expiresAt or entry.expiresAt <= now or (entry.count or 0) <= 0 then
      trackedByKey[key] = nil
    else
      local matches = collectMatchingCorpseItems(entry)
      if #matches > 0 then
        local limit = math.min(entry.count or 1, #matches)
        for i = 1, limit do
          local item = matches[i]
          local objectKey = tostring(item)
          visibleMarked[objectKey] = item
          setMark(item, color)
        end
      end
    end
  end

  for objectKey, item in pairs(markedByObjectKey) do
    if not visibleMarked[objectKey] then
      clearMark(item)
      markedByObjectKey[objectKey] = nil
    end
  end

  for objectKey, item in pairs(visibleMarked) do
    markedByObjectKey[objectKey] = item
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

local function onContainerOpen(container, previousContainer)
  local containerItem = safeCall(container.getContainerItem, container)
  if not containerItem then
    return
  end

  local pos = safeCall(containerItem.getPosition, containerItem)
  if not pos or not pos.x or pos.x == 65535 then
    return
  end

  local itemId = safeCall(containerItem.getId, containerItem)
  if not itemId then
    return
  end

  local key = makeKey(pos.x, pos.y, pos.z, itemId)
  local entry = trackedByKey[key]
  if entry then
    entry.count = math.max(0, (entry.count or 1) - 1)
    if entry.count <= 0 then
      trackedByKey[key] = nil
    end
  end

  local objectKey = tostring(containerItem)
  clearMark(containerItem)
  markedByObjectKey[objectKey] = nil
end

local function onTileAddThing(tile, thing)
  if not isLikelyCorpseThing(thing) then
    return
  end

  local tilePos = tile and safeCall(tile.getPosition, tile) or nil
  local entry = getEntryFromThing(thing, tilePos)
  if not entry then
    return
  end

  upsertTracked(entry, 1)
  applyImmediateMark(entry)
end

local function onTileRemoveThing(tile, thing)
  if not isLikelyCorpseThing(thing) then
    return
  end

  local tilePos = tile and safeCall(tile.getPosition, tile) or nil
  local entry = getEntryFromThing(thing, tilePos)
  if entry then
    upsertTracked(entry, -1)
  end

  local objectKey = tostring(thing)
  clearMark(thing)
  markedByObjectKey[objectKey] = nil
end

local function onGameStart()
  startPulse()
end

local function onGameEnd()
  stopPulse()
  clearAll()
end

function init()
  if ProtocolGame and ProtocolGame.registerExtendedOpcode then
    ProtocolGame.registerExtendedOpcode(OPCODE_CORPSE_PULSE, onExtendedOpcode)
  end

  connect(Container, {
    onOpen = onContainerOpen,
  })

  if Tile then
    connect(Tile, {
      onAddThing = onTileAddThing,
      onRemoveThing = onTileRemoveThing,
    })
  end

  connect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
  })

  if g_game.isOnline() then
    onGameStart()
  end
end

function terminate()
  if ProtocolGame and ProtocolGame.unregisterExtendedOpcode then
    pcall(function() ProtocolGame.unregisterExtendedOpcode(OPCODE_CORPSE_PULSE) end)
  end

  disconnect(Container, {
    onOpen = onContainerOpen,
  })

  if Tile then
    disconnect(Tile, {
      onAddThing = onTileAddThing,
      onRemoveThing = onTileRemoveThing,
    })
  end

  disconnect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
  })

  onGameEnd()
end
