local action = Action()

function action.onUse(player, item, fromPosition, target, toPosition)
	if item:getId() == 1945 then 
		item:transform(1946, 1)
		item:decay()
		doRelocate({x = 32225, y = 32276, z = 10},{x = 32225, y = 32275, z = 10})
		local teleportExit = Game.createItem(1387, 1, {x = 32225, y = 32276, z = 10})
		if teleportExit then
			teleportExit:setActionId(3115)
		end
		doRelocate({x = 32233, y = 32276, z = 09},{x = 32232, y = 32276, z = 09})
		local teleportPortal = Game.createItem(1387, 1, {x = 32233, y = 32276, z = 09})
		if teleportPortal then
			teleportPortal:setActionId(3114)
		end
	elseif item:getId() == 1946 then
		item:transform(1945, 1)
		item:decay()
		Game.removeItemInPosition({x = 32233, y = 32276, z = 09}, 1387)
		Game.removeItemInPosition({x = 32225, y = 32276, z = 10}, 1387)
	end
	return true
end

action:aid(2065)
action:register()
