local GAME_STORE_CODE = 102
local DONATION_URL = nil

gameStoreWindow = nil
offersGrid = nil
msgWindow = nil
local gameStoreButton = nil
local gameStoreButtonWindow = nil
local giftWindow = nil
local storePulseEvent = nil
local storePulseStep = 1

local STORE_BG_COLORS = {
  "#285b9fcc",
  "#4a6fa8d6",
  "#8a6a1dcc",
  "#4a6fa8d6"
}

local STORE_BORDER_COLORS = {
  "#79b6ff",
  "#a8d0ff",
  "#d5a03a",
  "#a8d0ff"
}

local categories = nil
local offers = {}
local historyEntries = {}

local selectedOffer = nil

local function resolveCategoryKey(widget)
  if not widget then
    return nil
  end

  local current = widget
  for _ = 1, 4 do
    if not current then
      break
    end

    local id = current.getId and current:getId() or nil
    if id == "name" and current.getText then
      local labelText = current:getText()
      if labelText and labelText ~= "" then
        return labelText
      end
    end

    local nameWidget = current.getChildById and current:getChildById("name") or nil
    if nameWidget and nameWidget.getText then
      local nameText = nameWidget:getText()
      if nameText and nameText ~= "" then
        return nameText
      end
    end

    if id and offers[id] then
      return id
    end

    current = current.getParent and current:getParent() or nil
  end

  return widget.getId and widget:getId() or nil
end

local function getFocusedCategoryId()
  if not gameStoreWindow then
    return nil
  end
  local categoriesPanel = gameStoreWindow:getChildById("categories")
  if not categoriesPanel then
    return nil
  end
  local focused = categoriesPanel:getFocusedChild()
  if not focused then
    return nil
  end
  return resolveCategoryKey(focused)
end

local function isHiddenCategory(categoryData)
  if type(categoryData) ~= "table" then
    return false
  end

  local title = type(categoryData.title) == "string" and categoryData.title:lower() or ""
  return title == "mounts" or categoryData.iconType == "mount"
end

local function refreshFocusedOffers()
  if not offersGrid then
    return
  end
  local focusedCategoryId = getFocusedCategoryId()
  if not focusedCategoryId then
    return
  end
  local focusedOffers = offers[focusedCategoryId]
  if type(focusedOffers) ~= "table" then
    return
  end
  offersGrid:destroyChildren()
  addOffers(focusedOffers)
end

local function createStoreButtonWindow()
  local rightPanel = modules.game_interface.getRightPanel()
  if not rightPanel then
    return false
  end

  gameStoreButtonWindow = g_ui.loadUI("store_button", rightPanel)
  if not gameStoreButtonWindow then
    return false
  end

  gameStoreButtonWindow:disableResize()
  gameStoreButtonWindow:setup()

  local contentsPanel = gameStoreButtonWindow:getChildById("contentsPanel")
  if contentsPanel then
    gameStoreButton = contentsPanel:getChildById("gameStoreWideButton")
  end
  if not gameStoreButton then
    gameStoreButton = gameStoreButtonWindow:recursiveGetChildById("gameStoreWideButton")
  end

  if not gameStoreButton then
    gameStoreButtonWindow:destroy()
    gameStoreButtonWindow = nil
    return false
  end

  gameStoreButton:setText("Store")
  gameStoreButton:setTooltip(tr("Store"))
  gameStoreButton.onClick = toggle

  return true
end

local function placeStoreButtonWindow()
  if not gameStoreButtonWindow or not modules.game_buttons or not modules.game_buttons.buttonsWindow then
    return
  end

  local buttonsWindow = modules.game_buttons.buttonsWindow
  local pos = buttonsWindow:getPosition()
  local width = math.max(124, buttonsWindow:getWidth())

  gameStoreButtonWindow:breakAnchors()
  gameStoreButtonWindow:setWidth(width)
  gameStoreButtonWindow:setHeight(22)
  if gameStoreButton then
    gameStoreButton:setWidth(width)
    gameStoreButton:setHeight(22)
  end
  gameStoreButtonWindow:setPosition({
    x = pos.x,
    y = pos.y + buttonsWindow:getHeight() + 3
  })
end

local function destroyStoreButtonWindow()
  removeEvent(storePulseEvent)
  storePulseEvent = nil
  if gameStoreButtonWindow then
    gameStoreButtonWindow:destroy()
    gameStoreButtonWindow = nil
  end
  gameStoreButton = nil
