local function consumeScroll(cid, item)
	if doRemoveItem(item.uid, 1) then
		return true
	end

	local removed = doPlayerRemoveItem(cid, item.itemid, 1)
	return removed == true or removed == 1
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	if not player then
		return true
	end

	local skullTime = tonumber(player:getSkullTime()) or 0
	if skullTime <= 0 then
		doPlayerSendCancel(cid, "You do not have any unjustified kills.")
		return true
	end

	if not consumeScroll(cid, item) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Couldn't consume the frag remover. Try again.")
		return true
	end

	player:setSkullTime(0)
	player:setSkull(SKULL_NONE)
	player:save()

	doSendMagicEffect(player:getPosition(), CONST_ME_MAGIC_RED)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Your frags and skull have been removed.")
	return true
end
