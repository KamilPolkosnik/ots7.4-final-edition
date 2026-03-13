local OPCODE_CORPSE_PULSE = 113
local OPCODE_CORPSE_PULSE_OPEN = 114
local PULSE_INTERVAL_MS = 420
local EFFECT_PULSE_INTERVAL_MS = 2000
local CORPSE_EFFECT_ID = 89
local OPEN_SUPPRESS_MS = 30 * 60 * 1000
local DEBUG = false
local ENABLE_CLIENT_EFFECT = false
local PULSE_SEQUENCE = {
  "#FFFF00",
  "",
}

-- Generated from server items.xml:
-- items with both corpseType and containerSize attributes.
local LOOTABLE_CORPSE_IDS = {
  [2806] = true, [2807] = true, [2808] = true, [2809] = true, [2810] = true, [2811] = true, [2813] = true, [2814] = true, [2820] = true, [2824] = true, [2826] = true, [2827] = true, [2830] = true, [2831] = true, [2832] = true, [2835] = true,
  [2836] = true, [2837] = true, [2839] = true, [2840] = true, [2843] = true, [2845] = true, [2846] = true, [2848] = true, [2849] = true, [2853] = true, [2857] = true, [2858] = true, [2860] = true, [2862] = true, [2864] = true, [2866] = true,
  [2867] = true, [2868] = true, [2871] = true, [2872] = true, [2873] = true, [2876] = true, [2877] = true, [2878] = true, [2881] = true, [2882] = true, [2883] = true, [2886] = true, [2889] = true, [2893] = true, [2897] = true, [2899] = true,
  [2902] = true, [2905] = true, [2906] = true, [2908] = true, [2909] = true, [2913] = true, [2914] = true, [2915] = true, [2916] = true, [2917] = true, [2920] = true, [2924] = true, [2925] = true, [2928] = true, [2929] = true, [2931] = true,
  [2932] = true, [2935] = true, [2936] = true, [2938] = true, [2940] = true, [2941] = true, [2945] = true, [2946] = true, [2949] = true, [2952] = true, [2953] = true, [2956] = true, [2957] = true, [2960] = true, [2961] = true, [2967] = true,
  [2968] = true, [2969] = true, [2970] = true, [2972] = true, [2973] = true, [2975] = true, [2977] = true, [2979] = true, [2981] = true, [2982] = true, [2983] = true, [2984] = true, [2985] = true, [2986] = true, [2987] = true, [2988] = true,
  [2989] = true, [2990] = true, [2992] = true, [2995] = true, [2998] = true, [3004] = true, [3005] = true, [3010] = true, [3013] = true, [3016] = true, [3017] = true, [3019] = true, [3022] = true, [3025] = true, [3028] = true, [3031] = true,
  [3032] = true, [3034] = true, [3035] = true, [3037] = true, [3038] = true, [3040] = true, [3041] = true, [3043] = true, [3044] = true, [3046] = true, [3049] = true, [3052] = true, [3055] = true, [3058] = true, [3059] = true, [3065] = true,
  [3066] = true, [3067] = true, [3068] = true, [3069] = true, [3073] = true, [3080] = true, [3084] = true, [3086] = true, [3087] = true, [3090] = true, [3095] = true, [3099] = true, [3103] = true, [3104] = true, [3105] = true, [3106] = true,
  [3108] = true, [3109] = true, [3113] = true, [3119] = true, [3128] = true, [3129] = true, [4251] = true, [4253] = true, [4256] = true, [4257] = true, [4259] = true, [4260] = true, [4262] = true, [4263] = true, [4265] = true, [4268] = true,
  [4271] = true, [4274] = true, [4277] = true, [4280] = true, [4283] = true, [4284] = true, [4286] = true, [4289] = true, [4292] = true, [4295] = true, [4296] = true, [4298] = true, [4301] = true, [4304] = true, [4307] = true, [4310] = true,
  [4314] = true, [4317] = true, [4320] = true, [4323] = true, [4324] = true, [4326] = true, [4327] = true, [4871] = true, [4872] = true, [5547] = true, [5548] = true, [5549] = true, [5551] = true, [5552] = true, [5553] = true, [5740] = true,
  [5741] = true, [5743] = true, [5744] = true, [5833] = true, [5834] = true, [6883] = true, [6884] = true, [6918] = true, [6919] = true, [6928] = true, [6929] = true, [6932] = true, [6933] = true, [6936] = true, [6937] = true, [6943] = true,
  [6944] = true, [6948] = true, [6949] = true, [6952] = true, [6953] = true, [6956] = true, [6957] = true, [6960] = true, [6961] = true, [6964] = true, [6965] = true, [6967] = true, [6968] = true, [6970] = true, [6971] = true, [6973] = true,
  [6974] = true, [6987] = true, [6989] = true, [6990] = true, [6992] = true, [6993] = true, [7028] = true, [7029] = true, [7085] = true,
}

