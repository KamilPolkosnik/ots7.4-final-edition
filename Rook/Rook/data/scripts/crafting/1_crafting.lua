Crafting = {}

local CODE_CRAFTING = 108
local fetchLimit = 10

local categories = {"weaponsmith", "armorsmith", "alchemist", "enchanter", "jeweller"}

local function parseTargetItem(player, targetData)
  if type(targetData) ~= "table" then
    return nil
  end

  local x = tonumber(targetData.x)
  local y = tonumber(targetData.y)
  local z = tonumber(targetData.z)
  local stackpos = tonumber(targetData.stackpos) or 0

  if not x or not y or not z then
    return nil
  end

  local pos = Position(x, y, z, stackpos)
  local item = player:getItem(pos)
  if item then
    return item
  end

  -- Some clients may send stackpos=0 for container items, so try without stack index.
  if stackpos == 0 then
    item = player:getItem(Position(x, y, z))
    if item then
      return item
    end
  end

  -- Fallback: if client position changed while the panel was open, find by id in containers.
  local fallbackId = tonumber(targetData.id) or 0
  if fallbackId > 0 then
    item = player:getItemById(fallbackId, true)
    if item then
      return item
    end

    local fallbackSubType = tonumber(targetData.subType)
    if fallbackSubType and fallbackSubType >= 0 then
      return player:getItemById(fallbackId, true, fallbackSubType)
    end
  end

  return nil
end

