function onUse(cid, item, fromPosition, itemEx, toPosition)
if isPlayer(cid) then
	if (getTilePzInfo(getPlayerPosition(cid)) == TRUE) then
	playername = getPlayerName(cid)
	doAddPlayerBanishment(playername, 2, -1, "Visit >My Account< on website to change your name.", getPlayerGUID(cid))
	doPlayerSendTextMessage(cid,22,"Visit >My Account< on website to change your name.")
	doSendMagicEffect(getPlayerPosition(cid),CONST_ME_MAGIC_RED)
	doRemoveItem(item.uid, 1)
	else
	doPlayerSendTextMessage(cid,22,"You can only use this item inside protection zone!")
	end
end
return true
end