local NAME_CHANGE_PENDING_STORAGE = 78190
local NAME_CHANGE_MIN_LENGTH = 3
local NAME_CHANGE_MAX_LENGTH = 25
local NAME_CHANGE_SCROLL_ITEM_ID = 5747

local function normalizeSpaces(text)
	text = tostring(text or "")
	text = text:gsub("%s+", " ")
	text = text:gsub("^%s+", "")
	text = text:gsub("%s+$", "")
	return text
end

local function formatName(text)
	local words = {}
	for word in text:gmatch("%S+") do
		local first = word:sub(1, 1):upper()
		local rest = word:sub(2):lower()
		words[#words + 1] = first .. rest
	end
	return table.concat(words, " ")
end

local function validateName(text)
	if #text < NAME_CHANGE_MIN_LENGTH then
		return false, "Name is too short."
	end

	if #text > NAME_CHANGE_MAX_LENGTH then
		return false, "Name is too long."
	end

	if text:find("%d") then
		return false, "Numbers are not allowed in character name."
	end

	if text:find("[^A-Za-z ]") then
		return false, "Only letters and spaces are allowed."
	end

	return true, nil
end

local function removeNameChangeScrollFromItem(it)
	if not it then
		return false
	end

	if it:getId() == NAME_CHANGE_SCROLL_ITEM_ID then
		return it:remove(1)
	end

	if not it:isContainer() then
		return false
	end

	for i = 0, it:getSize() - 1 do
		local child = it:getItem(i)
		if removeNameChangeScrollFromItem(child) then
			return true
		end
	end

	return false
end

local function removeNameChangeScroll(player)
	for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
		local slotItem = player:getSlotItem(slot)
		if removeNameChangeScrollFromItem(slotItem) then
			return true
		end
	end

	return false
end

function onTextEdit(player, item, text)
	if not player then
		return true
	end

	local pendingUntil = tonumber(player:getStorageValue(NAME_CHANGE_PENDING_STORAGE)) or -1
	if pendingUntil < os.time() then
		player:setStorageValue(NAME_CHANGE_PENDING_STORAGE, -1)
		return true
	end

	player:setStorageValue(NAME_CHANGE_PENDING_STORAGE, -1)

	local normalized = normalizeSpaces(text)
	if normalized == "" then
		player:sendCancelMessage("Name change cancelled.")
		return true
	end

	local valid, reason = validateName(normalized)
	if not valid then
		player:sendCancelMessage(reason)
		return true
	end

	local newName = formatName(normalized)
	if newName:lower() == player:getName():lower() then
		player:sendCancelMessage("You already have this name.")
		return true
	end

	local escapedName = db.escapeString(newName)
	local query = "SELECT `id` FROM `players` WHERE LOWER(`name`) = LOWER(" .. escapedName .. ") LIMIT 1"
	local resultId = db.storeQuery(query)
	if resultId then
		local existingGuid = tonumber(result.getDataInt(resultId, "id")) or 0
		result.free(resultId)
		if existingGuid ~= player:getGuid() then
			player:sendCancelMessage("A player with this name already exists.")
			return true
		end
	end

	local updateQuery = "UPDATE `players` SET `name` = " .. escapedName .. " WHERE `id` = " .. player:getGuid()
	if not db.query(updateQuery) then
		player:sendCancelMessage("Couldn't change your name now. Try again.")
		return true
	end

	if not removeNameChangeScroll(player) then
		player:sendCancelMessage("Name changed, but scroll could not be consumed. Contact staff.")
		return true
	end

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Name changed to " .. newName .. ". Relog to apply it in-game.")
	return true
end
