local area = createCombatArea({
	{1, 1, 1},
	{1, 3, 1},
	{1, 1, 1}
})

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_EXPLOSIONAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_BURSTARROW)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setArea(area)

local function isMageVocation(vocationId)
	return vocationId == 1 or vocationId == 2 or vocationId == 5 or vocationId == 6
end

function onGetFormulaValues(player, level, magicLevel)
	local minBase, maxBase = 15, 45
	local formulaDivisor = 100
	local mlvFactor = 3

	if isMageVocation(player:getVocation():getId()) then
		mlvFactor = 4
	end

	local formula = (mlvFactor * magicLevel) + (2 * level)
	local min = (formula * minBase) / formulaDivisor
	local max = (formula * maxBase) / formulaDivisor
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onUseWeapon(player, variant)
	if player:getSkull() == SKULL_BLACK then
		return false
	end

	return combat:execute(player, variant)
end
