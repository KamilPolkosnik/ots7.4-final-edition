local UPGRADE_SYSTEM_VERSION = "3.0.3"
print(">> Loaded Upgrade System v" .. UPGRADE_SYSTEM_VERSION)

US_CONDITIONS = {}
US_BUFFS = {}

local US_SUBID = {}
local US_ITEM_TIER_BY_ID = {}
local US_FIXED_LEECH_PROC_CHANCE = 25
local US_ITEM_TIER_CUSTOM_ATTRIBUTE = "item_tier"
local us_GetItemTier

local function us_CountTable(data)
    local count = 0
    for _ in pairs(data) do
        count = count + 1
    end
    return count
end

local function us_GetChanceForLevel(chanceByLevel, level)
    if type(chanceByLevel) ~= "table" then
        return nil
    end

    local normalizedLevel = tonumber(level)
    if not normalizedLevel then
        return nil
    end
    normalizedLevel = math.floor(normalizedLevel)

    local direct = tonumber(chanceByLevel[normalizedLevel])
    if direct then
        return direct
    end

    local fallbackLevel = nil
    local fallbackValue = nil
    for key, value in pairs(chanceByLevel) do
        local keyLevel = tonumber(key)
        local numericValue = tonumber(value)
        if keyLevel and numericValue and (not fallbackLevel or keyLevel > fallbackLevel) then
            fallbackLevel = keyLevel
            fallbackValue = numericValue
        end
    end

    return fallbackValue
end

local function us_GetTierRange(tier)
    tier = tonumber(tier)
    if not tier then
        return nil
    end

    tier = math.floor(tier)

    local minTier = tonumber(US_CONFIG and US_CONFIG.ITEM_TIER_MIN) or 1
    local maxTier = tonumber(US_CONFIG and US_CONFIG.ITEM_TIER_MAX) or 25
    local levelStep = tonumber(US_CONFIG and US_CONFIG.ITEM_LEVEL_PER_TIER) or 25
    local firstTierMin = tonumber(US_CONFIG and US_CONFIG.ITEM_LEVEL_FIRST_TIER_MIN) or 1

    minTier = math.max(1, math.floor(minTier))
    maxTier = math.max(minTier, math.floor(maxTier))
    levelStep = math.max(1, math.floor(levelStep))
    firstTierMin = math.max(1, math.floor(firstTierMin))

    if tier < minTier or tier > maxTier then
        return nil
    end

    -- Optional per-tier overrides kept for backward compatibility.
    local customRange = US_CONFIG and US_CONFIG.ITEM_LEVEL_TIERS and US_CONFIG.ITEM_LEVEL_TIERS[tier]
    if customRange then
        local customMin = tonumber(customRange.min)
        local customMax = tonumber(customRange.max)
        if customMin and customMax then
            customMin = math.max(1, math.floor(customMin))
            customMax = math.max(customMin, math.floor(customMax))
            return {min = customMin, max = customMax}
        end
    end

    local minLevel = (tier == minTier) and firstTierMin or ((tier - 1) * levelStep)
    local maxLevel = tier * levelStep
    minLevel = math.max(1, minLevel)
    maxLevel = math.max(minLevel, maxLevel)

    return {min = minLevel, max = maxLevel}
end

local function us_ParseItemTierFromLine(line)
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
    if not us_GetTierRange(tier) then
        return nil
    end

    return tier
end

local function us_LoadItemTiersFromItemsXml()
    if not US_CONFIG.USE_ITEM_XML_TIERS then
        US_ITEM_TIER_BY_ID = {}
        return
    end

    local path = "data/items/items.xml"
    local file = io.open(path, "r")
    if not file then
        print("[UpgradeSystem] Unable to load item tiers from " .. path)
        US_ITEM_TIER_BY_ID = {}
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
            local parsedTier = us_ParseItemTierFromLine(line)
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
    US_ITEM_TIER_BY_ID = tierMap
    print(string.format("[UpgradeSystem] Loaded %d item tiers from %s", us_CountTable(tierMap), path))
end

local function us_GetTieredRollLevel(item)
    if not US_CONFIG.USE_ITEM_XML_TIERS then
        return nil
    end

    local tier = us_GetItemTier(item)
    if not tier then
        return nil
    end

    local range = us_GetTierRange(tier)
    if not range then
        return nil
    end

    local minLevel = tonumber(range.min) or 1
    local maxLevel = tonumber(range.max) or minLevel

    minLevel = math.max(1, math.floor(minLevel))
    maxLevel = math.max(minLevel, math.floor(maxLevel))

    return math.random(minLevel, maxLevel)
end

us_GetItemTier = function(item)
    if not item then
        return nil
    end

    local customTier = tonumber(item:getCustomAttribute(US_ITEM_TIER_CUSTOM_ATTRIBUTE))
    if customTier then
        customTier = math.floor(customTier)
        if us_GetTierRange(customTier) then
            return customTier
        end
    end

    return US_ITEM_TIER_BY_ID[item:getId()]
end

local function us_SetItemTier(item, tier)
    if not item or not item.isItem or not item:isItem() then
        return false
    end

    local normalizedTier = tonumber(tier)
    if not normalizedTier then
        return false
    end

    normalizedTier = math.floor(normalizedTier)
    if not us_GetTierRange(normalizedTier) then
        return false
    end

    local baseTier = US_ITEM_TIER_BY_ID[item:getId()]
    if baseTier and normalizedTier == baseTier then
        item:removeCustomAttribute(US_ITEM_TIER_CUSTOM_ATTRIBUTE)
    else
        item:setCustomAttribute(US_ITEM_TIER_CUSTOM_ATTRIBUTE, normalizedTier)
    end

    return true
end

local function us_GetMaxUpgradeLevel(item)
    local fallbackMax = tonumber(US_CONFIG and US_CONFIG.MAX_UPGRADE_LEVEL) or 9
    fallbackMax = math.max(1, math.floor(fallbackMax))

    local perTierMultiplier = tonumber(US_CONFIG and US_CONFIG.MAX_UPGRADE_LEVEL_PER_TIER) or 0
    if perTierMultiplier <= 0 then
        return fallbackMax
    end

    local tier = us_GetItemTier(item)
    if not tier then
        return fallbackMax
    end

    local dynamicMax = math.floor(tier * perTierMultiplier)
    if dynamicMax < 1 then
        return fallbackMax
    end

    return dynamicMax
end

local function us_GetTierStatBaseLevel(item)
    if not US_CONFIG.ITEM_LEVEL_STAT_TIER_BASE then
        return 0
    end

    local tier = us_GetItemTier(item)
    if not tier then
        return 0
    end

    local range = us_GetTierRange(tier)
    if not range then
        return 0
    end

    local baseLevel = tonumber(range.max) or tonumber(range.min) or 0
    return math.max(0, math.floor(baseLevel))
end

local function us_GetEffectiveItemLevelForStats(item, itemLevel)
    local level = tonumber(itemLevel) or 0
    level = math.max(0, math.floor(level))
    local baseLevel = us_GetTierStatBaseLevel(item)

    if level <= baseLevel then
        return 0
    end

    return level - baseLevel
end

local function us_GetItemLevelGainFromUpgrade(item, levelsDelta)
    local delta = tonumber(levelsDelta) or 0
    if delta <= 0 then
        return 0
    end

    local rarity = COMMON
    if item and item.getRarityId then
        rarity = item:getRarityId()
    end

    local gainByRarity = US_CONFIG.UPGRADE_ITEM_LEVEL_BY_RARITY or {}
    local gainPerUpgrade = tonumber(gainByRarity[rarity]) or tonumber(US_CONFIG.ITEM_LEVEL_PER_UPGRADE) or 1
    gainPerUpgrade = math.max(0, math.floor(gainPerUpgrade))

    return delta * gainPerUpgrade
end

local function us_ToItem(value)
    if not value then
        return nil
    end

    local valueType = type(value)
    if valueType == "number" then
        return Item(value)
    end

    if valueType == "userdata" and value.isItem and value:isItem() then
        return value
    end

    return nil
end

function us_IsEnchantAllowedForItem(attr, item, usItemType)
    if not attr or not item or not item.isItem or not item:isItem() then
        return false
    end

    if usItemType == nil and item.getItemType then
        usItemType = item:getItemType()
    end

    local typeMask = tonumber(attr.itemType) or 0
    local maskAllowed = false
    if typeMask > 0 and usItemType and bit.band(usItemType, typeMask) ~= 0 then
        maskAllowed = true
    end

    local idAllowed = false
    if type(attr.allowedItemIds) == "table" then
        local itemId = item:getId()
        for _, allowedId in ipairs(attr.allowedItemIds) do
            if tonumber(allowedId) == itemId then
                idAllowed = true
                break
            end
        end
    end

    -- Allowed when either mask matches or explicit item id is listed.
    if not maskAllowed and not idAllowed then
        return false
    end

    local itemType = item:getType()
    if not itemType then
        return false
    end

    local weaponType = itemType:getWeaponType()
    if type(attr.allowedWeaponTypes) == "table" and weaponType > 0 then
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

    if type(attr.allowedAmmoTypes) == "table" and weaponType > 0 then
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

