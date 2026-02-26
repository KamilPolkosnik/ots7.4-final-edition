local OPCODE = 110

local trackerButton = nil
local trackerWindow = nil
local tasksButton = nil

local tasksWindow = nil
local rewardsWindow = nil

local jsonData = ""
local config = {}
local tasks = {}
local tasksById = {}
local rewards = {}
local selectedRewardId = nil
local currentTaskPoints = 0
local rewardPurchaseAmount = 1
local activeTasks = {}
local playerLevel = 0
local currentRewardCategory = "all"
local rewardCategoryWidgets = {}
local currentGameRewardSubcategory = "container"
local gameSubcategoryWidgets = {}
local RewardType = {
  Points = 1,
  Experience = 2,
  Gold = 3,
  Item = 4,
  Storage = 5,
  Teleport = 6
}
local RewardTypeMeta = {
  [RewardType.Points] = {tag = "POINTS", color = "#65dbff"},
  [RewardType.Experience] = {tag = "EXP", color = "#96ff84"},
  [RewardType.Gold] = {tag = "GOLD", color = "#ffd56b"},
  [RewardType.Item] = {tag = "ITEM", color = "#c4b5ff"},
  [RewardType.Storage] = {tag = "UNLOCK", color = "#ffb09a"},
  [RewardType.Teleport] = {tag = "TELEPORT", color = "#8ad9ff"}
}
local RewardCategories = {
  {id = "all", label = "All", description = "All rewards."},
  {id = "gold", label = "Gold", description = "Coins and gold rewards."},
  {id = "potions", label = "Potions", description = "Potions and fluid rewards."},
  {id = "creature", label = "Creature", description = "Creature and summon rewards."},
  {id = "craft", label = "Craft", description = "Crafting materials and forge rewards."},
  {id = "game", label = "Game", description = "Gameplay rewards (points, exp, unlocks, teleports)."},
  {id = "others", label = "Others", description = "Uncategorized rewards."}
}
local GameRewardSubcategories = {
  {id = "container", label = "Container"},
  {id = "usefull", label = "Usefull"},
  {id = "tools", label = "Tools"},
  {id = "others", label = "Others"}
}
local PotionItemIds = {
  [2005] = true, -- flask
  [2006] = true, -- vial
  [2007] = true, -- jug
  [7588] = true,
  [7589] = true,
  [7590] = true,
  [7591] = true,
  [7618] = true,
  [7620] = true,
  [7784] = true,
  [7785] = true,
  [7786] = true,
  [7787] = true,
  [7788] = true,
  [7789] = true,
  [7790] = true
}
local fluidServerToClientSubType = {
  [1] = 1,
  [2] = 5,
  [3] = 3,
  [4] = 6,
  [5] = 8,
  [6] = 9,
  [7] = 2,
  [10] = 11,
  [11] = 13,
  [13] = 12,
  [14] = 15,
  [15] = 10,
  [19] = 4,
  [21] = 14,
  [27] = 7,
  [35] = 16,
  [43] = 17
}
local fluidClientToServerSubType = {
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
local fluidSubtypeByName = {
  ["mana fluid"] = 2,
  ["life fluid"] = 11,
  ["oil"] = 13
}

local DEBUG = true
local function logTasks(msg)
  if DEBUG then
    g_logger.info("[Tasks] " .. msg)
  end
end

local function normalizeOutfit(outfit)
  if not outfit then
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
  outfit = normalizeOutfit(outfit)
  if not outfit or ((outfit.type or 0) == 0 and (outfit.typeEx or 0) == 0) then
    outfit = { type = 128, lookType = 128 }
  end
  return outfit
end

local function getRewardMeta(rewardType)
  return RewardTypeMeta[rewardType] or {tag = "REWARD", color = "#d0d0d0"}
end

local function getRewardCategoryMeta(categoryId)
  for _, category in ipairs(RewardCategories) do
    if category.id == categoryId then
      return category
    end
  end
  return RewardCategories[1]
end

local function classifyGameRewardSubcategory(item)
  if not item then
    return "others"
  end

  local explicitSubcategory = tostring(item.subcategory or ""):lower()
  for _, sub in ipairs(GameRewardSubcategories) do
    if sub.id == explicitSubcategory then
      return explicitSubcategory
    end
  end

  local name = tostring(item.name or ""):lower()
  if name:find("backpack", 1, true) or name:find("bag", 1, true) or name:find("container", 1, true) then
    return "container"
  end
  if name:find("ring", 1, true) then
    return "usefull"
  end
  if
    name:find("rope", 1, true) or name:find("sickle", 1, true) or name:find("machete", 1, true) or
      name:find("scythe", 1, true) or
      name:find("pick", 1, true) or
      name:find("shovel", 1, true) or
      name:find("saw", 1, true) or
      name:find("fishing rod", 1, true) or
      name:find("watch", 1, true) or
      name:find("clock", 1, true)
   then
    return "tools"
  end

  return "others"
end

local function classifyReward(item)
  if not item then
    return "others"
  end

  local rewardType = tonumber(item.type) or RewardType.Item
  local itemId = tonumber(item.id) or 0
  local name = tostring(item.name or ""):lower()
  local explicitCategory = tostring(item.category or ""):lower()

  if explicitCategory ~= "" then
    for _, category in ipairs(RewardCategories) do
      if category.id == explicitCategory then
        return explicitCategory
      end
    end
  end

  if rewardType == RewardType.Gold then
    return "gold"
  end
  if rewardType == RewardType.Points or rewardType == RewardType.Experience or rewardType == RewardType.Storage or rewardType == RewardType.Teleport then
    return "game"
  end
  if PotionItemIds[itemId] then
    return "potions"
  end

  if name:find("coin", 1, true) or name:find("gold", 1, true) then
    return "gold"
  end
  if name:find("potion", 1, true) or name:find("fluid", 1, true) or name:find("vial", 1, true) then
    return "potions"
  end
  if
    name:find("summon", 1, true) or name:find("creature", 1, true) or name:find("egg", 1, true) or
      name:find("pet", 1, true) or
      name:find("mount", 1, true)
   then
    return "creature"
  end
  if
    name:find("craft", 1, true) or name:find("anvil", 1, true) or name:find("material", 1, true) or
      name:find("ore", 1, true) or
      name:find("ingot", 1, true) or
      name:find("essence", 1, true) or
      name:find("upgrade", 1, true)
   then
    return "craft"
  end
  if
    name:find("exp", 1, true) or name:find("experience", 1, true) or name:find("task point", 1, true) or
      name:find("bless", 1, true) or
      name:find("teleport", 1, true) or
      name:find("premium", 1, true)
   then
    return "game"
  end

  return "others"
end

local function normalizeName(name)
  return tostring(name or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
end

local function getFluidDisplaySubTypeFromClient(subType)
  local value = tonumber(subType) or 0
  if g_game.getFeature and g_game.getFeature(GameNewFluids) then
    return value
  end
  return fluidClientToServerSubType[value] or value
end

local function getRewardDisplaySubType(item)
  if not item then
    return nil
  end

  local previewFluidType = tonumber(item.previewFluidType) or 0
  if previewFluidType > 0 then
    return getFluidDisplaySubTypeFromClient(previewFluidType)
  end

  local byName = fluidSubtypeByName[normalizeName(item.name)]
  if byName then
    return getFluidDisplaySubTypeFromClient(byName)
  end

  local fluidType = tonumber(item.fluidType) or 0
  if fluidType > 0 then
    if g_game.getFeature and g_game.getFeature(GameNewFluids) then
      return fluidServerToClientSubType[fluidType] or fluidType
    end
    return fluidType
  end
  return tonumber(item.count) or 1
end

local function updateRewardCategoryHeader()
  if not rewardsWindow then
    return
  end

  local meta = getRewardCategoryMeta(currentRewardCategory)
  local selectedCategory = rewardsWindow:recursiveGetChildById("selectedCategory")
  local description = rewardsWindow:recursiveGetChildById("categoryDescription")
  if selectedCategory then
    selectedCategory:setText("Rewards - " .. meta.label)
  end
  if description then
    description:setText(meta.description)
  end
end

local function formatRewardText(reward)
  if reward.type == RewardType.Points then
    return "Task Points +" .. tostring(reward.value or 0)
  elseif reward.type == RewardType.Experience then
    return "Experience +" .. tostring(reward.value or 0)
  elseif reward.type == RewardType.Gold then
    return "Gold +" .. tostring(reward.value or 0)
  elseif reward.type == RewardType.Item then
    return tostring(reward.amount or 1) .. "x " .. tostring(reward.name or ("Item " .. tostring(reward.id or 0)))
  elseif reward.type == RewardType.Storage then
    return tostring(reward.desc or "Storage unlock")
  elseif reward.type == RewardType.Teleport then
    return "Teleport: " .. tostring(reward.desc or "Unknown destination")
  end
  return tostring(reward.name or "Reward")
end

local function calculateTaskPointsPreview(task, kills)
  local level = math.max(1, tonumber(task and task.lvl) or 1)
  local minKills = tonumber(config.kills and config.kills.Min) or 100
  local maxKills = tonumber(config.kills and config.kills.Max) or 500
  local bonusStep = math.max(1, tonumber(config.bonus) or 100)
  kills = math.max(minKills, math.min(maxKills, tonumber(kills) or minKills))

  local bonusSteps = math.floor(math.max(0, kills - minKills) / bonusStep)
  local basePoints = level
  local totalPoints = basePoints
  local lengthBonusPercent = 0

  if bonusSteps > 0 then
    local lengthMultiplier = 1.1 + (bonusSteps * 0.1) -- 200=>1.2, 300=>1.3, ... 500=>1.5
    totalPoints = math.floor(((level * (kills / minKills) * lengthMultiplier)) + 0.5)
    lengthBonusPercent = math.floor(((lengthMultiplier - 1) * 100) + 0.5)
  end

  local bonusPoints = math.max(0, totalPoints - basePoints)

  if totalPoints < 1 then
    totalPoints = 1
  end

  return totalPoints, basePoints, math.floor(bonusPoints + 0.5), bonusSteps, bonusStep, lengthBonusPercent
end

local _killsValueSync = false
local function snapKillsValue(value)
  local minKills = tonumber(config.kills and config.kills.Min) or 100
  local maxKills = tonumber(config.kills and config.kills.Max) or 500
  local step = math.max(1, tonumber(config.bonus) or 100)
  local numeric = tonumber(value) or minKills
  local snapped = minKills + math.floor(((numeric - minKills) / step) + 0.5) * step
  return math.max(minKills, math.min(maxKills, snapped))
end

local function renderTaskMonsters(task, retryCount)
  if not tasksWindow or not tasksWindow.info or not tasksWindow.info.monsters then
    return
  end

  local monstersPanel = tasksWindow.info.monsters
  local count = #task.mobs
  monstersPanel:destroyChildren()
  if count == 0 then
    return
  end

  local panelWidth = monstersPanel:getWidth()
  local panelHeight = monstersPanel:getHeight()
  retryCount = retryCount or 0
  if (panelWidth <= 0 or panelHeight <= 0) and retryCount < 6 then
    scheduleEvent(function()
      renderTaskMonsters(task, retryCount + 1)
    end, 25)
    return
  end

  local slotSize = 64
  local slotSpacing = 4
  local rowWidth = (count * slotSize) + ((count - 1) * slotSpacing)
  local row = g_ui.createWidget("Panel", monstersPanel)
  row:setSize({width = rowWidth, height = slotSize})
  row:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
  row:addAnchor(AnchorVerticalCenter, "parent", AnchorVerticalCenter)

  for id, monster in ipairs(task.mobs) do
    local widget = g_ui.createWidget("TaskMonsterSlot", row)
    widget:setX((id - 1) * (slotSize + slotSpacing))
    widget:setY(0)
    local outfit = ensureOutfit(task.outfits[id])
    outfit.shader = "default"
    local creatureWidget = widget.creature or widget:getChildById("creature")
    if creatureWidget then
      creatureWidget:setOutfit(outfit)
      creatureWidget:setCenter(true)
      creatureWidget:setPhantom(false)
    end
    widget:setTooltip(monster)
  end
end

local function refreshRewardOfferVisuals()
  if not rewardsWindow then
    return
  end

  local offers = rewardsWindow:recursiveGetChildById("offers")
  if not offers then
    return
  end

  local amountWidget = rewardsWindow:recursiveGetChildById("purchaseAmount")
  local amount = rewardPurchaseAmount
  if amountWidget then
    amount = tonumber(amountWidget:getValue()) or rewardPurchaseAmount
    if amount < 1 then
      amount = 1
      amountWidget:setValue(amount)
    end
    rewardPurchaseAmount = amount
  end

  for _, child in ipairs(offers:getChildren()) do
    local rewardId = tonumber(child:getId())
    local reward = rewards[rewardId]
    if reward then
      local cost = tonumber(reward.cost) or 0
      local affordable = currentTaskPoints >= (cost * amount)
      local selected = selectedRewardId == rewardId

      if child.offerPrice then
        child.offerPrice:setColor(affordable and "#62e15f" or "#db6f6f")
      end
      if child.offerName then
        child.offerName:setColor(affordable and "#efefef" or "#b0b0b0")
      end

      if selected then
        child:setBorderColor(affordable and "#f2c96d" or "#d07b7b")
      else
        child:setBorderColor("#3f454e")
      end

    end
  end

  local purchaseButton = rewardsWindow:recursiveGetChildById("purchaseButton")
  local purchaseCost = rewardsWindow:recursiveGetChildById("purchaseCost")
  local selectedReward = selectedRewardId and rewards[selectedRewardId] or nil
  local singleCost = selectedReward and (tonumber(selectedReward.cost) or 0) or 0
  local totalCost = singleCost * amount
  local canPurchase = selectedReward and currentTaskPoints >= totalCost and amount >= 1

  if purchaseCost then
    purchaseCost:setText("Cost: " .. tostring(totalCost))
    purchaseCost:setColor(canPurchase and "#62e15f" or "#db6f6f")
  end

  if purchaseButton then
    purchaseButton:setText("Buy x" .. tostring(amount))
    purchaseButton:setEnabled(canPurchase and true or false)
  end
end

local function applyRewardsFilters()
  if not rewardsWindow then
    return
  end

  local offers = rewardsWindow:recursiveGetChildById("offers")
  if not offers then
    return
  end

  local searchInput = rewardsWindow:recursiveGetChildById("search")
  local searchText = ""
  if searchInput then
    searchText = tostring(searchInput:getText() or ""):lower()
  end

  local firstVisible = nil
  local selectedVisible = false

  for _, child in ipairs(offers:getChildren()) do
    local rewardId = tonumber(child:getId())
    local reward = rewards[rewardId]
    local rewardName = tostring(reward and reward.name or ""):lower()
    local rewardCategory = classifyReward(reward)
    local categoryOk = currentRewardCategory == "all" or rewardCategory == currentRewardCategory
    local gameSubcategoryOk = true
    if categoryOk and currentRewardCategory == "game" then
      local gameSub = classifyGameRewardSubcategory(reward)
      gameSubcategoryOk = gameSub == currentGameRewardSubcategory
    end
    local searchOk = searchText:len() == 0 or rewardName:find(searchText, 1, true) ~= nil

    if categoryOk and gameSubcategoryOk and searchOk then
      child:show()
      if not firstVisible then
        firstVisible = child
      end
      if selectedRewardId == rewardId then
        selectedVisible = true
      end
    else
      child:hide()
    end
  end

  if not selectedVisible then
    if firstVisible then
      selectedRewardId = tonumber(firstVisible:getId())
      firstVisible:focus()
    else
      selectedRewardId = nil
    end
  end

  refreshRewardOfferVisuals()
end

local function selectGameRewardSubcategory(subcategoryId)
  currentGameRewardSubcategory = subcategoryId or "container"

  for id, widget in pairs(gameSubcategoryWidgets) do
    if widget and widget.setImageColor then
      widget:setImageColor(id == currentGameRewardSubcategory and "#767c88" or "#50545c")
    end
  end

  applyRewardsFilters()
end

local function updateGameSubcategoriesPanel()
  if not rewardsWindow then
    return
  end

  local panel = rewardsWindow:recursiveGetChildById("gameSubcategories")
  if not panel then
    return
  end

  local visible = currentRewardCategory == "game"
  panel:setVisible(visible)
  panel:setHeight(visible and 22 or 0)
end

local function selectRewardCategory(categoryId)
  currentRewardCategory = categoryId or "all"

  for id, widget in pairs(rewardCategoryWidgets) do
    if widget and widget.setImageColor then
      widget:setImageColor(id == currentRewardCategory and "#767c88" or "#50545c")
    end
  end

  updateGameSubcategoriesPanel()
  updateRewardCategoryHeader()
  applyRewardsFilters()
end

local function setupGameSubcategories()
  if not rewardsWindow then
    return
  end

  local panel = rewardsWindow:recursiveGetChildById("gameSubcategories")
  if not panel then
    return
  end

  panel:destroyChildren()
  gameSubcategoryWidgets = {}

  for _, subcategory in ipairs(GameRewardSubcategories) do
    local widget = g_ui.createWidget("ShopCategory", panel)
    widget:setId(subcategory.id)
    widget:setWidth(96)
    widget.name:setText(subcategory.label)
    local onSubcategoryClick = function()
      selectGameRewardSubcategory(subcategory.id)
      return true
    end
    widget.onClick = onSubcategoryClick
    widget.onMouseRelease = onSubcategoryClick
    if widget.name then
      widget.name.onClick = onSubcategoryClick
      widget.name.onMouseRelease = onSubcategoryClick
    end
    gameSubcategoryWidgets[subcategory.id] = widget
  end

  selectGameRewardSubcategory(currentGameRewardSubcategory)
  updateGameSubcategoriesPanel()
end

local function setupRewardCategories()
  if not rewardsWindow then
    return
  end

  local categories = rewardsWindow:recursiveGetChildById("categories")
  if not categories then
    return
  end

  categories:destroyChildren()
  rewardCategoryWidgets = {}

  for _, category in ipairs(RewardCategories) do
    local widget = g_ui.createWidget("ShopCategory", categories)
    widget:setId(category.id)
    widget.name:setText(category.label)
    local onCategoryClick = function()
      selectRewardCategory(category.id)
      return true
    end
    widget.onClick = onCategoryClick
    widget.onMouseRelease = onCategoryClick
    if widget.name then
      widget.name.onClick = onCategoryClick
      widget.name.onMouseRelease = onCategoryClick
    end
    rewardCategoryWidgets[category.id] = widget
  end

  selectRewardCategory(currentRewardCategory)
end

local function placeTasksButton()
  if not tasksButton then
    return
  end
  local panel = tasksButton:getParent()
  if not panel then
    return
  end
  local tracker = panel:getChildById("trackerButton")
  if tracker then
    local trackerIndex = panel:getChildIndex(tracker)
    panel:moveChildToIndex(tasksButton, trackerIndex + 1)
  end
end

local function requestTasks()
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    logTasks("send fetch opcode=" .. OPCODE)
    protocolGame:sendExtendedOpcode(OPCODE, json.encode({action = "fetch", data = {}}))
  end
end

function init()
  connect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )

  ProtocolGame.registerExtendedOpcode(OPCODE, onExtendedOpcode)

  if g_game.isOnline() then
    create()
  end
end

function terminate()
  disconnect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )

  ProtocolGame.unregisterExtendedOpcode(OPCODE, onExtendedOpcode)

  destroy()
