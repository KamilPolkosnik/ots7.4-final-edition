local CODE = 108

local window = nil
local categories = nil
local craftPanel = nil
local itemsList = nil
local weaponCategoryPanel = nil
local weaponHandPanel = nil
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
local selectedWeaponHandFilter = "all"
local selectedArmorCategory = "helmet"
local selectedAlchemistCategory = "rings"
local Crafts = {weaponsmith = {}, armorsmith = {}, alchemist = {}, enchanter = {}, jeweller = {}, extractor = {}}
local money = 0
local selectedEnchantTarget = nil
local selectedEnchantTargetSlot = nil
local selectedExtractorTarget = nil
local allowedEnchanterCraftIds = {}
local getCraftWidget = nil
local craftPreviewAnimationEvents = {}
local extractorCraftIds = {
  [7882] = true,
  [7883] = true
}
local EXTRACTOR_TOOL_ITEM_ID = 7882
local EXTRACTOR_TARGET_ITEM_ID = 7883
local CRAFT_PREVIEW_BASE_BORDER_COLOR = "#4e5968"
local CRAFT_PREVIEW_PULSE_STEPS = {
  {delay = 0, opacity = 0.88, marginTop = 4, borderColor = "#9c7640", active = true},
  {delay = 70, opacity = 1.00, marginTop = 1, borderColor = "#f0ce86", active = true},
  {delay = 155, opacity = 0.84, marginTop = 3, borderColor = "#c89246", active = true},
  {delay = 270, opacity = 1.00, marginTop = 4, borderColor = CRAFT_PREVIEW_BASE_BORDER_COLOR, active = false}
}

local function isExtractorCraft(craft)
  if not craft then
    return false
  end

  local craftId = tonumber(craft.id or craft.serverId or craft.itemId)
  if craftId and extractorCraftIds[craftId] then
    return true
  end

  local name = tostring(craft.name or ""):lower()
  return name:find("extractor", 1, true) ~= nil or name:find("fossil", 1, true) ~= nil
end

local function rebuildExtractorCrafts()
  Crafts.extractor = {}

  for i = 1, #(Crafts.jeweller or {}) do
    local craft = Crafts.jeweller[i]
    if tonumber(craft.id) == EXTRACTOR_TOOL_ITEM_ID then
      local copy = {}
      for key, value in pairs(craft) do
        copy[key] = value
      end
      copy.sourceCategory = "jeweller"
      copy.sourceCraftId = i
      copy.serviceType = "extractor"
      copy.cost = 0
      copy.materials = {}
      copy.summary = "Use on crystal fossil"
      copy.tooltip = "Select crystal fossil from backpack and extract crystals."
      table.insert(Crafts.extractor, copy)
    end
  end
end

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

local function getEnchantPreviewText(craft)
  if selectedCategory ~= "enchanter" or not craft or not selectedEnchantTarget then
    return ""
  end

  local effectName = tostring(craft.name or "")
  local slotText = selectedEnchantTargetSlot and ("Slot " .. tostring(selectedEnchantTargetSlot)) or ""
  if effectName ~= "" then
    if slotText ~= "" then
      return effectName .. "\n" .. slotText
    end
    return effectName
  end

  local summary = tostring(craft.summary or "")
  if summary ~= "" and slotText ~= "" then
    return summary .. "\n" .. slotText
  end

  return summary ~= "" and summary or slotText
end

local function getEnchantPreviewTooltip(craft)
  if not craft then
    return ""
  end

  local tooltip = tostring(craft.tooltip or "")
  local summary = tostring(craft.summary or "")
  if summary ~= "" and not tooltip:find(summary, 1, true) then
    if tooltip ~= "" then
      tooltip = tooltip .. "\n" .. summary
    else
      tooltip = summary
    end
  end
  return tooltip
end

local function isExtractorServiceCraft(craft)
  return craft and tostring(craft.serviceType or "") == "extractor"
end

