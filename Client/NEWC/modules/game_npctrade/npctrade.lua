BUY = 1
SELL = 2
CURRENCY = 'gold'
CURRENCY_DECIMAL = false
WEIGHT_UNIT = 'oz'
LAST_INVENTORY = 10

npcWindow = nil
itemsPanel = nil
radioTabs = nil
radioItems = nil
searchText = nil
setupPanel = nil
quantity = nil
quantityScroll = nil
idLabel = nil
nameLabel = nil
priceLabel = nil
moneyLabel = nil
weightDesc = nil
weightLabel = nil
capacityDesc = nil
capacityLabel = nil
tradeButton = nil
buyTab = nil
sellTab = nil
initialized = false

showWeight = true
buyWithBackpack = nil
ignoreCapacity = nil
ignoreEquipped = nil
showAllItems = nil
sellAllButton = nil
sellAllWithDelayButton = nil
playerFreeCapacity = 0
playerMoney = 0
tradeItems = {}
playerItems = {}
playerItemsBySubtype = {}
selectedItem = nil

cancelNextRelease = nil

sellAllWithDelayEvent = nil
local npcTradeFluidDebug = false

local fluidContainerIds = {
  [2005] = true, [2006] = true, [2007] = true, [2008] = true, [2009] = true,
  [2010] = true, [2011] = true, [2012] = true, [2013] = true, [2014] = true,
  [2015] = true, [2873] = true, [2874] = true, [2875] = true, [2881] = true,
  [2901] = true
}

local fluidNameByType = {
  [1] = 'water',
  [2] = 'blood',
  [3] = 'beer',
  [4] = 'slime',
  [5] = 'lemonade',
  [6] = 'milk',
  [7] = 'mana fluid',
  [10] = 'life fluid',
  [11] = 'oil',
  [12] = 'crafter poison',
  [13] = 'urine',
  [14] = 'coconut milk',
  [15] = 'wine',
  [19] = 'mud',
  [21] = 'fruit juice',
  [26] = 'lava',
  [27] = 'rum',
  [28] = 'swamp',
  [35] = 'tea',
  [43] = 'mead'
}

local function normalizeName(name)
  return tostring(name or ''):lower():gsub('^%s+', ''):gsub('%s+$', '')
end

local fluidSubtypeByName = {
  -- Client fluid subtypes (not server fluid ids).
  ['mana fluid'] = 2,
  ['life fluid'] = 11,
  ['oil'] = 13
}

local fluidNameByClientSubType = {
  [2] = 'mana fluid',
  [11] = 'life fluid',
  [13] = 'oil'
}

-- Mapping used by server side (clientToServerFluidMap in engine).
-- Shop list sends client fluid subtypes; old-fluid clients render server fluid ids.
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

local function getFluidDisplaySubType(subType)
  local value = tonumber(subType) or 0
  if g_game.getFeature and g_game.getFeature(GameNewFluids) then
    return value
  end
  return fluidClientToServerSubType[value] or value
end

local function getFluidNameByPrice(price, tradeType)
  local p = tonumber(price) or -1
  -- Some servers send sell offers in buy list; handle both price sets globally first.
  if p == 100 or p == 15 then
    return 'mana fluid'
  elseif p == 60 or p == 12 then
    return 'life fluid'
  elseif p == 20 or p == 10 then
    return 'oil'
  end

  -- Kept for readability/future per-tab tuning.
  if tradeType == BUY then
    return nil
  else
    return nil
  end
end

local function isFluidTradeItem(itemPtr)
  if not itemPtr then
    return false
  end

  if itemPtr.isFluidContainer and itemPtr:isFluidContainer() then
    return true
  end

  return fluidContainerIds[itemPtr:getId()] == true
end

local function itemSubtypeKey(itemId, subType)
  return tostring(itemId) .. ":" .. tostring(subType or 0)
end

local function isEmptyFluidName(name)
  local normalizedName = normalizeName(name)
  return normalizedName == 'vial' or normalizedName == 'flask' or normalizedName == 'bottle' or normalizedName == 'bucket'
end

local function buildSubtypeCandidates(itemSubType, itemName)
  local candidates = {}
  local normalizedName = normalizeName(itemName)

  if isEmptyFluidName(normalizedName) then
    candidates[0] = true
    candidates[1] = true -- some clients report empty vial as subtype 1
    return candidates
  end

  local nameSubType = fluidSubtypeByName[normalizedName]
  if nameSubType then
    candidates[nameSubType] = true
    candidates[getFluidDisplaySubType(nameSubType)] = true
  end

  local rawSubType = tonumber(itemSubType) or 0
  if rawSubType > 0 or next(candidates) == nil then
    candidates[rawSubType] = true
  end

  return candidates
