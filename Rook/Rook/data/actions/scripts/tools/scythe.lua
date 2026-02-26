function onUse(cid, item, fromPosition, itemEx, toPosition, isHotkey)
	local player = Player(cid)
	if not player then
		return false
	end

	if itemEx.itemid == 2739 then
		itemEx:transform(2737)
		itemEx:decay()
		player:addItem(2694, math.random(1, 3))
		local exp = math.random(1, 10)
		player:addExperience(exp, true)
		player:getPosition():sendMagicEffect(4)

		local USES_STORAGE = 2550
		local uses = player:getStorageValue(USES_STORAGE) + 1
		player:setStorageValue(USES_STORAGE, uses)

		if uses % 1000 == 0 then
			local reward = math.random(100, 2000)
			player:addExperience(reward, true)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You gained " .. reward .. " experience from successful gathering!")
			player:setStorageValue(USES_STORAGE, 0)
			player:getPosition():sendMagicEffect(28)
		end

		return true
	end
	return destroyItem(cid, itemEx, toPosition)
end
