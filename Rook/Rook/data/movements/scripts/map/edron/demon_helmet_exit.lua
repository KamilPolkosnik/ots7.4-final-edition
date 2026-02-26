local TELEPORT_POS = {x = 33316, y = 31591, z = 15}
local DEST_POS = {x = 33328, y = 31592, z = 14}

local function isItemAt(pos, itemId)
	local tile = Tile(pos)
	if not tile then
		return false
	end
	return tile:getItemById(itemId) ~= nil
end

function onStepIn(creature, item, position, fromPosition)
	if isItemAt(TELEPORT_POS, 1387) then
		doRelocate(item:getPosition(), DEST_POS)
	end
	return true
end

function onAddItem(moveitem, tileitem, position)
	if isItemAt(TELEPORT_POS, 1387) then
		doRelocate(moveitem:getPosition(), DEST_POS)
	end
	return true
end
