dailyReward = {
	author = "Reddington",
	debug = true,
	testingMode = true
}


dailyLastSS = 0

DAILY_REWARD_SERVERSIDE = 211
STORAGE_DAILY_COOLDOWN = 37197
STORAGE_DAILY_DAYSTORAGE = 37198
STORAGE_DAILY_LASTSS = 37199
STORAGE_DAILY_REWARD = 37200 -- Ranged reserved to 37231 (31 days)

local function sendJSON(player, action, data)
	local msg = NetworkMessage()
	msg:addByte(50)
	msg:addByte(DAILY_REWARD_SERVERSIDE)
	msg:addString(json.encode({action = action, data = data}))
	msg:sendToPlayer(player)
end

function onDailyRewardCallback(player, opcode, buffer)
	local status, json_data = pcall(function() return json.decode(buffer) end)
	if not status then return false end
	local action = json_data['action']
	local data = json_data['data']
	
	if dailyReward.debug then
		print("Opcode "..opcode.." sent with value "..buffer)
	end
	
	if action == "requestDailyReward" then
		player:sendActualRewards()
	elseif action == "claimReward" then
		player:claimDailyReward()
	end
end

function Player.sendMessageBox(self, t, m)
	sendJSON(self, "sendMessage", {title = t, message = m})
end

function Player.sendFadeItem(self, t)
	sendJSON(self, "fadeItem", {item = t})
end

function Player.showDailyRewardWindow(self)
	sendJSON(self, "showWindow", {})
end

function Player.hideDailyRewardWindow(self, time)
	sendJSON(self, "hideWindow", {hidingTime = time})
end

function Player.getLastDayPicked(self)
	return self:getStorageValue(STORAGE_DAILY_DAYSTORAGE)
end

function Player.cleanDailyStorages(self)
	for i = 37200, 37231 do
		local actualDay = i + 1
		self:setStorageValue(i, -1)
	end
	
	self:setStorageValue(STORAGE_DAILY_DAYSTORAGE, 0)
end

function initDailyReward()
	dailyLastSS = os.time()
end

function Player.claimDailyReward(self)
	if not dailyReward.testingMode then
		if (self:getStorageValue(STORAGE_DAILY_COOLDOWN) == dailyLastSS) then
			self:sendMessageBox("Error", "Sorry, you've already picked your daily reward.")
		return true
		end
	end
	
	local day = self:getLastDayPicked()
	if dailyRewardList[day + 1] == nil then
		self:cleanDailyStorages()
		sendJSON(self, "sendRewardList", dailyRewardList)
	end
	
	if (day < #dailyRewardList) then
		local item = dailyRewardList[day + 1].itemId
		local amount = dailyRewardList[day + 1].amount
		self:addItem(item, amount)
		self:sendFadeItem(ItemType(item):getClientId())
		self:hideDailyRewardWindow(2000)
		
		-- Set actual pickup
		self:setStorageValue(STORAGE_DAILY_COOLDOWN, dailyLastSS)
		
		-- Raise actual day
		if day > 0 and day < #dailyRewardList then
			self:setStorageValue(STORAGE_DAILY_DAYSTORAGE, day + 1)
			self:setStorageValue(STORAGE_DAILY_REWARD + (day + 1), 1)
		else
			self:setStorageValue(STORAGE_DAILY_DAYSTORAGE, 1)
			self:setStorageValue(STORAGE_DAILY_REWARD + 1, 1)
		end
	end
	
	self:sendActualRewards()
end

function Player.sendActualRewards(self)
	for i = 1, #dailyRewardList do
		if (self:getStorageValue(STORAGE_DAILY_REWARD + i) == 1) then
			dailyRewardList[i].claimed = true
			dailyRewardList[i].premium = false
		end
	end

	sendJSON(self, "sendRewardList", dailyRewardList)
end

dailyRewardList = {
	[1] = {
		name = "Coat", 
		description = "Special coat that will protect you aganist all bad things!", 
		typeDesc = "Equipment", 
		premium = true, 
		price = 1, 
		itemId = 2651, 
		itemType = ItemType(2651):getClientId(), 
		amount = 1, 
		claimed = false, 
		failed = false
	},
	[2] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[3] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[4] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[5] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[6] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2195, itemType = ItemType(2195):getClientId(), amount = 1, claimed = false, failed = false},
	[7] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[8] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[9] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[10] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[11] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[12] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[13] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[14] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[15] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[16] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[17] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[18] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[19] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[20] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[21] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[22] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[23] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[24] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2544, itemType = ItemType(2544):getClientId(), amount = 10, claimed = false, failed = false},
	[25] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[26] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[27] = {name = "", description = "", typeDesc = "", premium = true, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[28] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[29] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
	[30] = {name = "", description = "", typeDesc = "", premium = false, price = 1, itemId = 2651, itemType = ItemType(2651):getClientId(), amount = 1, claimed = false, failed = false},
}


