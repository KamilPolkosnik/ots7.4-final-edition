local useWorms = false
local debugFishing = false
local fishItemId = 2667
local wormItemId = 3976
local PROFESSIONAL_ROD_ID = 5852
local PROFESSIONAL_ROD_RADIUS = 1
local FISHING_BAG_ID = 3939
local FISH_WEIGHT_REDUCTION_PERCENT = 30
local BASE_FISH_WEIGHT = ItemType(fishItemId):getWeight(1)
local REDUCED_FISH_WEIGHT = math.max(1, math.floor(BASE_FISH_WEIGHT * (100 - FISH_WEIGHT_REDUCTION_PERCENT) / 100))
local MAX_STACK_COUNT = 100

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

local function getFishingChance(cid)
	return math.min(math.max(10 + (getPlayerSkill(cid, SKILL_FISHING) - 10) * 0.597, 10), 50)
end

local function consumeProfessionalRodUse(item)
	if item.itemid ~= PROFESSIONAL_ROD_ID then
		return true
	end

	local charges = tonumber(item.type) or 0
	if charges <= 1 then
		return doRemoveItem(item.uid, 1)
	end

	doChangeTypeItem(item.uid, charges - 1)
	return true
end

local function getEquippedFishingBag(player)
	for slot = CONST_SLOT_TOTEM1, CONST_SLOT_TOTEM3 do
		local slotItem = player:getSlotItem(slot)
		if slotItem and slotItem:getId() == FISHING_BAG_ID and slotItem:isContainer() then
			return slotItem
		end
	end

	return nil
end

local function addFishToInventory(player)
	local fish = player:addItem(fishItemId, 1, false)
	return fish ~= nil
end

local function addFishToFishingBag(fishingBag)
	local items = fishingBag:getItems(true)
	local totalFish = 0
	local fishStacks = {}

	if items then
		for _, stack in ipairs(items) do
			if stack:getId() == fishItemId and stack:getParent() == fishingBag then
				totalFish = totalFish + stack:getCount()
				fishStacks[#fishStacks + 1] = stack
			end
		end
	end

	totalFish = totalFish + 1

	-- Rebuild fish stacks so old split fish get auto-stacked too.
	for _, stack in ipairs(fishStacks) do
		stack:remove(stack:getCount())
	end

	while totalFish > 0 do
		local addCount = math.min(MAX_STACK_COUNT, totalFish)
		local fish = fishingBag:addItem(fishItemId, addCount)
		if not fish then
			return false
		end
		fish:setAttribute(ITEM_ATTRIBUTE_WEIGHT, REDUCED_FISH_WEIGHT)
		totalFish = totalFish - addCount
	end

	return true
end

local function addCaughtFish(cid)
	local player = Player(cid)
	if not player then
		return false
	end

	local fishingBag = getEquippedFishingBag(player)
	if fishingBag and addFishToFishingBag(fishingBag) then
		return true
	end

	return addFishToInventory(player)
end

local function attemptFishOnPosition(cid, pos, chance)
	local target, water, effectPos = getWater(nil, pos)
	if not water then
		return 0
	end

	doSendMagicEffect(effectPos, CONST_ME_LOSEENERGY)

	if not water.canFish then
		return 0
	end

	doPlayerAddSkillTry(cid, SKILL_FISHING, 1)
	if math.random(1, 100) > chance then
		return 0
	end

	if useWorms then
		if getPlayerItemCount(cid, wormItemId) <= 0 then
			return 0
		end
		doPlayerRemoveItem(cid, wormItemId, 1)
	end

	addCaughtFish(cid)

	if water.transformId and target and target.uid and target.uid > 0 then
		doTransformItem(target.uid, water.transformId)
		doDecayItem(target.uid)
	end

	return 1
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

	if item.itemid == PROFESSIONAL_ROD_ID then
		if not consumeProfessionalRodUse(item) then
			return false
		end

		local chance = getFishingChance(cid)
		for dx = -PROFESSIONAL_ROD_RADIUS, PROFESSIONAL_ROD_RADIUS do
			for dy = -PROFESSIONAL_ROD_RADIUS, PROFESSIONAL_ROD_RADIUS do
				attemptFishOnPosition(
					cid,
					{x = toPosition.x + dx, y = toPosition.y + dy, z = toPosition.z},
					chance
				)
			end
		end
		return true
	end

	doSendMagicEffect(effectPos, CONST_ME_LOSEENERGY)

	if not water.canFish then
		return true
	end

	doPlayerAddSkillTry(cid, SKILL_FISHING, 1)
	local chance = getFishingChance(cid)
	if math.random(1, 100) > chance then
		return true
	end

	if useWorms then
		if getPlayerItemCount(cid, wormItemId) <= 0 then
			return true
		end
		doPlayerRemoveItem(cid, wormItemId, 1)
	end

	addCaughtFish(cid)

	if water.transformId and target and target.uid and target.uid > 0 then
		doTransformItem(target.uid, water.transformId)
		doDecayItem(target.uid)
	end

	return true
end