end

local function countLiveItems(itemId, subtypeCandidates, includeEquipped)
  local localPlayer = g_game.getLocalPlayer()
  if not localPlayer then
    return 0
  end

  local total = 0
  if includeEquipped then
    for i = InventorySlotFirst, InventorySlotLast do
      local item = localPlayer:getInventoryItem(i)
      if item and item:getId() == itemId then
        local subType = item:getSubType() or 0
        if not subtypeCandidates or subtypeCandidates[subType] then
          total = total + (item:getCount() or 1)
        end
      end
    end
  end

  for _, container in pairs(g_game.getContainers()) do
    for _, item in ipairs(container:getItems()) do
      if item:getId() == itemId then
        local subType = item:getSubType() or 0
        if not subtypeCandidates or subtypeCandidates[subType] then
          total = total + (item:getCount() or 1)
        end
      end
    end
  end

  return total
end

local function getNpcTradeDisplayName(itemPtr, fallbackName, price, tradeType)
  local normalizedName = normalizeName(fallbackName)
  local isFluidName = (normalizedName == 'vial' or normalizedName == 'flask' or normalizedName == 'bottle' or normalizedName == 'bucket')
  if not isFluidTradeItem(itemPtr) and not isFluidName then
    return fallbackName
  end

  -- Price mapping is the most stable for these fluid-shop entries.
  local byPriceFirst = getFluidNameByPrice(price, tradeType)
  if byPriceFirst then
    return byPriceFirst
  end

  local subType = tonumber(itemPtr and itemPtr:getSubType() or 0) or 0
  local fluidNameFromClientSubtype = fluidNameByClientSubType[subType]
  if fluidNameFromClientSubtype then
    return fluidNameFromClientSubtype
  end

  local fluidName = fluidNameByType[subType]
  if fluidName then
    return fluidName
  end

  local byPrice = getFluidNameByPrice(price, tradeType)
  if byPrice then
    return byPrice
  end

  return fallbackName
end

local function getNpcTradeDisplaySubType(itemPtr, itemName, price, tradeType)
  local byPrice = getFluidNameByPrice(price, tradeType)
  if byPrice and fluidSubtypeByName[byPrice] then
    return fluidSubtypeByName[byPrice]
  end

  local normalizedName = normalizeName(itemName)
  local byName = fluidSubtypeByName[normalizedName]
  if byName then
    return byName
  end

  if not isFluidTradeItem(itemPtr) then
    return nil
  end

  local subType = tonumber(itemPtr:getSubType()) or 0
  if subType and subType > 0 then
    return subType
  end

  return nil
end

local function createNpcTradeDisplayItem(itemPtr, itemName, price, tradeType)
  if not itemPtr then
    return nil
  end

  local displaySubType = getNpcTradeDisplaySubType(itemPtr, itemName, price, tradeType)
  if displaySubType then
    -- Use a separate preview item so we don't mutate the original shop pointer used for buy/sell packets.
    return Item.create(itemPtr:getId(), getFluidDisplaySubType(displaySubType))
  end

  return itemPtr
end