function Item.ensureInitialTierLevel(self, force)
    if not self or not self:isItem() then
        return false
    end

    local itemType = self:getType()
    if not itemType or not itemType:canHaveItemLevel() then
        return false
    end

    if not force and self:getItemLevel() > 0 then
        return false
    end

    local tieredLevel = us_GetTieredRollLevel(self)
    if not tieredLevel then
        return false
    end

    self:setItemLevel(math.min(US_CONFIG.MAX_ITEM_LEVEL, tieredLevel), false)
    return true
end

local function us_ApplyInitialTierLevel(value, force)
    local item = us_ToItem(value)
    if item then
        item:ensureInitialTierLevel(force)
    end
end

local function us_ApplyInitialTierLevelToResult(result)
    if not result then
        return
    end

    if type(result) == "table" then
        for _, entry in ipairs(result) do
            us_ApplyInitialTierLevel(entry, false)
        end
        return
    end

    us_ApplyInitialTierLevel(result, false)
end

local function us_InstallItemLevelWrappers()
    if rawget(_G, "US_ITEMLEVEL_WRAPPERS_INSTALLED") then
        return
    end
    _G.US_ITEMLEVEL_WRAPPERS_INSTALLED = true

    if type(Player) == "table" and type(Player.addItem) == "function" then
        local oldPlayerAddItem = Player.addItem
        Player.addItem = function(self, ...)
            local result = oldPlayerAddItem(self, ...)
            us_ApplyInitialTierLevelToResult(result)
            return result
        end
    end

    if type(Player) == "table" and type(Player.addItemEx) == "function" then
        local oldPlayerAddItemEx = Player.addItemEx
        Player.addItemEx = function(self, item, ...)
            us_ApplyInitialTierLevel(item, false)
            return oldPlayerAddItemEx(self, item, ...)
        end
    end

    if type(Container) == "table" and type(Container.addItem) == "function" then
        local oldContainerAddItem = Container.addItem
        Container.addItem = function(self, ...)
            local result = oldContainerAddItem(self, ...)
            us_ApplyInitialTierLevelToResult(result)
            return result
        end
    end

    if type(Container) == "table" and type(Container.addItemEx) == "function" then
        local oldContainerAddItemEx = Container.addItemEx
        Container.addItemEx = function(self, item, ...)
            us_ApplyInitialTierLevel(item, false)
            return oldContainerAddItemEx(self, item, ...)
        end
    end

    if type(Game) == "table" and type(Game.createItem) == "function" then
        local oldGameCreateItem = Game.createItem
        Game.createItem = function(...)
            local result = oldGameCreateItem(...)
            us_ApplyInitialTierLevelToResult(result)
            return result
        end
    end

    if type(doPlayerAddItem) == "function" then
        local oldDoPlayerAddItem = doPlayerAddItem
        doPlayerAddItem = function(...)
            local result = oldDoPlayerAddItem(...)
            us_ApplyInitialTierLevelToResult(result)
            return result
        end
    end

    if type(doAddContainerItem) == "function" then
        local oldDoAddContainerItem = doAddContainerItem
        doAddContainerItem = function(...)
            local result = oldDoAddContainerItem(...)
            us_ApplyInitialTierLevelToResult(result)
            return result
        end
    end
end

if US_CONFIG then
    us_LoadItemTiersFromItemsXml()
    us_InstallItemLevelWrappers()
else
    print("[UpgradeSystem] US_CONFIG missing while loading item tiers; skipping items.xml tier map.")
end

local TargetCombatEvent = EventCallback
TargetCombatEvent.onTargetCombat = function(creature, target)
    target:registerEvent("UpgradeSystemHealth")
    target:registerEvent("UpgradeSystemDeath")
    return RETURNVALUE_NOERROR
end
TargetCombatEvent:register()

local LoginEvent = CreatureEvent("UpgradeSystemLogin")

function LoginEvent.onLogin(player)
    us_onLogin(player)
    return true
end

local HealthChangeEvent = CreatureEvent("UpgradeSystemHealth")
local ManaChangeEvent = CreatureEvent("UpgradeSystemMana")
local DeathEvent = CreatureEvent("UpgradeSystemDeath")
local KillEvent = CreatureEvent("UpgradeSystemKill")
local PrepareDeathEvent = CreatureEvent("UpgradeSystemPD")

function us_onEquip(cid, iuid, slot)
    local player = Player(cid)
    if not player:getSlotItem(slot) then
        return
    end
    iuid = iuid + 1
    local slotUid = player:getSlotItem(slot):getUniqueId()
    if iuid ~= slotUid then
        return
    end
    local item = Item(iuid)
    if player and item then
        local maxHP = player:getMaxHealth()
        local maxMP = player:getMaxMana()
        local newBonuses = item:getBonusAttributes()
        if not newBonuses then
            return
        end

        for i = 1, #newBonuses do
            local value = newBonuses[i]
            local bonusId = value[1]
            local bonusValue = value[2]
            local attr = US_ENCHANTMENTS[bonusId]
            if attr then
                if attr.combatType == US_TYPES.CONDITION then
                    if not US_CONDITIONS[bonusId] then
                        US_CONDITIONS[bonusId] = {}
                    end
                    local itemId = item:getId()
                    if not US_CONDITIONS[bonusId][bonusValue] then
                        US_CONDITIONS[bonusId][bonusValue] = {}
                    end
                    if not US_CONDITIONS[bonusId][bonusValue][itemId] then
                        US_CONDITIONS[bonusId][bonusValue][itemId] = Condition(attr.condition)
                        if attr.condition ~= CONDITION_MANASHIELD then
                            US_CONDITIONS[bonusId][bonusValue][itemId]:setParameter(CONDITION_PARAM_SUBID, 1000 + player:getNextSubId(slot, i))
                            US_CONDITIONS[bonusId][bonusValue][itemId]:setParameter(attr.param, attr.percentage == true and 100 + bonusValue or bonusValue)
                            US_CONDITIONS[bonusId][bonusValue][itemId]:setParameter(CONDITION_PARAM_TICKS, -1)
                        else
                            US_CONDITIONS[bonusId][bonusValue][itemId]:setParameter(CONDITION_PARAM_TICKS, 86400000)
                        end
                        US_CONDITIONS[bonusId][bonusValue][itemId]:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
                        player:addCondition(US_CONDITIONS[bonusId][bonusValue][itemId])
                        if attr == BONUS_TYPE_MAXHP then
                            if player:getHealth() == maxHP then
                                player:addHealth(player:getMaxHealth())
                            end
                        end
                        if attr == BONUS_TYPE_MAXMP then
                            if player:getMana() == maxMP then
                                player:addMana(player:getMaxMana())
                            end
                        end
                    else
                        player:addCondition(US_CONDITIONS[bonusId][bonusValue][itemId])
                        if attr.param == CONDITION_PARAM_STAT_MAXHITPOINTS then
                            if player:getHealth() == maxHP then
                                player:addHealth(player:getMaxHealth())
                            end
                        end
                        if attr.param == CONDITION_PARAM_STAT_MAXMANAPOINTS then
                            if player:getMana() == maxMP then
                                player:addMana(player:getMaxMana())
                            end
                        end
                    end
                end
            end
        end
    end
end

