local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 18)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, 11)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setFormula(COMBAT_FORMULA_SKILL, 0, 0, 1, 0)


function onUseWeapon(player, variant)
	return combat:execute(player, variant)
end

