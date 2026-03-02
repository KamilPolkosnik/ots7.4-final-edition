Crafting = {}

local CODE_CRAFTING = 108
local fetchLimit = 10

local categories = {"weaponsmith", "armorsmith", "alchemist", "enchanter", "jeweller"}
local CRAFTING_RANGE = 1
local CraftingSessions = {}
local CONTAINER_POS = rawget(_G, "CONTAINER_POSITION") or 65535
local SLOT_AMMO = rawget(_G, "CONST_SLOT_AMMO") or 10
local MAX_CONTAINER_SCAN_ID = 15
local MAX_CONTAINER_RECURSION = 8
local REVIVE_SPELLBOOK_ITEM_ID = 7961
local REVIVE_SPELLBOOK_DODGE_VALUE = 5
local REVIVE_SPELLBOOK_DODGE_FALLBACK_ENCHANT_ID = 58

local function resolveEnchantIdBySpecial(specialName, fallbackId)
  if type(US_ENCHANTMENTS) ~= "table" then
    return fallbackId
  end

  for enchantId, attr in pairs(US_ENCHANTMENTS) do
    if type(attr) == "table" and attr.special == specialName then
      return tonumber(enchantId) or fallbackId
    end
  end

  return fallbackId
end

local function applyCraftPresetBonuses(result, craftedItemId)
  if craftedItemId ~= REVIVE_SPELLBOOK_ITEM_ID or not result then
    return
  end

  local dodgeEnchantId = resolveEnchantIdBySpecial("DODGE", REVIVE_SPELLBOOK_DODGE_FALLBACK_ENCHANT_ID)

  local function applyToItem(item)
    if not item or not item.isItem or not item:isItem() then
      return
    end

    if item:getId() ~= REVIVE_SPELLBOOK_ITEM_ID then
      return
    end

    local maxSlots = item:getMaxAttributes() or 0
    if maxSlots <= 0 then
      return
    end

    local emptySlot = nil
    for i = 1, maxSlots do
      local bonus = item:getBonusAttribute(i)
      if bonus then
        if bonus[1] == dodgeEnchantId then
          if tonumber(bonus[2]) ~= REVIVE_SPELLBOOK_DODGE_VALUE then
            item:setAttributeValue(i, dodgeEnchantId .. "|" .. REVIVE_SPELLBOOK_DODGE_VALUE)
          end
          return
        end
      elseif not emptySlot then
        emptySlot = i
      end
    end

    if emptySlot then
      item:addAttribute(emptySlot, dodgeEnchantId, REVIVE_SPELLBOOK_DODGE_VALUE)
    end
  end

  if type(result) == "table" then
    for i = 1, #result do
      applyToItem(result[i])
    end
  else
    applyToItem(result)
  end
end

local function getPlayerTotalMoney(player)
  if player and player.getTotalMoney then
    local total = player:getTotalMoney()
    if total then
      return total
    end
  end
  return (player:getMoney() or 0) + (player:getBankBalance() or 0)
end

local function clonePos(pos)
  if not pos then
    return nil
  end
  return {x = pos.x, y = pos.y, z = pos.z}
end

local function inRange(pos, anchor, range)
  if not pos or not anchor then
    return false
  end
  if pos.z ~= anchor.z then
    return false
  end
  return math.abs(pos.x - anchor.x) <= range and math.abs(pos.y - anchor.y) <= range
end

local function sendCraftingClose(player, message)
  if message and message ~= "" then
    player:sendCancelMessage(message)
  end
  player:sendExtendedOpcode(CODE_CRAFTING, json.encode({action = "close"}))
end

local function clearCraftingSession(player, closeClient, message)
  CraftingSessions[player:getId()] = nil
  if closeClient then
    sendCraftingClose(player, message)
  end
end

local function setCraftingSession(player, anchorPos)
  CraftingSessions[player:getId()] = {
    anchor = clonePos(anchorPos),
    range = CRAFTING_RANGE
  }
end

local function getCraftingSession(player)
  return CraftingSessions[player:getId()]
end

