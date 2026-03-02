local firstItems = {


	[0] = {
		2650, -- jacket
		1987, -- bag
		2674, -- apple
		2382, -- club
	},
    [1] = { -- Sorcerer
		2650, -- jacket
		1988, -- backpack
		7099, -- blue spellwand
		
    },
    [2] = { -- Druid
			2650, -- jacket
        1988, -- backpack
		7091, -- blue spellwand
    },
    [3] = { -- Paladin
			2650, -- jacket
        1988, -- backpack
		2389,
		2389,
		2389,
    },
    [4] = { -- Knight
			2650, -- jacket
        1988, -- backpack
		2448, -- club whatever
		2380, -- hand axe
		2384, -- rapier
    }
}

local EXP_BOOST_STORAGE = 78011
local LEGACY_ABSOLUTE_TIME_THRESHOLD = 1000000000

local function formatDuration(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end

local function normalizeRemainingSeconds(rawValue)
	local now = os.time()
	local value = tonumber(rawValue) or -1

	if value < 0 then
		return 0
	end

	if value >= LEGACY_ABSOLUTE_TIME_THRESHOLD then
		local remaining = value - now
		if remaining > 0 then
			return remaining
		end
		return 0
	end

	return value
end


function onLogin(player)
	



	local serverName = configManager.getString(configKeys.SERVER_NAME)
	local loginStr = "Welcome to " .. serverName .. "!"
	if player:getLastLoginSaved() <= 0 then
		loginStr = loginStr .. " Please choose your outfit."
		player:sendOutfitWindow()
		local vocation = player:getVocation():getId()
        local items = firstItems[vocation]
        if items then
            for i = 1, #items do
                player:addItem(items[i], 1)
            end
        end
		
		
	else
		if loginStr ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
		end

		loginStr = string.format("Your last visit in %s: %s.", serverName, os.date("%d %b %Y %X", player:getLastLoginSaved()))
	end
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)

	-- Promotion
	local vocation = player:getVocation()
	local promotion = vocation:getPromotion()
	if player:isPremium() then
		local value = player:getStorageValue(PlayerStorageKeys.promotion)
		if value == 1 then
			player:setVocation(promotion)
		end
	elseif not promotion then
		player:setVocation(vocation:getDemotion())
	end

	-- Ramz: force djinn access storages every login.
	if player:getName():lower() == "ramz" then
		if player:getStorageValue(278) ~= 3 then
			player:setStorageValue(278, 3)
		end
		if player:getStorageValue(288) < 3 then
			player:setStorageValue(288, 3)
		end
	end

	-- Events
	player:registerEvent("PlayerDeath")
	player:registerEvent("DropLoot")
	player:registerEvent("ExtendedOpcode")
	player:registerEvent("GameStore")
	player:registerEvent("Discoveries")
	player:registerEvent("AdvanceSave")
	player:registerEvent("task")

	local expBoostRemaining = normalizeRemainingSeconds(player:getStorageValue(EXP_BOOST_STORAGE))
	if expBoostRemaining > 0 then
		player:setStorageValue(EXP_BOOST_STORAGE, expBoostRemaining)
		local remaining = formatDuration(expBoostRemaining)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Active EXP boost: +30%. Remaining online time: " .. remaining .. ".")
	else
		player:setStorageValue(EXP_BOOST_STORAGE, -1)
	end

	return true
end
