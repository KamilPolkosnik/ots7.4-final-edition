local DONATION_URL = "https://website.com/donate.php"

local CODE_GAMESTORE = 102
local GAME_STORE = nil

local LoginEvent = CreatureEvent("GameStoreLogin")
local PREMIUM_SCROLL_ACTION_7 = 60007
local PREMIUM_SCROLL_ACTION_15 = 60015
local PREMIUM_SCROLL_ACTION_60 = 60060
local PREMIUM_SCROLL_ACTION_120 = 60120
local MARKET_TICKET_ACTION = 65048
local DECOR_PARCEL_ITEM_ID = 2595
local DECOR_PARCEL_ACTION_ID = 65150
local EXPERIENCE_BOOSTER_ITEM_ID = 5540
local EXPERIENCE_BOOSTER_COOLDOWN = 24 * 60 * 60
local FRAG_REMOVER_ITEM_ID = 5541
local FRAG_REMOVER_COOLDOWN = 30 * 24 * 60 * 60
local SHOP_HISTORY_TABLE = "shop_history"
local SHOP_HISTORY_COLUMN_CACHE = {}
local SHOP_HISTORY_ID_EXPLICIT = nil
local GAME_STORE_OFFERS_CHUNK_SIZE = 20
local GAME_STORE_HISTORY_CHUNK_SIZE = 40
GameStoreOutfitMirror = GameStoreOutfitMirror or {}

local STORE_EXPLICIT_OUTFIT_MIRROR_PAIRS = {
	-- Keep optional explicit pairs here only if an outfit is single-sex in offers.
}

local function registerOutfitMirrorPair(a, b)
	a = tonumber(a)
	b = tonumber(b)
	if not a or not b or a <= 0 or b <= 0 then
		return
	end
	GameStoreOutfitMirror[a] = b
	GameStoreOutfitMirror[b] = a
end

local function shopHistoryHasColumn(columnName)
	local cacheKey = tostring(columnName)
	local cached = SHOP_HISTORY_COLUMN_CACHE[cacheKey]
	if cached ~= nil then
		return cached
	end

	local q = "SHOW COLUMNS FROM `" .. SHOP_HISTORY_TABLE .. "` LIKE " .. db.escapeString(cacheKey)
	local resultId = db.storeQuery(q)
	local exists = resultId ~= false
	if exists then
		result.free(resultId)
	end
	SHOP_HISTORY_COLUMN_CACHE[cacheKey] = exists
	return exists
end

local function shopHistoryShowField(columnName, fieldName)
	local q = "SHOW COLUMNS FROM `" .. SHOP_HISTORY_TABLE .. "` LIKE " .. db.escapeString(columnName)
	local resultId = db.storeQuery(q)
	if resultId == false then
		return ""
	end
	local value = tostring(result.getDataString(resultId, fieldName) or "")
	result.free(resultId)
	return value
end

local function shopHistoryNeedsExplicitId()
	if SHOP_HISTORY_ID_EXPLICIT ~= nil then
		return SHOP_HISTORY_ID_EXPLICIT
	end

	if not shopHistoryHasColumn("id") then
		SHOP_HISTORY_ID_EXPLICIT = false
		return false
	end

	local extra = string.lower(shopHistoryShowField("id", "Extra"))
	SHOP_HISTORY_ID_EXPLICIT = extra:find("auto_increment", 1, true) == nil
	return SHOP_HISTORY_ID_EXPLICIT
end

local function ensureShopHistoryAutoIncrement()
	if not shopHistoryHasColumn("id") then
		return
	end

	if not shopHistoryNeedsExplicitId() then
		return
	end

	local keyType = string.upper(shopHistoryShowField("id", "Key"))
	if keyType == "" then
		db.query("ALTER TABLE `" .. SHOP_HISTORY_TABLE .. "` ADD PRIMARY KEY (`id`)")
	end

	db.query("ALTER TABLE `" .. SHOP_HISTORY_TABLE .. "` MODIFY COLUMN `id` INT NOT NULL AUTO_INCREMENT")

	-- Refresh cached id mode after migration attempt.
	SHOP_HISTORY_ID_EXPLICIT = nil
	shopHistoryNeedsExplicitId()
end

local function nextShopHistoryId()
	local resultId = db.storeQuery("SELECT COALESCE(MAX(`id`), 0) + 1 AS `next_id` FROM `" .. SHOP_HISTORY_TABLE .. "`")
	if resultId == false then
		return 1
	end
	local nextId = result.getDataInt(resultId, "next_id")
	result.free(resultId)
	nextId = tonumber(nextId) or 1
	return math.max(1, nextId)
end

local function getShopHistoryPriceColumn()
	if shopHistoryHasColumn("price") then
		return "price"
	end
	if shopHistoryHasColumn("cost") then
		return "cost"
	end
	return nil
end

