local invalidIds = {
	1, 2, 3, 4, 5, 6, 7, 10, 11, 13, 14, 15, 19, 21, 26, 27, 28, 35, 43
}

local DODGE_FALLBACK_ENCHANT_ID = 58
local LEGENDARY_DEFAULT = 4

local function getRarityByToken()
	local common = rawget(_G, "COMMON") or 1
	local rare = rawget(_G, "RARE") or 2
	local epic = rawget(_G, "EPIC") or 3
	local legendary = rawget(_G, "LEGENDARY") or 4
	return {
		common = common,
		c = common,
		rare = rare,
		r = rare,
		epic = epic,
		e = epic,
		legendary = legendary,
		leg = legendary,
		l = legendary
	}
end

local function normalizeToken(token)
	if not token then
		return ""
	end
	return token:lower():gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalizeBonusToken(token)
	return normalizeToken(token):gsub("[^a-z0-9]+", "")
end

local BONUS_ALIASES = {
	reflect = "damagereflect",
	dmgreflect = "damagereflect",
	ref = "damagereflect"
}

-- Fallback IDs for common test bonuses (used when US_ENCHANTMENTS is unavailable).
local FALLBACK_BONUS_IDS = {
	dodge = 58,
	dod = 58,
	damagereflect = 59,
	reflect = 59,
	dmgreflect = 59,
	ref = 59
}

local function parseCreateOptions(split, startIndex)
	local rarity = nil
	local unidentified = false
	local forcedDodgeValue = nil
	local rarityByToken = getRarityByToken()
	startIndex = startIndex or 3

	for i = startIndex, #split do
		local token = normalizeToken(split[i])
		if token ~= "" then
			if rarityByToken[token] then
				rarity = rarityByToken[token]
			elseif token == "unid" or token == "unidentified" or token == "ni" then
				unidentified = true
			elseif token == "identified" or token == "id" then
				unidentified = false
			else
				local dodgeValue = token:match("^dodge%s*=?%s*(%d+)$")
				if dodgeValue then
					forcedDodgeValue = math.max(0, math.min(100, math.floor(tonumber(dodgeValue) or 0)))
				end
			end
		end
	end

	return rarity, unidentified, forcedDodgeValue
end

local function applyCreateOptions(item, rarity, unidentified)
	if not item or not item:isItem() then
		return
	end

	if item.ensureInitialTierLevel then
		item:ensureInitialTierLevel(false)
	end

	if rarity and item.setRarity then
		item:setRarity(rarity)
	end

	if unidentified and item.unidentify then
		item:unidentify()
	end
end

local function getDodgeEnchantId()
	if rawget(_G, "US_ENCHANTMENTS") then
		for enchantId, attr in pairs(US_ENCHANTMENTS) do
			if attr and attr.special == "DODGE" then
				return enchantId
			end
		end
	end
	return DODGE_FALLBACK_ENCHANT_ID
end

local function applyTestDodge(item, dodgeValue)
	if not item or not item:isItem() then
		return false, "Invalid item instance."
	end

	if not item:getType():isUpgradable() then
		return false, "This item type is not upgradable."
	end

	local dodgeAttrId = getDodgeEnchantId()
	if not dodgeAttrId then
		return false, "Could not resolve DODGE enchant id."
	end

	-- Update existing dodge slot if already present.
	for slot = 1, item:getMaxAttributes() do
		local bonus = item:getBonusAttribute(slot)
		if bonus and bonus[1] == dodgeAttrId then
			item:addAttribute(slot, dodgeAttrId, dodgeValue)
			return true
		end
	end

	local maxAttributes = item:getMaxAttributes()
	if maxAttributes <= 0 then
		return false, "This item has no bonus slots."
	end

	local nextSlot = item:getLastSlot() + 1
	if nextSlot > maxAttributes then
		-- For testing, overwrite first slot when item is full.
		nextSlot = 1
	end

	item:addAttribute(nextSlot, dodgeAttrId, dodgeValue)
	return true
end

local function getLegendaryRarity()
	return rawget(_G, "LEGENDARY") or LEGENDARY_DEFAULT
end

