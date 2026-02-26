local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_EXPLOSIONHIT)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FIRE)

function onGetFormulaValues(player, level, maglevel)
	local base = 30
	local variation = 10
	
	local formula = 3 * maglevel + (2 * level)
	
	local min = (formula * (base - variation)) / 100
	local max = (formula * (base + variation)) / 100
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")


function onCastSpell(creature, variant, isHotkey)
    local position = variant:getPosition()
    local tile = Tile(position)
    if tile:getTopCreature() then
        return combat:execute(creature, variant)
    end
         
    creature:sendCancelMessage(RETURNVALUE_CANONLYUSETHISRUNEONCREATURES)
    creature:getPosition():sendMagicEffect(CONST_ME_POFF)
    return false
end