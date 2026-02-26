function onUse(cid, item, frompos, item2, topos)
	if getPlayerStorageValue(cid,1345) <= 0 then
		doCreatureSetStorage(cid, 1345, 1)
		doSendMagicEffect(getThingPos(cid), 13)
		doPlayerSendTextMessage(cid, 22, "You have upgraded your character. You can ask Quentin in Thais temple for {all} blessings.")
		doRemoveItem(item.uid, 1)
	else
		doPlayerSendTextMessage(cid, 22, "Your character is already upgraded.")
	end
		
	return true
end