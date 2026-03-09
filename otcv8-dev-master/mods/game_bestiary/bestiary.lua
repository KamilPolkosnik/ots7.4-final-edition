local OPCODE_BESTIARY = 112

local bestiaryWindow = nil
local bestiaryButton = nil

local jsonData = ""
local respecCost = 5000
local thresholds = {1000, 2000, 3000, 5000, 8000}
local tierPercents = {2, 4, 6, 8, 10}
local entries = {}
local entriesByTaskId = {}
local widgetsByTaskId = {}
local selectedTaskId = nil
local searchText = ""
local refs = {}

local BONUS_LABEL = {
  physical = "Physical",
  fire = "Fire",
  poison = "Poison",
  energy = "Energy",
  death = "Death"
}

local DEBUG = true

local function logBestiary(message)
  if DEBUG and g_logger and g_logger.info then
    g_logger.info("[Bestiary] " .. tostring(message))
  end
end

local function normalizeString(value)
  return tostring(value or ""):lower()
end

local function cloneTable(value)
  if type(value) ~= "table" then
    return nil
  end

  local copy = {}
  for key, data in pairs(value) do
    copy[key] = data
  end
  return copy
end

local function findChildById(root, id)
  if not root or not id or id == "" then
    return nil
  end

  if type(root.recursiveGetChildById) == "function" then
    local found = root:recursiveGetChildById(id)
    if found then
      return found
    end
  end

  if root[id] then
    return root[id]
  end

  if type(root.getChildren) ~= "function" then
    return nil
  end

  for _, child in ipairs(root:getChildren()) do
    if type(child.getId) == "function" and child:getId() == id then
      return child
    end
    local nested = findChildById(child, id)
    if nested then
      return nested
    end
  end
  return nil
end

local function normalizeOutfit(outfit)
  if type(outfit) ~= "table" then
    return nil
  end

  if outfit.type == nil and outfit.lookType ~= nil then
    outfit.type = outfit.lookType
  end
  if outfit.typeEx == nil and outfit.lookTypeEx ~= nil then
    outfit.typeEx = outfit.lookTypeEx
  end
  if outfit.head == nil and outfit.lookHead ~= nil then
    outfit.head = outfit.lookHead
  end
  if outfit.body == nil and outfit.lookBody ~= nil then
    outfit.body = outfit.lookBody
  end
  if outfit.legs == nil and outfit.lookLegs ~= nil then
    outfit.legs = outfit.lookLegs
  end
  if outfit.feet == nil and outfit.lookFeet ~= nil then
    outfit.feet = outfit.lookFeet
  end
  if outfit.addons == nil and outfit.lookAddons ~= nil then
    outfit.addons = outfit.lookAddons
  end
  if outfit.mount == nil and outfit.lookMount ~= nil then
    outfit.mount = outfit.lookMount
  end

  return outfit
end

local function ensureOutfit(outfit)
  local normalized = normalizeOutfit(cloneTable(outfit))
  if not normalized or ((normalized.type or 0) == 0 and (normalized.typeEx or 0) == 0) then
    return {type = 128, lookType = 128}
  end
  return normalized
end

local function safeSetOutfit(widget, outfit)
  if not widget or type(widget.setOutfit) ~= "function" then
    return
  end

  local ok = pcall(function()
    widget:setOutfit(ensureOutfit(outfit))
  end)

  if not ok then
    pcall(function()
      widget:setOutfit({type = 128, lookType = 128})
    end)
  end
end

local function tierToPercent(tierIndex)
  local index = math.max(0, math.floor(tonumber(tierIndex) or 0))
  if index <= 0 then
    return 0
  end
  local configured = tierPercents[index]
  if configured and configured > 0 then
    return configured
  end
  return index * 2
end

