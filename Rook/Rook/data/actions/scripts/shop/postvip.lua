function onUse(cid, item, frompos, item2, topos)
	if getPlayerStorageValue(cid,6681) <= 0 then
		doCreatureSetStorage(cid, 6681, 1)
		doSendMagicEffect(getThingPos(cid), 13)
		doPlayerSendTextMessage(cid, 22, "You have completed the postman quest.")
		doRemoveItem(item.uid, 1)
	else
		doPlayerSendTextMessage(cid, 22, "You have already completed the postman quest.")
	end
		
	return true
end