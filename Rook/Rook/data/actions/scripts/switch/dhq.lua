local DHQ = {
	leverPos = {x = 33330, y = 31591, z = 15},
	gatePos = {x = 33314, y = 31592, z = 15},
	teleportPos = {x = 33316, y = 31591, z = 15},
	teleportDest = {x = 33328, y = 31592, z = 14},
	playerDumpPos = {x = 33316, y = 31592, z = 15},
	gateClosedId = 1355,
	gateOpenId = 3621,
	resetMs = 120 * 1000
}

local function isDhqSwitch(item)
	return (item.uid == 4560) or (item.actionid == 50666) or (item.actionid == 2012)
end

local function removeItemAt(pos, itemId)
	local it = getTileItemById(pos, itemId)
	if it and it.uid and it.uid > 0 then
		doRemoveItem(it.uid, 1)
		return true
	end
	return false
end

local function resetDhq()
	removeItemAt(DHQ.teleportPos, 1387)
	removeItemAt(DHQ.gatePos, DHQ.gateOpenId)

	if not getTileItemById(DHQ.gatePos, DHQ.gateClosedId).uid or getTileItemById(DHQ.gatePos, DHQ.gateClosedId).uid <= 0 then
		doCreateItem(DHQ.gateClosedId, 1, DHQ.gatePos)
	end

	local switchOn = getTileItemById(DHQ.leverPos, 1946)
	if switchOn and switchOn.uid and switchOn.uid > 0 then
		doTransformItem(switchOn.uid, 1945)
		return
	end

	local leverOn = getTileItemById(DHQ.leverPos, 2773)
	if leverOn and leverOn.uid and leverOn.uid > 0 then
		doTransformItem(leverOn.uid, 2772)
	end
end

function onUse(cid, item, frompos, item2, topos)
	if not isDhqSwitch(item) then
		return false
	end

	if item.itemid == 1946 or item.itemid == 2773 then
		doPlayerSendCancel(cid, "Sorry, but this switch resets itself in a while.")
		return true
	end

	if item.itemid ~= 1945 and item.itemid ~= 2772 then
		return true
	end

	removeItemAt(DHQ.gatePos, DHQ.gateClosedId)
	if not getTileItemById(DHQ.gatePos, DHQ.gateOpenId).uid or getTileItemById(DHQ.gatePos, DHQ.gateOpenId).uid <= 0 then
		doCreateItem(DHQ.gateOpenId, 1, DHQ.gatePos)
	end

	doRelocate(DHQ.teleportPos, DHQ.playerDumpPos)
	removeItemAt(DHQ.teleportPos, 1387)
	doCreateTeleport(1387, DHQ.teleportDest, DHQ.teleportPos)

	doTransformItem(item.uid, item.itemid + 1)
	addEvent(resetDhq, DHQ.resetMs)
	return true
end
