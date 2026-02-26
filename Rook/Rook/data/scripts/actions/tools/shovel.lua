local holes = {468, 481, 483}
local sandIds = {231, 9059}

local shovel = Action()

function shovel.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local tile = Tile(toPosition)
	if not tile then
		return false
	end

	local ground = tile:getGround()
	local groundId = ground and ground:getId() or (target and target.itemid or 0)

	if table.contains(holes, groundId) then
		if ground then
			ground:transform(groundId + 1)
			ground:decay()
		end

		toPosition.z = toPosition.z + 1
		tile:relocateTo(toPosition)
		return true
	end

	if table.contains(sandIds, groundId) then
		if target and target.itemid == 231 and target.actionid == actionIds.sandHole then
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
				player:addExperience(math.random(1, 4), true)
			end
		end
		return true
	end

	return false
end

shovel:id(2554)
shovel:id(5710)
-- Disabled to avoid duplicate registration with legacy actions.xml tools/shovel.lua
-- shovel:register()
