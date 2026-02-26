
function onStepIn(creature, item, position, toPosition)
	local souls = 419
	
    message = "You need " .. souls .. " to enter this place"
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, message)
end


