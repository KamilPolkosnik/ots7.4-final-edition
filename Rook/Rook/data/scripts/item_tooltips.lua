local CODE_TOOLTIP = 105
local CODE_EXTRA_STATS = 107
local ITEM_TIER_BY_ID = {}
local FIXED_CRITICAL_HIT_DAMAGE = 50
local FIXED_LIFE_LEECH_CHANCE = 25
local FIXED_MANA_LEECH_CHANCE = 25

local function getMaxTooltipTier()
  if type(US_CONFIG) == "table" and US_CONFIG.ITEM_TIER_MAX then
    local maxTier = tonumber(US_CONFIG.ITEM_TIER_MAX)
    if maxTier then
      return math.max(1, math.floor(maxTier))
    end
  end
  return 25
end

local function parseItemTierFromLine(line)
  local key = line:match('key%s*=%s*"([^"]+)"')
  if not key then
    return nil
  end

  key = key:lower()
  if key ~= "tier" and key ~= "itemtier" then
    return nil
  end

  local value = line:match('value%s*=%s*"([^"]+)"')
  if not value then
    return nil
  end

  local tier = tonumber(value)
  if not tier then
    return nil
  end

  tier = math.floor(tier)
  if tier < 1 or tier > getMaxTooltipTier() then
    return nil
  end

  return tier
end

local function loadItemTiersFromItemsXml()
  local path = "data/items/items.xml"
  local file = io.open(path, "r")
  if not file then
    print("[Tooltips] Unable to load item tiers from " .. path)
    ITEM_TIER_BY_ID = {}
    return
  end

  local tierMap = {}
  local currentItemId = nil
  local currentTier = nil

  for line in file:lines() do
    local itemId = line:match('<item%s+id%s*=%s*"(%d+)"')
    if itemId then
      currentItemId = tonumber(itemId)
      currentTier = nil
    end

    if currentItemId then
      local parsedTier = parseItemTierFromLine(line)
      if parsedTier then
        currentTier = parsedTier
      end

      if line:find("</item>", 1, true) then
        if currentTier then
          tierMap[currentItemId] = currentTier
        end
        currentItemId = nil
        currentTier = nil
      end
    end
  end

  file:close()
  ITEM_TIER_BY_ID = tierMap
end

local function getItemTierById(itemId)
  if not itemId then
    return nil
  end
  return ITEM_TIER_BY_ID[itemId]
end

loadItemTiersFromItemsXml()

local specialSkills = {
  [SPECIALSKILL_CRITICALHITCHANCE] = "cc",
  [SPECIALSKILL_CRITICALHITAMOUNT] = "ca",
  [SPECIALSKILL_LIFELEECHCHANCE] = "lc",
  [SPECIALSKILL_LIFELEECHAMOUNT] = "la",
  [SPECIALSKILL_MANALEECHCHANCE] = "mc",
  [SPECIALSKILL_MANALEECHAMOUNT] = "ma"
}

local skills = {
  [SKILL_FIST] = "fist",
  [SKILL_AXE] = "axe",
  [SKILL_SWORD] = "sword",
  [SKILL_CLUB] = "club",
  [SKILL_DISTANCE] = "dist",
  [SKILL_SHIELD] = "shield",
  [SKILL_FISHING] = "fish"
}

local stats = {
  [STAT_MAGICPOINTS] = "mag",
  [STAT_MAXHITPOINTS] = "maxhp",
  [STAT_MAXMANAPOINTS] = "maxmp"
}

local statsPercent = {
  [STAT_MAXHITPOINTS] = "maxhp_p",
  [STAT_MAXMANAPOINTS] = "maxmp_p"
}