local function getCurrentTargetThing()
  if selectedCategory == "enchanter" then
    return selectedEnchantTarget
  elseif selectedCategory == "extractor" then
    return selectedExtractorTarget
  end
  return nil
end

local function getExtractorPreviewText(craft)
  if selectedCategory ~= "extractor" or not craft or not selectedExtractorTarget then
    return ""
  end

  local label = tostring(craft.name or "Crystal Extractor")
  if label ~= "" then
    return label
  end

  return "Crystal Extraction"
end

local function getExtractorPreviewTooltip(craft)
  if not craft then
    return ""
  end

  local tooltip = tostring(craft.tooltip or "")
  if tooltip == "" then
    tooltip = "Select crystal fossil from backpack and extract crystals."
  end
  return tooltip
end

local function updateCraftActionButton()
  local button = getCraftWidget("craftButton")
  if not button then
    return
  end

  local text = "Craft"
  if selectedCategory and selectedCraftId then
    local craft = Crafts[selectedCategory] and Crafts[selectedCategory][selectedCraftId]
    if selectedCategory == "extractor" and isExtractorServiceCraft(craft) then
      text = "Extract"
    end
  end
  button:setText(text)
end

local function updateCraftPreview(craft, recipe)
  local outcome = getCraftWidget("craftOutcome")
  local outcomeCount = getCraftWidget("outcomeCount")
  if not outcome or not craft then
    return
  end

  local resultCount = tonumber(recipe and recipe.count) or tonumber(craft.count) or 1
  local isEnchantPreview = selectedCategory == "enchanter" and selectedEnchantTarget ~= nil
  local isExtractorPreview = selectedCategory == "extractor" and selectedExtractorTarget ~= nil and isExtractorServiceCraft(craft)

  if isEnchantPreview then
    local targetItemId = tonumber(selectedEnchantTarget.id) or 0
    local targetSubType = tonumber(selectedEnchantTarget.subType) or 1
    if targetItemId > 0 then
      outcome:setItem(Item.create(targetItemId, targetSubType))
    else
      outcome:setItemId(craft.clientId)
    end
    outcome:setTooltip(getEnchantPreviewTooltip(craft))

    if outcomeCount then
      outcomeCount:setText(getEnchantPreviewText(craft))
    end
    return
  end

  if isExtractorPreview then
    local targetItemId = tonumber(selectedExtractorTarget.id) or 0
    local targetSubType = tonumber(selectedExtractorTarget.subType) or 1
    if targetItemId > 0 then
      outcome:setItem(Item.create(targetItemId, targetSubType))
    else
      outcome:setItemId(craft.clientId)
    end
    outcome:setTooltip(getExtractorPreviewTooltip(craft))

    if outcomeCount then
      outcomeCount:setText(getExtractorPreviewText(craft))
    end
    return
  end

  outcome:setItemId(craft.clientId)
  outcome:setTooltip(craft.tooltip or "")

  if outcomeCount then
    if resultCount > 1 then
      outcomeCount:setText("x" .. resultCount)
    else
      outcomeCount:setText("")
    end
  end
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

  local recipeLabel = getCraftWidget("recipeLabel")
  local recipePrev = getCraftWidget("recipePrev")
  local recipeNext = getCraftWidget("recipeNext")
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

getCraftWidget = function(id)
  if not window then
    return nil
  end
  return window:recursiveGetChildById(id)
end

local function resetCraftPreviewAnimationState()
  local outcome = getCraftWidget("craftOutcome")
  if outcome then
    outcome:setOpacity(1.0)
    outcome:setMarginTop(4)
    if outcome.setOn then
      outcome:setOn(false)
    end
    if outcome.setBorderColor then
      outcome:setBorderColor("#00000000")
    end
  end

  local previewPanel = getCraftWidget("previewPanel")
  if previewPanel and previewPanel.setBorderColor then
    previewPanel:setBorderColor(CRAFT_PREVIEW_BASE_BORDER_COLOR)
  end