local function insertShopHistory(accountId, playerGuid, title, price, count, targetName)
	local safeAccountId = math.floor(tonumber(accountId) or 0)
	local safePlayerGuid = math.floor(tonumber(playerGuid) or 0)
	local safeTitle = tostring(title or "")
	local safePrice = math.max(0, math.floor(tonumber(price) or 0))
	local safeCount = math.max(0, math.floor(tonumber(count) or 0))
	local safeTarget = tostring(targetName or "")

	local columns = {"`account`", "`player`", "`date`", "`title`"}
	local values = {
		tostring(safeAccountId),
		tostring(safePlayerGuid),
		"NOW()",
		db.escapeString(safeTitle)
	}

	local priceColumn = getShopHistoryPriceColumn()
	if priceColumn then
		columns[#columns + 1] = "`" .. priceColumn .. "`"
		values[#values + 1] = tostring(safePrice)
	end

	if shopHistoryHasColumn("count") then
		columns[#columns + 1] = "`count`"
		values[#values + 1] = tostring(safeCount)
	end

	if shopHistoryHasColumn("target") then
		columns[#columns + 1] = "`target`"
		if safeTarget ~= "" then
			values[#values + 1] = db.escapeString(safeTarget)
		else
			values[#values + 1] = "NULL"
		end
	elseif shopHistoryHasColumn("details") then
		columns[#columns + 1] = "`details`"
		if safeTarget ~= "" then
			values[#values + 1] = db.escapeString("gift:" .. safeTarget)
		else
			values[#values + 1] = db.escapeString("")
		end
	end

	local columnsSql = table.concat(columns, ",")
	local valuesSql = table.concat(values, ",")
	local baseInsert = "INSERT INTO `" .. SHOP_HISTORY_TABLE .. "` (" .. columnsSql .. ") VALUES (" .. valuesSql .. ")"
	if db.query(baseInsert) then
		return true
	end

	-- Legacy fallback for schemas where id is not AUTO_INCREMENT.
	if shopHistoryHasColumn("id") then
		local fallbackId = nextShopHistoryId()
		local fallbackInsert =
			"INSERT INTO `" ..
			SHOP_HISTORY_TABLE ..
			"` (`id`," .. columnsSql .. ") VALUES (" .. fallbackId .. "," .. valuesSql .. ")"
		if db.query(fallbackInsert) then
			return true
		end
	end

	return false
end

local function formatCooldown(seconds)
	seconds = math.max(0, math.floor(tonumber(seconds) or 0))
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	return string.format("%02dh %02dm", hours, minutes)
end

local function formatCooldownWithDays(seconds)
	seconds = math.max(0, math.floor(tonumber(seconds) or 0))
	local days = math.floor(seconds / (24 * 60 * 60))
	local hours = math.floor((seconds % (24 * 60 * 60)) / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	if days > 0 then
		return string.format("%dd %02dh %02dm", days, hours, minutes)
	end
	return string.format("%02dh %02dm", hours, minutes)
end

local function storePurchaseCooldownRemaining(accountId, title, cooldownSeconds)
	accountId = math.floor(tonumber(accountId) or 0)
	if accountId <= 0 then
		return 0
	end

	local lowerTitle = string.lower(tostring(title or ""))
	if lowerTitle == "" then
		return 0
	end

	local q = string.format(
		"SELECT UNIX_TIMESTAMP(`date`) AS `ts` FROM `%s` WHERE `account` = %d AND LOWER(`title`) = %s ORDER BY `date` DESC LIMIT 1",
		SHOP_HISTORY_TABLE,
		accountId,
		db.escapeString(lowerTitle)
	)
	local resultId = db.storeQuery(q)
	if resultId == false then
		return 0
	end

	local ts = tonumber(result.getDataInt(resultId, "ts")) or 0
	result.free(resultId)
	if ts <= 0 then
		return 0
	end

	local cooldown = math.max(0, math.floor(tonumber(cooldownSeconds) or 0))
	if cooldown <= 0 then
		return 0
	end

	local elapsed = os.time() - ts
	if elapsed >= cooldown then
		return 0
	end
	return cooldown - elapsed
end

local function experienceBoosterCooldownRemaining(accountId)
	return storePurchaseCooldownRemaining(accountId, "experience booster", EXPERIENCE_BOOSTER_COOLDOWN)
end

local function fragRemoverCooldownRemaining(accountId)
	return storePurchaseCooldownRemaining(accountId, "frag remover", FRAG_REMOVER_COOLDOWN)
end

local function premiumScrollStoreCallback(days, actionId)
	return function(player, offer)
		local weight = ItemType(offer.itemId):getWeight(offer.count)
		if player:getFreeCapacity() < weight then
			return "This item is too heavy for you!"
		end

		local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
		if not backpack then
			return "You don't have enough space in backpack."
		end

		local slots = backpack:getEmptySlots(true)
		if slots <= 0 then
			return "You don't have enough space in backpack."
		end

		local item = player:addItem(offer.itemId, offer.count, false)
		if not item then
			return "Something went wrong, item couldn't be added."
		end

		if actionId then
			item:setActionId(actionId)
			item:setAttribute(ITEM_ATTRIBUTE_NAME, days .. " days premium account scroll")
			item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Premium account for " .. days .. " days.")
		end

		return true
	end
end

local function marketTicketStoreCallback()
	return function(player, offer)
		local itemType = ItemType(offer.itemId)
		local weight = itemType and itemType:getWeight(offer.count) or 0
		if player:getFreeCapacity() < weight then
			return "This item is too heavy for you!"
		end

		local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
		if not backpack then
			return "You don't have enough space in backpack."
		end

		local slots = backpack:getEmptySlots(true)
		if slots <= 0 then
			return "You don't have enough space in backpack."
		end

		local item = player:addItem(offer.itemId, offer.count, false)
		if not item then
			return "Something went wrong, item couldn't be added."
		end

		item:setActionId(MARKET_TICKET_ACTION)
		item:setAttribute(ITEM_ATTRIBUTE_NAME, "market scroll")
		item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Use to open the Market window. First use starts 48h access time.")
		return true
	end
end

local function trainingWeaponStoreCallback()
	return function(player, offer)
		local itemType = ItemType(offer.itemId)
		local defaultCharges = tonumber(itemType and itemType:getCharges()) or 1500
		if defaultCharges <= 0 then
			defaultCharges = 1500
		end

		local weight = itemType and itemType:getWeight(1) or 0
		if player:getFreeCapacity() < weight then
			return "This item is too heavy for you!"
		end

		local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
		if not backpack then
			return "You don't have enough space in backpack."
		end

		local slots = backpack:getEmptySlots(true)
		if slots <= 0 then
			return "You don't have enough space in backpack."
		end

		local item = player:addItem(offer.itemId, defaultCharges, false)
		if not item then
			return "Something went wrong, item couldn't be added."
		end

		return true
	end
end

local function chargedItemStoreCallback(charges)
	return function(player, offer)
		local itemType = ItemType(offer.itemId)
		local useCharges = math.max(1, math.floor(tonumber(charges) or 1))

		local weight = itemType and itemType:getWeight(1) or 0
		if player:getFreeCapacity() < weight then
			return "This item is too heavy for you!"
		end

		local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
		if not backpack then
			return "You don't have enough space in backpack."
		end

		local slots = backpack:getEmptySlots(true)
		if slots <= 0 then
			return "You don't have enough space in backpack."
		end

		local item = player:addItem(offer.itemId, useCharges, false)
		if not item then
			return "Something went wrong, item couldn't be added."
		end

		return true
	end
end

local function decorParcelStoreCallback()
	return function(player, offer)
		local parcelType = ItemType(DECOR_PARCEL_ITEM_ID)
		local weight = parcelType and parcelType:getWeight(1) or 0
		if player:getFreeCapacity() < weight then
			return "This item is too heavy for you!"
		end

		local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
		if not backpack then
			return "You don't have enough space in backpack."
		end

		local slots = backpack:getEmptySlots(true)
		if slots <= 0 then
			return "You don't have enough space in backpack."
		end

		local unpackId = math.max(1, math.floor(tonumber(offer.itemId) or 0))
		local unpackCount = math.max(1, math.floor(tonumber(offer.count) or 1))
		local unpackType = ItemType(unpackId)
		if not unpackType or unpackType:getId() == 0 then
			return "This decorative item is invalid."
		end

		local unpackName = unpackType:getName()
		if unpackName == "" then
			unpackName = offer.title or ("item " .. unpackId)
		end

		local parcel = player:addItem(DECOR_PARCEL_ITEM_ID, 1, false)
		if not parcel then
			return "Something went wrong, item couldn't be added."
		end

		parcel:setActionId(DECOR_PARCEL_ACTION_ID)
		parcel:setAttribute(ITEM_ATTRIBUTE_NAME, "decor parcel")
		parcel:setAttribute(
			ITEM_ATTRIBUTE_DESCRIPTION,
			"Contains " .. unpackName .. " x" .. unpackCount .. ". Can be unpacked only inside a house."
		)
		parcel:setAttribute(ITEM_ATTRIBUTE_TEXT, "decor:" .. unpackId .. ":" .. unpackCount)
		return true
	end
end

local function addDecorStoreSection(categoryTitle, description, iconItemId, entries, callback)
	addCategory(categoryTitle, description, "item", iconItemId)
	for i = 1, #entries do
		local entry = entries[i]
		local itemId = entry[1]
		local price = entry[2]
		local itemType = ItemType(itemId)
		if itemType and itemType:getId() > 0 and itemType:getName() ~= "" then
			addItem(
				categoryTitle,
				itemType:getName(),
				"Packed in decor parcel. Unpack only inside a house.",
				itemId,
				1,
				price,
				callback
			)
		end
	end
end

function LoginEvent.onLogin(player)
	player:registerEvent("GameStoreExtended")
	return true
end

function gameStoreInitialize()
	ensureShopHistoryAutoIncrement()

	GAME_STORE = {
		categories = {},
		offers = {}
	}

	for i = 1, #STORE_EXPLICIT_OUTFIT_MIRROR_PAIRS do
		local pair = STORE_EXPLICIT_OUTFIT_MIRROR_PAIRS[i]
		registerOutfitMirrorPair(pair[1], pair[2])
	end

	addCategory("Premium Scrolls", "Premium account scrolls.", "item", 5546)
	addItem(
		"Premium Scrolls",
		"7 days premium account scroll",
		"Premium account for 7 days.",
		5546,
		1,
		150,
		premiumScrollStoreCallback(7, PREMIUM_SCROLL_ACTION_7)
	)
	-- Keep 7-day behavior (item id 5545) but use same icon as other premium scrolls.
	if GAME_STORE.offers["Premium Scrolls"] and GAME_STORE.offers["Premium Scrolls"][#GAME_STORE.offers["Premium Scrolls"]] then
		local sharedPremiumClientId = ItemType(5546):getClientId()
		if sharedPremiumClientId and sharedPremiumClientId > 0 then
			GAME_STORE.offers["Premium Scrolls"][#GAME_STORE.offers["Premium Scrolls"]].clientId = sharedPremiumClientId
		end
	end
	addItem(
		"Premium Scrolls",
		"15 days premium account scroll",
		"Premium account for 15 days.",
		5546,
		1,
		200,
		premiumScrollStoreCallback(15, PREMIUM_SCROLL_ACTION_15)
	)
	addItem(
		"Premium Scrolls",
		"30 days premium account scroll",
		"Premium account for 30 days.",
		5546,
		1,
		300,
		premiumScrollStoreCallback(30)
	)
	addItem(
		"Premium Scrolls",
		"60 days premium account scroll",
		"Premium account for 60 days.",
		5546,
		1,
		500,
		premiumScrollStoreCallback(60, PREMIUM_SCROLL_ACTION_60)
	)
	addItem(
		"Premium Scrolls",
		"120 days premium account scroll",
		"Premium account for 120 days.",
		5546,
		1,
		950,
		premiumScrollStoreCallback(120, PREMIUM_SCROLL_ACTION_120)
	)

	addCategory("Premium Coins", "Titania premium coin packs.", "item", 7965)
	addItem(
		"Premium Coins",
		"1 premium coin",
		"Get 1 Titania premium coin.",
		7965,
		1,
		2
	)
	addItem(
		"Premium Coins",
		"10 premium coins",
		"Get 10 Titania premium coins.",
		7965,
		10,
		13
	)
	addItem(
		"Premium Coins",
		"50 premium coins",
		"Get 50 Titania premium coins.",
		7965,
		50,
		55
	)
	addItem(
		"Premium Coins",
		"100 premium coins",
		"Get 100 Titania premium coins.",
		7965,
		100,
		105
	)

	addCategory(
		"Outfits",
		"Contains all addons.",
		"outfit",
		{
			mount = 0,
			type = 131,
			addons = 0,
			head = 0,
			body = 114,
			legs = 85,
			feet = 76
		}
	)
	addOutfit(
	"Outfits",
	"Citizen",
	"Citizen",
	{
		mount = 0,
		type = 128,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 136,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Hunter",
	"Hunter",
	{
		mount = 0,
		type = 129,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 137,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Mage",
	"Mage",
	{
		mount = 0,
		type = 130,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 138,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Knight",
	"Knight",
	{
		mount = 0,
		type = 131,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 139,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Noble",
	"Noble",
	{
		mount = 0,
		type = 132,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 140,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Summoner",
	"Summoner",
	{
		mount = 0,
		type = 133,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 141,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Warrior",
	"Warrior",
	{
		mount = 0,
		type = 134,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 142,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Barbarian",
	"Barbarian",
	{
		mount = 0,
		type = 143,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 147,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Druid",
	"Druid",
	{
		mount = 0,
		type = 144,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 148,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Wizard",
	"Wizard",
	{
		mount = 0,
		type = 145,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 149,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Oriental",
	"Oriental",
	{
		mount = 0,
		type = 146,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 150,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Pirate",
	"Pirate",
	{
		mount = 0,
		type = 151,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 155,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Assassin",
	"Assassin",
	{
		mount = 0,
		type = 152,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 156,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Beggar",
	"Beggar",
	{
		mount = 0,
		type = 153,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 157,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Shaman",
	"Shaman",
	{
		mount = 0,
		type = 154,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 158,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Nightmare",
	"Nightmare",
	{
		mount = 0,
		type = 161,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 162,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Jester",
	"Jester",
	{
		mount = 0,
		type = 163,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 164,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Brotherhood",
	"Brotherhood",
	{
		mount = 0,
		type = 166,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 165,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	450
)

addOutfit(
	"Outfits",
	"Moon Vanguard",
	"Moon Vanguard",
	{
		mount = 0,
		type = 254,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 264,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	550
)

addOutfit(
	"Outfits",
	"Desert Marshal",
	"Desert Marshal",
	{
		mount = 0,
		type = 263,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 260,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	550
)

addOutfit(
	"Outfits",
	"Void Hexer",
	"Void Hexer",
	{
		mount = 0,
		type = 559,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 560,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	550
)

addOutfit(
	"Outfits",
	"Dragon Slayer",
	"Dragon Slayer",
	{
		mount = 0,
		type = 635,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 639,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	1499
)

addOutfit(
	"Outfits",
	"Eclipse Vanguard",
	"Eclipse Vanguard",
	{
		mount = 0,
		type = 562,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 561,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	550
)

addOutfit(
	"Outfits",
	"Void Reaper",
	"Void Reaper",
	{
		mount = 0,
		type = 556,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 255,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	750
)

addOutfit(
	"Outfits",
	"Abyss Knight",
	"Abyss Knight",
	{
		mount = 0,
		type = 573,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 573,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	1299
)

addOutfit(
	"Outfits",
	"Night Sovereign",
	"Night Sovereign",
	{
		mount = 0,
		type = 574,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 257,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	1499
)

addOutfit(
	"Outfits",
	"Solar Templar",
	"Solar Templar",
	{
		mount = 0,
		type = 578,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 577,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	1799
)

addOutfit(
	"Outfits",
	"Golden Knight",
	"Golden Knight",
	{
		mount = 0,
		type = 632,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 636,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	1999
)

addOutfit(
	"Outfits",
	"Royal Warrior",
	"Royal Warrior",
	{
		mount = 0,
		type = 633,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 637,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	1499
)

addOutfit(
	"Outfits",
	"Astral Judge",
	"Astral Judge",
	{
		mount = 0,
		type = 551,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 547,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	2999
)

addOutfit(
	"Outfits",
	"Death",
	"Death",
	{
		mount = 0,
		type = 548,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 549,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	2999
)

addOutfit(
	"Outfits",
	"Golden Assassin",
	"Golden Assassin",
	{
		mount = 0,
		type = 638,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	{
		mount = 0,
		type = 634,
		addons = 3,
		head = 114,
		body = 114,
		legs = 114,
		feet = 114
	},
	1499
)

	addItem("Outfits", "Outfit doll", "Use to receive one random basic outfit (only outfits priced at 450 points) that you do not own yet.", 5811, 1, 299)

	addCategory("Mounts", "Fine selection of unique mounts.", "mount", 397)
	addMount("Mounts", "Crystal Wolf", "from the deep ice caves", 1, 388, 600)
	addMount("Mounts", "Reindeer", "Must have fallen off the sleigh.", 2, 397, 600)
	addMount("Mounts", "Panda", "From the depts of the jungle.", 3, 398, 600)
	addMount("Mounts", "Dromedary", "Perfect for the northern heatwaves.", 4, 401, 600)
	addMount("Mounts", "Scorpion", "A hard golden armour on this creature.", 5, 402, 600)
	addMount("Mounts", "Horse", "A perfect friend for an adventurer.", 6, 415, 600)
	addMount("Mounts", "War Horse", "Not for an average joe.", 7, 419, 600)
	addMount("Mounts", "Ladybug", "Not for an average joe.", 8, 434, 600)
	addMount("Mounts", "Mantis", "At first glance it seems harmless.", 9, 497, 600)
	addMount("Mounts", "Dragonling", "Who brought this thing from zao?.", 10, 468, 600)
	addMount("Mounts", "Gnarlhound", "Guys come on this is an orc job?.", 11, 475, 600)
	addMount("Mounts", "Red Mantis", "Someone must have been fishing huh?.", 12, 476, 600)
	addMount("Mounts", "Buffalo", "Been to a swamp or two.", 13, 479, 600)

	addCategory("Wings", "Unlock wings (+5 speed while worn).", "wings", 611)
	addWings("Wings", "Golden Butterfly", "Golden butterfly style wings.", 1, 611, 499)
	addWings("Wings", "Magical Butterfly", "Magical butterfly style wings.", 2, 597, 499)
	addWings("Wings", "Cave", "Dark cave themed wings.", 3, 608, 499)
	addWings("Wings", "Rainbow", "Rainbow colored wings.", 4, 585, 499)
	addWings("Wings", "Skeleton", "Skeletal wings.", 5, 601, 499)
	addWings("Wings", "Frozen", "Frozen crystal wings.", 6, 602, 499)
	addWings("Wings", "Pink Power", "Pink flower themed wings.", 7, 603, 499)
	addWings("Wings", "Night", "Night themed wings.", 8, 607, 499)
	addWings("Wings", "Royal", "Royal themed wings.", 9, 609, 499)
	addWings("Wings", "Anubis", "Anubis themed wings.", 10, 610, 499)
	addWings("Wings", "Fire Wings", "Burning fire wings.", 14, 604, 499)
	addWings("Wings", "Storm Wings", "Storm charged wings.", 15, 600, 499)
	addWings("Wings", "Mystic Wings", "Mystic arcane wings.", 16, 598, 499)
	addWings("Wings", "Blood Wings", "Blood red wings.", 17, 596, 499)
	addWings("Wings", "Bloody Wings", "Bloody battle wings.", 18, 595, 499)
	addWings("Wings", "Obsidian Wings", "Obsidian dark wings.", 19, 594, 499)
	addWings("Wings", "Celestial Wings", "Celestial radiant wings.", 20, 593, 499)
	addWings("Wings", "Toxic Wings", "Toxic venom wings.", 21, 592, 499)
	addWings("Wings", "Thunder Wings", "Thunder infused wings.", 22, 591, 499)
	addWings("Wings", "Emerald Wings", "Emerald green wings.", 23, 590, 499)
	addWings("Wings", "Void Wings", "Void touched wings.", 24, 589, 499)
	addWings("Wings", "Infernal Wings", "Infernal demon wings.", 26, 587, 499)
	addWings("Wings", "Ancient Wings", "Ancient relic wings.", 27, 586, 499)
	addWings("Wings", "Sunflare Wings", "Sunflare blazing wings.", 28, 584, 499)
	addWings("Wings", "Moonlight Wings", "Moonlight silver wings.", 29, 583, 499)
	addWings("Wings", "Spirit Wings", "Spirit infused wings.", 30, 582, 499)
	addWings("Wings", "Venom Wings", "Venomous wings.", 31, 581, 499)
	addWings("Wings", "Arcane Wings", "Arcane magic wings.", 32, 580, 499)

	addCategory("Auras", "Unlock auras (+3 speed while worn).", "aura", 612)
	addAura("Auras", "Flame Aura", "A fiery aura effect.", 1, 612, 499)
	addAura("Auras", "Thunder Aura", "A lightning aura effect.", 2, 613, 499)
	addAura("Auras", "Manarune Aura", "A mystical manarune aura.", 3, 615, 499)

	addCategory("Shaders", "Unlock shaders (+2 speed while worn).", "shader", 128)
	addShader("Shaders", "Colorizing Dots", "Animated colorizing dots shader.", 1, 128, 399)
	addShader("Shaders", "Holographic", "Holographic shine shader.", 2, 128, 399)
	addShader("Shaders", "Rainbow Wave", "Rainbow wave shader.", 3, 128, 399)
	addShader("Shaders", "Shine", "Shiny highlight shader.", 4, 128, 399)
	addShader("Shaders", "Darken Starslink", "Dark starslink shader.", 5, 128, 399)
	addShader("Shaders", "Matrix Fall", "Matrix-style falling lines shader.", 6, 128, 399)
	addShader("Shaders", "Outline Green", "Green outline shader.", 7, 128, 399)
	addShader("Shaders", "Outline Rainbow", "Rainbow outline shader.", 9, 128, 399)

	addCategory("Items", "Utility items.", "item", 7962)
	addItem("Items", "Multitool", "Useful tool for adventuring.", 7962, 1, 79)
	addItem("Items", "Ring of Light", "A handy source of light.", 7963, 1, 2)
	addItem("Items", "Gold Converter", "100 uses. Converts 100 gold -> 1 platinum or 100 platinum -> 1 crystal.", 7966, 1, 15, chargedItemStoreCallback(100))
	addItem("Items", "Gold Pouch", "Automatically collects dropped gold to your bank when equipped in a totem slot. Lasts for 7 days.", 7967, 1, 49)
	addItem("Items", "Fishing bag", "Equip in a totem slot to auto-store caught fish. Fish inside weigh 30% less. Lasts for 7 days.", 3939, 1, 19)
	addItem("Items", "professional fishing rod", "Fishes in a 3x3 area. 100 uses.", 7969, 1, 9, chargedItemStoreCallback(100))
	addItem("Items", "frags checker", "Shows your current frags, red skull progress and frag reset timers.", 5953, 1, 99)
	addItem("Items", "blessing checker", "Use to check which blessings you currently have.", 6340, 1, 89)

	addCategory("Containers", "Backpacks and special containers.", "item", 5842)
	addItem("Containers", "Frosty backpack", "A frosty themed backpack. Capacity: 24 slots.", 5842, 1, 10)
	addItem("Containers", "Energy backpack", "An energy themed backpack. Capacity: 24 slots.", 5843, 1, 10)
	addItem("Containers", "Backpack of holding", "A special backpack of holding. Capacity: 24 slots.", 6338, 1, 10)
	addItem("Containers", "War backpack", "A war themed backpack. Capacity: 30 slots.", 5954, 1, 15)
	addItem("Containers", "Goldenruby backpack", "A goldenruby backpack. Capacity: 40 slots.", 5859, 1, 25)

	addItem("Containers", "explo backpack", "Backpack for explosion runes. Capacity: 20 slots.", 5776, 1, 5)
	addItem("Containers", "gfb backpack", "Backpack for great fireball runes. Capacity: 20 slots.", 5777, 1, 5)
	addItem("Containers", "hmm backpack", "Backpack for heavy magic missile runes. Capacity: 20 slots.", 5778, 1, 5)
	addItem("Containers", "ih backpack", "Backpack for intense healing runes. Capacity: 20 slots.", 5779, 1, 5)
	addItem("Containers", "lmm backpack", "Backpack for light magic missile runes. Capacity: 20 slots.", 5780, 1, 5)
	addItem("Containers", "mw backpack", "Backpack for magic wall runes. Capacity: 20 slots.", 5781, 1, 5)
	addItem("Containers", "sd backpack", "Backpack for sudden death runes. Capacity: 20 slots.", 5782, 1, 5)
	addItem("Containers", "uh backpack", "Backpack for ultimate healing runes. Capacity: 20 slots.", 5783, 1, 5)

	local decorCallback = decorParcelStoreCallback()

	addCategory("House decor", "Decor items are delivered as decor parcel. Unpack only inside a house.", "item", 1650)
	addItem("House decor", "small round table", "Packed in decor parcel. Unpack only inside a house.", 1616, 1, 1, decorCallback)
	addItem("House decor", "small table", "Packed in decor parcel. Unpack only inside a house.", 1619, 1, 1, decorCallback)
	addItem("House decor", "throne", "Packed in decor parcel. Unpack only inside a house.", 1646, 1, 1, decorCallback)
	addItem("House decor", "wooden chair", "Packed in decor parcel. Unpack only inside a house.", 1650, 1, 1, decorCallback)
	addItem("House decor", "sofa chair", "Packed in decor parcel. Unpack only inside a house.", 1658, 1, 1, decorCallback)
	addItem("House decor", "red cushioned chair", "Packed in decor parcel. Unpack only inside a house.", 1666, 1, 1, decorCallback)
	addItem("House decor", "green cushioned chair", "Packed in decor parcel. Unpack only inside a house.", 1670, 1, 1, decorCallback)
	addItem("House decor", "rocking chair", "Packed in decor parcel. Unpack only inside a house.", 1674, 1, 1, decorCallback)
	addItem("House decor", "chest of drawers", "Packed in decor parcel. Unpack only inside a house.", 1714, 1, 1, decorCallback)
	addItem("House decor", "pendulum clock", "Packed in decor parcel. Unpack only inside a house.", 1728, 1, 1, decorCallback)
	addItem("House decor", "standing mirror", "Packed in decor parcel. Unpack only inside a house.", 1736, 1, 1, decorCallback)
	addItem("House decor", "purple tapestry", "Packed in decor parcel. Unpack only inside a house.", 1855, 1, 1, decorCallback)
	addItem("House decor", "green tapestry", "Packed in decor parcel. Unpack only inside a house.", 1858, 1, 1, decorCallback)
	addItem("House decor", "yellow tapestry", "Packed in decor parcel. Unpack only inside a house.", 1861, 1, 1, decorCallback)
	addItem("House decor", "orange tapestry", "Packed in decor parcel. Unpack only inside a house.", 1864, 1, 1, decorCallback)
	addItem("House decor", "red tapestry", "Packed in decor parcel. Unpack only inside a house.", 1867, 1, 1, decorCallback)
	addItem("House decor", "blue tapestry", "Packed in decor parcel. Unpack only inside a house.", 1870, 1, 1, decorCallback)
	addItem("House decor", "white tapestry", "Packed in decor parcel. Unpack only inside a house.", 1878, 1, 1, decorCallback)
	addItem("House decor", "candelabrum", "Packed in decor parcel. Unpack only inside a house.", 2041, 1, 1, decorCallback)
	addItem("House decor", "candlestick", "Packed in decor parcel. Unpack only inside a house.", 2047, 1, 1, decorCallback)
	addItem("House decor", "small oil lamp", "Packed in decor parcel. Unpack only inside a house.", 2062, 1, 1, decorCallback)
	addItem("House decor", "piano", "Packed in decor parcel. Unpack only inside a house.", 2080, 1, 1, decorCallback)
	addItem("House decor", "harp", "Packed in decor parcel. Unpack only inside a house.", 2084, 1, 1, decorCallback)
	addItem("House decor", "god flowers", "Packed in decor parcel. Unpack only inside a house.", 2100, 1, 1, decorCallback)
	addItem("House decor", "indoor plant", "Packed in decor parcel. Unpack only inside a house.", 2101, 1, 1, decorCallback)
	addItem("House decor", "flower bowl", "Packed in decor parcel. Unpack only inside a house.", 2102, 1, 1, decorCallback)
	addItem("House decor", "honey flower", "Packed in decor parcel. Unpack only inside a house.", 2103, 1, 1, decorCallback)
	addItem("House decor", "potted flower", "Packed in decor parcel. Unpack only inside a house.", 2104, 1, 1, decorCallback)
	addItem("House decor", "big flowerpot", "Packed in decor parcel. Unpack only inside a house.", 2106, 1, 1, decorCallback)
	addItem("House decor", "exotic flower", "Packed in decor parcel. Unpack only inside a house.", 2107, 1, 1, decorCallback)
	addItem("House decor", "crate", "Packed in decor parcel. Unpack only inside a house.", 1739, 1, 1, decorCallback)
	addItem("House decor", "barrel", "Packed in decor parcel. Unpack only inside a house.", 1770, 1, 1, decorCallback)
	addItem("House decor", "vase", "Packed in decor parcel. Unpack only inside a house.", 2008, 1, 1, decorCallback)
	addItem("House decor", "pot", "Packed in decor parcel. Unpack only inside a house.", 2562, 1, 1, decorCallback)
	addItem("House decor", "white vase", "Packed in decor parcel. Unpack only inside a house.", 2574, 1, 1, decorCallback)
	addItem("House decor", "yellow vase", "Packed in decor parcel. Unpack only inside a house.", 2575, 1, 1, decorCallback)
	addItem("House decor", "blue vase", "Packed in decor parcel. Unpack only inside a house.", 2576, 1, 1, decorCallback)
	addItem("House decor", "green vase", "Packed in decor parcel. Unpack only inside a house.", 2577, 1, 1, decorCallback)
	addItem("House decor", "statue", "Packed in decor parcel. Unpack only inside a house.", 1442, 1, 1, decorCallback)
	addItem("House decor", "minotaur statue", "Packed in decor parcel. Unpack only inside a house.", 1446, 1, 1, decorCallback)
	addItem("House decor", "goblin statue", "Packed in decor parcel. Unpack only inside a house.", 1447, 1, 1, decorCallback)
	addItem("House decor", "carved stone table", "Packed in decor parcel. Unpack only inside a house.", 3805, 1, 1, decorCallback)
	addItem("House decor", "tusk table", "Packed in decor parcel. Unpack only inside a house.", 3807, 1, 1, decorCallback)
	addItem("House decor", "bamboo table", "Packed in decor parcel. Unpack only inside a house.", 3809, 1, 1, decorCallback)
	addItem("House decor", "tusk chair", "Packed in decor parcel. Unpack only inside a house.", 3813, 1, 1, decorCallback)
	addItem("House decor", "ivory chair", "Packed in decor parcel. Unpack only inside a house.", 3817, 1, 1, decorCallback)
	addItem("House decor", "bamboo drawer", "Packed in decor parcel. Unpack only inside a house.", 3832, 1, 1, decorCallback)

	addCategory("Scrolls", "Utility and special account scrolls.", "item", 5546)
	addItem("Scrolls", "market scroll", "First use starts 48h market access.", 2329, 1, 5, marketTicketStoreCallback())
	addItem("Scrolls", "blessing scroll", "Grants all blessings.", 5542, 1, 55)
	addItem("Scrolls", "experience booster", "Grants +30% exp for 1 hour. Limit: once per 24h.", 5540, 1, 99)
	addItem("Scrolls", "frag remover", "Removes all unjustified kills and skull. Limit: once per 30 days.", 5541, 1, 99)
	addItem("Scrolls", "rashid scroll", "Unlocks Rashid trade access.", 5543, 1, 499)
	addItem("Scrolls", "sex change scroll", "Changes your character sex.", 5544, 1, 99)
	addItem("Scrolls", "name change scroll", "Lets you change your character name (unique, no numbers).", 5747, 1, 199)
	addItem("Scrolls", "postman scroll", "Unlocks postman quest access.", 5746, 1, 399)

	addCategory("Training", "Exercise weapons.", "item", 6876)
	addItem("Training", "Exercise Wand", "1500 uses. Does not consume mana.", 6876, 1, 109, trainingWeaponStoreCallback())
	addItem("Training", "Exercise Rod", "1500 uses. Does not consume mana.", 6877, 1, 109, trainingWeaponStoreCallback())
	addItem("Training", "Exercise Bow", "1500 uses. Attack speed is 10% faster.", 6878, 1, 109, trainingWeaponStoreCallback())
	addItem("Training", "Exercise Axe", "1500 uses. Attack speed is 10% faster.", 6879, 1, 109, trainingWeaponStoreCallback())
	addItem("Training", "Exercise Sword", "1500 uses. Attack speed is 10% faster.", 6880, 1, 109, trainingWeaponStoreCallback())
	addItem("Training", "Exercise Club", "1500 uses. Attack speed is 10% faster.", 6881, 1, 109, trainingWeaponStoreCallback())

	-- Keep all store offers ordered by price (cheap -> expensive), then by title.
	for _, offersTable in pairs(GAME_STORE.offers) do
		if type(offersTable) == "table" then
			table.sort(
				offersTable,
				function(a, b)
					local pa = tonumber(a.price) or 0
					local pb = tonumber(b.price) or 0
					if pa ~= pb then
						return pa < pb
					end
					return tostring(a.title or "") < tostring(b.title or "")
				end
			)
		end
	end

end

local ExtendedEvent = CreatureEvent("GameStoreExtended")

function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode == CODE_GAMESTORE then
		if not GAME_STORE then
			gameStoreInitialize()
			addEvent(refreshPlayersPoints, 10 * 1000)
		end

		local status, json_data =
			pcall(
			function()
				return json.decode(buffer)
			end
		)
		if not status then
			return
		end

		local action = json_data.action
		local data = json_data.data
		if not action or not data then
			return
		end

		if action == "fetch" then
			gameStoreFetch(player)
		elseif action == "purchase" then
			gameStorePurchase(player, data)
		elseif action == "gift" then
			gameStorePurchaseGift(player, data)
		end
	end
end

function gameStoreFetch(player)
	local sex = player:getSex()

	player:sendExtendedOpcode(CODE_GAMESTORE, json.encode({action = "fetchBase", data = {categories = GAME_STORE.categories, url = DONATION_URL}}))

	for category, offersTable in pairs(GAME_STORE.offers) do
		local offers = {}

		for i = 1, #offersTable do
			local offer = offersTable[i]
			local data = {
				type = offer.type,
				title = offer.title,
				description = offer.description,
				price = offer.price
			}

			if offer.count then
				data.count = offer.count
			end
			if offer.clientId then
				data.clientId = offer.clientId
			end
			if offer.shaderName then
				data.shaderName = offer.shaderName
			end
			if offer.shader then
				data.shader = offer.shader
			end
			if offer.wings then
				data.wings = offer.wings
			end
			if offer.aura then
				data.aura = offer.aura
			end
		
			local includeOffer = true
			if offer.type == "outfit" then
				if sex == PLAYERSEX_MALE then
					data.outfit = offer.outfitMale
				else
					data.outfit = offer.outfitFemale
				end

				-- Hide sex-locked outfit offers that do not have a variant for current player sex.
				if not data.outfit then
					includeOffer = false
				end
			else
				if sex == PLAYERSEX_MALE then
					if offer.outfitMale then
						data.outfit = offer.outfitMale
					end
				else
					if offer.outfitFemale then
						data.outfit = offer.outfitFemale
					end
				end
			end
			if includeOffer then
				if offer.data then
					data.data = offer.data
				end
				table.insert(offers, data)
			end
		end

		local total = math.max(1, math.ceil(#offers / GAME_STORE_OFFERS_CHUNK_SIZE))
		for chunk = 1, total do
			local first = ((chunk - 1) * GAME_STORE_OFFERS_CHUNK_SIZE) + 1
			local last = math.min(first + GAME_STORE_OFFERS_CHUNK_SIZE - 1, #offers)
			local part = {}
			for i = first, last do
				part[#part + 1] = offers[i]
			end

			player:sendExtendedOpcode(
				CODE_GAMESTORE,
				json.encode(
					{
						action = "fetchOffers",
						data = {
							category = category,
							offers = part,
							chunk = chunk,
							total = total
						}
					}
				)
			)
		end
	end

	gameStoreUpdatePoints(player)
	gameStoreUpdateHistory(player)
end

function gameStoreUpdatePoints(player)
	if type(player) == "number" then
		player = Player(player)
	end
	player:sendExtendedOpcode(CODE_GAMESTORE, json.encode({action = "points", data = getPoints(player)}))
end

function gameStoreUpdateHistory(player)
	if type(player) == "number" then
		player = Player(player)
	end
	local history = {}
	local priceColumn = getShopHistoryPriceColumn()
	local hasCountColumn = shopHistoryHasColumn("count")
	local hasTargetColumn = shopHistoryHasColumn("target")
	local hasDetailsColumn = shopHistoryHasColumn("details")
	local resultId = db.storeQuery("SELECT * FROM `shop_history` WHERE `account` = " .. player:getAccountId() .. " order by `id` DESC")

	if resultId ~= false then
		repeat
			local title = result.getDataString(resultId, "title")
			if title == "" then
				title = "unknown item"
			end

			local desc = "Bought " .. title
			local count = 0
			if hasCountColumn then
				count = tonumber(result.getDataInt(resultId, "count")) or 0
			end
			if count > 0 then
				desc = desc .. " (x" .. count .. ")"
			end

			local points = 0
			if priceColumn then
				points = tonumber(result.getDataInt(resultId, priceColumn)) or 0
			end

			local target = ""
			if hasTargetColumn then
				target = result.getDataString(resultId, "target")
			end

			if target == "" and hasDetailsColumn then
				local details = result.getDataString(resultId, "details")
				if details and details:sub(1, 5) == "gift:" then
					target = details:sub(6)
				end
			end

			if target ~= "" then
				desc = desc .. " on " .. result.getDataString(resultId, "date") .. " for " .. target .. " for " .. points .. " points."
			else
				desc = desc .. " on " .. result.getDataString(resultId, "date") .. " for " .. points .. " points."
			end
			table.insert(history, desc)
		until not result.next(resultId)
		result.free(resultId)
	end

	local total = math.max(1, math.ceil(#history / GAME_STORE_HISTORY_CHUNK_SIZE))
	for chunk = 1, total do
		local first = ((chunk - 1) * GAME_STORE_HISTORY_CHUNK_SIZE) + 1
		local last = math.min(first + GAME_STORE_HISTORY_CHUNK_SIZE - 1, #history)
		local part = {}
		for i = first, last do
			part[#part + 1] = history[i]
		end

		player:sendExtendedOpcode(
			CODE_GAMESTORE,
			json.encode(
				{
					action = "history",
					data = {
						entries = part,
						chunk = chunk,
						total = total
					}
				}
			)
		)
	end
end

function gameStorePurchase(player, offer)
	local offers = GAME_STORE.offers[offer.category]
	if not offers then
		return errorMsg(player, "Something went wrong, try again or contact server admin [#1]!")
	end
	for i = 1, #offers do
		if offers[i].title == offer.title and offers[i].price == offer.price then
			local callback = offers[i].callback
			if not callback then
				return errorMsg(player, "Something went wrong, try again or contact server admin [#2]!")
			end

			local points = getPoints(player)
			if offers[i].price > points then
				return errorMsg(player, "You don't have enough points!")
			end

			if offers[i].itemId == EXPERIENCE_BOOSTER_ITEM_ID then
				local remaining = experienceBoosterCooldownRemaining(player:getAccountId())
				if remaining > 0 then
					return errorMsg(
						player,
						"Experience booster can be bought once every 24 hours. Remaining: " .. formatCooldown(remaining) .. "."
					)
				end
			end

			if offers[i].itemId == FRAG_REMOVER_ITEM_ID then
				local remaining = fragRemoverCooldownRemaining(player:getAccountId())
				if remaining > 0 then
					return errorMsg(
						player,
						"Frag remover can be bought once every 30 days. Remaining: " .. formatCooldownWithDays(remaining) .. "."
					)
				end
			end

			local status = callback(player, offers[i])
			if status ~= true then
				return errorMsg(player, status)
			end

			local aid = player:getAccountId()
			local price = offers[i].price
			local count = offers[i].count or 0

			db.query("UPDATE `accounts` set `premium_points` = `premium_points` - " .. offers[i].price .. " WHERE `id` = " .. aid)
			insertShopHistory(aid, player:getGuid(), offers[i].title, price, count, nil)
			addEvent(gameStoreUpdateHistory, 1000, player:getId())
			addEvent(gameStoreUpdatePoints, 1000, player:getId())
			return infoMsg(player, "You've bought " .. offers[i].title .. "!", true)
		end
	end
	return errorMsg(player, "Something went wrong, try again or contact server admin [#4]!")
end

function gameStorePurchaseGift(player, offer)
	local offers = GAME_STORE.offers[offer.category]
	if not offers then
		return errorMsg(player, "Something went wrong, try again or contact server admin [#1]!")
	end
	if not offer.target then
		return errorMsg(player, "Target player not found!")
	end
	for i = 1, #offers do
		if offers[i].title == offer.title and offers[i].price == offer.price then
			local callback = offers[i].callback
			if not callback then
				return errorMsg(player, "Something went wrong, try again or contact server admin [#2]!")
			end

			local points = getPoints(player)
			if offers[i].price > points then
				return errorMsg(player, "You don't have enough points!")
			end

			if offers[i].itemId == EXPERIENCE_BOOSTER_ITEM_ID then
				local remaining = experienceBoosterCooldownRemaining(player:getAccountId())
				if remaining > 0 then
					return errorMsg(
						player,
						"Experience booster can be bought once every 24 hours. Remaining: " .. formatCooldown(remaining) .. "."
					)
				end
			end

			if offers[i].itemId == FRAG_REMOVER_ITEM_ID then
				local remaining = fragRemoverCooldownRemaining(player:getAccountId())
				if remaining > 0 then
					return errorMsg(
						player,
						"Frag remover can be bought once every 30 days. Remaining: " .. formatCooldownWithDays(remaining) .. "."
					)
				end
			end

			local targetPlayer = Player(offer.target)
			if not targetPlayer then
				return errorMsg(player, "Target player not found!")
			end

			local status = callback(targetPlayer, offers[i])
			if status ~= true then
				return errorMsg(player, status)
			end

			local aid = player:getAccountId()
			local price = offers[i].price
			local count = offers[i].count or 0
			db.query("UPDATE `accounts` set `premium_points` = `premium_points` - " .. offers[i].price .. " WHERE `id` = " .. aid)
			insertShopHistory(aid, player:getGuid(), offers[i].title, price, count, targetPlayer:getName())
			addEvent(gameStoreUpdateHistory, 1000, player:getId())
			addEvent(gameStoreUpdatePoints, 1000, player:getId())
			return infoMsg(player, "You've bought " .. offers[i].title .. " for " .. targetPlayer:getName() .. "!", true)
		end
	end
	return errorMsg(player, "Something went wrong, try again or contact server admin [#4]!")
end

function getPoints(player)
	local points = 0
	local resultId = db.storeQuery("SELECT `premium_points` FROM `accounts` WHERE `id` = " .. player:getAccountId())
	if resultId ~= false then
		points = result.getDataInt(resultId, "premium_points")
		result.free(resultId)
	end
	return points
end

function errorMsg(player, msg)
	player:sendExtendedOpcode(CODE_GAMESTORE, json.encode({action = "msg", data = {type = "error", msg = msg}}))
end

function infoMsg(player, msg, close)
	if not close then
		close = false
	end
	player:sendExtendedOpcode(CODE_GAMESTORE, json.encode({action = "msg", data = {type = "info", msg = msg, close = close}}))
end

function addCategory(title, description, iconType, iconData)
	if iconType == "item" then
		iconData = ItemType(iconData):getClientId()
	end

	table.insert(
		GAME_STORE.categories,
		{
			title = title,
			description = description,
			iconType = iconType,
			iconData = iconData
		}
	)
end

function addItem(category, title, description, itemId, count, price, callback)
	if not GAME_STORE.offers[category] then
		GAME_STORE.offers[category] = {}
	end

	if not callback then
		callback = defaultItemCallback
	end

	table.insert(
		GAME_STORE.offers[category],
		{
			type = "item",
			title = title,
			description = description,
			itemId = itemId,
			count = count,
			price = price,
			clientId = ItemType(itemId):getClientId(),
			callback = callback
		}
	)
end

function addOutfit(category, title, description, outfitMale, outfitFemale, price, callback)
	if not GAME_STORE.offers[category] then
		GAME_STORE.offers[category] = {}
	end

	if not callback then
		callback = defaultOutfitCallback
	end

	table.insert(
		GAME_STORE.offers[category],
		{
			type = "outfit",
			title = title,
			description = description,
			outfitMale = outfitMale,
			outfitFemale = outfitFemale,
			price = price,
			callback = callback
		}
	)

	-- Keep male/female mirror mapping globally so sex-change can preserve outfits with counterparts.
	if outfitMale and outfitFemale and outfitMale.type and outfitFemale.type then
		registerOutfitMirrorPair(outfitMale.type, outfitFemale.type)
	end
end

function addOutfitForSex(category, title, description, outfitData, sex, price, callback)
	if sex == PLAYERSEX_MALE then
		return addOutfit(category, title, description, outfitData, nil, price, callback)
	end
	return addOutfit(category, title, description, nil, outfitData, price, callback)
end

function addMount(category, title, description, mountId, clientId, price, callback)
	if not GAME_STORE.offers[category] then
		GAME_STORE.offers[category] = {}
	end

	if not callback then
		callback = defaultMountCallback
	end

	table.insert(
		GAME_STORE.offers[category],
		{
			type = "mount",
			title = title,
			description = description,
			mount = mountId,
			clientId = clientId,
			price = price,
			callback = callback
		}
	)
end



function addWings(category, title, description, wingsId, clientId, price, callback)
    if not GAME_STORE.offers[category] then
        GAME_STORE.offers[category] = {}
    end

    if category == "Wings" then
        price = 699
        if type(description) ~= "string" then
            description = ""
        end
        if not description:find("Grants +5 speed while worn.", 1, true) then
            description = description:gsub("%s+$", "")
            if description ~= "" and not description:find("%.$") then
                description = description .. "."
            end
            if description ~= "" then
                description = description .. " "
            end
            description = description .. "Grants +5 speed while worn."
        end
    end

    if not callback then
        callback = defaultWingsCallback
    end

    table.insert(
        GAME_STORE.offers[category],
        {
            type = "wings",
            title = title,
            description = description,
            wings = wingsId,
            clientId = clientId,
            price = price,
            callback = callback
        }
    )
end

function addAura(category, title, description, auraId, clientId, price, callback)
    if not GAME_STORE.offers[category] then
        GAME_STORE.offers[category] = {}
    end

    if category == "Auras" then
        price = 499
        if type(description) ~= "string" then
            description = ""
        end
        if not description:find("Grants +3 speed while worn.", 1, true) then
            description = description:gsub("%s+$", "")
            if description ~= "" and not description:find("%.$") then
                description = description .. "."
            end
            if description ~= "" then
                description = description .. " "
            end
            description = description .. "Grants +3 speed while worn."
        end
    end

    if not callback then
        callback = defaultAuraCallback
    end

    table.insert(
        GAME_STORE.offers[category],
        {
            type = "aura",
            title = title,
            description = description,
            aura = auraId,
            clientId = clientId,
            price = price,
            callback = callback
        }
    )
end

function defaultWingsCallback(player, offer)
    if player:hasWings(offer.wings) then
        return "You already have these wings."
    end

    player:addWings(offer.wings)
    return true
end

function defaultAuraCallback(player, offer)
    if player:hasAura(offer.aura) then
        return "You already have this aura."
    end

    player:addAura(offer.aura)
    return true
end




function addShader(category, title, description, shaderId, clientId, price, callback)
	if not GAME_STORE.offers[category] then
		GAME_STORE.offers[category] = {}
	end

	if category == "Shaders" then
		price = 399
		if type(description) ~= "string" then
			description = ""
		end
		if not description:find("Grants +2 speed while worn.", 1, true) then
			description = description:gsub("%s+$", "")
			if description ~= "" and not description:find("%.$") then
				description = description .. "."
			end
			if description ~= "" then
				description = description .. " "
			end
			description = description .. "Grants +2 speed while worn."
		end
	end

	local shaderNameById = {
		[1] = "Colorizing Dots",
		[2] = "Holographic",
		[3] = "Rainbow Wave",
		[4] = "Shine",
		[5] = "Darken Starslink",
		[6] = "Matrix Fall",
		[7] = "outlinegreen",
		[8] = "RedGlow",
		[9] = "outlinerainbow"
	}

	if not callback then
		callback = defaultShaderCallback
	end

	table.insert(
		GAME_STORE.offers[category],
		{
			type = "shader",
			title = title,
			description = description,
			shader = shaderId,
			shaderName = shaderNameById[shaderId] or title,
			clientId = clientId,
			price = price,
			callback = callback
		}
	)
end

function defaultShaderCallback(player, offer)
	if player:hasShader(offer.shader) then
		return "You already have this shader."
	end

	player:addShader(offer.shader)
	return true
end

function addCustom(category, type, title, description, data, count, price, callback)
	if not GAME_STORE.offers[category] then
		GAME_STORE.offers[category] = {}
	end

	if not callback then
		error("[Game Store] addCustom " .. title .. " without callback")
		return
	end

	table.insert(
		GAME_STORE.offers[category],
		{
			type = type,
			title = title,
			description = description,
			data = data,
			price = price,
			count = count,
			callback = callback
		}
	)
end

function defaultItemCallback(player, offer)
	local weight = ItemType(offer.itemId):getWeight(offer.count)
	if player:getFreeCapacity() < weight then
		return "This item is too heavy for you!"
	end

	local item = player:getSlotItem(CONST_SLOT_BACKPACK)
	if not item then
		return "You don't have enough space in backpack."
	end
	local slots = item:getEmptySlots(true)
	if slots <= 0 then
		return "You don't have enough space in backpack."
	end

	if player:addItem(offer.itemId, offer.count, false) then
		return true
	end

	return "Something went wrong, item couldn't be added."
end

function defaultOutfitCallback(player, offer)
	local selected = player:getSex() == PLAYERSEX_MALE and offer.outfitMale or offer.outfitFemale
	if not selected then
		return "This outfit is not available for your character sex."
	end

	local opposite = player:getSex() == PLAYERSEX_MALE and offer.outfitFemale or offer.outfitMale
	local checkAddons = selected.addons or 0
	local hasSelected = checkAddons > 0 and player:hasOutfit(selected.type, checkAddons) or player:hasOutfit(selected.type)
	local hasOpposite = false
	if opposite then
		local oppositeAddons = opposite.addons or 0
		hasOpposite = oppositeAddons > 0 and player:hasOutfit(opposite.type, oppositeAddons) or player:hasOutfit(opposite.type)
	end

	if hasSelected and (not opposite or hasOpposite) then
		if checkAddons > 0 then
			return "You already have this outfit with addons."
		end
		return "You already have this outfit."
	end

	if checkAddons > 0 then
		player:addOutfitAddon(selected.type, checkAddons)
	else
		player:addOutfit(selected.type)
	end

	-- If this outfit has a male/female counterpart, grant it too to survive sex changes.
	if opposite then
		local oppositeAddons = opposite.addons or 0
		if oppositeAddons > 0 then
			player:addOutfitAddon(opposite.type, oppositeAddons)
		else
			player:addOutfit(opposite.type)
		end
	end

	return true
end

function defaultMountCallback(player, offer)
	if player:hasMount(offer.mount) then
		return "You already have this mount."
	end

	player:addMount(offer.mount)
	return true
end

function refreshPlayersPoints()
	for _, p in ipairs(Game.getPlayers()) do
		if p:getIp() > 0 then
			gameStoreUpdatePoints(p)
		end
	end
	addEvent(refreshPlayersPoints, 10 * 1000)
end

LoginEvent:type("login")
LoginEvent:register()
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()