local function calculateProgressFromKills(kills)
  local count = math.max(0, math.floor(tonumber(kills) or 0))
  local currentThreshold = 0

  for index, threshold in ipairs(thresholds) do
    if count < threshold then
      local range = threshold - currentThreshold
      local progressPercent = 0
      if range > 0 then
        progressPercent = math.floor(((count - currentThreshold) * 100) / range)
      end
      progressPercent = math.max(0, math.min(100, progressPercent))

      return {
        currentThreshold = currentThreshold,
        nextThreshold = threshold,
        nextBonusPercent = tierToPercent(index),
        progressPercent = progressPercent,
        isMaxTier = false
      }
    end
    currentThreshold = threshold
  end

  local maxThreshold = thresholds[#thresholds] or 0
  return {
    currentThreshold = maxThreshold,
    nextThreshold = maxThreshold,
    nextBonusPercent = tierToPercent(#thresholds),
    progressPercent = 100,
    isMaxTier = true
  }
end

local function hydrateProgress(entry)
  if not entry then
    return
  end

  local hasProgress = (
    entry.currentThreshold ~= nil and
    entry.nextThreshold ~= nil and
    entry.nextBonusPercent ~= nil and
    entry.progressPercent ~= nil and
    entry.isMaxTier ~= nil
  )
  if hasProgress then
    return
  end

  local computed = calculateProgressFromKills(entry.kills)
  entry.currentThreshold = computed.currentThreshold
  entry.nextThreshold = computed.nextThreshold
  entry.nextBonusPercent = computed.nextBonusPercent
  entry.progressPercent = computed.progressPercent
  entry.isMaxTier = computed.isMaxTier
end

local function parseEntryRow(row)
  if type(row) ~= "table" or tonumber(row.taskId) == nil then
    return nil
  end

  local entry = {
    taskId = tonumber(row.taskId),
    name = tostring(row.name or "-"),
    kills = math.max(0, math.floor(tonumber(row.kills) or 0)),
    exp = math.max(0, math.floor(tonumber(row.exp) or 0)),
    bonusPercent = math.max(0, math.floor(tonumber(row.bonusPercent) or 0)),
    bonusType = normalizeString(row.bonusType),
    level = math.max(1, math.floor(tonumber(row.level) or 1)),
    hp = math.max(0, math.floor(tonumber(row.hp) or 0)),
    outfit = normalizeOutfit(cloneTable(row.outfit)),
    currentThreshold = tonumber(row.currentThreshold),
    nextThreshold = tonumber(row.nextThreshold),
    nextBonusPercent = tonumber(row.nextBonusPercent),
    progressPercent = tonumber(row.progressPercent),
    isMaxTier = (row.isMaxTier == true)
  }

  hydrateProgress(entry)
  return entry
end

local function getEntry(taskId)
  return entriesByTaskId[tonumber(taskId) or -1]
end

local function sortEntries()
  table.sort(entries, function(a, b)
    local aid = tonumber(a.taskId) or 0
    local bid = tonumber(b.taskId) or 0
    if aid == bid then
      return normalizeString(a.name) < normalizeString(b.name)
    end
    return aid < bid
  end)
end

local function rebuildIndex()
  entriesByTaskId = {}
  for _, entry in ipairs(entries) do
    local taskId = tonumber(entry.taskId)
    if taskId then
      entriesByTaskId[taskId] = entry
    end
  end
end

local function formatBonus(entry)
  if not entry then
    return "Locked"
  end

  local percent = tonumber(entry.bonusPercent) or 0
  if percent <= 0 then
    return "Locked"
  end

  local bonusType = normalizeString(entry.bonusType)
  if bonusType == "" then
    return string.format("Unlocked +%d%%", percent)
  end

  return string.format("+%d%% %s", percent, BONUS_LABEL[bonusType] or bonusType)
end

local function setButtonState(on)
  if bestiaryButton then
    bestiaryButton:setOn(on and true or false)
  end
end

local function showListView()
  if refs.listView then
    refs.listView:show()
  end
  if refs.detailsView then
    refs.detailsView:hide()
  end
  if refs.backButton then
    refs.backButton:hide()
  end
end

local function showDetailsView()
  if refs.listView then
    refs.listView:hide()
  end
  if refs.detailsView then
    refs.detailsView:show()
  end
  if refs.backButton then
    refs.backButton:show()
  end
end

local function bindWindowRefs()
  refs = {}
  if not bestiaryWindow then
    return
  end

  local ids = {
    "listView", "detailsView", "searchInput", "monstersList",
    "preview", "monsterName", "monsterKills", "monsterLevel", "monsterHp", "monsterXp",
    "monsterTier", "monsterBonus", "progressTitle", "progressBar", "progressText",
    "bonusHint", "bonusButtons", "physical", "fire", "poison", "energy", "death",
    "respecInfo", "backButton", "closeButton"
  }

  for _, id in ipairs(ids) do
    refs[id] = findChildById(bestiaryWindow, id)
  end

  if refs.backButton then
    refs.backButton.onClick = function()
      modules.game_bestiary.closeDetails()
    end
  end
end

local function sendAction(action, data)
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(OPCODE_BESTIARY, json.encode({action = action, data = data or {}}))
  end
end

local function requestSnapshot()
  sendAction("fetch", {})
end

local function parseThresholdList(value)
  if type(value) ~= "table" then
    return
  end

  local parsed = {}
  for _, threshold in ipairs(value) do
    local number = math.floor(tonumber(threshold) or 0)
    if number > 0 then
      table.insert(parsed, number)
    end
  end

  if #parsed <= 0 then
    return
  end

  table.sort(parsed, function(a, b)
    return a < b
  end)
  thresholds = parsed
end

local function updateRowWidget(widget, entry)
  if not widget or not entry then
    return
  end

  hydrateProgress(entry)
  safeSetOutfit(widget.preview, entry.outfit)
  if widget.preview and widget.preview.setCenter then
    widget.preview:setCenter(true)
  end

  widget.info.title:setText(entry.name or "-")
  widget.info.kills:setText(string.format("Kills: %d | Tier: %d%%", tonumber(entry.kills) or 0, tonumber(entry.bonusPercent) or 0))

  if entry.isMaxTier then
    widget.info.progress:setText("Progress: MAX")
  else
    widget.info.progress:setText(
      string.format("Progress: %d%% to +%d%%", tonumber(entry.progressPercent) or 0, tonumber(entry.nextBonusPercent) or 2)
    )
  end

  widget:setTooltip(formatBonus(entry))
end

local function updateDetailsView()
  local entry = getEntry(selectedTaskId)
  if not entry then
    showListView()
    return
  end

  hydrateProgress(entry)

  safeSetOutfit(refs.preview, entry.outfit)
  if refs.preview and refs.preview.setCenter then
    refs.preview:setCenter(true)
  end

  if refs.monsterName then
    refs.monsterName:setText(entry.name or "-")
  end
  if refs.monsterKills then
    refs.monsterKills:setText(string.format("Kills: %d", tonumber(entry.kills) or 0))
  end
  if refs.monsterLevel then
    refs.monsterLevel:setText(string.format("Bestiary Level: %d", tonumber(entry.level) or 1))
  end
  if refs.monsterHp then
    refs.monsterHp:setText(string.format("HP: %d", tonumber(entry.hp) or 0))
  end
  if refs.monsterXp then
    refs.monsterXp:setText(string.format("XP: %d", tonumber(entry.exp) or 0))
  end

  local bonusPercent = tonumber(entry.bonusPercent) or 0
  local bonusType = normalizeString(entry.bonusType)
  local activeBonusText = "none"
  if bonusType ~= "" then
    activeBonusText = BONUS_LABEL[bonusType] or bonusType
  end

  if refs.monsterTier then
    refs.monsterTier:setText(string.format("Tier Bonus: %d%%", bonusPercent))
  end
  if refs.monsterBonus then
    refs.monsterBonus:setText(string.format("Active Bonus: %s", activeBonusText))
  end

  local progressPercent = math.max(0, math.min(100, tonumber(entry.progressPercent) or 0))
  if refs.progressBar then
    refs.progressBar:setPercent(progressPercent)
    refs.progressBar:setText(string.format("%d%%", progressPercent))
  end

  if entry.isMaxTier then
    if refs.progressTitle then
      refs.progressTitle:setText("Progress to next tier: MAX")
    end
    if refs.progressText then
      refs.progressText:setText(
        string.format("Max tier reached at %d+ kills.", tonumber(entry.nextThreshold) or (thresholds[#thresholds] or 0))
      )
    end
  else
    if refs.progressTitle then
      refs.progressTitle:setText(
        string.format("Progress to +%d%% tier", tonumber(entry.nextBonusPercent) or 2)
      )
    end
    if refs.progressText then
      refs.progressText:setText(
        string.format("%d / %d kills", tonumber(entry.kills) or 0, tonumber(entry.nextThreshold) or 0)
      )
    end
  end

  local canChoose = bonusPercent > 0
  if refs.bonusButtons then
    refs.bonusButtons:setVisible(canChoose)
  end

  if refs.bonusHint then
    if canChoose then
      if bonusType ~= "" then
        refs.bonusHint:setText(string.format("Active bonus: +%d%% %s damage against %s.", bonusPercent, BONUS_LABEL[bonusType] or bonusType, entry.name or "-"))
      else
        refs.bonusHint:setText(string.format("Select +%d%% bonus damage for %s.", bonusPercent, entry.name or "-"))
      end
    else
      local requiredKills = tonumber(entry.nextThreshold) or tonumber(thresholds[1]) or 1000
      refs.bonusHint:setText(string.format("Unlock bonus selection at %d kills.", requiredKills))
    end
  end

  if refs.respecInfo then
    refs.respecInfo:setText(string.format("First selection is free. Each bonus type change costs %dgp.", respecCost))
  end

  local function setBonusButton(button, key, label)
    if not button then
      return
    end
    button:setVisible(canChoose)
    button:setEnabled(canChoose)
    local prefix = (bonusType == key) and "[x] " or ""
    button:setText(prefix .. label)
  end

  setBonusButton(refs.physical, "physical", "Physical")
  setBonusButton(refs.fire, "fire", "Fire")
  setBonusButton(refs.poison, "poison", "Poison")
  setBonusButton(refs.energy, "energy", "Energy")
  setBonusButton(refs.death, "death", "Death")
end

local function resolveTaskIdFromWidget(widget)
  local current = widget
  while current do
    local taskId = tonumber(current.taskId)
    if not taskId and type(current.getId) == "function" then
      taskId = tonumber(current:getId())
    end
    if taskId and entriesByTaskId[taskId] then
      return taskId, current
    end
    if type(current.getParent) ~= "function" then
      break
    end
    current = current:getParent()
  end
  return nil, nil
end

function onRowClick(parent, child, reason)
  local taskId = resolveTaskIdFromWidget(child or parent)
  if not taskId then
    return
  end
  selectedTaskId = taskId
  if refs.detailsView and refs.detailsView:isVisible() then
    updateDetailsView()
  end
end

function onMonsterClick(row)
  local taskId, rowWidget = resolveTaskIdFromWidget(row)
  if not taskId then
    return
  end

  selectedTaskId = taskId
  if refs.monstersList and refs.monstersList.focusChild and rowWidget then
    refs.monstersList:focusChild(rowWidget, KeyboardFocusReason)
  end

  showDetailsView()
  updateDetailsView()
end

local function rebuildList()
  if not refs.monstersList then
    return
  end

  local list = refs.monstersList
  list.onChildFocusChange = nil
  list:destroyChildren()
  widgetsByTaskId = {}

  if #entries <= 0 then
    local empty = g_ui.createWidget("Label", list)
    empty:setText("No bestiary data received yet.")
    empty:setColor("#b0b0b0")
    empty:setHeight(26)
    list.onChildFocusChange = onRowClick
    return
  end

  for _, entry in ipairs(entries) do
    local taskId = tonumber(entry.taskId)
    local row = g_ui.createWidget("BestiaryMenuEntry", list)
    row:setId(taskId)
    row.taskId = taskId
    updateRowWidget(row, entry)

    row.onMouseRelease = function(_, mousePosition, mouseButton)
      if mouseButton == MouseLeftButton or mouseButton == 1 then
        onMonsterClick(row)
      end
    end

    if row.preview then
      row.preview.taskId = taskId
      row.preview.onMouseRelease = row.onMouseRelease
    end
    if row.info then
      row.info.taskId = taskId
      row.info.onMouseRelease = row.onMouseRelease
      if row.info.title then
        row.info.title.taskId = taskId
        row.info.title.onMouseRelease = row.onMouseRelease
      end
      if row.info.kills then
        row.info.kills.taskId = taskId
        row.info.kills.onMouseRelease = row.onMouseRelease
      end
      if row.info.progress then
        row.info.progress.taskId = taskId
        row.info.progress.onMouseRelease = row.onMouseRelease
      end
    end

    widgetsByTaskId[taskId] = row
  end

  list.onChildFocusChange = onRowClick
end

local function applySearchFilter()
  if not refs.monstersList then
    return
  end

  if #entries <= 0 then
    return
  end

  local list = refs.monstersList
  local filter = normalizeString(searchText)
  local firstVisible = nil

  for _, row in ipairs(list:getChildren()) do
    local taskId = tonumber(row:getId())
    local entry = getEntry(taskId)
    local visible = false

    if entry then
      visible = (
        filter == "" or
        normalizeString(entry.name):find(filter, 1, true) ~= nil or
        tostring(taskId):find(filter, 1, true) ~= nil
      )
    end

    if visible then
      row:show()
      if not firstVisible then
        firstVisible = row
      end
    else
      row:hide()
    end
  end

  local selectedRow = widgetsByTaskId[selectedTaskId]
  if selectedRow and selectedRow:isVisible() then
    if list.focusChild then
      list:focusChild(selectedRow, KeyboardFocusReason)
    end
  else
    selectedTaskId = firstVisible and tonumber(firstVisible:getId()) or nil
    if firstVisible and list.focusChild then
      list:focusChild(firstVisible, KeyboardFocusReason)
    end
  end

  if refs.detailsView and refs.detailsView:isVisible() then
    if selectedTaskId then
      updateDetailsView()
    else
      showListView()
    end
  end
end

local function onSnapshot(data)
  respecCost = tonumber(data and data.respecCost) or respecCost
  parseThresholdList(data and data.thresholds)

  entries = {}
  if type(data) == "table" and type(data.list) == "table" then
    for _, row in ipairs(data.list) do
      local entry = parseEntryRow(row)
      if entry then
        table.insert(entries, entry)
      end
    end
  end

  sortEntries()
  rebuildIndex()

  if refs.searchInput and refs.searchInput.setText then
    refs.searchInput:setText("")
  end
  searchText = ""
  selectedTaskId = nil

  logBestiary(string.format("snapshot received, entries=%d", #entries))
  rebuildList()
  applySearchFilter()
  showListView()
end

local function onUpdate(data)
  local parsed = parseEntryRow(data)
  if not parsed then
    return
  end

  local current = entriesByTaskId[parsed.taskId]
  if current then
    for key, value in pairs(parsed) do
      current[key] = value
    end
  else
    table.insert(entries, parsed)
  end

  sortEntries()
  rebuildIndex()

  local row = widgetsByTaskId[parsed.taskId]
  if row then
    updateRowWidget(row, parsed)
    applySearchFilter()
  else
    rebuildList()
    applySearchFilter()
  end

  if refs.detailsView and refs.detailsView:isVisible() and tonumber(selectedTaskId) == tonumber(parsed.taskId) then
    updateDetailsView()
  end
end

local function onExtendedOpcode(protocol, code, buffer)
  if type(buffer) ~= "string" or buffer == "" then
    return
  end

  local firstChar = buffer:sub(1, 1)
  local isStartChunk = (firstChar == "S" and buffer:sub(2, 2) == "{")
  local isMiddleChunk = (firstChar == "P" and jsonData ~= "")
  local isEndChunk = (firstChar == "E" and jsonData ~= "")

  if isStartChunk then
    jsonData = buffer:sub(2)
    return
  elseif isMiddleChunk then
    jsonData = jsonData .. buffer:sub(2)
    return
  elseif isEndChunk then
    jsonData = jsonData .. buffer:sub(2)
    buffer = jsonData
    jsonData = ""
  end

  local ok, payload = pcall(function()
    return json.decode(buffer)
  end)
  if not ok or type(payload) ~= "table" then
    return
  end

  if payload.action == "snapshot" then
    onSnapshot(payload.data)
  elseif payload.action == "update" then
    onUpdate(payload.data)
  end
end

function onSearch()
  scheduleEvent(function()
    if not refs.searchInput then
      return
    end
    searchText = refs.searchInput:getText() or ""
    applySearchFilter()
  end, 50)
end

function chooseBonus(bonusType)
  local entry = getEntry(selectedTaskId)
  if not entry then
    return
  end

  if (tonumber(entry.bonusPercent) or 0) <= 0 then
    local requiredKills = tonumber(entry.nextThreshold) or tonumber(thresholds[1]) or 1000
    if modules and modules.game_textmessage and modules.game_textmessage.displayFailureMessage then
      modules.game_textmessage.displayFailureMessage(string.format("You need at least %d kills for this monster.", requiredKills))
    end
    return
  end

  sendAction("choose", {taskId = selectedTaskId, bonusType = tostring(bonusType or "")})
end

local function showWindow()
  if not bestiaryWindow then
    return
  end

  if refs.monstersList and refs.monstersList:getChildCount() == 0 then
    requestSnapshot()
  end

  showListView()
  bestiaryWindow:show()
  bestiaryWindow:raise()
  bestiaryWindow:focus()
  setButtonState(true)
end

local function hideWindow()
  if bestiaryWindow then
    bestiaryWindow:hide()
  end
  setButtonState(false)
end

function closeDetails()
  showListView()
end

function onMainWindowClose()
  closeDetails()
  setButtonState(false)
end

function toggle()
  if not bestiaryWindow then
    return
  end

  if bestiaryWindow:isVisible() then
    hideWindow()
  else
    showWindow()
  end
end

local function onGameStart()
  requestSnapshot()
end

local function onGameEnd()
  hideWindow()
  jsonData = ""
end

function init()
  ProtocolGame.registerExtendedOpcode(OPCODE_BESTIARY, onExtendedOpcode)

  connect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd
  })

  bestiaryButton = modules.client_topmenu.addRightGameToggleButton(
    "bestiaryButton",
    tr("Bestiary"),
    "/images/topbuttons/quest_tracker",
    toggle,
    false,
    26
  )
  bestiaryButton:setOn(false)

  bestiaryWindow = g_ui.displayUI("bestiary")
  bestiaryWindow:hide()
  bindWindowRefs()
  showListView()

  if g_game.isOnline() then
    requestSnapshot()
  end
end

function terminate()
  pcall(function()
    ProtocolGame.unregisterExtendedOpcode(OPCODE_BESTIARY, onExtendedOpcode)
  end)

  disconnect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd
  })

  if bestiaryWindow then
    bestiaryWindow:destroy()
    bestiaryWindow = nil
  end

  if bestiaryButton then
    bestiaryButton:destroy()
    bestiaryButton = nil
  end

  refs = {}
  entries = {}
  entriesByTaskId = {}
  widgetsByTaskId = {}
  selectedTaskId = nil
  searchText = ""
  jsonData = ""
end
