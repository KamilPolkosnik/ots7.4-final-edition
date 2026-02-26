local OPCODE_LANGUAGE = 1
local OPCODE_TASKS = 106
local OPCODE_TASKS_V2 = 110
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
			if not displayTaskId or displayTaskId < 1 or displayTaskId > #TaskSystem.monsters then
				return true
			end
			local taskId = TaskSystem.toRealTaskId(displayTaskId)
			if not taskId then
				return true
			end
			required = math.max(TaskSystem.config.kills.Min, math.min(TaskSystem.config.kills.Max, required or TaskSystem.config.kills.Min))

			local activeCount = TaskSystem.countActiveTasks(player)
			if activeCount >= TaskSystem.config.maxActive then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You are already doing the maximum number of tasks.")
				return true
			end

			if player:getStorageValue(TaskSystem.getActiveStorageKey(taskId)) > 0 then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "This task is already active.")
				return true
			end

			TaskSystem.startTask(player, taskId, required)
		elseif action == "buy" and type(payload) == "table" then
			local shopId = tonumber(payload.id)
			local amount = tonumber(payload.amount) or 1
			if shopId then
				TaskSystem.buyShopItem(player, shopId, amount)
			end
		elseif action == "cancel" then
			local displayTaskId = tonumber(payload)
			if displayTaskId and displayTaskId >= 1 and displayTaskId <= #TaskSystem.monsters then
				local taskId = TaskSystem.toRealTaskId(displayTaskId)
				if taskId then
					TaskSystem.cancelTask(player, taskId)
				end
			end
		end
	else
		-- other opcodes can be ignored, and the server will just work fine...
	end
end
