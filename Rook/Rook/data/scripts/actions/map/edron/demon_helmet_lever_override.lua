local action = Action()

function action.onUse(player, item, fromPosition, target, toPosition)
	local itemId = item:getId()
	if itemId == 1945 or itemId == 2772 then
		local newId = (itemId == 1945) and 1946 or 2773
		item:transform(newId, 1)
		item:decay()
		Game.removeItemInPosition({x = 33314, y = 31592, z = 15}, 1355)
		if not Game.isItemInPosition({x = 33314, y = 31592, z = 15}, 3621) then
			Game.createItem(3621, 1, {x = 33314, y = 31592, z = 15})
		end
		doRelocate({x = 33316, y = 31591, z = 15}, {x = 33317, y = 31591, z = 15})
		Game.removeItemInPosition({x = 33316, y = 31591, z = 15}, 1387)
		local teleport = Game.createItem(1387, 1, {x = 33316, y = 31591, z = 15})
		if teleport then
			teleport:setDestination(Position(33328, 31592, 14))
		end
	elseif itemId == 1946 or itemId == 2773 then
		local newId = (itemId == 1946) and 1945 or 2772
		item:transform(newId, 1)
		item:decay()
		doRelocate({x = 33314, y = 31592, z = 15}, {x = 33315, y = 31592, z = 15})
		Game.removeItemInPosition({x = 33314, y = 31592, z = 15}, 3621)
		Game.createItem(1355, 1, {x = 33314, y = 31592, z = 15})
		Game.removeItemInPosition({x = 33316, y = 31591, z = 15}, 1387)
	end
	return true
end

action:aid(2012)
action:register()
