local function parseArgs(param)
	local split = param:splitTrimmed(",")
	if not split[2] then
		return nil
	end

	local mode = "add"
	local first = split[1]:lower()
	if first == "set" or first == "add" then
		mode = first
		table.remove(split, 1)
	end

	if not split[2] then
		return nil
	end

	local points = tonumber(split[1])
	local name = split[2]
	if not points then
		points = tonumber(split[2])
		name = split[1]
	end

	if not points or not name or name == "" then
		return nil
	end

	return mode, points, name
end

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local mode, points, name = parseArgs(param)
	if not mode then
		player:sendCancelMessage("Usage: /taskpoints points, playerName | /taskpoints set, points, playerName")
		return false
	end

	local target = Player(name)
	if not target then
		player:sendCancelMessage("A player with that name is not online.")
		return false
	end

	if not TaskSystem then
		player:sendCancelMessage("TaskSystem is not loaded.")
		return false
	end

	if mode == "set" then
		TaskSystem.setPoints(target, points)
	else
		TaskSystem.addPoints(target, points)
	end
	TaskSystem.sendTaskPoints(target)

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Task points updated for " .. target:getName() .. ".")
	return false
end