end

local function stopCraftPreviewAnimation()
  for i = 1, #craftPreviewAnimationEvents do
    removeEvent(craftPreviewAnimationEvents[i])
  end
  craftPreviewAnimationEvents = {}
  resetCraftPreviewAnimationState()
end

local function playCraftPreviewAnimation()
  local outcome = getCraftWidget("craftOutcome")
  local previewPanel = getCraftWidget("previewPanel")
  if not outcome or not previewPanel then
    return
  end

  stopCraftPreviewAnimation()

  for i = 1, #CRAFT_PREVIEW_PULSE_STEPS do
    local step = CRAFT_PREVIEW_PULSE_STEPS[i]
    local isLastStep = i == #CRAFT_PREVIEW_PULSE_STEPS
    craftPreviewAnimationEvents[#craftPreviewAnimationEvents + 1] =
      scheduleEvent(
      function()
        local currentOutcome = getCraftWidget("craftOutcome")
        local currentPreviewPanel = getCraftWidget("previewPanel")
        if not currentOutcome or not currentPreviewPanel then
          craftPreviewAnimationEvents = {}
          return
        end

        currentOutcome:setOpacity(step.opacity)
        currentOutcome:setMarginTop(step.marginTop)
        if currentOutcome.setOn then
          currentOutcome:setOn(step.active)
        end
        if currentOutcome.setBorderColor then
          currentOutcome:setBorderColor(step.active and step.borderColor or "#00000000")
        end
        if currentPreviewPanel.setBorderColor then
          currentPreviewPanel:setBorderColor(step.borderColor)
        end

        if isLastStep then
          craftPreviewAnimationEvents = {}
          resetCraftPreviewAnimationState()
        end
      end,
      step.delay
    )
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
      local text = "Slot " .. tostring(button.slotValue)
      button:setText(text)
      button:setOn(tonumber(selectedEnchantTargetSlot) == tonumber(button.slotValue))
    end
  end
end

local function refreshTargetPanelAppearance()
  local craft = selectedCategory and selectedCraftId and Crafts[selectedCategory] and Crafts[selectedCategory][selectedCraftId] or nil
  local showEnchanter = selectedCategory == "enchanter"
  local showExtractor = selectedCategory == "extractor" and isExtractorServiceCraft(craft)
  local showTargetPanel = showEnchanter or showExtractor

  if enchantTargetPanel then
    enchantTargetPanel:setVisible(showTargetPanel)
    if showEnchanter then
      enchantTargetPanel:setHeight(120)
    elseif showExtractor then
      enchantTargetPanel:setHeight(78)
    else
      enchantTargetPanel:setHeight(0)
    end
  end

  if enchantTargetLabel then
    if showEnchanter then
      enchantTargetLabel:setText("Enchant Target")
    elseif showExtractor then
      enchantTargetLabel:setText("Extractor Target")
    end
    enchantTargetLabel:setVisible(showTargetPanel)
  end

  if enchantTargetWidget then
    enchantTargetWidget:setVisible(showTargetPanel)
  end

  if enchantTargetSelectButton then
    enchantTargetSelectButton:setVisible(showTargetPanel)
  end

  if enchantTargetSlotsPanel then
    enchantTargetSlotsPanel:setVisible(showEnchanter)
  end

  if enchantTargetHint then
    enchantTargetHint:setVisible(showTargetPanel)
  end
end

local function refreshEnchantTargetHint(slotCount)
  if not enchantTargetHint then
    return
  end

  if not selectedEnchantTarget then
    enchantTargetHint:setText("")
    return
  end

  slotCount = tonumber(slotCount) or 0
  if slotCount <= 0 then
    enchantTargetHint:setText("No empty enchant slots on selected item")
  elseif slotCount == 1 then
    enchantTargetHint:setText("Using slot " .. tostring(selectedEnchantTargetSlot or 1))
  else
    enchantTargetHint:setText("")
  end
end

local function refreshExtractorTargetHint()
  if not enchantTargetHint then
    return
  end

  if not selectedExtractorTarget then
    enchantTargetHint:setText("")
    return
  end

  enchantTargetHint:setText("")
end

local function updateCostColors(totalCost)
  if not craftPanel then
    return
  end

  local totalCostLabel = getCraftWidget("totalCost")
  local playerMoneyLabel = getCraftWidget("playerMoney")
  local required = tonumber(totalCost) or 0
  local hasEnough = money >= required

  if totalCostLabel then
    totalCostLabel:setColor(hasEnough and "#f3d598" or "#e48f8f")
  end

  if playerMoneyLabel then
    playerMoneyLabel:setColor(hasEnough and "#e8f2fb" or "#f0c7c7")
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
  local slotCount = #normalized

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
          refreshEnchantTargetHint(slotCount)
          if selectedCategory == "enchanter" and selectedCraftId then
            selectItem(selectedCraftId)
          end
          return true
        end
      else
        button.slotValue = nil
        button:setOn(false)
        button:setVisible(false)
        button.onClick = nil
      end
    end
  end

  refreshEnchantTargetSlotButtons()
  refreshEnchantTargetHint(slotCount)
end

local function clearExtractorTargetSelection(skipRefresh)
  selectedExtractorTarget = nil
  if selectedCategory == "extractor" then
    if enchantTargetWidget then
      enchantTargetWidget:setItem(nil)
      enchantTargetWidget:setTooltip("")
    end
    refreshExtractorTargetHint()
    if not skipRefresh and selectedCraftId then
      selectItem(selectedCraftId)
    end
  end
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
    enchantTargetHint:setText("")
  end
  if selectedCategory == "enchanter" then
    refreshItemsList()
  end
end

local function applyExtractorTargetThing(targetThing)
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

  local itemId = targetThing:getId()
  if itemId ~= EXTRACTOR_TARGET_ITEM_ID then
    modules.game_textmessage.displayFailureMessage("Select crystal fossil.")
    return false
  end

  local stackPos = targetThing.getStackPos and targetThing:getStackPos() or 0
  local subType = targetThing.getCountOrSubType and targetThing:getCountOrSubType() or 1
  selectedExtractorTarget = {
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

  refreshExtractorTargetHint()
  if selectedCategory == "extractor" and selectedCraftId then
    selectItem(selectedCraftId)
  end
  return true
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

  selectedEnchantTargetSlot = nil
  updateEnchantTargetSlots({})
  if enchantTargetHint then
    enchantTargetHint:setText("Loading empty slots...")
  end
  if selectedCategory == "enchanter" and selectedCraftId then
    selectItem(selectedCraftId)
  end
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
  weaponHandPanel = window:getChildById("weaponHandPanel")
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
      if selectedCategory == "extractor" then
        return applyExtractorTargetThing(draggedItem)
      end
      return applyEnchantTargetThing(draggedItem)
    end

    enchantTargetWidget.onMouseRelease = function(self, mousePos, mouseButton)
      if mouseButton == MouseRightButton then
        if selectedCategory == "extractor" then
          clearExtractorTargetSelection(true)
          if enchantTargetWidget then
            enchantTargetWidget:setItem(nil)
            enchantTargetWidget:setTooltip("")
          end
          if selectedCraftId then
            selectItem(selectedCraftId)
          end
        else
          clearEnchantTargetSelection()
        end
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
    stopCraftPreviewAnimation()
    categories = nil
    craftPanel = nil
    itemsList = nil
    weaponCategoryPanel = nil
    weaponHandPanel = nil
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
    selectedWeaponHandFilter = "all"
    selectedArmorCategory = "helmet"
    selectedAlchemistCategory = "rings"
    Crafts = {weaponsmith = {}, armorsmith = {}, alchemist = {}, enchanter = {}, jeweller = {}, extractor = {}}
    selectedEnchantTarget = nil
    selectedEnchantTargetSlot = nil
    selectedExtractorTarget = nil
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
    if data.category == "jeweller" then
      rebuildExtractorCrafts()
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
    if data.category == "jeweller" then
      rebuildExtractorCrafts()
    end
    if data.from == 1 and window:isVisible() and selectedCategory == data.category and selectedCraftId then
      selectItem(selectedCraftId)
    elseif data.category == "jeweller" and window:isVisible() and selectedCategory == "extractor" then
      refreshItemsList()
    end
  elseif action == "money" then
    money = data
    local playerMoneyLabel = getCraftWidget("playerMoney")
    if playerMoneyLabel then
      playerMoneyLabel:setText(comma_value(money))
    end
    if selectedCategory and selectedCraftId then
      selectItem(selectedCraftId)
    else
      updateCostColors(0)
    end
  elseif action == "show" then
    if selectedCraftId then
      selectItem(selectedCraftId)
    end
    show()
  elseif action == "crafted" then
    onItemCrafted()
    if selectedCategory == "enchanter" and selectedEnchantTarget then
      requestEnchanterOptions()
    elseif selectedCategory == "extractor" and selectedCraftId then
      selectItem(selectedCraftId)
    end
  elseif action == "close" then
    clearEnchantTargetSelection()
    clearExtractorTargetSelection(true)
    hide()
  elseif action == "enchanter_options" then
    local ids = data and data.ids or {}
    setAllowedEnchanterCraftIds(ids)
    updateEnchantTargetSlots(data and data.emptySlots or {})
    if data and data.debug and data.debug ~= "" then
      g_logger.info("[EnchanterDebug] " .. data.debug)
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
      local button = getCraftWidget("craftButton")
      if not button then
        return
      end
      button:disable()
      scheduleEvent(
        function()
          button:enable()
          updateCraftActionButton()
        end,
        860
      )
    end
  end
end

function selectCurrentTargetUseWith()
  if selectedCategory == "extractor" then
    selectExtractorTargetUseWith()
  else
    selectEnchantTargetUseWith()
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

local function isTwoHandedCraft(craft)
  if not craft then
    return false
  end

  local twoHanded = craft.twoHanded
  if twoHanded == true or twoHanded == 1 then
    return true
  end

  if type(twoHanded) == "string" then
    local v = twoHanded:lower()
    return v == "true" or v == "1" or v == "yes"
  end

  return false
end

local function getCraftAttackValue(craft)
  if not craft then
    return 0
  end

  local direct = tonumber(craft.attack)
  if direct then
    return direct
  end

  local summary = tostring(craft.summary or "")
  local fromSummary = tonumber(summary:match("Atk%s+([%-]?%d+)"))
  if fromSummary then
    return fromSummary
  end

  return 0
end

local function getCraftDefenseValue(craft)
  if not craft then
    return 0
  end

  local defense = tonumber(craft.defense)
  local extraDefense = tonumber(craft.extraDefense) or 0
  if defense then
    return defense + extraDefense
  end

  local summary = tostring(craft.summary or "")
  local fromSummary = tonumber(summary:match("Def%s+([%-]?%d+)")) or 0
  local fromExtra = tonumber(summary:match("Def%+%s*([%-]?%d+)")) or 0
  return fromSummary + fromExtra
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

local function updateWeaponHandButtons()
  if not weaponHandPanel then
    return
  end

  local map = {
    all = "weaponHandAll",
    one = "weaponHandOne",
    two = "weaponHandTwo"
  }

  for key, widgetId in pairs(map) do
    local button = weaponHandPanel:getChildById(widgetId)
    if button then
      button:setOn(key == selectedWeaponHandFilter)
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
    return "armor"
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
    armor = "armorChestCat",
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
  stopCraftPreviewAnimation()
  selectedCraftId = nil
  local materialsList = getCraftWidget("materialsList")
  if materialsList then
    materialsList:destroyChildren()
  end

  local outcomeWidget = getCraftWidget("craftOutcome")
  if outcomeWidget then
    outcomeWidget:setItem(nil)
    outcomeWidget:setTooltip("")
  end
  local outcomeCount = getCraftWidget("outcomeCount")
  if outcomeCount then
    outcomeCount:setText("")
  end
  local totalCostLabel = getCraftWidget("totalCost")
  if totalCostLabel then
    totalCostLabel:setText("")
  end
  updateCostColors(0)
  updateRecipeControls(1, 1)
  updateCraftActionButton()
  refreshTargetPanelAppearance()
end

local function rebuildMaterialsList(recipeMaterials)
  local materialsList = getCraftWidget("materialsList")
  if not materialsList then
    return
  end

  materialsList:destroyChildren()

  for i = 1, #(recipeMaterials or {}) do
    local material = recipeMaterials[i]
    local row = g_ui.createWidget("MaterialListRow", materialsList)
    row:setId("materialRow" .. i)

    local itemWidget = row:getChildById("item")
    if itemWidget then
      itemWidget:setItemId(material.id)
      itemWidget:setTooltip(getMaterialTooltip(material))
    end

    local nameWidget = row:getChildById("name")
    if nameWidget then
      nameWidget:setText(tostring(material.name or ("Item " .. tostring(material.id))))
    end

    local countWidget = row:getChildById("count")
    if countWidget then
      countWidget:setText(string.format("%d / %d", tonumber(material.player) or 0, tonumber(material.count) or 0))
      if (tonumber(material.player) or 0) >= (tonumber(material.count) or 0) then
        countWidget:setColor("#dfe8f2")
      else
        countWidget:setColor("#e48f8f")
      end
    end
  end
end

local function updateCategoryLayout()
  if not weaponCategoryPanel or not weaponHandPanel or not armorCategoryPanel or not alchemistCategoryPanel then
    return
  end

  local showWeapon = selectedCategory == "weaponsmith"
  local showArmor = selectedCategory == "armorsmith"
  local showAlchemist = selectedCategory == "alchemist"
  local hasSubcategory = showWeapon or showArmor or showAlchemist

  weaponCategoryPanel:setVisible(showWeapon)
  weaponHandPanel:setVisible(false)
  armorCategoryPanel:setVisible(showArmor)
  alchemistCategoryPanel:setVisible(showAlchemist)

  if categorySeparator then
    if showWeapon then
      categorySeparator:setMarginTop(60)
    else
      categorySeparator:setMarginTop(hasSubcategory and 60 or 12)
    end
  end

  refreshTargetPanelAppearance()
  updateCraftActionButton()
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
      if visible and selectedWeaponHandFilter == "one" then
        visible = not isTwoHandedCraft(craft)
      elseif visible and selectedWeaponHandFilter == "two" then
        visible = isTwoHandedCraft(craft)
      end
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
      if selectedCategory == "weaponsmith" then
        local attackA = getCraftAttackValue(a.craft)
        local attackB = getCraftAttackValue(b.craft)
        if attackA ~= attackB then
          return attackA < attackB
        end
      elseif selectedCategory == "armorsmith" and selectedArmorCategory == "shield" then
        local defenseA = getCraftDefenseValue(a.craft)
        local defenseB = getCraftDefenseValue(b.craft)
        if defenseA ~= defenseB then
          return defenseA < defenseB
        end
      end

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
    enchantTargetHint:setText("Click item in backpack")
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

function selectExtractorTargetUseWith()
  if selectedCategory ~= "extractor" then
    return
  end

  if not modules.game_interface or not modules.game_interface.startUseWith then
    modules.game_textmessage.displayFailureMessage("Use-with selector is unavailable.")
    return
  end

  clearExtractorTargetSelection(true)
  if enchantTargetHint then
    enchantTargetHint:setText("Click crystal fossil in backpack")
  end

  local selectorItem = Item.create(EXTRACTOR_TOOL_ITEM_ID, 1)
  modules.game_interface.startUseWith(selectorItem, 0, function(clickedWidget, mousePos, targetThing)
    if clickedWidget and clickedWidget.getClassName and clickedWidget:getClassName() == "UIItem" and clickedWidget.isVirtual and clickedWidget:isVirtual() then
      modules.game_textmessage.displayFailureMessage("Select real item from backpack/container.")
      return
    end

    if not targetThing or not targetThing:isItem() then
      modules.game_textmessage.displayFailureMessage("Select item from backpack/container.")
      return
    end
    applyExtractorTargetThing(targetThing)
  end)
end

function selectWeaponCategory(category)
  selectedWeaponCategory = category or "axe"
  updateWeaponCategoryButtons()
  if selectedCategory == "weaponsmith" then
    refreshItemsList()
  end
end

function selectWeaponHandFilter(filter)
  local value = tostring(filter or "all"):lower()
  if value ~= "one" and value ~= "two" then
    value = "all"
  end

  selectedWeaponHandFilter = value
  updateWeaponHandButtons()
  if selectedCategory == "weaponsmith" then
    refreshItemsList()
  end
end

function selectArmorCategory(category)
  local value = tostring(category or "helmet"):lower()
  if value == "chest" then
    value = "armor"
  end

  selectedArmorCategory = value
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
    if weaponHandPanel then
      weaponHandPanel:setVisible(false)
    end
    if armorCategoryPanel then
      armorCategoryPanel:setVisible(selectedCategory == "armorsmith")
    end
    if alchemistCategoryPanel then
      alchemistCategoryPanel:setVisible(selectedCategory == "alchemist")
    end
    updateCategoryLayout()
    updateWeaponCategoryButtons()
    updateWeaponHandButtons()
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
  stopCraftPreviewAnimation()
  selectedCraftId = craftId

  local craft = Crafts[selectedCategory][craftId]
  if not craft then
    return
  end

  local recipe, recipeIndex, recipeCount = getActiveRecipe(craft)
  if not recipe then
    return
  end

  refreshTargetPanelAppearance()
  local recipeMaterials = recipe.materials or {}
  rebuildMaterialsList(recipeMaterials)

  local outcome = getCraftWidget("craftOutcome")
  local resultCount = tonumber(recipe.count) or tonumber(craft.count) or 1
  if outcome and outcome.setItemCount then
    outcome:setItemCount(resultCount)
  end
  updateCraftPreview(craft, recipe)
  local totalCost = recipe.cost or craft.cost or 0
  local totalCostLabel = getCraftWidget("totalCost")
  if totalCostLabel then
    totalCostLabel:setText(comma_value(totalCost))
  end
  updateCostColors(totalCost)
  updateRecipeControls(recipeIndex, recipeCount)
  updateCraftActionButton()
end

function focusSearch()
  if not window then
    return
  end

  local searchInput = window:recursiveGetChildById("searchInput")
  if searchInput then
    searchInput:focus()
  end
end

function craftItem()
  if selectedCategory and selectedCraftId then
    local protocolGame = g_game.getProtocolGame()
    if protocolGame then
      local craft = Crafts[selectedCategory][selectedCraftId]
      if not craft then
        return
      end
      local _, recipeIndex = getActiveRecipe(craft)
      local payload = {
        category = craft.sourceCategory or selectedCategory,
        craftId = craft.sourceCraftId or selectedCraftId,
        recipeId = recipeIndex,
        uiCategory = selectedCategory
      }
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
      elseif selectedCategory == "extractor" and isExtractorServiceCraft(craft) then
        if not selectedExtractorTarget then
          modules.game_textmessage.displayFailureMessage("Select crystal fossil first.")
          return
        end
        payload.target = selectedExtractorTarget
      end
      protocolGame:sendExtendedOpcode(CODE, json.encode({action = "craft", data = payload}))
      playCraftPreviewAnimation()
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
  stopCraftPreviewAnimation()
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
