local function hasAllBlessings(cid)
	for i = 1, 5 do
		if not getPlayerBlessing(cid, i) then
			return false
		end
	end
	return true
end

local function grantAllBlessings(cid)
	for i = 1, 5 do
		if not getPlayerBlessing(cid, i) then
			doPlayerAddBlessing(cid, i)
		end
	end
end

local function consumeScroll(cid, item)
	if doRemoveItem(item.uid, 1) then
		return true
	end

	local removed = doPlayerRemoveItem(cid, item.itemid, 1)
	return removed == true or removed == 1
end

function onUse(cid, item, frompos, item2, topos)
	if hasAllBlessings(cid) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "You already have all 5 blessings. Use !bless to check your blessings.")
		return true
	end

	if not consumeScroll(cid, item) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Couldn't consume the blessing scroll. Try again.")
		return true
	end

	grantAllBlessings(cid)
	doSendMagicEffect(getThingPos(cid), 13)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "You received all 5 blessings. You can check them with !bless.")
	return true
end
