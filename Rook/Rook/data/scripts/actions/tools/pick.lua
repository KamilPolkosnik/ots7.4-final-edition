local groundIds = {351, 352, 353, 354, 355}

local pick = Action()

function pick.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target then
		return false
	end

	if target.itemid == 11227 then
		local chance = math.random(1, 100)
		if chance == 1 then
			player:addItem(2160) -- crystal coin
		elseif chance <= 6 then
			player:addItem(2148) -- gold coin
		elseif chance <= 51 then
			player:addItem(2152) -- platinum coin
		else
			player:addItem(2145) -- small diamond
		end
		target:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
		target:remove(1)
		return true
	end

	local tile = Tile(toPosition)
	if not tile then
		return false
	end

	local ground = tile:getGround()
	local groundId = ground and ground:getId() or nil
	local groundAction = ground and ground.actionid or 0
	local targetId = target.itemid
	local targetAction = target.actionid or 0

	local isPickGround = (groundId and table.contains(groundIds, groundId)) or (targetId and table.contains(groundIds, targetId))
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

pick:id(2553)
-- Disabled to avoid duplicate registration with legacy actions.xml tools/pick.lua
-- pick:register()
