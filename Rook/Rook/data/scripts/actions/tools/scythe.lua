local function destroyItem(player, target, toPosition)
	if not target or not target:isItem() then
		return false
	end

	if target:hasAttribute(ITEM_ATTRIBUTE_UNIQUEID) or target:hasAttribute(ITEM_ATTRIBUTE_ACTIONID) then
		return false
	end

	if toPosition.x == CONTAINER_POSITION then
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		return true
	end

	local destroyId = ItemType(target.itemid):getDestroyId()
	if destroyId == 0 then
		return false
	end

	if math.random(7) == 1 then
		local item = Game.createItem(destroyId, 1, toPosition)
		if item then
			item:decay()
		end

		if target:isContainer() then
			for i = target:getSize() - 1, 0, -1 do
				local containerItem = target:getItem(i)
				if containerItem then
					containerItem:moveTo(toPosition)
				end
			end
		end

		target:remove(1)
	end

	toPosition:sendMagicEffect(CONST_ME_POFF)
	return true
end

local scythe = Action()

function scythe.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target and target.itemid == 2739 then
		target:transform(2737)
		target:decay()
		player:addItem(2694, math.random(1, 3))
		local exp = math.random(1, 10)
		player:addExperience(exp, true)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)

		local usesStorage = 2550
		local uses = player:getStorageValue(usesStorage) + 1
		player:setStorageValue(usesStorage, uses)

		if uses % 1000 == 0 then
			local reward = math.random(100, 2000)
			player:addExperience(reward, true)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You gained " .. reward .. " experience from successful gathering!")
			player:setStorageValue(usesStorage, 0)
			player:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)
		end

		return true
	end
	return destroyItem(player, target, toPosition)
end

scythe:id(2550)
-- Disabled to avoid duplicate registration with legacy actions.xml tools/scythe.lua
-- scythe:register()