function init()
  npcWindow = g_ui.displayUI('npctrade')
  npcWindow:setVisible(false)

  itemsPanel = npcWindow:recursiveGetChildById('itemsPanel')
  searchText = npcWindow:recursiveGetChildById('searchText')

  setupPanel = npcWindow:recursiveGetChildById('setupPanel')
  quantityScroll = setupPanel:getChildById('quantityScroll')
  idLabel = setupPanel:getChildById('id')
  nameLabel = setupPanel:getChildById('name')
  priceLabel = setupPanel:getChildById('price')
  moneyLabel = setupPanel:getChildById('money')
  weightDesc = setupPanel:getChildById('weightDesc')
  weightLabel = setupPanel:getChildById('weight')
  capacityDesc = setupPanel:getChildById('capacityDesc')
  capacityLabel = setupPanel:getChildById('capacity')
  tradeButton = npcWindow:recursiveGetChildById('tradeButton')

  buyWithBackpack = npcWindow:recursiveGetChildById('buyWithBackpack')
  ignoreCapacity = npcWindow:recursiveGetChildById('ignoreCapacity')
  ignoreEquipped = npcWindow:recursiveGetChildById('ignoreEquipped')
  showAllItems = npcWindow:recursiveGetChildById('showAllItems')
  sellAllButton = npcWindow:recursiveGetChildById('sellAllButton')
  sellAllWithDelayButton = npcWindow:recursiveGetChildById('sellAllWithDelayButton')
  buyTab = npcWindow:getChildById('buyTab')
  sellTab = npcWindow:getChildById('sellTab')
  if showAllItems then
    showAllItems:setChecked(false)
  end

  radioTabs = UIRadioGroup.create()
  radioTabs:addWidget(buyTab)
  radioTabs:addWidget(sellTab)
  radioTabs:selectWidget(buyTab)
  radioTabs.onSelectionChange = onTradeTypeChange

  cancelNextRelease = false

  if g_game.isOnline() then
    playerFreeCapacity = g_game.getLocalPlayer():getFreeCapacity()
  end

  connect(g_game, { onGameEnd = hide,
                    onOpenNpcTrade = onOpenNpcTrade,
                    onCloseNpcTrade = onCloseNpcTrade,
                    onPlayerGoods = onPlayerGoods } )

  connect(LocalPlayer, { onFreeCapacityChange = onFreeCapacityChange,
                         onInventoryChange = onInventoryChange } )

  initialized = true
end

function terminate()
  initialized = false
  npcWindow:destroy()
  removeEvent(sellAllWithDelayEvent)
  
  disconnect(g_game, {  onGameEnd = hide,
                        onOpenNpcTrade = onOpenNpcTrade,
                        onCloseNpcTrade = onCloseNpcTrade,
                        onPlayerGoods = onPlayerGoods } )

  disconnect(LocalPlayer, { onFreeCapacityChange = onFreeCapacityChange,
                            onInventoryChange = onInventoryChange } )
end

function show()
  if g_game.isOnline() then
    if #tradeItems[BUY] > 0 then
      radioTabs:selectWidget(buyTab)
    else
      radioTabs:selectWidget(sellTab)
    end

    npcWindow:show()
    npcWindow:raise()
    npcWindow:focus()
  end
end

function hide()
  removeEvent(sellAllWithDelayEvent)

  npcWindow:hide()

  local layout = itemsPanel:getLayout()
  layout:disableUpdates()

  clearSelectedItem()

  searchText:clearText()
  setupPanel:disable()
  itemsPanel:destroyChildren()

  if radioItems then
    radioItems:destroy()
    radioItems = nil
  end

  layout:enableUpdates()
  layout:update()  
end

function onItemBoxChecked(widget)
  if widget:isChecked() then
    local item = widget.item
    selectedItem = item
    refreshItem(item)
    tradeButton:enable()

    if getCurrentTradeType() == SELL then
      quantityScroll:setValue(quantityScroll:getMaximum())
    end
  end
end

function onQuantityValueChange(quantity)
  if selectedItem then
    weightLabel:setText(string.format('%.2f', selectedItem.weight*quantity) .. ' ' .. WEIGHT_UNIT)
    priceLabel:setText(formatCurrency(getItemPrice(selectedItem)))
  end
end

function onTradeTypeChange(radioTabs, selected, deselected)
  tradeButton:setText(selected:getText())
  selected:setOn(true)
  deselected:setOn(false)

  local currentTradeType = getCurrentTradeType()
  buyWithBackpack:setVisible(currentTradeType == BUY)
  ignoreCapacity:setVisible(currentTradeType == BUY)
  ignoreEquipped:setVisible(currentTradeType == SELL)
  showAllItems:setVisible(currentTradeType == SELL)
  sellAllButton:setVisible(currentTradeType == SELL)
  sellAllWithDelayButton:setVisible(currentTradeType == SELL)
  
  refreshTradeItems()
  refreshPlayerGoods()
end

function onTradeClick()
  removeEvent(sellAllWithDelayEvent)
  if getCurrentTradeType() == BUY then
    g_game.buyItem(selectedItem.ptr, quantityScroll:getValue(), ignoreCapacity:isChecked(), buyWithBackpack:isChecked())
  else
    g_game.sellItem(selectedItem.ptr, quantityScroll:getValue(), ignoreEquipped:isChecked())
  end
end

function onSearchTextChange()
  refreshPlayerGoods()
end

