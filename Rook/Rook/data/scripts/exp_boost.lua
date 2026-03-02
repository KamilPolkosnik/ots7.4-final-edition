local EXP_BOOST_STORAGE = 78011
local EXP_BOOST_MULTIPLIER = 1.30
local EXP_BOOST_TICK_INTERVAL_MS = 1000
local LEGACY_ABSOLUTE_TIME_THRESHOLD = 1000000000

local function normalizeRemainingSeconds(rawValue)
	local now = os.time()
	local value = tonumber(rawValue) or -1

	if value < 0 then
		return 0
	end

	-- Legacy format: absolute expiration timestamp.
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
	local rawValue = tonumber(player:getStorageValue(EXP_BOOST_STORAGE)) or -1
	if rawValue < 0 then
		return 0
	end

	if rawValue >= LEGACY_ABSOLUTE_TIME_THRESHOLD then
		local remaining = normalizeRemainingSeconds(rawValue)
		if remaining > 0 then
			player:setStorageValue(EXP_BOOST_STORAGE, remaining)
			return remaining
		end
		player:setStorageValue(EXP_BOOST_STORAGE, -1)
		return 0
	end

	return rawValue
end

local GainExperienceEvent = EventCallback

function GainExperienceEvent.onGainExperience(player, source, exp, rawExp)
	if getRemainingSeconds(player) <= 0 then
		return exp
	end

	return math.ceil(exp * EXP_BOOST_MULTIPLIER)
end

GainExperienceEvent:register()

local ExpBoostTick = GlobalEvent("ExpBoostTick")

function ExpBoostTick.onThink(interval)
	local secondsToSubtract = math.max(1, math.floor((tonumber(interval) or EXP_BOOST_TICK_INTERVAL_MS) / 1000))

	for _, player in ipairs(Game.getPlayers()) do
		local remaining = getRemainingSeconds(player)
		if remaining > 0 then
			remaining = remaining - secondsToSubtract
			if remaining <= 0 then
				player:setStorageValue(EXP_BOOST_STORAGE, -1)
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Your extra experience time has ended.")
				if player.sendExtraStatsSnapshot then
					player:sendExtraStatsSnapshot()
				end
			else
				player:setStorageValue(EXP_BOOST_STORAGE, remaining)
			end
		end
	end

	return true
end

ExpBoostTick:interval(EXP_BOOST_TICK_INTERVAL_MS)
ExpBoostTick:register()
