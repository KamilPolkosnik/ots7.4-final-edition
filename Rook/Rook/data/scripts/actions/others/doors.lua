local positionOffsets = {
	Position(1, 0, 0), -- east
	Position(0, 1, 0), -- south
	Position(-1, 0, 0), -- west
	Position(0, -1, 0) -- north
}

--[[
When closing a door with a creature in it findPushPosition will find the most appropriate
adjacent position following a prioritization order.
The function returns the position of the first tile that fulfills all the checks in a round.
The function loops trough east -> south -> west -> north on each following line in that order.
In round 1 it checks if there's an unhindered walkable tile without any creature.
In round 2 it checks if there's a tile with a creature.
In round 3 it checks if there's a tile blocked by a movable tile-blocking item.
In round 4 it checks if there's a tile blocked by a magic wall or wild growth.
]]
local function findPushPosition(creature, round)
	local pos = creature:getPosition()
	for _, offset in ipairs(positionOffsets) do
		local offsetPosition = pos + offset
		local tile = Tile(offsetPosition)
		if tile then
			local creatureCount = tile:getCreatureCount()
			if round == 1 then
				if tile:queryAdd(creature) == RETURNVALUE_NOERROR and creatureCount == 0 then
					if not tile:hasFlag(TILESTATE_PROTECTIONZONE) or (tile:hasFlag(TILESTATE_PROTECTIONZONE) and creature:canAccessPz()) then
						return offsetPosition
					end
				end
			elseif round == 2 then
				if creatureCount > 0 then
					if not tile:hasFlag(TILESTATE_PROTECTIONZONE) or (tile:hasFlag(TILESTATE_PROTECTIONZONE) and creature:canAccessPz()) then
						return offsetPosition
					end
				end
			elseif round == 3 then
				local topItem = tile:getTopDownItem()
				if topItem then
					if topItem:getType():isMovable() then
						return offsetPosition
					end
				end
			else
				if tile:getItemById(ITEM_MAGICWALL) or tile:getItemById(ITEM_WILDGROWTH) then
					return offsetPosition
				end
			end
		end
	end
	if round < 4 then
		return findPushPosition(creature, round + 1)
	end
end

local door = Action()

local function isDoorId(itemId)
	return table.contains(openDoors, itemId) or table.contains(closedDoors, itemId) or table.contains(lockedDoors, itemId)
end

local function findDoorOnTile(tile)
	if not tile then
		return nil
	end

	for _, list in ipairs({lockedDoors, closedDoors, openDoors}) do
		for _, id in ipairs(list) do
			local found = tile:getItemById(id)
			if found then
				return found
			end
		end
	end

	return nil
end

function door.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local itemId = item:getId()
	if table.contains(closedQuestDoors, itemId) then
		if player:getStorageValue(item.actionid) ~= -1 or player:getGroup():getAccess() then
			item:transform(itemId + 1)
			player:teleportTo(toPosition, true)
		else
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The door seems to be sealed against unwanted intruders.")
		end
		return true
	elseif table.contains(closedLevelDoors, itemId) then
		if item.actionid > 0 and player:getLevel() >= item.actionid - actionIds.levelDoor or player:getGroup():getAccess() then
			item:transform(itemId + 1)
			player:teleportTo(toPosition, true)
		else
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Only the worthy may pass.")
		end
		return true
	elseif table.contains(keys, itemId) then
		local doorTarget = target
		if not doorTarget or not doorTarget.itemid or not isDoorId(doorTarget.itemid) then
			doorTarget = findDoorOnTile(Tile(toPosition))
		end

		if not doorTarget then
			return false
		end

		if table.contains(keys, doorTarget.itemid) then
			return false
		end

		local keyActionId = item.actionid or 0
		local keyNumber = item:getAttribute(ITEM_ATTRIBUTE_KEYNUMBER) or 0
		local doorActionId = doorTarget.actionid or 0
		local doorKeyhole = doorTarget:getAttribute(ITEM_ATTRIBUTE_KEYHOLENUMBER) or 0

		local keyMatches = false
		if keyActionId > 0 and doorActionId > 0 and keyActionId == doorActionId then
			keyMatches = true
		elseif keyNumber > 0 and doorKeyhole > 0 and keyNumber == doorKeyhole then
			keyMatches = true
		elseif keyNumber > 0 and doorActionId > 0 and keyNumber == doorActionId then
			keyMatches = true
		elseif keyActionId > 0 and doorKeyhole > 0 and keyActionId == doorKeyhole then
			keyMatches = true
		end

		if not keyMatches then
			player:sendTextMessage(MESSAGE_STATUS_SMALL, "The key does not match.")
			return true
		end
		local transformTo = doorTarget.itemid + 2
		if table.contains(openDoors, doorTarget.itemid) then
			transformTo = doorTarget.itemid - 2
		elseif table.contains(closedDoors, doorTarget.itemid) then
			transformTo = doorTarget.itemid - 1
		end
		doorTarget:transform(transformTo)
		return true
	elseif table.contains(lockedDoors, itemId) then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "It is locked.")
		return true	
	elseif table.contains(openDoors, itemId) or table.contains(openExtraDoors, itemId) or table.contains(openHouseDoors, itemId) then
		local creaturePositionTable = {}
		local doorCreatures = Tile(toPosition):getCreatures()
		if doorCreatures and #doorCreatures > 0 then
			for _, doorCreature in pairs(doorCreatures) do
				local pushPosition = findPushPosition(doorCreature, 1)
				if not pushPosition then
					player:sendCancelMessage(RETURNVALUE_NOTENOUGHROOM)
					return true
				end
				table.insert(creaturePositionTable, {creature = doorCreature, position = pushPosition})
			end
			for _, tableCreature in ipairs(creaturePositionTable) do
				tableCreature.creature:teleportTo(tableCreature.position, true)
			end
		end
	
		item:transform(itemId - 1)
		return true	
	elseif table.contains(closedDoors, itemId) or table.contains(closedExtraDoors, itemId) or table.contains(closedHouseDoors, itemId) then
		item:transform(itemId + 1)
		return true
	end
	return false
end

local doorTables = {keys, openDoors, closedDoors, lockedDoors, openExtraDoors, closedExtraDoors, openHouseDoors, closedHouseDoors, closedQuestDoors, closedLevelDoors}
for _, doors in pairs(doorTables) do
	for _, doorId in pairs(doors) do
		door:id(doorId)
	end
end
door:register()