function itemPopup(self, mousePosition, mouseButton)
  if cancelNextRelease then
    cancelNextRelease = false
    return false
  end

  if mouseButton == MouseRightButton then
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addOption(tr('Look'), function() return g_game.inspectNpcTrade(self:getItem()) end)
    menu:display(mousePosition)
    return true
  elseif ((g_mouse.isPressed(MouseLeftButton) and mouseButton == MouseRightButton)
    or (g_mouse.isPressed(MouseRightButton) and mouseButton == MouseLeftButton)) then
    cancelNextRelease = true
    g_game.inspectNpcTrade(self:getItem())
    return true
  end
  return false
end

function onBuyWithBackpackChange()
  if selectedItem then
    refreshItem(selectedItem)
  end
end

function onIgnoreCapacityChange()
  refreshPlayerGoods()
end

function onIgnoreEquippedChange()
  refreshPlayerGoods()
end

function onShowAllItemsChange()
  refreshPlayerGoods()
end

function setCurrency(currency, decimal)
  CURRENCY = currency
  CURRENCY_DECIMAL = decimal
end

function setShowWeight(state)
  showWeight = state
  weightDesc:setVisible(state)
  weightLabel:setVisible(state)
end

function setShowYourCapacity(state)
  capacityDesc:setVisible(state)
  capacityLabel:setVisible(state)
  ignoreCapacity:setVisible(state)
end

function clearSelectedItem()
  idLabel:clearText()
  nameLabel:clearText()
  weightLabel:clearText()
  priceLabel:clearText()
  tradeButton:disable()
  quantityScroll:setMinimum(0)
  quantityScroll:setMaximum(0)
  if selectedItem then
    radioItems:selectWidget(nil)
    selectedItem = nil
  end
end

function getCurrentTradeType()
  if tradeButton:getText() == tr('Buy') then
    return BUY
  else
    return SELL
  end
end

function getItemPrice(item, single)
  local amount = 1
  local single = single or false
  if not single then
    amount = quantityScroll:getValue()
  end
  if getCurrentTradeType() == BUY then
    if buyWithBackpack:isChecked() then
      if item.ptr:isStackable() then
          return item.price*amount + 20
      else
        return item.price*amount + math.ceil(amount/20)*20
      end
    end
  end
  return item.price*amount
end

function getSellQuantity(item, itemName)
  if not item then
    return 0
  end

  local itemId = item:getId()
  local itemSubType = item:getSubType() or 0
  local subtypeSensitive = isFluidTradeItem(item)
  local emptyFluidTrade = isEmptyFluidName(itemName)
  local ownedAmount = 0
  if subtypeSensitive then
    local candidates = buildSubtypeCandidates(itemSubType, itemName)
    -- Prefer live inventory/container scan for fluids, because PlayerGoods may collapse subtypes.
    ownedAmount = countLiveItems(itemId, candidates, true)
    if ownedAmount <= 0 and not emptyFluidTrade then
      for subType, _ in pairs(candidates) do
        ownedAmount = ownedAmount + (playerItemsBySubtype[itemSubtypeKey(itemId, subType)] or 0)
      end
    end
  else
    ownedAmount = playerItems[itemId] or 0
  end
  if ownedAmount <= 0 then
    return 0
  end

  local removeAmount = 0
  if ignoreEquipped:isChecked() then
    local localPlayer = g_game.getLocalPlayer()
    local equippedCandidates = nil
    if subtypeSensitive then
      equippedCandidates = buildSubtypeCandidates(itemSubType, itemName)
    end
    for i=1,LAST_INVENTORY do
      local inventoryItem = localPlayer:getInventoryItem(i)
      if inventoryItem and inventoryItem:getId() == item:getId() then
        if not subtypeSensitive or equippedCandidates[(inventoryItem:getSubType() or 0)] then
          removeAmount = removeAmount + inventoryItem:getCount()
        end
      end
    end
  end
  return ownedAmount - removeAmount
end

function canTradeItem(item)
  if getCurrentTradeType() == BUY then
    return (ignoreCapacity:isChecked() or (not ignoreCapacity:isChecked() and playerFreeCapacity >= item.weight)) and playerMoney >= getItemPrice(item, true)
  else
    return getSellQuantity(item.ptr, item.name) > 0
  end
end

