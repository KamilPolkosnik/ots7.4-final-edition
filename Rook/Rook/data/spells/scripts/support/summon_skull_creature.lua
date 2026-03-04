local FORCED_SKULL = SKULL_RED
local FORCED_VARIANT_TIER = 3
local SOUL_LOCK_PER_SUMMON = 70
local MAX_SKULL_SUMMONS = 1

local function getSpawnKey(position)
	return string.format("%d|%d|%d", position.x, position.y, position.z)
end

local function markPendingVariantSkip(position)
	if not MonsterVariants then
		return nil
	end

	MonsterVariants.pendingSummonPositions = MonsterVariants.pendingSummonPositions or {}
	local key = getSpawnKey(position)
	MonsterVariants.pendingSummonPositions[key] = true
	return key
end

local function clearPendingVariantSkip(key)
	if not key or not MonsterVariants or not MonsterVariants.pendingSummonPositions then
		return
	end
	MonsterVariants.pendingSummonPositions[key] = nil
end

local function applyForcedVariant(summon)
	local cfg = MonsterVariants
	if not cfg or not cfg.tiers then
		return
	end

	local tier = cfg.tiers[FORCED_VARIANT_TIER]
	if not tier then
		return
	end

	local multiplier = tonumber(tier.multiplier) or 1
	if multiplier > 0 and multiplier ~= 1 then
		local oldMax = summon:getMaxHealth()
		local newMax = math.max(1, math.floor(oldMax * multiplier + 0.5))
		if newMax ~= oldMax then
			summon:setMaxHealth(newMax)
			summon:setHealth(newMax)
		end
	end

	local effect = tonumber(tier.effect)
	if effect and effect > 0 then
		summon:getPosition():sendMagicEffect(effect)
	end
end

function onCastSpell(creature, variant)
	if creature:getSkull() == SKULL_BLACK then
		creature:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		return false
	end

	if creature.getSkullSoulSummonCount and creature:getSkullSoulSummonCount() >= MAX_SKULL_SUMMONS then
		creature:sendCancelMessage("You already control a skull summon.")
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local monsterName = variant:getString()
	local monsterType = MonsterType(monsterName)
	if not monsterType then
		creature:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if not creature:hasFlag(PlayerFlag_CanSummonAll) then
		if not monsterType:isSummonable() then
			creature:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			creature:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if #creature:getSummons() >= 2 then
			creature:sendCancelMessage("You cannot summon more creatures.")
			creature:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

	local manaCost = monsterType:getManaCost()
	if creature:getMana() < manaCost and not creature:hasFlag(PlayerFlag_HasInfiniteMana) then
		creature:sendCancelMessage(RETURNVALUE_NOTENOUGHMANA)
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local position = creature:getPosition()
	local pendingKey = markPendingVariantSkip(position)
	local summon = Game.createMonster(monsterName, position, true)
	if not summon then
		clearPendingVariantSkip(pendingKey)
		creature:sendCancelMessage(RETURNVALUE_NOTENOUGHROOM)
		position:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if pendingKey then
		addEvent(clearPendingVariantSkip, 2000, pendingKey)
	end

	creature:addMana(-manaCost)
	creature:addManaSpent(manaCost)
	creature:addSummon(summon)
	summon:setSkull(FORCED_SKULL)
	applyForcedVariant(summon)

	if creature.registerSkullSoulSummon then
		creature:registerSkullSoulSummon(summon)
	end

	local effectiveMaxSoul = creature.getEffectiveMaxSoul and creature:getEffectiveMaxSoul() or creature:getVocation():getMaxSoul()
	creature:sendTextMessage(MESSAGE_STATUS_SMALL,
		string.format("Skull summon active: soul cap reduced by %d (max soul now %d).", SOUL_LOCK_PER_SUMMON, effectiveMaxSoul))

	position:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	summon:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	return true
end
