local holeId = {
	294, 369, 370, 383, 392, 408, 409, 410, 427, 428, 429, 430, 462, 469, 470, 482,
	484, 485, 489, 924, 3135, 3136, 4835, 4837, 7933, 7938, 8170, 8249, 8250,
	8251, 8252, 8254, 8255, 8256, 8276, 8277, 8279, 8281, 8284, 8285, 8286, 8323,
	8567, 8585, 8595, 8596, 8972, 9606, 9625, 13190, 14461, 19519, 21536
}

local DEBUG_ROPE = false

function onUse(cid, item, fromPosition, itemEx, toPosition, isHotkey)
	local player = Player(cid)
	if not player then
		return true
	end

	local exhaustStorage = 9999
	if player:getStorageValue(exhaustStorage) > os.time() then
		player:sendCancelMessage("You must wait a while before using this again.")
		return true
	end

	local tile = Tile(toPosition)
	if not tile then
		return false
	end

	local ground = tile:getGround()
	local groundId = ground and ground:getId() or nil
	local targetId = itemEx and itemEx.itemid or nil

	if DEBUG_ROPE then
		local posStr = string.format("%d,%d,%d", toPosition.x, toPosition.y, toPosition.z)
		local ropeGround = groundId and table.contains(ropeSpots, groundId) or false
		local ropeTarget = targetId and table.contains(ropeSpots, targetId) or false
		local has14435 = tile:getItemById(14435) ~= nil
		local holeCheck = itemEx and table.contains(holeId, itemEx.itemid) or false
		print(string.format(
			"[RopeDebug] player=%s pos=%s ground=%s target=%s itemEx=%s ropeSpots(ground=%s target=%s) has14435=%s holeCheck=%s",
			player:getName(),
			posStr,
			tostring(groundId),
			tostring(targetId),
			tostring(itemEx and itemEx.itemid or nil),
			tostring(ropeGround),
			tostring(ropeTarget),
			tostring(has14435),
			tostring(holeCheck)
		))
	end

	if (groundId and table.contains(ropeSpots, groundId)) or (targetId and table.contains(ropeSpots, targetId)) or tile:getItemById(14435) then
		if Tile(toPosition:moveUpstairs()):hasFlag(TILESTATE_PROTECTIONZONE) and player:isPzLocked() then
			player:sendCancelMessage(RETURNVALUE_PLAYERISPZLOCKED)
			return true
		end
		player:teleportTo(toPosition, false)
		return true
	elseif table.contains(holeId, itemEx.itemid) then
		toPosition.z = toPosition.z + 1
		tile = Tile(toPosition)
		if tile then
			local thing = tile:getTopVisibleThing()
			if thing:isPlayer() or thing:isCreature() or thing:isMonster() then
				if Tile(toPosition:moveUpstairs()):hasFlag(TILESTATE_PROTECTIONZONE) and thing:isPzLocked() then
					return false
				end
				player:setStorageValue(exhaustStorage, os.time() + 60)
				player:setStorageValue(5565633, player:getStorageValue(5565633) + 1)
				return thing:teleportTo(toPosition, false)
			end
			if thing:isItem() and thing:getType():isMovable() then
				return thing:moveTo(toPosition:moveUpstairs())
			end
		end
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		return true
	end
	return false
end
