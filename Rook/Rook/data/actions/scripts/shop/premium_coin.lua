local PREMIUM_COIN_ITEMID = 7965
local PREMIUM_COIN_MODAL_ID_BASE = 796500
local STORAGE_PENDING_PREMIUM_COINS = 7965001
local STORAGE_MODAL_TOKEN = 7965002
local STORAGE_EXPECTED_MODAL_ID = 7965003

local function getCoinCount(item)
	local count = tonumber(item.type) or 1
	if count < 1 then
		return 1
	end
	return count
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	if not player then
		return true
	end

	-- Ensure modal callback event is available even without relog after script changes.
	player:registerEvent("PremiumCoinModal")

	local count = getCoinCount(item)
	local noun = count == 1 and "coin" or "coins"

	player:setStorageValue(STORAGE_PENDING_PREMIUM_COINS, count)

	local token = player:getStorageValue(STORAGE_MODAL_TOKEN)
	if token < 1 then
		token = 1
	else
		token = token + 1
		if token > 200000 then
			token = 1
		end
	end
	player:setStorageValue(STORAGE_MODAL_TOKEN, token)

	local modalId = PREMIUM_COIN_MODAL_ID_BASE + token
	player:setStorageValue(STORAGE_EXPECTED_MODAL_ID, modalId)

	local message = string.format(
		"Are u sure u want to use %d titania %s and add them to your store balance?",
		count,
		noun
	)

	local modal = ModalWindow(modalId, "Titania premium coin", message)
	modal:addButton(1, "Yes")
	modal:addButton(2, "No")
	modal:setDefaultEnterButton(1)
	modal:setDefaultEscapeButton(2)
	modal:sendToPlayer(player)
	return true
end
