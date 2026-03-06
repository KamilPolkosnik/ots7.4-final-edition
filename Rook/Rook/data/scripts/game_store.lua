local DONATION_URL = "https://website.com/donate.php"

local CODE_GAMESTORE = 102
local GAME_STORE = nil

local LoginEvent = CreatureEvent("GameStoreLogin")
local PREMIUM_SCROLL_ACTION_15 = 60015
local PREMIUM_SCROLL_ACTION_60 = 60060
local PREMIUM_SCROLL_ACTION_120 = 60120

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
			item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Premium account for " .. days .. " days.")
		end

		return true
	end
end

function LoginEvent.onLogin(player)
	player:registerEvent("GameStoreExtended")
	return true
end

function gameStoreInitialize()
	GAME_STORE = {
		categories = {},
		offers = {}
	}

	addCategory("Premium", "Premium account scrolls.", "item", 5546)
	addItem(
		"Premium",
		"7 days premium account scroll",
		"Premium account for 7 days.",
		5545,
		1,
		150,
		premiumScrollStoreCallback(7)
	)
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
	

	addCategory("Mounts", "Here you can find a fine selection of unique mounts.", "mount", 397)
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

	addCategory("Items", "Utility items and account extras.", "item", 7962)
	addItem("Items", "Multitool", "Useful tool for adventuring.", 7962, 1, 100)
	addItem("Items", "Ring of Light", "A handy source of light.", 7963, 1, 2)

	addCategory("Training", "Exercise weapons for offline training.", "item", 6876)
	addItem("Training", "Exercise Wand", "Training weapon.", 6876, 1, 50)
	addItem("Training", "Exercise Rod", "Training weapon.", 6877, 1, 50)
	addItem("Training", "Exercise Bow", "Training weapon.", 6878, 1, 50)
	addItem("Training", "Exercise Axe", "Training weapon.", 6879, 1, 50)
	addItem("Training", "Exercise Sword", "Training weapon.", 6880, 1, 50)
	addItem("Training", "Exercise Club", "Training weapon.", 6881, 1, 50)

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

			local status = callback(player, offers[i])
			if status ~= true then
				return errorMsg(player, status)
			end

			local aid = player:getAccountId()
			local escapeTitle = db.escapeString(offers[i].title)
			local escapePrice = db.escapeString(offers[i].price)
			local escapeCount = offers[i].count and db.escapeString(offers[i].count) or 0

			db.query("UPDATE `accounts` set `premium_points` = `premium_points` - " .. offers[i].price .. " WHERE `id` = " .. aid)
			db.asyncQuery(
				"INSERT INTO `shop_history` VALUES (NULL, '" ..
					aid .. "', '" .. player:getGuid() .. "', NOW(), " .. escapeTitle .. ", " .. escapePrice .. ", " .. escapeCount .. ", NULL)"
			)
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

			local targetPlayer = Player(offer.target)
			if not targetPlayer then
				return errorMsg(player, "Target player not found!")
			end

			local status = callback(targetPlayer, offers[i])
			if status ~= true then
				return errorMsg(player, status)
			end

			local aid = player:getAccountId()
			local escapeTitle = db.escapeString(offers[i].title)
			local escapePrice = db.escapeString(offers[i].price)
			local escapeCount = offers[i].count and db.escapeString(offers[i].count) or 0
			local escapeTarget = db.escapeString(targetPlayer:getName())
			db.query("UPDATE `accounts` set `premium_points` = `premium_points` - " .. offers[i].price .. " WHERE `id` = " .. aid)
			db.asyncQuery(
				"INSERT INTO `shop_history` VALUES (NULL, '" ..
					aid .. "', '" .. player:getGuid() .. "', NOW(), " .. escapeTitle .. ", " .. escapePrice .. ", " .. escapeCount .. ", " .. escapeTarget .. ")"
			)
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
