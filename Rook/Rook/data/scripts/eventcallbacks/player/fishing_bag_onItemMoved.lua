local ec = EventCallback

local FISHING_BAG_ID = 3939
local FISH_ITEM_ID = 2667
local FISH_WEIGHT_REDUCTION_PERCENT = 30
local FIRST_INVENTORY_SLOT = CONST_SLOT_HEAD
local REDUCED_FISH_WEIGHT = math.max(1, math.floor(ItemType(FISH_ITEM_ID):getWeight(1) * (100 - FISH_WEIGHT_REDUCTION_PERCENT) / 100))

local function isContainerThing(thing)
	return thing and thing.isContainer and thing:isContainer()
end

local function isInsideContainer(item, targetContainer)
	local parent = item:getParent()
	while parent do
		if parent == targetContainer then
			return true
		end

		if not isContainerThing(parent) then
			break
		end
		parent = parent:getParent()
	end
	return false
end

local function getEquippedFishingBags(player)
	local bags = {}
	for slot = CONST_SLOT_TOTEM1, CONST_SLOT_TOTEM3 do
		local slotItem = player:getSlotItem(slot)
		if slotItem and slotItem:getId() == FISHING_BAG_ID and slotItem:isContainer() then
			bags[#bags + 1] = slotItem
		end
	end
	return bags
end

local function isInsideAnyEquippedFishingBag(fishItem, bags)
	for _, bag in ipairs(bags) do
		if isInsideContainer(fishItem, bag) then
			return true
		end
	end
	return false
end

local function setFishWeight(fishItem, reduced)
	if reduced then
		fishItem:setAttribute(ITEM_ATTRIBUTE_WEIGHT, REDUCED_FISH_WEIGHT)
	else
		fishItem:removeAttribute(ITEM_ATTRIBUTE_WEIGHT)
	end
end

local function applyFishWeight(fishItem, bags)
	if fishItem:getId() ~= FISH_ITEM_ID then
		return
	end

	setFishWeight(fishItem, isInsideAnyEquippedFishingBag(fishItem, bags))
end

local function normalizePlayerFishWeights(player)
	local bags = getEquippedFishingBags(player)

	for slot = FIRST_INVENTORY_SLOT, CONST_SLOT_TOTEM3 do
		local slotItem = player:getSlotItem(slot)
		if slotItem then
			applyFishWeight(slotItem, bags)
			if slotItem:isContainer() then
				local nestedItems = slotItem:getItems(true)
				if nestedItems then
					for _, nestedItem in ipairs(nestedItems) do
						applyFishWeight(nestedItem, bags)
					end
				end
			end
		end
	end
end

ec.onItemMoved = function(self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	if item:getId() == FISH_ITEM_ID or item:getId() == FISHING_BAG_ID then
		normalizePlayerFishWeights(self)
	end
end

ec:register()
