-- Player with storage value of the item's actionid set to 1 can open

function onUse(cid, item, frompos, item2, topos)
	if(item.actionid == 0) then
		-- Make it a normal door
		doTransformItem(item.uid, item.itemid+1)
		return true
	end

	
	local canEnter = (getPlayerStorageValue(cid, item.actionid) == 1)
	if not(canEnter) then
	doPlayerSendTextMessage(cid,22,'The door is sealed against unwanted intruders.')
	return true
	else
		doTransformItem(item.uid, item.itemid+1)
		topos = {x=topos.x, y=topos.y, z=topos.z}
		doTeleportThing(cid,topos)	
	end

	local canGo = (queryTileAddThing(cid, frompos, bit.bor(2, 4)) == RETURNVALUE_NOERROR) --Veryfies if the player can go, ignoring blocking things
	if not(canGo) then
		return false
	end
	return true
end

