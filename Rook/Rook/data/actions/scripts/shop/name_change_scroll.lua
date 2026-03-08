local NAME_CHANGE_PENDING_STORAGE = 78190
local NAME_CHANGE_MAX_LENGTH = 25
local NAME_CHANGE_PENDING_TTL = 180
local NAME_CHANGE_SCROLL_ITEM_ID = 5747

function onUse(cid, item, fromPosition, target, toPosition, isHotkey)
	local player = Player(cid)
	if not player then
		return true
	end

	player:setStorageValue(NAME_CHANGE_PENDING_STORAGE, os.time() + NAME_CHANGE_PENDING_TTL)

	player:sendTextMessage(MESSAGE_INFO_DESCR, "Enter new name (3-25 letters/spaces, no numbers, unique).")
	if not player:showTextDialog(NAME_CHANGE_SCROLL_ITEM_ID, "", true, NAME_CHANGE_MAX_LENGTH) then
		player:setStorageValue(NAME_CHANGE_PENDING_STORAGE, -1)
		player:sendCancelMessage("Could not open name change window. Try again.")
	end

	return true
end
