local config = {
	time = 1 * 60 * 60, -- 1 hour
	storage = 78011
}

local function consumeScroll(cid, item)
	if doRemoveItem(item.uid, 1) then
		return true
	end

	local removed = doPlayerRemoveItem(cid, item.itemid, 1)
	return removed == true or removed == 1
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	local expiresAt = getCreatureStorage(cid, config.storage)
	if expiresAt > os.time() then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "You still have extra experience time left. Use !expboost to check the remaining time.")
		return true
	end

	if not consumeScroll(cid, item) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Couldn't consume the experience booster. Try again.")
		return true
	end

	doCreatureSetStorage(cid, config.storage, os.time() + config.time)
	doSendMagicEffect(getPlayerPosition(cid), CONST_ME_MAGIC_RED)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "You have now 30% experience boost. It will last for 1 hour. Use !expboost to check the remaining time.")
	return true
end