local trackedByInstanceKey = {}
local openedUntilByStableKey = {}
local pulseEvent = nil
local effectPulseEvent = nil
local pulseIndex = 1
local debugLastPulseAt = 0
local effectApiChecked = false
local effectApiAvailable = false
local originalProcessMouseAction = nil
local processMouseActionHookInstalled = false

local function safeCall(fn, ...)
  if type(fn) ~= "function" then
    return nil
  end

  local ok, result = pcall(fn, ...)
  if ok then
    return result
  end
  return nil
end

local function debugLog(message)
  if not DEBUG then
    return
  end

  local line = "[CorpsePulse] " .. tostring(message)
  if g_logger and g_logger.info then
    g_logger.info(line)
  else
    print(line)
  end
end

local function tableSize(t)
  local n = 0
  for _ in pairs(t) do
    n = n + 1
  end
  return n
end

local function canUseEffectApi()
  if effectApiChecked then
    return effectApiAvailable
  end

  effectApiChecked = true
  effectApiAvailable = (Effect and type(Effect.create) == "function" and g_map and type(g_map.addThing) == "function")
  debugLog("effect api available=" .. tostring(effectApiAvailable))
  return effectApiAvailable
end

local function spawnCorpseEffectAt(pos)
  if not pos then
    return false
  end

  if not canUseEffectApi() then
    return false
  end

  -- Most OTC builds use Effect.create(id). Some expose setId afterwards.
  local effect = safeCall(Effect.create, CORPSE_EFFECT_ID)
  if not effect then
    effect = safeCall(Effect.create)
    if not effect then
      return false
    end
    if type(effect.setId) == "function" then
      safeCall(effect.setId, effect, CORPSE_EFFECT_ID)
    else
      return false
    end
  end

  local added = safeCall(g_map.addThing, effect, { x = pos.x, y = pos.y, z = pos.z }, -1)
  return added ~= nil
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

local function getInstanceKey(thing)
  return thing and tostring(thing) or nil
end

local function getStableKey(thing, fallbackPos)
  if not thing then
    return nil
  end

  local pos = safeCall(thing.getPosition, thing) or fallbackPos
  if not pos then
    return nil
  end

  local itemId = safeCall(thing.getId, thing)
  if not itemId then
    return nil
  end

  -- Keep it stable per tile and item id; stackpos can shift when opening a corpse.
  return string.format("%d:%d:%d:%d", pos.x, pos.y, pos.z, itemId)
end

local function getStableKeyFromPosId(pos, itemId)
  if not pos or not itemId then
    return nil
  end
  return string.format("%d:%d:%d:%d", pos.x, pos.y, pos.z, itemId)
end

local function isLootableCorpse(thing)
  if not thing then
    return false
  end

  if not safeCall(thing.isItem, thing) then
    return false
  end

  local itemId = safeCall(thing.getId, thing)
  if not itemId then
    return false
  end

  local itemName = safeCall(thing.getName, thing)
  if type(itemName) == "string" and itemName:lower():find("bag", 1, true) then
    return false
  end

  return LOOTABLE_CORPSE_IDS[itemId] == true
