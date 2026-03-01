skillsWindow = nil
skillsButton = nil
bonusStatsWindow = nil
bonusStatsButton = nil
bonusRefreshEvent = nil
bonusStatsPollEvent = nil
inventorySignalDeadline = 0
lastObservedSkillValues = {}
syntheticEquipBonusBySkill = {}
serverExtraStatsSnapshot = nil
serverExtraStatsRequestPending = false
lastServerExtraStatsRequestAt = 0

local OPCODE_EXTRA_STATS = 107
local EXTRA_STATS_REQUEST_INTERVAL = 400
local EXTRA_STATS_REQUEST_TIMEOUT = 2500

-- Item ids that provide time-based bonuses while equipped (active forms).
local timedSkillBonusByItem = {
  [2203] = { skillId0 = true }, -- power ring -> fist
  [2206] = { speed = true }, -- time ring -> speed
  [2210] = { skillId2 = true }, -- sword ring
  [2211] = { skillId3 = true }, -- axe ring
  [2212] = { skillId1 = true }, -- club ring
  [7955] = { skillId4 = true }  -- distance ring
}

local function trimText(text)
  if not text then
    return ""
  end
  return text:gsub("^%s+", ""):gsub("%s+$", "")
end

local function shouldDisplayBonusLine(line)
  if not line or line == "" then
    return false
  end

  local lower = line:lower()

  if lower:find("^you see ") or lower:find("^it weighs") or lower:find("^item level:") or lower:find("^item id:") or lower:find("^position:") then
    return false
  end

  if lower:find("^it can only be wielded") then
    return false
  end

  -- Include the vast majority of upgrade-system lines:
  -- +value, any numeric percent, trigger texts and known keyword-based bonuses.
  if line:find("%+") or line:find("%d+%%") or lower:find(" on kill") or lower:find(" on hit") or lower:find(" on attack") then
    return true
  end

  local keywordPatterns = {
    "dodge",
    "reflect",
    "mana shield",
    "heal for",
    "regenerate mana for",
    "more healing",
    "more gold",
    "be revived",
    "explosion on kill",
    "life steal",
    "mana steal"
  }

  for i = 1, #keywordPatterns do
    if lower:find(keywordPatterns[i], 1, true) then
      return true
    end
  end

  return false
end

local statNameAliases = {
  magiclevel = 'Magic Level',
  magiclvl = 'Magic Level',
  mlvl = 'Magic Level',
  criticalhitchance = 'Critical Hit Chance',
  criticalhitdamage = 'Critical Hit Damage',
  criticaldamage = 'Critical Hit Damage',
  critchance = 'Critical Hit Chance',
  critdamage = 'Critical Hit Damage',
  lifeleechchance = 'Life Leech Chance',
  lifeleechamount = 'Life Leech Amount',
  manaleechchance = 'Mana Leech Chance',
  manaleechamount = 'Mana Leech Amount',
  physicalprotection = 'Physical Protection',
  energyprotection = 'Energy Protection',
  earthprotection = 'Earth Protection',
  fireprotection = 'Fire Protection',
  iceprotection = 'Ice Protection',
  holyprotection = 'Holy Protection',
  deathprotection = 'Death Protection',
  elementalprotection = 'Elemental Protection',
  physicalprot = 'Physical Protection',
  energyprot = 'Energy Protection',
  earthprot = 'Earth Protection',
  fireprot = 'Fire Protection',
  iceprot = 'Ice Protection',
  holyprot = 'Holy Protection',
  deathprot = 'Death Protection',
  allprot = 'Elemental Protection',
  damagereflect = 'Damage Reflect',
  reflect = 'Damage Reflect',
  dodge = 'Dodge',
  manaonkill = 'Mana on Kill',
  lifeonkill = 'Life on Kill',
  healthonkill = 'Life on Kill'
}

local function canonicalStatName(name)
  local clean = trimText(name)
  if clean == '' then
    return ''
  end

  local normalized = clean:lower():gsub('[^a-z0-9]+', '')
  return statNameAliases[normalized] or clean
end

local function clearServerExtraStatsSnapshot()
  serverExtraStatsSnapshot = nil
  serverExtraStatsRequestPending = false
  lastServerExtraStatsRequestAt = 0
end

local function requestServerExtraStats(force)
  if not g_game.isOnline() then
    return
  end

  local now = g_clock.millis()
  if serverExtraStatsRequestPending and now - lastServerExtraStatsRequestAt >= EXTRA_STATS_REQUEST_TIMEOUT then
    serverExtraStatsRequestPending = false
  end

  if not force then
    if serverExtraStatsRequestPending then
      return
    end
    if now - lastServerExtraStatsRequestAt < EXTRA_STATS_REQUEST_INTERVAL then
      return
    end
  end

  local protocol = g_game.getProtocolGame()
  if not protocol then
    return
  end

  lastServerExtraStatsRequestAt = now
  serverExtraStatsRequestPending = true
  protocol:sendExtendedOpcode(OPCODE_EXTRA_STATS, json.encode({action = "request"}))
end

local function onExtraStatsExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_EXTRA_STATS then
    return
  end

  serverExtraStatsRequestPending = false

  local ok, payload = pcall(function()
    return json.decode(buffer)
  end)
  if not ok or type(payload) ~= "table" then
    return
  end

  if payload.action ~= "snapshot" or type(payload.data) ~= "table" then
    return
  end

  serverExtraStatsSnapshot = payload.data
  refreshBonusStatsWindow(false)
end

