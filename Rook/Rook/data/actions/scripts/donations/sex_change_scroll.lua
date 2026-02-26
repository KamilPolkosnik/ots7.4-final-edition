function onUse(cid, item, frompos, item2, topos)
if (getTilePzInfo(getPlayerPosition(cid)) == TRUE) then
playername = getPlayerName(cid)
if getPlayerSex(cid) == 0 then
newsex = 1
else
newsex = 0
end
	doRemoveItem(item.uid, 1)
	doRemoveCreature(cid) 
	mysqlQuery("UPDATE `players` SET `sex` = ".. newsex .." WHERE `players`.`name` =\"".. playername .."\";", "set")
else
doPlayerSendTextMessage(cid, 22, "You can only use this item inside protection zone!")
end
end