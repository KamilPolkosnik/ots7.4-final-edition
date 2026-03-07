local DONATION_URL = "https://website.com/donate.php"

local CODE_GAMESTORE = 102
local GAME_STORE = nil

local LoginEvent = CreatureEvent("GameStoreLogin")
local PREMIUM_SCROLL_ACTION_7 = 60007
local PREMIUM_SCROLL_ACTION_15 = 60015
local PREMIUM_SCROLL_ACTION_60 = 60060
local PREMIUM_SCROLL_ACTION_120 = 60120
local MARKET_TICKET_ACTION = 65048
local EXPERIENCE_BOOSTER_ITEM_ID = 5540
local EXPERIENCE_BOOSTER_COOLDOWN = 24 * 60 * 60
local SHOP_HISTORY_TABLE = "shop_history"
local SHOP_HISTORY_COLUMN_CACHE = {}
local SHOP_HISTORY_ID_EXPLICIT = nil

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

local function experienceBoosterCooldownRemaining(accountId)
	accountId = math.floor(tonumber(accountId) or 0)
	if accountId <= 0 then
		return 0
	end

	local q = string.format(
		"SELECT UNIX_TIMESTAMP(`date`) AS `ts` FROM `%s` WHERE `account` = %d AND LOWER(`title`) = %s ORDER BY `date` DESC LIMIT 1",
		SHOP_HISTORY_TABLE,
		accountId,
		db.escapeString("experience booster")
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

	local elapsed = os.time() - ts
	if elapsed >= EXPERIENCE_BOOSTER_COOLDOWN then
		return 0
	end
	return EXPERIENCE_BOOSTER_COOLDOWN - elapsed
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

	addCategory("Premium", "Premium account scrolls.", "item", 5546)
	addItem(
		"Premium",
		"7 days premium account scroll",
		"Premium account for 7 days.",
		5546,
		1,
		150,
		premiumScrollStoreCallback(7, PREMIUM_SCROLL_ACTION_7)
	)
	-- Keep 7-day behavior (item id 5545) but use same icon as other premium scrolls.
	if GAME_STORE.offers.Premium and GAME_STORE.offers.Premium[#GAME_STORE.offers.Premium] then
		local sharedPremiumClientId = ItemType(5546):getClientId()
		if sharedPremiumClientId and sharedPremiumClientId > 0 then
			GAME_STORE.offers.Premium[#GAME_STORE.offers.Premium].clientId = sharedPremiumClientId
		end
	end
	addItem(
		"Premium",
		"15 days premium account scroll",
		"Premium account for 15 days.",
		5546,
		1,
		200,
		premiumScrollStoreCallback(15, PREMIUM_SCROLL_ACTION_15)
	)
	addItem(
		"Premium",
		"30 days premium account scroll",
		"Premium account for 30 days.",
		5546,
		1,
		300,
		premiumScrollStoreCallback(30)
	)
	addItem(
		"Premium",
		"60 days premium account scroll",
		"Premium account for 60 days.",
		5546,
		1,
		500,
		premiumScrollStoreCallback(60, PREMIUM_SCROLL_ACTION_60)
	)
	addItem(
		"Premium",
		"120 days premium account scroll",
		"Premium account for 120 days.",
		5546,
		1,
		950,
		premiumScrollStoreCallback(120, PREMIUM_SCROLL_ACTION_120)
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
	"Noblewoman",
	"Noblewoman",
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

	addCategory("Items", "Utility items.", "item", 7962)
	addItem("Items", "Multitool", "Useful tool for adventuring.", 7962, 1, 100)
	addItem("Items", "Ring of Light", "A handy source of light.", 7963, 1, 2)
	addItem("Items", "Gold Converter", "100 uses. Converts 100 gold -> 1 platinum or 100 platinum -> 1 crystal.", 7966, 1, 10, chargedItemStoreCallback(100))
	addItem("Items", "Gold Pouch", "Automatically collects dropped gold to your bank when equipped in a totem slot.", 7967, 1, 499)

	addCategory("Scrolls", "Utility and special account scrolls.", "item", 5546)
	addItem("Scrolls", "market scroll", "First use starts 48h market access.", 2329, 1, 5, marketTicketStoreCallback())
	addItem("Scrolls", "blessing scroll", "Grants all blessings.", 5542, 1, 55)
	addItem("Scrolls", "experience booster", "Grants +30% exp for 1 hour. Limit: once per 24h.", 5540, 1, 99)
	addItem("Scrolls", "rashid scroll", "Unlocks Rashid trade access.", 5543, 1, 499)
	addItem("Scrolls", "sex change scroll", "Changes your character sex.", 5544, 1, 99)
	addItem("Scrolls", "postman scroll", "Unlocks postman quest access.", 5746, 1, 399)

	addCategory("Training", "Exercise weapons.", "item", 6876)
	addItem("Training", "Exercise Wand", "1500 uses. Does not consume mana.", 6876, 1, 50, trainingWeaponStoreCallback())
	addItem("Training", "Exercise Rod", "1500 uses. Does not consume mana.", 6877, 1, 50, trainingWeaponStoreCallback())
	addItem("Training", "Exercise Bow", "1500 uses. Attack speed is 10% faster.", 6878, 1, 50, trainingWeaponStoreCallback())
	addItem("Training", "Exercise Axe", "1500 uses. Attack speed is 10% faster.", 6879, 1, 50, trainingWeaponStoreCallback())
	addItem("Training", "Exercise Sword", "1500 uses. Attack speed is 10% faster.", 6880, 1, 50, trainingWeaponStoreCallback())
	addItem("Training", "Exercise Club", "1500 uses. Attack speed is 10% faster.", 6881, 1, 50, trainingWeaponStoreCallback())

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
		
			if sex == PLAYERSEX_MALE then
				if offer.outfitMale then
					data.outfit = offer.outfitMale
				end
			else
				if offer.outfitFemale then
					data.outfit = offer.outfitFemale
				end
			end
			if offer.data then
				data.data = offer.data
			end
			table.insert(offers, data)
		end
		player:sendExtendedOpcode(CODE_GAMESTORE, json.encode({action = "fetchOffers", data = {category = category, offers = offers}}))
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
	local resultId = db.storeQuery("SELECT * FROM `shop_history` WHERE `account` = " .. player:getAccountId() .. " order by `id` DESC")

	if resultId ~= false then
		repeat
			local desc = "Bought " .. result.getDataString(resultId, "title")
			local count = result.getDataInt(resultId, "count")
			if count > 0 then
				desc = desc .. " (x" .. count .. ")"
			end
			local target = result.getDataString(resultId, "target")
			if target ~= "" then
				desc = desc .. " on " .. result.getDataString(resultId, "date") .. " for " .. target .. " for " .. result.getDataInt(resultId, "price") .. " points."
			else
				desc = desc .. " on " .. result.getDataString(resultId, "date") .. " for " .. result.getDataInt(resultId, "price") .. " points."
			end
			table.insert(history, desc)
		until not result.next(resultId)
		result.free(resultId)
	end
	player:sendExtendedOpcode(CODE_GAMESTORE, json.encode({action = "history", data = history}))
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




function addShader(category, title, description, ShaderId, clientId, price, callback)
	if not GAME_STORE.offers[category] then
		GAME_STORE.offers[category] = {}
	end

	if not callback then
		callback = defaultShaderCallback
	end

	table.insert(
		GAME_STORE.offers[category],
		{
			type = "Shader",
			title = title,
			description = description,
			Shader = ShaderId,
			clientId = 131,
			price = price,
			callback = callback
		}
	)
end

function defaultShaderCallback(player, offer)
	if player:hasShader(offer.Shader) then
		return "You already have this Shader."
	end

	player:addShader(offer.Shader)
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
	if offer.outfitMale.addons > 0 then
		if player:hasOutfit(offer.outfitMale.type, offer.outfitMale.addons) then
			return "You already have this outfit with addons."
		end

		player:addOutfitAddon(offer.outfitMale.type, offer.outfitMale.addons)
	else
		if player:hasOutfit(offer.outfitMale.type) then
			return "You already have this outfit."
		end

		player:addOutfit(offer.outfitMale.type)
	end
	if offer.outfitFemale.addons > 0 then
		player:addOutfitAddon(offer.outfitFemale.type, offer.outfitFemale.addons)
	else
		player:addOutfit(offer.outfitFemale.type)
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