local function collectEquipmentBonusLines(player)
  local counts = {}
  local missingTooltip = false
  local aggregatedTotals = {}

  local function addAggregatedBonus(name, value, isPercent)
    if not name or name == "" or not value then
      return
    end
    local key = trimText(name)
    if key == "" then
      return
    end

    local entry = aggregatedTotals[key]
    if not entry then
      entry = {value = 0, percent = isPercent and true or false}
      aggregatedTotals[key] = entry
    end

    entry.value = entry.value + value
    if isPercent then
      entry.percent = true
    end
  end

  local function parseAggregatedBonusLine(line)
    -- Pattern: "Name +12%" / "Name +12"
    local bonusName, numericValue = line:match("^(.+)%s+%+([%d%.]+)%%+$")
    if bonusName and numericValue then
      addAggregatedBonus(bonusName, tonumber(numericValue) or 0, true)
      return
    end

    bonusName, numericValue = line:match("^(.+)%s+%+([%d%.]+)$")
    if bonusName and numericValue then
      addAggregatedBonus(bonusName, tonumber(numericValue) or 0, false)
      return
    end

    numericValue = line:match("^Regenerate%s+([%d%.]+)%s+Mana%s+on%s+Kill$")
    if numericValue then
      addAggregatedBonus("Mana on Kill", tonumber(numericValue) or 0, false)
      return
    end

    numericValue = line:match("^Regenerate%s+([%d%.]+)%s+Health%s+on%s+Kill$")
    if numericValue then
      addAggregatedBonus("Life on Kill", tonumber(numericValue) or 0, false)
      return
    end

    numericValue = line:match("^Regenerate%s+Mana%s+for%s+([%d%.]+)%%+%s+of%s+dealt%s+damage$")
    if numericValue then
      addAggregatedBonus("Mana Steal", tonumber(numericValue) or 0, true)
      return
    end

    numericValue = line:match("^Heal%s+for%s+([%d%.]+)%%+%s+of%s+dealt%s+damage$")
    if numericValue then
      addAggregatedBonus("Life Steal", tonumber(numericValue) or 0, true)
      return
    end
  end

  local function readTooltipForItem(item)
    local tooltip = item:getTooltip()
    if tooltip and tooltip:len() > 0 then
      return tooltip
    end

    if modules and modules.game_itemtooltip then
      local itemTooltipModule = modules.game_itemtooltip
      if itemTooltipModule.getCachedTooltipForItem then
        local cached = itemTooltipModule.getCachedTooltipForItem(item)
        if cached and cached:len() > 0 then
          return cached
        end
      end
      if itemTooltipModule.requestTooltipForItem then
        itemTooltipModule.requestTooltipForItem(item)
        missingTooltip = true
      end
    end

    return nil
  end

  for slot = InventorySlotFirst, InventorySlotLast do
    local item = player:getInventoryItem(slot)
    if item then
      local tooltip = readTooltipForItem(item)
      if tooltip and tooltip:len() > 0 then
        for rawLine in tooltip:gmatch("[^\r\n]+") do
          local line = trimText(rawLine)
          if shouldDisplayBonusLine(line) then
            counts[line] = (counts[line] or 0) + 1
            parseAggregatedBonusLine(line)
          end
        end
      end
    end
  end

  local lines = {}
  for line, count in pairs(counts) do
    if count > 1 then
      lines[#lines + 1] = string.format("%s x%d", line, count)
    else
      lines[#lines + 1] = line
    end
  end

  table.sort(lines, function(a, b)
    return a:lower() < b:lower()
  end)

  return lines, missingTooltip, aggregatedTotals
end

local function addBonusLine(panel, text, color)
  local label = g_ui.createWidget('GameLabel', panel)
  label:setText(text)
  label:setFont('verdana-11px-monochrome')
  if color then
    label:setColor(color)
  end
end

local function stripLineCountSuffix(line)
  if not line then
    return ''
  end
  return trimText(line):gsub('%s+[xX]%d+$', '')
end

local function parseCanonicalStatNameFromLine(line)
  local clean = stripLineCountSuffix(line)
  if clean == '' then
    return nil
  end

  local bonusName = clean:match("^(.+)%s+%+([%d%.]+)%%+$")
  if bonusName then
    return canonicalStatName(bonusName)
  end

  bonusName = clean:match("^(.+)%s+%+([%d%.]+)$")
  if bonusName then
    return canonicalStatName(bonusName)
  end

  bonusName = clean:match("^(.+):%s*([%d%.]+)%%+$")
  if bonusName then
    return canonicalStatName(bonusName)
  end

  bonusName = clean:match("^(.+):%s*([%d%.]+)$")
  if bonusName then
    return canonicalStatName(bonusName)
  end

  if clean:match("^Regenerate%s+([%d%.]+)%s+Mana%s+on%s+Kill$") then
    return 'Mana on Kill'
  end

  if clean:match("^Regenerate%s+([%d%.]+)%s+Health%s+on%s+Kill$") then
    return 'Life on Kill'
  end

  if clean:match("^Regenerate%s+Mana%s+for%s+([%d%.]+)%%+%s+of%s+dealt%s+damage$") then
    return 'Mana Steal'
  end

  if clean:match("^Heal%s+for%s+([%d%.]+)%%+%s+of%s+dealt%s+damage$") then
    return 'Life Steal'
  end

  return nil
end

local function isTriggerOrSpecialLine(line)
  local clean = stripLineCountSuffix(line)
  if clean == '' then
    return false
  end

  local lower = clean:lower()

  if lower == 'mana shield' then
    return true
  end

  if lower:find(' on attack', 1, true) or lower:find(' on hit', 1, true) or lower:find(' on kill', 1, true) then
    return true
  end

  local keywordPatterns = {
    'to cast ',
    ' to get ',
    ' to regenerate ',
    ' to be revived',
    'deal double damage',
    'more healing',
    'more gold',
    'explosion on kill'
  }

  for i = 1, #keywordPatterns do
    if lower:find(keywordPatterns[i], 1, true) then
      return true
    end
  end

  return false
end

local function refreshBonusStatsWindow(force)
  if not bonusStatsWindow or not bonusStatsButton then
    return
  end

  if not force and not bonusStatsButton:isOn() then
    return
  end

  local player = g_game.getLocalPlayer()
  if not player then
    return
  end

  local listPanel = bonusStatsWindow:recursiveGetChildById('bonusList')
  if not listPanel then
    return
  end

  local scrollBar = bonusStatsWindow:recursiveGetChildById('bonusListScroll')
  local preservedScrollValue = nil
  if scrollBar and scrollBar.getValue then
    local ok, value = pcall(function()
      return scrollBar:getValue()
    end)
    if ok then
      preservedScrollValue = value
    end
  end

  listPanel:destroyChildren()

  if serverExtraStatsSnapshot then
    requestServerExtraStats(false)
  else
    requestServerExtraStats(true)
  end

  local function readSkillValue(skillId)
    return tonumber(player:getSkillLevel(skillId)) or 0
  end

  local usingServerData = type(serverExtraStatsSnapshot) == 'table' and type(serverExtraStatsSnapshot.coreStats) == 'table'
  local equipmentLines = {}
  local aggregatedEntries = {}
  local missingTooltip = false

  local function readTotalPercent(serverSkillId, tooltipName, aggregatedTotals)
    local serverValue = readSkillValue(serverSkillId)
    if serverValue > 0 then
      return serverValue
    end

    local fromTooltip = aggregatedTotals and aggregatedTotals[tooltipName]
    if fromTooltip and fromTooltip.value and fromTooltip.value > 0 then
      return math.floor(fromTooltip.value)
    end

    return 0
  end

  local criticalHitChance = 0
  local criticalHitDamage = 50
  local lifeLeechChance = 25
  local lifeLeechAmount = 0
  local manaLeechChance = 25
  local manaLeechAmount = 0
  local dodgeValue = 0
  local reflectValue = 0

  if usingServerData then
    local coreStats = serverExtraStatsSnapshot.coreStats
    criticalHitChance = math.floor(tonumber(coreStats.criticalChance) or 0)
    criticalHitDamage = math.floor(tonumber(coreStats.criticalDamage) or 50)
    lifeLeechChance = math.floor(tonumber(coreStats.lifeLeechChance) or 25)
    lifeLeechAmount = math.floor(tonumber(coreStats.lifeLeechAmount) or 0)
    manaLeechChance = math.floor(tonumber(coreStats.manaLeechChance) or 25)
    manaLeechAmount = math.floor(tonumber(coreStats.manaLeechAmount) or 0)
    dodgeValue = math.floor(tonumber(coreStats.dodge) or 0)
    reflectValue = math.floor(tonumber(coreStats.reflect) or 0)

    if type(serverExtraStatsSnapshot.aggregatedBonuses) == 'table' then
      for i = 1, #serverExtraStatsSnapshot.aggregatedBonuses do
        local entry = serverExtraStatsSnapshot.aggregatedBonuses[i]
        if type(entry) == 'table' then
          local entryName = trimText(tostring(entry.name or ''))
          if entryName ~= '' then
            aggregatedEntries[#aggregatedEntries + 1] = {
              name = entryName,
              value = math.floor(tonumber(entry.value) or 0),
              percent = entry.percent and true or false
            }
          end
        end
      end
    end

    if type(serverExtraStatsSnapshot.equipmentLines) == 'table' then
      for i = 1, #serverExtraStatsSnapshot.equipmentLines do
        local line = trimText(tostring(serverExtraStatsSnapshot.equipmentLines[i] or ''))
        if line ~= '' then
          equipmentLines[#equipmentLines + 1] = line
        end
      end
    end
  else
    local tooltipLines, tooltipMissing, aggregatedTotals = collectEquipmentBonusLines(player)
    equipmentLines = tooltipLines
    missingTooltip = tooltipMissing

    criticalHitChance = readTotalPercent(Skill.CriticalChance, "Critical Hit Chance", aggregatedTotals)
    criticalHitDamage = 50 + readTotalPercent(Skill.CriticalDamage, "Critical Hit Damage", aggregatedTotals)
    lifeLeechChance = 25 + readTotalPercent(Skill.LifeLeechChance, "Life Leech Chance", aggregatedTotals)
    lifeLeechAmount = readTotalPercent(Skill.LifeLeechAmount, "Life Leech Amount", aggregatedTotals)
    manaLeechChance = 25 + readTotalPercent(Skill.ManaLeechChance, "Mana Leech Chance", aggregatedTotals)
    manaLeechAmount = readTotalPercent(Skill.ManaLeechAmount, "Mana Leech Amount", aggregatedTotals)
    dodgeValue = math.floor((aggregatedTotals["Dodge"] and aggregatedTotals["Dodge"].value) or 0)
    reflectValue = math.floor((aggregatedTotals["Damage Reflect"] and aggregatedTotals["Damage Reflect"].value) or 0)

    for key, entry in pairs(aggregatedTotals) do
      aggregatedEntries[#aggregatedEntries + 1] = {
        name = key,
        value = math.floor(tonumber(entry.value) or 0),
        percent = entry.percent and true or false
      }
    end
  end

  local mergedByKey = {}

  local function mergeStat(name, value, isPercent, authoritative)
    local label = canonicalStatName(name)
    if label == '' then
      return
    end

    local numericValue = math.floor(tonumber(value) or 0)
    local key = label:lower()
    local entry = mergedByKey[key]
    if not entry then
      entry = {name = label, value = 0, percent = false, authoritative = false}
      mergedByKey[key] = entry
    end

    if authoritative then
      entry.value = numericValue
      entry.authoritative = true
    elseif not entry.authoritative then
      entry.value = entry.value + numericValue
    end

    if isPercent then
      entry.percent = true
    end
  end

  mergeStat('Critical Hit Chance', criticalHitChance, true, true)
  mergeStat('Critical Hit Damage', criticalHitDamage, true, true)
  mergeStat('Life Leech Chance', lifeLeechChance, true, true)
  mergeStat('Life Leech Amount', lifeLeechAmount, true, true)
  mergeStat('Mana Leech Chance', manaLeechChance, true, true)
  mergeStat('Mana Leech Amount', manaLeechAmount, true, true)
  mergeStat('Dodge', dodgeValue, true, true)
  mergeStat('Damage Reflect', reflectValue, true, true)

  for i = 1, #aggregatedEntries do
    local entry = aggregatedEntries[i]
    mergeStat(entry.name, entry.value, entry.percent and true or false, false)
  end

  local mergedEntries = {}
  for _, entry in pairs(mergedByKey) do
    mergedEntries[#mergedEntries + 1] = entry
  end

  table.sort(mergedEntries, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  local coreCombatOrder = {
    'Critical Hit Chance',
    'Critical Hit Damage',
    'Life Leech Amount',
    'Life Leech Chance',
    'Mana Leech Amount',
    'Mana Leech Chance'
  }

  local skillAndSpeedLookup = {
    ['fist fighting'] = true,
    ['club fighting'] = true,
    ['sword fighting'] = true,
    ['axe fighting'] = true,
    ['distance fighting'] = true,
    ['shielding'] = true,
    ['fishing'] = true,
    ['magic level'] = true,
    ['speed'] = true
  }

  local coreLookup = {}
  local coreEntries = {}
  local skillEntries = {}
  local otherEntries = {}
  local triggerEntries = {}

  for i = 1, #coreCombatOrder do
    local key = coreCombatOrder[i]:lower()
    coreLookup[key] = true
    local entry = mergedByKey[key]
    if entry then
      coreEntries[#coreEntries + 1] = entry
    end
  end

  for i = 1, #mergedEntries do
    local entry = mergedEntries[i]
    local key = entry.name:lower()
    if coreLookup[key] then
      -- already rendered in fixed order
    elseif skillAndSpeedLookup[key] then
      skillEntries[#skillEntries + 1] = entry
    else
      otherEntries[#otherEntries + 1] = entry
    end
  end

  local mergedLookup = {}
  for key, _ in pairs(mergedByKey) do
    mergedLookup[key] = true
  end

  local seenTriggerLine = {}
  for i = 1, #equipmentLines do
    local line = trimText(equipmentLines[i])
    if line ~= '' and isTriggerOrSpecialLine(line) then
      local canonicalName = parseCanonicalStatNameFromLine(line)
      local alreadyInMerged = canonicalName and mergedLookup[canonicalName:lower()]
      if not alreadyInMerged then
        local key = line:lower()
        if not seenTriggerLine[key] then
          seenTriggerLine[key] = true
          triggerEntries[#triggerEntries + 1] = line
        end
      end
    end
  end

  table.sort(triggerEntries, function(a, b)
    return a:lower() < b:lower()
  end)

  local hasAnyDisplayEntries = (#mergedEntries > 0) or (#triggerEntries > 0)

  if not hasAnyDisplayEntries then
    if serverExtraStatsRequestPending then
      addBonusLine(listPanel, tr('Loading server extra stats...'), '#9a9a9a')
    elseif missingTooltip and not usingServerData then
      addBonusLine(listPanel, tr('Loading equipped item bonuses...'), '#9a9a9a')
    else
      addBonusLine(listPanel, tr('No summed stats detected.'), '#9a9a9a')
    end
  else
    addBonusLine(listPanel, ' ', nil)
    addBonusLine(listPanel, tr('1. Core Combat Stats'), '#f15a5a')
    if #coreEntries == 0 then
      addBonusLine(listPanel, tr('No core combat stats.'), '#9a9a9a')
    else
      for i = 1, #coreEntries do
        local entry = coreEntries[i]
        local suffix = entry.percent and "%" or ""
        addBonusLine(listPanel, string.format("%s: %d%s", entry.name, math.floor(entry.value), suffix), '#d4d4d4')
      end
    end

    addBonusLine(listPanel, ' ', nil)
    addBonusLine(listPanel, tr('2. Skill Stats + Speed'), '#f15a5a')
    if #skillEntries == 0 then
      addBonusLine(listPanel, tr('No skill/speed bonuses.'), '#9a9a9a')
    else
      for i = 1, #skillEntries do
        local entry = skillEntries[i]
        local suffix = entry.percent and "%" or ""
        addBonusLine(listPanel, string.format("%s: %d%s", entry.name, math.floor(entry.value), suffix), '#d4d4d4')
      end
    end

    addBonusLine(listPanel, ' ', nil)
    addBonusLine(listPanel, tr('3. Other Stats'), '#f15a5a')
    if #otherEntries == 0 then
      addBonusLine(listPanel, tr('No other bonuses.'), '#9a9a9a')
    else
      for i = 1, #otherEntries do
        local entry = otherEntries[i]
        local suffix = entry.percent and "%" or ""
        addBonusLine(listPanel, string.format("%s: %d%s", entry.name, math.floor(entry.value), suffix), '#d4d4d4')
      end
    end

    addBonusLine(listPanel, ' ', nil)
    addBonusLine(listPanel, tr('4. Trigger / Special Effects'), '#f15a5a')
    if #triggerEntries == 0 then
      addBonusLine(listPanel, tr('No trigger/special effects.'), '#9a9a9a')
    else
      for i = 1, #triggerEntries do
        addBonusLine(listPanel, triggerEntries[i], '#d4d4d4')
      end
    end
  end

  local lineCount = 0
  if not hasAnyDisplayEntries then
    lineCount = lineCount + 1
  else
    lineCount = lineCount + 12 + #coreEntries + #skillEntries + #otherEntries + #triggerEntries
    if #coreEntries == 0 then
      lineCount = lineCount + 1
    end
    if #skillEntries == 0 then
      lineCount = lineCount + 1
    end
    if #otherEntries == 0 then
      lineCount = lineCount + 1
    end
    if #triggerEntries == 0 then
      lineCount = lineCount + 1
    end
  end

  bonusStatsWindow:setContentMinimumHeight(44)
  bonusStatsWindow:setContentMaximumHeight(math.max(200, math.min(620, lineCount * 15)))

  if scrollBar and preservedScrollValue ~= nil and scrollBar.setValue then
    scheduleEvent(function()
      if scrollBar and scrollBar.setValue then
        pcall(function()
          scrollBar:setValue(preservedScrollValue)
        end)
      end
    end, 1)
  end
end

local function startBonusStatsPolling()
  if bonusStatsPollEvent then
    bonusStatsPollEvent:cancel()
    bonusStatsPollEvent = nil
  end
  -- Disabled intentionally: panel is updated by server snapshot pushes and key events.
end

local function stopBonusStatsPolling()
  if bonusStatsPollEvent then
    bonusStatsPollEvent:cancel()
    bonusStatsPollEvent = nil
  end
end

local function hasTimedBonusForSkill(id)
  local player = g_game.getLocalPlayer()
  if not player then
    return false
  end

  for slot = InventorySlotFirst, InventorySlotLast do
    local item = player:getInventoryItem(slot)
    if item then
      local itemMap = timedSkillBonusByItem[item:getId()]
      if itemMap and itemMap[id] then
        return true
      end
    end
  end

  return false
end

local function refreshBonusDisplay()
  local player = g_game.getLocalPlayer()
  if not player then
    return
  end

  onBaseSpeedChange(player, player:getBaseSpeed())
  onBaseMagicLevelChange(player, player:getBaseMagicLevel())
  for i = Skill.Fist, Skill.ManaLeechAmount do
    onBaseSkillChange(player, i, player:getSkillBaseLevel(i))
  end
end

local function scheduleBonusDisplayRefresh(delay)
  if bonusRefreshEvent then
    bonusRefreshEvent:cancel()
    bonusRefreshEvent = nil
  end

  bonusRefreshEvent = scheduleEvent(function()
    bonusRefreshEvent = nil
    refreshBonusDisplay()
  end, delay or 75)
end

local function onSkillsInventoryChange(localPlayer, slot, item, oldItem)
  inventorySignalDeadline = g_clock.millis() + 1200
  -- Refresh immediately and once again shortly after equip/deequip packets settle.
  requestServerExtraStats(true)
  refreshBonusDisplay()
  refreshBonusStatsWindow(false)
  scheduleBonusDisplayRefresh(75)
end

function init()
  clearServerExtraStatsSnapshot()

  connect(LocalPlayer, {
    onExperienceChange = onExperienceChange,
    onLevelChange = onLevelChange,
    onHealthChange = onHealthChange,
    onManaChange = onManaChange,
    onSoulChange = onSoulChange,
    onFreeCapacityChange = onFreeCapacityChange,
    onTotalCapacityChange = onTotalCapacityChange,
    onStaminaChange = onStaminaChange,
    onOfflineTrainingChange = onOfflineTrainingChange,
    onRegenerationChange = onRegenerationChange,
    onSpeedChange = onSpeedChange,
    onBaseSpeedChange = onBaseSpeedChange,
    onMagicLevelChange = onMagicLevelChange,
    onBaseMagicLevelChange = onBaseMagicLevelChange,
    onSkillChange = onSkillChange,
    onBaseSkillChange = onBaseSkillChange,
    onInventoryChange = onSkillsInventoryChange
  })
  connect(g_game, {
    onGameStart = refresh,
    onGameEnd = offline
  })

  ProtocolGame.registerExtendedOpcode(OPCODE_EXTRA_STATS, onExtraStatsExtendedOpcode)

  skillsButton = modules.client_topmenu.addRightGameToggleButton('skillsButton', tr('Skills'), '/images/topbuttons/skills', toggle, false, 1)
  skillsButton:setOn(true)
  skillsWindow = g_ui.loadUI('skills', modules.game_interface.getRightPanel())
  bonusStatsButton = modules.client_topmenu.addRightGameToggleButton('bonusStatsButton', tr('Extra Stats'), '/images/topbuttons/skills_red', toggleBonusStats, false, 2)
  bonusStatsButton:setOn(false)
  bonusStatsWindow = g_ui.loadUI('bonus_stats', modules.game_interface.getRightPanel())
  
  refresh()
  skillsWindow:setup()
  bonusStatsWindow:setup()
end

function terminate()
  if bonusRefreshEvent then
    bonusRefreshEvent:cancel()
    bonusRefreshEvent = nil
  end
  stopBonusStatsPolling()
  clearServerExtraStatsSnapshot()

  disconnect(LocalPlayer, {
    onExperienceChange = onExperienceChange,
    onLevelChange = onLevelChange,
    onHealthChange = onHealthChange,
    onManaChange = onManaChange,
    onSoulChange = onSoulChange,
    onFreeCapacityChange = onFreeCapacityChange,
    onTotalCapacityChange = onTotalCapacityChange,
    onStaminaChange = onStaminaChange,
    onOfflineTrainingChange = onOfflineTrainingChange,
    onRegenerationChange = onRegenerationChange,
    onSpeedChange = onSpeedChange,
    onBaseSpeedChange = onBaseSpeedChange,
    onMagicLevelChange = onMagicLevelChange,
    onBaseMagicLevelChange = onBaseMagicLevelChange,
    onSkillChange = onSkillChange,
    onBaseSkillChange = onBaseSkillChange,
    onInventoryChange = onSkillsInventoryChange
  })
  disconnect(g_game, {
    onGameStart = refresh,
    onGameEnd = offline
  })
  pcall(function() ProtocolGame.unregisterExtendedOpcode(OPCODE_EXTRA_STATS) end)

  skillsWindow:destroy()
  skillsButton:destroy()
  bonusStatsWindow:destroy()
  bonusStatsButton:destroy()
end

function expForLevel(level)
  return math.floor((50*level*level*level)/3 - 100*level*level + (850*level)/3 - 200)
end

function expToAdvance(currentLevel, currentExp)
  return expForLevel(currentLevel+1) - currentExp
end

function resetSkillColor(id)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setColor('#bbbbbb')
end

function toggleSkill(id, state)
  local skill = skillsWindow:recursiveGetChildById(id)
  skill:setVisible(state)
end

function setSkillBase(id, value, baseValue)
  if value < 0 then
    return
  end
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  local hasBase = type(baseValue) == 'number' and baseValue > 0
  local bonus = hasBase and (value - baseValue) or 0
  local timedBonusActive = hasTimedBonusForSkill(id)
  local oldValue = lastObservedSkillValues[id]

  if oldValue ~= nil and g_clock.millis() <= inventorySignalDeadline then
    local delta = value - oldValue
    if delta ~= 0 then
      syntheticEquipBonusBySkill[id] = (syntheticEquipBonusBySkill[id] or 0) + delta
      if syntheticEquipBonusBySkill[id] == 0 then
        syntheticEquipBonusBySkill[id] = nil
      end
    end
  end

  -- If server provides base value, trust it and drop heuristic fallback.
  if hasBase then
    syntheticEquipBonusBySkill[id] = nil
  elseif g_clock.millis() > inventorySignalDeadline then
    -- Prevent stale fallback color when no fresh equipment signal is active.
    syntheticEquipBonusBySkill[id] = nil
  end

  -- Keep classic single-number display; color/tooltip indicate bonus source.
  widget:setText(value)

  if timedBonusActive then
    widget:setColor('#ff3b30') -- red for timed bonus
    if hasBase then
      skill:setTooltip(string.format('Base: %d\nTimed bonus: %+d\nTotal: %d', baseValue, bonus, value))
    else
      skill:setTooltip(string.format('Timed bonus active\nTotal: %d', value))
    end
  elseif (hasBase and bonus > 0) or ((syntheticEquipBonusBySkill[id] or 0) > 0) then
    local staticBonus = hasBase and bonus or (syntheticEquipBonusBySkill[id] or 0)
    if staticBonus == 0 then
      staticBonus = syntheticEquipBonusBySkill[id] or 0
    end
    widget:setColor('#2ecc71') -- green for static/permanent bonus
    if hasBase then
      skill:setTooltip(string.format('Base: %d\nBonus: +%d\nTotal: %d', baseValue, staticBonus, value))
    else
      skill:setTooltip(string.format('Equipment bonus: +%d\nTotal: %d', staticBonus, value))
    end
  elseif hasBase and bonus < 0 then
    widget:setColor('#ff3b30') -- red
    skill:setTooltip(string.format('Base: %d\nBonus: %d\nTotal: %d', baseValue, bonus, value))
  else
    widget:setColor('#bbbbbb') -- default
    skill:removeTooltip()
  end

  lastObservedSkillValues[id] = value
end

function setSkillValue(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setText(value)
end

function setSkillColor(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setColor(value)
end

function setSkillTooltip(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setTooltip(value)
end

function setSkillPercent(id, percent, tooltip, color)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('percent')
  if widget then
    widget:setPercent(math.floor(percent))

    if tooltip then
      widget:setTooltip(tooltip)
    end

    if color then
    	widget:setBackgroundColor(color)
    end
  end
end

function checkAlert(id, value, maxValue, threshold, greaterThan)
  if greaterThan == nil then greaterThan = false end
  local alert = false

  -- maxValue can be set to false to check value and threshold
  -- used for regeneration checking
  if type(maxValue) == 'boolean' then
    if maxValue then
      return
    end

    if greaterThan then
      if value > threshold then
        alert = true
      end
    else
      if value < threshold then
        alert = true
      end
    end
  elseif type(maxValue) == 'number' then
    if maxValue < 0 then
      return
    end

    local percent = math.floor((value / maxValue) * 100)
    if greaterThan then
      if percent > threshold then
        alert = true
      end
    else
      if percent < threshold then
        alert = true
      end
    end
  end

  if alert then
    setSkillColor(id, '#b22222') -- red
  else
    resetSkillColor(id)
  end
end

function update()
  local offlineTraining = skillsWindow:recursiveGetChildById('offlineTraining')
  if not g_game.getFeature(GameOfflineTrainingTime) then
    offlineTraining:hide()
  else
    offlineTraining:show()
  end

  local regenerationTime = skillsWindow:recursiveGetChildById('regenerationTime')
  if not g_game.getFeature(GamePlayerRegenerationTime) then
    regenerationTime:hide()
  else
    regenerationTime:show()
  end
end

function refresh()
  local player = g_game.getLocalPlayer()
  if not player then return end

  clearServerExtraStatsSnapshot()
  inventorySignalDeadline = 0
  lastObservedSkillValues = {}
  syntheticEquipBonusBySkill = {}

  if expSpeedEvent then expSpeedEvent:cancel() end
  expSpeedEvent = cycleEvent(checkExpSpeed, 30*1000)

  onExperienceChange(player, player:getExperience())
  onLevelChange(player, player:getLevel(), player:getLevelPercent())
  onHealthChange(player, player:getHealth(), player:getMaxHealth())
  onManaChange(player, player:getMana(), player:getMaxMana())
  onSoulChange(player, player:getSoul())
  onFreeCapacityChange(player, player:getFreeCapacity())
  onStaminaChange(player, player:getStamina())
  onMagicLevelChange(player, player:getMagicLevel(), player:getMagicLevelPercent())
  onOfflineTrainingChange(player, player:getOfflineTrainingTime())
  onRegenerationChange(player, player:getRegenerationTime())
  onSpeedChange(player, player:getSpeed())

  local hasAdditionalSkills = g_game.getFeature(GameAdditionalSkills)
  for i = Skill.Fist, Skill.ManaLeechAmount do
    onSkillChange(player, i, player:getSkillLevel(i), player:getSkillLevelPercent(i))
    onBaseSkillChange(player, i, player:getSkillBaseLevel(i))

    if i > Skill.Fishing then
      toggleSkill('skillId'..i, hasAdditionalSkills)
    end
  end

  update()

  local contentsPanel = skillsWindow:getChildById('contentsPanel')
  skillsWindow:setContentMinimumHeight(44)
  if hasAdditionalSkills then
    skillsWindow:setContentMaximumHeight(480)
  else
    skillsWindow:setContentMaximumHeight(390)
  end

  requestServerExtraStats(true)
  refreshBonusStatsWindow(true)
end

function offline()
  if expSpeedEvent then expSpeedEvent:cancel() expSpeedEvent = nil end
  stopBonusStatsPolling()
  clearServerExtraStatsSnapshot()
  inventorySignalDeadline = 0
  lastObservedSkillValues = {}
  syntheticEquipBonusBySkill = {}
end

function toggle()
  if skillsButton:isOn() then
    skillsWindow:close()
    skillsButton:setOn(false)
  else
    skillsWindow:open()
    skillsButton:setOn(true)
  end
end

function toggleBonusStats()
  if bonusStatsButton:isOn() then
    bonusStatsWindow:close()
    bonusStatsButton:setOn(false)
    stopBonusStatsPolling()
  else
    bonusStatsWindow:open()
    bonusStatsButton:setOn(true)
    requestServerExtraStats(true)
    refreshBonusStatsWindow(true)
  end
end

function checkExpSpeed()
  local player = g_game.getLocalPlayer()
  if not player then return end

  local currentExp = player:getExperience()
  local currentTime = g_clock.seconds()
  if player.lastExps ~= nil then
    player.expSpeed = (currentExp - player.lastExps[1][1])/(currentTime - player.lastExps[1][2])
    onLevelChange(player, player:getLevel(), player:getLevelPercent())
  else
    player.lastExps = {}
  end
  table.insert(player.lastExps, {currentExp, currentTime})
  if #player.lastExps > 30 then
    table.remove(player.lastExps, 1)
  end
end

function onMiniWindowClose()
  skillsButton:setOn(false)
end

function onBonusMiniWindowClose()
  bonusStatsButton:setOn(false)
  stopBonusStatsPolling()
end

function onSkillButtonClick(button)
  local percentBar = button:getChildById('percent')
  if percentBar then
    percentBar:setVisible(not percentBar:isVisible())
    if percentBar:isVisible() then
      button:setHeight(21)
    else
      button:setHeight(21 - 6)
    end
  end
end

function onExperienceChange(localPlayer, value)
  local postFix = ""
  if value > 1e15 then
	postFix = "B"
	value = math.floor(value / 1e9)
  elseif value > 1e12 then
	postFix = "M"
	value = math.floor(value / 1e6)
  elseif value > 1e9 then
	postFix = "K"
	value = math.floor(value / 1e3)
  end
  setSkillValue('experience', comma_value(value) .. postFix)
end

function onLevelChange(localPlayer, value, percent)
  setSkillValue('level', value)
  local text = tr('You have %s percent to go', 100 - percent) .. '\n' ..
               comma_value(expToAdvance(localPlayer:getLevel(), localPlayer:getExperience())) .. tr(' of experience left')

  if localPlayer.expSpeed ~= nil then
     local expPerHour = math.floor(localPlayer.expSpeed * 3600)
     if expPerHour > 0 then
        local nextLevelExp = expForLevel(localPlayer:getLevel()+1)
        local hoursLeft = (nextLevelExp - localPlayer:getExperience()) / expPerHour
        local minutesLeft = math.floor((hoursLeft - math.floor(hoursLeft))*60)
        hoursLeft = math.floor(hoursLeft)
        text = text .. '\n' .. comma_value(expPerHour) .. ' of experience per hour'
        text = text .. '\n' .. tr('Next level in %d hours and %d minutes', hoursLeft, minutesLeft)
     end
  end

  setSkillPercent('level', percent, text)
end

function onHealthChange(localPlayer, health, maxHealth)
  setSkillValue('health', health)
  checkAlert('health', health, maxHealth, 30)
end

function onManaChange(localPlayer, mana, maxMana)
  setSkillValue('mana', mana)
  checkAlert('mana', mana, maxMana, 30)
end

function onSoulChange(localPlayer, soul)
  setSkillValue('soul', soul)
end

function onFreeCapacityChange(localPlayer, freeCapacity)
  setSkillValue('capacity', freeCapacity)
  checkAlert('capacity', freeCapacity, localPlayer:getTotalCapacity(), 20)
end

function onTotalCapacityChange(localPlayer, totalCapacity)
  checkAlert('capacity', localPlayer:getFreeCapacity(), totalCapacity, 20)
end

function onStaminaChange(localPlayer, stamina)
  local hours = math.floor(stamina / 60)
  local minutes = stamina % 60
  if minutes < 10 then
    minutes = '0' .. minutes
  end
  local percent = math.floor(100 * stamina / (42 * 60)) -- max is 42 hours --TODO not in all client versions

  setSkillValue('stamina', hours .. ":" .. minutes)

  --TODO not all client versions have premium time
  if stamina > 2400 and g_game.getClientVersion() >= 1038 and localPlayer:isPremium() then
  	local text = tr("You have %s hours and %s minutes left", hours, minutes) .. '\n' ..
		tr("Now you will gain 50%% more experience")
		setSkillPercent('stamina', percent, text, 'green')
	elseif stamina > 2400 and g_game.getClientVersion() >= 1038 and not localPlayer:isPremium() then
		local text = tr("You have %s hours and %s minutes left", hours, minutes) .. '\n' ..
		tr("You will not gain 50%% more experience because you aren't premium player, now you receive only 1x experience points")
		setSkillPercent('stamina', percent, text, '#89F013')
	elseif stamina > 2400 and g_game.getClientVersion() < 1038 then
		local text = tr("You have %s hours and %s minutes left", hours, minutes) .. '\n' ..
		tr("If you are premium player, you will gain 50%% more experience")
		setSkillPercent('stamina', percent, text, 'green')
	elseif stamina <= 2400 and stamina > 840 then
		setSkillPercent('stamina', percent, tr("You have %s hours and %s minutes left", hours, minutes), 'orange')
	elseif stamina <= 840 and stamina > 0 then
		local text = tr("You have %s hours and %s minutes left", hours, minutes) .. "\n" ..
		tr("You gain only 50%% experience and you don't may gain loot from monsters")
		setSkillPercent('stamina', percent, text, 'red')
	elseif stamina == 0 then
		local text = tr("You have %s hours and %s minutes left", hours, minutes) .. "\n" ..
		tr("You don't may receive experience and loot from monsters")
		setSkillPercent('stamina', percent, text, 'black')
	end
end

function onOfflineTrainingChange(localPlayer, offlineTrainingTime)
  if not g_game.getFeature(GameOfflineTrainingTime) then
    return
  end
  local hours = math.floor(offlineTrainingTime / 60)
  local minutes = offlineTrainingTime % 60
  if minutes < 10 then
    minutes = '0' .. minutes
  end
  local percent = 100 * offlineTrainingTime / (12 * 60) -- max is 12 hours

  setSkillValue('offlineTraining', hours .. ":" .. minutes)
  setSkillPercent('offlineTraining', percent, tr('You have %s percent', percent))
end

function onRegenerationChange(localPlayer, regenerationTime)
  if not g_game.getFeature(GamePlayerRegenerationTime) or regenerationTime < 0 then
    return
  end
  local minutes = math.floor(regenerationTime / 60)
  local seconds = regenerationTime % 60
  if seconds < 10 then
    seconds = '0' .. seconds
  end

  setSkillValue('regenerationTime', minutes .. ":" .. seconds)
  checkAlert('regenerationTime', regenerationTime, false, 300)
end

function onSpeedChange(localPlayer, speed)
  setSkillValue('speed', speed)

  onBaseSpeedChange(localPlayer, localPlayer:getBaseSpeed())
end

function onBaseSpeedChange(localPlayer, baseSpeed)
  setSkillBase('speed', localPlayer:getSpeed(), baseSpeed)
end

function onMagicLevelChange(localPlayer, magiclevel, percent)
  setSkillValue('magiclevel', magiclevel)
  setSkillPercent('magiclevel', percent, tr('You have %s percent to go', 100 - percent))

  onBaseMagicLevelChange(localPlayer, localPlayer:getBaseMagicLevel())
end

function onBaseMagicLevelChange(localPlayer, baseMagicLevel)
  setSkillBase('magiclevel', localPlayer:getMagicLevel(), baseMagicLevel)
end

function onSkillChange(localPlayer, id, level, percent)
  setSkillValue('skillId' .. id, level)
  setSkillPercent('skillId' .. id, percent, tr('You have %s percent to go', 100 - percent))

  onBaseSkillChange(localPlayer, id, localPlayer:getSkillBaseLevel(id))
  refreshBonusStatsWindow(false)
end

function onBaseSkillChange(localPlayer, id, baseLevel)
  setSkillBase('skillId'..id, localPlayer:getSkillLevel(id), baseLevel)
  refreshBonusStatsWindow(false)
end
