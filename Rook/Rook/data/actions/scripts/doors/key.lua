-- keys (support actionid-based and keynumber-based keys)
local DEBUG_KEYS = true

local function debugPrint(msg)
	if DEBUG_KEYS then
		print(msg)
	end
end

local function getKeyValue(item)
	-- Prefer keynumber attribute if present, fallback to actionid
	local keyNumber = 0
	local keyAttr = 0
	if Item then
		local obj = Item(item.uid)
		if obj then
			local attr = ITEM_ATTRIBUTE_KEYNUMBER and obj:getAttribute(ITEM_ATTRIBUTE_KEYNUMBER) or 0
			if attr and attr > 0 then
				keyAttr = attr
				keyNumber = attr
			end
		end
	end
	if keyNumber == 0 then
		keyNumber = item.actionid or 0
	end
	-- Some NPC-created keys store the number in subtype (item.type) instead of actionid
	if keyNumber == 0 and item.type and item.type > 1 then
		keyNumber = item.type
	end
	return keyNumber
end

local function getDoorValue(item)
	local doorValue = item.actionid or 0
	if doorValue == 0 and Item and ITEM_ATTRIBUTE_KEYHOLENUMBER then
		local obj = Item(item.uid)
		if obj then
			local keyhole = obj:getAttribute(ITEM_ATTRIBUTE_KEYHOLENUMBER)
			if keyhole and keyhole > 0 then
				doorValue = keyhole
			end
		end
	end
	return doorValue
end

function onUse(cid, item, frompos, item2, topos)
LOCKEDDOOR = {1209, 1212, 1231, 1234, 1249, 1252, 3535, 3544, 4913, 4916, 5098, 5107, 5116, 5125, 5134, 5137, 5140, 5143, 5278, 5281, 6192, 6195, 6249, 6252, 6891, 6900, 7033, 7042}
UNLOCKED = {1210, 1213, 1232, 1235, 1250, 1253, 3536, 4917, 3545, 4914, 5099, 5108, 5117, 5126, 5135, 5138, 5141, 5144, 5279, 5282, 6193, 6196, 6250, 6253, 6892, 6901, 7034, 7043}
OPEN = {1211, 1214, 1233, 1236, 1251, 1254, 3537, 4918, 3546, 4915, 5100, 5109, 5118, 5127, 5136, 5139, 5142, 5145, 5280, 5283, 6194, 6197, 6251, 6254, 6893, 6902, 7035, 7044}
CHECKKEY = {2086, 2087, 2088, 2089, 2090, 2091, 2092}
	local keyValue = getKeyValue(item)
	local doorValue = getDoorValue(item2)
	local match = (keyValue > 0 and doorValue > 0 and keyValue == doorValue) and 1 or 0
	if DEBUG_KEYS then
		local keyAttr = 0
		local keyHole = 0
		if Item then
			local obj = Item(item.uid)
			if obj then
				local attr = ITEM_ATTRIBUTE_KEYNUMBER and obj:getAttribute(ITEM_ATTRIBUTE_KEYNUMBER) or 0
				if attr and attr > 0 then keyAttr = attr end
			end
			local door = Item(item2.uid)
			if door and ITEM_ATTRIBUTE_KEYHOLENUMBER then
				local kh = door:getAttribute(ITEM_ATTRIBUTE_KEYHOLENUMBER)
				if kh and kh > 0 then keyHole = kh end
			end
		end
		local pos = topos or {x = 0, y = 0, z = 0}
		debugPrint(string.format(
			"[KeyDebug] key itemid=%d actionid=%d type=%d keyattr=%d -> keyValue=%d | door itemid=%d actionid=%d keyhole=%d at %d,%d,%d",
			item.itemid or 0, item.actionid or 0, item.type or 0, keyAttr, keyValue,
			item2.itemid or 0, item2.actionid or 0, keyHole, pos.x or 0, pos.y or 0, pos.z or 0
		))
	end

	if isInArray(LOCKEDDOOR, item2.itemid) == true then

		if match == 1 then
			doTransformItem(item2.uid,item2.itemid+2)
		else
			doPlayerSendCancel(cid,"The key does not match.")
		end

	elseif isInArray(UNLOCKED, item2.itemid) == true then
		if match == 1 then
			doTransformItem(item2.uid,item2.itemid-1)
		else
			doPlayerSendCancel(cid,"The key does not match.")
		end
		
	elseif isInArray(OPEN, item2.itemid) == true then
		if match == 1 then
			doTransformItem(item2.uid,item2.itemid-2)
		else
			doPlayerSendCancel(cid,"The key does not match.")
		end	
		
		
		
	else

		return 0

	end

	return 1
	
end

