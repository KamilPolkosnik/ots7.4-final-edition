function getRandomPositionAround(pos, radius)
    local newPos = {x = pos.x, y = pos.y, z = pos.z}
    local attempts = 10 -- Max number of attempts to find a valid position
    while attempts > 0 do
        newPos.x = pos.x + math.random(-radius, radius)
        newPos.y = pos.y + math.random(-radius, radius)
        if newPos.x ~= pos.x or newPos.y ~= pos.y then
            return newPos
        end
        attempts = attempts - 1
    end
    return nil -- Return nil if no valid position found
end

function onUse(player, item, frompos, item2, topos)
    local x, y, z = topos.x, topos.y, topos.z
    local radius = 1 -- Radius around the player

    if item.itemid == 1945 then
        player:setStorageValue(156001, 2)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "OOGA BOOGA !!!")
        doTransformItem(item.uid, 1946) -- Change lever appearance to 1946
        local lookType = 199
		local playerOutfit = player:getOutfit()
		playerOutfit.lookType = lookType
		player:setOutfit(playerOutfit)
        -- Add 1 gold to a random tile around the player, excluding the lever tile
        local randomPos = getRandomPositionAround(topos, radius)
        if randomPos then
            doCreateItem(2148, 1, randomPos)
        end
    elseif item.itemid == 1946 then
        player:setStorageValue(156001, 1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "OOGA BOOGA !!!")
        doTransformItem(item.uid, 1945) -- Change lever appearance to 1945
        -- Add 1 gold to a random tile around the player, excluding the lever tile
		local lookType = 199
		local playerOutfit = player:getOutfit()
		playerOutfit.lookType = lookType
		player:setOutfit(playerOutfit)
        local randomPos = getRandomPositionAround(topos, radius)
        if randomPos then
            doCreateItem(2148, 1, randomPos)
        end
    else
        player:sendCancelMessage("Sorry, not possible.")
    end
    return true
end