local combatTypeNames = {
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

local combatShortNames = {
  [COMBAT_PHYSICALDAMAGE] = "a_phys",
  [COMBAT_ENERGYDAMAGE] = "a_ene",
  [COMBAT_EARTHDAMAGE] = "a_earth",
  [COMBAT_FIREDAMAGE] = "a_fire",
  [COMBAT_LIFEDRAIN] = "a_ldrain",
  [COMBAT_MANADRAIN] = "a_mdrain",
  [COMBAT_HEALING] = "a_heal",
  [COMBAT_DROWNDAMAGE] = "a_drown",
  [COMBAT_ICEDAMAGE] = "a_ice",
  [COMBAT_HOLYDAMAGE] = "a_holy",
  [COMBAT_DEATHDAMAGE] = "a_death"
}

local extraStatsImplicitLabels = {
  a_phys = "Physical Prot",
  a_ene = "Energy Prot",
  a_earth = "Earth Prot",
  a_fire = "Fire Prot",
  a_ldrain = "Lifedrain Prot",
  a_mdrain = "Manadrain Prot",
  a_heal = "Healing Prot",
  a_drown = "Drown Prot",
  a_ice = "Ice Prot",
  a_holy = "Holy Prot",
  a_death = "Death Prot",
  a_all = "All Prot",
  cc = "Critical Hit Chance",
  ca = "Critical Hit Damage",
  lc = "Life Leech Chance",
  la = "Life Leech Amount",
  mc = "Mana Leech Chance",
  ma = "Mana Leech Amount",
  fist = "Fist Fighting",
  axe = "Axe Fighting",
  sword = "Sword Fighting",
  club = "Club Fighting",
  dist = "Distance Fighting",
  shield = "Shielding",
  fish = "Fishing",
  mag = "Magic Level",
  maxhp = "Max HP",
  maxmp = "Max MP",
  maxhp_p = "Max HP",
  maxmp_p = "Max MP",
  hpgain = "Life Gain",
  hpticks = "Life Tick",
  mpgain = "Mana Gain",
  mpticks = "Mana Tick",
  speed = "Speed",
  cap = "Capacity",
  eleDmg = "Element"
}

local extraStatsNameAliases = {
  magiclevel = "Magic Level",
  magiclvl = "Magic Level",
  mlvl = "Magic Level",
  fistfighting = "Fist Fighting",
  axefighting = "Axe Fighting",
  swordfighting = "Sword Fighting",
  clubfighting = "Club Fighting",
  distancefighting = "Distance Fighting",
  shielding = "Shielding",
  fishing = "Fishing",
  criticalhitchance = "Critical Hit Chance",
  criticalhitdamage = "Critical Hit Damage",
  criticaldamage = "Critical Hit Damage",
  critchance = "Critical Hit Chance",
  critdamage = "Critical Hit Damage",
  lifeleechchance = "Life Leech Chance",
  lifeleechamount = "Life Leech Amount",
  manaleechchance = "Mana Leech Chance",
  manaleechamount = "Mana Leech Amount",
  physicalprotection = "Physical Protection",
  energyprotection = "Energy Protection",
  earthprotection = "Earth Protection",
  fireprotection = "Fire Protection",
  iceprotection = "Ice Protection",
  holyprotection = "Holy Protection",
  deathprotection = "Death Protection",
  elementalprotection = "Elemental Protection",
  physicalprot = "Physical Protection",
  energyprot = "Energy Protection",
  earthprot = "Earth Protection",
  fireprot = "Fire Protection",
  iceprot = "Ice Protection",
  holyprot = "Holy Protection",
  deathprot = "Death Protection",
  allprot = "Elemental Protection",
  damagereflect = "Damage Reflect",
  reflect = "Damage Reflect",
  dodge = "Dodge",
  manaonkill = "Mana on Kill",
  lifeonkill = "Life on Kill",
  healthonkill = "Life on Kill"
}

local function toNumberOrZero(value)
  return tonumber(value) or 0
end

local function clampChance(value)
  value = toNumberOrZero(value)
  if value < 0 then
    return 0
  end
  if value > 100 then
    return 100
  end
  return value
end

local function canonicalExtraStatsName(name)
  name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if name == "" then
    return ""
  end

  local normalized = name:lower():gsub("[^a-z0-9]+", "")
  local alias = extraStatsNameAliases[normalized]
  if alias then
    return alias
  end

  return name
end

local function addExtraStatsAggregated(totalsByName, name, value, isPercent)
  name = canonicalExtraStatsName(name)
  if name == "" then
    return
  end

  local entry = totalsByName[name]
  if not entry then
    entry = {value = 0, percent = false}
    totalsByName[name] = entry
  end

  entry.value = entry.value + value
  if isPercent then
    entry.percent = true
  end
end

local function addExtraStatsLine(lineCounts, totalsByName, line)
  if not line then
    return
  end

  line = tostring(line):gsub("^%s+", ""):gsub("%s+$", "")
  if line == "" or line == "Empty Slot" then
    return
  end

  lineCounts[line] = (lineCounts[line] or 0) + 1

  local name, numeric = line:match("^(.+)%s+%+([%d%.]+)%%+$")
  if name and numeric then
    addExtraStatsAggregated(totalsByName, name, tonumber(numeric) or 0, true)
    return
  end

  name, numeric = line:match("^(.+)%s+%+([%d%.]+)$")
  if name and numeric then
    addExtraStatsAggregated(totalsByName, name, tonumber(numeric) or 0, false)
    return
  end

  name, numeric = line:match("^(.+):%s*([%d%.]+)%%+$")
  if name and numeric then
    addExtraStatsAggregated(totalsByName, name, tonumber(numeric) or 0, true)
    return
  end

  name, numeric = line:match("^(.+):%s*([%d%.]+)$")
  if name and numeric then
    addExtraStatsAggregated(totalsByName, name, tonumber(numeric) or 0, false)
    return
  end

  numeric = line:match("^Regenerate%s+([%d%.]+)%s+Mana%s+on%s+Kill$")
  if numeric then
    addExtraStatsAggregated(totalsByName, "Mana on Kill", tonumber(numeric) or 0, false)
    return
  end

  numeric = line:match("^Regenerate%s+([%d%.]+)%s+Health%s+on%s+Kill$")
  if numeric then
    addExtraStatsAggregated(totalsByName, "Life on Kill", tonumber(numeric) or 0, false)
    return
  end

  numeric = line:match("^Regenerate%s+Mana%s+for%s+([%d%.]+)%%+%s+of%s+dealt%s+damage$")
  if numeric then
    addExtraStatsAggregated(totalsByName, "Mana Steal", tonumber(numeric) or 0, true)
    return
  end

  numeric = line:match("^Heal%s+for%s+([%d%.]+)%%+%s+of%s+dealt%s+damage$")
  if numeric then
    addExtraStatsAggregated(totalsByName, "Life Steal", tonumber(numeric) or 0, true)
    return
  end
end

local function collectExtraStatsBonuses(player)
  local totalsByName = {}
  local lineCounts = {}
  local dodgeTotalFromSpecial = 0
  local reflectTotalFromSpecial = 0

  local function addImplicitIfPositive(labelKey, value, isPercent)
    value = toNumberOrZero(value)
    if value <= 0 then
      return
    end

    local label = extraStatsImplicitLabels[labelKey] or labelKey
    local suffix = isPercent and "%" or ""
    addExtraStatsLine(lineCounts, totalsByName, string.format("%s +%d%s", label, math.floor(value), suffix))
  end

  local function collectItemImplicit(item)
    local itemType = item:getType()
    if not itemType then
      return
    end

    for key, shortKey in pairs(specialSkills) do
      addImplicitIfPositive(shortKey, itemType:getSpecialSkill(key), true)
    end

    for key, shortKey in pairs(skills) do
      addImplicitIfPositive(shortKey, itemType:getSkill(key), false)
    end

    for key, shortKey in pairs(stats) do
      addImplicitIfPositive(shortKey, itemType:getStat(key), false)
    end

    for key, shortKey in pairs(statsPercent) do
      local s = toNumberOrZero(itemType:getStatPercent(key))
      if s >= 1 then
        addImplicitIfPositive(shortKey, s - 100, true)
      end
    end

    addImplicitIfPositive("hpgain", itemType:getHealthGain(), false)
    addImplicitIfPositive("hpticks", itemType:getHealthTicks(), false)
    addImplicitIfPositive("mpgain", itemType:getManaGain(), false)
    addImplicitIfPositive("mpticks", itemType:getManaTicks(), false)
    addImplicitIfPositive("speed", itemType:getSpeed(), false)
  end

  local function collectItemSlotBonuses(item)
    if not item.getBonusAttributes then
      return
    end

    local ok, values = pcall(function()
      return item:getBonusAttributes()
    end)
    if not ok or not values then
      return
    end

    for i = 1, #values do
      local bonus = values[i]
      local attrId = bonus[1]
      local attrValue = toNumberOrZero(bonus[2])
      local attr = US_ENCHANTMENTS and US_ENCHANTMENTS[attrId] or nil

      if attr and attrValue ~= 0 then
        local line = nil
        if type(attr.format) == "function" then
          local ok, formatted = pcall(attr.format, attrValue)
          if ok and type(formatted) == "string" and formatted:len() > 0 then
            line = formatted
          end
        end

        if not line then
          local suffix = (attr.percentage == true or attr.special == "DODGE" or attr.special == "REFLECT") and "%" or ""
          local attrName = attr.name or ("Bonus " .. tostring(attrId))
          line = string.format("%s +%d%s", attrName, math.floor(attrValue), suffix)
        end

        addExtraStatsLine(lineCounts, totalsByName, line)

        if attr.special == "DODGE" then
          dodgeTotalFromSpecial = dodgeTotalFromSpecial + attrValue
        elseif attr.special == "REFLECT" then
          reflectTotalFromSpecial = reflectTotalFromSpecial + attrValue
        end
      elseif attrValue ~= 0 then
        addExtraStatsLine(lineCounts, totalsByName, string.format("Unknown Bonus %s +%d", tostring(attrId), math.floor(attrValue)))
      end
    end
  end

  for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
    local item = player:getSlotItem(slot)
    if item and (item:getType():usesSlot(slot) or slot == CONST_SLOT_LEFT or slot == CONST_SLOT_RIGHT) then
      collectItemSlotBonuses(item)
      collectItemImplicit(item)
    end
  end

  local aggregatedBonuses = {}
  for name, entry in pairs(totalsByName) do
    aggregatedBonuses[#aggregatedBonuses + 1] = {
      name = name,
      value = math.floor(entry.value),
      percent = entry.percent and true or false
    }
  end

  table.sort(aggregatedBonuses, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  local equipmentLines = {}
  for line, count in pairs(lineCounts) do
    if count > 1 then
      equipmentLines[#equipmentLines + 1] = string.format("%s x%d", line, count)
    else
      equipmentLines[#equipmentLines + 1] = line
    end
  end

  table.sort(equipmentLines, function(a, b)
    return a:lower() < b:lower()
  end)

  local dodgeTotal = totalsByName["Dodge"] and toNumberOrZero(totalsByName["Dodge"].value) or 0
  local reflectTotal = totalsByName["Damage Reflect"] and toNumberOrZero(totalsByName["Damage Reflect"].value) or 0
  dodgeTotal = math.max(dodgeTotal, dodgeTotalFromSpecial)
  reflectTotal = math.max(reflectTotal, reflectTotalFromSpecial)

  return aggregatedBonuses, equipmentLines, dodgeTotal, reflectTotal
end

local function buildExtraStatsPayload(player)
  local critChanceBonus = toNumberOrZero(player:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE))
  local critDamageBonus = toNumberOrZero(player:getSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT))
  local lifeLeechChanceBonus = toNumberOrZero(player:getSpecialSkill(SPECIALSKILL_LIFELEECHCHANCE))
  local lifeLeechAmount = toNumberOrZero(player:getSpecialSkill(SPECIALSKILL_LIFELEECHAMOUNT))
  local manaLeechChanceBonus = toNumberOrZero(player:getSpecialSkill(SPECIALSKILL_MANALEECHCHANCE))
  local manaLeechAmount = toNumberOrZero(player:getSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT))

  local aggregatedBonuses, equipmentLines, dodgeTotal, reflectTotal = collectExtraStatsBonuses(player)

  return {
    coreStats = {
      criticalChance = clampChance(critChanceBonus),
      criticalDamage = math.floor(FIXED_CRITICAL_HIT_DAMAGE + critDamageBonus),
      criticalDamageBase = FIXED_CRITICAL_HIT_DAMAGE,
      criticalDamageBonus = math.floor(critDamageBonus),
      lifeLeechChance = clampChance(FIXED_LIFE_LEECH_CHANCE + lifeLeechChanceBonus),
      lifeLeechChanceBase = FIXED_LIFE_LEECH_CHANCE,
      lifeLeechChanceBonus = math.floor(lifeLeechChanceBonus),
      lifeLeechAmount = math.floor(lifeLeechAmount),
      manaLeechChance = clampChance(FIXED_MANA_LEECH_CHANCE + manaLeechChanceBonus),
      manaLeechChanceBase = FIXED_MANA_LEECH_CHANCE,
      manaLeechChanceBonus = math.floor(manaLeechChanceBonus),
      manaLeechAmount = math.floor(manaLeechAmount),
      dodge = clampChance(dodgeTotal),
      reflect = clampChance(reflectTotal)
    },
    aggregatedBonuses = aggregatedBonuses,
    equipmentLines = equipmentLines,
    generatedAt = os.time()
  }
end

local function isEquipmentPosition(pos)
  if not pos or not pos.y then
    return false
  end

  return pos.y <= CONST_SLOT_AMMO and pos.y ~= CONST_SLOT_BACKPACK
end

local LoginEvent = CreatureEvent("TooltipsLogin")

function LoginEvent.onLogin(player)
  player:registerEvent("TooltipsExtended")
  addEvent(function(playerId)
    local onlinePlayer = Player(playerId)
    if onlinePlayer and onlinePlayer.sendExtraStatsSnapshot then
      onlinePlayer:sendExtraStatsSnapshot()
    end
  end, 300, player:getId())
  return true
end

local ExtendedEvent = CreatureEvent("TooltipsExtended")

function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode == CODE_TOOLTIP then
    local status, data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )
    if not status or not data then
      return
    end

    if #data == 4 then
      local pos = Position(data[1], data[2], data[3], data[4])
      local item = player:getItem(pos)
      player:sendItemTooltip(item)
    elseif #data == 1 then
      local item = Game.getRealUniqueItem(data[1])
      if item then
        player:sendItemTooltip(item)
      end
    end
  elseif opcode == CODE_EXTRA_STATS then
    if buffer and buffer:len() > 0 then
      local ok, payload = pcall(function()
        return json.decode(buffer)
      end)
      if ok and type(payload) == "table" and payload.action and payload.action ~= "request" then
        return
      end
    end

    player:sendExtraStatsSnapshot()
  end