local function getEmptyAttributeSlots(target)
  local slots = {}
  if not target then
    return slots
  end
  local maxSlots = target:getMaxAttributes() or 0
  for i = 1, maxSlots do
    if not target:getBonusAttribute(i) then
      slots[#slots + 1] = i
    end
  end
  return slots
end

local function canApplyEnchanterCraft(target, craft, player, selectedSlot)
  if not target or not craft or not craft.enchantId then
    return false, nil, "invalid_target_or_craft"
  end

  local targetPosition = target:getPosition()
  if targetPosition and targetPosition.x == CONTAINER_POSITION and targetPosition.y <= CONST_SLOT_AMMO then
    return false, nil, "equipped_slot"
  end
  if targetPosition and targetPosition.x ~= CONTAINER_POSITION and player then
    local dist = getDistanceBetween(player:getPosition(), targetPosition)
    if dist > 1 then
      return false, nil, "too_far_from_target"
    end
  end

  local itemType = target:getType()
  if not itemType or not itemType:isUpgradable() then
    return false, nil, "not_upgradable"
  end

  if target:isUnidentified() or target:isMirrored() or target:isUnique() then
    return false, nil, "state_blocked"
  end

  local attr = US_ENCHANTMENTS[craft.enchantId]
  if not attr then
    return false, nil, "missing_enchant"
  end

  local itemLevel = target:getItemLevel()
  if attr.minLevel and itemLevel < attr.minLevel then
    return false, attr, "min_level"
  end

  local usItemType = target:getItemType()
  if not usItemType or bit.band(usItemType, attr.itemType) == 0 then
    return false, attr, "item_type_mask"
  end

  local maxSlots = target:getMaxAttributes() or 0
  local emptyCount = 0
  for i = 1, maxSlots do
    local bonus = target:getBonusAttribute(i)
    if bonus then
      if bonus[1] == craft.enchantId then
        return false, attr, "duplicate_enchant"
      end
    else
      emptyCount = emptyCount + 1
    end
  end

  if emptyCount <= 0 then
    return false, attr, "no_empty_slots"
  end

  local slot = tonumber(selectedSlot)
  if slot then
    if slot < 1 or slot > maxSlots then
      return false, attr, "invalid_slot"
    end
    if target:getBonusAttribute(slot) then
      return false, attr, "slot_not_empty"
    end
  end

  return true, attr, nil
end

local function shortenText(text, maxLen)
  if not text or text:len() <= maxLen then
    return text
  end
  return text:sub(1, maxLen - 3) .. "..."
end

local function buildCraftSummary(itemType)
  if not itemType or itemType:getId() == 0 then
    return nil
  end

  local tags = {}

  local attack = itemType:getAttack()
  if attack and attack > 0 then
    tags[#tags + 1] = "Atk " .. attack
  end

  local defense = itemType:getDefense()
  if defense and defense > 0 then
    tags[#tags + 1] = "Def " .. defense
  end

  local extraDefense = itemType:getExtraDefense()
  if extraDefense and extraDefense > 0 then
    tags[#tags + 1] = "Def+ " .. extraDefense
  end

  local armor = itemType:getArmor()
  if armor and armor > 0 then
    tags[#tags + 1] = "Arm " .. armor
  end

  local hitChance = itemType:getHitChance()
  if hitChance and hitChance > 0 then
    tags[#tags + 1] = "Hit +" .. hitChance .. "%"
  end

  local shootRange = itemType:getShootRange()
  if shootRange and shootRange > 1 then
    tags[#tags + 1] = "Rng " .. shootRange
  end

  local desc = (itemType:getDescription() or ""):lower()
  if desc:find("regen") or desc:find("regenerat") then
    if desc:find("mana") then
      tags[#tags + 1] = "Mana Regen"
    end
    if desc:find("health") or desc:find("life") or desc:find("hitpoint") then
      tags[#tags + 1] = "Life Regen"
    end
  end

  if #tags > 0 then
    return table.concat(tags, " | ")
  end

  local plainDesc = itemType:getDescription()
  if plainDesc and plainDesc:len() > 0 then
    return shortenText(plainDesc, 60)
  end

  return ""
end

local function buildCraftTooltip(itemType, craft)
  if not itemType or itemType:getId() == 0 then
    return nil
  end

  local lines = {}
  lines[#lines + 1] = itemType:getName()

  local desc = itemType:getDescription()
  if desc and desc:len() > 0 then
    lines[#lines + 1] = desc
  end

  local armor = itemType:getArmor()
  if armor and armor > 0 then
    lines[#lines + 1] = "Armor: " .. armor
  end

  local attack = itemType:getAttack()
  if attack and attack > 0 then
    lines[#lines + 1] = "Attack: " .. attack
  end

  local defense = itemType:getDefense()
  if defense and defense > 0 then
    lines[#lines + 1] = "Defense: " .. defense
  end

  local extraDefense = itemType:getExtraDefense()
  if extraDefense and extraDefense > 0 then
    lines[#lines + 1] = "Extra Defense: " .. extraDefense
  end

  local hitChance = itemType:getHitChance()
  if hitChance and hitChance > 0 then
    lines[#lines + 1] = "Hit Chance: +" .. hitChance .. "%"
  end

  local shootRange = itemType:getShootRange()
  if shootRange and shootRange > 1 then
    lines[#lines + 1] = "Range: " .. shootRange
  end

  lines[#lines + 1] = "Craft Cost: " .. craft.cost .. " gp"

  return table.concat(lines, "\n")
end

local function resolveCraftRecipe(craft, recipeId)
  if craft and craft.recipes and #craft.recipes > 0 then
    local idx = tonumber(recipeId) or 1
    idx = math.max(1, math.min(idx, #craft.recipes))
    local recipe = craft.recipes[idx]
    return {
      cost = recipe.cost or craft.cost or 0,
      count = recipe.count or craft.count or 1,
      materials = recipe.materials or {}
    }, idx
  end

  return {
    cost = craft.cost or 0,
    count = craft.count or 1,
    materials = craft.materials or {}
  }, 1
end

local ActionEvent = Action()

function ActionEvent.onUse(player)
  player:showCrafting()
  return true
end

local LoginEvent = CreatureEvent("CraftingLogin")

function LoginEvent.onLogin(player)
  player:registerEvent("CraftingExtended")
  return true
end

local ExtendedEvent = CreatureEvent("CraftingExtended")

function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode == CODE_CRAFTING then
    local status, json_data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )

    if not status then
      return false
    end

    local action = json_data.action
    local data = json_data.data

    if action == "fetch" then
      Crafting:sendMoney(player)
      for _, category in ipairs(categories) do
        Crafting:sendCrafts(player, category)
      end
    elseif action == "enchanter_target" then
      Crafting:sendEnchanterOptions(player, data and data.target or nil)
    elseif action == "craft" then
      Crafting:craft(player, data)
    end
  end
  return true
end

function Crafting:sendCrafts(player, category)
  local data = {}

  for i = 1, #Crafting[category] do
    local craft = {}
    for key, value in pairs(Crafting[category][i]) do
      if key == "materials" then
        craft.materials = {}
        for indx, material in ipairs(value) do
          local matType = ItemType(material.id)
          craft.materials[indx] = {
            id = material.id,
            serverId = material.id,
            name = matType:getName(),
            count = material.count,
            player = player:getItemCount(material.id)
          }
        end
      elseif key == "recipes" then
        craft.recipes = {}
        for recipeIndex, recipe in ipairs(value) do
          local recipeData = {
            cost = recipe.cost or Crafting[category][i].cost or 0,
            count = recipe.count or Crafting[category][i].count or 1,
            materials = {}
          }

          for materialIndex, material in ipairs(recipe.materials or {}) do
            local matType = ItemType(material.id)
            recipeData.materials[materialIndex] = {
              id = material.id,
              serverId = material.id,
              name = matType:getName(),
              count = material.count,
              player = player:getItemCount(material.id)
            }
          end
          craft.recipes[recipeIndex] = recipeData
        end
      else
        craft[key] = value
      end
    end

    if craft.recipes and #craft.recipes > 0 then
      for recipeIndex = 1, #craft.recipes do
        local recipe = craft.recipes[recipeIndex]
        for materialIndex = 1, #recipe.materials do
          recipe.materials[materialIndex].id = ItemType(recipe.materials[materialIndex].id):getClientId()
        end
      end

      local defaultRecipe = craft.recipes[1]
      craft.cost = defaultRecipe.cost or craft.cost
      craft.count = defaultRecipe.count or craft.count
      craft.materials = {}
      for materialIndex, material in ipairs(defaultRecipe.materials or {}) do
        craft.materials[materialIndex] = {
          id = material.id,
          serverId = material.serverId,
          name = material.name,
          count = material.count,
          player = material.player
        }
      end
    else
      craft.materials = craft.materials or {}
      for x = 1, #craft.materials do
        craft.materials[x].id = ItemType(craft.materials[x].id):getClientId()
      end
    end

    local itemType = ItemType(craft.id)
    craft.clientId = itemType:getClientId()
    craft.tooltip = buildCraftTooltip(itemType, craft)
    craft.summary = buildCraftSummary(itemType)
    if category == "enchanter" and craft.enchantId then
      local attr = US_ENCHANTMENTS[craft.enchantId]
      if attr then
        craft.summary = "Min item lvl: " .. (attr.minLevel or 1)
        craft.tooltip = (attr.description or attr.name) .. "\nCost: 1 enchant crystal"
      end
    end
    table.insert(data, craft)
  end

  if #data >= fetchLimit then
    local x = 1
    for i = 1, math.floor(#data / fetchLimit) do
      player:sendExtendedOpcode(
        CODE_CRAFTING,
        json.encode({action = "fetch", data = {category = category, crafts = {unpack(data, x, math.min(x + fetchLimit - 1, #data))}}})
      )
      x = x + fetchLimit
    end

    if x < #data then
      player:sendExtendedOpcode(CODE_CRAFTING, json.encode({action = "fetch", data = {category = category, crafts = {unpack(data, x, #data)}}}))
    end
  else
    player:sendExtendedOpcode(CODE_CRAFTING, json.encode({action = "fetch", data = {category = category, crafts = data}}))
  end
end

function Crafting:craft(player, data)
  local category = data and data.category
  local craftId = data and data.craftId
  local recipeId = data and data.recipeId
  if not category or not craftId or not Crafting[category] then
    return
  end
  local craft = Crafting[category][craftId]
  if not craft then
    return
  end

  local recipe = resolveCraftRecipe(craft, recipeId)
  local isEnchantService = category == "enchanter" and craft.enchantId ~= nil

  if isEnchantService then
    if player:getLevel() < craft.level then
      return
    end

    local target = parseTargetItem(player, data.target)
    if not target then
      player:sendCancelMessage("Select target item first.")
      return
    end

    local requestedSlot = tonumber(data.targetSlot)
    local canApply, attr = canApplyEnchanterCraft(target, craft, player, requestedSlot)
    if not canApply then
      player:sendCancelMessage("This enchant is not compatible with the selected item.")
      return
    end

    local chosenSlot = requestedSlot
    if not chosenSlot then
      local emptySlots = getEmptyAttributeSlots(target)
      chosenSlot = emptySlots[1]
    end
    if not chosenSlot then
      player:sendCancelMessage("No empty enchant slot.")
      return
    end

    local money = player:getTotalMoney()
    if money < recipe.cost then
      return
    end

    local crystalId = US_CONFIG[1][ITEM_ENCHANT_CRYSTAL]
    if player:getItemCount(crystalId) < 1 then
      player:sendCancelMessage("You need enchant crystal.")
      return
    end

    local maxRoll = 1
    local itemLevel = target:getItemLevel()
    if attr.VALUES_PER_LEVEL then
      maxRoll = math.max(1, math.ceil(math.max(1, itemLevel) * attr.VALUES_PER_LEVEL))
    end
    local value = attr.VALUES_PER_LEVEL and math.random(1, maxRoll) or 1
    target:addAttribute(chosenSlot, craft.enchantId, value)

    player:removeItem(crystalId, 1)
    if recipe.cost > 0 then
      player:removeTotalMoney(recipe.cost)
    end

    player:sendTextMessage(MESSAGE_INFO_DESCR, "Enchantment applied in slot " .. chosenSlot .. ": " .. attr.name .. " +" .. value)
    player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
    player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_BLUE)

    Crafting:sendMoney(player)
    Crafting:sendMaterials(player, category)
    player:sendExtendedOpcode(CODE_CRAFTING, json.encode({action = "crafted"}))
    return
  end

  local money = player:getTotalMoney()

  if money < recipe.cost then
    return
  end

  if player:getLevel() < craft.level then
    return
  end

  for i = 1, #recipe.materials do
    local material = recipe.materials[i]
    if player:getItemCount(material.id) < material.count then
      return
    end
  end

  local resultCount = math.max(1, tonumber(recipe.count) or tonumber(craft.count) or 1)
  if player:addItem(craft.id, resultCount, false) then
    player:removeTotalMoney(recipe.cost)

    for i = 1, #recipe.materials do
      local material = recipe.materials[i]
      player:removeItem(material.id, material.count)
    end

    Crafting:sendMoney(player)
    Crafting:sendMaterials(player, category)
    player:sendExtendedOpcode(CODE_CRAFTING, json.encode({action = "crafted"}))
  else
    player:sendCancelMessage("Not enough capacity or space.")
  end
end

function Crafting:sendEnchanterOptions(player, targetData)
  local allowed = {}
  local emptySlots = {}
  local target = parseTargetItem(player, targetData)
  local debug = {}

  if target then
    local targetPos = target:getPosition()
    debug[#debug + 1] = "target=" .. target:getId()
    if targetPos then
      debug[#debug + 1] = string.format("pos=%d,%d,%d", targetPos.x or -1, targetPos.y or -1, targetPos.z or -1)
    end
    debug[#debug + 1] = "lvl=" .. tostring(target:getItemLevel() or 0)
    debug[#debug + 1] = "max=" .. tostring(target:getMaxAttributes() or 0)
    emptySlots = getEmptyAttributeSlots(target)
    debug[#debug + 1] = "empty=" .. tostring(#emptySlots)
    debug[#debug + 1] = "slots=" .. table.concat(emptySlots, ",")

    local reasonStats = {}
    for i = 1, #Crafting.enchanter do
      local craft = Crafting.enchanter[i]
      local ok, _, reason = canApplyEnchanterCraft(target, craft, player)
      if ok then
        allowed[#allowed + 1] = i
      else
        reason = reason or "unknown"
        reasonStats[reason] = (reasonStats[reason] or 0) + 1
      end
    end
    debug[#debug + 1] = "allowed=" .. tostring(#allowed) .. "/" .. tostring(#Crafting.enchanter)
    for reason, count in pairs(reasonStats) do
      debug[#debug + 1] = reason .. ":" .. count
    end
  else
    debug[#debug + 1] = "target=nil"
  end

  player:sendExtendedOpcode(CODE_CRAFTING, json.encode({action = "enchanter_options", data = {ids = allowed, emptySlots = emptySlots, debug = table.concat(debug, " | ")}}))
end

function Crafting:sendMaterials(player, category)
  local data = {}

  for i = 1, #Crafting[category] do
    local sourceCraft = Crafting[category][i]
    if sourceCraft.recipes and #sourceCraft.recipes > 0 then
      local recipes = {}
      for recipeIndex, recipe in ipairs(sourceCraft.recipes) do
        local recipeCounts = {}
        for matId, matData in ipairs(recipe.materials or {}) do
          recipeCounts[matId] = player:getItemCount(matData.id)
        end
        recipes[recipeIndex] = recipeCounts
      end
      table.insert(data, {recipes = recipes})
    else
      local materials = {}
      for matId, matData in ipairs(sourceCraft.materials or {}) do
        materials[matId] = player:getItemCount(matData.id)
      end
      table.insert(data, materials)
    end
  end

  if #data >= fetchLimit then
    local x = 1
    for i = 1, math.floor(#data / fetchLimit) do
      player:sendExtendedOpcode(
        CODE_CRAFTING,
        json.encode({action = "materials", data = {category = category, from = x, materials = {unpack(data, x, math.min(x + fetchLimit - 1, #data))}}})
      )
      x = x + fetchLimit
    end

    if x < #data then
      player:sendExtendedOpcode(
        CODE_CRAFTING,
        json.encode({action = "materials", data = {category = category, from = x, materials = {unpack(data, x, #data)}}})
      )
    end
  else
    player:sendExtendedOpcode(CODE_CRAFTING, json.encode({action = "materials", data = {category = category, from = 1, materials = data}}))
  end
end

function Crafting:sendMoney(player)
  player:sendExtendedOpcode(CODE_CRAFTING, json.encode({action = "money", data = player:getTotalMoney()}))
end

function Player:showCrafting()
  Crafting:sendMoney(self)
  for _, category in ipairs(categories) do
    Crafting:sendMaterials(self, category)
  end
  self:sendExtendedOpcode(CODE_CRAFTING, json.encode({action = "show"}))
end

ActionEvent:aid(38820)
ActionEvent:register()
LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()
