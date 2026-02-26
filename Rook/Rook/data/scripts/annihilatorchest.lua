-- Register annihilator chest action
local annihilatorChest = Action()
annihilatorChest:aid(65533)

function annihilatorChest.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Check if player has already completed the quest
    if player:getStorageValue(8160) == 1 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "It is empty because you have already completed the quest.")
        return true
    end

    -- Check the unique id of the chest and give the appropriate reward
    local chestUniqueId = item:getUniqueId()
    local rewardItemId
    local rewardItemName
    if chestUniqueId == 8160 then
        rewardItemId = 2494 -- Demon Armor
        rewardItemName = "Demon Armor"
    elseif chestUniqueId == 8161 then
        rewardItemId = 2400 -- Magic Sword
        rewardItemName = "Magic Sword"
    elseif chestUniqueId == 8162 then
        rewardItemId = 2431 -- Stonecutter Axe
        rewardItemName = "Stonecutter Axe"
    elseif chestUniqueId == 8163 then
        rewardItemId = 2421 -- Thunder Hammer
        rewardItemName = "Thunder Hammer"
    end

    -- Check if a valid reward item id was found
    if rewardItemId then
        -- Give the reward to the player
        local reward = player:addItem(rewardItemId, 1)
		 local plevel = player:getLevel()
        reward:setItemLevel(math.random(plevel*0.8,plevel*2), true)
        reward:unidentify()
        -- Set storage to 1 to indicate quest completion
        player:setStorageValue(8160, 1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You found " .. rewardItemName .. "!")
    else
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "An error occurred. Reward could not be given.")
    end

    return true
end

annihilatorChest:register()
