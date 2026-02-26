 function onUse(cid, item, fromPosition, itemEx, toPosition)
	if(getCreatureStorage(cid, 1038) == -1) then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You completed the full green djinn quest.")
		doSendMagicEffect(getPlayerPosition(cid),CONST_ME_MAGIC_RED)
		doCreatureSetStorage(cid, 1038, 1) 
		doRemoveItem(item.uid, 1)
	else
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have already completed the green djinn quest.")
	end
	return true
end 