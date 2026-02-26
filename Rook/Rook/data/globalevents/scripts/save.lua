function onThink(interval)
    local players = Game.getPlayers()
    for i = 1, #players do
        local player = players[i]
        if player:save() then
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your data has been successfully saved.")
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Failed to save your data.")
        end
    end
    Game.broadcastMessage("All player data has been successfully saved.", MESSAGE_STATUS_CONSOLE_BLUE)
    return true
end