function refreshItem(item)
  idLabel:setText(item.ptr:getId())
  nameLabel:setText(item.name)
  weightLabel:setText(string.format('%.2f', item.weight) .. ' ' .. WEIGHT_UNIT)
  priceLabel:setText(formatCurrency(getItemPrice(item)))

  if getCurrentTradeType() == BUY then
    local capacityMaxCount = math.floor(playerFreeCapacity / item.weight)
    if ignoreCapacity:isChecked() then
      capacityMaxCount = 65535
    end
    local priceMaxCount = math.floor(playerMoney / getItemPrice(item, true))
    local finalCount = math.max(0, math.min(getMaxAmount(), math.min(priceMaxCount, capacityMaxCount)))
    quantityScroll:setMinimum(1)
    quantityScroll:setMaximum(finalCount)
  else
    quantityScroll:setMinimum(1)
    quantityScroll:setMaximum(math.max(0, math.min(getMaxAmount(), getSellQuantity(item.ptr, item.name))))
  end

  setupPanel:enable()
end

function refreshTradeItems()
  local layout = itemsPanel:getLayout()
  layout:disableUpdates()

  clearSelectedItem()

  searchText:clearText()
  setupPanel:disable()
  itemsPanel:destroyChildren()

  if radioItems then
    radioItems:destroy()
  end
  radioItems = UIRadioGroup.create()

  local currentTradeItems = tradeItems[getCurrentTradeType()] or {}
  for key,item in pairs(currentTradeItems) do
    local itemBox = g_ui.createWidget('NPCItemBox', itemsPanel)
    itemBox.item = item

    local text = ''
    local currentTradeType = getCurrentTradeType()
    local name = getNpcTradeDisplayName(item.ptr, item.name, item.price, currentTradeType)
    item.name = name
    text = text .. name
    if showWeight then
      local weight = string.format('%.2f', item.weight) .. ' ' .. WEIGHT_UNIT
      text = text .. '\n' .. weight
    end
    local price = formatCurrency(item.price)
    text = text .. '\n' .. price
    itemBox:setText(text)

    local itemWidget = itemBox:getChildById('item')
    local displayItem = createNpcTradeDisplayItem(item.ptr, item.name, item.price, currentTradeType)
    itemWidget:setItem(displayItem)
    itemWidget.onMouseRelease = itemPopup

    radioItems:addWidget(itemBox)
  end

  layout:enableUpdates()
  layout:update()
end

function refreshPlayerGoods()
  if not initialized then return end
  if not tradeItems[BUY] then tradeItems[BUY] = {} end
  if not tradeItems[SELL] then tradeItems[SELL] = {} end

  checkSellAllTooltip()

  moneyLabel:setText(formatCurrency(playerMoney))
  capacityLabel:setText(string.format('%.2f', playerFreeCapacity) .. ' ' .. WEIGHT_UNIT)

  local currentTradeType = getCurrentTradeType()
  local searchFilter = searchText:getText():lower()
  local foundSelectedItem = false

  local items = itemsPanel:getChildCount()
  for i=1,items do
    local itemWidget = itemsPanel:getChildByIndex(i)
    local item = itemWidget.item

    local canTrade = canTradeItem(item)
    itemWidget:setOn(canTrade)
    itemWidget:setEnabled(canTrade)

    local searchCondition = (searchFilter == '') or (searchFilter ~= '' and string.find(item.name:lower(), searchFilter) ~= nil)
    local showAllItemsCondition = (currentTradeType == BUY) or (showAllItems:isChecked()) or (currentTradeType == SELL and not showAllItems:isChecked() and canTrade)
    itemWidget:setVisible(searchCondition and showAllItemsCondition)

    if selectedItem == item and itemWidget:isEnabled() and itemWidget:isVisible() then
      foundSelectedItem = true
    end
  end

  if not foundSelectedItem then
    clearSelectedItem()
  end

  if selectedItem then
    refreshItem(selectedItem)
  end
end

function onOpenNpcTrade(items)
  tradeItems[BUY] = {}
  tradeItems[SELL] = {}
  for key,item in pairs(items) do
    if npcTradeFluidDebug and item[1] then
      g_logger.info(string.format('[NpcTradeFluidDebug] id=%d subtype=%d name=%s buy=%d sell=%d',
        item[1]:getId(), item[1]:getSubType(), item[2], item[4], item[5]))
    end

    if item[4] > 0 then
      local newItem = {}
      newItem.ptr = item[1]
      newItem.name = getNpcTradeDisplayName(item[1], item[2], item[4], BUY)
      newItem.weight = item[3] / 100
      newItem.price = item[4]
      table.insert(tradeItems[BUY], newItem)
    end
    
    if item[5] > 0 then
      local newItem = {}
      newItem.ptr = item[1]
      newItem.name = getNpcTradeDisplayName(item[1], item[2], item[5], SELL)
      newItem.weight = item[3] / 100
      newItem.price = item[5]
      table.insert(tradeItems[SELL], newItem)
    end
  end

  refreshTradeItems()
  addEvent(show) -- player goods has not been parsed yet