end

function Player:sendItemTooltip(item)
  if item then
    local item_data = item:buildTooltip()
    if item_data then
      self:sendExtendedOpcode(CODE_TOOLTIP, json.encode({action = "new", data = item_data}))
    end
  end
end

function Player:sendExtraStatsSnapshot()
  self:sendExtendedOpcode(CODE_EXTRA_STATS, json.encode({action = "snapshot", data = buildExtraStatsPayload(self)}))
end

function Item:buildTooltip()
  local uid = self:getRealUID()
  local itemType = self:getType()
  local item_data = {
    uid = uid,
    itemName = itemType:getName(),
    clientId = itemType:getClientId()
  }
  local itemTier = getItemTierById(self:getId())
  if itemTier then
    item_data.tier = itemTier
  end

  if itemType:getDescription():len() > 0 then
    item_data.desc = itemType:getDescription()
  end

  if self:getType():isUpgradable() or self:getType():canHaveItemLevel() then
    item_data.itemLevel = self:getItemLevel()
  end

  if itemType:getRequiredLevel() >= 1 then
    if not self:isLimitless() then
    item_data.reqLvl = itemType:getRequiredLevel()
    end
  end

  local implicit = {}

  if itemType:getElementType() ~= COMBAT_NONE and combatTypeNames[itemType:getElementType()] then
    implicit.eleDmg = "+" .. itemType:getElementDamage() .. " " .. combatTypeNames[itemType:getElementType()] .. " Damage"
  end

  local allprot = itemType:getAbsorbPercent(0)

  if allprot ~= 0 then
    for i = 0, COMBAT_COUNT - 1 do
      if itemType:getAbsorbPercent(i) ~= allprot then
        allprot = 0
        break
      end
    end
  end

  if allprot == 0 then
    for i = 0, COMBAT_COUNT - 1 do
      if itemType:getAbsorbPercent(i) ~= 0 then
        local combatType = bit.lshift(1, i)
        if combatType ~= COMBAT_UNDEFINEDDAMAGE then
          implicit[combatShortNames[combatType]] = itemType:getAbsorbPercent(i)
        end
      end
    end
  else
    implicit.a_all = allprot
  end

  for key, value in pairs(specialSkills) do
    local s = itemType:getSpecialSkill(key)
    if s and s >= 1 then
      implicit[value] = s
    end
  end

  for key, value in pairs(skills) do
    local s = itemType:getSkill(key)
    if s and s >= 1 then
      implicit[value] = s
    end
  end

  for key, value in pairs(stats) do
    local s = itemType:getStat(key)
    if s and s >= 1 then
      implicit[value] = s
    end
  end

  for key, value in pairs(statsPercent) do
    local s = itemType:getStatPercent(key)
    if s and s >= 1 then
      implicit[value] = s - 100
    end
  end

  local healthGain = itemType:getHealthGain()
  if healthGain and healthGain > 0 then
    implicit.hpgain = healthGain
  end

  local healthTicks = itemType:getHealthTicks()
  if healthTicks and healthTicks > 0 then
    implicit.hpticks = healthTicks
  end

  local manaGain = itemType:getManaGain()
  if manaGain and manaGain > 0 then
    implicit.mpgain = manaGain
  end

  local manaTicks = itemType:getManaTicks()
  if manaTicks and manaTicks > 0 then
    implicit.mpticks = manaTicks
  end

  local speed = itemType:getSpeed()
  if speed and speed > 0 then
    implicit.speed = speed
  end

  if self:isContainer() then
    implicit.cap = "Capacity " .. self:getCapacity()
  end

  if next(implicit) ~= nil then
    item_data.imp = implicit
  end

   if self:getType():isUpgradable() then
     if self:isUnidentified() then
       item_data.unidentified = true
     else
       item_data.uLevel = self:getUpgradeLevel()
       if self:isMirrored() then
         item_data.mirrored = true
       end
       if self:isUnique() then
         item_data.uniqueName = self:getUniqueName()
       end
       item_data.rarityId = self:getRarityId()
       item_data.maxAttr = self:getMaxAttributes()
       item_data.attr = {}
       for i = self:getMaxAttributes(), 1, -1 do
         local enchant = self:getBonusAttribute(i)
         if enchant then
           local attr = US_ENCHANTMENTS[enchant[1]]
           item_data.attr[i] = attr.format(enchant[2])
         else
           item_data.attr[i] = "Empty Slot"
         end
       end
     end
   end

  item_data.stackable = itemType:isStackable()
  item_data.itemType = formatItemType(itemType)
  if itemType:getArmor() > 0 then
    if self:getAttribute(ITEM_ATTRIBUTE_ARMOR) > 0 then
      item_data.armor = self:getAttribute(ITEM_ATTRIBUTE_ARMOR)
    else
      item_data.armor = itemType:getArmor()
    end
  elseif itemType:getShootRange() > 1 then
    if self:getAttribute(ITEM_ATTRIBUTE_ATTACK) > 0 then
      item_data.attack = self:getAttribute(ITEM_ATTRIBUTE_ATTACK)
    else
      item_data.attack = itemType:getAttack()
    end
    if self:getAttribute(ITEM_ATTRIBUTE_HITCHANCE) > 0 then
      item_data.hitChance = self:getAttribute(ITEM_ATTRIBUTE_HITCHANCE)
    else
      item_data.hitChance = itemType:getHitChance()
    end
    item_data.shootRange = itemType:getShootRange()
  elseif itemType:getAttack() > 0 then
    if self:getAttribute(ITEM_ATTRIBUTE_ATTACK) > 0 then
      item_data.attack = self:getAttribute(ITEM_ATTRIBUTE_ATTACK)
    else
      item_data.attack = itemType:getAttack()
    end
    if self:getAttribute(ITEM_ATTRIBUTE_DEFENSE) > 0 then
      item_data.defense = self:getAttribute(ITEM_ATTRIBUTE_DEFENSE)
    else
      item_data.defense = itemType:getDefense()
    end
    if self:getAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE) > 0 then
      item_data.extraDefense = self:getAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE)
    else
      item_data.extraDefense = itemType:getExtraDefense()
    end
  elseif itemType:getDefense() > 0 then
    if self:getAttribute(ITEM_ATTRIBUTE_DEFENSE) > 0 then
      item_data.defense = self:getAttribute(ITEM_ATTRIBUTE_DEFENSE)
    else
      item_data.defense = itemType:getDefense()
    end
    if self:getAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE) > 0 then
      item_data.extraDefense = self:getAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE)
    else
      item_data.extraDefense = itemType:getExtraDefense()
    end
  end

  item_data.weight = self:getWeight()
  return item_data