end

local function purgeExpiredOpened(now)
  for key, expiresAt in pairs(openedUntilByStableKey) do
    if expiresAt <= now then
      openedUntilByStableKey[key] = nil
    end
  end
end

local function isOpened(thing, fallbackPos, now)
  now = now or g_clock.millis()
  local stableKey = getStableKey(thing, fallbackPos)
  if not stableKey then
    return false
  end
  return openedUntilByStableKey[stableKey] and openedUntilByStableKey[stableKey] > now
end

local function markOpened(thing, fallbackPos, now)
  now = now or g_clock.millis()
  local instanceKey = getInstanceKey(thing)
  local stableKey = getStableKey(thing, fallbackPos)
  if not stableKey and fallbackPos and thing then
    local itemId = safeCall(function()
      return thing:getId()
    end)
    if itemId then
      stableKey = getStableKeyFromPosId(fallbackPos, itemId)
    end
  end
  if stableKey then
    openedUntilByStableKey[stableKey] = now + OPEN_SUPPRESS_MS

    -- Remove all tracked corpses with the same stable identity immediately.
    for trackedInstanceKey, entry in pairs(trackedByInstanceKey) do
      if entry and entry.stableKey == stableKey then
        clearMark(entry.thing)
        trackedByInstanceKey[trackedInstanceKey] = nil
      end
    end
  end

  -- Fallback for builds where container item position is unavailable on open.
  if instanceKey and trackedByInstanceKey[instanceKey] then
    clearMark(trackedByInstanceKey[instanceKey].thing)
    trackedByInstanceKey[instanceKey] = nil
  end
end

local function markOpenedByPosId(pos, itemId, now)
  now = now or g_clock.millis()
  local stableKey = getStableKeyFromPosId(pos, itemId)
  if not stableKey then
    return
  end

  openedUntilByStableKey[stableKey] = now + OPEN_SUPPRESS_MS
  for trackedInstanceKey, entry in pairs(trackedByInstanceKey) do
    if entry and entry.stableKey == stableKey then
      clearMark(entry.thing)
      trackedByInstanceKey[trackedInstanceKey] = nil
    end
  end
end

local function parsePosFromStableKey(stableKey)
  if type(stableKey) ~= "string" then
    return nil
  end

  local x, y, z = stableKey:match("^(%-?%d+):(%-?%d+):(%-?%d+):")
  if not x or not y or not z then
    return nil
  end

  return {
    x = tonumber(x),
    y = tonumber(y),
    z = tonumber(z),
  }
end

local function sendCorpseOpenToServer(pos, itemId)
  if not pos or not itemId then
    return
  end

  local protocol = g_game.getProtocolGame and g_game.getProtocolGame() or nil
  if not protocol or type(protocol.sendExtendedOpcode) ~= "function" then
    return
  end

  local payload = string.format("open|%d|%d|%d|%d|1", pos.x, pos.y, pos.z, itemId)
  safeCall(protocol.sendExtendedOpcode, protocol, OPCODE_CORPSE_PULSE_OPEN, payload)
end

local function trackCorpse(thing, fallbackPos, color, now)
  if not isLootableCorpse(thing) then
    return false
  end

  local instanceKey = getInstanceKey(thing)
  if not instanceKey then
    return false
  end

  now = now or g_clock.millis()
  if isOpened(thing, fallbackPos, now) then
    if trackedByInstanceKey[instanceKey] then
      clearMark(thing)
      trackedByInstanceKey[instanceKey] = nil
    end
    return false
  end

  trackedByInstanceKey[instanceKey] = {
    thing = thing,
    stableKey = getStableKey(thing, fallbackPos),
  }
  setMark(thing, color)
  return true
end

local function untrackCorpse(thing, fallbackPos)
  if not thing then
    return
  end

  local instanceKey = getInstanceKey(thing)
  if instanceKey and trackedByInstanceKey[instanceKey] then
    clearMark(trackedByInstanceKey[instanceKey].thing)
    trackedByInstanceKey[instanceKey] = nil
  else
    clearMark(thing)
  end

  local stableKey = getStableKey(thing, fallbackPos)
  if stableKey then
    openedUntilByStableKey[stableKey] = nil
  end