end

function create()
  if tasksWindow then
    return
  end

  trackerButton = modules.client_topmenu.addRightGameToggleButton("trackerButton", tr("Tasks Tracker"), "/images/topbuttons/battle", toggleTracker)
  trackerButton:setOn(true)
  trackerWindow = g_ui.loadUI("tasks_tracker", modules.game_interface.getRightPanel())
  trackerWindow.miniwindowScrollBar:mergeStyle({["$!on"] = {}})
  trackerWindow:setContentMinimumHeight(120)
  trackerWindow:setup()

  tasksWindow = g_ui.displayUI("tasks")
  tasksWindow:hide()

  rewardsWindow = g_ui.displayUI("tasks_rewards")
  rewardsWindow:hide()
  setupRewardCategories()
  setupGameSubcategories()
  updateRewardCategoryHeader()

  tasksButton = modules.client_topmenu.addRightGameToggleButton("tasksButton", tr("Tasks"), "/images/topbuttons/questlog", toggle, true)
  placeTasksButton()
  addEvent(placeTasksButton)

  tasksWindow.info.kills.bar.scroll.onValueChange = onKillsValueChange

  requestTasks()
end

function destroy()
  if tasksWindow then
    trackerButton:destroy()
    trackerButton = nil
    trackerPanel = nil
    trackerWindow:destroy()
    trackerWindow = nil

    if tasksButton then
      tasksButton:destroy()
      tasksButton = nil
    end

    tasksWindow:destroy()
    tasksWindow = nil
  end

  if rewardsWindow then
    rewardsWindow:destroy()
    rewardsWindow = nil
  end

  config = {}
  tasks = {}
  rewards = {}
  selectedRewardId = nil
  rewardPurchaseAmount = 1
  currentRewardCategory = "all"
  rewardCategoryWidgets = {}
  currentGameRewardSubcategory = "container"
  gameSubcategoryWidgets = {}
  currentTaskPoints = 0
  activeTasks = {}
  playerLevel = 0
  jsonData = ""
