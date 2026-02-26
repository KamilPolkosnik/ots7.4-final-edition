-- 10544 = PoI Arcane Staff.
-- 10545 = PoI Epee.
-- 10546 = PoI Crystal Arrow.
-- 10547 = PoI Soft Boots.
-- 10548 = PoI BackPack of Holding.
-- 10549 = PoI Panda Bear.
-- 10550 = PoI Frozen Starlight.
-- 10551 = PoI Ornamented Ankh
-- 10552 = Holy Tible

function onUse(cid, item, frompos, item2, topos)

	if item.uid == 10544 then
if getPlayerStorageValue(cid,10544) == -1 then
 	doPlayerSendTextMessage(cid,22,"You have chosen a Winged Helmet.")
 	doPlayerAddItem(cid,2474,1)
 	setPlayerStorageValue(cid,10544,1)
 else
 	doPlayerSendTextMessage(cid,22,"The chest is empty.")
 end
 
	elseif item.uid == 10545 then
if getPlayerStorageValue(cid,10544) == -1 then
 	doPlayerSendTextMessage(cid,22,"You have chosen a a pair of Soft Boots.")
 	doPlayerAddItem(cid,2358,1)
 	setPlayerStorageValue(cid,10544,1)
 else
 	doPlayerSendTextMessage(cid,22,"The chest is empty.")
 end
 
 	elseif item.uid == 10546 then
if getPlayerStorageValue(cid,10544) == -1 then
 	doPlayerSendTextMessage(cid,22,"You have chosen a Thunder Hammer.")
 	doPlayerAddItem(cid,2421,1)
 	setPlayerStorageValue(cid,10544,1)
 else
 	doPlayerSendTextMessage(cid,22,"The chest is empty.")
 end
 
	elseif item.uid == 10547 then
if getPlayerStorageValue(cid,10547) == -1 then
 	doPlayerSendTextMessage(cid,22,"You have found 10 crystal coins.")
 	doPlayerAddItem(cid,2160,10)
 	setPlayerStorageValue(cid,10547,1)
 else
 	doPlayerSendTextMessage(cid,22,"The chest is empty.")
 end

	elseif item.uid == 10548 then
if getPlayerStorageValue(cid,10548) == -1 then
	doPlayerSendTextMessage(cid,22,"You have found a yellow spell wand.")
 	doPlayerAddItem(cid,2189,1)
 	setPlayerStorageValue(cid,10548,1)
 else
 	doPlayerSendTextMessage(cid,22,"The chest is empty.")
 end


	elseif item.uid == 10549 then
if getPlayerStorageValue(cid,10549) == -1 then
	doPlayerSendTextMessage(cid,22,"You have found a green spell wand.")
 	doPlayerAddItem(cid,2188,1)
 	setPlayerStorageValue(cid,10549,1)
 else
 	doPlayerSendTextMessage(cid,22,"The chest is empty.")
 end
	elseif item.uid == 10550 then
if getPlayerStorageValue(cid,10550) == -1 then
	doPlayerSendTextMessage(cid,22,"You have found a blue spell wand.")
 	doPlayerAddItem(cid,2190,1)
 	setPlayerStorageValue(cid,10550,1)
 else
 	doPlayerSendTextMessage(cid,22,"The chest is empty.")
 end
 
 	elseif item.uid == 10551 then
if getPlayerStorageValue(cid,10551) == -1 then
 	doPlayerSendTextMessage(cid,22,"You have found a red spell wand.")
 	doPlayerAddItem(cid,2191,1)
 	setPlayerStorageValue(cid,10551,1)
 else
 	doPlayerSendTextMessage(cid,22,"The chest is empty.")
 end
	elseif item.uid == 10552 then
 
if getPlayerStorageValue(cid,10552) == -1 then
 	doPlayerSendTextMessage(cid,22,"You have found the Holy Tible.")
 	local book = doPlayerAddItem(cid,1970,1)
 	doSetItemText(book,"Banor I praise your name.\nBe with me in the battle.\nBe my shield, let me be your sword.\nI will honour the godly spark in my soul. May it flourish and grow.")
 	setPlayerStorageValue(cid,10552,1)
 else
 	doPlayerSendTextMessage(cid,22,"The chest is empty.")
 end

end
return TRUE
end