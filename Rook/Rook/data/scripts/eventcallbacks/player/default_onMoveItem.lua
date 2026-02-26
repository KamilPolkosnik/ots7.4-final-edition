local ec = EventCallback

ec.onMoveItem = function(self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	-- Prevent moving quest reward chests (keeps non-quest chests movable).
	local itemId = item:getId()
	if (itemId == 1738 or itemId == 1739 or itemId == 1740 or itemId == 1741 or
		itemId == 1746 or itemId == 1747 or itemId == 1748 or itemId == 1749) then
		local aid = item:getActionId()
		if aid == 2000 or aid == 1203 then
			self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			return false
		end
	end

	if item:getAttribute("wrapid") ~= 0 then
		local tile = Tile(toPosition)
		if (fromPosition.x ~= CONTAINER_POSITION and toPosition.x ~= CONTAINER_POSITION) or tile and not tile:getHouse() then
			if tile and not tile:getHouse() then
				self:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
				return false
			end
		end
	end

	if toPosition.x ~= CONTAINER_POSITION then
		return true
	end

	if item:getTopParent() == self and bit.band(toPosition.y, 0x40) == 0 then
		local itemType, moveItem = ItemType(item:getId())
		if bit.band(itemType:getSlotPosition(), SLOTP_TWO_HAND) ~= 0 and toPosition.y == CONST_SLOT_LEFT then
			moveItem = self:getSlotItem(CONST_SLOT_RIGHT)
		elseif itemType:getWeaponType() == WEAPON_SHIELD and toPosition.y == CONST_SLOT_RIGHT then
			moveItem = self:getSlotItem(CONST_SLOT_LEFT)
			if moveItem and bit.band(ItemType(moveItem:getId()):getSlotPosition(), SLOTP_TWO_HAND) == 0 then
				return true
			end
		end

		if moveItem then
			local parent = item:getParent()
			if parent:isContainer() and parent:getSize() == parent:getCapacity() then
				self:sendTextMessage(MESSAGE_STATUS_SMALL, Game.getReturnMessage(RETURNVALUE_CONTAINERNOTENOUGHROOM))
				return false
			else
				return moveItem:moveTo(parent)
			end
		end
	end

	return true
end

ec:register()
