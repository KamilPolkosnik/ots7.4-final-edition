local CODE = 108

local window = nil
local categories = nil
local craftPanel = nil
local itemsList = nil
local weaponCategoryPanel = nil
local armorCategoryPanel = nil
local alchemistCategoryPanel = nil
local categorySeparator = nil
local enchantTargetPanel = nil
local enchantTargetWidget = nil
local enchantTargetLabel = nil
local enchantTargetHint = nil
local enchantTargetSelectButton = nil
local enchantTargetSlotsPanel = nil
local enchantTargetSlotButtons = {}
local refreshItemsList = nil

local selectedCategory = nil
local selectedCraftId = nil
local selectedWeaponCategory = "axe"
local selectedArmorCategory = "helmet"
local selectedAlchemistCategory = "rings"
local Crafts = {weaponsmith = {}, armorsmith = {}, alchemist = {}, enchanter = {}, jeweller = {}}
local money = 0
local selectedEnchantTarget = nil
local selectedEnchantTargetSlot = nil
local allowedEnchanterCraftIds = {}

local function clampRecipeIndex(craft, index)
  local total = craft and craft.recipes and #craft.recipes or 0
  if total <= 0 then
    return 1
  end
  index = tonumber(index) or 1
  if index < 1 then
    index = 1
  elseif index > total then
    index = total
  end
  return index
end

local function getActiveRecipe(craft)
  if craft and craft.recipes and #craft.recipes > 0 then
    craft.selectedRecipe = clampRecipeIndex(craft, craft.selectedRecipe)
    return craft.recipes[craft.selectedRecipe], craft.selectedRecipe, #craft.recipes
  end
  return craft, 1, 1
end

local function getMaterialTooltip(material)
  if not material then
    return ""
  end

  local name = tostring(material.name or "")
  local serverId = tonumber(material.serverId) or 0
  if name ~= "" and serverId > 0 then
    return string.format("%s (id: %d)", name, serverId)
  elseif name ~= "" then
    return name
  elseif serverId > 0 then
    return string.format("id: %d", serverId)
  end
  return ""
end

local function updateRecipeControls(recipeIndex, recipeCount)
  if not craftPanel then
    return
  end

  local recipeLabel = craftPanel:getChildById("recipeLabel")
  local recipePrev = craftPanel:getChildById("recipePrev")
  local recipeNext = craftPanel:getChildById("recipeNext")
  -- Recipe controls were moved to the craftable item row list.
  if recipeLabel then
    recipeLabel:setText("")
    recipeLabel:hide()
  end

  if recipePrev then
    recipePrev:setVisible(false)
  end

  if recipeNext then
    recipeNext:setVisible(false)
  end
end

local function cycleCraftRecipe(craftId)
  if not selectedCategory then
    return
  end

  local craft = Crafts[selectedCategory] and Crafts[selectedCategory][craftId]
  if not craft or not craft.recipes or #craft.recipes <= 1 then
    return
  end

  local current = clampRecipeIndex(craft, craft.selectedRecipe)
  craft.selectedRecipe = current + 1
  if craft.selectedRecipe > #craft.recipes then
    craft.selectedRecipe = 1
  end

  selectItem(craftId)
end

local function setAllowedEnchanterCraftIds(ids)
  allowedEnchanterCraftIds = {}
  if type(ids) ~= "table" then
    return
  end

  for _, id in ipairs(ids) do
    id = tonumber(id)
    if id then
      allowedEnchanterCraftIds[id] = true
    end
  end
end

local function refreshEnchantTargetSlotButtons()
  for i = 1, #enchantTargetSlotButtons do
    local button = enchantTargetSlotButtons[i]
    if button and button.slotValue then
      local text = "Slot[" .. tostring(button.slotValue) .. "]"
      button:setText(text)
    end
  end
end