end

function onExtendedOpcode(protocol, code, buffer)
  if DEBUG then
    logTasks("recv opcode=" .. code .. " size=" .. buffer:len())
  end
  local char = buffer:sub(1, 1)
  local endData = false
  if char == "E" then
    endData = true
  end

  local partialData = false
  if char == "S" or char == "P" or char == "E" then
    partialData = true
    buffer = buffer:sub(2)
    jsonData = jsonData .. buffer
  end

  if partialData and not endData then
    return
  end

  local json_status, json_data =
    pcall(
    function()
      return json.decode(endData and jsonData or buffer)
    end
  )

  if not json_status then
    g_logger.error("[Tasks] JSON error: " .. json_data)
    return
  end
  if endData then
    jsonData = ""
  end

  local action = json_data.action
  local data = json_data.data
  if DEBUG then
    logTasks("action=" .. tostring(action))
  end

  if action == "config" then
    onTasksConfig(data)
  elseif action == "tasks" then
    onTasksList(data)
  elseif action == "shop" then
    onTasksShop(data)
  elseif action == "active" then
    onTasksActive(data)
  elseif action == "update" then
    onTaskUpdate(data)
  elseif action == "points" then
    onTasksPoints(data)
  elseif action == "open" then
    show()
  elseif action == "close" then
    hide()
  end
