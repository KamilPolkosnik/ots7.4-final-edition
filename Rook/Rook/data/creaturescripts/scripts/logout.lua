function onLogout(player)
	local playerId = player:getId()
	if nextUseStaminaTime[playerId] then
		nextUseStaminaTime[playerId] = nil
	end

	if player.clearSkullSoulSummonLocks then
		player:clearSkullSoulSummonLocks()
	end
	return true
end
