function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return true
	end

	local aid = item.getActionId and item:getActionId() or item.actionid
	local townId = nil

	-- Newer mapping range from actionIds (e.g. 30021+)
	if aid > actionIds.citizenship and aid < actionIds.citizenshipLast then
		townId = aid - actionIds.citizenship
	end

	-- Legacy mapping used on this map: 4001..4009 => town 1..9
	if not townId and aid >= 4001 and aid <= 4999 then
		townId = aid - 4000
	end

	-- Direct mapping fallback: aid is already town id
	if not townId and aid >= 1 and aid <= 20 then
		townId = aid
	end

	if not townId then
		return true
	end

	local town = Town(townId)
	if not town then
		return true
	end

	creature:setTown(town)
	local templePos = town:getTemplePosition()
	if templePos then
		creature:teleportTo(templePos, true)
		templePos:sendMagicEffect(CONST_ME_TELEPORT)
	end

	creature:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are now a citizen of " .. town:getName() .. ".")
	return true
end
