function onUse(cid, item, frompos, item2, topos)
if item.uid == 9501 then
		if getPlayerStorageValue(cid,9501) <= 0 then
	if getPlayerItemCount(cid, 2344) >= 1 then
			if getPlayerFreeCap(cid) <= 13 then
					doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE,"You need 13 cap or more to use this!")
				return true
			end
				doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You have found a gemmed lamp.")
				doPlayerAddItem(cid, 5750, 1)
				doPlayerRemoveItem(cid, 2344, 1)
				setPlayerStorageValue(cid,9501,1)
				setPlayerStorageValue(cid,1014,1)
				doAddQuestPoint(cid)
		else
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You need a oil lamp to use this.")
		end
	else
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You cannot use this anymore.")
	end
elseif item.uid == 9502 then
		if getPlayerStorageValue(cid,9502) <= 0 then
	if getPlayerItemCount(cid, 2344) >= 1 then
			if getPlayerFreeCap(cid) <= 13 then
					doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE,"You need 13 cap or more to use this!")
				return true
			end
				doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You have found a gemmed lamp.")
				doPlayerAddItem(cid, 5750, 1)
				doPlayerRemoveItem(cid, 2344, 1)
				setPlayerStorageValue(cid,9502,1)
				setPlayerStorageValue(cid,1037,1)
				doAddQuestPoint(cid)
		else
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You need a oil lamp to use this.")
		end
	else
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You cannot use this anymore.")
	end
-----
-----
else	
  return 0
end
return 1
end

