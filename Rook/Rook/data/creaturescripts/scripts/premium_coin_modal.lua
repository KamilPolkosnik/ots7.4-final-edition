local PREMIUM_COIN_ITEMID = 7965
local STORAGE_PENDING_PREMIUM_COINS = 7965001
local STORAGE_EXPECTED_MODAL_ID = 7965003

function onModalWindow(player, modalWindowId, buttonId, choiceId)
	local expectedModalId = player:getStorageValue(STORAGE_EXPECTED_MODAL_ID)
	if expectedModalId < 1 or modalWindowId ~= expectedModalId then
		return true
	end

	local pending = player:getStorageValue(STORAGE_PENDING_PREMIUM_COINS)
	if pending < 1 then
		player:setStorageValue(STORAGE_EXPECTED_MODAL_ID, -1)
		return true
	end

	player:setStorageValue(STORAGE_PENDING_PREMIUM_COINS, -1)
	player:setStorageValue(STORAGE_EXPECTED_MODAL_ID, -1)

	if buttonId ~= 1 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Titania premium coin conversion cancelled.")
		return true
	end

	local coinsInInventory = player:getItemCount(PREMIUM_COIN_ITEMID)
	if coinsInInventory < pending then
		player:sendCancelMessage("You no longer have that many Titania premium coins.")
		return true
	end

	local removed = player:removeItem(PREMIUM_COIN_ITEMID, pending)
	if not removed then
		removed = doPlayerRemoveItem(player:getId(), PREMIUM_COIN_ITEMID, pending)
	end

	if not removed then
		player:sendCancelMessage("Couldn't consume Titania premium coins. Try again.")
		return true
	end

	db.query(
		"UPDATE `accounts` SET `premium_points` = `premium_points` + " ..
		pending ..
		" WHERE `id` = " ..
		player:getAccountId()
	)

	local noun = pending == 1 and "coin" or "coins"
	player:sendTextMessage(
		MESSAGE_INFO_DESCR,
		string.format("Added %d store point(s) by converting %d Titania premium %s.", pending, pending, noun)
	)
	doSendMagicEffect(player:getPosition(), CONST_ME_GIFT_WRAPS)

	if gameStoreUpdatePoints then
		addEvent(gameStoreUpdatePoints, 100, player:getId())
	end

	return true
end