local MoveItemEvent = EventCallback
MoveItemEvent.onMoveItem = function(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    if not item:getType():isUpgradable() and not item:getType():canHaveItemLevel() or toPosition.y == CONST_SLOT_AMMO then
        return true
    end

    if not item:getType():usesSlot(toPosition.y) then
        return true
    end

   

    if US_CONFIG.REQUIRE_LEVEL == true then
        if player:getLevel() < item:getItemLevel() and not item:isLimitless() then
            if toPosition.y <= CONST_SLOT_AMMO and toPosition.y ~= CONST_SLOT_BACKPACK then
                player:sendTextMessage(MESSAGE_STATUS_SMALL, "You need higher level to equip that item.")
                return false
            end
        end
    end

    if toPosition.y <= CONST_SLOT_AMMO then
        if toPosition.y ~= CONST_SLOT_BACKPACK then
            if fromPosition.y >= 64 or fromPosition.x ~= CONTAINER_POSITION then
                -- remove old
                local oldItem = player:getSlotItem(toPosition.y)
                if oldItem then
                    if oldItem:getType():isUpgradable() then
                        local oldBonuses = oldItem:getBonusAttributes()
                        if oldBonuses then
                            local itemId = oldItem:getId()
                            for key, value in pairs(oldBonuses) do
                                local attr = US_ENCHANTMENTS[value[1]]
                                if attr then
                                    if attr.combatType == US_TYPES.CONDITION then
                                        if US_CONDITIONS[value[1]] and US_CONDITIONS[value[1]][value[2]] and US_CONDITIONS[value[1]][value[2]][itemId] then
                                            if US_CONDITIONS[value[1]][value[2]][itemId]:getType() ~= CONDITION_MANASHIELD then
                                                player:removeCondition(
                                                    US_CONDITIONS[value[1]][value[2]][itemId]:getType(),
                                                    CONDITIONID_COMBAT,
                                                    US_CONDITIONS[value[1]][value[2]][itemId]:getSubId()
                                                )
                                            else
                                                player:removeCondition(US_CONDITIONS[value[1]][value[2]][itemId]:getType(), CONDITIONID_COMBAT)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                -- apply new
                if item:getType():isUpgradable() then
                    local newBonuses = item:getBonusAttributes()
                    if newBonuses then
                        addEvent(us_onEquip, 10, player:getId(), item:getUniqueId(), toPosition.y)
                    end
                end
            end
        end
    end

    return true
end
MoveItemEvent:register()

local ItemMovedEvent = EventCallback
ItemMovedEvent.onItemMoved = function(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    local itemType = item:getType()

    -- Catch items created by C++ paths (e.g. behavior NPC shops) that bypass Lua addItem wrappers.
    if itemType and itemType:canHaveItemLevel() and item:getItemLevel() <= 0 then
        if item.ensureInitialTierLevel then
            item:ensureInitialTierLevel(false)
        end
        if item:getItemLevel() <= 0 and item.setItemLevel then
            item:setItemLevel(1, false)
        end
    end

    if not itemType:isUpgradable() then
        return
    end
    if toPosition.y <= CONST_SLOT_AMMO and toPosition.y ~= CONST_SLOT_BACKPACK then
        return
    end
    if fromPosition.y >= 64 and toPosition.y >= 64 then
        return
    end
    if fromPosition.y >= 64 and toPosition.y == CONST_SLOT_BACKPACK then
        return
    end

    local bonuses = item:getBonusAttributes()
    if bonuses then
        local itemId = item:getId()
        for i = 1, #bonuses do
            local value = bonuses[i]
            local bonusId = value[1]
            local bonusValue = value[2]
            local attr = US_ENCHANTMENTS[bonusId]
            if attr then
                if attr.combatType == US_TYPES.CONDITION then
                    if US_CONDITIONS[bonusId] and US_CONDITIONS[bonusId][bonusValue] and US_CONDITIONS[bonusId][bonusValue][itemId] then
                        if US_CONDITIONS[bonusId][bonusValue][itemId]:getType() ~= CONDITION_MANASHIELD then
                            player:removeCondition(
                                US_CONDITIONS[bonusId][bonusValue][itemId]:getType(),
                                CONDITIONID_COMBAT,
                                US_CONDITIONS[bonusId][bonusValue][itemId]:getSubId()
                            )
                        else
                            player:removeCondition(US_CONDITIONS[bonusId][bonusValue][itemId]:getType(), CONDITIONID_COMBAT)
                        end
                    end
                end
            end
        end
    end
end
ItemMovedEvent:register()

function us_onLogin(player)
    player:registerEvent("UpgradeSystemKill")
    player:registerEvent("UpgradeSystemHealth")
    player:registerEvent("UpgradeSystemMana")
    player:registerEvent("UpgradeSystemPD")

    local maxHP = player:getMaxHealth()
    local maxMP = player:getMaxMana()
    for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
        local item = player:getSlotItem(slot)
        if item then
            local newBonuses = item:getBonusAttributes()
            if newBonuses then
                local itemId = item:getId()
                for i = 1, #newBonuses do
                    local value = newBonuses[i]
                    local bonusId = value[1]
                    local bonusValue = value[2]
                    local attr = US_ENCHANTMENTS[bonusId]
                    if attr then
                        if attr.combatType == US_TYPES.CONDITION then
                            if not US_CONDITIONS[bonusId] then
                                US_CONDITIONS[bonusId] = {}
                            end
                            if not US_CONDITIONS[bonusId][bonusValue] then
                                US_CONDITIONS[bonusId][bonusValue] = {}
                            end
                            if not US_CONDITIONS[bonusId][bonusValue][itemId] then
                                US_CONDITIONS[bonusId][bonusValue][itemId] = Condition(attr.condition)
                                if attr.condition ~= CONDITION_MANASHIELD then
                                    US_CONDITIONS[bonusId][bonusValue][itemId]:setParameter(CONDITION_PARAM_SUBID, 1000 + player:getNextSubId(slot, i))
                                    US_CONDITIONS[bonusId][bonusValue][itemId]:setParameter(
                                        attr.param,
                                        attr.percentage == true and 100 + bonusValue or bonusValue
                                    )
                                    US_CONDITIONS[bonusId][bonusValue][itemId]:setParameter(CONDITION_PARAM_TICKS, -1)
                                else
                                    US_CONDITIONS[bonusId][bonusValue][itemId]:setParameter(CONDITION_PARAM_TICKS, 86400000)
                                end
                                US_CONDITIONS[bonusId][bonusValue][itemId]:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
                                player:addCondition(US_CONDITIONS[bonusId][bonusValue][itemId])
                                if attr == BONUS_TYPE_MAXHP then
                                    if player:getHealth() == maxHP then
                                        player:addHealth(player:getMaxHealth())
                                    end
                                end
                                if attr == BONUS_TYPE_MAXMP then
                                    if player:getMana() == maxMP then
                                        player:addMana(player:getMaxMana())
                                    end
                                end
                            else
                                player:addCondition(US_CONDITIONS[bonusId][bonusValue][itemId])
                                if attr.param == CONDITION_PARAM_STAT_MAXHITPOINTS then
                                    if player:getHealth() == maxHP then
                                        player:addHealth(player:getMaxHealth())
                                    end
                                end
                                if attr.param == CONDITION_PARAM_STAT_MAXMANAPOINTS then
                                    if player:getMana() == maxMP then
                                        player:addMana(player:getMaxMana())
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function ManaChangeEvent.onManaChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not creature or not attacker then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if creature:isPlayer() and creature:getParty() and attacker:isPlayer() and attacker:getParty() then
        if creature:getParty() == attacker:getParty() then
            return primaryDamage, primaryType, secondaryDamage, secondaryType
        end
    end

    if creature == attacker and primaryType ~= COMBAT_HEALING then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if origin == ORIGIN_CONDITION then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    return us_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
end

function HealthChangeEvent.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not creature or not attacker then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if creature:isPlayer() and creature:getParty() and attacker:isPlayer() and attacker:getParty() then
        if creature:getParty() == attacker:getParty() then
            return primaryDamage, primaryType, secondaryDamage, secondaryType
        end
    end

    if creature == attacker and primaryType ~= COMBAT_HEALING then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if origin == ORIGIN_CONDITION then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    return us_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
end

function us_onDamaged(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if primaryType == COMBAT_HEALING or secondaryType == COMBAT_HEALING then
        if attacker:isPlayer() then
            local primaryTotal = 0
            local secondaryTotal = 0
            for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
                local item = attacker:getSlotItem(slot)
                if item then
                    if item:getType():usesSlot(slot) or slot == CONST_SLOT_LEFT or slot == CONST_SLOT_RIGHT then
                        local values = item:getBonusAttributes()
                        if values then
                            for key, value in pairs(values) do
                                local attr = US_ENCHANTMENTS[value[1]]
                                if attr then
                                    if attr.name == "Increased Healing" then
                                        if primaryType == COMBAT_HEALING then
                                            primaryTotal = primaryTotal + value[2]
                                        end
                                        if secondaryType == COMBAT_HEALING then
                                            secondaryTotal = secondaryTotal + value[2]
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if primaryType == COMBAT_HEALING then
                primaryDamage = math.floor(primaryDamage + (primaryDamage * primaryTotal / 100))
            end
            if secondaryType == COMBAT_HEALING then
                secondaryDamage = math.floor(secondaryDamage + (secondaryDamage * secondaryTotal / 100))
            end
        end
        if creature:isPlayer() then
            local primaryTotal = 0
            local secondaryTotal = 0
            for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
                local item = creature:getSlotItem(slot)
                if item then
                    if item:getType():usesSlot(slot) or slot == CONST_SLOT_LEFT or slot == CONST_SLOT_RIGHT then
                        local values = item:getBonusAttributes()
                        if values then
                            for key, value in pairs(values) do
                                local attr = US_ENCHANTMENTS[value[1]]
                                if attr then
                                    if attr.name == "Increased Healing" then
                                        if primaryDamage > 0 then
                                            primaryTotal = primaryTotal + value[2]
                                        end
                                        if secondaryDamage > 0 then
                                            secondaryTotal = secondaryTotal + value[2]
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if primaryTotal > 0 then
                primaryDamage = math.floor(primaryDamage + (primaryDamage * primaryTotal / 100))
            end
            if secondaryTotal > 0 then
                secondaryDamage = math.floor(secondaryDamage + (secondaryDamage * secondaryTotal / 100))
            end
        end
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    if attacker:isPlayer() then
        local pid = attacker:getId()
        if US_BUFFS[pid] then
            if US_BUFFS[pid][1] then
                if primaryDamage ~= 0 then
                    primaryDamage = primaryDamage + (primaryDamage * US_BUFFS[pid][1].value / 100)
                end
                if secondaryDamage ~= 0 then
                    secondaryDamage = secondaryDamage + (secondaryDamage * US_BUFFS[pid][1].value / 100)
                end
            end
        end
        local doubleDamageTotal = 0
        local primaryDamageTotal = 0
        local secondaryDamageTotal = 0
        local lifeStealTotal = 0
        local manaStealTotal = 0
        for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
            local item = attacker:getSlotItem(slot)
            if item then
                if item:getType():usesSlot(slot) or slot == CONST_SLOT_LEFT or slot == CONST_SLOT_RIGHT then
                    if item:getId() == 2390 then
                        doubleDamageTotal = math.max(doubleDamageTotal, 100)
                    end
                    local values = item:getBonusAttributes()
                    if values then
                        for key, value in pairs(values) do
                            local attr = US_ENCHANTMENTS[value[1]]
                            if attr then
                                if attr.combatType and attr.combatType ~= US_TYPES.CONDITION then
                                    if attr.combatType == US_TYPES.TRIGGER then
                                        if attr.triggerType == US_TRIGGERS.ATTACK then
                                            attr.execute(attacker, creature, value[2])
                                        end
                                    elseif attr.name == "Double Damage" then
                                        doubleDamageTotal = doubleDamageTotal + value[2]
                                    else
                                        if attr.combatDamage then
                                            if (attr.combatDamage % (primaryType + primaryType) >= primaryType) == true then
                                                if attr.combatType == US_TYPES.OFFENSIVE then
                                                    primaryDamageTotal = primaryDamageTotal + value[2]
                                                end
                                            end
                                            if (attr.combatDamage % (secondaryType + secondaryType) >= secondaryType) == true then
                                                if attr.combatType == US_TYPES.OFFENSIVE then
                                                    secondaryDamageTotal = secondaryDamageTotal + value[2]
                                                end
                                            end
                                        end

                                        if attr.name == "Life Steal" then
                                            lifeStealTotal = lifeStealTotal + value[2]
                                        end

                                        if attr.name == "Mana Steal" then
                                            manaStealTotal = manaStealTotal + value[2]
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if doubleDamageTotal > 0 then
            if math.random(100) < doubleDamageTotal then
                primaryDamage = primaryDamage * 2
                secondaryDamage = secondaryDamage * 2
                if creature and creature:isCreature() then
                    local pos = creature:getPosition()
                    pos:sendMagicEffect(CONST_ME_CRAPS)
                    creature:say("CRIT!", TALKTYPE_MONSTER_SAY)
                end
            end
        end

        if primaryDamageTotal > 0 then
            primaryDamage = math.floor(primaryDamage + (primaryDamage * primaryDamageTotal / 100))
        end

        if secondaryDamageTotal > 0 then
            secondaryDamage = math.floor(secondaryDamage + (secondaryDamage * secondaryDamageTotal / 100))
        end

        local damage = (primaryDamage + secondaryDamage)
        if damage < 0 then
            damage = damage * -1
        end

        if lifeStealTotal > 0 then
            if math.random(100) <= US_FIXED_LEECH_PROC_CHANCE then
                local lifeSteal = math.floor((damage * (lifeStealTotal / 100)))
                if lifeSteal > 0 then
                    attacker:addHealth(lifeSteal)
                end
            end
        end

        if manaStealTotal > 0 then
            if math.random(100) <= US_FIXED_LEECH_PROC_CHANCE then
                local manaSteal = math.floor((damage * (manaStealTotal / 100)))
                if manaSteal > 0 then
                    attacker:addMana(manaSteal)
                end
            end
        end
    end

    if creature:isPlayer() then
        local primaryDamageTotal = 0
        local secondaryDamageTotal = 0
        local dodgeTotal = 0
        local reflectTotal = 0
        for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
            local item = creature:getSlotItem(slot)
            if item then
                if item:getType():usesSlot(slot) or slot == CONST_SLOT_LEFT or slot == CONST_SLOT_RIGHT then
                    local values = item:getBonusAttributes()
                    if values then
                        for key, value in pairs(values) do
                            local attr = US_ENCHANTMENTS[value[1]]
                            if attr then
                                if attr.combatType and attr.combatType ~= US_TYPES.CONDITION then
                                    if attr.combatType == US_TYPES.TRIGGER then
                                        if attr.triggerType == US_TRIGGERS.HIT then
                                            attr.execute(creature, attacker, value[2])
                                        end
                                    else
                                        if attr.special == "DODGE" then
                                            dodgeTotal = dodgeTotal + value[2]
                                        elseif attr.special == "REFLECT" then
                                            reflectTotal = reflectTotal + value[2]
                                        elseif attr.combatDamage then
                                            if (attr.combatDamage % (primaryType + primaryType) >= primaryType) == true then
                                                if attr.combatType == US_TYPES.DEFENSIVE and creature:isPlayer() then
                                                    primaryDamageTotal = primaryDamageTotal + value[2]
                                                end
                                            end
                                            if (attr.combatDamage % (secondaryType + secondaryType) >= secondaryType) == true then
                                                if attr.combatType == US_TYPES.DEFENSIVE and creature:isPlayer() then
                                                    secondaryDamageTotal = secondaryDamageTotal + value[2]
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        local incomingBeforeReduction = math.abs(primaryDamage) + math.abs(secondaryDamage)

        if dodgeTotal > 0 and incomingBeforeReduction > 0 and primaryType ~= COMBAT_HEALING then
            local dodgeChance = math.max(0, math.min(100, dodgeTotal))
            if math.random(100) <= dodgeChance then
                primaryDamage = 0
                secondaryDamage = 0
                creature:getPosition():sendMagicEffect(CONST_ME_POFF)
                creature:say("DODGE!", TALKTYPE_MONSTER_SAY)
                return primaryDamage, primaryType, secondaryDamage, secondaryType
            end
        end

        if primaryDamageTotal > 0 then
            primaryDamage = math.floor(primaryDamage - (primaryDamage * primaryDamageTotal / 100))
        end
        if secondaryDamageTotal > 0 then
            secondaryDamage = math.floor(secondaryDamage - (secondaryDamage * secondaryDamageTotal / 100))
        end

        local incomingAfterReduction = math.abs(primaryDamage) + math.abs(secondaryDamage)

        if reflectTotal > 0 and incomingAfterReduction > 0 and attacker and attacker:isCreature() and attacker ~= creature and primaryType ~= COMBAT_HEALING then
            local reflectPercent = math.max(0, math.min(100, reflectTotal))
            local reflectDamage = math.floor(incomingAfterReduction * (reflectPercent / 100))
            if reflectDamage > 0 then
                doTargetCombatHealth(creature:getId(), attacker, COMBAT_PHYSICALDAMAGE, -reflectDamage, -reflectDamage, CONST_ME_HITAREA, ORIGIN_MELEE)
                if creature:isPlayer() then
                    creature:sendTextMessage(MESSAGE_STATUS_SMALL, "Reflect dealt " .. reflectDamage .. " damage.")
                end
            end
        end
    end
    return primaryDamage, primaryType, secondaryDamage, secondaryType
end

function DeathEvent.onDeath(creature, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
    if not lasthitkiller or not creature:isMonster() or not corpse or corpse.itemid == 0 or not corpse:isContainer() then
        return true
    end
    if not lasthitkiller:isPlayer() and not lasthitkiller:getMaster() then
        return true
    end
    addEvent(
        us_CheckCorpse,
        10,
        creature:getType(),
        corpse:getPosition(),
        lasthitkiller:getMaster() and lasthitkiller:getMaster():getId() or lasthitkiller:getId()
    )
    return true
end

function KillEvent.onKill(player, target, lastHit)
    if not player or not player:isPlayer() or not target or not target:isMonster() then
        return
    end
    local center = target:getPosition()
    for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
        local item = player:getSlotItem(slot)
        if item then
            local values = item:getBonusAttributes()
            if values then
                for key, value in pairs(values) do
                    local attr = US_ENCHANTMENTS[value[1]]
                    if attr then
                        if attr.triggerType == US_TRIGGERS.KILL then
                            attr.execute(player, value[2], center, target, item)
                        end
                    end
                end
            end
        end
    end
end

function PrepareDeathEvent.onPrepareDeath(creature, killer)
    if creature:isPlayer() then
        for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
            local item = creature:getSlotItem(slot)
            if item then
                local values = item:getBonusAttributes()
                if values then
                    for key, value in pairs(values) do
                        local attr = US_ENCHANTMENTS[value[1]]
                        if attr then
                            if attr.name == "Revive on death" then
                                if math.random(100) < value[2] then
                                    creature:addHealth(creature:getMaxHealth())
                                    creature:addMana(creature:getMaxMana())
                                    creature:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
                                    creature:sendTextMessage(MESSAGE_INFO_DESCR, "You have been revived!")
                                    return false
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return true
end

local GainExperienceEvent = EventCallback
GainExperienceEvent.onGainExperience = function(player, source, exp, rawExp)
    for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
        local item = player:getSlotItem(slot)
        if item then
            local values = item:getBonusAttributes()
            if values then
                for key, value in pairs(values) do
                    local attr = US_ENCHANTMENTS[value[1]]
                    if attr then
                        if attr.name == "Experience" then
                            exp = exp + math.ceil(exp * value[2] / 100)
                        end
                    end
                end
            end
        end
    end
    return exp
end
GainExperienceEvent:register()

local function isEquipmentItem(item)
    local it = item:getType()
    if it:isContainer() then
        return false
    end
    if it:isWeapon() or it:isShield() or it:isBow() or it:isWand() then
        return true
    end
    if it:isHelmet() or it:isArmor() or it:isLegs() or it:isBoots() then
        return true
    end
    if it:isNecklace() or it:isRing() or it:isAmmo() or it:isTrinket() then
        return true
    end
    return false
end

local function moveEquipmentIntoBag(corpse)
    local items = corpse:getItems(true)
    if not items then
        return
    end

    local equipment = {}
    local bag = nil

    for _, item in ipairs(items) do
        if item:getId() == 1987 and item:isContainer() then
            if not bag then
                bag = item
            end
        elseif isEquipmentItem(item) then
            equipment[#equipment + 1] = item
        end
    end

    if #equipment == 0 then
        if bag and bag:getSize() == 0 then
            bag:remove()
        end
        return
    end

    if not bag then
        bag = corpse:addItem(1987, 1)
    end
    if not bag then
        return
    end

    for _, item in ipairs(equipment) do
        local parent = item:getParent()
        if parent == corpse then
            item:moveTo(bag)
        end
    end

    if bag:getSize() == 0 then
        bag:remove()
    end
end

function us_CheckCorpse(monsterType, corpsePosition, killerId)
    local killer = Player(killerId)
    local corpse = Tile(corpsePosition):getTopDownItem()
    if killer and killer:isPlayer() and corpse and corpse:isContainer() then
        for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
            local item = killer:getSlotItem(slot)
            if item then
                local values = item:getBonusAttributes()
                if values then
                    for key, value in pairs(values) do
                        local attr = US_ENCHANTMENTS[value[1]]
                        if attr then
                            if attr.name == "Additonal Gold" then
                                local cc, plat, gold = 0, 0, 0
                                for i = 0, corpse:getSize() do
                                    local item = corpse:getItem(i)
                                    if item then
                                        if item.itemid == 2160 then
                                            gold = gold + (item:getCount() * 10000)
                                        elseif item.itemid == 2152 then
                                            gold = gold + (item:getCount() * 100)
                                        elseif item.itemid == 2148 then
                                            gold = gold + item:getCount()
                                        end
                                    end
                                end

                                gold = math.floor(gold * value[2] / 100)

                                while gold >= 10000 do
                                    gold = gold / 10000
                                    cc = cc + 1
                                end

                                if cc > 0 then
                                    local crystalCoin = Game.createItem(2160, cc)
                                    corpse:addItemEx(crystalCoin)
                                end

                                while gold >= 100 do
                                    gold = gold / 100
                                    plat = plat + 1
                                end

                                if plat > 0 then
                                    local platinumCoin = Game.createItem(2152, plat)
                                    corpse:addItemEx(platinumCoin)
                                end

                                if gold > 0 then
                                    local goldCoin = Game.createItem(2148, gold)
                                    corpse:addItemEx(goldCoin)
                                end
                            end
                        end
                    end
                end
            end
        end
        local iLvl = monsterType:calculateItemLevel()
        if iLvl >= US_CONFIG.CRYSTAL_FOSSIL_DROP_LEVEL then
            if math.random(US_CONFIG.CRYSTAL_FOSSIL_DROP_CHANCE) == 1 then
                corpse:addItem(US_CONFIG.CRYSTAL_FOSSIL, 1)
                local specs = Game.getSpectators(corpsePosition, false, true, 9, 9, 8, 8)
                if #specs > 0 then
                    for i = 1, #specs do
                        local player = specs[i]
                        player:say("Crystal Fossil!", TALKTYPE_MONSTER_SAY, false, player, corpsePosition)
                    end
                end
            end
        end
        for i = 0, corpse:getCapacity() do
            local item = corpse:getItem(i)
            if item then
                local itemType = item:getType()
                if itemType then
                    if itemType:canHaveItemLevel() then
                        if not item:ensureInitialTierLevel(true) then
                            item:setItemLevel(math.min(US_CONFIG.MAX_ITEM_LEVEL, math.random(math.max(1, iLvl - 5), iLvl)), true)
                        end
                    end
                    if itemType:isUpgradable() then
                        if math.random(US_CONFIG.UNIDENTIFIED_DROP_CHANCE) == 1 then
                            item:unidentify()
                        else
                            item:rollRarity("drop")
                        end
                    end
                end
            end
        end
        -- Bag equipment after rarity roll so items keep their rolled rarity.
        moveEquipmentIntoBag(corpse)
    end
end

function us_RemoveBuff(pid, buffId, buffName)
    if US_BUFFS[pid] then
        US_BUFFS[pid][buffId] = nil
        local player = Player(pid)
        if player then
            player:sendTextMessage(MESSAGE_STATUS_WARNING, buffName .. " ended!")
        end
    end
end

local LookEvent = EventCallback
LookEvent.onLook = function(player, thing, position, distance, description)
    if thing:isItem() and thing.itemid == US_CONFIG.ITEM_MIND_CRYSTAL and thing:hasMemory() then
        for i = 4, 1, -1 do
            local enchant = thing:getBonusAttribute(i)
            if enchant then
                local attr = US_ENCHANTMENTS[enchant[1]]
                description = description:gsub(thing:getName() .. "%.", "%1\n" .. attr.format(enchant[2]))
            end
        end
    elseif thing:isItem() then
        -- Some NPC shop paths create items through C++ and bypass Lua addItem wrappers.
        -- Initialize Item Level when the owner looks at the item for the first time.
        local itemType = thing:getType()
        if itemType and itemType:canHaveItemLevel() and thing:getItemLevel() <= 0 then
            local topParent = thing:getTopParent()
            if topParent and topParent == player then
                if thing.ensureInitialTierLevel then
                    thing:ensureInitialTierLevel(false)
                end
                if thing:getItemLevel() <= 0 and thing.setItemLevel then
                    thing:setItemLevel(1, false)
                end
            end
        end

        if itemType:isUpgradable() then
            local upgrade = thing:getUpgradeLevel()
            local itemLevel = thing:getItemLevel()
            if upgrade > 0 then
                description = description:gsub(thing:getName(), "%1 +" .. upgrade)
            end
            if description:find("(%)%.?)") then
                description = description:gsub("(%)%.?)", "%1\nItem Level: " .. itemLevel)
            else
                if upgrade > 0 then
                    description = description:gsub("+" .. upgrade .. "%.", "%1\nItem Level: " .. itemLevel)
                else
                    description = description:gsub(thing:getName(), "%1\nItem Level: " .. itemLevel)
                end
            end
            if thing:isUnidentified() then
                description = description:gsub(thing:getName(), "unidentified %1")
                if thing:getArticle():len() > 0 and thing:getArticle() ~= "an" then
                    description = description:gsub("You see (" .. thing:getArticle() .. "%S?)", "You see an")
                end
            else
                description = description:gsub(thing:getName(), thing:getRarity().name .. " %1")
                if thing:getArticle():len() > 0 and thing:getRarity().name == "epic" and thing:getArticle() ~= "an" then
                    description = description:gsub("You see (" .. thing:getArticle() .. "%S?)", "You see an")
                end
                if thing:isUnique() then
                    description = description:gsub("Item Level: " .. itemLevel, thing:getUniqueName() .. "\n%1")
                end
                for i = thing:getMaxAttributes(), 1, -1 do
                    local enchant = thing:getBonusAttribute(i)
                    if enchant then
                        local attr = US_ENCHANTMENTS[enchant[1]]
                        description = description:gsub("Item Level: " .. itemLevel, "%1\n" .. attr.format(enchant[2]))
                    end
                end
            end
            if US_CONFIG.REQUIRE_LEVEL then
                if thing:isLimitless() then
                    if description:find("It can only be wielded properly by") then
                        description = description:gsub("It can only be wielded properly by (.-)%.", "Removed required Item Level to wear.")
                    else
                        description = description:gsub("It weighs", "Removed required Item Level to wear.\nIt weighs")
                    end
                else
                    if description:find("of level (%d+) or higher") then
                        for match in description:gmatch("of level (%d+) or higher") do
                            if tonumber(match) < itemLevel then
                                description = description:gsub("of level (%d+) or higher", "of level " .. itemLevel .. " or higher")
                            end
                        end
                    elseif description:find("It can only be wielded properly by") then
                        description =
                            description:gsub(
                            "It can only be wielded properly by (.+).\n",
                            "It can only be wielded properly by %1 of level " .. itemLevel .. " or higher.\n"
                        )
                    else
                        if description:find("It weighs") then
                            description =
                                description:gsub("It weighs", "It can only be wielded properly by players of level " .. itemLevel .. " or higher.\nIt weighs")
                        else
                            description = description .. "\nIt can only be wielded properly by players of level " .. itemLevel .. " or higher."
                        end
                    end
                end
            end
            if thing:isMirrored() then
                if description:find("It weighs") then
                    description = description:gsub("oz.(.+)", "oz.%1\nMirrored")
                else
                    description = description .. "\nMirrored"
                end
            end
        elseif itemType:canHaveItemLevel() then
            local itemLevel = thing:getItemLevel()
            if description:find("(%)%.?)") then
                description = description:gsub("(%)%.?)", "%1\nItem Level: " .. itemLevel)
            end
        end
    elseif thing:isPlayer() then
        local iLvl = 0
        for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
            local item = thing:getSlotItem(slot)
            if item then
                iLvl = iLvl + item:getItemLevel()
            end
        end
        description = description .. "\nTotal Item LeveL: " .. iLvl
    end
    return description
end
LookEvent:register(10)

local function us_GetAttributeRequiredLevel(attr)
    local requiredLevel = tonumber(attr.minLevel) or 0
    local baseLevel = tonumber(attr.BASE_ITEM_LEVEL or attr.baseItemLevel) or tonumber(US_CONFIG.BONUS_BASE_ITEM_LEVEL_DEFAULT) or 0
    if baseLevel > requiredLevel then
        requiredLevel = baseLevel
    end
    return math.max(0, math.floor(requiredLevel))
end

local function us_GetAttributeValue(itemLevel, attr)
    local tick = tonumber(attr.VALUE_TICK_EVERY or attr.valueTickEvery) or tonumber(US_CONFIG.BONUS_VALUE_TICK_EVERY_DEFAULT) or 0
    if tick > 0 then
        local baseLevel = us_GetAttributeRequiredLevel(attr)
        local level = math.max(0, math.floor(tonumber(itemLevel) or 0))
        local effectiveLevel = math.max(0, level - baseLevel)
        return 1 + math.floor(effectiveLevel / math.floor(tick))
    end

    if attr.VALUES_PER_LEVEL then
        return math.random(1, math.ceil(itemLevel * attr.VALUES_PER_LEVEL))
    end

    return 1
end

function Item.rollAttribute(self, player, itemType, weaponType, unidentify)
    if not itemType:isUpgradable() or self:isUnique() then
        return false
    end

    -- Debug: Print information about the rolling process
    print("Rolling attributes for " .. (unidentify and "unidentified" or "identified") .. " item.")

    local attrIds = {}
    local item_level = self:getItemLevel()
    if unidentify then
        if US_CONFIG.IDENTIFY_UPGRADE_LEVEL then
            local upgrade_level = 1
            local maxUpgradeLevel = us_GetMaxUpgradeLevel(self)
            for i = maxUpgradeLevel, 1, -1 do
                if i >= US_CONFIG.UPGRADE_LEVEL_DESTROY then
                    local destroyChance = us_GetChanceForLevel(US_CONFIG.UPGRADE_DESTROY_CHANCE, i) or 0
                    if math.random(100) <= destroyChance then
                        upgrade_level = i
                        break
                    end
                else
                    local successChance = us_GetChanceForLevel(US_CONFIG.UPGRADE_SUCCESS_CHANCE, i) or 0
                    if math.random(100) <= successChance then
                        upgrade_level = i
                        break
                    end
                end
            end
            self:setUpgradeLevel(upgrade_level)
        end
        local slots = math.random(1, self:getMaxAttributes())
        print("Rolling attributes for " .. slots .. " slots.")
        local usItemType = self:getItemType()
        for i = 1, slots do
            local attrId = math.random(1, #US_ENCHANTMENTS)
            local attr = US_ENCHANTMENTS[attrId]
            while isInArray(attrIds, attrId) or item_level < us_GetAttributeRequiredLevel(attr) or not us_IsEnchantAllowedForItem(attr, self, usItemType) or
                attr.chance and math.random(100) >= attr.chance do
                attrId = math.random(1, #US_ENCHANTMENTS)
                attr = US_ENCHANTMENTS[attrId]
            end
            table.insert(attrIds, attrId)
            local value = us_GetAttributeValue(item_level, attr)
            print("Rolled attribute: " .. attrId .. " (" .. attr.name .. "), Value: " .. value)
            self:setCustomAttribute("Slot" .. i, attrId .. "|" .. value)
        end

        -- Debug: Print message if only one slot is used for rolling attributes
        if slots == 1 then
            print("Only one slot used for rolling attributes.")
        end

        return true
    else
        local bonuses = self:getBonusAttributes()
        if bonuses then
            if #bonuses >= self:getMaxAttributes() then
                player:sendTextMessage(MESSAGE_STATUS_WARNING, "Max number of bonuses reached!")
                return false
            end
            for v, k in pairs(bonuses) do
                table.insert(attrIds, k[1])
            end
        end
        local usItemType = self:getItemType()
        local attrId = math.random(1, #US_ENCHANTMENTS)
        local attr = US_ENCHANTMENTS[attrId]
        while isInArray(attrIds, attrId) or item_level < us_GetAttributeRequiredLevel(attr) or not us_IsEnchantAllowedForItem(attr, self, usItemType) or
            attr.chance and math.random(100) >= attr.chance do
            attrId = math.random(1, #US_ENCHANTMENTS)
            attr = US_ENCHANTMENTS[attrId]
        end
        local value = us_GetAttributeValue(item_level, attr)
        print("Rolled attribute: " .. attrId .. " (" .. attr.name .. "), Value: " .. value)
        self:setCustomAttribute("Slot" .. self:getLastSlot() + 1, attrId .. "|" .. value)
        return true
    end
    return false
end





function Item.addAttribute(self, slot, attr, value)
    self:setCustomAttribute("Slot" .. slot, attr .. "|" .. value)
end

function Item.setAttributeValue(self, slot, value)
    self:setCustomAttribute("Slot" .. slot, value)
end

function Item.getBonusAttribute(self, slot)
    local bonuses = self:getCustomAttribute("Slot" .. slot)
    if bonuses then
        local data = {}
        for bonus in bonuses:gmatch("([^|]+)") do
            data[#data + 1] = tonumber(bonus)
        end
        return data
    end

    return nil
end

function Item.getBonusAttributes(self)
    local data = {}
    for i = 1, self:getMaxAttributes() do
        local bonuses = self:getCustomAttribute("Slot" .. i)
        if bonuses then
            local t = {}
            for bonus in bonuses:gmatch("([^|]+)") do
                t[#t + 1] = tonumber(bonus)
            end
            data[#data + 1] = t
        end
    end

    return #data > 0 and data or nil
end

function Item.getLastSlot(self)
    local last = 0
    for i = 1, self:getMaxAttributes() do
        if self:getCustomAttribute("Slot" .. i) then
            last = i
        end
    end
    return last
end

local function us_RecalculateItemBonusSlots(item, itemLevel)
    if not item or not item.isItem or not item:isItem() then
        return
    end

    local level = math.max(0, math.floor(tonumber(itemLevel) or 0))
    for slot = 1, item:getMaxAttributes() do
        local bonus = item:getBonusAttribute(slot)
        if bonus and bonus[1] then
            local attrId = bonus[1]
            local attr = US_ENCHANTMENTS[attrId]
            if attr then
                local recalculated = tonumber(us_GetAttributeValue(level, attr)) or bonus[2] or 1
                recalculated = math.max(1, math.floor(recalculated))
                if bonus[2] ~= recalculated then
                    item:setCustomAttribute("Slot" .. slot, attrId .. "|" .. recalculated)
                end
            end
        end
    end
end

function Item.setItemLevel(self, level, first)
    local oldLevel = self:getItemLevel()
    level = math.max(0, math.floor(tonumber(level) or 0))
    local itemType = ItemType(self.itemid)
    local oldEffectiveLevel = us_GetEffectiveItemLevelForStats(self, oldLevel)
    local newEffectiveLevel = us_GetEffectiveItemLevelForStats(self, level)

    local function getBonus(effectiveLevel, levelsPerBonus, bonusPerStep)
        local per = tonumber(levelsPerBonus) or 0
        local bonus = tonumber(bonusPerStep) or 0
        if per <= 0 or bonus == 0 then
            return 0
        end
        return math.floor(effectiveLevel / per) * bonus
    end

    local function addDeltaAttribute(attributeKey, baseValue, oldBonus, newBonus)
        local delta = newBonus - oldBonus
        if delta == 0 then
            return
        end

        local current = self:getAttribute(attributeKey)
        if not current or current <= 0 then
            current = baseValue
        end

        self:setAttribute(attributeKey, current + delta)
    end

    if itemType:getAttack() > 0 then
        local oldAttackBonus = getBonus(oldEffectiveLevel, US_CONFIG.ATTACK_PER_ITEM_LEVEL, US_CONFIG.ATTACK_FROM_ITEM_LEVEL)
        local newAttackBonus = getBonus(newEffectiveLevel, US_CONFIG.ATTACK_PER_ITEM_LEVEL, US_CONFIG.ATTACK_FROM_ITEM_LEVEL)
        addDeltaAttribute(ITEM_ATTRIBUTE_ATTACK, itemType:getAttack(), oldAttackBonus, newAttackBonus)
    end

    if itemType:getDefense() > 0 then
        local oldDefenseBonus = getBonus(oldEffectiveLevel, US_CONFIG.DEFENSE_PER_ITEM_LEVEL, US_CONFIG.DEFENSE_FROM_ITEM_LEVEL)
        local newDefenseBonus = getBonus(newEffectiveLevel, US_CONFIG.DEFENSE_PER_ITEM_LEVEL, US_CONFIG.DEFENSE_FROM_ITEM_LEVEL)
        addDeltaAttribute(ITEM_ATTRIBUTE_DEFENSE, itemType:getDefense(), oldDefenseBonus, newDefenseBonus)
    end

    if itemType:getArmor() > 0 then
        local oldArmorBonus = getBonus(oldEffectiveLevel, US_CONFIG.ARMOR_PER_ITEM_LEVEL, US_CONFIG.ARMOR_FROM_ITEM_LEVEL)
        local newArmorBonus = getBonus(newEffectiveLevel, US_CONFIG.ARMOR_PER_ITEM_LEVEL, US_CONFIG.ARMOR_FROM_ITEM_LEVEL)
        addDeltaAttribute(ITEM_ATTRIBUTE_ARMOR, itemType:getArmor(), oldArmorBonus, newArmorBonus)
    end

    if itemType:getHitChance() > 0 then
        local oldHitBonus = getBonus(oldEffectiveLevel, US_CONFIG.HITCHANCE_PER_ITEM_LEVEL, US_CONFIG.HITCHANCE_FROM_ITEM_LEVEL)
        local newHitBonus = getBonus(newEffectiveLevel, US_CONFIG.HITCHANCE_PER_ITEM_LEVEL, US_CONFIG.HITCHANCE_FROM_ITEM_LEVEL)
        addDeltaAttribute(ITEM_ATTRIBUTE_HITCHANCE, itemType:getHitChance(), oldHitBonus, newHitBonus)
    end

    if first then
        if itemType:getAttack() > 0 then
            level = level + math.floor(itemType:getAttack() / US_CONFIG.ITEM_LEVEL_PER_ATTACK)
        end
        if itemType:getDefense() > 0 then
            level = level + math.floor(itemType:getDefense() / US_CONFIG.ITEM_LEVEL_PER_DEFENSE)
        end
        if itemType:getArmor() > 0 then
            level = level + math.floor(itemType:getArmor() / US_CONFIG.ITEM_LEVEL_PER_ARMOR)
        end
        if itemType:getHitChance() > 0 then
            level = level + math.floor(itemType:getHitChance() / US_CONFIG.ITEM_LEVEL_PER_HITCHANCE)
        end
    end

    local updated = self:setCustomAttribute("item_level", level)
    if updated then
        -- Keep slot values synchronized with current item level scaling rules.
        us_RecalculateItemBonusSlots(self, level)
    end
    return updated
end

function Item.getItemLevel(self)
    return self:getCustomAttribute("item_level") and self:getCustomAttribute("item_level") or 0
end

function Item.getItemTier(self)
    return us_GetItemTier(self)
end

function Item.setItemTier(self, tier)
    return us_SetItemTier(self, tier)
end

function Item.getMaxUpgradeLevel(self)
    return us_GetMaxUpgradeLevel(self)
end

function Item.setUpgradeLevel(self, level)
    local itemType = ItemType(self.itemid)
    local oldLevel = self:getUpgradeLevel()
    local delta = oldLevel < level and (level - oldLevel) or (oldLevel - level)

    local function currentOrBase(attrKey, baseValue)
        local v = self:getAttribute(attrKey)
        if not v or v <= 0 then
            return baseValue
        end
        return v
    end

    if itemType:getAttack() > 0 then
        if oldLevel < level then
            self:setAttribute(ITEM_ATTRIBUTE_ATTACK, currentOrBase(ITEM_ATTRIBUTE_ATTACK, itemType:getAttack()) + delta * US_CONFIG.ATTACK_PER_UPGRADE)
        else
            self:setAttribute(ITEM_ATTRIBUTE_ATTACK, currentOrBase(ITEM_ATTRIBUTE_ATTACK, itemType:getAttack()) - delta * US_CONFIG.ATTACK_PER_UPGRADE)
        end
    end
    if itemType:getDefense() > 0 then
        if oldLevel < level then
            self:setAttribute(ITEM_ATTRIBUTE_DEFENSE, currentOrBase(ITEM_ATTRIBUTE_DEFENSE, itemType:getDefense()) + delta * US_CONFIG.DEFENSE_PER_UPGRADE)
        else
            self:setAttribute(ITEM_ATTRIBUTE_DEFENSE, currentOrBase(ITEM_ATTRIBUTE_DEFENSE, itemType:getDefense()) - delta * US_CONFIG.DEFENSE_PER_UPGRADE)
        end
    end
    if itemType:getExtraDefense() > 0 then
        if oldLevel < level then
            self:setAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE, currentOrBase(ITEM_ATTRIBUTE_EXTRADEFENSE, itemType:getExtraDefense()) + delta * US_CONFIG.EXTRADEFENSE_PER_UPGRADE)
        else
            self:setAttribute(ITEM_ATTRIBUTE_EXTRADEFENSE, currentOrBase(ITEM_ATTRIBUTE_EXTRADEFENSE, itemType:getExtraDefense()) - delta * US_CONFIG.EXTRADEFENSE_PER_UPGRADE)
        end
    end
    if itemType:getArmor() > 0 then
        if oldLevel < level then
            self:setAttribute(ITEM_ATTRIBUTE_ARMOR, currentOrBase(ITEM_ATTRIBUTE_ARMOR, itemType:getArmor()) + delta * US_CONFIG.ARMOR_PER_UPGRADE)
        else
            self:setAttribute(ITEM_ATTRIBUTE_ARMOR, currentOrBase(ITEM_ATTRIBUTE_ARMOR, itemType:getArmor()) - delta * US_CONFIG.ARMOR_PER_UPGRADE)
        end
    end
    if itemType:getHitChance() > 0 then
        if oldLevel < level then
            self:setAttribute(ITEM_ATTRIBUTE_HITCHANCE, currentOrBase(ITEM_ATTRIBUTE_HITCHANCE, itemType:getHitChance()) + delta * US_CONFIG.HITCHANCE_PER_UPGRADE)
        else
            self:setAttribute(ITEM_ATTRIBUTE_HITCHANCE, currentOrBase(ITEM_ATTRIBUTE_HITCHANCE, itemType:getHitChance()) - delta * US_CONFIG.HITCHANCE_PER_UPGRADE)
        end
    end
    self:setCustomAttribute("upgrade", level)
    if oldLevel < level then
        local addedLevel = us_GetItemLevelGainFromUpgrade(self, (level - oldLevel))
        if addedLevel > 0 then
            self:setItemLevel(self:getItemLevel() + addedLevel)
        end
    end
end

function Item.getUpgradeLevel(self)
    return self:getCustomAttribute("upgrade") and self:getCustomAttribute("upgrade") or 0
end

function Item.reduceUpgradeLevel(self)
    local oldUpgradeLevel = self:getUpgradeLevel()
    if oldUpgradeLevel <= 0 then
        return
    end

    local removedLevel = us_GetItemLevelGainFromUpgrade(self, 1)
    self:setUpgradeLevel(oldUpgradeLevel - 1)
    if removedLevel > 0 then
        self:setItemLevel(math.max(0, self:getItemLevel() - removedLevel))
    end
end

function Item.unidentify(self)
    self:setCustomAttribute("unidentified", true)
end

function Item.isUnidentified(self)
    return self:getCustomAttribute("unidentified")
end

function Item.identify(self, player, itemType, weaponType)
    self:removeCustomAttribute("unidentified")
    local usItemType = self:getItemType()
    local canUnique = false
    for i = 1, #US_UNIQUES do
        if US_UNIQUES[i].minLevel <= self:getItemLevel() and bit.band(usItemType, US_UNIQUES[i].itemType) ~= 0 then
            canUnique = true
            break
        end
    end
    self:rollRarity("identify")
    if canUnique and math.random(US_CONFIG.UNIQUE_CHANCE) == 1 then
        local unique = math.random(#US_UNIQUES)
        while US_UNIQUES[unique].minLevel > self:getItemLevel() or bit.band(usItemType, US_UNIQUES[unique].itemType) == 0 or
            US_UNIQUES[unique].chance and math.random(100) >= US_UNIQUES[unique].chance do
            unique = math.random(#US_UNIQUES)
        end
        self:setUnique(unique)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Unique item " .. self:getUniqueName() .. " discovered!")
    else
        self:rollAttribute(player, itemType, weaponType, true)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Item successfully identified!")
    end
    return true
end

function Item.setUnique(self, uniqueId)
    self:setCustomAttribute("unique", uniqueId)
    local unique = US_UNIQUES[uniqueId]
    if unique then
        for i = 1, #unique.attributes do
            local attrId = unique.attributes[i]
            local attr = US_ENCHANTMENTS[attrId]
            local value = us_GetAttributeValue(self:getItemLevel(), attr)
            self:setCustomAttribute("Slot" .. self:getLastSlot() + 1, attrId .. "|" .. value)
        end
    end
end

function Item.getUnique(self)
    return self:getCustomAttribute("unique") and self:getCustomAttribute("unique") or nil
end

function Item.isUnique(self)
    return self:getCustomAttribute("unique") and true or false
end

function Item.getUniqueName(self)
    return US_UNIQUES[self:getUnique()].name
end

function Item.setMemory(self, value)
    self:setCustomAttribute("memory", value)
end

function Item.hasMemory(self)
    return self:getCustomAttribute("memory")
end

function Item.setLimitless(self, value)
    self:setCustomAttribute("limitless", value)
end

function Item.isLimitless(self)
    return self:getCustomAttribute("limitless")
end

function Item.setMirrored(self, value)
    self:setCustomAttribute("mirrored", value)
end

function Item.isMirrored(self)
    return self:getCustomAttribute("mirrored")
end

local function us_NormalizeSlotPosition(slotPosition)
    return bit.band(slotPosition, bit.bnot(bit.bor(SLOTP_LEFT, SLOTP_RIGHT)))
end

function Item.getItemType(self)
    local itemType = self:getType()
    local slot = us_NormalizeSlotPosition(itemType:getSlotPosition())

    local weaponType = itemType:getWeaponType()
    if weaponType > 0 then
        if weaponType == WEAPON_SHIELD then
            return US_ITEM_TYPES.SHIELD
        end
        if weaponType == WEAPON_DISTANCE then
            return US_ITEM_TYPES.WEAPON_DISTANCE
        end
        if weaponType == WEAPON_WAND then
            return US_ITEM_TYPES.WEAPON_WAND
        end
        if isInArray({WEAPON_SWORD, WEAPON_CLUB, WEAPON_AXE}, weaponType) then
            return US_ITEM_TYPES.WEAPON_MELEE
        end
    else
        if slot == SLOTP_HEAD then
            return US_ITEM_TYPES.HELMET
        end
        if slot == SLOTP_ARMOR then
            return US_ITEM_TYPES.ARMOR
        end
        if slot == SLOTP_LEGS then
            return US_ITEM_TYPES.LEGS
        end
        if slot == SLOTP_FEET then
            return US_ITEM_TYPES.BOOTS
        end
        if slot == SLOTP_NECKLACE then
            return US_ITEM_TYPES.NECKLACE
        end
        if slot == SLOTP_RING then
            return US_ITEM_TYPES.RING
        end
        if slot == SLOTP_QUIVER then
            return US_ITEM_TYPES.WEAPON_DISTANCE
        end
    end
    return US_ITEM_TYPES.ALL
end

function Item.setRarity(self, rarity)
    rarity = rarity or COMMON

    local itemType = self:getType()
    if itemType and itemType:canHaveItemLevel() then
        if self:getItemLevel() <= 0 then
            self:ensureInitialTierLevel(false)
        end

        local currentLevel = self:getItemLevel()
        local previousBonus = self:getCustomAttribute("rarity_level_bonus") or 0
        local baseLevel = currentLevel - previousBonus
        if baseLevel < 0 then
            baseLevel = 0
        end

        local rarityMultipliers = US_CONFIG.RARITY_ITEM_LEVEL_MULTIPLIER or {}
        local multiplier = rarityMultipliers[rarity] or 1.0
        local boostedLevel = math.floor(baseLevel * multiplier + 0.5)
        if boostedLevel < 0 then
            boostedLevel = 0
        end

        if boostedLevel ~= currentLevel then
            self:setItemLevel(boostedLevel, false)
        end
        self:setCustomAttribute("rarity_level_bonus", boostedLevel - baseLevel)
    end

    self:setCustomAttribute("rarity", rarity)
	self:updateRarityFrame()
end

function Item.rollRarity(self, source)
    local rarityRollScale = US_CONFIG.RARITY_ROLL_SCALE or 1000
    local noBonusCutoff = US_CONFIG.RARITY_NO_BONUS_COMMON_CUTOFF or 50
    local thresholdByRarity = nil
    if source == "drop" then
        thresholdByRarity = US_CONFIG.RARITY_DROP_CHANCE
    elseif source == "identify" then
        thresholdByRarity = US_CONFIG.RARITY_IDENTIFY_CHANCE
    end
    local rarity = COMMON

    -- Roll for rarity
    local roll = math.random(rarityRollScale)

    -- Keep a small common slice with no bonus slots.
    if roll < noBonusCutoff then
        -- If roll lands in this slice, keep common and skip adding attributes.
        self:setRarity(rarity)
        return
    end

    for i = #US_CONFIG.RARITY, 1, -1 do
        local threshold = US_CONFIG.RARITY[i].chance
        if thresholdByRarity and thresholdByRarity[i] then
            threshold = thresholdByRarity[i]
        end
        if roll >= threshold then
            rarity = i
            break
        end
    end
    self:setRarity(rarity)

    -- Get the maximum number of attributes for the item's rarity
    local maxAttributes = US_CONFIG.RARITY[rarity].maxBonus
    local currentAttributes = self:getBonusAttributes() or {}
    local availableSlots = maxAttributes - #currentAttributes

    -- If no available slots, return
    if availableSlots <= 0 then
        return
    end

    -- Define chance values based on rarity
    local chanceValues = {}
    if rarity == COMMON then
        chanceValues = {1}
    elseif rarity == RARE then
        chanceValues = {1, 1}
    elseif rarity == EPIC then
        chanceValues = {3, 2, 1}
    elseif rarity == LEGENDARY then
        chanceValues = {4, 2, 1, 1}
    end

    -- Determine the number of slots to populate
    local numSlotsToPopulate = 0
    local totalChance = 0
    for _, chance in ipairs(chanceValues) do
        totalChance = totalChance + chance
    end

    roll = math.random(totalChance)
    for index, chance in ipairs(chanceValues) do
        if roll <= chance then
            numSlotsToPopulate = index
            break
        else
            roll = roll - chance
        end
    end

    -- Populate the selected number of slots with random attributes
    local usItemType = self:getItemType()
    local itemLevel = self:getItemLevel()
    local attrIds = {}
    for _, bonus in pairs(currentAttributes) do
        if bonus and bonus[1] then
            table.insert(attrIds, bonus[1])
        end
    end

    for i = 1, numSlotsToPopulate do
        local attrId = math.random(1, #US_ENCHANTMENTS)
        local attr = US_ENCHANTMENTS[attrId]
        local guard = 0
        while isInArray(attrIds, attrId) or itemLevel < us_GetAttributeRequiredLevel(attr) or not us_IsEnchantAllowedForItem(attr, self, usItemType) or
            attr.chance and math.random(100) >= attr.chance do
            attrId = math.random(1, #US_ENCHANTMENTS)
            attr = US_ENCHANTMENTS[attrId]
            guard = guard + 1
            if guard > (#US_ENCHANTMENTS * 4) then
                attrId = nil
                break
            end
        end

        if attrId then
            table.insert(attrIds, attrId)
            local value = us_GetAttributeValue(itemLevel, attr)
            self:setCustomAttribute("Slot" .. self:getLastSlot() + 1, attrId .. "|" .. value)
        end
    end
end




function Item.getRarity(self)
    return self:getCustomAttribute("rarity") and US_CONFIG.RARITY[self:getCustomAttribute("rarity")] or US_CONFIG.RARITY[COMMON]
end

function Item.getRarityId(self)
    return self:getCustomAttribute("rarity") and self:getCustomAttribute("rarity") or COMMON
end

function Item.getMaxAttributes(self)
    if self:isUnique() then
        return #US_UNIQUES[self:getUnique()].attributes
    end
    local rarity = self:getRarity()
    return rarity.maxBonus
end

function ItemType.isUpgradable(self)
    if self:isStackable() or self:getTransformEquipId() > 0 or self:getDecayId() > 0 or self:getDestroyId() > 0 or self:getCharges() > 0 then
        return false
    end
    local slot = us_NormalizeSlotPosition(self:getSlotPosition())

    local weaponType = self:getWeaponType()
    if weaponType > 0 then
        if weaponType == WEAPON_AMMO then
            return false
        end
        if
            weaponType == WEAPON_SHIELD or weaponType == WEAPON_DISTANCE or weaponType == WEAPON_WAND or
                isInArray({WEAPON_SWORD, WEAPON_CLUB, WEAPON_AXE}, weaponType)
         then
            return true
        end
    else
        if slot == SLOTP_HEAD or slot == SLOTP_ARMOR or slot == SLOTP_LEGS or slot == SLOTP_FEET or slot == SLOTP_NECKLACE or slot == SLOTP_RING or slot == SLOTP_QUIVER then
            return true
        end
    end
    return false
end

function ItemType.canHaveItemLevel(self)
    if self:getTransformEquipId() > 0 or self:getDecayId() > 0 or self:getDestroyId() > 0 or self:getCharges() > 0 then
        return false
    end
    local slot = us_NormalizeSlotPosition(self:getSlotPosition())

    local weaponType = self:getWeaponType()
    if weaponType > 0 then
        if weaponType == WEAPON_AMMO then
            return false
        end
        if
            weaponType == WEAPON_SHIELD or weaponType == WEAPON_DISTANCE or weaponType == WEAPON_WAND or
                isInArray({WEAPON_SWORD, WEAPON_CLUB, WEAPON_AXE}, weaponType)
         then
            return true
        end
    else
        if slot == SLOTP_HEAD or slot == SLOTP_ARMOR or slot == SLOTP_LEGS or slot == SLOTP_FEET or slot == SLOTP_NECKLACE or slot == SLOTP_RING or slot == SLOTP_QUIVER then
            return true
        end
    end
    return false
end

function MonsterType.calculateItemLevel(self)
    local level = 1
    local monsterValue = self:getMaxHealth() + self:getExperience()
    level = math.ceil(math.pow(monsterValue, 0.478))
    return math.max(1, level)
end

function Player.getNextSubId(self, itemSlot, attrSlot)
    local cid = self:getId()
    if not US_SUBID[cid] then
        US_SUBID[cid] = {current = 0}
    end

    local subId = US_SUBID[cid]
    subId.current = subId.current + 1

    if not subId[itemSlot] then
        subId[itemSlot] = {}
    end

    subId[itemSlot][attrSlot] = subId.current

    return subId.current
end

LoginEvent:type("login")
LoginEvent:register()
HealthChangeEvent:type("healthchange")
HealthChangeEvent:register()
ManaChangeEvent:type("manachange")
ManaChangeEvent:register()
DeathEvent:type("death")
DeathEvent:register()
KillEvent:type("kill")
KillEvent:register()
PrepareDeathEvent:type("preparedeath")
PrepareDeathEvent:register()
