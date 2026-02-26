function onSay(player, words, param)
    if not player:getGroup():getAccess() then
        return true
    end

    local position = player:getPosition()
    local targetPosition = position:getNextPosition(player:getDirection())

    local tile = Tile(targetPosition)
    if not tile then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "There is no tile in front of you.")
        return false
    end

    local players = tile:getPlayers()
    if #players == 0 then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "There are no players in front of you.")
        return false
    end

    -- Add 7 days of premium to each player found
    local SECONDS_IN_DAY = 24 * 60 * 60
    local DAYS_TO_ADD = 7
    local secondsToAdd = SECONDS_IN_DAY * DAYS_TO_ADD

    for _, foundPlayer in ipairs(players) do
        local currentPremiumEndsAt = foundPlayer:getPremiumEnd()
        local newPremiumEndsAt = currentPremiumEndsAt + secondsToAdd
        foundPlayer:setPremiumEnd(newPremiumEndsAt)
        foundPlayer:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have received 7 days of premium time.")
    end

    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Premium time has been added to players in front of you.")
    position:sendMagicEffect(CONST_ME_MAGIC_GREEN)
end