end

local function updateStorePulse()
  if not gameStoreButton then
    storePulseEvent = nil
    return
  end

  gameStoreButton:setBackgroundColor(STORE_BG_COLORS[storePulseStep])
  gameStoreButton:setBorderColor(STORE_BORDER_COLORS[storePulseStep])

  storePulseStep = storePulseStep + 1
  if storePulseStep > #STORE_BG_COLORS then
    storePulseStep = 1
  end

  storePulseEvent = scheduleEvent(updateStorePulse, 420)
end

local function startStorePulse()
  removeEvent(storePulseEvent)
  storePulseEvent = nil
  storePulseStep = 1
  updateStorePulse()
end

function init()
  g_ui.importStyle("store_button")

  connect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )

  ProtocolGame.registerExtendedOpcode(GAME_STORE_CODE, onExtendedOpcode)

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

  ProtocolGame.unregisterExtendedOpcode(GAME_STORE_CODE, onExtendedOpcode)

  destroy()
end

function onExtendedOpcode(protocol, code, buffer)
  local json_status, json_data =
    pcall(
    function()
      return json.decode(buffer)
    end
  )
  if not json_status then
    g_logger.error("SHOP json error: " .. json_data)
    return false
  end

  local action = json_data["action"]
  local data = json_data["data"]
  if not action or not data then
    return false
  end

  if action == "fetchBase" then
    onGameStoreFetchBase(data)
  elseif action == "fetchOffers" then
    onGameStoreFetchOffers(data)
  elseif action == "points" then
    onGameStoreUpdatePoints(data)
  elseif action == "history" then
    onGameStoreUpdateHistory(data)
  elseif action == "msg" then
    onGameStoreMsg(data)
  end
end

function create()
  if gameStoreWindow then
    return
  end
  gameStoreWindow = g_ui.displayUI("store")
  gameStoreWindow:hide()

  if not createStoreButtonWindow() then
    gameStoreButton = modules.client_topmenu.addRightGameToggleButton("gameStoreButton", tr("Store"), "/images/topbuttons/shop", toggle, true)
  else
    addEvent(placeStoreButtonWindow)
    scheduleEvent(placeStoreButtonWindow, 50)
    scheduleEvent(placeStoreButtonWindow, 150)
    startStorePulse()
  end

  connect(gameStoreWindow:getChildById("categories"), {onChildFocusChange = changeCategory})
  connect(gameStoreWindow:getChildById("offers"), {onChildFocusChange = offerFocus})

  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(GAME_STORE_CODE, json.encode({action = "fetch", data = {}}))
  end
end

function destroy()
  if gameStoreButton and not gameStoreButtonWindow then
    gameStoreButton:destroy()
  end
  destroyStoreButtonWindow()

  if gameStoreWindow then
    disconnect(gameStoreWindow:getChildById("categories"), {onChildFocusChange = changeCategory})
    disconnect(gameStoreWindow:getChildById("offers"), {onChildFocusChange = offerFocus})
    offersGrid = nil
    gameStoreWindow:destroy()
    gameStoreWindow = nil
  end

  if msgWindow then
    msgWindow:destroy()
    msgWindow = nil
  end

  if giftWindow then
    giftWindow:destroy()
    giftWindow = nil
  end
end

function onGameStoreFetchBase(data)
  categories = {}
  for _, categoryData in ipairs(data.categories or {}) do
    if not isHiddenCategory(categoryData) then
      table.insert(categories, categoryData)
    end
  end
  offers = {}
  historyEntries = {}
  selectedOffer = nil

  local categoriesPanel = gameStoreWindow and gameStoreWindow:getChildById("categories")
  if categoriesPanel then
    categoriesPanel:destroyChildren()
  end
  if offersGrid then
    offersGrid:destroyChildren()
  end

  for i = 1, #categories do
    addCategory(categories[i], i == 1)
  end
  DONATION_URL = data.url
end

