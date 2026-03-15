local PREMIUM_TOKEN_ITEM_ID = 5962 -- titanian token
local PREMIUM_TOKEN_STORAGE_NEXT_AT = 88261
local PREMIUM_TOKEN_INTERVAL_SECONDS = 3600 -- 60 minutes

local PremiumTitanianTokenReward = GlobalEvent("PremiumTitanianTokenReward")

function PremiumTitanianTokenReward.onThink(interval)
	local now = os.time()

	for _, player in ipairs(Game.getPlayers()) do
		if player and player:isPremium() then
			local nextAt = tonumber(player:getStorageValue(PREMIUM_TOKEN_STORAGE_NEXT_AT)) or -1

			if nextAt < 1 then
				player:setStorageValue(PREMIUM_TOKEN_STORAGE_NEXT_AT, now + PREMIUM_TOKEN_INTERVAL_SECONDS)
			elseif now >= nextAt then
				local added = player:addItem(PREMIUM_TOKEN_ITEM_ID, 1, false)
				if added then
					player:setStorageValue(PREMIUM_TOKEN_STORAGE_NEXT_AT, now + PREMIUM_TOKEN_INTERVAL_SECONDS)
					player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Premium reward: you received 1 titanian token.")
				end
			end
		end
	end

	return true
end

PremiumTitanianTokenReward:interval(10 * 1000)
PremiumTitanianTokenReward:register()
