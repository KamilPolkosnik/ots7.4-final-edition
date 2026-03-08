local function formatDuration(seconds)
	seconds = math.max(0, math.floor(tonumber(seconds) or 0))
	local days = math.floor(seconds / 86400)
	local hours = math.floor((seconds % 86400) / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if days > 0 then
		return string.format("%dd %02dh %02dm %02ds", days, hours, minutes, secs)
	end
	return string.format("%02dh %02dm %02ds", hours, minutes, secs)
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	if not player then
		return true
	end

	local fragTime = math.max(1, configManager.getNumber(configKeys.FRAG_TIME))
	local killsToRed = math.max(0, configManager.getNumber(configKeys.KILLS_TO_RED))
	local skullTime = math.max(0, tonumber(player:getSkullTime()) or 0)

	local frags = 0
	if skullTime > 0 then
		frags = math.ceil(skullTime / fragTime)
	end

	local toRed = 0
	if killsToRed > 0 then
		toRed = math.max(0, killsToRed - frags)
	end

	local nextDecrease = 0
	if skullTime > 0 then
		nextDecrease = skullTime % fragTime
		if nextDecrease == 0 then
			nextDecrease = fragTime
		end
	end

	local resetInfo = skullTime > 0 and formatDuration(skullTime) or "now"
	local nextInfo = nextDecrease > 0 and formatDuration(nextDecrease) or "now"

	local message =
		"Frags: " ..
		frags ..
		(killsToRed > 0 and (" | To red skull: " .. toRed .. " (red at " .. killsToRed .. ")") or "") ..
		" | Next frag decrease: " ..
		nextInfo ..
		" | Full frag reset: " ..
		resetInfo

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, message)
	doSendMagicEffect(player:getPosition(), CONST_ME_MAGIC_BLUE)
	return true
end