local function updateEnchantTargetSlots(emptySlots)
  if type(emptySlots) ~= "table" then
    emptySlots = {}
  end

  local normalized = {}
  for _, slot in ipairs(emptySlots) do
    slot = tonumber(slot)
    if slot and slot > 0 then
      table.insert(normalized, slot)
    end
  end
  table.sort(normalized)

  local selectedStillValid = false
  for _, slot in ipairs(normalized) do
    if tonumber(selectedEnchantTargetSlot) == slot then
      selectedStillValid = true
      break
    end
  end
  if not selectedStillValid then
    selectedEnchantTargetSlot = normalized[1] or nil
  end

  for i = 1, #enchantTargetSlotButtons do
    local button = enchantTargetSlotButtons[i]
    if button then
      local slot = normalized[i]
      if slot then
        button.slotValue = slot
        button:setTooltip("Empty slot " .. slot)
        button:setVisible(true)
        button.onClick = function()
          selectedEnchantTargetSlot = slot
          refreshEnchantTargetSlotButtons()
          if enchantTargetHint then
            enchantTargetHint:setText("slot: " .. tostring(selectedEnchantTargetSlot))
          end
          return true
        end
      else
        button.slotValue = nil
        button:setVisible(false)
        button.onClick = nil
      end
    end
  end

  refreshEnchantTargetSlotButtons()
end

local function requestEnchanterOptions()
  if not selectedEnchantTarget then
    setAllowedEnchanterCraftIds({})
    selectedEnchantTargetSlot = nil
    updateEnchantTargetSlots({})
    if selectedCategory == "enchanter" then
      refreshItemsList()
    end
    return
  end

  local protocolGame = g_game.getProtocolGame()
  if not protocolGame then
    return
  end

  protocolGame:sendExtendedOpcode(CODE, json.encode({action = "enchanter_target", data = {target = selectedEnchantTarget}}))
end

local function clearEnchantTargetSelection()
  selectedEnchantTarget = nil
  selectedEnchantTargetSlot = nil
  setAllowedEnchanterCraftIds({})
  updateEnchantTargetSlots({})
  if enchantTargetWidget then
    enchantTargetWidget:setItem(nil)
    enchantTargetWidget:setTooltip("")
  end
  if enchantTargetHint then
    enchantTargetHint:setText("choose item from backpack and empty slot")
  end
  if selectedCategory == "enchanter" then
    refreshItemsList()
  end
end

local function applyEnchantTargetThing(targetThing)
  if not targetThing or not targetThing:isItem() then
    modules.game_textmessage.displayFailureMessage("Select an item.")
    return false
  end

  local pos = targetThing:getPosition()
  if not pos then
    modules.game_textmessage.displayFailureMessage("Invalid target item.")
    return false
  end

  if pos.x ~= 65535 then
    modules.game_textmessage.displayFailureMessage("Select item from backpack/container only.")
    return false
  end

  if pos.y <= InventorySlotLast then
    modules.game_textmessage.displayFailureMessage("Select from backpack/container, not equipped slot.")
    return false
  end

  local stackPos = targetThing.getStackPos and targetThing:getStackPos() or 0
  local subType = targetThing.getCountOrSubType and targetThing:getCountOrSubType() or 1
  local itemId = targetThing:getId()
  selectedEnchantTarget = {
    x = pos.x,
    y = pos.y,
    z = pos.z,
    stackpos = stackPos,
    id = itemId,
    subType = subType
  }

  if enchantTargetWidget then
    enchantTargetWidget:setItem(Item.create(itemId, subType))
    enchantTargetWidget:setTooltip("Selected item id: " .. itemId)
  end
  if enchantTargetHint then
    enchantTargetHint:setText("item id: " .. itemId .. " pos: " .. pos.x .. "," .. pos.y .. "," .. pos.z .. " | loading...")
  end

  selectedEnchantTargetSlot = nil
  updateEnchantTargetSlots({})
  requestEnchanterOptions()
  return true
end

function init()
  connect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )

  ProtocolGame.registerExtendedOpcode(CODE, onExtendedOpcode)

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

  ProtocolGame.unregisterExtendedOpcode(CODE, onExtendedOpcode)

  destroy()
end