end

function closeNpcTrade()
  g_game.closeNpcTrade()
  addEvent(hide)
end

function onCloseNpcTrade()
  addEvent(hide)
end

function onPlayerGoods(money, items)
  playerMoney = money

  playerItems = {}
  playerItemsBySubtype = {}
  for key,item in pairs(items) do
    local id = item[1]:getId()
    local subType = item[1]:getSubType() or 0
    local count = item[2] or 0
    if not playerItems[id] then
      playerItems[id] = count
    else
      playerItems[id] = playerItems[id] + count
    end
    local subtypeKey = itemSubtypeKey(id, subType)
    playerItemsBySubtype[subtypeKey] = (playerItemsBySubtype[subtypeKey] or 0) + count
  end

  refreshPlayerGoods()
end

function onFreeCapacityChange(localPlayer, freeCapacity, oldFreeCapacity)
  playerFreeCapacity = freeCapacity * 100

  if npcWindow:isVisible() then
    refreshPlayerGoods()
  end
end

function onInventoryChange(inventory, item, oldItem)
  refreshPlayerGoods()
end

function getTradeItemData(id, type)
  if table.empty(tradeItems[type]) then
    return false
  end

  if type then
    for key,item in pairs(tradeItems[type]) do
      if item.ptr and item.ptr:getId() == id then
        return item
      end
    end
  else
    for _,items in pairs(tradeItems) do
      for key,item in pairs(items) do
        if item.ptr and item.ptr:getId() == id then
          return item
        end
      end
    end
  end
  return false
end

function checkSellAllTooltip()
  if not tradeItems[SELL] then
    sellAllButton:setEnabled(false)
    sellAllButton:removeTooltip()
    sellAllWithDelayButton:setEnabled(false)
    sellAllWithDelayButton:removeTooltip()
    return
  end

  sellAllButton:setEnabled(true)
  sellAllButton:removeTooltip()
  sellAllWithDelayButton:setEnabled(true)
  sellAllWithDelayButton:removeTooltip()

  local total = 0
  local info = ''
  local first = true

  for _, data in ipairs(tradeItems[SELL]) do
    local amount = getSellQuantity(data.ptr, data.name)
    if amount > 0 then
      info = info..(not first and "\n" or "")..
             amount.." "..
             data.name.." ("..
             data.price*amount.." gold)"

      total = total+(data.price*amount)
      if first then first = false end
    end
  end
  if info ~= '' then
    info = info.."\nTotal: "..total.." gold"
    sellAllButton:setTooltip(info)
    sellAllWithDelayButton:setTooltip(info)
  else
    sellAllButton:setEnabled(false)
    sellAllWithDelayButton:setEnabled(false)
  end
end

function formatCurrency(amount)
  if CURRENCY_DECIMAL then
    return string.format("%.02f", amount/100.0) .. ' ' .. CURRENCY
  else
    return amount .. ' ' .. CURRENCY
  end
end

function getMaxAmount()
  if getCurrentTradeType() == SELL and g_game.getFeature(GameDoubleShopSellAmount) then
    return 10000
  end
  return 100
end

function sellAll(delayed, exceptions)
  -- backward support
  if type(delayed) == "table" then
    exceptions = delayed
    delayed = false
  end
  exceptions = exceptions or {}
  removeEvent(sellAllWithDelayEvent)
  local queue = {}
  for _,entry in ipairs(tradeItems[SELL] or {}) do
    local id = entry.ptr:getId()
    if not table.find(exceptions, id) then
      local sellQuantity = getSellQuantity(entry.ptr, entry.name)
      while sellQuantity > 0 do
        local maxAmount = math.min(sellQuantity, getMaxAmount())
        if delayed then
          g_game.sellItem(entry.ptr, maxAmount, ignoreEquipped:isChecked())
          sellAllWithDelayEvent = scheduleEvent(function() sellAll(true) end, 1100)
          return
        end
        table.insert(queue, {entry.ptr, maxAmount, ignoreEquipped:isChecked()})
        sellQuantity = sellQuantity - maxAmount
      end
    end
  end
  for _, entry in ipairs(queue) do
    g_game.sellItem(entry[1], entry[2], entry[3])
  end
end