end

function onTasksConfig(data)
  config = data

  tasksWindow.info.kills.bar.min:setText(config.kills.Min)
  tasksWindow.info.kills.bar.max:setText(config.kills.Max)
  tasksWindow.info.kills.bar.scroll:setRange(config.kills.Min, config.kills.Max)
  tasksWindow.info.kills.bar.scroll:setStep(math.max(1, tonumber(config.bonus) or 100))
  tasksWindow.info.kills.bar.scroll:setValue(config.kills.Min)
end

function onTasksShop(data)
  rewards = data or {}
  if not rewardsWindow then
    return
  end

  local offers = rewardsWindow:recursiveGetChildById("offers")
  if not offers then
    return
  end

  offers:destroyChildren()
  selectedRewardId = nil
  rewardPurchaseAmount = 1
  local amountWidget = rewardsWindow:recursiveGetChildById("purchaseAmount")
  if amountWidget then
    amountWidget:setValue(1)
  end
  local purchaseButton = rewardsWindow:recursiveGetChildById("purchaseButton")
  if purchaseButton then
    purchaseButton:setEnabled(false)
  end

  local entries = {}
  for idx, item in ipairs(rewards) do
    table.insert(entries, {id = idx, item = item})
  end
  table.sort(
    entries,
    function(a, b)
      local acost = a.item.cost or 0
      local bcost = b.item.cost or 0
      if acost == bcost then
        return (a.item.name or "") < (b.item.name or "")
      end
      return acost < bcost
    end
  )

  for _, entry in ipairs(entries) do
    local item = entry.item
    local widget = g_ui.createWidget("RewardOfferLine", offers)
    widget:setId(entry.id)
    local rewardCount = tonumber(item.count) or 1
    local rewardName = item.name or ("Item " .. tostring(item.id))
    if rewardCount > 1 then
      rewardName = string.format("%dx %s", rewardCount, rewardName)
    end
    widget.offerName:setText(rewardName)
    widget.offerPrice:setText(string.format("%s pts", tostring(item.cost or 0)))
    local displayCount = getRewardDisplaySubType(item)
    local iconId = tonumber(item.clientId) or tonumber(item.id)
    widget.offerIcon:setItem(Item.create(iconId, displayCount))
    local tooltip = (item.name or "Reward") .. "\nCost: " .. tostring(item.cost or 0) .. " task points"
    if item.description and tostring(item.description):len() > 0 then
      tooltip = tooltip .. "\n" .. tostring(item.description)
    end
    widget:setTooltip(tooltip)
  end

  offers.onChildFocusChange = onRewardSelected
  applyRewardsFilters()
