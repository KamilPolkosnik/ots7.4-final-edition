local DECOR_PREFIX = "decor:"
local FORCE_BACKPACK_IDS = {
	[1809] = true, -- painting
	[1812] = true, -- tapestry
	[1855] = true, -- purple tapestry
	[1858] = true, -- green tapestry
	[1861] = true, -- yellow tapestry
	[1864] = true, -- orange tapestry
	[1867] = true, -- red tapestry
	[1870] = true, -- blue tapestry
	[1878] = true, -- white tapestry
	[1882] = true, -- demon trophy
	[1884] = true, -- wolf trophy
	[1886] = true, -- orc trophy
	[1888] = true, -- behemnot trophy
	[1890] = true, -- deer trophy
	[1892] = true, -- cyclops trophy
	[1894] = true, -- dragon trophy
	[1896] = true, -- lion trophy
	[1898] = true -- minotaur trophy
}
local FORCE_BACKPACK_VARIANTS = {
	-- Default tapestry has 2 variants.
	[1812] = {1813, 1812},
	-- Colored tapestries: prefer inventory variant.
	[1855] = {1857, 1855, 1856},
	[1858] = {1860, 1858, 1859},
	[1861] = {1863, 1861, 1862},
	[1864] = {1866, 1864, 1865},
	[1867] = {1869, 1867, 1868},
	[1870] = {1872, 1870, 1871},
	[1878] = {1880, 1878, 1879},
	-- Trophies: keep non-hanging variant first.
	[1882] = {1882},
	[1884] = {1884},
	[1886] = {1886},
	[1888] = {1888},
	[1890] = {1890},
	[1892] = {1892},
	[1894] = {1894},
	[1896] = {1896},
	[1898] = {1898}
}

local function parseDecorPayload(text)
	if type(text) ~= "string" or text == "" then
		return nil, nil
	end

	local itemId, count = text:match("^" .. DECOR_PREFIX .. "(%d+):(%d+)$")
	if not itemId then
		return nil, nil
	end

	return tonumber(itemId), tonumber(count)
end

local function tryAddOnHouseTile(tile, itemId, count)
	if not tile then
		return nil
	end

	local house = tile:getHouse()
	if not house then
		return nil
	end

	return tile:addItem(itemId, count)
end

local function tryAddAroundPlayerInHouse(player, itemId, count)
	local center = player:getPosition()
	local centerTile = Tile(center)
	local item = tryAddOnHouseTile(centerTile, itemId, count)
	if item then
		return item
	end

	for dy = -1, 1 do
		for dx = -1, 1 do
			if not (dx == 0 and dy == 0) then
				local pos = Position(center.x + dx, center.y + dy, center.z)
				local tile = Tile(pos)
				item = tryAddOnHouseTile(tile, itemId, count)
				if item then
					return item
				end
			end
		end
	end

	return nil
end

local function tryAddToBackpack(player, itemId, count, itemType)
	local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
	if not backpack then
		return nil
	end

	local inBackpack = backpack:addItem(itemId, count)
	if inBackpack then
		return inBackpack
	end

	return player:addItem(itemId, count, false)
end

local function tryAddDecorToBackpack(player, itemId, count)
	local candidates = FORCE_BACKPACK_VARIANTS[itemId] or {itemId}
	for i = 1, #candidates do
		local candidateId = candidates[i]
		local candidateType = ItemType(candidateId)
		if candidateType and candidateType:getId() > 0 then
			local added = tryAddToBackpack(player, candidateId, count, candidateType)
			if added then
				return added, candidateId
			end
		end
	end
	return nil, nil
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	if not player then
		return true
	end

	local tile = player:getTile()
	local house = tile and tile:getHouse()
	if not house then
		doPlayerSendCancel(cid, "You can unpack a decor parcel only inside a house.")
		return true
	end

	local parcel = Item(item.uid)
	if not parcel then
		doPlayerSendCancel(cid, "This decor parcel is invalid.")
		return true
	end

	local unpackId, unpackCount = parseDecorPayload(parcel:getText())
	if not unpackId or unpackId <= 0 then
		doPlayerSendCancel(cid, "This decor parcel is empty.")
		return true
	end

	unpackCount = math.max(1, math.floor(tonumber(unpackCount) or 1))

	local unpackType = ItemType(unpackId)
	if not unpackType or unpackType:getId() == 0 then
		doPlayerSendCancel(cid, "This decor parcel contains an invalid item.")
		return true
	end

	local unpacked = nil
	local forceBackpack = FORCE_BACKPACK_IDS[unpackId] == true
	local effectiveId = unpackId

	local isMovable = unpackType.isMovable and unpackType:isMovable() or false

	if forceBackpack then
		local added, addedId = tryAddDecorToBackpack(player, effectiveId, unpackCount)
		unpacked = added
		if addedId then
			effectiveId = addedId
		end
		if not unpacked then
			-- Last fallback: place in house, otherwise keep original error.
			unpacked = tryAddAroundPlayerInHouse(player, effectiveId, unpackCount)
			if not unpacked then
				doPlayerSendCancel(cid, "Make free backpack space/capacity to unpack this decoration.")
				return true
			end
		else
			unpackType = ItemType(effectiveId)
		end
	else
		-- Movable decorations first try backpack (convenience), then house tiles.
		if isMovable then
			unpacked = tryAddToBackpack(player, effectiveId, unpackCount, unpackType)
		end

		if not unpacked then
			unpacked = tryAddAroundPlayerInHouse(player, effectiveId, unpackCount)
		end
	end

	if not unpacked then
		doPlayerSendCancel(cid, "Couldn't unpack this parcel. Ensure there is free space in your house.")
		return true
	end

	doRemoveItem(item.uid, 1)
	doSendMagicEffect(getThingPos(cid), CONST_ME_MAGIC_GREEN)
	doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You unpacked " .. unpackType:getName() .. " x" .. unpackCount .. ".")
	return true
end
