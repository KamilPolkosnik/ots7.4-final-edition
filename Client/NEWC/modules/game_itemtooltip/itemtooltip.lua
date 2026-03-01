local CODE_TOOLTIP = 105
local hoveredWidget = nil
local lastRequest = 0
local REQUEST_DELAY = 150
local originalOnHoverChange = nil
local tooltipCache = {}
local requestQueue = {}
local waitingResponse = false
local activeRequest = nil
local activeRequestTimeoutEvent = nil

local impLabels = {
  a_phys = "Physical Prot",
  a_ene = "Energy Prot",
  a_earth = "Earth Prot",
  a_fire = "Fire Prot",
  a_ldrain = "Lifedrain Prot",
  a_mdrain = "Manadrain Prot",
  a_heal = "Healing Prot",
  a_drown = "Drown Prot",
  a_ice = "Ice Prot",
  a_holy = "Holy Prot",
  a_death = "Death Prot",
  a_all = "All Prot",
  cc = "Crit Chance",
  ca = "Crit Amount",
  lc = "Life Leech Chance",
  la = "Life Leech Amount",
  mc = "Mana Leech Chance",
  ma = "Mana Leech Amount",
  fist = "Fist",
  axe = "Axe",
  sword = "Sword",
  club = "Club",
  dist = "Distance",
  shield = "Shield",
  fish = "Fishing",
  mag = "Magic Level",
  maxhp = "Max HP",
  maxmp = "Max MP",
  maxhp_p = "Max HP%",
  maxmp_p = "Max MP%",
  hpgain = "HP/4s",
  hpticks = "HP ticks",
  mpgain = "MP/4s",
  mpticks = "MP ticks",
  speed = "Speed",
  cap = "Capacity",
  eleDmg = "Element"
}

local function formatImpValue(key, value)
  if type(value) == 'string' then
    return value
  end
  if key:sub(1,2) == 'a_' or key:sub(-2) == '_p' or key == 'cc' or key == 'ca' or key == 'lc' or key == 'la' or key == 'mc' or key == 'ma' then
    return tostring(value) .. "%"
  end
  return tostring(value)
end

local function buildTooltipText(data)
  if not data then return nil end
  local lines = {}
  local name = data.itemName or "Item"
  if data.itemLevel then
    name = name .. " +" .. data.itemLevel
  end
  table.insert(lines, name)

  if data.uniqueName then
    table.insert(lines, data.uniqueName)
  end

  if data.itemType then
    table.insert(lines, "Type: " .. data.itemType)
  end

  if data.reqLvl then
    table.insert(lines, "Req Level: " .. data.reqLvl)
  end

  if data.armor then
    table.insert(lines, "Armor: " .. data.armor)
  end

  if data.attack then
    table.insert(lines, "Attack: " .. data.attack)
  end

  if data.defense then
    local def = "Defense: " .. data.defense
    if data.extraDefense and data.extraDefense > 0 then
      def = def .. " (+" .. data.extraDefense .. ")"
    end
    table.insert(lines, def)
  end

  if data.hitChance then
    table.insert(lines, "Hit Chance: " .. data.hitChance)
  end

  if data.shootRange then
    table.insert(lines, "Range: " .. data.shootRange)
  end

  if data.desc then
    table.insert(lines, data.desc)
  end

  if data.imp then
    for k, v in pairs(data.imp) do
      local label = impLabels[k] or k
      table.insert(lines, label .. ": " .. formatImpValue(k, v))
    end
  end

  if data.weight then
    table.insert(lines, "Weight: " .. data.weight)
  end

  if #lines == 0 then return nil end
  return table.concat(lines, "\n")
end

local function getStackPos(item)
  if item.getStackPos then
    local ok, val = pcall(function() return item:getStackPos() end)
    if ok and val then return val end
  end
  return 0
end

local function getItemCacheKey(item)
  if not item then
    return nil
  end

  local pos = item:getPosition()
  if not pos then
    return nil
  end

  local stack = getStackPos(item)
  return string.format("%d:%d:%d:%d:%d", pos.x or -1, pos.y or -1, pos.z or -1, stack or 0, item:getId() or 0)
end

