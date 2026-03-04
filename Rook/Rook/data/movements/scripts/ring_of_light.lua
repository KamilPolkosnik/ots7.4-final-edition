local RING_OF_LIGHT_SUBID = 796300

local ringLightCondition = Condition(CONDITION_LIGHT, CONDITIONID_COMBAT)
ringLightCondition:setParameter(CONDITION_PARAM_SUBID, RING_OF_LIGHT_SUBID)
ringLightCondition:setParameter(CONDITION_PARAM_LIGHT_LEVEL, 8)
ringLightCondition:setParameter(CONDITION_PARAM_LIGHT_COLOR, 215)
ringLightCondition:setParameter(CONDITION_PARAM_TICKS, 4 * 60 * 60 * 1000)

function onEquip(player, item, slot, isCheck)
	if isCheck then
		return true
	end

	player:addCondition(ringLightCondition)
	return true
end

function onDeEquip(player, item, slot, isCheck)
	if isCheck then
		return true
	end

	player:removeCondition(CONDITION_LIGHT, CONDITIONID_COMBAT, RING_OF_LIGHT_SUBID)
	return true
end