local function ensureCraftingInRange(player, closeOnFail)
  local session = getCraftingSession(player)
  if not session or not session.anchor then
    if closeOnFail then
      clearCraftingSession(player, true, "Open crafting at the crafting station.")
    end
    return nil
  end

  if not inRange(player:getPosition(), session.anchor, session.range or CRAFTING_RANGE) then
    if closeOnFail then
      clearCraftingSession(player, true, "You moved too far from the crafting station.")
    end
    return nil
  end

  return session
end

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

  -- Enchanter target is selected from backpack/container.
  if x ~= CONTAINER_POS then
    return nil
  end

  local function isBackpackItem(it)
    if not it then
      return false
    end
    local p = it:getPosition()
    if not p or p.x ~= CONTAINER_POS then
      return false
    end
    -- Equipped items usually come as x=65535, y=slot(<=10), z=0.
    if p.z == 0 and p.y <= SLOT_AMMO then
      return false
    end
    return true
  end

  local function getContainerItemByIndex(container, index)
    if not container then
      return nil
    end
    index = tonumber(index)
    if not index then
      return nil
    end
    local it = container:getItem(index)
    if it then
      return it
    end
    -- Some builds expose 1-based indexing in Lua wrappers.
    if index >= 0 then
      return container:getItem(index + 1)
    end
    return nil
  end

  local function findByIdInContainer(container, wantedId, depth)
    if not container or depth <= 0 then
      return nil
    end
    local size = container:getSize() or 0
    for i = 0, size - 1 do
      local ci = container:getItem(i)
      if ci then
        if ci:getId() == wantedId then
          return ci
        end
        if ci:isContainer() then
          local nested = findByIdInContainer(ci, wantedId, depth - 1)
          if nested then
            return nested
          end
        end
      end
    end
    return nil
  end

  local item
  local fallbackId = tonumber(targetData.id) or 0

  -- Protocol container addressing: x=65535, y=containerId+64, z=slotIndex.
  if y >= 64 then
    local containerId = y - 64
    local container = player:getContainerById(containerId)
    if container then
      item = getContainerItemByIndex(container, z)
      if item then
        return item
      end

      if stackpos and stackpos ~= z and stackpos >= 0 then
        item = getContainerItemByIndex(container, stackpos)
        if item then
          return item
        end
      end

      if fallbackId > 0 then
        item = findByIdInContainer(container, fallbackId, MAX_CONTAINER_RECURSION)
        if item then
          return item
        end
      end
    end
  end

  -- Generic lookup fallback.
  local pos = Position(x, y, z, stackpos)
  item = player:getItem(pos)
  if isBackpackItem(item) then
    return item
  end

  -- Try without stack index as some builds ignore/expect different stackpos for container positions.
  item = player:getItem(Position(x, y, z))
  if isBackpackItem(item) then
    return item
  end

  if stackpos ~= 0 then
    item = player:getItem(Position(x, y, z, 0))
    if isBackpackItem(item) then
      return item
    end
  end

  -- Fallback by id/subtype inside open containers.
  if fallbackId > 0 then
    -- Prefer searching all open containers before generic getItemById to avoid map collisions.
    for containerId = 0, MAX_CONTAINER_SCAN_ID do
      local container = player:getContainerById(containerId)
      if container then
        item = findByIdInContainer(container, fallbackId, MAX_CONTAINER_RECURSION)
        if isBackpackItem(item) then
          return item
        end
      end
    end

    local fallbackSubType = tonumber(targetData.subType)
    if fallbackSubType and fallbackSubType >= 0 then
      item = player:getItemById(fallbackId, true, fallbackSubType)
      if isBackpackItem(item) then
        return item
      end
    end

    item = player:getItemById(fallbackId, true)
    if isBackpackItem(item) then
      return item
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

