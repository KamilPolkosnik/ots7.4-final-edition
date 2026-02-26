--[[
    Little Quest Chests
    Create By: 𝓜𝓲𝓵𝓵𝓱𝓲𝓸𝓻𝓮 𝓑𝓣
    TFS Version: 1.5
]]--

local actionId = 65535

function onUse(player, chest, fromPos, target, toPos, isHotkey)
    local questId = chest:getUniqueId()
    if not chest:getType():isContainer() then
        error(string.format("[Error - LittleQuestChests::%d] Item %d is not a container.", questId, chest:getId()))
    end

    if player:getStorageValue(questId) ~= -1 then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "It is empty.")
        return true
    end

    -- Replace the following line with the correct method for your server
    local items = getContainerItems(chest)

    if #items == 0 then
        error(string.format("[Error - LittleQuestChests::%d] No items found for quest %d", questId, questId))
    end

    local totalWeight = 0
    for _, item in pairs(items) do
        totalWeight = totalWeight + item:getWeight()
    end

    if player:getFreeCapacity() < totalWeight then
        player:sendCancelMessage(RETURNVALUE_NOTENOUGHCAPACITY)
        return true
    end

    player:setStorageValue(questId, 1)
    player:sendTextMessage(MESSAGE_LOOT, string.format("You have found %s.", chest:getContentDescription()))
    for _, item in pairs(items) do
        player:addItemEx(item:clone(), true)
    end
    return true
end
