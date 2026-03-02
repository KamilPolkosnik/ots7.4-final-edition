local EXP_BOOST_STORAGE = 78011

local function formatDuration(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end

function onSay(player, words, param)
	local expiresAt = player:getStorageValue(EXP_BOOST_STORAGE)
	local now = os.time()

	if expiresAt <= now then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "EXP boost is not active. You can check your boost time anytime with !expboost.")
		return false
	end

	local remaining = formatDuration(expiresAt - now)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Active EXP boost: +30%. Remaining time: " .. remaining .. ". You can check your boost time anytime with !expboost.")
	return false
end
