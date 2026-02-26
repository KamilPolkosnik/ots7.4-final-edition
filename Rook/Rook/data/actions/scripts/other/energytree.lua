function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:getStorageValue(4000) == -1 then
        player:addAura(2)
        player:setStorageValue(4000, 1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have obtained the aura of energy.")
        player:getPosition():sendMagicEffect(13)
    else
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You already have this essence.")
        player:getPosition():sendMagicEffect(14)
    end
    return true
end
