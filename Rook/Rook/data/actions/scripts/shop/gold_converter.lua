local function consumeCharge(item)
	if item.type and item.type > 1 then
		doChangeTypeItem(item.uid, item.type - 1)
	else
		doRemoveItem(item.uid, 1)
	end
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	if doPlayerRemoveItem(cid, ITEM_PLATINUM_COIN, 100) then
		doPlayerAddItem(cid, ITEM_CRYSTAL_COIN, 1)
		consumeCharge(item)
		doSendMagicEffect(getThingPos(cid), CONST_ME_MAGIC_GREEN)
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Converted 100 platinum coins into 1 crystal coin.")
		return true
	end

	if doPlayerRemoveItem(cid, ITEM_GOLD_COIN, 100) then
		doPlayerAddItem(cid, ITEM_PLATINUM_COIN, 1)
		consumeCharge(item)
		doSendMagicEffect(getThingPos(cid), CONST_ME_MAGIC_GREEN)
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Converted 100 gold coins into 1 platinum coin.")
		return true
	end

	doPlayerSendCancel(cid, "You need at least 100 gold coins or 100 platinum coins.")
	return true
end