end

function ItemType:buildTooltip(count)
  if not count then
    count = 1
  end

  local item_data = {
    clientId = self:getClientId(),
    count = count,
    itemName = self:getName()
  }
  local itemTier = getItemTierById(self:getId())
  if itemTier then
    item_data.tier = itemTier
  end

  if self:getDescription():len() > 0 then
    item_data.desc = self:getDescription()
  end

  if self:getRequiredLevel() >= 1 then
    item_data.reqLvl = self:getRequiredLevel()
  end

  local implicit = {}

  if self:getElementType() ~= COMBAT_NONE and combatTypeNames[self:getElementType()] then
    implicit.eleDmg = "Attack +" .. self:getElementDamage() .. " " .. combatTypeNames[self:getElementType()]
  end

  local allprot = self:getAbsorbPercent(0)

  if allprot ~= 0 then
    for i = 0, COMBAT_COUNT - 1 do
      if self:getAbsorbPercent(i) ~= allprot then
        allprot = 0
        break
      end
    end
  end

  if allprot == 0 then
    for i = 0, COMBAT_COUNT - 1 do
      if self:getAbsorbPercent(i) ~= 0 then
        local combatType = bit.lshift(1, i)
        if combatType ~= COMBAT_UNDEFINEDDAMAGE then
          implicit[combatShortNames[combatType]] = self:getAbsorbPercent(i)
        end
      end
    end
  else
    implicit.a_all = allprot
  end

  for key, value in pairs(specialSkills) do
    local s = self:getSpecialSkill(key)
    if s and s >= 1 then
      implicit[value] = s
    end
  end

  for key, value in pairs(skills) do
    local s = self:getSkill(key)
    if s and s >= 1 then
      implicit[value] = s
    end
  end

  for key, value in pairs(stats) do
    local s = self:getStat(key)
    if s and s >= 1 then
      implicit[value] = s
    end
  end

  for key, value in pairs(statsPercent) do
    local s = self:getStatPercent(key)
    if s and s >= 1 then
      implicit[value] = s - 100
    end
  end

  local healthGain = self:getHealthGain()
  if healthGain and healthGain > 0 then
    implicit.hpgain = healthGain
  end

  local healthTicks = self:getHealthTicks()
  if healthTicks and healthTicks > 0 then
    implicit.hpticks = healthTicks
  end

  local manaGain = self:getManaGain()
  if manaGain and manaGain > 0 then
    implicit.mpgain = manaGain
  end

  local manaTicks = self:getManaTicks()
  if manaTicks and manaTicks > 0 then
    implicit.mpticks = manaTicks
  end

  local speed = self:getSpeed()
  if speed and speed > 0 then
    implicit.speed = speed
  end

  if self:isContainer() then
    implicit.cap = "Capacity " .. self:getCapacity()
  end

  if next(implicit) ~= nil then
    item_data.imp = implicit
  end

  item_data.itemType = formatItemType(self)
  if self:getArmor() > 0 then
    item_data.armor = self:getArmor()
  elseif self:getShootRange() > 1 then
    item_data.attack = self:getAttack()
    item_data.hitChance = self:getHitChance()
    item_data.shootRange = self:getShootRange()
  elseif self:getAttack() > 0 then
    item_data.attack = self:getAttack()
    item_data.defense = self:getDefense()
    item_data.extraDefense = self:getExtraDefense()
  elseif self:getDefense() > 0 then
    item_data.defense = self:getDefense()
    item_data.extraDefense = self:getExtraDefense()
  end

  item_data.weight = self:getWeight() * item_data.count
  return item_data