local function isEnchantAllowedForTarget(attr, target, usItemType)
  if type(us_IsEnchantAllowedForItem) == "function" then
    return us_IsEnchantAllowedForItem(attr, target, usItemType)
  end

  local typeMask = tonumber(attr and attr.itemType) or 0
  local maskAllowed = typeMask > 0 and usItemType and bit.band(usItemType, typeMask) ~= 0

  local idAllowed = false
  if attr and type(attr.allowedItemIds) == "table" then
    local itemId = target:getId()
    for _, allowedId in ipairs(attr.allowedItemIds) do
      if tonumber(allowedId) == itemId then
        idAllowed = true
        break
      end
    end
  end

  if not maskAllowed and not idAllowed then
    return false
  end

  local itemType = target:getType()
  if not itemType then
    return false
  end

  local weaponType = itemType:getWeaponType()
  if attr and type(attr.allowedWeaponTypes) == "table" and weaponType > 0 then
    local weaponAllowed = false
    for _, allowedWeaponType in ipairs(attr.allowedWeaponTypes) do
      if tonumber(allowedWeaponType) == weaponType then
        weaponAllowed = true
        break
      end
    end
    if not weaponAllowed then
      return false
    end
  end

  if attr and type(attr.allowedAmmoTypes) == "table" and weaponType > 0 then
    local ammoType = itemType:getAmmoType()
    local ammoAllowed = false
    for _, allowedAmmoType in ipairs(attr.allowedAmmoTypes) do
      if tonumber(allowedAmmoType) == ammoType then
        ammoAllowed = true
        break
      end
    end
    if not ammoAllowed then
      return false
    end
  end

  return true
end

local function canApplyEnchanterCraft(target, craft, player, selectedSlot)
  if not target or not craft or not craft.enchantId then
    return false, nil, "invalid_target_or_craft"
  end

  local session = getCraftingSession(player)
  if not session or not session.anchor then
    return false, nil, "session_missing"
  end

  local targetPosition = target:getPosition()
  if targetPosition and targetPosition.x == CONTAINER_POS and targetPosition.z == 0 and targetPosition.y <= SLOT_AMMO then
    return false, nil, "equipped_slot"
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
  local matchesType = usItemType and isEnchantAllowedForTarget(attr, target, usItemType) or false
  if not matchesType then
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

local function getEnchanterRollValue(target, attr)
  local itemLevel = math.max(0, math.floor(tonumber(target and target:getItemLevel() or 0) or 0))

  local tick = tonumber(attr.VALUE_TICK_EVERY or attr.valueTickEvery) or tonumber(US_CONFIG.BONUS_VALUE_TICK_EVERY_DEFAULT) or 0
  if tick > 0 then
    local minLevel = tonumber(attr.minLevel) or 0
    local baseLevel = tonumber(attr.BASE_ITEM_LEVEL or attr.baseItemLevel) or tonumber(US_CONFIG.BONUS_BASE_ITEM_LEVEL_DEFAULT) or 0
    local requiredLevel = math.max(math.floor(minLevel), math.floor(baseLevel))
    local effectiveLevel = math.max(0, itemLevel - requiredLevel)
    return 1 + math.floor(effectiveLevel / math.max(1, math.floor(tick)))
  end

  if attr.VALUES_PER_LEVEL then
    local maxRoll = math.max(1, math.ceil(math.max(1, itemLevel) * attr.VALUES_PER_LEVEL))
    return math.random(1, maxRoll)
  end

  return 1
end

local function shortenText(text, maxLen)
  if not text or text:len() <= maxLen then
    return text
  end
  return text:sub(1, maxLen - 3) .. "..."
end

