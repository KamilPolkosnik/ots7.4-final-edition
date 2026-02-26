 function onUse(cid, item, fromPosition, itemEx, toPosition)
	if(getCreatureStorage(cid, 1015) == -1) then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You completed the full blue djinn quest.")
		doSendMagicEffect(getPlayerPosition(cid),CONST_ME_MAGIC_RED)
		doCreatureSetStorage(cid, 1015, 1) 
		doRemoveItem(item.uid, 1)
	else
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have already completed the blue djinn quest.")
	end
	return true
end 