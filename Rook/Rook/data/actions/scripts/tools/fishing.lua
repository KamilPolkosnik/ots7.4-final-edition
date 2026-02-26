local useWorms = false
local debugFishing = false
local fishItemId = 2667
local wormItemId = 3976

-- TVP-style water states:
-- canFish=true  => can attempt fishing
-- canFish=false => valid water tile, only splash effect
local waterItems = {
	[4608] = {canFish = true, transformId = 4620},
	[4609] = {canFish = true, transformId = 4621},
	[4610] = {canFish = true, transformId = 4622},
	[4611] = {canFish = true, transformId = 4623},
	[4612] = {canFish = true, transformId = 4624},
	[4613] = {canFish = true, transformId = 4625},
	[490] = {canFish = true, transformId = 492},
	[4820] = {canFish = true, transformId = 4620},
	[4821] = {canFish = true, transformId = 4621},
	[4822] = {canFish = true, transformId = 4622},
	[4823] = {canFish = true, transformId = 4623},
	[4824] = {canFish = true, transformId = 4624},
	[4825] = {canFish = true, transformId = 4625},
	[491] = {canFish = false},
	[492] = {canFish = true, transformId = 492},
	[493] = {canFish = false},
	[4614] = {canFish = false},
	[4615] = {canFish = false},
	[4616] = {canFish = false},
	[4617] = {canFish = false},
	[4618] = {canFish = false},
	[4619] = {canFish = false},
	[4620] = {canFish = false},
	[4621] = {canFish = false},
	[4622] = {canFish = false},
	[4623] = {canFish = false},
	[4624] = {canFish = false},
	[4625] = {canFish = false},
	[4664] = {canFish = false},
	[4665] = {canFish = false},
	[4666] = {canFish = false},
	[618] = {canFish = false},
	[619] = {canFish = false},
	[620] = {canFish = false},
	[621] = {canFish = false},
	[622] = {canFish = false},
	[623] = {canFish = false},
	[624] = {canFish = false},
	[625] = {canFish = false},
	[626] = {canFish = false},
	[627] = {canFish = false},
	[628] = {canFish = false},
	[629] = {canFish = false}
}

local function getWater(itemEx, toPosition)
	if itemEx and itemEx.itemid and waterItems[itemEx.itemid] then
		return itemEx, waterItems[itemEx.itemid], toPosition
	end

	local ground = getThingfromPos({
		x = toPosition.x,
		y = toPosition.y,
		z = toPosition.z,
		stackpos = 0
	})
	if ground and ground.itemid and waterItems[ground.itemid] then
		return ground, waterItems[ground.itemid], toPosition
	end

	return nil, nil, nil
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	if debugFishing then
		print(string.format("[FishingDebug] cid=%s rod=%s target=%s pos=%s,%s,%s", tostring(cid), tostring(item.itemid), tostring(itemEx and itemEx.itemid or "nil"), tostring(toPosition.x), tostring(toPosition.y), tostring(toPosition.z)))
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "[FishingDebug] onUse fired")
	end

	local target, water, effectPos = getWater(itemEx, toPosition)
	if not water then
		if debugFishing then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "[FishingDebug] no water match")
		end
		return false
	end

	doSendMagicEffect(effectPos, CONST_ME_LOSEENERGY)

	if not water.canFish then
		return true
	end

	doPlayerAddSkillTry(cid, SKILL_FISHING, 1)

	local chance = math.min(math.max(10 + (getPlayerSkill(cid, SKILL_FISHING) - 10) * 0.597, 10), 50)
	if math.random(1, 100) > chance then
		return true
	end

	if useWorms then
		if getPlayerItemCount(cid, wormItemId) <= 0 then
			return true
		end
		doPlayerRemoveItem(cid, wormItemId, 1)
	end

	doPlayerAddItem(cid, fishItemId, 1)

	if water.transformId and target and target.uid and target.uid > 0 then
		doTransformItem(target.uid, water.transformId)
		doDecayItem(target.uid)
	end

	return true
end