end

local function scanVisibleCorpses(color, now)
  local player = g_game.getLocalPlayer()
  if not player then
    return
  end

  local playerPos = player:getPosition()
  if not playerPos then
    return
  end

  local visible = {}
  local tiles = g_map.getTiles(playerPos.z) or {}
  for _, tile in ipairs(tiles) do
    local tilePos = safeCall(tile.getPosition, tile)
    local things = safeCall(tile.getThings, tile)
    if type(things) == "table" then
      for _, thing in ipairs(things) do
        if isLootableCorpse(thing) then
          local instanceKey = getInstanceKey(thing)
          if instanceKey then
            visible[instanceKey] = true
          end
          trackCorpse(thing, tilePos, color, now)
        end
      end
    end
  end

  for instanceKey, entry in pairs(trackedByInstanceKey) do
    if not visible[instanceKey] then
      clearMark(entry.thing)
      trackedByInstanceKey[instanceKey] = nil
    end
  end
end

local function tryMarkByPayload(data, retriesLeft)
  local tile = g_map.getTile({ x = data.x, y = data.y, z = data.z })
  if not tile then
    if retriesLeft > 0 then
      scheduleEvent(function() tryMarkByPayload(data, retriesLeft - 1) end, 60)
    end
    return
  end

  local things = safeCall(tile.getThings, tile)
  if type(things) ~= "table" then
    if retriesLeft > 0 then
      scheduleEvent(function() tryMarkByPayload(data, retriesLeft - 1) end, 60)
    end
    return
  end

  for _, thing in ipairs(things) do
    if isLootableCorpse(thing) and safeCall(thing.getId, thing) == data.id then
      trackCorpse(thing, { x = data.x, y = data.y, z = data.z }, PULSE_SEQUENCE[pulseIndex], g_clock.millis())
      return
    end
  end

  if retriesLeft > 0 then
    scheduleEvent(function() tryMarkByPayload(data, retriesLeft - 1) end, 60)
  end
end

local function parsePayload(buffer)
  if type(buffer) ~= "string" or buffer == "" then
    return nil
  end

  if buffer:sub(1, 1) == "{" and json and json.decode then
    return safeCall(json.decode, buffer)
  end

  local action, x, y, z, id = buffer:match("^([%a_]+)|(%-?%d+)|(%-?%d+)|(%-?%d+)|(%-?%d+)")
  if not action then
    return nil
  end

  return {
    action = action,
    data = {
      x = tonumber(x),
      y = tonumber(y),
      z = tonumber(z),
      id = tonumber(id),
    },
  }
end

local function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_CORPSE_PULSE then
    return
  end

  debugLog("opcode 112 received")

  local payload = parsePayload(buffer)
  if type(payload) ~= "table" or type(payload.data) ~= "table" then
    debugLog("opcode payload invalid")
    return
  end

  if tostring(payload.action or "") ~= "spawn" then
    debugLog("opcode action ignored: " .. tostring(payload.action))
    return
  end

  local data = payload.data
  if not data.x or not data.y or not data.z or not data.id then
    debugLog("opcode missing fields")
    return
  end

  if not LOOTABLE_CORPSE_IDS[data.id] then
    debugLog("opcode corpse id not lootable: " .. tostring(data.id))
    return
  end

  debugLog(string.format("opcode spawn x=%d y=%d z=%d id=%d", data.x, data.y, data.z, data.id))
  tryMarkByPayload(data, 4)
end

local function onTileAddThing(tile, thing)
  if not g_game.isOnline() then
    return
  end

  if not isLootableCorpse(thing) then
    return
  end

  local tilePos = safeCall(tile.getPosition, tile)
  local itemId = safeCall(thing.getId, thing) or -1
  if tilePos then
    debugLog(string.format("tile add corpse id=%d at %d,%d,%d", itemId, tilePos.x, tilePos.y, tilePos.z))
  else
    debugLog(string.format("tile add corpse id=%d at unknown pos", itemId))
  end
  trackCorpse(thing, tilePos, PULSE_SEQUENCE[pulseIndex], g_clock.millis())