local function getQuiverSlotCount(itemType)
  if not itemType or itemType:getId() == 0 then
    return 0
  end

  local isQuiver = false
  local slotPosition = itemType:getSlotPosition()
  if type(slotPosition) == "number" and type(SLOTP_QUIVER) == "number" then
    if bit and bit.band then
      isQuiver = bit.band(slotPosition, SLOTP_QUIVER) ~= 0
    else
      isQuiver = slotPosition == SLOTP_QUIVER
    end
  end

  if not isQuiver and itemType:isContainer() then
    local lowerName = (itemType:getName() or ""):lower()
    isQuiver = lowerName:find("quiver", 1, true) ~= nil
  end

  if not isQuiver then
    return 0
  end

  local capacity = tonumber(itemType:getCapacity()) or 0
  return math.max(0, capacity)
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

  local quiverSlots = getQuiverSlotCount(itemType)
  if quiverSlots > 0 then
    tags[#tags + 1] = "Slots " .. quiverSlots
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

local craftProtectionNames = {
  [COMBAT_PHYSICALDAMAGE] = "Physical Protection",
  [COMBAT_ENERGYDAMAGE] = "Energy Protection",
  [COMBAT_EARTHDAMAGE] = "Earth Protection",
  [COMBAT_FIREDAMAGE] = "Fire Protection",
  [COMBAT_LIFEDRAIN] = "Lifedrain Protection",
  [COMBAT_MANADRAIN] = "Manadrain Protection",
  [COMBAT_HEALING] = "Healing Protection",
  [COMBAT_DROWNDAMAGE] = "Drown Protection",
  [COMBAT_ICEDAMAGE] = "Ice Protection",
  [COMBAT_HOLYDAMAGE] = "Holy Protection",
  [COMBAT_DEATHDAMAGE] = "Death Protection"
}

local craftElementNames = {
  [COMBAT_PHYSICALDAMAGE] = "Physical",
  [COMBAT_ENERGYDAMAGE] = "Energy",
  [COMBAT_EARTHDAMAGE] = "Earth",
  [COMBAT_FIREDAMAGE] = "Fire",
  [COMBAT_LIFEDRAIN] = "Lifedrain",
  [COMBAT_MANADRAIN] = "Manadrain",
  [COMBAT_HEALING] = "Healing",
  [COMBAT_DROWNDAMAGE] = "Drown",
  [COMBAT_ICEDAMAGE] = "Ice",
  [COMBAT_HOLYDAMAGE] = "Holy",
  [COMBAT_DEATHDAMAGE] = "Death"
}

local craftSkillBonuses = {}
local craftStatBonuses = {}
local craftSpecialBonuses = {}

local function addCraftBonusDef(target, id, name, percent)
  if id ~= nil then
    target[#target + 1] = {id = id, name = name, percent = percent == true}
  end
end

addCraftBonusDef(craftSkillBonuses, SKILL_FIST, "Fist Fighting")
addCraftBonusDef(craftSkillBonuses, SKILL_SWORD, "Sword Fighting")
addCraftBonusDef(craftSkillBonuses, SKILL_AXE, "Axe Fighting")
addCraftBonusDef(craftSkillBonuses, SKILL_CLUB, "Club Fighting")
addCraftBonusDef(craftSkillBonuses, SKILL_DISTANCE, "Distance Fighting")
addCraftBonusDef(craftSkillBonuses, SKILL_SHIELD, "Shielding")
addCraftBonusDef(craftSkillBonuses, SKILL_FISHING, "Fishing")

addCraftBonusDef(craftStatBonuses, STAT_MAGICPOINTS, "Magic Level")
addCraftBonusDef(craftStatBonuses, STAT_MAXHITPOINTS, "Max HP")
addCraftBonusDef(craftStatBonuses, STAT_MAXMANAPOINTS, "Max Mana")

addCraftBonusDef(craftSpecialBonuses, SPECIALSKILL_CRITICALHITCHANCE, "Critical Chance", true)
addCraftBonusDef(craftSpecialBonuses, SPECIALSKILL_CRITICALHITAMOUNT, "Critical Damage", true)
addCraftBonusDef(craftSpecialBonuses, SPECIALSKILL_LIFELEECHCHANCE, "Life Leech Chance", true)
addCraftBonusDef(craftSpecialBonuses, SPECIALSKILL_LIFELEECHAMOUNT, "Life Leech", true)
addCraftBonusDef(craftSpecialBonuses, SPECIALSKILL_MANALEECHCHANCE, "Mana Leech Chance", true)
addCraftBonusDef(craftSpecialBonuses, SPECIALSKILL_MANALEECHAMOUNT, "Mana Leech", true)

local function formatSigned(value, suffix)
  local n = tonumber(value) or 0
  local sign = n > 0 and "+" or ""
  return sign .. tostring(n) .. (suffix or "")
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

  local quiverSlots = getQuiverSlotCount(itemType)
  if quiverSlots > 0 then
    lines[#lines + 1] = "Slots: " .. quiverSlots
  end

  local hitChance = itemType:getHitChance()
  if hitChance and hitChance > 0 then
    lines[#lines + 1] = "Hit Chance: +" .. hitChance .. "%"
  end

  local shootRange = itemType:getShootRange()
  if shootRange and shootRange > 1 then
    lines[#lines + 1] = "Range: " .. shootRange
  end

  local bonuses = {}

  local elementType = itemType:getElementType()
  local elementDamage = itemType:getElementDamage()
  if elementType and elementType ~= COMBAT_NONE and elementDamage and elementDamage ~= 0 then
    local elementName = craftElementNames[elementType] or "Elemental"
    bonuses[#bonuses + 1] = "Element Damage: " .. formatSigned(elementDamage) .. " " .. elementName
  end

  local allProtection = itemType:getAbsorbPercent(0)
  if allProtection ~= 0 then
    for i = 0, COMBAT_COUNT - 1 do
      if itemType:getAbsorbPercent(i) ~= allProtection then
        allProtection = 0
        break
      end
    end
  end

  if allProtection ~= 0 then
    bonuses[#bonuses + 1] = "All Protection: " .. formatSigned(allProtection, "%")
  else
    for i = 0, COMBAT_COUNT - 1 do
      local value = itemType:getAbsorbPercent(i)
      if value ~= 0 then
        local combatType = bit.lshift(1, i)
        if combatType ~= COMBAT_UNDEFINEDDAMAGE then
          local protectionName = craftProtectionNames[combatType]
          if protectionName then
            bonuses[#bonuses + 1] = protectionName .. ": " .. formatSigned(value, "%")
          end
        end
      end
    end
  end

  for i = 1, #craftSkillBonuses do
    local bonus = craftSkillBonuses[i]
    local value = itemType:getSkill(bonus.id)
    if value and value ~= 0 then
      bonuses[#bonuses + 1] = bonus.name .. ": " .. formatSigned(value)
    end
  end

  for i = 1, #craftStatBonuses do
    local bonus = craftStatBonuses[i]
    local flatValue = itemType:getStat(bonus.id)
    if flatValue and flatValue ~= 0 then
      bonuses[#bonuses + 1] = bonus.name .. ": " .. formatSigned(flatValue)
    end

    local percentValue = itemType:getStatPercent(bonus.id)
    if percentValue and percentValue ~= 0 and percentValue ~= 100 then
      bonuses[#bonuses + 1] = bonus.name .. ": " .. formatSigned(percentValue - 100, "%")
    end
  end

  for i = 1, #craftSpecialBonuses do
    local bonus = craftSpecialBonuses[i]
    local value = itemType:getSpecialSkill(bonus.id)
    if value and value ~= 0 then
      bonuses[#bonuses + 1] = bonus.name .. ": " .. formatSigned(value, bonus.percent and "%" or "")
    end
  end

  local speed = itemType:getSpeed()
  if speed and speed ~= 0 then
    bonuses[#bonuses + 1] = "Movement Speed: " .. formatSigned(speed)
  end

  local healthGain = itemType:getHealthGain()
  local healthTicks = itemType:getHealthTicks()
  if healthGain and healthGain ~= 0 then
    if healthTicks and healthTicks > 0 then
      bonuses[#bonuses + 1] = "Health Regen: " .. formatSigned(healthGain) .. " / " .. (healthTicks / 1000) .. "s"
    else
      bonuses[#bonuses + 1] = "Health Regen: " .. formatSigned(healthGain)
    end
  end

  local manaGain = itemType:getManaGain()
  local manaTicks = itemType:getManaTicks()
  if manaGain and manaGain ~= 0 then
    if manaTicks and manaTicks > 0 then
      bonuses[#bonuses + 1] = "Mana Regen: " .. formatSigned(manaGain) .. " / " .. (manaTicks / 1000) .. "s"
    else
      bonuses[#bonuses + 1] = "Mana Regen: " .. formatSigned(manaGain)
    end
  end

  if #bonuses > 0 then
    lines[#lines + 1] = "Bonuses:"
    for i = 1, #bonuses do
      lines[#lines + 1] = "- " .. bonuses[i]
    end
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

function ActionEvent.onUse(player, item, fromPosition, target, toPosition, isHotkey)
  local anchor = player:getPosition()
  if item and item:getPosition() then
    anchor = item:getPosition()
  end
  setCraftingSession(player, anchor)
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
      if not ensureCraftingInRange(player, true) then
        return true
      end
      Crafting:sendEnchanterOptions(player, data and data.target or nil)
    elseif action == "craft" then
      if not ensureCraftingInRange(player, true) then
        return true
      end
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
    craft.attack = itemType:getAttack()
    craft.defense = itemType:getDefense()
    craft.extraDefense = itemType:getExtraDefense()
    craft.twoHanded = itemType:isTwoHanded()
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
    if not ensureCraftingInRange(player, true) then
      return
    end

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

    local money = getPlayerTotalMoney(player)
    if money < recipe.cost then
      return
    end

    local crystalId = US_CONFIG[1][ITEM_ENCHANT_CRYSTAL]
    if player:getItemCount(crystalId) < 1 then
      player:sendCancelMessage("You need enchant crystal.")
      return
    end

    local value = getEnchanterRollValue(target, attr)
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

  local money = getPlayerTotalMoney(player)

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
  local craftedResult = player:addItem(craft.id, resultCount, false)
  if craftedResult then
    applyCraftPresetBonuses(craftedResult, craft.id)
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
    if #allowed > 0 then
      local preview = {}
      for i = 1, math.min(#allowed, 10) do
        preview[#preview + 1] = tostring(allowed[i])
      end
      debug[#debug + 1] = "allowed_ids=" .. table.concat(preview, ",")
    end
    for reason, count in pairs(reasonStats) do
      debug[#debug + 1] = reason .. ":" .. count
    end
  else
    debug[#debug + 1] = "target=nil"
    if type(targetData) == "table" then
      debug[#debug + 1] =
        string.format(
        "in=%s,%s,%s sp=%s id=%s st=%s cpos=%s",
        tostring(targetData.x),
        tostring(targetData.y),
        tostring(targetData.z),
        tostring(targetData.stackpos),
        tostring(targetData.id),
        tostring(targetData.subType),
        tostring(CONTAINER_POS)
      )

      local probeId = tonumber(targetData.id) or 0
      if probeId > 0 then
        local containerId = tonumber(targetData.y)
        if containerId and containerId >= 64 then
          containerId = containerId - 64
          local c = player:getContainerById(containerId)
          if c then
            local size = c:getSize() or 0
            local zidx = tonumber(targetData.z) or 0
            local i0 = c:getItem(zidx)
            local i1 = c:getItem(zidx + 1)
            debug[#debug + 1] =
              string.format(
              "cont=%d size=%d idx=%d item0=%s item1=%s",
              containerId,
              size,
              zidx,
              tostring(i0 and i0:getId() or "nil"),
              tostring(i1 and i1:getId() or "nil")
            )
          else
            debug[#debug + 1] = "cont=" .. tostring(containerId) .. " nil"
          end
        end

        local probe = player:getItemById(probeId, true)
        if probe then
          local pp = probe:getPosition()
          debug[#debug + 1] =
            string.format(
            "probe_id=%d pos=%s,%s,%s",
            probeId,
            tostring(pp and pp.x or -1),
            tostring(pp and pp.y or -1),
            tostring(pp and pp.z or -1)
          )
        else
          debug[#debug + 1] = "probe_id=" .. probeId .. " not_found"
        end
      end
    end
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
  player:sendExtendedOpcode(CODE_CRAFTING, json.encode({action = "money", data = getPlayerTotalMoney(player)}))
end

function Player:showCrafting()
  if not ensureCraftingInRange(self, false) then
    setCraftingSession(self, self:getPosition())
  end
  Crafting:sendMoney(self)
  for _, category in ipairs(categories) do
    Crafting:sendMaterials(self, category)
  end
  self:sendExtendedOpcode(CODE_CRAFTING, json.encode({action = "show"}))
end

local CraftingSessionWatch = GlobalEvent("CraftingSessionWatch")

function CraftingSessionWatch.onThink(interval)
  for playerId, session in pairs(CraftingSessions) do
    local player = Player(playerId)
    if not player or not session or not session.anchor then
      CraftingSessions[playerId] = nil
    else
      if not inRange(player:getPosition(), session.anchor, session.range or CRAFTING_RANGE) then
        clearCraftingSession(player, true, "You moved too far from the crafting station.")
      end
    end
  end
  return true
end

CraftingSessionWatch:interval(500)
CraftingSessionWatch:register()

ActionEvent:aid(38820)
ActionEvent:register()
LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()