function create()
  if window then
    return
  end

  window = g_ui.displayUI("crafting")
  window:hide()

  categories = window:getChildById("categories")
  craftPanel = window:getChildById("craftPanel")
  itemsList = window:getChildById("itemsList")
  weaponCategoryPanel = window:getChildById("weaponCategoryPanel")
  armorCategoryPanel = window:getChildById("armorCategoryPanel")
  alchemistCategoryPanel = window:getChildById("alchemistCategoryPanel")
  categorySeparator = window:getChildById("categorySeparator")
  enchantTargetPanel = window:getChildById("enchantTargetPanel")
  enchantTargetWidget = window:recursiveGetChildById("enchantTargetLeft")
  enchantTargetLabel = window:recursiveGetChildById("enchantTargetLabelLeft")
  enchantTargetHint = window:recursiveGetChildById("enchantTargetHintLeft")
  enchantTargetSelectButton = window:recursiveGetChildById("enchantTargetSelectButton")
  enchantTargetSlotsPanel = window:recursiveGetChildById("enchantTargetSlotsPanel")
  enchantTargetSlotButtons = {}
  for i = 1, 6 do
    local button = window:recursiveGetChildById("enchantTargetSlot" .. i)
    if button then
      enchantTargetSlotButtons[#enchantTargetSlotButtons + 1] = button
    end
  end
  updateEnchantTargetSlots({})

  if enchantTargetWidget then
    enchantTargetWidget.onDrop = function(self, widget, mousePos, forced)
      if not self:canAcceptDrop(widget, mousePos) and not forced then
        return false
      end
      local draggedItem = widget.currentDragThing
      if not draggedItem or not draggedItem:isItem() then
        return false
      end
      return applyEnchantTargetThing(draggedItem)
    end

    enchantTargetWidget.onMouseRelease = function(self, mousePos, mouseButton)
      if mouseButton == MouseRightButton then
        clearEnchantTargetSelection()
        return true
      end
      return false
    end
  end

  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(CODE, json.encode({action = "fetch"}))
  end
end

function destroy()
  if window then
    categories = nil
    craftPanel = nil
    itemsList = nil
    weaponCategoryPanel = nil
    armorCategoryPanel = nil
    alchemistCategoryPanel = nil
    categorySeparator = nil
    enchantTargetPanel = nil
    enchantTargetWidget = nil
    enchantTargetLabel = nil
    enchantTargetHint = nil
    enchantTargetSelectButton = nil
    enchantTargetSlotsPanel = nil
    enchantTargetSlotButtons = {}

    selectedCategory = nil
    selectedCraftId = nil
    selectedWeaponCategory = "axe"
    selectedArmorCategory = "helmet"
    selectedAlchemistCategory = "rings"
    Crafts = {weaponsmith = {}, armorsmith = {}, alchemist = {}, enchanter = {}, jeweller = {}}
    selectedEnchantTarget = nil
    selectedEnchantTargetSlot = nil
    allowedEnchanterCraftIds = {}

    window:destroy()
    window = nil
  end
end

function onExtendedOpcode(protocol, code, buffer)
  local status, json_data =
    pcall(
    function()
      return json.decode(buffer)
    end
  )

  if not status then
    g_logger.error("[Crafting] JSON error: " .. data)
    return false
  end

  local action = json_data.action
  local data = json_data.data
  if action == "fetch" then
    for i = 1, #data.crafts do
      table.insert(Crafts[data.category], data.crafts[i])
    end
    if data.category == "weaponsmith" then
      selectCategory("weaponsmith")
    end
  elseif action == "materials" then
    for i = 1, #data.materials do
      local material = data.materials[i]
      local craft = Crafts[data.category][data.from + i - 1]
      if craft then
        if material.recipes and craft.recipes then
          for recipeIndex = 1, #material.recipes do
            local recipeCounts = material.recipes[recipeIndex]
            local recipe = craft.recipes[recipeIndex]
            if recipe and recipe.materials then
              for x = 1, #recipeCounts do
                local mats = recipe.materials[x]
                if mats then
                  mats.player = recipeCounts[x]
                end
              end
            end
          end
        else
          for x = 1, #material do
            local mats = craft.materials[x]
            if mats then
              mats.player = material[x]
            end
          end
        end
      end
    end
    if data.from == 1 and window:isVisible() and selectedCategory == data.category and selectedCraftId then
      selectItem(selectedCraftId)
    end
  elseif action == "money" then
    money = data
    craftPanel:recursiveGetChildById("playerMoney"):setText(comma_value(money))
  elseif action == "show" then
    if selectedCraftId then
      selectItem(selectedCraftId)
    end
    show()
  elseif action == "crafted" then
    onItemCrafted()
    if selectedCategory == "enchanter" and selectedEnchantTarget then
      requestEnchanterOptions()
    end
  elseif action == "close" then
    clearEnchantTargetSelection()
    hide()
  elseif action == "enchanter_options" then
    local ids = data and data.ids or {}
    setAllowedEnchanterCraftIds(ids)
    updateEnchantTargetSlots(data and data.emptySlots or {})
    if enchantTargetHint and selectedCategory == "enchanter" and selectedEnchantTarget then
      local optionsText = "options: " .. tostring(type(ids) == "table" and #ids or 0) .. " | slot: " .. tostring(selectedEnchantTargetSlot or "-")
      if data and data.debug and data.debug ~= "" then
        enchantTargetHint:setText(optionsText)
        g_logger.info("[EnchanterDebug] " .. data.debug)
        if modules.game_textmessage and modules.game_textmessage.displayStatusMessage then
          modules.game_textmessage.displayStatusMessage(data.debug)
        end
      else
        enchantTargetHint:setText(optionsText)
      end
    end
    if selectedCategory == "enchanter" then
      refreshItemsList()
    end
  end
end

function onItemCrafted()
  if selectedCategory and selectedCraftId then
    local craft = Crafts[selectedCategory][selectedCraftId]
    if craft then
      local recipe = getActiveRecipe(craft)
      local recipeMaterials = recipe.materials or {}
      for i = 1, math.min(6, #recipeMaterials) do
        local materialWidget = craftPanel:getChildById("craftLine" .. i)
        if materialWidget then
          materialWidget:setImageSource("/images/crafting/craft_line" .. i .. "on")
          scheduleEvent(
            function()
              materialWidget:setImageSource("/images/crafting/craft_line" .. (i == 2 and 5 or i))
            end,
            850
          )
        end
      end
      local button = craftPanel:getChildById("craftButton")
      button:disable()
      scheduleEvent(
        function()
          button:enable()
        end,
        860
      )
    end
  end
end

function onSearch()
  scheduleEvent(
    function()
      local searchInput = window:recursiveGetChildById("searchInput")
      local text = searchInput:getText():lower()
      if text:len() >= 1 then
        local children = itemsList:getChildCount()
        for i = children, 1, -1 do
          local child = itemsList:getChildByIndex(i)
          local name = child:getChildById("name"):getText():lower()
          if name:find(text) then
            child:show()
            child:focus()
            selectItem(tonumber(child:getId()))
          else
            child:hide()
          end
        end
      else
        local children = itemsList:getChildCount()
        for i = children, 1, -1 do
          local child = itemsList:getChildByIndex(i)
          child:show()
          child:focus()
          selectItem(tonumber(child:getId()))
        end
      end
    end,
    25
  )
end

local function getWeaponGroup(craft)
  if not craft then
    return "others"
  end

  local weaponType = tostring(craft.weaponType or ""):lower()
  if weaponType == "axe" then
    return "axe"
  elseif weaponType == "sword" then
    return "sword"
  elseif weaponType == "club" then
    return "club"
  elseif weaponType == "distance" then
    return "dist"
  end
  return "others"
end

local function updateWeaponCategoryButtons()
  if not weaponCategoryPanel then
    return
  end

  local map = {
    axe = "weaponAxeCat",
    sword = "weaponSwordCat",
    club = "weaponClubCat",
    dist = "weaponDistCat",
    others = "weaponOthersCat"
  }

  for key, widgetId in pairs(map) do
    local button = weaponCategoryPanel:getChildById(widgetId)
    if button then
      button:setOn(key == selectedWeaponCategory)
    end
  end
end

local function getArmorGroup(craft)
  if not craft then
    return "others"
  end

  local armorType = tostring(craft.armorType or ""):lower()
  if armorType == "helmet" then
    return "helmet"
  elseif armorType == "chest" or armorType == "armor" then
    return "chest"
  elseif armorType == "legs" then
    return "legs"
  elseif armorType == "boots" then
    return "boots"
  elseif armorType == "shield" then
    return "shield"
  end
  return "others"
end

local function updateArmorCategoryButtons()
  if not armorCategoryPanel then
    return
  end

  local map = {
    helmet = "armorHelmetCat",
    chest = "armorChestCat",
    legs = "armorLegsCat",
    boots = "armorBootsCat",
    shield = "armorShieldCat",
    others = "armorOthersCat"
  }

  for key, widgetId in pairs(map) do
    local button = armorCategoryPanel:getChildById(widgetId)
    if button then
      button:setOn(key == selectedArmorCategory)
    end
  end
end

local function getAlchemistGroup(craft)
  if not craft then
    return "rings"
  end

  local t = tostring(craft.alchemyType or ""):lower()
  if t == "rings" or t == "ammunition" then
    return t
  end

  local name = tostring(craft.name or ""):lower()
  if name:find("ring", 1, true) then
    return "rings"
  end
  return "ammunition"
end

local function updateAlchemistCategoryButtons()
  if not alchemistCategoryPanel then
    return
  end

  local map = {
    rings = "alchemistRingsCat",
    ammunition = "alchemistAmmunitionCat"
  }

  for key, widgetId in pairs(map) do
    local button = alchemistCategoryPanel:getChildById(widgetId)
    if button then
      button:setOn(key == selectedAlchemistCategory)
    end
  end
end

local function resetCraftDetails()
  selectedCraftId = nil
  for i = 1, 6 do
    local materialWidget = craftPanel:getChildById("material" .. i)
    materialWidget:setItem(nil)
    materialWidget:setTooltip("")
    craftPanel:getChildById("count" .. i):setText("")
  end

  craftPanel:getChildById("craftOutcome"):setItem(nil)
  craftPanel:getChildById("craftOutcome"):setTooltip("")
  local outcomeCount = craftPanel:getChildById("outcomeCount")
  if outcomeCount then
    outcomeCount:setText("")
  end
  craftPanel:recursiveGetChildById("totalCost"):setText("")
  updateRecipeControls(1, 1)
end

local function updateCategoryLayout()
  if not weaponCategoryPanel or not armorCategoryPanel or not alchemistCategoryPanel then
    return
  end

  local showWeapon = selectedCategory == "weaponsmith"
  local showArmor = selectedCategory == "armorsmith"
  local showAlchemist = selectedCategory == "alchemist"
  local showEnchanter = selectedCategory == "enchanter"
  local hasSubcategory = showWeapon or showArmor or showAlchemist

  weaponCategoryPanel:setVisible(showWeapon)
  armorCategoryPanel:setVisible(showArmor)
  alchemistCategoryPanel:setVisible(showAlchemist)

  if categorySeparator then
    categorySeparator:setMarginTop(hasSubcategory and 40 or 10)
  end

  if enchantTargetPanel then
    enchantTargetPanel:setVisible(showEnchanter)
    enchantTargetPanel:setHeight(showEnchanter and 76 or 0)
  end
  if enchantTargetWidget then
    enchantTargetWidget:setVisible(showEnchanter)
  end
  if enchantTargetLabel then
    enchantTargetLabel:setVisible(showEnchanter)
  end
  if enchantTargetHint then
    enchantTargetHint:setVisible(showEnchanter)
  end
  if enchantTargetSelectButton then
    enchantTargetSelectButton:setVisible(showEnchanter)
  end
  if enchantTargetSlotsPanel then
    enchantTargetSlotsPanel:setVisible(showEnchanter)
  end
end

function refreshItemsList()
  if not selectedCategory or not itemsList then
    return
  end

  itemsList:destroyChildren()
  resetCraftDetails()

  local sortedCrafts = {}
  local firstId = nil
  for i = 1, #Crafts[selectedCategory] do
    local craft = Crafts[selectedCategory][i]
    local visible = true
    if selectedCategory == "weaponsmith" then
      visible = getWeaponGroup(craft) == selectedWeaponCategory
    elseif selectedCategory == "armorsmith" then
      visible = getArmorGroup(craft) == selectedArmorCategory
    elseif selectedCategory == "alchemist" then
      visible = getAlchemistGroup(craft) == selectedAlchemistCategory
    elseif selectedCategory == "enchanter" then
      if not selectedEnchantTarget then
        visible = false
      else
        visible = allowedEnchanterCraftIds and allowedEnchanterCraftIds[i] == true
      end
    end

    if visible then
      table.insert(sortedCrafts, {id = i, craft = craft})
    end
  end

  table.sort(
    sortedCrafts,
    function(a, b)
      local levelA = tonumber(a.craft.level) or 0
      local levelB = tonumber(b.craft.level) or 0
      if levelA ~= levelB then
        return levelA < levelB
      end
      return tostring(a.craft.name or ""):lower() < tostring(b.craft.name or ""):lower()
    end
  )

  for i = 1, #sortedCrafts do
    local entry = sortedCrafts[i]
    local craft = entry.craft
    local w = g_ui.createWidget("ItemListItem")
    w:setId(entry.id)
    w:getChildById("item"):setItemId(craft.clientId)
    w:getChildById("name"):setText(craft.name)
    w:getChildById("level"):setText(craft.summary or "")
    local recipeNext = w:getChildById("recipeNext")
    if recipeNext then
      recipeNext:setVisible(false)
      recipeNext:setEnabled(false)
      recipeNext.onClick = nil

      local recipeCount = type(craft.recipes) == "table" and #craft.recipes or 0
      local hasVariants = recipeCount > 1
      if hasVariants then
        recipeNext:setVisible(true)
        recipeNext:setEnabled(true)
        recipeNext.onClick = function()
          cycleCraftRecipe(entry.id)
          return true
        end
      end
    end
    itemsList:addChild(w)

    if not firstId then
      firstId = entry.id
      w:focus()
    end
  end

  if firstId then
    selectItem(firstId)
  end
end

function selectEnchantTargetUseWith()
  if selectedCategory ~= "enchanter" then
    return
  end

  if not modules.game_interface or not modules.game_interface.startUseWith then
    modules.game_textmessage.displayFailureMessage("Use-with selector is unavailable.")
    return
  end

  clearEnchantTargetSelection()
  if enchantTargetHint then
    enchantTargetHint:setText("click item in backpack")
  end

  local selectorItem = Item.create(3031, 1)
  modules.game_interface.startUseWith(selectorItem, 0, function(clickedWidget, mousePos, targetThing)
    if clickedWidget and clickedWidget.getClassName and clickedWidget:getClassName() == "UIItem" and clickedWidget.isVirtual and clickedWidget:isVirtual() then
      modules.game_textmessage.displayFailureMessage("Select real item from backpack/container.")
      return
    end

    if not targetThing or not targetThing:isItem() then
      modules.game_textmessage.displayFailureMessage("Select item from backpack/container.")
      return
    end
    applyEnchantTargetThing(targetThing)
  end)
end

function selectWeaponCategory(category)
  selectedWeaponCategory = category or "axe"
  updateWeaponCategoryButtons()
  if selectedCategory == "weaponsmith" then
    refreshItemsList()
  end
end

function selectArmorCategory(category)
  selectedArmorCategory = category or "helmet"
  updateArmorCategoryButtons()
  if selectedCategory == "armorsmith" then
    refreshItemsList()
  end
end

function selectAlchemistCategory(category)
  selectedAlchemistCategory = category or "rings"
  updateAlchemistCategoryButtons()
  if selectedCategory == "alchemist" then
    refreshItemsList()
  end
end

function selectCategory(category)
  if selectedCategory then
    local oldCatBtn = categories:getChildById(selectedCategory .. "Cat")
    if oldCatBtn then
      oldCatBtn:setOn(false)
    end
  end

  local newCatBtn = categories:getChildById(category .. "Cat")
  if newCatBtn then
    newCatBtn:setOn(true)
    selectedCategory = category

    if weaponCategoryPanel then
      weaponCategoryPanel:setVisible(selectedCategory == "weaponsmith")
    end
    if armorCategoryPanel then
      armorCategoryPanel:setVisible(selectedCategory == "armorsmith")
    end
    if alchemistCategoryPanel then
      alchemistCategoryPanel:setVisible(selectedCategory == "alchemist")
    end
    updateCategoryLayout()
    updateWeaponCategoryButtons()
    updateArmorCategoryButtons()
    updateAlchemistCategoryButtons()
    refreshItemsList()
    if selectedCategory == "enchanter" then
      requestEnchanterOptions()
    end
  end
end

function selectItem(id)
  local craftId = tonumber(id)
  if not craftId then
    return
  end
  selectedCraftId = craftId

  local craft = Crafts[selectedCategory][craftId]
  if not craft then
    return
  end

  local recipe, recipeIndex, recipeCount = getActiveRecipe(craft)
  if not recipe then
    return
  end

  for i = 1, 6 do
    local materialWidget = craftPanel:getChildById("material" .. i)
    materialWidget:setItem(nil)
    materialWidget:setTooltip("")
    craftPanel:getChildById("count" .. i):setText("")
  end

  local recipeMaterials = recipe.materials or {}
  for i = 1, math.min(6, #recipeMaterials) do
    local material = recipeMaterials[i]
    local materialWidget = craftPanel:getChildById("material" .. i)
    if materialWidget then
      materialWidget:setItemId(material.id)
      materialWidget:setTooltip(getMaterialTooltip(material))
      local count = craftPanel:getChildById("count" .. i)
      count:setText(material.player .. "\n" .. material.count)
      if material.player >= material.count then
        count:setColor("#FFFFFF")
      else
        count:setColor("#FF0000")
      end
    end
  end

  local outcome = craftPanel:getChildById("craftOutcome")
  local resultCount = tonumber(recipe.count) or tonumber(craft.count) or 1
  if selectedCategory == "enchanter" and selectedEnchantTarget and selectedEnchantTarget.id then
    local targetSubType = tonumber(selectedEnchantTarget.subType) or 1
    outcome:setItem(Item.create(tonumber(selectedEnchantTarget.id), targetSubType))
    local slotText = selectedEnchantTargetSlot and ("Slot: " .. tostring(selectedEnchantTargetSlot) .. "\n") or ""
    outcome:setTooltip(slotText .. "Enchant: " .. tostring(craft.name or ""))
  else
    outcome:setItemId(craft.clientId)
    outcome:setItemCount(resultCount)
    outcome:setTooltip(craft.tooltip or "")
  end
  local outcomeCount = craftPanel:getChildById("outcomeCount")
  if outcomeCount then
    if selectedCategory == "enchanter" then
      outcomeCount:setText("")
    elseif resultCount > 1 then
      outcomeCount:setText("x" .. resultCount)
    else
      outcomeCount:setText("")
    end
  end
  craftPanel:recursiveGetChildById("totalCost"):setText(comma_value(recipe.cost or craft.cost or 0))
  updateRecipeControls(recipeIndex, recipeCount)
end

function craftItem()
  if selectedCategory and selectedCraftId then
    local protocolGame = g_game.getProtocolGame()
    if protocolGame then
      local craft = Crafts[selectedCategory][selectedCraftId]
      local _, recipeIndex = getActiveRecipe(craft)
      local payload = {category = selectedCategory, craftId = selectedCraftId, recipeId = recipeIndex}
      if selectedCategory == "enchanter" then
        if not selectedEnchantTarget then
          modules.game_textmessage.displayFailureMessage("Select target item first.")
          return
        end
        if not selectedEnchantTargetSlot then
          modules.game_textmessage.displayFailureMessage("Select empty slot first.")
          return
        end
        payload.target = selectedEnchantTarget
        payload.targetSlot = selectedEnchantTargetSlot
      end
      protocolGame:sendExtendedOpcode(CODE, json.encode({action = "craft", data = payload}))
    end
  end
end

function nextRecipe()
  if not selectedCategory or not selectedCraftId then
    return
  end

  local craft = Crafts[selectedCategory][selectedCraftId]
  if not craft or not craft.recipes or #craft.recipes <= 1 then
    return
  end

  local current = clampRecipeIndex(craft, craft.selectedRecipe)
  craft.selectedRecipe = current + 1
  if craft.selectedRecipe > #craft.recipes then
    craft.selectedRecipe = 1
  end
  selectItem(selectedCraftId)
end

function prevRecipe()
  if not selectedCategory or not selectedCraftId then
    return
  end

  local craft = Crafts[selectedCategory][selectedCraftId]
  if not craft or not craft.recipes or #craft.recipes <= 1 then
    return
  end

  local current = clampRecipeIndex(craft, craft.selectedRecipe)
  craft.selectedRecipe = current - 1
  if craft.selectedRecipe < 1 then
    craft.selectedRecipe = #craft.recipes
  end
  selectItem(selectedCraftId)
end

function show()
  if not window then
    return
  end
  window:show()
  window:raise()
  window:focus()
end

function hide()
  if not window then
    return
  end
  window:hide()
end

function comma_value(amount)
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1.%2")
    if (k == 0) then
      break
    end
  end
  return formatted
end