local function findEnchantIdByToken(token)
	local normalized = normalizeBonusToken(token)
	if normalized ~= "" then
		normalized = BONUS_ALIASES[normalized] or normalized
		if FALLBACK_BONUS_IDS[normalized] then
			return FALLBACK_BONUS_IDS[normalized]
		end
	end

	local enchantments = rawget(_G, "US_ENCHANTMENTS")
	local asNumber = tonumber(token)
	if asNumber then
		asNumber = math.floor(asNumber)
		if enchantments and enchantments[asNumber] then
			return asNumber
		end
	end

	if not enchantments then
		return nil
	end

	if normalized == "" then
		return nil
	end

	for enchantId, attr in pairs(enchantments) do
		if attr then
			local attrName = normalizeBonusToken(attr.name or "")
			local attrSpecial = normalizeBonusToken(attr.special or "")
			if normalized == attrName or (attrSpecial ~= "" and normalized == attrSpecial) then
				return enchantId
			end
		end
	end

	return nil
end

local function parseBonusToken(token)
	local name, value = token:match("^(.+)%s*=%s*([%+%-]?%d+)%s*%%?$")
	if not name then
		name, value = token:match("^(.+)%s+([%+%-]?%d+)%s*%%?$")
	end
	if not name then
		name, value = token:match("^(.-)([%+%-]?%d+)%s*%%?$")
	end

	name = normalizeToken(name)
	if name == "" or not value then
		return nil, nil
	end

	return name, math.floor(tonumber(value) or 0)
end

