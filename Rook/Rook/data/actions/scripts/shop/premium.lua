function onUse(cid, item, fromPosition, itemEx, toPosition)
if isPlayer(cid) then
	if getPlayerStorageValue(cid,34000) <= 0 then
doPlayerSendTextMessage(cid, 20, 'Your account is now upgraded to VIP Account!')
doSendMagicEffect(getPlayerPosition(cid),CONST_ME_MAGIC_RED)
		setPlayerStorageValue(cid,34000,1)
		doRemoveItem(item.uid, 1)
	else
	doPlayerSendTextMessage(cid,22,"Your account is VIP already.")
	end
end
return true
end