function onGameStoreFetchOffers(data)
  if type(data) ~= "table" then
    return
  end

  local category = data.category
  if not category then
    return
  end

  local chunk = tonumber(data.chunk) or 1
  local total = tonumber(data.total) or 1
  local incomingOffers = type(data.offers) == "table" and data.offers or {}

  if chunk <= 1 or type(offers[category]) ~= "table" then
    offers[category] = {}
  end
  for i = 1, #incomingOffers do
    table.insert(offers[category], incomingOffers[i])
  end

  if chunk < total then
    return
  end

  if not offersGrid then
    offersGrid = gameStoreWindow and gameStoreWindow:recursiveGetChildById("offers") or nil
  end
  if not gameStoreWindow or not offersGrid then
    return
  end

  local categoriesPanel = gameStoreWindow:getChildById("categories")
  if categoriesPanel and not categoriesPanel:getFocusedChild() and categoriesPanel:getChildCount() > 0 then
    categoriesPanel:getChildByIndex(1):focus()
  end

  local focusedCategoryId = getFocusedCategoryId()
  if focusedCategoryId == category then
    offersGrid:destroyChildren()
    addOffers(offers[category])
  elseif offersGrid:getChildCount() == 0 then
    refreshFocusedOffers()
  end
end

function onGameStoreUpdatePoints(data)
  local pointsWidget = gameStoreWindow:recursiveGetChildById("points")
  local points = comma_value(tonumber(data))
  pointsWidget:setText(string.format(pointsWidget.baseText, points))
end

function onGameStoreUpdateHistory(history)
  if type(history) == "table" and history.entries then
    local chunk = tonumber(history.chunk) or 1
    local total = tonumber(history.total) or 1
    local entries = type(history.entries) == "table" and history.entries or {}

    if chunk <= 1 then
      historyEntries = {}
    end

    for i = 1, #entries do
      table.insert(historyEntries, entries[i])
    end

    if chunk < total then
      return
    end

    history = historyEntries
  elseif type(history) ~= "table" then
    history = {}
  else
    historyEntries = history
  end

  local historyPanel = gameStoreWindow:getChildById("history")
  historyPanel:destroyChildren()
  scheduleEvent(
    function()
      for i = 1, #history do
        local category = g_ui.createWidget("HistoryLabel", historyPanel)
        category:setText(history[i])
      end
    end,
    250
  )
end

function purchase()
  if not selectedOffer then
    displayInfoBox("Error", "Something went wrong, make sure to select category and offer.")
    return
  end

  hide()

  local title = "Purchase Confirmation"
  local msg = "Do you want to buy " .. selectedOffer.title .. " for " .. selectedOffer.price .. " points?"
  msgWindow =
    displayGeneralBox(
    title,
    msg,
    {
      {text = "Yes", callback = buyConfirmed},
      {text = "No", callback = buyCanceled},
      anchor = AnchorHorizontalCenter
    },
    buyConfirmed,
    buyCanceled
  )
end

function buyConfirmed()
  msgWindow:destroy()
  msgWindow = nil
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(GAME_STORE_CODE, json.encode({action = "purchase", data = selectedOffer}))
  end
end

function buyCanceled()
  msgWindow:destroy()
  msgWindow = nil
end

function gift()
  if giftWindow then
    return
  end
  if not selectedOffer then
    displayInfoBox("Error", "Something went wrong, make sure to select category and offer.")
    return
  end

  giftWindow = g_ui.displayUI("gift")
end

function confirmGift()
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    local targetName = giftWindow:getChildById("targetName")
    selectedOffer.target = targetName:getText()
    protocolGame:sendExtendedOpcode(GAME_STORE_CODE, json.encode({action = "gift", data = selectedOffer}))
    targetName = nil
    giftWindow:destroy()
    giftWindow = nil
  end
end

function cancelGift()
  giftWindow:destroy()
  giftWindow = nil
end

function onGameStoreMsg(data)
  local type = data.type
  local text = data.msg

  local title = nil
  local close = false
  if type == "info" then
    title = "Store Information"
    close = data.close
  elseif type == "error" then
    title = "Store Error"
    close = true
  end

  if close then
    hideHistory()
    gameStoreWindow:getChildById("purchaseButton"):disable()
    gameStoreWindow:getChildById("giftButton"):disable()
    gameStoreWindow:getChildById("offers"):focusChild(nil)
    hide()
  end

  displayInfoBox(title, text, {{text = "Ok", callback = defaultCallback}}, defaultCallback, defaultCallback)
end

function changeCategory(widget, newCategory)
  if not newCategory then
    return
  end

  local id = resolveCategoryKey(newCategory)
  offersGrid:destroyChildren()
  addOffers(offers[id])

  local category = nil
  for i = 1, #categories do
    if categories[i].title == id then
      category = categories[i]
      break
    end
  end

  if category then
    updateTopPanel(category)
    gameStoreWindow:getChildById("purchaseButton"):disable()
    gameStoreWindow:getChildById("giftButton"):disable()
    gameStoreWindow:getChildById("search"):setText("")
  end
