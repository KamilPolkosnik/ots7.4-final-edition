local OPCODE_MARKET = 116
local MENU_HOOK_CATEGORY = "market"
local MENU_HOOK_NAME = "Open Shop"

local marketWindow
local descWindow
local historyWindow
local containerPreviewWindow
local refs = {}
local historyRefs = {}
local descRefs = {}
local containerRefs = {}
local jsonBuffer = ""
local tickEvent = nil
local stallIndexEvent = nil
local menuHookAdded = false

local currentMode = "own"
local ticketRemaining = 0
local draftOffers = {}
local viewedStall = nil
local viewedOffers = {}
local historyEntries = {}
local historyPage = 1
local ownDescription = ""
local selectedDraftId = nil
local selectedOfferId = nil
local pendingDropTarget = nil
local marketCountWindow = nil
local containerPreviewStack = {}
local knownStallCreatureIds = {}
local pendingBrowseOpen = false
local DRAFT_SLOT_MIN = 40
local HISTORY_PAGE_SIZE = 20
local onDropItem
local renderOffers
local closeContainerPreview
local renderContainerPreview
local openContainerPreviewForOffer

local function trim(v)
  return tostring(v or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function toNumber(v, d)
  local n = tonumber(v)
  if not n then
    return d or 0
  end
  return n
end

local function formatNumber(value)
  local amount = math.max(0, math.floor(toNumber(value, 0)))
  local formatted = tostring(amount)
  while true do
    local output, changed = formatted:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
    formatted = output
    if changed == 0 then
      break
    end
  end
  return formatted
end

local function formatDuration(seconds)
  local value = math.max(0, math.floor(toNumber(seconds, 0)))
  local h = math.floor(value / 3600)
  local m = math.floor((value % 3600) / 60)
  local s = value % 60
  return string.format("%02d:%02d:%02d", h, m, s)
end

local function formatTooltipDuration(milliseconds)
  local totalSeconds = math.max(0, math.floor(toNumber(milliseconds, 0) / 1000))
  if totalSeconds <= 0 then
    return nil
  end
  local days = math.floor(totalSeconds / 86400)
  local hours = math.floor((totalSeconds % 86400) / 3600)
  local minutes = math.floor((totalSeconds % 3600) / 60)
  local seconds = totalSeconds % 60
  if days > 0 then
    return string.format("%dd %02d:%02d:%02d", days, hours, minutes, seconds)
  end
  return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function appendDescLine(desc, line)
  local base = trim(desc or "")
  if base == "" then
    return tostring(line or "")
  end
  return base .. "\n" .. tostring(line or "")
end

local function formatDate(ts)
  local t = os.date("*t", tonumber(ts) or 0)
  if not t then
    return "-"
  end
  return string.format("%02d %s %02d:%02d", t.day, os.date("%b", tonumber(ts) or 0), t.hour, t.min)
end

local function showFailure(text)
  if modules and modules.game_textmessage and modules.game_textmessage.displayFailureMessage then
    modules.game_textmessage.displayFailureMessage(tostring(text or "Operation failed."))
  end
end

local function showStatus(text)
  if modules and modules.game_textmessage and modules.game_textmessage.displayStatusMessage then
    modules.game_textmessage.displayStatusMessage(tostring(text or ""))
  end
end

local function destroyChildren(widget)
  if widget and widget.destroyChildren then
    widget:destroyChildren()
  end
end

local function sendAction(action, data)
  local protocol = g_game.getProtocolGame()
  if not protocol then
    return
  end
  protocol:sendExtendedOpcode(OPCODE_MARKET, json.encode({action = action, data = data or {}}))
end

local function applyStallIndex(data)
  knownStallCreatureIds = {}
  data = type(data) == "table" and data or {}
  local ids = type(data.creatureIds) == "table" and data.creatureIds or {}
  for _, raw in ipairs(ids) do
    local cid = math.floor(toNumber(raw, 0))
    if cid > 0 then
      knownStallCreatureIds[cid] = true
    end
  end
end

local function refreshStallIndex()
  if not g_game.isOnline() then
    knownStallCreatureIds = {}
    return
  end
  sendAction("stallIndex", {})
end

local function setItemIcon(widget, clientId, fallbackId, count, tooltipData)
  if not widget then return end
  local iconId = math.floor(toNumber(clientId, 0))
  if iconId <= 0 then
    iconId = math.floor(toNumber(fallbackId, 0))
  end
  local amount = math.max(1, math.floor(toNumber(count, 1)))
  if iconId > 0 then
    widget:setItem(Item.create(iconId, amount))
  else
    widget:setItem(nil)
  end
  if tooltipData then
    widget.getItemTooltip = function()
      return tooltipData
    end
  else
    widget.getItemTooltip = nil
  end
end

local function buildTooltipFromData(data, fallbackName, fallbackId, fallbackCount)
  local sourceRoot = type(data) == "table" and data or {}
  local source = sourceRoot
  if type(sourceRoot.tooltip) == "table" then
    source = sourceRoot.tooltip
  end
  local t = {}
  for k, v in pairs(source) do
    t[k] = v
  end
  t.id = tonumber(t.id or sourceRoot.id or t.clientId or fallbackId) or 0
  t.clientId = tonumber(t.clientId or sourceRoot.clientId or t.id or fallbackId) or 0
  t.count = tonumber(t.count or sourceRoot.count or fallbackCount or 1) or 1
  t.itemName = tostring(t.itemName or t.name or sourceRoot.name or fallbackName or ("item " .. tostring(t.id)))
  t.name = tostring(t.name or t.itemName)

  -- Required defaults for game_tooltips/item_tooltip.lua
  t.desc = tostring(t.desc or "")
  t.iLvl = tonumber(t.iLvl or t.itemLevel) or 0
  t.reqLvl = tonumber(t.reqLvl) or 0
  t.unidentified = t.unidentified == true
  t.mirrored = t.mirrored == true
  t.uLvl = tonumber(t.uLvl or t.upgradeLevel) or 0
  t.uniqueName = t.uniqueName and tostring(t.uniqueName) or nil
  t.rarity = tonumber(t.rarity or t.rarityId) or 0
  t.tier = tonumber(t.tier) or 0
  if type(t.attributes) ~= "table" and type(t.attr) == "table" then
    t.attributes = t.attr
  elseif type(t.attributes) ~= "table" then
    t.attributes = {}
  end
  t.maxAttributes = tonumber(t.maxAttributes or t.maxAttr) or #t.attributes
  t.type = tostring(t.type or t.itemType or "")
  t.first = tonumber(t.first or t.armor or t.attack) or 0
  t.second = tonumber(t.second or t.hitChance or t.defense) or 0
  t.third = tonumber(t.third or t.shootRange or t.extraDefense) or 0
  t.weight = tonumber(t.weight) or 0

  local descLower = string.lower(t.desc or "")
  local rawCharges = math.max(0, math.floor(toNumber(source.charges or sourceRoot.charges, 0)))
  local rawDuration = math.max(0, math.floor(toNumber(source.duration or sourceRoot.duration, 0)))
  local rawSubType = math.max(0, math.floor(toNumber(source.subType or sourceRoot.subType, 0)))
  local lowerName = string.lower(t.itemName or "")
  local isRune = lowerName:find("rune", 1, true) ~= nil
  local typeLower = string.lower(t.type or "")
  if typeLower == "rune" then
    isRune = true
  end

  local effectiveCharges = rawCharges
  if effectiveCharges <= 0 and isRune then
    effectiveCharges = rawSubType
  end

  if effectiveCharges > 0 and not descLower:find("uses left:", 1, true) and not descLower:find("charges left:", 1, true) then
    local chargeLabel = isRune and "Uses left: " or "Charges left: "
    t.desc = appendDescLine(t.desc, chargeLabel .. tostring(effectiveCharges))
    descLower = string.lower(t.desc or "")
  end

  local durationText = formatTooltipDuration(rawDuration)
  if durationText and not descLower:find("time left:", 1, true) and not descLower:find("expire", 1, true) then
    t.desc = appendDescLine(t.desc, "Time left: " .. durationText)
  end

  -- Market buyer tooltip should not display right-side sprite block.
  t.hideSprite = true

  return t
end

local function buildTooltip(offer)
  if not offer then
    return nil
  end
  return buildTooltipFromData(
    offer.itemData,
    tostring(offer.name or "item"),
    tonumber(offer.clientId or offer.itemId) or 0,
    tonumber(offer.count) or 1
  )
end

local function setItemIconFromData(widget, data)
  if type(data) ~= "table" then
    setItemIcon(widget, 0, 0, 1, nil)
    return
  end
  local cid = tonumber(data.clientId or data.id) or 0
  local sid = tonumber(data.id) or 0
  local cnt = tonumber(data.count) or 1
  local tooltip = buildTooltipFromData(data, tostring(data.name or data.itemName or "item"), sid, cnt)
  setItemIcon(widget, cid, sid, cnt, tooltip)
end

local function updateTicketLabel()
  if not refs.ticketLabel then return end
  if currentMode ~= "own" then
    refs.ticketLabel:setText("")
    refs.ticketLabel:setVisible(false)
    return
  end
  if ticketRemaining > 0 then
    refs.ticketLabel:setText("Market ticket: active (" .. formatDuration(ticketRemaining) .. ")")
    refs.ticketLabel:setColor("#62e15f")
    refs.ticketLabel:setVisible(true)
  else
    refs.ticketLabel:setText("")
    refs.ticketLabel:setVisible(false)
  end
end

local function updateDescriptionCounter()
  if not descRefs.input or not descRefs.limitLabel then
    return
  end
  local text = trim(descRefs.input:getText() or "")
  if #text > 30 then
    text = text:sub(1, 30)
    descRefs.input:setText(text)
  end
  descRefs.limitLabel:setText(string.format("Max 30 characters. Counter: %d/30", #text))
end

local function closeMarketCountWindow()
  if marketCountWindow then
    marketCountWindow:destroy()
    marketCountWindow = nil
  end
end

local function requestStackAmount(itemId, maxCount, callback, unitPrice)
  local maximum = math.max(1, math.floor(toNumber(maxCount, 1)))
  if maximum <= 1 then
    callback(1)
    return
  end

  if g_keyboard.isCtrlPressed() then
    callback(maximum)
    return
  elseif g_keyboard.isShiftPressed() then
    callback(1)
    return
  end

  closeMarketCountWindow()
  marketCountWindow = g_ui.createWidget("CountWindow", rootWidget)
  if not marketCountWindow then
    callback(maximum)
    return
  end

  local itemWidget = marketCountWindow:getChildById("item")
  local scrollbar = marketCountWindow:getChildById("countScrollBar")
  local spinbox = marketCountWindow:getChildById("spinBox")
  local okButton = marketCountWindow:getChildById("buttonOk")
  local cancelButton = marketCountWindow:getChildById("buttonCancel")
  if not itemWidget or not scrollbar or not spinbox or not okButton or not cancelButton then
    closeMarketCountWindow()
    callback(maximum)
    return
  end

  itemWidget:setItemId(math.max(0, math.floor(toNumber(itemId, 0))))
  itemWidget:setItemCount(maximum)
  scrollbar:setMinimum(1)
  scrollbar:setMaximum(maximum)
  scrollbar:setValue(maximum)

  spinbox:setMinimum(1)
  spinbox:setMaximum(maximum)
  spinbox:setValue(0)
  spinbox:hideButtons()
  spinbox:focus()
  spinbox.firstEdit = true

  local unit = math.max(0, math.floor(toNumber(unitPrice, 0)))
  local totalLabel = nil
  local function updateTotalLabel(amount)
    if not totalLabel then
      return
    end
    local count = math.max(1, math.floor(toNumber(amount, 1)))
    local total = unit * count
    totalLabel:setText(string.format("%s gp x %d = %s gp", formatNumber(unit), count, formatNumber(total)))
  end

  if unit > 0 then
    marketCountWindow:setHeight(112)
    totalLabel = g_ui.createWidget("Label", marketCountWindow)
    totalLabel:setId("marketTotalLabel")
    totalLabel:setColor("#f0d080")
    totalLabel:setTextAlign(AlignCenter)
    totalLabel:setFont("verdana-11px-rounded")
    totalLabel:addAnchor(AnchorLeft, "parent", AnchorLeft)
    totalLabel:addAnchor(AnchorRight, "parent", AnchorRight)
    totalLabel:addAnchor(AnchorTop, "buttonOk", AnchorBottom)
    totalLabel:setMarginTop(4)
    updateTotalLabel(maximum)
  end

  local finished = false
  local function finish(value)
    if finished then
      return
    end
    finished = true
    closeMarketCountWindow()
    callback(value)
  end

  local spinBoxValueChange = function(self, value)
    spinbox.firstEdit = false
    local val = math.max(1, math.min(maximum, math.floor(toNumber(value, maximum))))
    scrollbar:setValue(val)
    itemWidget:setItemCount(val)
    updateTotalLabel(val)
  end
  spinbox.onValueChange = spinBoxValueChange

  local function checkFirstEdit()
    if spinbox.firstEdit then
      spinbox:setValue(spinbox:getMaximum())
      spinbox.firstEdit = false
    end
  end

  scrollbar.onValueChange = function(self, value)
    local val = math.max(1, math.min(maximum, math.floor(toNumber(value, maximum))))
    itemWidget:setItemCount(val)
    updateTotalLabel(val)
    -- Mark as user-edited so confirm does not force maximum amount.
    spinbox.firstEdit = false
    spinbox.onValueChange = nil
    spinbox:setValue(val)
    spinbox.onValueChange = spinBoxValueChange
  end

  local confirm = function()
    checkFirstEdit()
    local value = math.max(1, math.min(maximum, math.floor(toNumber(spinbox:getValue(), maximum))))
    finish(value)
  end
  local cancel = function()
    finish(nil)
  end

  marketCountWindow.onEnter = confirm
  marketCountWindow.onEscape = cancel
  okButton.onClick = confirm
  cancelButton.onClick = cancel
end

local function updateStartShopButtonState()
  if not refs.startShopButton then
    return
  end

  if currentMode ~= "own" then
    refs.startShopButton:setEnabled(false)
    return
  end

  local hasDraft = #draftOffers > 0
  local hasUnpriced = false
  for _, offer in ipairs(draftOffers) do
    if math.floor(toNumber(offer.price, 0)) <= 0 then
      hasUnpriced = true
      break
    end
  end

  refs.startShopButton:setEnabled(hasDraft and not hasUnpriced)
  if hasUnpriced then
    refs.startShopButton:setTooltip("Set Price for all draft offers before starting shop.")
  elseif hasDraft then
    refs.startShopButton:setTooltip(nil)
  else
    refs.startShopButton:setTooltip("Add at least one offer.")
  end
end

local function getSelectedOffer()
  if currentMode == "own" then
    for _, offer in ipairs(draftOffers) do
      if tonumber(offer.id) == tonumber(selectedDraftId) then
        return offer
      end
    end
    return nil
  end
  for _, offer in ipairs(viewedOffers) do
    if tonumber(offer.id) == tonumber(selectedOfferId) then
      return offer
    end
  end
  return nil
end

local function renderSelection()
  local offer = getSelectedOffer()
  if not offer then
    refs.selectedName:setText("None selected")
    if currentMode == "browse" then
      refs.selectedDesc:setText("Click item tile to preview details and buy.")
    else
      refs.selectedDesc:setText("Drop item in Draft Offers slots, then click item and set unit price (Set Price = 1 item).")
    end
    setItemIcon(refs.selectedIcon, 0, 0, 1, nil)
    refs.buyButton:setVisible(false)
    return
  end

  refs.selectedName:setText(tostring(offer.name or "item"))
  local offerPrice = math.max(0, math.floor(toNumber(offer.price, 0)))
  local offerCount = math.max(1, tonumber(offer.count) or 1)
  if currentMode == "own" and offerPrice <= 0 then
    refs.selectedDesc:setText(string.format("Amount: %d | Price not set. Enter unit price (for 1 item) and click Set Price.", offerCount))
  else
    refs.selectedDesc:setText(string.format("Price: %s gp each | Amount: %d", formatNumber(offerPrice), offerCount))
  end
  setItemIcon(refs.selectedIcon, offer.clientId, offer.itemId, offer.count, buildTooltip(offer))
  if currentMode == "own" then
    refs.priceInput:setText(tostring(math.max(1, math.floor(toNumber(offer.price, 1)))))
  end
  refs.buyButton:setVisible(currentMode == "browse")
end

local function renderDraftSlots(list)
  if not refs.offersList then return end
  local usableWidth = math.max(36, refs.offersList:getWidth() - 14)
  local usableHeight = math.max(36, refs.offersList:getHeight() - 8)
  local cols = math.max(1, math.floor(usableWidth / 36))
  local rowsVisible = math.max(1, math.floor(usableHeight / 36))
  local slotCount = math.max(#list, rowsVisible * cols, DRAFT_SLOT_MIN)
  if (slotCount % cols) ~= 0 then
    slotCount = (math.floor(slotCount / cols) + 1) * cols
  end
  local row = nil
  for i = 1, slotCount do
    if ((i - 1) % cols) == 0 then
      row = g_ui.createWidget("MarketDraftSlotRow", refs.offersList)
      row:setWidth(usableWidth)
    end

    local slot = g_ui.createWidget("MarketDraftSlot", row)
    local offer = list[i]
    if offer then
      setItemIcon(slot, offer.clientId, offer.itemId, offer.count, buildTooltip(offer))
      if tonumber(selectedDraftId) == tonumber(offer.id) then
        slot:setBorderWidth(1)
        slot:setBorderColor("#f0d080")
      else
        slot:setBorderWidth(0)
        slot:setBorderColor("#1a1a1a")
      end

      slot.onMouseRelease = function(self, mousePos, mouseButton)
      if mouseButton == MouseLeftButton or mouseButton == 1 then
          selectedDraftId = offer.id
          refs.priceInput:setText(tostring(math.max(1, math.floor(toNumber(offer.price, 1)))))
          renderOffers()
          return true
        elseif mouseButton == MouseRightButton or mouseButton == 2 then
          sendAction("removeDraft", {offerId = offer.id})
          return true
        end
        return false
      end
    else
      slot:setItem(nil)
      slot:setBorderWidth(0)
      slot:setBorderColor("#1a1a1a")
      slot.onMouseRelease = nil
    end

    slot.onDrop = function(self, widget, mousePos, forced)
      return onDropItem(self, widget, mousePos, true)
    end
  end
end

local function renderBrowseSlots(list)
  if not refs.offersList then
    return
  end

  local usableWidth = math.max(36, refs.offersList:getWidth() - 14)
  local usableHeight = math.max(36, refs.offersList:getHeight() - 8)
  local cols = math.max(1, math.floor(usableWidth / 36))
  local rowsVisible = math.max(1, math.floor(usableHeight / 36))
  local slotCount = math.max(#list, rowsVisible * cols)
  if (slotCount % cols) ~= 0 then
    slotCount = (math.floor(slotCount / cols) + 1) * cols
  end

  local row = nil
  for i = 1, slotCount do
    if ((i - 1) % cols) == 0 then
      row = g_ui.createWidget("MarketBrowseSlotRow", refs.offersList)
      row:setWidth(usableWidth)
    end

    local slot = g_ui.createWidget("MarketBrowseSlot", row)
    local offer = list[i]
    if offer then
      setItemIcon(slot, offer.clientId, offer.itemId, offer.count, buildTooltip(offer))
      if tonumber(selectedOfferId) == tonumber(offer.id) then
        slot:setBorderWidth(1)
        slot:setBorderColor("#f0d080")
      else
        slot:setBorderWidth(0)
        slot:setBorderColor("#1a1a1a")
      end
      slot.onMouseRelease = function(self, mousePos, mouseButton)
        if mouseButton ~= MouseLeftButton and mouseButton ~= 1 then
          return false
        end
        selectedOfferId = offer.id
        renderOffers()
        openContainerPreviewForOffer(offer)
        return true
      end
    else
      slot:setItem(nil)
      slot:setBorderWidth(0)
      slot:setBorderColor("#1a1a1a")
      slot.onMouseRelease = nil
    end
  end
end

renderOffers = function()
  if not refs.offersList then return end
  destroyChildren(refs.offersList)

  local list = currentMode == "own" and draftOffers or viewedOffers
  if currentMode == "own" then
    renderDraftSlots(list)
    if #list > 0 and (not selectedDraftId or not getSelectedOffer()) then
      selectedDraftId = list[1].id
    end
    renderSelection()
    updateStartShopButtonState()
    return
  end

  if #list == 0 then
    local empty = g_ui.createWidget("Label", refs.offersList)
    if pendingBrowseOpen then
      empty:setText("Loading shop offers...")
    else
      empty:setText("This shop has no offers.")
    end
    empty:setColor("#b0b0b0")
    closeContainerPreview()
    renderSelection()
    return
  end

  renderBrowseSlots(list)

  if currentMode == "browse" and not selectedOfferId then
    selectedOfferId = list[1].id
  end
  renderSelection()
  updateStartShopButtonState()
end

local function setMode(mode)
  currentMode = mode == "browse" and "browse" or "own"
  if currentMode ~= "browse" then
    pendingBrowseOpen = false
  end
  refs.editDescriptionButton:setVisible(currentMode == "own")
  refs.startShopButton:setVisible(currentMode == "own")
  refs.historyButton:setVisible(currentMode == "own")
  refs.dropPanel:setVisible(currentMode == "own")
  refs.dropHint:setVisible(currentMode == "own")
  if refs.priceLabel then
    refs.priceLabel:setVisible(currentMode == "own")
  end
  if refs.unitPriceHintLabel then
    refs.unitPriceHintLabel:setVisible(currentMode == "own")
  end
  refs.priceInput:setVisible(currentMode == "own")
  refs.addButton:setVisible(currentMode == "own")
  refs.addButton:setText("Set Price")
  refs.buyButton:setVisible(currentMode == "browse")
  if currentMode ~= "browse" then
    closeContainerPreview()
  end
  refs.shopModeLabel:setText(currentMode == "own" and "Manage your own shop." or "Viewing selected market stall.")
  updateTicketLabel()
  updateStartShopButtonState()
  renderOffers()
end

local function getHistoryPageCount()
  local total = #historyEntries
  return math.max(1, math.ceil(total / HISTORY_PAGE_SIZE))
end

local function clampHistoryPage()
  local maxPage = getHistoryPageCount()
  historyPage = math.max(1, math.min(maxPage, math.floor(toNumber(historyPage, 1))))
end

local function renderHistory()
  if not historyRefs.list then return end
  destroyChildren(historyRefs.list)

  clampHistoryPage()
  local total = #historyEntries
  local maxPage = getHistoryPageCount()
  local firstIndex = ((historyPage - 1) * HISTORY_PAGE_SIZE) + 1
  local lastIndex = math.min(total, firstIndex + HISTORY_PAGE_SIZE - 1)

  for i = firstIndex, lastIndex do
    local e = historyEntries[i]
    local row = g_ui.createWidget("MarketHistoryRow", historyRefs.list)
    row.date:setText(formatDate(e.createdAt))
    row.buyer:setText(tostring(e.buyerName or "-"))
    row.desc:setText(string.format("%s x%d", tostring(e.itemName or "item"), math.max(1, tonumber(e.count) or 1)))
    row.price:setText(string.format("%s gp", formatNumber(e.totalPrice)))
  end
  if historyRefs.pageLabel then
    historyRefs.pageLabel:setText(string.format("Page %d/%d", historyPage, maxPage))
  end
  if historyRefs.prevButton then
    historyRefs.prevButton:setEnabled(historyPage > 1)
  end
  if historyRefs.nextButton then
    historyRefs.nextButton:setEnabled(historyPage < maxPage)
  end
end

closeContainerPreview = function()
  containerPreviewStack = {}
  if containerPreviewWindow then
    containerPreviewWindow:hide()
  end
end

renderContainerPreview = function()
  if not containerRefs.list or #containerPreviewStack == 0 then
    return
  end

  local node = containerPreviewStack[#containerPreviewStack]
  local items = type(node.items) == "table" and node.items or {}
  local title = tostring(node.title or "Container")
  if containerPreviewWindow then
    containerPreviewWindow:setText(title .. " - Contents")
  end
  if containerRefs.title then
    containerRefs.title:setText("Click container item to open its contents. Current: " .. title)
  end
  if containerRefs.backButton then
    containerRefs.backButton:setEnabled(#containerPreviewStack > 1)
  end

  destroyChildren(containerRefs.list)
  if #items == 0 then
    local empty = g_ui.createWidget("Label", containerRefs.list)
    empty:setText("Container is empty.")
    empty:setColor("#b0b0b0")
    return
  end

  local usableWidth = math.max(36, containerRefs.list:getWidth() - 14)
  local cols = math.max(1, math.floor(usableWidth / 36))
  local slotCount = #items
  if (slotCount % cols) ~= 0 then
    slotCount = (math.floor(slotCount / cols) + 1) * cols
  end

  local row = nil
  for i = 1, slotCount do
    if ((i - 1) % cols) == 0 then
      row = g_ui.createWidget("MarketContainerSlotRow", containerRefs.list)
      row:setWidth(usableWidth)
    end
    local slot = g_ui.createWidget("MarketContainerSlot", row)
    local itemData = items[i]
    if itemData then
      setItemIconFromData(slot, itemData)
      slot.onMouseRelease = function(self, mousePos, mouseButton)
        if mouseButton ~= MouseLeftButton and mouseButton ~= 1 then
          return false
        end
        if itemData.isContainer and type(itemData.children) == "table" then
          containerPreviewStack[#containerPreviewStack + 1] = {
            title = tostring(itemData.name or itemData.itemName or ("item " .. tostring(itemData.id or 0))),
            items = itemData.children
          }
          renderContainerPreview()
          return true
        end
        return false
      end
    else
      slot:setItem(nil)
      slot.onMouseRelease = nil
    end
  end
end

openContainerPreviewForOffer = function(offer)
  if not containerPreviewWindow or not offer then
    return
  end
  local itemData = type(offer.itemData) == "table" and offer.itemData or nil
  if not itemData or not itemData.isContainer then
    closeContainerPreview()
    return
  end
  containerPreviewStack = {{
    title = tostring(offer.name or itemData.name or "Container"),
    items = type(itemData.children) == "table" and itemData.children or {}
  }}
  containerPreviewWindow:show()
  containerPreviewWindow:raise()
  containerPreviewWindow:focus()
  renderContainerPreview()
end

local function clearPendingDrop()
  pendingDropTarget = nil
  refs.dropHint:setText("Drop item into slot, then click Set Price (price for 1 item).")
end

onDropItem = function(self, widget, mousePos, forced)
  if not mousePos and g_mouse and g_mouse.getPosition then
    mousePos = g_mouse.getPosition()
  end
  local dragWidget = widget
  if (not dragWidget or not dragWidget.currentDragThing) and g_ui and g_ui.getDraggingWidget then
    dragWidget = g_ui.getDraggingWidget()
  end
  if self and self.canAcceptDrop and not self:canAcceptDrop(dragWidget, mousePos) and not forced then
    return false
  end
  local dragged = dragWidget and dragWidget.currentDragThing
  if not dragged or not dragged.isItem or not dragged:isItem() then
    return false
  end

  local function normalizePos(p)
    if not p then
      return nil
    end
    local px = tonumber(p.x)
    local py = tonumber(p.y)
    local pz = tonumber(p.z)
    if not px or not py or not pz then
      return nil
    end
    return {x = px, y = py, z = pz}
  end

  local function isContainerPos(p)
    return p and p.x == 65535 and p.y >= 64 and p.z >= 0
  end

  local posFromWidget = nil
  if dragWidget and type(dragWidget.position) == "table" then
    local px = tonumber(dragWidget.position.x)
    local py = tonumber(dragWidget.position.y)
    local pz = tonumber(dragWidget.position.z)
    if px and py and pz then
      posFromWidget = {x = px, y = py, z = pz}
    end
  end
  local posFromItem = normalizePos(dragged:getPosition())

  -- Prefer real container source position (backpack) over widget fallback.
  local pos = nil
  if isContainerPos(posFromItem) then
    pos = posFromItem
  elseif isContainerPos(posFromWidget) then
    pos = posFromWidget
  else
    pos = posFromItem or posFromWidget
  end
  if not pos then
    return false
  end

  local stackpos = 0
  if dragWidget and dragWidget.getId then
    local wid = tostring(dragWidget:getId() or "")
    local idx = tonumber(wid:match("^item(%d+)$"))
    if idx then
      stackpos = idx
    end
  end
  if stackpos <= 0 and isContainerPos(pos) then
    stackpos = tonumber(pos.z) or 0
  end
  if stackpos <= 0 then
    stackpos = tonumber(dragged:getStackPos()) or tonumber(pos.z) or 0
  end

  pendingDropTarget = {
    x = pos.x, y = pos.y, z = pos.z,
    stackpos = stackpos,
    id = dragged:getId(),
    subType = dragged:getCountOrSubType()
  }
  refs.dropHint:setText(string.format("Adding: %s", tostring(dragged:getName() or ("item " .. dragged:getId()))))

  if currentMode == "own" then
    if dragged.isStackable and dragged:isStackable() then
      local maxAmount = math.max(1, math.floor(toNumber(dragged:getCount(), 1)))
      if maxAmount > 1 then
        requestStackAmount(dragged:getId(), maxAmount, function(amount)
          if amount and amount > 0 then
            sendAction("addFromTarget", {target = pendingDropTarget, amount = amount, price = 0})
          end
          clearPendingDrop()
        end)
        return true
      end
    end
    sendAction("addFromTarget", {target = pendingDropTarget, amount = 1, price = 0})
    clearPendingDrop()
  end
  return true
end

local function applySnapshot(data)
  data = type(data) == "table" and data or {}
  ticketRemaining = math.max(0, math.floor(toNumber(data.ticketRemaining, 0)))
  ownDescription = tostring(data.ownDescription or "")
  draftOffers = type(data.draftOffers) == "table" and data.draftOffers or {}
  applyStallIndex({creatureIds = data.stallCreatureIds})
  updateTicketLabel()
  if currentMode == "own" then
    renderOffers()
  end
end

local function applyStall(data)
  data = type(data) == "table" and data or {}
  pendingBrowseOpen = false
  viewedStall = type(data.stall) == "table" and data.stall or nil
  viewedOffers = type(data.offers) == "table" and data.offers or {}
  if viewedStall then
    closeContainerPreview()
    marketWindow:setText(tostring(viewedStall.ownerName or "Shop") .. "'s Shop")
    selectedOfferId = nil
    setMode("browse")
  end
end

local function applyHistory(data)
  historyEntries = type(data) == "table" and type(data.entries) == "table" and data.entries or {}
  renderHistory()
end

local function ensureWindows()
  if marketWindow then return true end

  marketWindow = g_ui.displayUI("market")
  marketWindow:hide()
  marketWindow.onVisibilityChange = function(self, visible)
    if not visible then
      closeContainerPreview()
    end
  end
  descWindow = g_ui.createWidget("MarketDescWindow", rootWidget)
  descWindow:hide()
  historyWindow = g_ui.createWidget("MarketHistoryWindow", rootWidget)
  historyWindow:hide()
  containerPreviewWindow = g_ui.createWidget("MarketContainerWindow", rootWidget)
  containerPreviewWindow:hide()

  refs.ticketLabel = marketWindow:recursiveGetChildById("ticketLabel")
  refs.shopModeLabel = marketWindow:recursiveGetChildById("shopModeLabel")
  refs.offersList = marketWindow:recursiveGetChildById("offersList")
  refs.dropPanel = marketWindow:recursiveGetChildById("dropPanel")
  refs.dropHint = marketWindow:recursiveGetChildById("dropHint")
  refs.priceLabel = marketWindow:recursiveGetChildById("priceLabel")
  refs.unitPriceHintLabel = marketWindow:recursiveGetChildById("unitPriceHintLabel")
  refs.priceInput = marketWindow:recursiveGetChildById("priceInput")
  refs.addButton = marketWindow:recursiveGetChildById("addButton")
  refs.selectedIcon = marketWindow:recursiveGetChildById("selectedIcon")
  refs.selectedName = marketWindow:recursiveGetChildById("selectedName")
  refs.selectedDesc = marketWindow:recursiveGetChildById("selectedDesc")
  refs.buyButton = marketWindow:recursiveGetChildById("buyButton")
  refs.startShopButton = marketWindow:recursiveGetChildById("startShopButton")
  refs.editDescriptionButton = marketWindow:recursiveGetChildById("editDescriptionButton")
  refs.historyButton = marketWindow:recursiveGetChildById("historyButton")
  refs.closeButton = marketWindow:recursiveGetChildById("closeButton")

  historyRefs.list = historyWindow:recursiveGetChildById("historyList")
  historyRefs.prevButton = historyWindow:recursiveGetChildById("historyPrevButton")
  historyRefs.nextButton = historyWindow:recursiveGetChildById("historyNextButton")
  historyRefs.pageLabel = historyWindow:recursiveGetChildById("historyPageLabel")
  historyRefs.closeButton = historyWindow:recursiveGetChildById("historyCloseButton")

  containerRefs.list = containerPreviewWindow:recursiveGetChildById("containerPreviewList")
  containerRefs.title = containerPreviewWindow:recursiveGetChildById("containerPreviewTitle")
  containerRefs.backButton = containerPreviewWindow:recursiveGetChildById("containerPreviewBackButton")
  containerRefs.closeButton = containerPreviewWindow:recursiveGetChildById("containerPreviewCloseButton")

  descRefs.input = descWindow:recursiveGetChildById("descriptionInput")
  descRefs.limitLabel = descWindow:recursiveGetChildById("descriptionLimitLabel")
  descRefs.saveButton = descWindow:recursiveGetChildById("descriptionSaveButton")
  descRefs.closeButton = descWindow:recursiveGetChildById("descriptionCloseButton")

  refs.offersList.onDrop = function(self, widget, mousePos)
    local row = self:getChildByPos(mousePos)
    local slot = row and row.getChildByPos and row:getChildByPos(mousePos) or nil
    if slot and slot.onDrop then
      return slot:onDrop(widget, mousePos, true)
    end

    local lastRow = self:getChildByIndex(-1)
    local lastSlot = lastRow and lastRow.getChildByIndex and lastRow:getChildByIndex(-1) or nil
    if lastSlot and lastSlot.onDrop then
      return lastSlot:onDrop(widget, mousePos, true)
    end
    return false
  end

  marketWindow.onDrop = function(self, widget, mousePos)
    if currentMode ~= "own" then
      return false
    end
    if not refs.offersList or not refs.offersList.containsPoint or not refs.offersList:containsPoint(mousePos) then
      return false
    end
    return refs.offersList:onDrop(widget, mousePos)
  end

  refs.addButton.onClick = function()
    if currentMode ~= "own" then
      return
    end
    local offer = getSelectedOffer()
    if not offer or not selectedDraftId then
      showFailure("Select draft item first.")
      return
    end
    local price = math.max(1, math.floor(toNumber(refs.priceInput:getText(), 1)))
    if price <= 0 then
      showFailure("Enter valid price.")
      return
    end
    sendAction("updateDraft", {offerId = selectedDraftId, price = price})
  end
  refs.addButton:setTooltip("Set unit price (price for 1 item).")

  refs.buyButton.onClick = function()
    local offer = getSelectedOffer()
    if not offer or not viewedStall then
      return
    end
    local maxAmount = math.max(1, math.floor(toNumber(offer.count, 1)))
    if maxAmount <= 1 then
      sendAction("buy", {stallId = viewedStall.id, offerId = offer.id, amount = 1})
      return
    end
    local requestItemId = toNumber(offer.clientId, 0)
    if requestItemId <= 0 and type(offer.itemData) == "table" then
      requestItemId = toNumber(offer.itemData.clientId or offer.itemData.id, 0)
    end
    if requestItemId <= 0 then
      requestItemId = toNumber(offer.itemId, 0)
    end
    requestStackAmount(requestItemId, maxAmount, function(amount)
      if not amount or amount <= 0 then
        return
      end
      sendAction("buy", {stallId = viewedStall.id, offerId = offer.id, amount = amount})
    end, offer.price)
  end

  refs.startShopButton.onClick = function() sendAction("startShop", {}) end
  refs.historyButton.onClick = function()
    historyPage = 1
    renderHistory()
    historyWindow:show()
    historyWindow:raise()
    sendAction("history", {})
  end
  refs.editDescriptionButton.onClick = function()
    descRefs.input:setText(ownDescription or "")
    updateDescriptionCounter()
    descWindow:show()
    descWindow:raise()
    descWindow:focus()
  end
  refs.closeButton.onClick = function()
    closeContainerPreview()
    marketWindow:hide()
  end
  historyRefs.closeButton.onClick = function() historyWindow:hide() end
  if historyRefs.prevButton then
    historyRefs.prevButton.onClick = function()
      historyPage = historyPage - 1
      renderHistory()
    end
  end
  if historyRefs.nextButton then
    historyRefs.nextButton.onClick = function()
      historyPage = historyPage + 1
      renderHistory()
    end
  end
  containerRefs.closeButton.onClick = function() closeContainerPreview() end
  containerRefs.backButton.onClick = function()
    if #containerPreviewStack > 1 then
      table.remove(containerPreviewStack, #containerPreviewStack)
      renderContainerPreview()
    end
  end
  descRefs.closeButton.onClick = function() descWindow:hide() end
  descRefs.input.onTextChange = function()
    updateDescriptionCounter()
  end
  descRefs.saveButton.onClick = function()
    local text = trim(descRefs.input:getText() or "")
    if #text > 30 then
      text = text:sub(1, 30)
      descRefs.input:setText(text)
    end
    updateDescriptionCounter()
    sendAction("setDescription", {description = text})
    descWindow:hide()
  end

  refs.priceInput:setText("1")
  clearPendingDrop()
  setMode("own")
  return true
end

local function openWindow(mode, title)
  if not ensureWindows() then return end
  marketWindow:setText(tostring(title or "Market"))
  marketWindow:show()
  marketWindow:raise()
  marketWindow:focus()
  setMode(mode)
  scheduleEvent(function()
    if marketWindow and marketWindow:isVisible() and currentMode == "own" then
      renderOffers()
    end
  end, 50)
end

local function onResult(data)
  local ok = type(data) == "table" and data.ok == true
  local message = type(data) == "table" and tostring(data.message or "") or ""
  if pendingBrowseOpen and not ok then
    pendingBrowseOpen = false
  end
  if ok then showStatus(message) else showFailure(message) end
end

local function onExtendedOpcode(protocol, opcode, buffer)
  if type(buffer) ~= "string" or buffer == "" then return end

  local first = buffer:sub(1, 1)
  if first == "S" and buffer:sub(2, 2) == "{" then jsonBuffer = buffer:sub(2); return end
  if first == "P" and jsonBuffer ~= "" then jsonBuffer = jsonBuffer .. buffer:sub(2); return end
  if first == "E" and jsonBuffer ~= "" then buffer = jsonBuffer .. buffer:sub(2); jsonBuffer = "" end

  local ok, payload = pcall(function() return json.decode(buffer) end)
  if not ok or type(payload) ~= "table" then return end

  local action = payload.action
  local data = payload.data
  if action == "open" then
    if type(data) == "table" and data.mode == "browse" then
      pendingBrowseOpen = false
    end
    openWindow(type(data) == "table" and data.mode or "own", type(data) == "table" and data.title or "Market")
    if type(data) == "table" and data.ticketRemaining then
      ticketRemaining = math.max(0, math.floor(toNumber(data.ticketRemaining, 0)))
      updateTicketLabel()
    end
    if currentMode == "own" then
      sendAction("fetch", {})
      sendAction("history", {})
    end
  elseif action == "snapshot" then
    applySnapshot(data)
  elseif action == "stall" then
    applyStall(data)
  elseif action == "history" then
    applyHistory(data)
  elseif action == "result" then
    onResult(data)
    sendAction("fetch", {})
  elseif action == "activated" then
    showStatus(type(data) == "table" and data.message or "Shop started.")
    scheduleEvent(function() if g_game.isOnline() then g_game.safeLogout() end end, 10)
  elseif action == "ticket" then
    ticketRemaining = type(data) == "table" and math.max(0, math.floor(toNumber(data.ticketRemaining, 0))) or 0
    updateTicketLabel()
  elseif action == "stallIndex" then
    applyStallIndex(data)
  end
end

function shouldShowSelfMenu()
  return g_game.isOnline()
end

function openFromSelfMenu()
  openWindow("own", (g_game.getCharacterName() or "Player") .. "'s Shop")
  sendAction("openOwn", {})
end

local function openStallByCreature(creatureId)
  pendingBrowseOpen = true
  viewedStall = nil
  viewedOffers = {}
  selectedOfferId = nil
  sendAction("openByCreature", {creatureId = creatureId})
end

local function addMenuHook()
  if menuHookAdded then return end
  if not modules or not modules.game_interface or not modules.game_interface.addMenuHook then return end
  modules.game_interface.addMenuHook(
    MENU_HOOK_CATEGORY,
    MENU_HOOK_NAME,
    function(_, _, _, creatureThing)
      if not creatureThing or not creatureThing.getId then return end
      openStallByCreature(creatureThing:getId())
    end,
    function(_, _, _, creatureThing)
      if not creatureThing or not creatureThing.getId then return false end
      local cid = creatureThing:getId()
      if knownStallCreatureIds[cid] then
        return true
      end

      if creatureThing.getName then
        local name = trim(creatureThing:getName()):lower()
        if name == "market stall" then
          return true
        end
      end
      return false
    end
  )
  menuHookAdded = true
end

local function removeMenuHook()
  if not menuHookAdded then return end
  if modules and modules.game_interface and modules.game_interface.removeMenuHook then
    modules.game_interface.removeMenuHook(MENU_HOOK_CATEGORY, MENU_HOOK_NAME)
  end
  menuHookAdded = false
end

function init()
  ProtocolGame.registerExtendedOpcode(OPCODE_MARKET, onExtendedOpcode)
  ensureWindows()
  addMenuHook()
  refreshStallIndex()
  tickEvent = cycleEvent(function()
    if ticketRemaining > 0 then
      ticketRemaining = math.max(0, ticketRemaining - 1)
      updateTicketLabel()
    end
  end, 1000)
  stallIndexEvent = cycleEvent(function()
    refreshStallIndex()
  end, 3000)
end

function terminate()
  pcall(function() ProtocolGame.unregisterExtendedOpcode(OPCODE_MARKET, onExtendedOpcode) end)
  if tickEvent then removeEvent(tickEvent) tickEvent = nil end
  if stallIndexEvent then removeEvent(stallIndexEvent) stallIndexEvent = nil end
  closeMarketCountWindow()
  removeMenuHook()

  if marketWindow then marketWindow:destroy() marketWindow = nil end
  if descWindow then descWindow:destroy() descWindow = nil end
  if historyWindow then historyWindow:destroy() historyWindow = nil end
  if containerPreviewWindow then containerPreviewWindow:destroy() containerPreviewWindow = nil end

  refs = {}
  historyRefs = {}
  descRefs = {}
  containerRefs = {}
  jsonBuffer = ""
  containerPreviewStack = {}
  knownStallCreatureIds = {}
  pendingBrowseOpen = false
end
