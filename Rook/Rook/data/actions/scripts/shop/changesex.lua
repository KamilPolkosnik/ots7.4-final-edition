local STORE_OUTFIT_PAIRS_FALLBACK = {
	{128, 136}, {129, 137}, {130, 138}, {131, 139}, {132, 140},
	{133, 141}, {134, 142}, {143, 147}, {144, 148}, {145, 149},
	{146, 150}, {151, 155}, {152, 156}, {153, 157}, {154, 158},
	{161, 162}, {163, 164}, {166, 165},
	{254, 264}, {571, 257}, {263, 260}, {559, 560},
	{635, 639}, {562, 561}, {573, 573}, {574, 257},
	{578, 577}, {632, 636}, {633, 637}, {551, 547},
	{548, 549}, {638, 634}, {556, 255}
}

local function registerMirror(pairs, fromType, toType)
	fromType = tonumber(fromType)
	toType = tonumber(toType)
	if not fromType or not toType or fromType <= 0 or toType <= 0 then
		return
	end

	if not pairs[fromType] then
		pairs[fromType] = {}
	end

	for i = 1, #pairs[fromType] do
		if pairs[fromType][i] == toType then
			return
		end
	end
	pairs[fromType][#pairs[fromType] + 1] = toType
end

local function buildOutfitMirrorTable()
	local mirrorTable = {}

	-- Primary source: explicit fallback table (works even if store script wasn't initialized yet).
	for i = 1, #STORE_OUTFIT_PAIRS_FALLBACK do
		local a = STORE_OUTFIT_PAIRS_FALLBACK[i][1]
		local b = STORE_OUTFIT_PAIRS_FALLBACK[i][2]
		registerMirror(mirrorTable, a, b)
		registerMirror(mirrorTable, b, a)
	end

	-- Secondary source: runtime mirror from game_store.lua (if available).
	if type(GameStoreOutfitMirror) == "table" then
		for fromType, toType in pairs(GameStoreOutfitMirror) do
			registerMirror(mirrorTable, fromType, toType)
		end
	end

	return mirrorTable
end

local function outfitAddonLevel(player, lookType)
	if player:hasOutfit(lookType, 3) then
		return 3
	elseif player:hasOutfit(lookType, 2) then
		return 2
	elseif player:hasOutfit(lookType, 1) then
		return 1
	elseif player:hasOutfit(lookType) then
		return 0
	end
	return -1
end

local function grantMirrorOutfit(player, lookType, addons)
	if addons >= 1 then
		if not player:hasOutfit(lookType, addons) then
			player:addOutfitAddon(lookType, addons)
		end
	else
		if not player:hasOutfit(lookType) then
			player:addOutfit(lookType)
		end
	end
end

local function ensureOutfitMirrorOwnership(player)
	local mirror = buildOutfitMirrorTable()

	for fromType, targetList in pairs(mirror) do
		local addons = outfitAddonLevel(player, tonumber(fromType))
		if addons >= 0 then
			for i = 1, #targetList do
				grantMirrorOutfit(player, tonumber(targetList[i]), addons)
			end
		end
	end
end

local function canPlayerUseOutfit(player, lookType, addons)
	lookType = tonumber(lookType) or 0
	addons = tonumber(addons) or 0
	if lookType <= 0 then
		return false
	end

	-- Prefer explicit wear check for current sex; fallback to ownership.
	if player.canWear and player:canWear(lookType, addons) then
		return true
	end
	return player:hasOutfit(lookType, addons) or player:hasOutfit(lookType)
end

local function switchCurrentOutfitToMirror(player)
	local outfit = player:getOutfit()
	if not outfit then
		return
	end

	local currentType = tonumber(outfit.lookType) or 0
	if currentType <= 0 then
		return
	end

	local currentAddons = tonumber(outfit.lookAddons) or 0
	local mirror = buildOutfitMirrorTable()
	local candidates = mirror[currentType]
	if type(candidates) ~= "table" or #candidates == 0 then
		-- No explicit mirror; if current looktype is still valid for new sex, keep it.
		if canPlayerUseOutfit(player, currentType, currentAddons) then
			player:setOutfit(outfit)
		end
		return
	end

	-- Try mirror candidates in configured order.
	for i = 1, #candidates do
		local targetType = tonumber(candidates[i]) or 0
		if targetType > 0 and canPlayerUseOutfit(player, targetType, currentAddons) then
			outfit.lookType = targetType
			player:setOutfit(outfit)
			return
		end
	end

	-- Fallback: try same looktype if still wearable after sex change.
	if canPlayerUseOutfit(player, currentType, currentAddons) then
		player:setOutfit(outfit)
		return
	end

	-- Last fallback: try one addon-less candidate.
	for i = 1, #candidates do
		local targetType = tonumber(candidates[i]) or 0
		if targetType > 0 and canPlayerUseOutfit(player, targetType, 0) then
			outfit.lookType = targetType
			outfit.lookAddons = 0
			player:setOutfit(outfit)
			return
		end
	end
end

function onUse(cid, item, fromPosition, item2, toPosition)
	local player = Player(cid)
	if not player then
		return true
	end

	local newSex = player:getSex() == PLAYERSEX_FEMALE and PLAYERSEX_MALE or PLAYERSEX_FEMALE
	player:setSex(newSex)
	ensureOutfitMirrorOwnership(player)
	switchCurrentOutfitToMirror(player)
	item:remove(1)

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Your sex has been changed.")
	return true
end
