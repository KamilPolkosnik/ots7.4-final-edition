local holes = {468, 481, 483}
local sandIds = {231, 9059}

function onUse(cid, item, fromPosition, itemEx, toPosition, isHotkey)
	local tile = Tile(toPosition)
	if not tile then
		return false
	end

	local ground = tile:getGround()
	local groundId = ground and ground:getId() or (itemEx and itemEx.itemid or 0)

	if table.contains(holes, groundId) then
		if ground then
			ground:transform(groundId + 1)
			ground:decay()
		end

		toPosition.z = toPosition.z + 1
		tile:relocateTo(toPosition)
	elseif groundId == 231 then
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
	else
		return false
	end

	return true
end
