-- Register premium scroll action
local premiumScroll = Action()
premiumScroll:id(5546)

function premiumScroll.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local currentTime = os.time()
	local currentPremiumTime = math.max(0, player:getPremiumEndsAt() - currentTime)

	local days = 30
	local secondsToAdd = days * 24 * 60 * 60

	player:setPremiumEndsAt(currentTime + (currentPremiumTime + secondsToAdd))
    -- Inform the player about the premium upgrade
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have been upgraded to premium account for 30 days!")
	player:getPosition():sendMagicEffect(84)
    -- Remove the premium scroll from the player's inventory
    item:remove(1)

    return true
end

premiumScroll:register()
