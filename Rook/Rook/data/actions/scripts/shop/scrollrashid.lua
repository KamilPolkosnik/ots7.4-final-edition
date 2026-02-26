function onUse(cid, item, frompos, item2, topos)
	if getPlayerStorageValue(cid,1347) <= 0 then
		doCreatureSetStorage(cid, 1347, 1)
		doSendMagicEffect(getThingPos(cid), 13)
		doPlayerSendTextMessage(cid, 22, "You have upgraded your character. You can trade now with Rashid.")
		doRemoveItem(item.uid, 1)
	else
		doPlayerSendTextMessage(cid, 22, "Your character is already upgraded.")
	end
		
	return true
end