end

local function onTileRemoveThing(tile, thing)
  if not isLootableCorpse(thing) then
    return
  end

  local tilePos = safeCall(tile.getPosition, tile)
  local itemId = safeCall(thing.getId, thing) or -1
  if tilePos then
    debugLog(string.format("tile remove corpse id=%d at %d,%d,%d", itemId, tilePos.x, tilePos.y, tilePos.z))
  end
  untrackCorpse(thing, tilePos)
end

local function onContainerOpen(container, previousContainer)
  local containerItem = safeCall(function()
    return container:getContainerItem()
  end)
  if not isLootableCorpse(containerItem) then
    return
  end

  local pos = safeCall(containerItem.getPosition, containerItem)
  if not pos then
    local instanceKey = getInstanceKey(containerItem)
    local tracked = instanceKey and trackedByInstanceKey[instanceKey] or nil
    if tracked and tracked.stableKey then
      pos = parsePosFromStableKey(tracked.stableKey)
    end
  end

  local itemId = safeCall(containerItem.getId, containerItem) or -1
  if pos then
    debugLog(string.format("container open corpse id=%d at %d,%d,%d", itemId, pos.x, pos.y, pos.z))
  else
    debugLog(string.format("container open corpse id=%d at unknown pos", itemId))
  end
  markOpened(containerItem, pos, g_clock.millis())
  if pos and itemId and itemId > 0 then
    sendCorpseOpenToServer(pos, itemId)
  end
end

local function onUseItem(pos, itemId, stackPos, subType)
  if not g_game.isOnline() then
    return
  end

  if not pos or not itemId or not LOOTABLE_CORPSE_IDS[itemId] then
    return
  end

  local now = g_clock.millis()
  markOpenedByPosId(pos, itemId, now)
  sendCorpseOpenToServer(pos, itemId)
  debugLog(string.format("use corpse id=%d at %d,%d,%d", itemId, pos.x, pos.y, pos.z))
end

local function processRightClickCorpse(useThing, fallbackPos)
  if not useThing or not isLootableCorpse(useThing) then
    return
  end

  local pos = safeCall(useThing.getPosition, useThing) or fallbackPos
  local itemId = safeCall(useThing.getId, useThing)
  if not pos or not itemId then
    return
  end

  local now = g_clock.millis()
  markOpenedByPosId(pos, itemId, now)
  sendCorpseOpenToServer(pos, itemId)
  debugLog(string.format("right click corpse id=%d at %d,%d,%d", itemId, pos.x, pos.y, pos.z))
end

local function installProcessMouseActionHook()
  if processMouseActionHookInstalled then
    return true
  end

  if not modules or not modules.game_interface then
    return false
  end

  local current = modules.game_interface.processMouseAction
  if type(current) ~= "function" then
    return false
  end

  originalProcessMouseAction = current
  modules.game_interface.processMouseAction = function(menuPosition, mouseButton, autoWalkPos, lookThing, useThing, creatureThing, attackCreature, marking)
    if not marking and mouseButton == MouseRightButton and useThing then
      processRightClickCorpse(useThing, autoWalkPos)
    end
    return originalProcessMouseAction(menuPosition, mouseButton, autoWalkPos, lookThing, useThing, creatureThing, attackCreature, marking)
  end

  processMouseActionHookInstalled = true
  debugLog("processMouseAction hook installed")
  return true
end

