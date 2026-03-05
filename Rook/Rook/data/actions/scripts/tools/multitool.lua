local ropeHoleId = {
	294, 369, 370, 383, 392, 408, 409, 410, 427, 428, 429, 430, 462, 469, 470, 482,
	484, 485, 489, 924, 3135, 3136, 4835, 4837, 7933, 7938, 8170, 8249, 8250,
	8251, 8252, 8254, 8255, 8256, 8276, 8277, 8279, 8281, 8284, 8285, 8286, 8323,
	8567, 8585, 8595, 8596, 8972, 9606, 9625, 13190, 14461, 19519, 21536
}

local shovelHoles = {468, 481, 483}
local pickGroundIds = {351, 352, 353, 354, 355}

local function copyPosition(pos)
	return Position(pos.x, pos.y, pos.z)
end

local function useAsRope(player, itemEx, toPosition)
	if not itemEx then
		return false
	end

	local tile = Tile(toPosition)
	if not tile then
		return false
	end

	local ground = tile:getGround()
	local groundId = ground and ground:getId() or nil
	local targetId = itemEx.itemid

	local isRopeSpot = (groundId and table.contains(ropeSpots, groundId)) or (targetId and table.contains(ropeSpots, targetId)) or tile:getItemById(14435)
	local isRopeHole = targetId and table.contains(ropeHoleId, targetId)
	if not isRopeSpot and not isRopeHole then
		return false
	end

	local exhaustStorage = 9999
	if player:getStorageValue(exhaustStorage) > os.time() then
		player:sendCancelMessage("You must wait a while before using this again.")
		return true
	end

	if isRopeSpot then
		if Tile(toPosition:moveUpstairs()):hasFlag(TILESTATE_PROTECTIONZONE) and player:isPzLocked() then
			player:sendCancelMessage(RETURNVALUE_PLAYERISPZLOCKED)
			return true
		end

		player:teleportTo(toPosition, false)
		return true
	end

	toPosition.z = toPosition.z + 1
	tile = Tile(toPosition)
	if tile then
		local thing = tile:getTopVisibleThing()
		if thing:isPlayer() or thing:isCreature() or thing:isMonster() then
			if Tile(toPosition:moveUpstairs()):hasFlag(TILESTATE_PROTECTIONZONE) and thing:isPzLocked() then
				return true
			end

			player:setStorageValue(exhaustStorage, os.time() + 60)
			player:setStorageValue(5565633, player:getStorageValue(5565633) + 1)
			thing:teleportTo(toPosition, false)
			return true
		end

		if thing:isItem() and thing:getType():isMovable() then
			thing:moveTo(toPosition:moveUpstairs())
			return true
		end
	end

	player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	return true
end

local function useAsShovel(cid, itemEx, toPosition)
	local tile = Tile(toPosition)
	if not tile then
		return false
	end

	local ground = tile:getGround()
	local groundId = ground and ground:getId() or (itemEx and itemEx.itemid or 0)

	if table.contains(shovelHoles, groundId) then
		if ground then
			ground:transform(groundId + 1)
			ground:decay()
		end

		toPosition.z = toPosition.z + 1
		tile:relocateTo(toPosition)
		return true
	end

	if groundId == 231 then
		if itemEx and itemEx.itemid == 231 and itemEx.actionid == actionIds.sandHole then
			if ground then
				ground:transform(489)
				ground:decay()
			end
		else
			local randomValue = math.random(1, 1000)
			if randomValue <= 10 then
				Game.createItem(2159, 1, toPosition)
			elseif randomValue <= 30 then
				Game.createMonster("Scarab", toPosition)
			elseif randomValue <= 50 then
				Game.createMonster("Larva", toPosition)
			else
				toPosition:sendMagicEffect(CONST_ME_POFF)
				local player = Player(cid)
				if player then
					player:addExperience(math.random(1, 4), true)
				end
			end
		end
		return true
	end

	return false
end

local function useAsPick(player, itemEx, toPosition)
	if not itemEx then
		return false
	end

	if itemEx.itemid == 11227 then
		local chance = math.random(1, 100)
		if chance == 1 then
			player:addItem(2160)
		elseif chance <= 6 then
			player:addItem(2148)
		elseif chance <= 51 then
			player:addItem(2152)
		else
			player:addItem(2145)
		end
		itemEx:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
		itemEx:remove(1)
		return true
	end

	local tile = Tile(toPosition)
	if not tile then
		return false
	end

	local ground = tile:getGround()
	local groundId = ground and ground:getId() or nil
	local groundAction = ground and ground.actionid or 0
	local targetId = itemEx.itemid
	local targetAction = itemEx.actionid or 0

	local isPickGround = (groundId and table.contains(pickGroundIds, groundId)) or (targetId and table.contains(pickGroundIds, targetId))
	if not isPickGround then
		return false
	end

	local actionId = (groundAction > 0 and groundAction) or targetAction
	if actionId ~= actionIds.pickHole and actionId ~= 55555 then
		return false
	end

	if ground then
		ground:transform(392)
		ground:decay()
	end
	return true
end

local function useAsScythe(player, itemEx, toPosition)
	if not itemEx then
		return false
	end

	if itemEx and itemEx.itemid == 2739 then
		itemEx:transform(2737)
		itemEx:decay()
		player:addItem(2694, math.random(1, 3))
		local exp = math.random(1, 10)
		player:addExperience(exp, true)
		player:getPosition():sendMagicEffect(4)

		local USES_STORAGE = 2550
		local uses = player:getStorageValue(USES_STORAGE) + 1
		player:setStorageValue(USES_STORAGE, uses)

		if uses % 1000 == 0 then
			local reward = math.random(100, 2000)
			player:addExperience(reward, true)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You gained " .. reward .. " experience from successful gathering!")
			player:setStorageValue(USES_STORAGE, 0)
			player:getPosition():sendMagicEffect(28)
		end

		return true
	end

	return destroyItem(player:getId(), itemEx, toPosition)
end

local function useAsMachete(itemEx)
	if not itemEx then
		return false
	end

	if itemEx.itemid == 2782 then
		itemEx:transform(2781)
		itemEx:decay()
		return true
	end

	return false
end

function onUse(cid, item, fromPosition, itemEx, toPosition, isHotkey)
	local player = Player(cid)
	if not player then
		return false
	end

	if useAsRope(player, itemEx, copyPosition(toPosition)) then
		return true
	end

	if useAsShovel(cid, itemEx, copyPosition(toPosition)) then
		return true
	end

	if useAsPick(player, itemEx, copyPosition(toPosition)) then
		return true
	end

	if useAsMachete(itemEx) then
		return true
	end

	if useAsScythe(player, itemEx, toPosition) then
		return true
	end

	return false
end
