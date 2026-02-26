local talk = TalkAction("/aol", "!aol")

function talk.onSay(player, words, param)
    local moneyNeeded = 50000
    if player:getMoney() >= moneyNeeded then
        player:removeMoney(moneyNeeded)
        player:addItem(2173, 1) -- Amulet of Loss ID is 2173
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have bought Amulet of Loss for " .. moneyNeeded .. " gold.")
    else
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You need " .. moneyNeeded .. " gold to buy Amulet of Loss.")
    end
end

talk:separator(" ")
talk:register()
