-- Register premium scroll action
local premiumScroll = Action()
premiumScroll:id(5546)
local PREMIUM_SCROLL_ACTION_15 = 60015
local PREMIUM_SCROLL_ACTION_60 = 60060
local PREMIUM_SCROLL_ACTION_120 = 60120

function premiumScroll.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local currentTime = os.time()
	local currentPremiumTime = math.max(0, player:getPremiumEndsAt() - currentTime)

	local days = 30
	local actionId = item:getActionId()
	if actionId == PREMIUM_SCROLL_ACTION_15 then
		days = 15
	elseif actionId == PREMIUM_SCROLL_ACTION_60 then
		days = 60
	elseif actionId == PREMIUM_SCROLL_ACTION_120 then
		days = 120
	end

	local secondsToAdd = days * 24 * 60 * 60

	player:setPremiumEndsAt(currentTime + (currentPremiumTime + secondsToAdd))
    -- Inform the player about the premium upgrade
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have been upgraded to premium account for " .. days .. " days!")
	player:getPosition():sendMagicEffect(29)
    -- Remove the premium scroll from the player's inventory
    item:remove(1)

    return true
end

premiumScroll:register()