end

function onRewardSelected(parent, child, reason)
  if not child then
    selectedRewardId = nil
    refreshRewardOfferVisuals()
    return
  end
  selectedRewardId = tonumber(child:getId())
  refreshRewardOfferVisuals()
end

function purchaseReward()
  if not selectedRewardId then
    return
  end

  local amount = rewardPurchaseAmount
  if rewardsWindow then
    local amountWidget = rewardsWindow:recursiveGetChildById("purchaseAmount")
    if amountWidget then
      amount = tonumber(amountWidget:getValue()) or rewardPurchaseAmount
    end
  end
  if amount < 1 then
    amount = 1
  end

  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(OPCODE, json.encode({action = "buy", data = {id = selectedRewardId, amount = amount}}))
  end
end

function onRewardAmountChange()
  if not rewardsWindow then
    return
  end

  local amountWidget = rewardsWindow:recursiveGetChildById("purchaseAmount")
  if amountWidget then
    local value = tonumber(amountWidget:getValue()) or 1
    if value < 1 then
      value = 1
      amountWidget:setValue(value)
    end
    rewardPurchaseAmount = value
  end

  refreshRewardOfferVisuals()
end

function onTasksList(data)
  tasks = data
  tasksById = {}
  tasksWindow.tasksList.onChildFocusChange = nil
  tasksWindow.tasksList:destroyChildren()
  logTasks("tasks list count=" .. tostring(#data))
  local localPlayer = g_game.getLocalPlayer()
  local level = localPlayer:getLevel()
  local entries = {}
  for index, task in ipairs(data) do
    local taskId = tonumber(task.taskId) or index
    tasksById[taskId] = task
    table.insert(entries, {id = taskId, task = task})
  end
  table.sort(
    entries,
    function(a, b)
      local alvl = a.task.lvl or 0
      local blvl = b.task.lvl or 0
      if alvl == blvl then
        return a.task.name < b.task.name
      end
      return alvl < blvl
    end
  )

  for _, entry in ipairs(entries) do
    local taskId = entry.id
    local task = entry.task
    local widget = g_ui.createWidget("TaskMenuEntry", tasksWindow.tasksList)
    widget:setId(taskId)
    local outfit = ensureOutfit(task.outfits[1])
    outfit.shader = "default"
    widget.preview:setOutfit(outfit)
    widget.preview:setCenter(true)
    widget.info.title:setText(task.name)
    widget.info.level:setText("Level " .. task.lvl)
    if not (task.lvl >= level - config.range and task.lvl <= level + config.range) then
      widget.info.bonus:hide()
    end
  end

  tasksWindow.tasksList.onChildFocusChange = onTaskSelected
  onTaskSelected(nil, tasksWindow.tasksList:getChildByIndex(1))
  playerLevel = g_game.getLocalPlayer():getLevel()
end

function onTasksActive(data)
  local panel = trackerWindow and trackerWindow.contentsPanel and trackerWindow.contentsPanel.trackerPanel
  if not panel then
    return
  end

  panel:destroyChildren()
  activeTasks = {}

  local seenTaskIds = {}
  for _, active in ipairs(data) do
    local taskId = tonumber(active.taskId)
    if taskId and not seenTaskIds[taskId] then
      seenTaskIds[taskId] = true
      local task = tasksById[taskId] or tasks[taskId]
      if task then
        local widget = g_ui.createWidget("TrackerButton", panel)
        widget:setId(taskId)
        local outfit = ensureOutfit(task.outfits[1])
        outfit.shader = "default"
        widget.creature:setOutfit(outfit)
        widget.creature:setCenter(true)
        if task.name:len() > 12 then
          widget.label:setText(task.name:sub(1, 9) .. "...")
        else
          widget.label:setText(task.name)
        end
        widget.kills:setText(active.kills .. "/" .. active.required)
        local percent = active.kills * 100 / active.required
        setBarPercent(widget, percent)
        widget.onMouseRelease = onTrackerClick
        activeTasks[taskId] = true
      else
        logTasks("onTasksActive missing taskId=" .. tostring(taskId))
      end
    elseif taskId then
      logTasks("onTasksActive duplicate taskId=" .. tostring(taskId))
    end
  end
end

function onTaskUpdate(data)
  local widget = trackerWindow.contentsPanel.trackerPanel[tostring(data.taskId)]
  if data.status == 1 then
    local task = tasksById[data.taskId] or tasks[data.taskId]
    if not task then
      logTasks("onTaskUpdate missing taskId=" .. tostring(data.taskId))
      return
    end
    if not widget then
      widget = g_ui.createWidget("TrackerButton", trackerWindow.contentsPanel.trackerPanel)
      widget:setId(data.taskId)
      local outfit = ensureOutfit(task.outfits[1])
      outfit.shader = "default"
      widget.creature:setOutfit(outfit)
      widget.creature:setCenter(true)
      if task.name:len() > 12 then
        widget.label:setText(task.name:sub(1, 9) .. "...")
      else
        widget.label:setText(task.name)
      end
      widget.onMouseRelease = onTrackerClick
      activeTasks[data.taskId] = true
    end

    widget.kills:setText(data.kills .. "/" .. data.required)
    local percent = data.kills * 100 / data.required
    setBarPercent(widget, percent)
  elseif data.status == 2 then
    activeTasks[data.taskId] = nil
    if widget then
      widget:destroy()
    end
  end

  local focused = tasksWindow.tasksList:getFocusedChild()
  if focused then
    local taskId = tonumber(focused:getId())
    if taskId == data.taskId then
      if activeTasks[data.taskId] then
        tasksWindow.start:hide()
        tasksWindow.cancel:show()
      else
        tasksWindow.start:show()
        tasksWindow.cancel:hide()
      end
    end
  end
end

function onTasksPoints(points)
  currentTaskPoints = tonumber(points) or 0
  tasksWindow.points:setText("Current Tasks Points: " .. points)
  if rewardsWindow then
    local pointsWidget = rewardsWindow:recursiveGetChildById("points")
    if pointsWidget and pointsWidget.baseText then
      pointsWidget:setText(string.format(pointsWidget.baseText, points))
    end
  end
  refreshRewardOfferVisuals()
end

function onTrackerClick(widget, mousePosition, mouseButton)
  local taskId = tonumber(widget:getId())
  local menu = g_ui.createWidget("PopupMenu")
  menu:setGameMenu(true)
  menu:addOption(
    "Abandon this task",
    function()
      cancel(taskId)
    end
  )
  menu:display(menuPosition)

  return true
end

function setBarPercent(widget, percent)
  if percent > 92 then
    widget.killsBar:setBackgroundColor("#00BC00")
  elseif percent > 60 then
    widget.killsBar:setBackgroundColor("#50A150")
  elseif percent > 30 then
    widget.killsBar:setBackgroundColor("#A1A100")
  elseif percent > 8 then
    widget.killsBar:setBackgroundColor("#BF0A0A")
  elseif percent > 3 then
    widget.killsBar:setBackgroundColor("#910F0F")
  else
    widget.killsBar:setBackgroundColor("#850C0C")
  end
  widget.killsBar:setPercent(percent)
end

function onTaskSelected(parent, child, reason)
  if not child then
    return
  end

  local taskId = tonumber(child:getId())
  if not taskId then
    return
  end
  local task = tasksById[taskId] or tasks[taskId]
  if not task then
    logTasks("onTaskSelected missing taskId=" .. tostring(taskId))
    return
  end

  local rewardsContainer = tasksWindow.info.rewards
  local rewardsList = rewardsContainer.rewardsList or rewardsContainer
  rewardsList:destroyChildren()

  if not task.rewards or #task.rewards == 0 then
    local empty = g_ui.createWidget("Label", rewardsList)
    empty:setText("No rewards configured")
    empty:setTextAlign(AlignCenter)
    empty:setColor("#b8b8b8")
  else
    for _, reward in ipairs(task.rewards) do
      local widget = g_ui.createWidget("TaskRewardLine", rewardsList)
      local meta = getRewardMeta(reward.type)
      if reward.type == RewardType.Points then
        widget:setId("reward_points")
      end
      widget.rewardBadge:setText(meta.tag)
      widget.rewardBadge:setColor(meta.color)
      widget.rewardText:setText(formatRewardText(reward))
      widget:setTooltip(formatRewardText(reward))
    end
  end

  renderTaskMonsters(task, 0)

  if activeTasks[taskId] then
    tasksWindow.start:hide()
    tasksWindow.cancel:show()
  else
    tasksWindow.start:show()
    tasksWindow.cancel:hide()
  end

  onKillsValueChange(tasksWindow.info.kills.bar.scroll, tasksWindow.info.kills.bar.scroll:getValue(), 0)
end

function onKillsValueChange(widget, value, delta)
  local snappedValue = snapKillsValue(value)
  if widget and not _killsValueSync and snappedValue ~= value then
    _killsValueSync = true
    widget:setValue(snappedValue)
    _killsValueSync = false
  end
  value = snappedValue
  tasksWindow.info.kills.bar.value:setText(value)

  local focused = tasksWindow.tasksList:getFocusedChild()
  if not focused then
    return
  end

  local taskId = tonumber(focused:getId())
  local task = tasksById[taskId] or tasks[taskId]
  if not task then
    return
  end

  local totalPoints, _, _, _, _, bonusPercent = calculateTaskPointsPreview(task, value)
  tasksWindow.info.kills.bonuses.none:hide()
  tasksWindow.info.kills.bonuses.points:show()
  tasksWindow.info.kills.bonuses.exp:hide()
  tasksWindow.info.kills.bonuses.gold:hide()

  tasksWindow.info.kills.bonuses.points:setText(string.format("+%d%% Task Points", bonusPercent))

  local rewardsContainer = tasksWindow.info.rewards
  local rewardsList = rewardsContainer and (rewardsContainer.rewardsList or rewardsContainer)
  if rewardsList then
    local rewardPointsWidget = rewardsList:getChildById("reward_points")
    if rewardPointsWidget and rewardPointsWidget.rewardText then
      rewardPointsWidget.rewardText:setText(string.format("Laczna wartosc taska: %d", totalPoints))
    end
  end
end

function onSearch()
  scheduleEvent(
    function()
      local searchInput = tasksWindow.searchInput
      local text = searchInput:getText():lower()

      if text:len() >= 1 then
        local children = tasksWindow.tasksList:getChildren()
        for _, child in ipairs(children) do
          local taskId = tonumber(child:getId())
          local task = tasks[taskId]
          local found = false
          for _, mob in ipairs(task.mobs) do
            if mob:lower():find(text) then
              found = true
              break
            end
          end

          if found then
            child:show()
          else
            child:hide()
          end
        end
      else
        local children = tasksWindow.tasksList:getChildren()
        for _, child in ipairs(children) do
          child:show()
        end
      end
    end,
    50
  )
end

function start()
  local focused = tasksWindow.tasksList:getFocusedChild()
  local taskId = tonumber(focused:getId())
  local kills = tasksWindow.info.kills.bar.scroll:getValue()

  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(OPCODE, json.encode({action = "start", data = {taskId = taskId, kills = kills}}))
  end
end

function cancel(taskId)
  if not taskId then
    local focused = tasksWindow.tasksList:getFocusedChild()
    if not focused then
      return
    end

    taskId = tonumber(focused:getId())
  end

  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(OPCODE, json.encode({action = "cancel", data = taskId}))
  end
end

function onTrackerClose()
  trackerButton:setOn(false)
end

function toggleTracker()
  if not trackerWindow then
    return
  end

  if trackerButton:isOn() then
    trackerWindow:close()
    trackerButton:setOn(false)
  else
    trackerWindow:open()
    trackerButton:setOn(true)
  end
end

function toggle()
  if not tasksWindow then
    return
  end
  if tasksWindow:isVisible() then
    return hide()
  end
  show()
end

function toggleRewards()
  if not rewardsWindow then
    return
  end
  if rewardsWindow:isVisible() then
    rewardsWindow:hide()
    return
  end
  rewardsWindow:show()
  rewardsWindow:raise()
  rewardsWindow:focus()
  updateRewardCategoryHeader()
  applyRewardsFilters()
end

function onRewardsSearch()
  scheduleEvent(
    function()
      applyRewardsFilters()
    end,
    50
  )
end

function show()
  if not tasksWindow then
    return
  end

  if tasksWindow.tasksList:getChildCount() == 0 then
    requestTasks()
  end

  local level = g_game.getLocalPlayer():getLevel()
  if playerLevel ~= level then
    local children = tasksWindow.tasksList:getChildren()
    for _, child in ipairs(children) do
      local taskId = tonumber(child:getId())
      local task = tasks[taskId]
      if task.lvl >= level - config.range and task.lvl <= level + config.range then
        child.info.bonus:show()
      else
        child.info.bonus:hide()
      end
    end
    playerLevel = level
  end

  local focused = tasksWindow.tasksList:getFocusedChild()
  if focused then
    local taskId = tonumber(focused:getId())
    if activeTasks[taskId] then
      tasksWindow.start:hide()
      tasksWindow.cancel:show()
    else
      tasksWindow.start:show()
      tasksWindow.cancel:hide()
    end
  end

  tasksWindow:show()
  tasksWindow:raise()
  tasksWindow:focus()
  if focused then
    onTaskSelected(nil, focused)
  end
  if tasksButton then
    tasksButton:setOn(true)
  end
end

function hide()
  if not tasksWindow then
    return
  end
  tasksWindow:hide()
  if tasksButton then
    tasksButton:setOn(false)
  end
end