end

local ExtraStatsMoveEvent = EventCallback

function ExtraStatsMoveEvent.onMoveItem(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
  if not player then
    return true
  end

  if isEquipmentPosition(fromPosition) or isEquipmentPosition(toPosition) then
    addEvent(function(playerId)
      local onlinePlayer = Player(playerId)
      if onlinePlayer and onlinePlayer.sendExtraStatsSnapshot then
        onlinePlayer:sendExtraStatsSnapshot()
      end
    end, 100, player:getId())
  end

  return true
end

ExtraStatsMoveEvent:register()

function formatItemType(itemType)
  local weaponType = itemType:getWeaponType()
  local function normalizeSlotPosition(slotPosition)
    return bit.band(slotPosition, bit.bnot(bit.bor(SLOTP_LEFT, SLOTP_RIGHT)))
  end

  if weaponType ~= WEAPON_SHIELD then
    local slotPosition = normalizeSlotPosition(itemType:getSlotPosition())

    if slotPosition == SLOTP_TWO_HAND and weaponType == WEAPON_SWORD then
      return "Two-Handed Sword"
    elseif slotPosition == SLOTP_TWO_HAND and weaponType == WEAPON_CLUB then
      return "Two-Handed Club"
    elseif slotPosition == SLOTP_TWO_HAND and weaponType == WEAPON_AXE then
      return "Two-Handed Axe"
    elseif weaponType == WEAPON_SWORD then
      return "Sword"
    elseif weaponType == WEAPON_CLUB then
      return "Club"
    elseif weaponType == WEAPON_AXE then
      return "Axe"
    elseif weaponType == WEAPON_DISTANCE then
      return "Distance"
    elseif weaponType == WEAPON_WAND then
      return "Wand"
    elseif slotPosition == SLOTP_HEAD then
      return "Helmet"
    elseif slotPosition == SLOTP_NECKLACE then
      return "Necklace"
    elseif slotPosition == SLOTP_ARMOR then
      return "Armor"
    elseif slotPosition == SLOTP_LEGS then
      return "Legs"
    elseif slotPosition == SLOTP_FEET then
      return "Boots"
    elseif slotPosition == SLOTP_RING then
      return "Ring"
    elseif slotPosition == SLOTP_QUIVER then
      return "Quiver"
    elseif slotPosition == SLOTP_AMMO and itemType:getAmmoType() > 0 then
      return "Ammunition"
    elseif itemType:isRune() then
      return "Rune"
    elseif itemType:isContainer() then
      return "Container"
    elseif itemType:isFluidContainer() then
      return "Potion"
    elseif itemType:isUseable() then
      return "Usable"
    end
  else
    return "Shield"
  end

  return "Common"
end

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()
