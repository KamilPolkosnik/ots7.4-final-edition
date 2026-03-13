function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local town = Town(param) or Town(tonumber(param))
	if town then
		local templePos = town:getTemplePosition()
		if templePos then
			player:teleportTo(templePos, true)
			templePos:sendMagicEffect(CONST_ME_TELEPORT)
		end
	else
		player:sendCancelMessage("Town not found.")
	end
	return false
end