local function pumpTooltipQueue()
  if waitingResponse or #requestQueue == 0 then
    return
  end

  if not g_game.isOnline() then
    requestQueue = {}
    return
  end

  local now = g_clock.millis()
  if now - lastRequest < REQUEST_DELAY then
    scheduleEvent(pumpTooltipQueue, REQUEST_DELAY)
    return
  end

  local request = table.remove(requestQueue, 1)
  if not request or not request.item then
    scheduleEvent(pumpTooltipQueue, REQUEST_DELAY)
    return
  end

  local item = request.item
  local pos = item:getPosition()
  if not pos then
    scheduleEvent(pumpTooltipQueue, REQUEST_DELAY)
    return
  end

  local protocol = g_game.getProtocolGame()
  if not protocol then
    scheduleEvent(pumpTooltipQueue, REQUEST_DELAY)
    return
  end

  lastRequest = now
  waitingResponse = true
  activeRequest = request
  if activeRequestTimeoutEvent then
    activeRequestTimeoutEvent:cancel()
    activeRequestTimeoutEvent = nil
  end

  protocol:sendExtendedOpcode(CODE_TOOLTIP, json.encode({pos.x, pos.y, pos.z, getStackPos(item)}))

  activeRequestTimeoutEvent = scheduleEvent(function()
    activeRequestTimeoutEvent = nil
    waitingResponse = false
    activeRequest = nil
    pumpTooltipQueue()
  end, 1000)
end

local function enqueueTooltipRequest(item, widget)
  if not item then
    return
  end

  local key = getItemCacheKey(item)
  if not key then
    return
  end

  -- De-duplicate queued request by key.
  for i = 1, #requestQueue do
    if requestQueue[i].key == key then
      -- Prefer a concrete hovered widget if present.
      if widget then
        requestQueue[i].widget = widget
      end
      return
    end
  end

  -- If this exact key is already in-flight, just attach widget (if any).
  if activeRequest and activeRequest.key == key then
    if widget then
      activeRequest.widget = widget
    end
    return
  end

  requestQueue[#requestQueue + 1] = {key = key, item = item, widget = widget}
  pumpTooltipQueue()
end

local function requestTooltip(widget)
  if not g_game.isOnline() then return end
  if not widget or widget:isVirtual() then return end

  local item = widget:getItem()
  if not item then return end

  hoveredWidget = widget
  enqueueTooltipRequest(item, widget)
end

local function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= CODE_TOOLTIP then return end
  local ok, payload = pcall(function() return json.decode(buffer) end)
  if activeRequestTimeoutEvent then
    activeRequestTimeoutEvent:cancel()
    activeRequestTimeoutEvent = nil
  end

  if not ok or not payload or type(payload) ~= 'table' then
    waitingResponse = false
    activeRequest = nil
    scheduleEvent(pumpTooltipQueue, REQUEST_DELAY)
    return
  end
  if payload.action ~= "new" or not payload.data then
    waitingResponse = false
    activeRequest = nil
    scheduleEvent(pumpTooltipQueue, REQUEST_DELAY)
    return
  end

  local text = buildTooltipText(payload.data)
  if not text then
    waitingResponse = false
    activeRequest = nil
    scheduleEvent(pumpTooltipQueue, REQUEST_DELAY)
    return
  end

  if activeRequest and activeRequest.key then
    tooltipCache[activeRequest.key] = text
  end

  local targetWidget = nil
  if activeRequest and activeRequest.widget and activeRequest.widget:getItem() then
    targetWidget = activeRequest.widget
  elseif hoveredWidget and hoveredWidget:getItem() then
    targetWidget = hoveredWidget
  end

  if targetWidget then
    targetWidget:setTooltip(text)
    if g_tooltip and g_tooltip.display and targetWidget:isHovered() then
      g_tooltip.display(text)
    end
  end

  waitingResponse = false
  activeRequest = nil
  scheduleEvent(pumpTooltipQueue, REQUEST_DELAY)
end

function getCachedTooltipForItem(item)
  local key = getItemCacheKey(item)
  if not key then
    return nil
  end
  return tooltipCache[key]
end

function requestTooltipForItem(item)
  enqueueTooltipRequest(item, nil)
end

function hasTooltipRequestPending()
  return waitingResponse or #requestQueue > 0
end

function init()
  ProtocolGame.registerExtendedOpcode(CODE_TOOLTIP, onExtendedOpcode)

  originalOnHoverChange = UIItem.onHoverChange
  function UIItem:onHoverChange(hovered)
    originalOnHoverChange(self, hovered)
    if hovered then
      requestTooltip(self)
    else
      self:removeTooltip()
      if g_tooltip and g_tooltip.hide then g_tooltip.hide() end
      if hoveredWidget == self then hoveredWidget = nil end
    end
  end
end

function terminate()
  if originalOnHoverChange then
    UIItem.onHoverChange = originalOnHoverChange
    originalOnHoverChange = nil
  end

  if pcall(function() ProtocolGame.unregisterExtendedOpcode(CODE_TOOLTIP) end) then end
  hoveredWidget = nil
  tooltipCache = {}
  requestQueue = {}
  waitingResponse = false
  activeRequest = nil
  if activeRequestTimeoutEvent then
    activeRequestTimeoutEvent:cancel()
    activeRequestTimeoutEvent = nil
  end
end
