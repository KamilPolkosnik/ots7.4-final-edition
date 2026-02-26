function onUse(cid, item, frompos, item2, topos)
if (getTilePzInfo(getPlayerPosition(cid)) == TRUE) then
playername = getPlayerName(cid)
	doRemoveItem(item.uid, 1)
	doRemoveCreature(cid) 
	mysqlQuery("UPDATE `players` SET `name_locked` = 1 WHERE `players`.`name` =\"".. playername .."\";", "set")
else
doPlayerSendTextMessage(cid, 22, "You can only use this item inside protection zone!")
end
end