function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or not target:isItem() then
		return false
	end

	if target:getId() == 2334 and toPosition.x == 31948 and toPosition.y == 31711 and toPosition.z == 6 then
		item:transform(1993, 1) -- red bag
		item:decay()
		player:setStorageValue(244, 2)
		toPosition:sendMagicEffect(19)
		return true
	end

	return false
end
