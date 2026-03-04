local SEARCH_RADIUS = 2

local function findNearestFreePosition(summon, centerPosition)
	local getClosestFreePosition = summon.getClosestFreePosition
	if getClosestFreePosition then
		local position = getClosestFreePosition(summon, centerPosition, SEARCH_RADIUS, false)
		if position and position.x and position.x > 0 then
			return position
		end
	end

	return centerPosition
end

function onCastSpell(creature, variant)
	local summons = creature:getSummons()
	if #summons == 0 then
		creature:sendCancelMessage("You have no summons.")
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local playerPosition = creature:getPosition()
	local moved = 0

	for _, summon in ipairs(summons) do
		if summon then
			local targetPosition = findNearestFreePosition(summon, playerPosition)
			local fromPosition = summon:getPosition()
			if summon:teleportTo(targetPosition, true) then
				fromPosition:sendMagicEffect(CONST_ME_TELEPORT)
				targetPosition:sendMagicEffect(CONST_ME_TELEPORT)
				moved = moved + 1
			end
		end
	end

	if moved == 0 then
		creature:sendCancelMessage("No free space near you for your summons.")
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	creature:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end
