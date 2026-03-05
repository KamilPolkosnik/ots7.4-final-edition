local BestiaryHealthChange = CreatureEvent("BestiaryHealthChange")

function BestiaryHealthChange.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
    if not BestiarySystem or not BestiarySystem.applyDamageBonus then
        return primaryDamage, primaryType, secondaryDamage, secondaryType
    end

    return BestiarySystem.applyDamageBonus(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
end

BestiaryHealthChange:type("healthchange")
BestiaryHealthChange:register()