local function uninstallProcessMouseActionHook()
  if not processMouseActionHookInstalled then
    return
  end

  if modules and modules.game_interface and type(originalProcessMouseAction) == "function" then
    modules.game_interface.processMouseAction = originalProcessMouseAction
  end

  originalProcessMouseAction = nil
  processMouseActionHookInstalled = false
  debugLog("processMouseAction hook removed")
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

  local now = g_clock.millis()
  purgeExpiredOpened(now)
  scanVisibleCorpses(PULSE_SEQUENCE[pulseIndex], now)

  if DEBUG and now - debugLastPulseAt >= 2000 then
    debugLastPulseAt = now
    debugLog(string.format("pulse tracked=%d openedSuppressed=%d color=%s",
      tableSize(trackedByInstanceKey), tableSize(openedUntilByStableKey), tostring(PULSE_SEQUENCE[pulseIndex])))
  end
end

local function effectPulseTick()
  effectPulseEvent = scheduleEvent(effectPulseTick, EFFECT_PULSE_INTERVAL_MS)

  if not g_game.isOnline() then
    return
  end

  if not ENABLE_CLIENT_EFFECT then
    return
  end

  local emitted = 0
  for _, entry in pairs(trackedByInstanceKey) do
    local thing = entry.thing
    if thing and isLootableCorpse(thing) then
      local pos = safeCall(thing.getPosition, thing)
      if pos and spawnCorpseEffectAt(pos) then
        emitted = emitted + 1
      end
    end
  end

  if DEBUG then
    debugLog("effect emitted count=" .. tostring(emitted))
  end
end

local function startPulse()
  if pulseEvent then
    return
  end
  pulseEvent = scheduleEvent(pulseTick, PULSE_INTERVAL_MS)

  if ENABLE_CLIENT_EFFECT and not effectPulseEvent then
    effectPulseEvent = scheduleEvent(effectPulseTick, EFFECT_PULSE_INTERVAL_MS)
  end
end

local function stopPulse()
  if pulseEvent then
    removeEvent(pulseEvent)
    pulseEvent = nil
  end

  if effectPulseEvent then
    removeEvent(effectPulseEvent)
    effectPulseEvent = nil
  end
end

local function clearAll()
  for _, entry in pairs(trackedByInstanceKey) do
    clearMark(entry.thing)
  end
  trackedByInstanceKey = {}
  openedUntilByStableKey = {}
end

local function onGameStart()
  installProcessMouseActionHook()
  startPulse()
end

local function onGameEnd()
  stopPulse()
  clearAll()
end

function init()
  debugLog("init")
  if g_settings and g_settings.getBoolean and g_settings.set then
    if not g_settings.getBoolean("highlightThingsUnderCursor") then
      g_settings.set("highlightThingsUnderCursor", true)
      debugLog("enabled setting: highlightThingsUnderCursor=true")
    else
      debugLog("setting already enabled: highlightThingsUnderCursor=true")
    end
  end

  if ProtocolGame and ProtocolGame.registerExtendedOpcode then
    ProtocolGame.registerExtendedOpcode(OPCODE_CORPSE_PULSE, onExtendedOpcode)
    debugLog("extended opcode registered")
  end

  if Tile then
    connect(Tile, {
      onAddThing = onTileAddThing,
      onRemoveThing = onTileRemoveThing,
    })
    debugLog("tile callbacks connected")
  else
    debugLog("Tile userdata not available")
  end

  if Container then
    connect(Container, { onOpen = onContainerOpen })
    debugLog("container callback connected")
  else
    debugLog("Container userdata not available")
  end

  connect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
    onUse = onUseItem,
  })
  debugLog("game callbacks connected")

  if g_game.isOnline() then
    debugLog("already online, starting pulse")
    onGameStart()
  end

  installProcessMouseActionHook()
end

function terminate()
  if ProtocolGame and ProtocolGame.unregisterExtendedOpcode then
    pcall(function() ProtocolGame.unregisterExtendedOpcode(OPCODE_CORPSE_PULSE) end)
  end

  if Tile then
    disconnect(Tile, {
      onAddThing = onTileAddThing,
      onRemoveThing = onTileRemoveThing,
    })
  end

  if Container then
    disconnect(Container, { onOpen = onContainerOpen })
  end

  disconnect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
    onUse = onUseItem,
  })

  uninstallProcessMouseActionHook()
  onGameEnd()
end
