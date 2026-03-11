local OPCODE_LANGUAGE = 1
local OPCODE_TASKS = 106
local OPCODE_TASKS_V2 = 110
local OPCODE_EXP_STATS = 111
local OPCODE_BESTIARY = 112
local OPCODE_HEADHUNTER = 115
local OPCODE_MARKET = 116
local OPCODE_FOOD_STATUS = 109
local function logTasks(msg)
	print("[TasksV2] " .. msg)
end

function onExtendedOpcode(player, opcode, buffer)
	if opcode == OPCODE_LANGUAGE then
		-- otclient language
		if buffer == 'en' or buffer == 'pt' then
			-- example, setting player language, because otclient is multi-language...
			-- player:setStorageValue(SOME_STORAGE_ID, SOME_VALUE)
		end
	elseif opcode == OPCODE_TASKS then
		if buffer == "list" then
			local data = { tasks = {} }
			for i, name in ipairs(TaskSystem.monsters) do
				local count = player:getStorageValue(TaskSystem.getStorageKey(i))
				if count < 0 then
					count = 0
				end
				table.insert(data.tasks, { name = name, count = count })
			end
			player:sendExtendedOpcode(OPCODE_TASKS, json.encode(data))
		end
	elseif opcode == OPCODE_TASKS_V2 then
		logTasks("recv from " .. player:getName() .. " len=" .. tostring(#buffer))
		local status, data = pcall(function()
			return json.decode(buffer)
		end)
		if not status or type(data) ~= "table" then
			logTasks("invalid json")
			return true
		end

		local action = data.action
		local payload = data.data
		logTasks("action=" .. tostring(action))
		if action == "fetch" then
			logTasks("sendAll()")
			TaskSystem.sendAll(player)
		elseif action == "start" and type(payload) == "table" then
			local displayTaskId = tonumber(payload.taskId)
			local required = tonumber(payload.kills)
			local taskKind, taskRef = TaskSystem.decodeTaskId(displayTaskId)
			if not taskKind or not taskRef then
				return true
			end
			if taskKind == TaskSystem.taskKinds.normal then
				required = math.max(TaskSystem.config.kills.Min, math.min(TaskSystem.config.kills.Max, required or TaskSystem.config.kills.Min))

				local activeCount = TaskSystem.countActiveTasks(player)
				if activeCount >= TaskSystem.config.maxActive then
					player:sendTextMessage(
						MESSAGE_STATUS_CONSOLE_ORANGE,
						string.format(
							"You can only have %d active tasks. To start this one, abandon one of your active tasks first.",
							TaskSystem.config.maxActive
						)
					)
					return true
				end

				if player:getStorageValue(TaskSystem.getActiveStorageKey(taskRef)) > 0 then
					player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "This task is already active.")
					return true
				end

				TaskSystem.startTask(player, taskRef, required)
			else
				local kindConfig = TaskSystem.getRotatingConfig(taskKind)
				if not kindConfig then
					return true
				end

				local activeCount = TaskSystem.countActiveTasksByKind(player, taskKind)
				if activeCount >= kindConfig.maxActive then
					player:sendTextMessage(
						MESSAGE_STATUS_CONSOLE_ORANGE,
						string.format(
							"You can only have %d active %s task(s).",
							kindConfig.maxActive,
							taskKind
						)
					)
					return true
				end

				TaskSystem.startRotatingTask(player, taskKind, taskRef)
			end
		elseif action == "buy" and type(payload) == "table" then
			local shopId = tonumber(payload.id)
			local amount = tonumber(payload.amount) or 1
			if shopId then
				TaskSystem.buyShopItem(player, shopId, amount)
			end
		elseif action == "cancel" then
			local displayTaskId = tonumber(payload)
			local taskKind, taskRef = TaskSystem.decodeTaskId(displayTaskId)
			if taskKind == TaskSystem.taskKinds.normal and taskRef then
				TaskSystem.cancelTask(player, taskRef)
			elseif (taskKind == TaskSystem.taskKinds.daily or taskKind == TaskSystem.taskKinds.weekly) and taskRef then
				TaskSystem.cancelRotatingTask(player, taskKind, taskRef)
			end
		end
	elseif opcode == OPCODE_EXP_STATS then
		local status, data = pcall(function()
			return json.decode(buffer)
		end)
		if not status or type(data) ~= "table" then
			return true
		end

		local action = data.action
		local payload = data.data
		if action == "fetchClientIds" and type(payload) == "table" and type(payload.ids) == "table" then
			local map = {}
			for _, rawId in ipairs(payload.ids) do
				local serverId = tonumber(rawId)
				if serverId and serverId > 0 then
					local itemType = ItemType(serverId)
					if itemType then
						local clientId = tonumber(itemType:getClientId()) or 0
						if clientId > 0 then
							map[tostring(serverId)] = clientId
						end
					end
				end
			end

			player:sendExtendedOpcode(OPCODE_EXP_STATS, json.encode({action = "clientIds", data = {map = map}}))
		end
	elseif opcode == OPCODE_BESTIARY then
		if not BestiarySystem then
			print("[Bestiary] BestiarySystem is not loaded.")
			return true
		end

		local status, data = pcall(function()
			return json.decode(buffer)
		end)
		if not status or type(data) ~= "table" then
			return true
		end

		local action = data.action
		local payload = data.data
		if action == "fetch" then
			print("[Bestiary] fetch from " .. player:getName())
			BestiarySystem.sendSnapshot(player)
		elseif action == "choose" and type(payload) == "table" then
			print("[Bestiary] choose from " .. player:getName() .. " taskId=" .. tostring(payload.taskId) .. " type=" .. tostring(payload.bonusType))
			BestiarySystem.chooseBonus(player, payload.taskId, payload.bonusType)
		end
	elseif opcode == OPCODE_HEADHUNTER then
		if not HeadhunterSystem then
			print("[Headhunter] HeadhunterSystem is not loaded.")
			return true
		end

		local status, data = pcall(function()
			return json.decode(buffer)
		end)
		if not status or type(data) ~= "table" then
			return true
		end

		local action = data.action
		local payload = data.data
		if action == "fetch" then
			HeadhunterSystem.sendSnapshot(player)
		elseif action == "create" and type(payload) == "table" then
			HeadhunterSystem.createBounty(
				player,
				payload.targetName or payload.target or "",
				payload.reward or 0,
				payload.description or "",
				payload.anonymous == true
			)
		elseif action == "withdraw" and type(payload) == "table" then
			HeadhunterSystem.withdrawBounty(player, payload.id)
		end
	elseif opcode == OPCODE_MARKET then
		if not MarketSystem then
			print("[Market] MarketSystem is not loaded.")
			return true
		end

		local status, data = pcall(function()
			return json.decode(buffer)
		end)
		if not status or type(data) ~= "table" then
			return true
		end

		local action = data.action
		local payload = data.data
		MarketSystem.handleOpcode(player, action, payload)
	elseif opcode == OPCODE_FOOD_STATUS then
		player:sendFoodStatus()
	else
		-- other opcodes can be ignored, and the server will just work fine...
	end
end
