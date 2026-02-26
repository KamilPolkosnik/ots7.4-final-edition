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

local machete = Action()

function machete.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target and target.itemid == 2782 then
		target:transform(2781)
		target:decay()
		return true
	end
	return destroyItem(player, target, toPosition)
end

machete:id(2420)
-- Disabled to avoid duplicate registration with legacy actions.xml tools/machete.lua
-- machete:register()
