local holeId = {
	294, 369, 370, 383, 392, 408, 409, 410, 427, 428, 429, 430, 462, 469, 470, 482,
	484, 485, 489, 924, 3135, 3136, 4835, 4837, 7933, 7938, 8170, 8249, 8250,
	8251, 8252, 8254, 8255, 8256, 8276, 8277, 8279, 8281, 8284, 8285, 8286, 8323,
	8567, 8585, 8595, 8596, 8972, 9606, 9625, 13190, 14461, 19519, 21536
}

local DEBUG_ROPE = false

local rope = Action()

function rope.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local tile = Tile(toPosition)
	if not tile then
		return false
	end

	local targetItem = target
	if targetItem then
		local itemType = ItemType(targetItem.itemid)
		if itemType and itemType:getGroup() == ITEM_GROUP_SPLASH then
			targetItem = tile:getGround()
		end
	else
		targetItem = tile:getGround()
	end

	local ground = tile:getGround()
	local groundId = ground and ground:getId() or nil
	local targetId = targetItem and targetItem:getId() or (targetItem and targetItem.itemid) or nil

	if DEBUG_ROPE then
		local posStr = string.format("%d,%d,%d", toPosition.x, toPosition.y, toPosition.z)
		local ropeGround = groundId and table.contains(ropeSpots, groundId) or false
		local ropeTarget = targetId and table.contains(ropeSpots, targetId) or false
		local has14435 = tile:getItemById(14435) ~= nil
		local holeCheck = target and table.contains(holeId, target.itemid) or false
		print(string.format(
			"[RopeDebug] player=%s pos=%s ground=%s target=%s itemEx=%s ropeSpots(ground=%s target=%s) has14435=%s holeCheck=%s",
			player:getName(),
			posStr,
			tostring(groundId),
			tostring(targetId),
			tostring(target and target.itemid or nil),
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
	end

	if target and table.contains(holeId, target.itemid) then
		toPosition.z = toPosition.z + 1
		tile = Tile(toPosition)
		if tile then
			local creature = tile:getTopCreature() or tile:getBottomCreature()
			if creature then
				if creature:isPlayer() and Tile(toPosition:moveUpstairs()):hasFlag(TILESTATE_PROTECTIONZONE) and creature:isPzLocked() then
					return false
				end
				return creature:teleportTo(toPosition:moveUpstairs(), false)
			end

			local topItem = tile:getTopDownItem()
			if topItem and topItem:isItem() and topItem:getType():isMovable() then
				return topItem:moveTo(toPosition:moveUpstairs())
			end
		end
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		return true
	end

	return false
end

rope:id(2120)
-- Disabled to avoid duplicate registration with legacy actions.xml tools/rope.lua
-- rope:register()
