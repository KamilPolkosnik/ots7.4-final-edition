local EXP_BOOST_STORAGE = 78011
local LEGACY_ABSOLUTE_TIME_THRESHOLD = 1000000000

local function formatDuration(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end

local function normalizeRemainingSeconds(rawValue)
	local now = os.time()
	local value = tonumber(rawValue) or -1

	if value < 0 then
		return 0
	end

	if value >= LEGACY_ABSOLUTE_TIME_THRESHOLD then
		local remaining = value - now
		if remaining > 0 then
			return remaining
		end
		return 0
	end

	return value
end

local function getRemainingSeconds(player)
	local remaining = normalizeRemainingSeconds(player:getStorageValue(EXP_BOOST_STORAGE))
	if remaining > 0 then
		player:setStorageValue(EXP_BOOST_STORAGE, remaining)
	else
		player:setStorageValue(EXP_BOOST_STORAGE, -1)
	end
	return remaining
end

function onSay(player, words, param)
	local remainingSeconds = getRemainingSeconds(player)
	if remainingSeconds <= 0 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "EXP boost is not active.")
		return false
	end

	local remaining = formatDuration(remainingSeconds)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Active EXP boost: +30%. Remaining online time: " .. remaining .. ".")
	return false
end
