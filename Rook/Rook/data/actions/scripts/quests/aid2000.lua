local posToAid = dofile('data/actions/scripts/quests/tvp_pos_to_aid.lua')
local chests = dofile('data/actions/scripts/quests/tvp_chests.lua')

local function onUseQuest(player, item, chest)
	local storageValue = chest.storageValue
	local isGM = false
	local group = player:getGroup()
	if group and (group:getAccess() or group:getId() >= 4) then
		isGM = true
	elseif player.getAccountType then
		isGM = player:getAccountType() >= (ACCOUNT_TYPE_GAMEMASTER or 4)
	end

	if not isGM and player:getStorageValue(storageValue) ~= -1 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "The " .. item:getName() .. " is empty.")
		return true
	end

	local mainItemType = ItemType(chest.item.id)
	if not mainItemType then
		return false
	end

	local mainCount = chest.item.count or chest.item.subtype or chest.item.charges or 1
	local rewardName = mainItemType:getName()
	if mainItemType:isStackable() and (mainCount or 0) > 1 then
		rewardName = mainCount .. " " .. mainItemType:getPluralName()
	end

	if mainItemType:getArticle():len() > 0 and math.max(1, mainCount or 0) <= 1 then
		rewardName = mainItemType:getArticle() .. " " .. rewardName
	end

	local rewardWeight = mainItemType:getWeight(mainCount)

	if chest.content then
		for _, reward in ipairs(chest.content) do
			local itemType = ItemType(reward.id)
			local rewardCount = reward.count or reward.subtype or reward.charges or 1
			rewardWeight = rewardWeight + itemType:getWeight(rewardCount)
		end
	end

	local term = "it is"
	if mainItemType:isStackable() and (mainCount or 0) > 1 then
		term = "they are"
	end

	local noCapacityMessage = string.format("You have found %s. Weighing %d.%02d oz %s too heavy.", rewardName, rewardWeight / 100, rewardWeight % 100, term)

	if rewardWeight > player:getFreeCapacity() and not getPlayerFlagValue(player, PlayerFlag_HasInfiniteCapacity) then
		player:sendTextMessage(MESSAGE_INFO_DESCR, noCapacityMessage)
		return true
	end

	local reward = Game.createItem(mainItemType:getId(), mainCount)
	if not reward then
		return false
	end

	if chest.item.text then
		reward:setAttribute(ITEM_ATTRIBUTE_TEXT, chest.item.text)
	end

	if chest.item.keynumber then
		if ITEM_ATTRIBUTE_KEYNUMBER then
			reward:setAttribute(ITEM_ATTRIBUTE_KEYNUMBER, chest.item.keynumber)
		end
		if reward:getActionId() == 0 then
			reward:setActionId(chest.item.keynumber)
		end
	end

	if chest.content and mainItemType:isContainer() then
		for _, nextReward in ipairs(chest.content) do
			local nextCount = nextReward.count or nextReward.subtype or nextReward.charges or 1
			local nextItem = reward:addItem(nextReward.id, nextCount)
			if nextReward.text then
				nextItem:setAttribute(ITEM_ATTRIBUTE_TEXT, nextReward.text)
			end
			if nextReward.keynumber then
				if ITEM_ATTRIBUTE_KEYNUMBER then
					nextItem:setAttribute(ITEM_ATTRIBUTE_KEYNUMBER, nextReward.keynumber)
				end
				if nextItem:getActionId() == 0 then
					nextItem:setActionId(nextReward.keynumber)
				end
			end
		end
	end

	if player:getFreeCapacity() >= reward:getWeight() then
		if player:addItemEx(reward) == RETURNVALUE_NOERROR then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "You have found " .. rewardName .. ".")
			if not isGM and not getPlayerFlagValue(player, PlayerFlag_HasInfiniteCapacity) then
				player:setStorageValue(storageValue, 1)
			end
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "You have found " .. rewardName .. ", but you have no room to take it.")
			reward:remove()
		end
	else
		player:sendTextMessage(MESSAGE_INFO_DESCR, noCapacityMessage)
		reward:remove()
	end

	return true
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not item or not player then
		return true
	end

	local pos = item:getPosition()
	local key = string.format("%d,%d,%d", pos.x, pos.y, pos.z)
	local aid = posToAid[key]
	if not aid then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "It is empty.")
		return true
	end

	local chest = chests[aid]
	if not chest then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "It is empty.")
		return true
	end

	return onUseQuest(player, item, chest)
end
