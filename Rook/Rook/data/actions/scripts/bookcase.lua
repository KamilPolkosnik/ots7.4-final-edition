function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Generate a unique storage key based on the bookcase's position
    local storagePosition = string.format("%d%d%d", toPosition.x, toPosition.y, toPosition.z)
    
    -- Check if there's an exhaust storage set for this position
    local exhaustStorage = "exhaust_" .. storagePosition
    local exhaustTime = player:getStorageValue(exhaustStorage) or 0
    
    -- Check if the exhaust time has passed
    if exhaustTime <= os.time() then
        -- Reset the exhaust time to the next available time
        local nextExhaustTime = os.time() + 24 * 60 * 60 -- 24 hours in seconds
        player:setStorageValue(exhaustStorage, nextExhaustTime)
        
        -- Define the item pool
        local itemPool = {
            {itemId = 2148, count = 10}, -- Gold coins
            {itemId = 2223, count = 1},  -- Some item
            {itemId = 1987, count = 1},  -- Some item
            {itemId = 2461, count = 1},  -- Some item
        }

        -- Determine the number of items to give (up to 5 with decreasing probability)
        local itemCount = math.random(5)
        
        -- Give items based on the determined count
        for i = 1, itemCount do
            local selectedItem = itemPool[math.random(#itemPool)]
            player:addItem(selectedItem.itemId, selectedItem.count)
        end
        
        if itemCount > 0 then
            player:sendTextMessage(MESSAGE_EVENT_DEFAULT, "You found something in the bookcase!")
        else
            player:sendTextMessage(MESSAGE_EVENT_DEFAULT, "You found nothing in the bookcase.")
        end
    else
        player:sendTextMessage(MESSAGE_EVENT_DEFAULT, "The bookcase has been looted recently. Come back later.")
    end
    
    return true
end
