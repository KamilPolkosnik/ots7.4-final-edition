local TELEPORT_POS = {x = 32225, y = 32276, z = 10}
local DEST_POS = {x = 32232, y = 32276, z = 9}

local function isItemAt(pos, itemId)
	local tile = Tile(pos)
	if not tile then
		return false
	end
	return tile:getItemById(itemId) ~= nil
end

local function sendEffects()
	Position(TELEPORT_POS.x, TELEPORT_POS.y, TELEPORT_POS.z):sendMagicEffect(15)
	Position(DEST_POS.x, DEST_POS.y, DEST_POS.z):sendMagicEffect(15)
end

function onStepIn(creature, item, position, fromPosition)
	if isItemAt(TELEPORT_POS, 1387) then
		doRelocate(item:getPosition(), DEST_POS)
		sendEffects()
	end
	return true
end

function onAddItem(moveitem, tileitem, position)
	if isItemAt(TELEPORT_POS, 1387) then
		doRelocate(moveitem:getPosition(), DEST_POS)
		sendEffects()
	end
	return true
end
