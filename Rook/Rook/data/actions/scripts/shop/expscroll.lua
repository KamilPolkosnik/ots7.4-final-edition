local config = {
	time = 1 * 60 * 60, -- 1 hour
	storage = 78011
}

local LEGACY_ABSOLUTE_TIME_THRESHOLD = 1000000000

local function normalizeRemainingSeconds(rawValue)
	local now = os.time()
	local value = tonumber(rawValue) or -1

	if value < 0 then
		return 0
	end

	-- Legacy format: absolute expiration timestamp.
	if value >= LEGACY_ABSOLUTE_TIME_THRESHOLD then
		local remaining = value - now
		if remaining > 0 then
			return remaining
		end
		return 0
	end

	return value
end

local function getRemainingSeconds(cid)
	local remaining = normalizeRemainingSeconds(getCreatureStorage(cid, config.storage))
	if remaining > 0 then
		doCreatureSetStorage(cid, config.storage, remaining)
	else
		doCreatureSetStorage(cid, config.storage, -1)
	end
	return remaining
end

local function consumeScroll(cid, item)
	if doRemoveItem(item.uid, 1) then
		return true
	end

	local removed = doPlayerRemoveItem(cid, item.itemid, 1)
	return removed == true or removed == 1
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	if getRemainingSeconds(cid) > 0 then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "You still have extra experience time left.")
		return true
	end

	if not consumeScroll(cid, item) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Couldn't consume the experience booster. Try again.")
		return true
	end

	doCreatureSetStorage(cid, config.storage, config.time)
	doSendMagicEffect(getPlayerPosition(cid), CONST_ME_MAGIC_RED)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "You have now 30% experience boost. It will last for 1 hour of online time.")

	local player = Player(cid)
	if player and player.sendExtraStatsSnapshot then
		player:sendExtraStatsSnapshot()
	end

	return true
end
