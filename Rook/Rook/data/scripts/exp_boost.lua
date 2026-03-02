local EXP_BOOST_STORAGE = 78011
local EXP_BOOST_MULTIPLIER = 1.30

local GainExperienceEvent = EventCallback

function GainExperienceEvent.onGainExperience(player, source, exp, rawExp)
	local expiresAt = player:getStorageValue(EXP_BOOST_STORAGE)
	local now = os.time()

	if expiresAt <= now then
		if expiresAt ~= -1 then
			player:setStorageValue(EXP_BOOST_STORAGE, -1)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Your extra experience time has ended.")
		end
		return exp
	end

	return math.ceil(exp * EXP_BOOST_MULTIPLIER)
end

GainExperienceEvent:register()

