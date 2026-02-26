function onUse(cid, item, frompos, item2, topos)
	if getPlayerLevel(cid) < 110 then
		doRemoveItem(item.uid, 1)
		doPlayerAddExp(cid, 100000)
		doSendAnimatedText(getPlayerPosition(cid), "100000", 215)	
	else
	doPlayerSendTextMessage(cid, 22, "Only players of level 109 and below may use this item!")
	end
end