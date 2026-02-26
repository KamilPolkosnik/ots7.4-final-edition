-- ActionIDs:
-- 1001~1999: Level doors(level is actionID-1000)
-- 2001~2008: Vocation doors(voc is ActionID-2000. 1:Sorcerer, 2:Druid, 3:Paladin, 4:Knight, 5:MS, 6:ED, 7:RP, 8:EK)

function onUse(cid, item, frompos, item2, topos)
	local isLevelDoor = (item.actionid >= 1001 and item.actionid <= 1999)
	local isVocationDoor = (item.actionid >= 2001 and item.actionid <= 2008)

	
if item.actionid >= 1001 and item.actionid <= 1999 then	
	local requiredLevel = item.actionid - 1000
	if getPlayerLevel(cid) >= item.actionid-1000 then
	doTransformItem(item.uid, item.itemid+1)
	topos = {x=topos.x, y=topos.y, z=topos.z}
	local dir = getDirectionTo(getPlayerPosition(cid), frompos)
	doMoveCreature(cid, dir)
	else
	doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass. (You need lvl " .. requiredLevel .. " to open this door)")
	end
	
elseif item.actionid >= 2001 and item.actionid <= 2008 then
	if item.actionid == 2001 then
	if getPlayerVocation(cid) == 1 or getPlayerVocation(cid) == 5 then
	maypass = true
	end
	elseif item.actionid == 2002 then
	if getPlayerVocation(cid) == 2 or getPlayerVocation(cid) == 6 then
	maypass = true
	end
	elseif item.actionid == 2003 then 
	if getPlayerVocation(cid) == 3 or getPlayerVocation(cid) == 7 then
	maypass = true
	end
	elseif item.actionid == 2004 then 
	if getPlayerVocation(cid) == 4 or getPlayerVocation(cid) == 8 then
	maypass = true
	end
	elseif item.actionid == 2005 then
	if getPlayerVocation(cid) == 5 then
	maypass = true
	end
	elseif item.actionid == 2006 then 
	if getPlayerVocation(cid) == 6 then
	maypass = true
	end
	elseif item.actionid == 2007 then
	if getPlayerVocation(cid) == 7 then
	maypass = true
	end
	elseif item.actionid == 2008 then 
	if getPlayerVocation(cid) == 8 then
	maypass = true
	end
	else
	maypass = false
	end
	
	
	
	if (maypass == true) then
	doTransformItem(item.uid, item.itemid+1)
	topos = {x=topos.x, y=topos.y, z=topos.z}
	local dir = getDirectionTo(getPlayerPosition(cid), frompos)
	doMoveCreature(cid, dir)
	else
	doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Your vocation are not allowed to pass this door!")
	end
	
end


	local canGo = (queryTileAddThing(cid, frompos, bit.bor(2, 4)) == RETURNVALUE_NOERROR) --Veryfies if the player can go, ignoring blocking things
	if not(canGo) then
		return FALSE
	end
	
	return TRUE
end
