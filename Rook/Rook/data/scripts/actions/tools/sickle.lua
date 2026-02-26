local sickle = Action()

function sickle.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target then
		return false
	end

	local counter = player:getStorageValue(2405)
	if counter < 0 then
		counter = 0
	end

	if target.itemid == 2761 then
		local exp = math.random(1, 150)
		if player:getCondition(CONDITION_DRUNK) then
			player:addExperience(exp * 2, true)
		end
		player:addExperience(exp, true)
		target:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

		local chance = math.random(1, 100)
		if chance <= 1 then
			local roses = {2744, 2745, 2746}
			local rose = roses[math.random(1, 3)]
			local expReward = math.random(1, 1000)
			player:addExperience(expReward, true)
			player:addItem(rose, 1)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You found a colored rose!")
		end

		target:remove()
		return true
	end

	if target.itemid == 2785 then
		local exp = math.random(1, 10)
		player:addExperience(exp, true)
		target:transform(2786)
		player:addItem(2677, math.random(1, 9))
		target:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		target:decay()

		counter = counter + 1
		player:setStorageValue(2405, counter)
		if counter % 10000 == 0 then
			local expReward = math.random(1, 1000)
			player:addExperience(expReward)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, string.format("Congratulations! You've gathered and earned %d experience points.", expReward))
			player:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)
			player:setStorageValue(2405, 0)
		end

		return true
	end

	return false
end

sickle:id(2405)
sickle:id(2418)
sickle:register()
