MarketSystem = MarketSystem or {}

MarketSystem.OPCODE = 116
MarketSystem.TICKET_STORAGE = 1460000
MarketSystem.TICKET_DURATION = 48 * 60 * 60
MarketSystem.TICKET_AID = 65048
MarketSystem.TICKET_USED_AID = 65049
MarketSystem.TICKET_ITEM_ID = 2329
MarketSystem.STALL_MONSTER = "Market Stall"
MarketSystem.STALL_DURATION = 48 * 60 * 60
MarketSystem.MAX_PRICE = 2000000000
MarketSystem.MAX_OFFERS = 200
MarketSystem.DESCRIPTION_MAXLEN = 30

MarketSystem.byStallCreature = MarketSystem.byStallCreature or {}
MarketSystem.byCreatureStall = MarketSystem.byCreatureStall or {}
MarketSystem.stallDescriptionById = MarketSystem.stallDescriptionById or {}
MarketSystem.stallNextSpeechAt = MarketSystem.stallNextSpeechAt or {}

local CONTAINER_POS = 0xFFFF
local MAX_CONTAINER_SCAN_ID = 31
local MAX_CONTAINER_RECURSION = 8

local function trim(v)
	return tostring(v or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function toNum(v, d)
	local n = tonumber(v)
	if not n then
		return d or 0
	end
	return n
end

local function parseRows(resultId, parser)
	local rows = {}
	if not resultId then
		return rows
	end
	repeat
		rows[#rows + 1] = parser(resultId)
	until not result.next(resultId)
	result.free(resultId)
	return rows
end

local function sendPayload(player, payload)
	if not player or not player:isPlayer() then
		return
	end
	local encoded = json.encode(payload)
	if TaskSystem and TaskSystem.sendChunked then
		TaskSystem.sendChunked(player, MarketSystem.OPCODE, encoded)
	else
		player:sendExtendedOpcode(MarketSystem.OPCODE, encoded)
	end
end

local function sendResult(player, ok, message)
	sendPayload(player, {
		action = "result",
		data = {ok = ok and true or false, message = tostring(message or "")}
	})
end

-- Forward declarations used before concrete definitions.
local getActiveStallPosition
local canPlayerUseStall

local function dbN(row, col)
	return tonumber(result.getNumber(row, col)) or 0
end

local function dbS(row, col)
	return tostring(result.getString(row, col) or "")
end

local function tableHasColumn(tableName, columnName)
	local q = string.format("SHOW COLUMNS FROM `%s` LIKE %s", tableName, db.escapeString(columnName))
	local r = db.storeQuery(q)
	if r then
		result.free(r)
		return true
	end
	return false
end

local _hasColumnCache = {}
local _idInsertModeCache = {}
local function hasColumnCached(tableName, columnName)
	local key = tostring(tableName) .. "." .. tostring(columnName)
	local cached = _hasColumnCache[key]
	if cached ~= nil then
		return cached
	end
	local exists = tableHasColumn(tableName, columnName)
	_hasColumnCache[key] = exists and true or false
	return _hasColumnCache[key]
end

local function idRequiresExplicitInsert(tableName)
	local key = tostring(tableName) .. ".__id_explicit"
	local cached = _idInsertModeCache[key]
	if cached ~= nil then
		return cached
	end

	if not tableHasColumn(tableName, "id") then
		_idInsertModeCache[key] = false
		return false
	end

	local q = string.format("SHOW COLUMNS FROM `%s` LIKE 'id'", tableName)
	local r = db.storeQuery(q)
	local extra = ""
	if r then
		extra = string.lower(dbS(r, "Extra") or "")
		result.free(r)
	end
	local explicit = extra:find("auto_increment", 1, true) == nil
	_idInsertModeCache[key] = explicit and true or false
	return _idInsertModeCache[key]
end

local function addColumnIfMissing(tableName, columnName, ddl)
	if tableHasColumn(tableName, columnName) then
		return
	end
	db.query(string.format("ALTER TABLE `%s` ADD COLUMN %s", tableName, ddl))
end

local function columnExtra(tableName, columnName)
	local q = string.format("SHOW COLUMNS FROM `%s` LIKE %s", tableName, db.escapeString(columnName))
	local r = db.storeQuery(q)
	if not r then
		return ""
	end
	local extra = dbS(r, "Extra")
	result.free(r)
	return string.lower(extra or "")
end

local function columnKey(tableName, columnName)
	local q = string.format("SHOW COLUMNS FROM `%s` LIKE %s", tableName, db.escapeString(columnName))
	local r = db.storeQuery(q)
	if not r then
		return ""
	end
	local key = dbS(r, "Key")
	result.free(r)
	return string.upper(key or "")
end

local function ensureAutoIncrement(tableName)
	if not tableHasColumn(tableName, "id") then
		return
	end
	if columnExtra(tableName, "id"):find("auto_increment", 1, true) ~= nil then
		return
	end
	local keyType = columnKey(tableName, "id")
	if keyType == "" then
		-- legacy schema may have id without key; keep fallback insert strategy without logging SQL errors
		return
	end
	db.query(string.format("ALTER TABLE `%s` MODIFY COLUMN `id` INT UNSIGNED NOT NULL AUTO_INCREMENT", tableName))
end

local function nextIdForTable(tableName)
	local r = db.storeQuery(string.format("SELECT COALESCE(MAX(`id`), 0) + 1 AS `nid` FROM `%s`", tableName))
	if not r then
		return 1
	end
	local id = dbN(r, "nid")
	result.free(r)
	return id > 0 and id or 1
end

local function insertWithFallback(tableName, columnsSql, valuesSql)
	local q = string.format("INSERT INTO `%s` (%s) VALUES (%s)", tableName, columnsSql, valuesSql)

	if idRequiresExplicitInsert(tableName) then
		local fallbackId = nextIdForTable(tableName)
		local q2 = string.format("INSERT INTO `%s` (`id`,%s) VALUES (%d,%s)", tableName, columnsSql, fallbackId, valuesSql)
		if db.query(q2) then
			return true
		end

		-- Last-resort fallback for inconsistent schemas.
		return db.query(q)
	end

	if db.query(q) then
		return true
	end

	-- Safety fallback if cache is stale.
	if tableHasColumn(tableName, "id") then
		local fallbackId = nextIdForTable(tableName)
		local q2 = string.format("INSERT INTO `%s` (`id`,%s) VALUES (%d,%s)", tableName, columnsSql, fallbackId, valuesSql)
		if db.query(q2) then
			_idInsertModeCache[tostring(tableName) .. ".__id_explicit"] = true
			return true
		end
	end

	return false
end

function MarketSystem.ensureSchema()
	if MarketSystem._schemaReady then
		return
	end

	_hasColumnCache = {}
	_idInsertModeCache = {}

	db.query([[
		CREATE TABLE IF NOT EXISTS `market_stalls` (
			`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
			`owner_guid` INT NOT NULL,
			`owner_name` VARCHAR(255) NOT NULL,
			`x` INT NOT NULL DEFAULT 0,
			`y` INT NOT NULL DEFAULT 0,
			`z` INT NOT NULL DEFAULT 7,
			`look_json` TEXT NULL,
			`description` VARCHAR(255) NOT NULL DEFAULT '',
			`expires_at` BIGINT NOT NULL DEFAULT 0,
			`active` TINYINT(1) NOT NULL DEFAULT 1,
			`creature_id` INT NOT NULL DEFAULT 0,
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `market_offers` (
			`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
			`owner_guid` INT NOT NULL,
			`stall_id` INT NOT NULL DEFAULT 0,
			`item_id` INT NOT NULL,
			`client_id` INT NOT NULL DEFAULT 0,
			`item_name` VARCHAR(255) NOT NULL,
			`count` INT NOT NULL DEFAULT 1,
			`price` BIGINT UNSIGNED NOT NULL DEFAULT 0,
			`item_data` LONGTEXT NULL,
			`active` TINYINT(1) NOT NULL DEFAULT 1,
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `market_pending_payouts` (
			`owner_guid` INT NOT NULL,
			`gold` BIGINT UNSIGNED NOT NULL DEFAULT 0,
			PRIMARY KEY (`owner_guid`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `market_pending_returns` (
			`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
			`owner_guid` INT NOT NULL,
			`item_data` LONGTEXT NULL,
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `market_profiles` (
			`owner_guid` INT NOT NULL,
			`description` VARCHAR(255) NOT NULL DEFAULT '',
			PRIMARY KEY (`owner_guid`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `market_history` (
			`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
			`stall_id` INT NOT NULL DEFAULT 0,
			`seller_guid` INT NOT NULL,
			`seller_name` VARCHAR(255) NOT NULL DEFAULT '',
			`buyer_name` VARCHAR(255) NOT NULL DEFAULT '',
			`item_name` VARCHAR(255) NOT NULL,
			`count` INT NOT NULL DEFAULT 1,
			`price_each` BIGINT UNSIGNED NOT NULL DEFAULT 0,
			`total_price` BIGINT UNSIGNED NOT NULL DEFAULT 0,
			`created_at` BIGINT NOT NULL DEFAULT 0,
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8
	]])

	addColumnIfMissing("market_stalls", "owner_guid", "`owner_guid` INT NOT NULL DEFAULT 0")
	addColumnIfMissing("market_stalls", "owner_name", "`owner_name` VARCHAR(255) NOT NULL DEFAULT ''")
	addColumnIfMissing("market_stalls", "description", "`description` VARCHAR(255) NOT NULL DEFAULT ''")
	addColumnIfMissing("market_offers", "owner_guid", "`owner_guid` INT NOT NULL DEFAULT 0")
	addColumnIfMissing("market_offers", "stall_id", "`stall_id` INT NOT NULL DEFAULT 0")
	addColumnIfMissing("market_offers", "item_name", "`item_name` VARCHAR(255) NOT NULL DEFAULT ''")
	addColumnIfMissing("market_offers", "item_data", "`item_data` LONGTEXT NULL")
	addColumnIfMissing("market_offers", "active", "`active` TINYINT(1) NOT NULL DEFAULT 1")
	addColumnIfMissing("market_history", "stall_id", "`stall_id` INT NOT NULL DEFAULT 0")
	addColumnIfMissing("market_history", "seller_guid", "`seller_guid` INT NOT NULL DEFAULT 0")
	addColumnIfMissing("market_history", "seller_name", "`seller_name` VARCHAR(255) NOT NULL DEFAULT ''")
	addColumnIfMissing("market_history", "buyer_name", "`buyer_name` VARCHAR(255) NOT NULL DEFAULT ''")
	addColumnIfMissing("market_history", "item_name", "`item_name` VARCHAR(255) NOT NULL DEFAULT ''")
	addColumnIfMissing("market_history", "count", "`count` INT NOT NULL DEFAULT 1")
	addColumnIfMissing("market_history", "price_each", "`price_each` BIGINT UNSIGNED NOT NULL DEFAULT 0")
	addColumnIfMissing("market_history", "total_price", "`total_price` BIGINT UNSIGNED NOT NULL DEFAULT 0")
	addColumnIfMissing("market_history", "created_at", "`created_at` BIGINT NOT NULL DEFAULT 0")

	ensureAutoIncrement("market_stalls")
	ensureAutoIncrement("market_offers")
	ensureAutoIncrement("market_pending_returns")
	ensureAutoIncrement("market_history")

	MarketSystem._schemaReady = true
end

local function decodeJson(raw)
	if type(raw) ~= "string" or raw == "" then
		return nil
	end
	local ok, data = pcall(function()
		return json.decode(raw)
	end)
	if ok and type(data) == "table" then
		return data
	end
	return nil
end

local function encodeJson(data)
	local ok, encoded = pcall(function()
		return json.encode(data)
	end)
	if ok then
		return encoded
	end
	return "{}"
end

local function ticketExpire(player)
	local v = toNum(player:getStorageValue(MarketSystem.TICKET_STORAGE), -1)
	if v < 0 then
		return 0
	end
	return v
end

local function ticketRemaining(player)
	return math.max(0, ticketExpire(player) - os.time())
end

local function getProfileDescription(ownerGuid)
	local r = db.storeQuery("SELECT `description` FROM `market_profiles` WHERE `owner_guid` = " .. ownerGuid .. " LIMIT 1")
	if not r then
		return ""
	end
	local value = trim(dbS(r, "description"))
	result.free(r)
	return value
end

local function setProfileDescription(ownerGuid, description)
	description = trim(description):sub(1, MarketSystem.DESCRIPTION_MAXLEN)
	db.query(string.format(
		"INSERT INTO `market_profiles` (`owner_guid`,`description`) VALUES (%d,%s) ON DUPLICATE KEY UPDATE `description`=VALUES(`description`)",
		ownerGuid,
		db.escapeString(description)
	))
end

local function activeStallForOwner(ownerGuid)
	local r = db.storeQuery("SELECT `id`,`owner_guid`,`owner_name`,`x`,`y`,`z`,`look_json`,`description`,`expires_at`,`creature_id` FROM `market_stalls` WHERE `owner_guid` = " .. ownerGuid .. " AND `active` = 1 ORDER BY `id` DESC LIMIT 1")
	if not r then
		return nil
	end
	local row = {
		id = dbN(r, "id"),
		ownerGuid = dbN(r, "owner_guid"),
		ownerName = dbS(r, "owner_name"),
		x = dbN(r, "x"),
		y = dbN(r, "y"),
		z = dbN(r, "z"),
		look = dbS(r, "look_json"),
		description = dbS(r, "description"),
		expiresAt = dbN(r, "expires_at"),
		creatureId = dbN(r, "creature_id")
	}
	result.free(r)
	return row
end

local function activeStallForAccount(accountId, excludeOwnerGuid)
	accountId = math.floor(toNum(accountId, 0))
	excludeOwnerGuid = math.floor(toNum(excludeOwnerGuid, 0))
	if accountId <= 0 then
		return nil
	end

	local where = string.format("p.`account_id` = %d AND ms.`active` = 1 AND ms.`expires_at` > %d", accountId, os.time())
	if excludeOwnerGuid > 0 then
		where = where .. " AND ms.`owner_guid` <> " .. excludeOwnerGuid
	end

	local q = "SELECT ms.`id`, ms.`owner_guid`, ms.`owner_name`, ms.`x`, ms.`y`, ms.`z`, ms.`look_json`, ms.`description`, ms.`expires_at`, ms.`creature_id` " ..
		"FROM `market_stalls` ms JOIN `players` p ON p.`id` = ms.`owner_guid` " ..
		"WHERE " .. where .. " ORDER BY ms.`id` DESC LIMIT 1"
	local r = db.storeQuery(q)
	if not r then
		return nil
	end

	local row = {
		id = dbN(r, "id"),
		ownerGuid = dbN(r, "owner_guid"),
		ownerName = dbS(r, "owner_name"),
		x = dbN(r, "x"),
		y = dbN(r, "y"),
		z = dbN(r, "z"),
		look = dbS(r, "look_json"),
		description = dbS(r, "description"),
		expiresAt = dbN(r, "expires_at"),
		creatureId = dbN(r, "creature_id")
	}
	result.free(r)
	return row
end

local function getStallById(stallId)
	local r = db.storeQuery("SELECT `id`,`owner_guid`,`owner_name`,`x`,`y`,`z`,`look_json`,`description`,`expires_at`,`active`,`creature_id` FROM `market_stalls` WHERE `id` = " .. stallId .. " LIMIT 1")
	if not r then
		return nil
	end
	local row = {
		id = dbN(r, "id"),
		ownerGuid = dbN(r, "owner_guid"),
		ownerName = dbS(r, "owner_name"),
		x = dbN(r, "x"),
		y = dbN(r, "y"),
		z = dbN(r, "z"),
		look = dbS(r, "look_json"),
		description = dbS(r, "description"),
		expiresAt = dbN(r, "expires_at"),
		active = dbN(r, "active") == 1,
		creatureId = dbN(r, "creature_id")
	}
	result.free(r)
	return row
end

local function serializeItem(item, forcedCount)
	if not item or not item:isItem() then
		return nil
	end
	local itemId = toNum(item:getId(), 0)
	if itemId <= 0 then
		return nil
	end
	local it = ItemType(itemId)
	local data = {
		id = itemId,
		clientId = it and toNum(it:getClientId(), 0) or 0,
		name = (it and it:getName()) or item:getName(),
		count = math.max(1, math.floor(toNum(forcedCount, toNum(item:getCount(), 1)))),
		subType = toNum(item:getSubType(), 1),
		isContainer = item:isContainer() and true or false,
		children = {}
	}

	if item.buildTooltip then
		local ok, tooltip = pcall(function()
			return item:buildTooltip()
		end)
		if ok and type(tooltip) == "table" then
			tooltip.id = itemId
			tooltip.clientId = toNum(tooltip.clientId, data.clientId)
			tooltip.count = data.count
			tooltip.itemName = tostring(tooltip.itemName or data.name or ("item " .. tostring(itemId)))
			data.tooltip = tooltip
		end
	end

	if item:isContainer() then
		local children = item:getItems() or {}
		for _, child in ipairs(children) do
			local childData = serializeItem(child)
			if childData then
				data.children[#data.children + 1] = childData
			end
		end
	end
	return data
end

local function createFromData(parent, data)
	if type(data) ~= "table" then
		return nil
	end
	local itemId = math.floor(toNum(data.id, 0))
	if itemId <= 0 then
		return nil
	end
	local it = ItemType(itemId)
	local count = math.max(1, math.floor(toNum(data.count, 1)))
	local subType = math.max(0, math.floor(toNum(data.subType, count)))
	local param = (it and it:isStackable()) and count or (subType > 0 and subType or 1)
	local created = nil
	if parent and parent.isContainer and parent:isContainer() then
		created = parent:addItem(itemId, param)
	elseif parent and parent.isPlayer and parent:isPlayer() then
		created = parent:addItem(itemId, param, false)
	end
	if not created then
		return nil
	end
	if created:isContainer() and type(data.children) == "table" then
		for _, child in ipairs(data.children) do
			createFromData(created, child)
		end
	end
	return created
end

local function isBackpackItem(it)
	if not it then
		return false
	end
	local p = it:getPosition()
	if not p or p.x ~= CONTAINER_POS then
		return false
	end
	if p.z == 0 and p.y <= CONST_SLOT_AMMO then
		return false
	end
	return true
end

local function getContainerItemByIndex(container, index)
	if not container then
		return nil
	end
	index = tonumber(index)
	if not index then
		return nil
	end
	local it = container:getItem(index)
	if it then
		return it
	end
	if index >= 0 then
		return container:getItem(index + 1)
	end
	return nil
end

local function findByIdInContainer(container, wantedId, depth, wantedSubType)
	if not container or depth <= 0 then
		return nil
	end
	local size = container:getSize() or 0
	for i = 0, size - 1 do
		local ci = container:getItem(i)
		if ci then
			if ci:getId() == wantedId then
				if not wantedSubType or wantedSubType <= 0 then
					return ci
				end
				local ciSubType = tonumber(ci:getSubType()) or tonumber(ci:getCount()) or 0
				if ciSubType == wantedSubType then
					return ci
				end
			end
			if ci:isContainer() then
				local nested = findByIdInContainer(ci, wantedId, depth - 1, wantedSubType)
				if nested then
					return nested
				end
			end
		end
	end
	return nil
end

local function findByIdFlexible(container, wantedId, depth, wantedSubType)
	local item = findByIdInContainer(container, wantedId, depth, wantedSubType)
	if item then
		return item
	end
	if wantedSubType and wantedSubType > 0 then
		return findByIdInContainer(container, wantedId, depth, nil)
	end
	return nil
end

local function parseTargetItem(player, targetData)
	if type(targetData) ~= "table" then
		return nil
	end
	local x = tonumber(targetData.x)
	local y = tonumber(targetData.y)
	local z = tonumber(targetData.z)
	local stackpos = tonumber(targetData.stackpos) or 0
	local fallbackId = tonumber(targetData.id) or 0
	local fallbackSubType = tonumber(targetData.subType) or 0

	local item
	local inventorySlotMax = tonumber(CONST_SLOT_AMMO) or 10
	if x == CONTAINER_POS and y and z and y >= 1 and y <= inventorySlotMax and z == 0 then
		item = player:getSlotItem(y)
		if item then
			return item
		end
	end

	if x == CONTAINER_POS and y and z and y >= 64 then
		local container = player:getContainerById(y - 64)
		if container then
			item = getContainerItemByIndex(container, z)
			if item then
				return item
			end
			if stackpos >= 0 and stackpos ~= z then
				item = getContainerItemByIndex(container, stackpos)
				if item then
					return item
				end
			end
			if fallbackId > 0 then
				item = findByIdFlexible(container, fallbackId, MAX_CONTAINER_RECURSION, fallbackSubType)
				if item then
					return item
				end
			end
		end
	end

	if fallbackId > 0 then
		for containerId = 0, MAX_CONTAINER_SCAN_ID do
			local container = player:getContainerById(containerId)
			if container then
				item = findByIdFlexible(container, fallbackId, MAX_CONTAINER_RECURSION, fallbackSubType)
				if item then
					return item
				end
			end
		end
	end

	-- Last-resort fallback: resolve by slot index across opened containers.
	-- Some clients/widgets may send non-container coordinates while dragging.
	if z and z >= 0 then
		for containerId = 0, MAX_CONTAINER_SCAN_ID do
			local container = player:getContainerById(containerId)
			if container then
				item = getContainerItemByIndex(container, z)
				if item then
					return item
				end
			end
		end
	end

	return nil
end

local function draftOffers(ownerGuid)
	local q = "SELECT `id`,`item_id`,`client_id`,`item_name`,`count`,`price`,`item_data` FROM `market_offers` WHERE `owner_guid` = " .. ownerGuid .. " AND `stall_id` = 0 AND `active` = 1 ORDER BY `id` ASC"
	local r = db.storeQuery(q)
	return parseRows(r, function(row)
		local itemData = decodeJson(dbS(row, "item_data")) or {}
		return {
			id = dbN(row, "id"),
			itemId = dbN(row, "item_id"),
			clientId = dbN(row, "client_id"),
			name = dbS(row, "item_name"),
			count = dbN(row, "count"),
			price = dbN(row, "price"),
			itemData = itemData,
			isContainer = itemData.isContainer == true
		}
	end)
end

local function offersForStall(stallId)
	local q = "SELECT `id`,`owner_guid`,`item_id`,`client_id`,`item_name`,`count`,`price`,`item_data` FROM `market_offers` WHERE `stall_id` = " .. stallId .. " AND `active` = 1 ORDER BY `id` ASC"
	local r = db.storeQuery(q)
	return parseRows(r, function(row)
		local itemData = decodeJson(dbS(row, "item_data")) or {}
		return {
			id = dbN(row, "id"),
			ownerGuid = dbN(row, "owner_guid"),
			itemId = dbN(row, "item_id"),
			clientId = dbN(row, "client_id"),
			name = dbS(row, "item_name"),
			count = dbN(row, "count"),
			price = dbN(row, "price"),
			itemData = itemData,
			isContainer = itemData.isContainer == true
		}
	end)
end

local function historyForSeller(ownerGuid)
	local whereCol = nil
	if hasColumnCached("market_history", "seller_guid") then
		whereCol = "`seller_guid`"
	elseif hasColumnCached("market_history", "player_id") then
		whereCol = "`player_id`"
	else
		return {}
	end

	local buyerExpr = hasColumnCached("market_history", "buyer_name") and "`buyer_name`" or "''"
	local itemExpr = hasColumnCached("market_history", "item_name") and "`item_name`" or "''"
	local countExpr = hasColumnCached("market_history", "count") and "`count`"
		or (hasColumnCached("market_history", "amount") and "`amount`" or "1")
	local totalExpr = hasColumnCached("market_history", "total_price") and "`total_price`"
		or (hasColumnCached("market_history", "price") and "`price`" or "0")
	local createdExpr = hasColumnCached("market_history", "created_at") and "`created_at`"
		or (hasColumnCached("market_history", "inserted") and "`inserted`" or "0")
	local idExpr = hasColumnCached("market_history", "id") and "`id`" or "0"

	local q = string.format(
		"SELECT %s AS `id`, %s AS `buyer_name`, %s AS `item_name`, %s AS `count`, %s AS `total_price`, %s AS `created_at` FROM `market_history` WHERE %s = %d ORDER BY `id` DESC LIMIT 300",
		idExpr, buyerExpr, itemExpr, countExpr, totalExpr, createdExpr, whereCol, ownerGuid
	)
	local r = db.storeQuery(q)
	return parseRows(r, function(row)
		return {
			id = dbN(row, "id"),
			buyerName = dbS(row, "buyer_name"),
			itemName = dbS(row, "item_name"),
			count = dbN(row, "count"),
			totalPrice = dbN(row, "total_price"),
			createdAt = dbN(row, "created_at")
		}
	end)
end

function MarketSystem.sendSnapshot(player)
	local ownStall = activeStallForOwner(player:getGuid())
	local creatureIds = {}
	for _, cid in pairs(MarketSystem.byStallCreature) do
		if Creature(cid) then
			creatureIds[#creatureIds + 1] = cid
		end
	end
	sendPayload(player, {
		action = "snapshot",
		data = {
			ticketExpireAt = ticketExpire(player),
			ticketRemaining = ticketRemaining(player),
			ownActiveStallId = ownStall and ownStall.id or 0,
			ownDescription = getProfileDescription(player:getGuid()),
			draftOffers = draftOffers(player:getGuid()),
			stallCreatureIds = creatureIds
		}
	})
end

function MarketSystem.sendStallIndex(player)
	local creatureIds = {}
	for _, cid in pairs(MarketSystem.byStallCreature) do
		if Creature(cid) then
			creatureIds[#creatureIds + 1] = cid
		end
	end
	sendPayload(player, {action = "stallIndex", data = {creatureIds = creatureIds}})
end

function MarketSystem.sendHistory(player)
	sendPayload(player, {action = "history", data = {entries = historyForSeller(player:getGuid())}})
end

function MarketSystem.openOwn(player)
	sendPayload(player, {
		action = "open",
		data = {
			mode = "own",
			title = player:getName() .. "'s Shop",
			ticketRemaining = ticketRemaining(player)
		}
	})
	MarketSystem.sendSnapshot(player)
	MarketSystem.sendHistory(player)
end

function MarketSystem.openStall(player, stallId)
	local stall = getStallById(math.floor(toNum(stallId, 0)))
	if not stall or not stall.active or stall.expiresAt <= os.time() then
		sendResult(player, false, "Shop is no longer active.")
		return
	end
	local canUse, reason = canPlayerUseStall(player, stall)
	if not canUse then
		sendResult(player, false, reason or "You cannot access this shop.")
		return
	end
	sendPayload(player, {
		action = "open",
		data = {
			mode = "browse",
			title = tostring(stall.ownerName or "Unknown") .. "'s Shop",
			stallId = stall.id
		}
	})
	sendPayload(player, {action = "stall", data = {stall = stall, offers = offersForStall(stall.id)}})
end

function MarketSystem.openByCreature(player, creatureId)
	local cid = math.floor(toNum(creatureId, 0))
	local stallId = MarketSystem.byCreatureStall[cid]
	if not stallId then
		local r = db.storeQuery("SELECT `id` FROM `market_stalls` WHERE `creature_id` = " .. cid .. " AND `active` = 1 AND `expires_at` > " .. os.time() .. " LIMIT 1")
		if r then
			stallId = dbN(r, "id")
			result.free(r)
		end
	end
	if not stallId or stallId <= 0 then
		sendResult(player, false, "This shop is unavailable.")
		return
	end
	MarketSystem.openStall(player, stallId)
end

function MarketSystem.addDraftFromTarget(player, targetData, amount, price)
	local active = activeStallForOwner(player:getGuid())
	if active then
		sendResult(player, false, "Close active shop before editing offers.")
		return
	end
	local drafts = draftOffers(player:getGuid())
	if #drafts >= MarketSystem.MAX_OFFERS then
		sendResult(player, false, "Draft offer limit reached.")
		return
	end

	local rawPrice = math.floor(toNum(price, 0))
	if rawPrice > MarketSystem.MAX_PRICE then
		sendResult(player, false, "Invalid price.")
		return
	end
	-- Force explicit confirmation: new drafts start with no price.
	local offerPrice = 0

	local item = parseTargetItem(player, targetData)
	if not item then
		sendResult(player, false, "Drop an item from your backpack.")
		return
	end
	local it = ItemType(item:getId())
	local isStackable = it and it:isStackable() or false
	local wanted = math.floor(toNum(amount, 1))
	if wanted <= 0 then
		wanted = 1
	end
	if not isStackable then
		wanted = 1
	else
		wanted = math.min(wanted, math.max(1, toNum(item:getCount(), 1)))
	end

	local data = serializeItem(item, wanted)
	if not data then
		sendResult(player, false, "Could not serialize item.")
		return
	end
	if not item:remove(wanted) then
		sendResult(player, false, "Could not move item from backpack.")
		return
	end

	local columns = {
		"`owner_guid`","`stall_id`","`item_id`","`client_id`","`item_name`","`count`","`price`","`item_data`","`active`"
	}
	local values = {
		tostring(player:getGuid()),
		"0",
		tostring(data.id),
		tostring(data.clientId or 0),
		db.escapeString(data.name or "item"),
		tostring(wanted),
		tostring(offerPrice),
		db.escapeString(encodeJson(data)),
		"1"
	}

	-- Legacy compatibility for old market_offers schema.
	if hasColumnCached("market_offers", "player_id") then
		columns[#columns + 1] = "`player_id`"
		values[#values + 1] = tostring(player:getGuid())
	end
	if hasColumnCached("market_offers", "sale") then
		columns[#columns + 1] = "`sale`"
		values[#values + 1] = "1"
	end
	if hasColumnCached("market_offers", "itemtype") then
		columns[#columns + 1] = "`itemtype`"
		values[#values + 1] = tostring(data.id)
	end
	if hasColumnCached("market_offers", "amount") then
		columns[#columns + 1] = "`amount`"
		values[#values + 1] = tostring(wanted)
	end
	if hasColumnCached("market_offers", "created") then
		columns[#columns + 1] = "`created`"
		values[#values + 1] = tostring(os.time())
	end
	if hasColumnCached("market_offers", "anonymous") then
		columns[#columns + 1] = "`anonymous`"
		values[#values + 1] = "0"
	end

	local okInsert, inserted = pcall(function()
		return insertWithFallback("market_offers", table.concat(columns, ","), table.concat(values, ","))
	end)
	if not okInsert or not inserted then
		createFromData(player, data)
		sendResult(player, false, "Database error. Item was returned.")
		return
	end

	sendResult(player, true, "Offer added to draft.")
	MarketSystem.sendSnapshot(player)
end

function MarketSystem.removeDraft(player, offerId)
	local id = math.floor(toNum(offerId, 0))
	if id <= 0 then
		sendResult(player, false, "Invalid offer id.")
		return
	end
	local q = "SELECT `item_data`,`count` FROM `market_offers` WHERE `id` = " .. id .. " AND `owner_guid` = " .. player:getGuid() .. " AND `stall_id` = 0 AND `active` = 1 LIMIT 1"
	local r = db.storeQuery(q)
	if not r then
		sendResult(player, false, "Draft offer not found.")
		return
	end
	local data = decodeJson(dbS(r, "item_data"))
	local count = dbN(r, "count")
	result.free(r)
	if not data then
		sendResult(player, false, "Draft data invalid.")
		return
	end
	data.count = count
	if not createFromData(player, data) then
		sendResult(player, false, "No space to return item.")
		return
	end
	db.query("UPDATE `market_offers` SET `active` = 0 WHERE `id` = " .. id .. " LIMIT 1")
	sendResult(player, true, "Draft offer removed.")
	MarketSystem.sendSnapshot(player)
end

function MarketSystem.updateDraft(player, offerId, price)
	local id = math.floor(toNum(offerId, 0))
	if id <= 0 then
		sendResult(player, false, "Invalid offer id.")
		return
	end

	local offerPrice = math.floor(toNum(price, 0))
	if offerPrice <= 0 or offerPrice > MarketSystem.MAX_PRICE then
		sendResult(player, false, "Invalid price.")
		return
	end

	local q = "SELECT `id` FROM `market_offers` WHERE `id` = " .. id .. " AND `owner_guid` = " .. player:getGuid() .. " AND `stall_id` = 0 AND `active` = 1 LIMIT 1"
	local r = db.storeQuery(q)
	if not r then
		sendResult(player, false, "Draft offer not found.")
		return
	end
	result.free(r)

	db.query("UPDATE `market_offers` SET `price` = " .. offerPrice .. " WHERE `id` = " .. id .. " LIMIT 1")
	sendResult(player, true, "Draft price updated.")
	MarketSystem.sendSnapshot(player)
end

local function despawnStall(stallId)
	local cid = MarketSystem.byStallCreature[stallId]
	if cid then
		local cr = Creature(cid)
		if cr then
			cr:remove()
		end
		MarketSystem.byCreatureStall[cid] = nil
		MarketSystem.byStallCreature[stallId] = nil
	end
	MarketSystem.stallDescriptionById[stallId] = nil
	MarketSystem.stallNextSpeechAt[stallId] = nil
	db.query("UPDATE `market_stalls` SET `creature_id` = 0 WHERE `id` = " .. stallId .. " LIMIT 1")
end

local function creditPayoutToBackpackOrBank(player, amount)
	amount = math.max(0, math.floor(toNum(amount, 0)))
	if not player or not player:isPlayer() or amount <= 0 then
		return 0, 0
	end

	local beforeMoney = toNum(player:getMoney(), 0)
	local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
	if backpack and backpack:isContainer() then
		local remaining = amount
		local denominations = {
			{id = 2160, worth = 10000},
			{id = 2152, worth = 100},
			{id = 2148, worth = 1}
		}
		for _, d in ipairs(denominations) do
			local coins = math.floor(remaining / d.worth)
			remaining = remaining % d.worth
			while coins > 0 do
				local stack = math.min(100, coins)
				local added = backpack:addItem(d.id, stack)
				if not added then
					remaining = remaining + (coins * d.worth)
					coins = 0
					break
				end
				coins = coins - stack
			end
		end
	end

	local addedToBackpack = math.max(0, toNum(player:getMoney(), 0) - beforeMoney)
	local sentToBank = math.max(0, amount - addedToBackpack)
	if sentToBank > 0 then
		player:setBankBalance(player:getBankBalance() + sentToBank)
	end
	return addedToBackpack, sentToBank
end

local function pushPendingPayout(ownerGuid, gold)
	gold = math.max(0, math.floor(toNum(gold, 0)))
	if ownerGuid <= 0 or gold <= 0 then
		return
	end

	local onlineOwner = nil
	for _, p in ipairs(Game.getPlayers()) do
		if p:getGuid() == ownerGuid then
			onlineOwner = p
			break
		end
	end

	if onlineOwner then
		local backpackGold, bankGold = creditPayoutToBackpackOrBank(onlineOwner, gold)
		if bankGold > 0 then
			onlineOwner:sendTextMessage(
				MESSAGE_STATUS_CONSOLE_ORANGE,
				string.format("Market payout received: %d gp to backpack, %d gp to bank.", backpackGold, bankGold)
			)
		else
			onlineOwner:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, string.format("Market payout received: %d gp.", backpackGold))
		end
		return
	end

	db.query(string.format(
		"INSERT INTO `market_pending_payouts` (`owner_guid`,`gold`) VALUES (%d,%d) ON DUPLICATE KEY UPDATE `gold`=`gold`+VALUES(`gold`)",
		ownerGuid,
		gold
	))
end

local function pushPendingReturn(ownerGuid, itemData)
	if ownerGuid <= 0 or type(itemData) ~= "table" then
		return
	end
	insertWithFallback("market_pending_returns", "`owner_guid`,`item_data`", string.format("%d,%s", ownerGuid, db.escapeString(encodeJson(itemData))))
end

local function pushHistory(stall, buyerName, itemName, count, priceEach, totalPrice, itemId)
	if not stall then
		return
	end
	local now = os.time()
	local safeCount = math.max(1, math.floor(toNum(count, 1)))
	local safePriceEach = math.max(0, math.floor(toNum(priceEach, 0)))
	local safeTotal = math.max(0, math.floor(toNum(totalPrice, 0)))
	local safeItemId = math.max(0, math.floor(toNum(itemId, 0)))

	local columns = {
		"`stall_id`","`seller_guid`","`seller_name`","`buyer_name`","`item_name`","`count`","`price_each`","`total_price`","`created_at`"
	}
	local values = {
		tostring(stall.id),
		tostring(stall.ownerGuid),
		db.escapeString(stall.ownerName or ""),
		db.escapeString(buyerName or ""),
		db.escapeString(itemName or "item"),
		tostring(safeCount),
		tostring(safePriceEach),
		tostring(safeTotal),
		tostring(now)
	}

	-- Legacy compatibility for old market_history schema.
	if hasColumnCached("market_history", "player_id") then
		columns[#columns + 1] = "`player_id`"
		values[#values + 1] = tostring(stall.ownerGuid)
	end
	if hasColumnCached("market_history", "sale") then
		columns[#columns + 1] = "`sale`"
		values[#values + 1] = "1"
	end
	if hasColumnCached("market_history", "itemtype") then
		columns[#columns + 1] = "`itemtype`"
		values[#values + 1] = tostring(safeItemId)
	end
	if hasColumnCached("market_history", "amount") then
		columns[#columns + 1] = "`amount`"
		values[#values + 1] = tostring(safeCount)
	end
	if hasColumnCached("market_history", "price") then
		columns[#columns + 1] = "`price`"
		values[#values + 1] = tostring(safeTotal)
	end
	if hasColumnCached("market_history", "expires_at") then
		columns[#columns + 1] = "`expires_at`"
		values[#values + 1] = tostring(now)
	end
	if hasColumnCached("market_history", "inserted") then
		columns[#columns + 1] = "`inserted`"
		values[#values + 1] = tostring(now)
	end
	if hasColumnCached("market_history", "state") then
		columns[#columns + 1] = "`state`"
		values[#values + 1] = "0"
	end

	insertWithFallback("market_history", table.concat(columns, ","), table.concat(values, ","))
end

local function closeStall(stallId, ownerGuid)
	local offers = offersForStall(stallId)
	for _, offer in ipairs(offers) do
		if offer.itemData then
			offer.itemData.count = offer.count
			pushPendingReturn(ownerGuid, offer.itemData)
		end
	end
	db.query("UPDATE `market_offers` SET `active` = 0 WHERE `stall_id` = " .. stallId .. " AND `active` = 1")
	db.query("UPDATE `market_stalls` SET `active` = 0, `creature_id` = 0 WHERE `id` = " .. stallId .. " LIMIT 1")
	despawnStall(stallId)
end

local function hasPlayerAround(centerPos, ownerId)
	local specs = Game.getSpectators(centerPos, false, true, 1, 1, 1, 1) or {}
	for _, spectator in ipairs(specs) do
		if spectator and spectator:isPlayer() and spectator:getId() ~= ownerId then
			local sPos = spectator:getPosition()
			if sPos and sPos.z == centerPos.z then
				local dx = math.abs(sPos.x - centerPos.x)
				local dy = math.abs(sPos.y - centerPos.y)
				if dx <= 1 and dy <= 1 and not (dx == 0 and dy == 0) then
					return true
				end
			end
		end
	end
	return false
end

local function hasStallAround(centerPos)
	-- Runtime check: any spawned market stall creature on 8 adjacent tiles.
	local specs = Game.getSpectators(centerPos, false, false, 1, 1, 1, 1) or {}
	for _, spectator in ipairs(specs) do
		if spectator and not spectator:isPlayer() then
			local cid = spectator:getId()
			if cid and MarketSystem.byCreatureStall[cid] then
				local sPos = spectator:getPosition()
				if sPos and sPos.z == centerPos.z then
					local dx = math.abs(sPos.x - centerPos.x)
					local dy = math.abs(sPos.y - centerPos.y)
					if dx <= 1 and dy <= 1 and not (dx == 0 and dy == 0) then
						return true
					end
				end
			end
		end
	end

	-- DB fallback: protects against stale runtime maps / not-yet-indexed stalls.
	local q = string.format(
		"SELECT COUNT(*) AS `c` FROM `market_stalls` WHERE `active` = 1 AND `expires_at` > %d AND `z` = %d AND `x` BETWEEN %d AND %d AND `y` BETWEEN %d AND %d",
		os.time(),
		centerPos.z,
		centerPos.x - 1,
		centerPos.x + 1,
		centerPos.y - 1,
		centerPos.y + 1
	)
	local r = db.storeQuery(q)
	if not r then
		return false
	end
	local count = dbN(r, "c")
	result.free(r)
	return count > 0
end

local function hasDepotZoneAround(centerPos)
	-- Block creating stalls on depot tile and in 2 tiles radius around depot access.
	-- This prevents blocking approach paths to depot use tiles.
	for dx = -2, 2 do
		for dy = -2, 2 do
			local checkPos = Position(centerPos.x + dx, centerPos.y + dy, centerPos.z)
			local tile = Tile(checkPos)
			if tile and tile:hasFlag(TILESTATE_DEPOT) then
				return true
			end
		end
	end
	return false
end

getActiveStallPosition = function(stall)
	if not stall then
		return nil
	end

	local cid = MarketSystem.byStallCreature[stall.id] or toNum(stall.creatureId, 0)
	if cid > 0 then
		local cr = Creature(cid)
		if cr then
			local pos = cr:getPosition()
			if pos then
				return pos
			end
		end
	end

	if stall.x and stall.y and stall.z then
		return Position(stall.x, stall.y, stall.z)
	end
	return nil
end

canPlayerUseStall = function(player, stall)
	if not player or not stall then
		return false, "Shop is unavailable."
	end

	local playerPos = player:getPosition()
	local playerTile = Tile(playerPos)
	if not playerTile or not playerTile:hasFlag(TILESTATE_PROTECTIONZONE) then
		return false, "You must stand in a protection zone to use market stalls."
	end

	local stallPos = getActiveStallPosition(stall)
	if not stallPos then
		return false, "Shop is unavailable."
	end

	if playerPos.z ~= stallPos.z then
		return false, "You must stand next to the market stall."
	end

	local dx = math.abs(playerPos.x - stallPos.x)
	local dy = math.abs(playerPos.y - stallPos.y)
	if dx > 1 or dy > 1 then
		return false, "You must stand next to the market stall."
	end

	return true
end

function MarketSystem.startShop(player)
	local active = activeStallForOwner(player:getGuid())
	if active then
		sendResult(player, false, "You already have an active shop.")
		return
	end
	local otherOnAccount = activeStallForAccount(player:getAccountId(), player:getGuid())
	if otherOnAccount then
		sendResult(player, false, string.format("Character %s already has an active shop on this account.", otherOnAccount.ownerName))
		return
	end
	if ticketRemaining(player) <= 0 then
		sendResult(player, false, "You need an active market ticket.")
		return
	end
	local tile = Tile(player:getPosition())
	if not tile or not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
		sendResult(player, false, "You can start your shop only in a protection zone.")
		return
	end
	local playerPos = player:getPosition()
	if hasPlayerAround(playerPos, player:getId()) then
		sendResult(player, false, "No player can stand on any of the 8 tiles around you when starting a shop.")
		return
	end
	if hasStallAround(playerPos) then
		sendResult(player, false, "No market stall can stand on any of the 8 tiles around you when starting a shop.")
		return
	end
	if hasDepotZoneAround(playerPos) then
		sendResult(player, false, "You cannot start a shop on depot access tiles or in their surrounding 8 tiles.")
		return
	end
	local drafts = draftOffers(player:getGuid())
	if #drafts == 0 then
		sendResult(player, false, "Add at least one offer.")
		return
	end
	for _, offer in ipairs(drafts) do
		if math.floor(toNum(offer.price, 0)) <= 0 then
			sendResult(player, false, "Set Price for all draft offers before starting shop.")
			return
		end
	end

	local description = getProfileDescription(player:getGuid())
	local pos = playerPos
	local look = player:getOutfit()
	local lookJson = encodeJson({
		lookType = toNum(look.lookType, 0),
		lookHead = toNum(look.lookHead, 0),
		lookBody = toNum(look.lookBody, 0),
		lookLegs = toNum(look.lookLegs, 0),
		lookFeet = toNum(look.lookFeet, 0),
		lookAddons = toNum(look.lookAddons, 0),
		lookMount = toNum(look.lookMount, 0),
		lookWings = toNum(look.lookWings, 0),
		lookAura = toNum(look.lookAura, 0),
		lookShader = toNum(look.lookShader, 0)
	})
	local columns = "`owner_guid`,`owner_name`,`x`,`y`,`z`,`look_json`,`description`,`expires_at`,`active`,`creature_id`"
	local values = string.format("%d,%s,%d,%d,%d,%s,%s,%d,1,0", player:getGuid(), db.escapeString(player:getName()), pos.x, pos.y, pos.z, db.escapeString(lookJson), db.escapeString(description), os.time() + MarketSystem.STALL_DURATION)
	if not insertWithFallback("market_stalls", columns, values) then
		sendResult(player, false, "Failed to create shop.")
		return
	end

	local idResult = db.storeQuery("SELECT LAST_INSERT_ID() AS `id`")
	local stallId = 0
	if idResult then
		stallId = dbN(idResult, "id")
		result.free(idResult)
	end
	if stallId <= 0 then
		local fallback = db.storeQuery("SELECT `id` FROM `market_stalls` WHERE `owner_guid` = " .. player:getGuid() .. " AND `active` = 1 ORDER BY `id` DESC LIMIT 1")
		if fallback then
			stallId = dbN(fallback, "id")
			result.free(fallback)
		end
	end
	if stallId <= 0 then
		sendResult(player, false, "Failed to resolve shop id.")
		return
	end

	db.query("UPDATE `market_offers` SET `stall_id` = " .. stallId .. " WHERE `owner_guid` = " .. player:getGuid() .. " AND `stall_id` = 0 AND `active` = 1")
	sendPayload(player, {action = "activated", data = {stallId = stallId, message = "Shop started. Logging out..."}})
end

local function spawnStallRecord(stall, ignoreOwnerOnlineCheck)
	if not stall or stall.id <= 0 then
		return false
	end
	if stall.expiresAt <= os.time() then
		closeStall(stall.id, stall.ownerGuid)
		return false
	end
	if not ignoreOwnerOnlineCheck and Player(stall.ownerName) then
		return false
	end

	local existing = MarketSystem.byStallCreature[stall.id]
	if existing and Creature(existing) then
		MarketSystem.stallDescriptionById[stall.id] = trim(stall.description or "")
		return true
	end

	local monster = Game.createMonster(MarketSystem.STALL_MONSTER, Position(stall.x, stall.y, stall.z), false, true)
	if not monster then
		return false
	end
	local ownerName = trim(stall.ownerName or "")
	if ownerName ~= "" then
		pcall(function()
			monster:rename(ownerName, "a market stall")
		end)
	end
	local look = decodeJson(stall.look) or {}
	if toNum(look.lookType, 0) > 0 then
		monster:setOutfit(look)
	end
	monster:setSkull(SKULL_GREEN)
	local cid = monster:getId()
	MarketSystem.byStallCreature[stall.id] = cid
	MarketSystem.byCreatureStall[cid] = stall.id
	MarketSystem.stallDescriptionById[stall.id] = trim(stall.description or "")
	MarketSystem.stallNextSpeechAt[stall.id] = os.time() + 5
	db.query("UPDATE `market_stalls` SET `creature_id` = " .. cid .. " WHERE `id` = " .. stall.id .. " LIMIT 1")
	return true
end

function MarketSystem.spawnAll()
	for stallId, cid in pairs(MarketSystem.byStallCreature) do
		local creature = Creature(cid)
		if not creature then
			MarketSystem.byStallCreature[stallId] = nil
			MarketSystem.byCreatureStall[cid] = nil
			MarketSystem.stallDescriptionById[stallId] = nil
			MarketSystem.stallNextSpeechAt[stallId] = nil
		end
	end

	local r = db.storeQuery("SELECT `id`,`owner_guid`,`owner_name`,`x`,`y`,`z`,`look_json`,`description`,`expires_at`,`creature_id` FROM `market_stalls` WHERE `active` = 1")
	local rows = parseRows(r, function(row)
		return {
			id = dbN(row, "id"),
			ownerGuid = dbN(row, "owner_guid"),
			ownerName = dbS(row, "owner_name"),
			x = dbN(row, "x"),
			y = dbN(row, "y"),
			z = dbN(row, "z"),
			look = dbS(row, "look_json"),
			description = dbS(row, "description"),
			expiresAt = dbN(row, "expires_at"),
			creatureId = dbN(row, "creature_id")
		}
	end)
	for _, stall in ipairs(rows) do
		spawnStallRecord(stall)
	end
end

function MarketSystem.announceDescriptions()
	local now = os.time()
	for stallId, cid in pairs(MarketSystem.byStallCreature) do
		local desc = trim(MarketSystem.stallDescriptionById[stallId] or "")
		if desc ~= "" and now >= toNum(MarketSystem.stallNextSpeechAt[stallId], 0) then
			local cr = Creature(cid)
			if cr then
				cr:say(desc, TALKTYPE_MONSTER_SAY)
				MarketSystem.stallNextSpeechAt[stallId] = now + 5
			end
		end
	end
end

function MarketSystem.buy(player, stallId, offerId, amount)
	local stallIdNum = math.floor(toNum(stallId, 0))
	local offerIdNum = math.floor(toNum(offerId, 0))
	local qty = math.max(1, math.floor(toNum(amount, 1)))
	if stallIdNum <= 0 or offerIdNum <= 0 then
		sendResult(player, false, "Invalid purchase request.")
		return
	end

	local stall = getStallById(stallIdNum)
	if not stall or not stall.active or stall.expiresAt <= os.time() then
		sendResult(player, false, "Shop expired.")
		return
	end
	if stall.ownerGuid == player:getGuid() then
		sendResult(player, false, "You cannot buy your own offer.")
		return
	end
	local canUse, reason = canPlayerUseStall(player, stall)
	if not canUse then
		sendResult(player, false, reason or "You cannot buy from this shop.")
		return
	end

	local ro = db.storeQuery("SELECT `item_id`,`item_name`,`count`,`price`,`item_data` FROM `market_offers` WHERE `id` = " .. offerIdNum .. " AND `stall_id` = " .. stallIdNum .. " AND `active` = 1 LIMIT 1")
	if not ro then
		sendResult(player, false, "Offer no longer available.")
		return
	end
	local itemId = dbN(ro, "item_id")
	local itemName = dbS(ro, "item_name")
	local available = dbN(ro, "count")
	local priceEach = dbN(ro, "price")
	local data = decodeJson(dbS(ro, "item_data"))
	result.free(ro)
	if priceEach <= 0 then
		sendResult(player, false, "This offer has no valid price.")
		return
	end
	if not data then
		sendResult(player, false, "Offer data invalid.")
		return
	end

	local it = ItemType(itemId)
	local stackable = it and it:isStackable() or false
	local buyCount = stackable and math.min(qty, available) or 1
	if buyCount <= 0 then
		sendResult(player, false, "Invalid amount.")
		return
	end

	local total = buyCount * priceEach
	if not player:removeMoney(total) then
		sendResult(player, false, "Not enough gold in backpack.")
		return
	end
	data.count = buyCount
	if not createFromData(player, data) then
		player:addMoney(total)
		sendResult(player, false, "No space for purchased item.")
		return
	end

	if stackable and available > buyCount then
		db.query("UPDATE `market_offers` SET `count` = `count` - " .. buyCount .. " WHERE `id` = " .. offerIdNum .. " LIMIT 1")
	else
		db.query("UPDATE `market_offers` SET `active` = 0 WHERE `id` = " .. offerIdNum .. " LIMIT 1")
	end

	pushPendingPayout(stall.ownerGuid, total)
	pushHistory(stall, player:getName(), itemName, buyCount, priceEach, total, itemId)

	local remainingResult = db.storeQuery("SELECT COUNT(*) AS `c` FROM `market_offers` WHERE `stall_id` = " .. stallIdNum .. " AND `active` = 1")
	local remaining = 0
	if remainingResult then
		remaining = dbN(remainingResult, "c")
		result.free(remainingResult)
	end
	if remaining <= 0 then
		closeStall(stallIdNum, stall.ownerGuid)
		sendResult(player, true, string.format("Bought %dx %s for %d gp. Shop sold out and closed.", buyCount, itemName, total))
		sendPayload(player, {action = "stall", data = {stall = {}, offers = {}}})
		return
	end

	sendResult(player, true, string.format("Bought %dx %s for %d gp.", buyCount, itemName, total))
	MarketSystem.openStall(player, stallIdNum)
end

function MarketSystem.closeOwn(player)
	local stall = activeStallForOwner(player:getGuid())
	if not stall then
		sendResult(player, false, "No active shop.")
		return
	end
	closeStall(stall.id, stall.ownerGuid)
	sendResult(player, true, "Shop closed. Unsold items will be returned on login.")
	MarketSystem.sendSnapshot(player)
	MarketSystem.sendHistory(player)
end

function MarketSystem.setDescription(player, description)
	local text = trim(description):sub(1, MarketSystem.DESCRIPTION_MAXLEN)
	setProfileDescription(player:getGuid(), text)
	local stall = activeStallForOwner(player:getGuid())
	if stall then
		db.query("UPDATE `market_stalls` SET `description` = " .. db.escapeString(text) .. " WHERE `id` = " .. stall.id .. " LIMIT 1")
		MarketSystem.stallDescriptionById[stall.id] = text
		MarketSystem.stallNextSpeechAt[stall.id] = os.time() + 5
	end
	sendResult(player, true, "Shop description updated.")
	MarketSystem.sendSnapshot(player)
end

function MarketSystem.deliverPending(player)
	local guid = player:getGuid()
	local rp = db.storeQuery("SELECT `gold` FROM `market_pending_payouts` WHERE `owner_guid` = " .. guid .. " LIMIT 1")
	if rp then
		local gold = dbN(rp, "gold")
		result.free(rp)
		if gold > 0 then
			local backpackGold, bankGold = creditPayoutToBackpackOrBank(player, gold)
			if bankGold > 0 then
				player:sendTextMessage(
					MESSAGE_STATUS_CONSOLE_ORANGE,
					string.format("Market payout received: %d gp to backpack, %d gp to bank.", backpackGold, bankGold)
				)
			else
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, string.format("Market payout received: %d gp.", backpackGold))
			end
		end
		db.query("DELETE FROM `market_pending_payouts` WHERE `owner_guid` = " .. guid)
	end

	local rr = db.storeQuery("SELECT `id`,`item_data` FROM `market_pending_returns` WHERE `owner_guid` = " .. guid .. " ORDER BY `id` ASC")
	local rows = parseRows(rr, function(row)
		return {id = dbN(row, "id"), data = decodeJson(dbS(row, "item_data"))}
	end)
	local returned = 0
	for _, row in ipairs(rows) do
		if row.data and createFromData(player, row.data) then
			returned = returned + 1
			db.query("DELETE FROM `market_pending_returns` WHERE `id` = " .. row.id .. " LIMIT 1")
		end
	end
	if returned > 0 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, string.format("Returned %d unsold market item(s).", returned))
	end
end

function MarketSystem.handleOpcode(player, action, data)
	data = type(data) == "table" and data or {}
	if action == "openOwn" then
		MarketSystem.openOwn(player)
	elseif action == "fetch" then
		MarketSystem.sendSnapshot(player)
	elseif action == "history" then
		MarketSystem.sendHistory(player)
	elseif action == "addFromTarget" then
		MarketSystem.addDraftFromTarget(player, data.target or {}, data.amount or 1, data.price or 0)
	elseif action == "removeDraft" then
		MarketSystem.removeDraft(player, data.offerId)
	elseif action == "updateDraft" then
		MarketSystem.updateDraft(player, data.offerId, data.price)
	elseif action == "setDescription" then
		MarketSystem.setDescription(player, data.description or "")
	elseif action == "startShop" then
		MarketSystem.startShop(player)
	elseif action == "closeOwnStall" then
		MarketSystem.closeOwn(player)
	elseif action == "openByCreature" then
		MarketSystem.openByCreature(player, data.creatureId)
	elseif action == "openStall" then
		MarketSystem.openStall(player, data.stallId)
	elseif action == "buy" then
		MarketSystem.buy(player, data.stallId, data.offerId, data.amount or 1)
	elseif action == "stallIndex" then
		MarketSystem.sendStallIndex(player)
	else
		sendResult(player, false, "Unknown market action.")
	end
end

function MarketSystem.onLogin(player)
	local stall = activeStallForOwner(player:getGuid())
	if stall then
		closeStall(stall.id, stall.ownerGuid)
	end
	local playerId = player:getId()
	addEvent(function(cid)
		local p = Player(cid)
		if p then
			MarketSystem.deliverPending(p)
		end
	end, 250, playerId)
	return true
end

function MarketSystem.onLogout(player)
	local stall = activeStallForOwner(player:getGuid())
	if stall then
		local stallId = stall.id
		local tries = 0
		local function trySpawn()
			local refreshed = getStallById(stallId)
			if not refreshed or not refreshed.active then
				return
			end
			if spawnStallRecord(refreshed, true) then
				return
			end
			tries = tries + 1
			if tries < 15 then
				addEvent(trySpawn, 120)
			end
		end
		addEvent(trySpawn, 1)
	end
	return true
end

function MarketSystem.onStartup()
	MarketSystem.spawnAll()
end

function MarketSystem.onThink()
	local now = os.time()
	if now >= toNum(MarketSystem._nextSpawnRefresh, 0) then
		MarketSystem.spawnAll()
		MarketSystem._nextSpawnRefresh = now + 30
	end
	MarketSystem.announceDescriptions()
end

function MarketSystem.activateTicket(player, item)
	local remaining = ticketRemaining(player)
	local aid = toNum(item and item:getActionId() or 0, 0)
	local itemId = toNum(item and item:getId() or 0, 0)
	local isTicketItem = (itemId == MarketSystem.TICKET_ITEM_ID)

	if remaining <= 0 then
		if aid == MarketSystem.TICKET_USED_AID then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "This market ticket has expired. Buy a new one from the store.")
			return true
		end
		if aid ~= MarketSystem.TICKET_AID and not isTicketItem then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "This item cannot activate market access.")
			return true
		end

		player:setStorageValue(MarketSystem.TICKET_STORAGE, os.time() + MarketSystem.TICKET_DURATION)
		remaining = ticketRemaining(player)
		if item then
			item:remove(1)
		end
		player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Market ticket activated for 48 hours.")
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Market ticket is already active.")
	end

	sendPayload(player, {action = "ticket", data = {ticketRemaining = remaining, ticketExpireAt = ticketExpire(player)}})
	return true
end

MarketSystem.ensureSchema()