end

function offerFocus(widget, offerWidget)
  if offerWidget then
    local focusedCategory = gameStoreWindow:getChildById("categories"):getFocusedChild()
    local category = resolveCategoryKey(focusedCategory)
    local title = offerWidget:getChildById("offerNameHidden"):getText()
    local priceLabel = offerWidget:getChildById("offerPrice"):getText()
    local price = priceLabel:split(" points")[1]:gsub("%,", "")
    selectedOffer = {category = category, title = title, price = tonumber(price)}
    gameStoreWindow:getChildById("purchaseButton"):enable()
    gameStoreWindow:getChildById("giftButton"):enable()
  end
end

function purchaseDouble(offerWidget)
  if offerWidget and offerWidget:isFocused() then
    local focusedCategory = gameStoreWindow:getChildById("categories"):getFocusedChild()
    local category = resolveCategoryKey(focusedCategory)
    local title = offerWidget:getChildById("offerNameHidden"):getText()
    local priceLabel = offerWidget:getChildById("offerPrice"):getText()
    local price = priceLabel:split(" points")[1]:gsub("%,", "")
    selectedOffer = {category = category, title = title, price = tonumber(price), clientId = tonumber(offerWidget:getId())}
    gameStoreWindow:getChildById("purchaseButton"):enable()
    gameStoreWindow:getChildById("giftButton"):enable()
    purchase()
  end
end

function addCategory(data, first)
  local category = g_ui.createWidget("ShopCategory", gameStoreWindow:getChildById("categories"))
  category:setId(data.title)
  category:getChildById("name"):setText(data.title)

  if first then
    updateTopPanel(data)
  end
end

function showHistory()
  gameStoreWindow:getChildById("historyButton"):hide()
  gameStoreWindow:getChildById("purchaseButton"):hide()
  gameStoreWindow:getChildById("giftButton"):hide()
  gameStoreWindow:getChildById("offers"):hide()
  gameStoreWindow:getChildById("offersScrollBar"):hide()
  gameStoreWindow:getChildById("topPanel"):hide()
  gameStoreWindow:getChildById("categories"):hide()
  gameStoreWindow:getChildById("infoPanel"):hide()
  gameStoreWindow:getChildById("search"):hide()
  gameStoreWindow:getChildById("searchLabel"):hide()

  gameStoreWindow:getChildById("historyScrollBar"):show()
  gameStoreWindow:getChildById("history"):show()
  gameStoreWindow:getChildById("backButton"):show()

  gameStoreWindow:getChildById("purchaseButton"):disable()
  gameStoreWindow:getChildById("giftButton"):disable()
  gameStoreWindow:getChildById("offers"):focusChild(nil)
end

function hideHistory()
  gameStoreWindow:getChildById("historyButton"):show()
  gameStoreWindow:getChildById("purchaseButton"):show()
  gameStoreWindow:getChildById("giftButton"):show()
  gameStoreWindow:getChildById("offers"):show()
  gameStoreWindow:getChildById("offersScrollBar"):show()
  gameStoreWindow:getChildById("topPanel"):show()
  gameStoreWindow:getChildById("categories"):show()
  gameStoreWindow:getChildById("infoPanel"):show()
  gameStoreWindow:getChildById("search"):show()
  gameStoreWindow:getChildById("searchLabel"):show()

  gameStoreWindow:getChildById("historyScrollBar"):hide()
  gameStoreWindow:getChildById("history"):hide()
  gameStoreWindow:getChildById("backButton"):hide()

  gameStoreWindow:getChildById("categories"):getChildByIndex(1):focus()
end

