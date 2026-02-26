

function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end
	creature:sendTextMessage(MESSAGE_EVENT_ADVANCE, "As you step into the pulsating wall of energy, magic swiftly whisks you away from the vicinity.")
	creature:teleportTo(Position(32370, 32194, 8))
end