local function parseExplicitBonuses(split, startIndex)
	local bonuses = {}
	local invalid = {}

	local i = startIndex
	while i <= #split do
		local rawToken = split[i]
		local token = normalizeToken(rawToken)
		if token ~= "" then
			local bonusName, bonusValue = parseBonusToken(token)
			-- Support format: bonus,50 (two tokens) in addition to bonus50 / bonus=50.
			if not bonusName and i < #split then
				local nextToken = normalizeToken(split[i + 1])
				local numeric = nextToken:match("^([%+%-]?%d+)%s*%%?$")
				if numeric then
					bonusName = token
					bonusValue = math.floor(tonumber(numeric) or 0)
					i = i + 1
				end
			end
			if not bonusName then
				invalid[#invalid + 1] = rawToken
			else
				local enchantId = findEnchantIdByToken(bonusName)
				if enchantId then
					bonuses[#bonuses + 1] = {id = enchantId, value = bonusValue}
				else
					invalid[#invalid + 1] = rawToken
				end
			end
		end
		i = i + 1
	end

	return bonuses, invalid
end

local function isLegacyIiFallback(words, param)
	if normalizeToken(words) ~= "/i" then
		return false, param
	end

	local fixedParam, replaced = tostring(param or ""):gsub("^%s*[iI]%s+", "", 1)
	if replaced == 1 then
		return true, fixedParam
	end
	return false, param
end

local function shouldUseExplicitLegendaryBuilder(words, split, param)
	local normalizedWords = normalizeToken(words)
	if normalizedWords == "/ii" then
		return true, param
	end

	local legacyIi, fixedParam = isLegacyIiFallback(words, param)
	if legacyIi then
		return true, fixedParam
	end

	-- Some engine builds pass the same 'words' value for /i and /ii when both point
	-- to one script. In that case infer /ii mode from bonus-style tokens.
	if #split < 2 then
		return false, param
	end

	local second = normalizeToken(split[2])
	if second == "" or tonumber(second) then
		return false, param
	end

	local rarityByToken = getRarityByToken()
	if rarityByToken[second] or second == "unid" or second == "unidentified" or second == "ni" or second == "identified" or second == "id" then
		return false, param
	end

	local bonusName = parseBonusToken(second)
	if not bonusName then
		return false, param
	end

	return findEnchantIdByToken(bonusName) ~= nil, param
end

local function applyExplicitBonuses(item, bonuses)
	if not item or not item:isItem() then
		return 0, #bonuses, "Invalid item instance."
	end
	if not item:getType():isUpgradable() then
		return 0, #bonuses, "This item type is not upgradable."
	end

	local maxAttributes = item:getMaxAttributes()
	if maxAttributes <= 0 then
		return 0, #bonuses, "This item has no bonus slots."
	end

	-- Ensure all slots are empty first.
	for slot = 1, maxAttributes do
		item:removeCustomAttribute("Slot" .. slot)
	end

	local applied = 0
	for _, bonus in ipairs(bonuses) do
		if applied >= maxAttributes then
			break
		end
		applied = applied + 1
		item:addAttribute(applied, bonus.id, bonus.value)
	end

	local ignored = math.max(0, #bonuses - applied)
	return applied, ignored, nil
end

local function sendCreateFeedback(player, text)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, text)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, text)
end

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	param = param or ""
	local split = param:splitTrimmed(",")
	local explicitLegendaryBuilder, fixedParam = shouldUseExplicitLegendaryBuilder(words, split, param)
	if explicitLegendaryBuilder and fixedParam ~= param then
		param = fixedParam
		split = param:splitTrimmed(",")
	end

	if not split[1] or split[1] == "" then
		player:sendCancelMessage("Usage: /i item[,count][,rarity][,unid] or /ii item,bonus50,bonus20%...")
		return false
	end

	local itemType = ItemType(split[1])
	if itemType:getId() == 0 then
		itemType = ItemType(tonumber(split[1]))
		if not tonumber(split[1]) or itemType:getId() == 0 then
			player:sendCancelMessage("There is no item with that id or name.")
			return false
		end
	end

	if table.contains(invalidIds, itemType:getId()) then
		return false
	end

	if explicitLegendaryBuilder then
		local result = player:addItem(itemType:getId(), 1)
		local item = result
		if type(result) == "table" then
			item = result[1]
		end

		if not item or not item:isItem() then
			player:sendCancelMessage("Could not create item.")
			return false
		end

		if item.setRarity then
			item:setRarity(getLegendaryRarity())
		end

		local explicitBonuses, invalidBonuses = parseExplicitBonuses(split, 2)
		if #split > 1 and #explicitBonuses == 0 and #invalidBonuses > 0 then
			item:remove()
			player:sendCancelMessage("No valid bonus tokens. Example: /ii demon armor,reflect50 or /ii demon armor,dodge50")
			sendCreateFeedback(player, "Ignored invalid bonus tokens: " .. table.concat(invalidBonuses, ", "))
			return false
		end
		local appliedCount, ignoredCount, applyError = applyExplicitBonuses(item, explicitBonuses)

		item:decay()
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

		if #invalidBonuses > 0 then
			sendCreateFeedback(player, "Ignored invalid bonus tokens: " .. table.concat(invalidBonuses, ", "))
		end

		if applyError then
			sendCreateFeedback(player, "Legendary bonus apply error: " .. applyError)
		else
			sendCreateFeedback(
				player,
				string.format("Created Legendary %s with %d bonus(es). Empty slots left: %d.", itemType:getName(), appliedCount, math.max(0, item:getMaxAttributes() - appliedCount))
			)
			if ignoredCount > 0 then
				sendCreateFeedback(player, "Ignored extra bonuses: " .. ignoredCount .. " (slot limit reached).")
			end
		end
		return false
	end

	local keyNumber = 0
	local count = tonumber(split[2])
	local optionsStart = count and 3 or 2
	local rarity, unidentified, forcedDodgeValue = parseCreateOptions(split, optionsStart)
	if count then
		if itemType:isStackable() then
			count = math.min(10000, math.max(1, count))
		elseif itemType:isKey() then
			keyNumber = count
			count = 1
		elseif not itemType:isFluidContainer() then
			count = math.min(100, math.max(1, count))
		else
			count = math.max(0, count)
		end
	else
		if not itemType:isFluidContainer() then
			count = 1
		else
			count = 0
		end
	end

	local result = player:addItem(itemType:getId(), count)
	if result then
		local dodgeValueToApply = forcedDodgeValue
		local dodgeAppliedAny = false
		local dodgeError = nil

		if not itemType:isStackable() then
			if type(result) == "table" then
				for _, item in ipairs(result) do
					applyCreateOptions(item, rarity, unidentified)
					if dodgeValueToApply then
						local applied, err = applyTestDodge(item, dodgeValueToApply)
						dodgeAppliedAny = dodgeAppliedAny or applied
						dodgeError = dodgeError or err
					end
					item:decay()
				end
			else
				applyCreateOptions(result, rarity, unidentified)
				if itemType:isKey() then
					result:setAttribute(ITEM_ATTRIBUTE_ACTIONID, keyNumber)
				end
				if dodgeValueToApply then
					local applied, err = applyTestDodge(result, dodgeValueToApply)
					dodgeAppliedAny = dodgeAppliedAny or applied
					dodgeError = dodgeError or err
				end
				result:decay()
			end
		else
			applyCreateOptions(result, rarity, unidentified)
		end

		if dodgeValueToApply and not dodgeAppliedAny and dodgeError then
			sendCreateFeedback(player, "Dodge test bonus not applied: " .. dodgeError)
		elseif dodgeValueToApply and dodgeAppliedAny then
			sendCreateFeedback(player, "Applied Dodge +" .. dodgeValueToApply .. "%.")
		end

		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end
	return false
end
