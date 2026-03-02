--Pre-made areas
function healingFormula(level, maglevel, base, variation, value_min, value_max)
	local value = 3 * maglevel + (2 * level)
	
	if value_min ~= nil and value <= value_min then
		value = value_min
	end
	
	if value_max ~= nil and value >= value_max then
		value = value_max
	end
	
	local min = value * (base - variation) / 100
	local max = value * (base + variation) / 100
	return min, max
end

function damageFormula(level, maglevel, base, variation)
	local value = 3 * maglevel + (2 * level)

	local min = value * (base - variation) / 100
	local max = value * (base + variation) / 100
	return min, max
end

function computeFormula(level, maglevel, base, variation)
	local damage = base
	if variation > 0 then
		damage = math.random(-variation, variation) + damage
	end
	
	local level_formula = 2 * level
	local magic_formula = 3 * maglevel + level_formula 

	return magic_formula * damage / 100
end

---------------------------------------------------------------------------------------


--Waves
AREA_WAVE3 = {
	{1, 1, 1},
	{1, 1, 1},
	{0, 3, 0}
}

AREA_WAVE4 = {
	{1, 1, 1, 1, 1},
	{0, 1, 1, 1, 0},
	{0, 1, 1, 1, 0},
	{0, 0, 3, 0, 0}
}

AREA_WAVE6 = {
	{0, 0, 0, 0, 0},
	{0, 1, 3, 1, 0},
	{0, 0, 0, 0, 0}
}

AREA_SQUAREWAVE5 = {
	{1, 1, 1},
	{1, 1, 1},
	{1, 1, 1},
	{0, 1, 0},
	{0, 3, 0}
}

