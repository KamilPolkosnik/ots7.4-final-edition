
--[[
    Little Quest Chests + Oens upgrade itemlevel + Daily quest
    Create By: 𝓜𝓲𝓵𝓵𝓱𝓲𝓸𝓻𝓮 𝓑𝓣 Edited by Idler
    TFS Version: 1.5



local storageBase = 9000000
local actionId = 65535
local questCooldown = 24 * 60 * 60 -- 24 hours in seconds

local action = Action()

function action.onUse(player, chest, fromPos, target, toPos, isHotkey)
    local questId = chest:getUniqueId()
    if not chest:getType():isContainer() then
        error(string.format("[Error - LittleQuestChests::%d] Item %d is not a container.", questId, chest:getId()))
    end

    local lastCompletionTime = player:getStorageValue(storageBase + questId) or 0
	local currentTime = os.time()

	if currentTime - lastCompletionTime < questCooldown then
		local remainingSeconds = questCooldown - (currentTime - lastCompletionTime)
		local remainingHours = math.floor(remainingSeconds / 3600)
		local remainingMinutes = math.floor((remainingSeconds % 3600) / 60)
		local remainingSecondsDisplay = remainingSeconds % 60

		local remainingTimeString = string.format("%d hours, %d minutes, and %d seconds", remainingHours, remainingMinutes, remainingSecondsDisplay)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You need to wait " .. remainingTimeString .. " before you can complete this quest again.")
		return true
	end

    local items = chest:getItems()
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
    
    local plevel = player:getLevel()
    player:setStorageValue(storageBase + questId, currentTime) -- Set last completion time
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("You have found %s.", chest:getContentDescription()))
    for _, item in pairs(items) do
        item:setItemLevel(math.random(plevel*0.8,plevel*2), true)
        item:unidentify()
        local item = player:addItemEx(item:clone(), true)
    end
    return true
end

action:aid(actionId)
action:register()

]]--

--[[
    Little Quest Chests
    Create By: 𝓜𝓲𝓵𝓵𝓱𝓲𝓸𝓻𝓮 𝓑𝓣
    TFS Version: 1.5
]]--

local storageBase = 9000000
local actionId = 65535

local action = Action()

function action.onUse(player, chest, fromPos, target, toPos, isHotkey)
    local questId = chest:getUniqueId()
    if not chest:getType():isContainer() then
        error(string.format("[Error - LittleQuestChests::%d] Item %d is not a container.", questId, chest:getId()))
    end

    if player:getStorageValue(questId) ~= -1 then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "It is empty.")
        return true
    end

    local items = chest:getItems()
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
    player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("You have found %s.", chest:getContentDescription()))
    for _, item in pairs(items) do
        player:addItemEx(item:clone(), true)
    end
    return true
end

action:aid(actionId)
action:register()