function addOffers(offerData)
  if type(offerData) ~= "table" then
    return
  end
  for i = 1, #offerData do
    local offer = offerData[i]
    local panel = g_ui.createWidget("OfferWidget")
	panel:setTooltip(offer.description)
    local nameHidden = panel:recursiveGetChildById("offerNameHidden")
    if offer.title:len() > 20 then
      local shorter = offer.title:sub(1, 20) .. "..."
      panel:setText(shorter)
    else
      panel:setText(offer.title)
    end
    nameHidden:setText(offer.title)

    local priceLabel = panel:recursiveGetChildById("offerPrice")
    local price = comma_value(offer.price)
    priceLabel:setText(string.format(priceLabel.baseText, price))

    local offerTypePanel = panel:getChildById("offerTypePanel")
    if offer.type == "item" then
      local offerIcon = g_ui.createWidget("OfferIconItem", offerTypePanel)
      offerIcon:setItemId(offer.clientId)
      offerIcon:setItemCount(offer.count)
    elseif offer.type == "outfit" then
      local offerIcon = g_ui.createWidget("OfferIconCreature", offerTypePanel)
      offerIcon:setOutfit(offer.outfit)
    elseif offer.type == "mount" then
      local offerIcon = g_ui.createWidget("OfferIconCreature", offerTypePanel)
      offerIcon:setOutfit({type = offer.clientId})
	elseif offer.type == "wings" then
      local offerIcon = g_ui.createWidget("OfferIconCreature", offerTypePanel)
      offerIcon:setOutfit({type = offer.clientId})
	elseif offer.type == "aura" then
      local offerIcon = g_ui.createWidget("OfferIconCreature", offerTypePanel)
      offerIcon:setOutfit({type = offer.clientId})
	elseif offer.type == "shader" then
      local offerIcon = g_ui.createWidget("OfferIconCreature", offerTypePanel)
      offerIcon:setOutfit({type = offer.clientId})
	
	
    end

    offersGrid:addChild(panel)
  end
end

function updateTopPanel(data)
  local topPanel = gameStoreWindow:getChildById("topPanel")
  local categoryItemBg = topPanel:getChildById("categoryItemBg")
  categoryItemBg:destroyChildren()
  if data.iconType == "sprite" then
    local spriteIcon = g_ui.createWidget("CategoryIconSprite", categoryItemBg)
    spriteIcon:setSpriteId(data.iconData)
  elseif data.iconType == "item" then
    local spriteIcon = g_ui.createWidget("CategoryIconItem", categoryItemBg)
    spriteIcon:setItemId(data.iconData)
  elseif data.iconType == "outfit" then
    local spriteIcon = g_ui.createWidget("CategoryIconCreature", categoryItemBg)
    spriteIcon:setOutfit(data.iconData)
  elseif data.iconType == "mount" then
    local spriteIcon = g_ui.createWidget("CategoryIconCreature", categoryItemBg)
    spriteIcon:setOutfit({type = data.iconData})
	elseif data.iconType == "wings" then
    local spriteIcon = g_ui.createWidget("CategoryIconCreature", categoryItemBg)
    spriteIcon:setOutfit({type = data.iconData})
	elseif data.iconType == "aura" then
    local spriteIcon = g_ui.createWidget("CategoryIconCreature", categoryItemBg)
    spriteIcon:setOutfit({type = data.iconData})
	
    end

  topPanel:getChildById("selectedCategory"):setText(data.title)
  topPanel:getChildById("categoryDescription"):setText(data.description)
end

function onSearch()
  scheduleEvent(
    function()
      local searchWidget = gameStoreWindow:getChildById("search")
      local text = searchWidget:getText()
      if text:len() >= 1 then
        local children = offersGrid:getChildCount()
        for i = 1, children do
          local child = offersGrid:getChildByIndex(i)
          local offerName = child:getChildById("offerNameHidden"):getText():lower()
          if offerName:find(text) then
            child:show()
          else
            child:hide()
          end
        end
      else
        local children = offersGrid:getChildCount()
        for i = 1, children do
          local child = offersGrid:getChildByIndex(i)
          child:show()
        end
      end
    end,
    50
  )
end

function buyPoints()
  g_platform.openUrl(DONATION_URL)
end

function toggle()
  if not gameStoreWindow then
    return
  end
  if gameStoreWindow:isVisible() then
    return hide()
  end
  show()
end

function show()
  if not gameStoreWindow or not gameStoreButton then
    return
  end
  local categoriesPanel = gameStoreWindow:getChildById("categories")
  if categoriesPanel then
    local firstCategory = categoriesPanel:getChildByIndex(1)
    if firstCategory then
      firstCategory:focus()
    end
  end
  refreshFocusedOffers()
  hideHistory()
  gameStoreWindow:show()
  gameStoreWindow:raise()
  gameStoreWindow:focus()
  gameStoreButton:setOn(true)
end

function hide()
  if not gameStoreWindow then
    return
  end
  gameStoreWindow:hide()
  if gameStoreButton then
    gameStoreButton:setOn(false)
  end
end

function comma_value(n)
  local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")
  return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end