AREA_SQUAREWAVE6 = {
	{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
	{0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
	{0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
	{0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
	{0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
	{0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0},
	{0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0}
}

AREA_SQUAREWAVE7 = {
	{0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
	{0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
	{0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
	{0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
	{0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
	{0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
	{0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0},
	{0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0},
	{0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0}
}

--Diagonal waves
AREADIAGONAL_WAVE4 = {
	{0, 0, 0, 0, 1, 0},
	{0, 0, 0, 1, 1, 0},
	{0, 0, 1, 1, 1, 0},
	{0, 1, 1, 1, 1, 0},
	{1, 1, 1, 1, 1, 0},
	{0, 0, 0, 0, 0, 3}
}

AREADIAGONAL_SQUAREWAVE5 = {
	{1, 1, 1, 0, 0},
	{1, 1, 1, 0, 0},
	{1, 1, 1, 0, 0},
	{0, 0, 0, 1, 0},
	{0, 0, 0, 0, 3}
}

AREADIAGONAL_WAVE6 = {
	{0, 0, 1},
	{0, 3, 0},
	{1, 0, 0}
}

--Beams
AREA_BEAM1 = {
	{3}
}

AREA_BEAM5 = {
	{1},
	{1},
	{1},
	{1},
	{3}
}

AREA_BEAM7 = {
	{1},
	{1},
	{1},
	{1},
	{1},
	{1},
	{3}
}

AREA_BEAM8 = {
	{1},
	{1},
	{1},
	{1},
	{1},
	{1},
	{1},
	{3}
}

--Diagonal Beams
AREADIAGONAL_BEAM5 = {
	{1, 0, 0, 0, 0},
	{0, 1, 0, 0, 0},
	{0, 0, 1, 0, 0},
	{0, 0, 0, 1, 0},
	{0, 0, 0, 0, 3}
}

AREADIAGONAL_BEAM7 = {
	{1, 0, 0, 0, 0, 0, 0},
	{0, 1, 0, 0, 0, 0, 0},
	{0, 0, 1, 0, 0, 0, 0},
	{0, 0, 0, 1, 0, 0, 0},
	{0, 0, 0, 0, 1, 0, 0},
	{0, 0, 0, 0, 0, 1, 0},
	{0, 0, 0, 0, 0, 0, 3}
}

--Circles
AREA_CIRCLE2X2 = {
	{0, 1, 1, 1, 0},
	{1, 1, 1, 1, 1},
	{1, 1, 3, 1, 1},
	{1, 1, 1, 1, 1},
	{0, 1, 1, 1, 0}
}

AREA_CIRCLE3X3 = {
	{0, 0, 1, 1, 1, 0, 0},
	{0, 1, 1, 1, 1, 1, 0},
	{1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 3, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1},
	{0, 1, 1, 1, 1, 1, 0},
	{0, 0, 1, 1, 1, 0, 0}
}

-- Crosses
AREA_CROSS1X1 = {
	{0, 1, 0},
	{1, 3, 1},
	{0, 1, 0}
}

AREA_CIRCLE5X5 = {
	{0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0},
	{0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
	{0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
	{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
	{1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1},
	{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
	{0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
	{0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}
}

AREA_CIRCLE6X6 = {
	{0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0},
	{0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0},
	{0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0},
	{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
	{1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1},
	{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0},
	{0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0},
	{0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0}
}

--Squares
AREA_SQUARE1X1 = {
	{1, 1, 1},
	{1, 3, 1},
	{1, 1, 1}
}

-- Walls
AREA_WALLFIELD = {
	{1, 1, 3, 1, 1}
}

AREADIAGONAL_WALLFIELD = {
	{0, 0, 0, 0, 1},
	{0, 0, 0, 1, 1},
	{0, 1, 3, 1, 0},
	{1, 1, 0, 0, 0},
	{1, 0, 0, 0, 0},
}

-- This array contains all destroyable field items
FIELDS = {1487,1488,1489,1490,1491,1492,1493,1494,1495,1496,1500,1501,1502,1503,1504}

function Player:addPartyCondition(combat, variant, condition, baseMana)
	local party = self:getParty()
	if not party then
		self:sendCancelMessage(RETURNVALUE_NOPARTYMEMBERSINRANGE)
		self:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local positions = combat:getPositions(self, variant)
	local members = party:getMembers()
	members[#members + 1] = party:getLeader()

	local affectedMembers = {}
	for _, member in ipairs(members) do
		local memberPosition = member:getPosition()
		for _, position in ipairs(positions) do
			if memberPosition == position then
				affectedMembers[#affectedMembers + 1] = member
			end
		end
	end

	if #affectedMembers <= 1 then
		self:sendCancelMessage(RETURNVALUE_NOPARTYMEMBERSINRANGE)
		self:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local mana = math.ceil(#affectedMembers * math.pow(0.9, #affectedMembers - 1) * baseMana)
	if self:getMana() < mana then
		self:sendCancelMessage(RETURNVALUE_NOTENOUGHMANA)
		self:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	self:addMana(-mana)
	self:addManaSpent(mana)

	for _, member in ipairs(affectedMembers) do
		member:addCondition(condition)
	end

	for _, position in ipairs(positions) do
		position:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	end
	return true
end

if not Player.conjureItem then
	local BLANK_RUNE_MANA_COST_BY_CONJURE_ID = {
		[2261] = 60, [2262] = 220, [2265] = 60, [2266] = 70, [2268] = 220, [2273] = 100,
		[2277] = 80, [2278] = 900, [2279] = 250, [2285] = 50, [2286] = 120, [2287] = 50,
		[2289] = 160, [2290] = 100, [2291] = 150, [2292] = 100, [2293] = 250, [2301] = 60,
		[2302] = 60, [2303] = 200, [2304] = 120, [2305] = 150, [2308] = 150, [2310] = 100,
		[2311] = 70, [2313] = 180, [2316] = 300, [7936] = 75, [7937] = 125,
	}

	function Player:conjureItem(reagentId, conjureId, conjureCount, effect)
		if not conjureCount and conjureId ~= 0 then
			local itemType = ItemType(conjureId)
			if itemType:getId() == 0 then
				return false
			end

			local charges = itemType:getCharges()
			if charges ~= 0 then
				conjureCount = charges
			end
		end

		if reagentId == 2260 then
			local leftHandItem = self:getSlotItem(CONST_SLOT_LEFT)
			local rightHandItem = self:getSlotItem(CONST_SLOT_RIGHT)
			local hasLeftBlankRune = leftHandItem and leftHandItem:getId() == 2260
			local hasRightBlankRune = rightHandItem and rightHandItem:getId() == 2260
			local castCount = 1
			local extraManaCost = 0

			if not hasLeftBlankRune and not hasRightBlankRune then
				self:sendCancelMessage(RETURNVALUE_YOUNEEDAMAGICITEMTOCASTSPELL)
				self:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if hasLeftBlankRune and hasRightBlankRune then
				local manaCost = BLANK_RUNE_MANA_COST_BY_CONJURE_ID[conjureId] or 0
				if manaCost > 0 and self:getMana() >= (manaCost * 2) then
					castCount = 2
					extraManaCost = manaCost
				end
			end

			local function transformBlankRune(blankRune)
				if not blankRune then
					return nil
				end

				if not blankRune:transform(conjureId, conjureCount) then
					return nil
				end

				if blankRune:hasAttribute(ITEM_ATTRIBUTE_DURATION) then
					blankRune:decay()
				end
				return blankRune
			end

			local producedRune = nil
			if castCount == 2 then
				local leftRune = transformBlankRune(leftHandItem)
				local rightRune = transformBlankRune(rightHandItem)
				if not leftRune or not rightRune then
					self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
					self:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end
				producedRune = rightRune
			else
				local sourceRune = hasRightBlankRune and rightHandItem or leftHandItem
				producedRune = transformBlankRune(sourceRune)
				if not producedRune then
					self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
					self:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end
			end

			if extraManaCost > 0 then
				self:addMana(-extraManaCost)
				self:addManaSpent(extraManaCost)
			end

			self:getPosition():sendMagicEffect(producedRune:getType():isRune() and CONST_ME_MAGIC_RED or effect)
			return true
		elseif reagentId ~= 0 and not self:removeItem(reagentId, 1, -1) then
			self:sendCancelMessage(RETURNVALUE_YOUNEEDAMAGICITEMTOCASTSPELL)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local item = self:addItem(conjureId, conjureCount)
		if not item then
			self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			self:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if item:hasAttribute(ITEM_ATTRIBUTE_DURATION) then
			item:decay()
		end

		self:getPosition():sendMagicEffect(item:getType():isRune() and CONST_ME_MAGIC_RED or effect)
		return true
	end
end

function Creature:addAttributeCondition(parameters)
	local condition = Condition(CONDITION_ATTRIBUTES)
	for _, parameter in ipairs(parameters) do
		if parameter.key and parameter.value then
			condition:setParameter(parameter.key, parameter.value)
		end
	end

	self:addCondition(condition)
end
