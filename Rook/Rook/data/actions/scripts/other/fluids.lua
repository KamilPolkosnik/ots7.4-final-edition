


local drunk = Condition(CONDITION_DRUNK)
drunk:setParameter(CONDITION_PARAM_TICKS, 60000)

local poison = Condition(CONDITION_POISON)
poison:setParameter(CONDITION_PARAM_DELAYED, true)
poison:setParameter(CONDITION_PARAM_MINVALUE, -50)
poison:setParameter(CONDITION_PARAM_MAXVALUE, -120)
poison:setParameter(CONDITION_PARAM_STARTVALUE, -5)
poison:setParameter(CONDITION_PARAM_TICKINTERVAL, 4000)
poison:setParameter(CONDITION_PARAM_FORCEUPDATE, true)




local fluidMessage = {
	[FLUID_BEER] = "Aah...",
	[FLUID_SLIME] = "Urgh!",
	[FLUID_LEMONADE] = "Mmmh.",
	[FLUID_MANA] = "Aaaah...",
	[FLUID_LIFE] = "Aaaah...",
	[FLUID_OIL] = "Urgh!",
	[12] = "Audegouh...",
	[FLUID_URINE] = "Urgh!",
	[FLUID_WINE] = "Aah...",
	[FLUID_MUD] = "Urgh!",
	[FLUID_RUM] = "Aah...",
	[FLUID_MEAD] = "Aaaah..."
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Print target information
    print("Target Item ID:", target.itemid)
    print("Target UID:", target.uid)
    -- Add more print statements as needed for debugging
    
    local targetItemType = ItemType(target.itemid)
    -- Print fluid information
    print("Item Type:", item.type)
    -- Add more print statements as needed for debugging

    if targetItemType and targetItemType:isFluidContainer() then
        if target.type == FLUID_NONE and item.type ~= FLUID_NONE then
            target:transform(target:getId(), item.type)
            item:transform(item:getId(), FLUID_NONE)
            return true
        elseif target.type ~= FLUID_NONE and item.type == FLUID_NONE then
            item:transform(item:getId(), target.type)
            target:transform(target:getId(), FLUID_NONE)
            return true
        end
    end

    if target:isPlayer() then
        if item.type == FLUID_NONE then
            player:sendTextMessage(MESSAGE_STATUS_SMALL, "It is empty.")
        else
            if table.contains({FLUID_BEER, FLUID_WINE, FLUID_MEAD}, item.type) then
                target:addCondition(drunk)
            elseif item.type == FLUID_SLIME then
                target:addCondition(poison)
			elseif item.type == 12 then
				local poisonCombat = Combat()
				poisonCombat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
				poisonCombat:setParameter(COMBAT_PARAM_EFFECT, 9)
				poisonCombat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, 15)
				poisonCombat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
				poisonCombat:setParameter(COMBAT_PARAM_BLOCKSHIELD, true)
				poisonCombat:setParameter(COMBAT_PARAM_AGGRESSIVE, true)

				function onGetPoisonFormulaValues(player, level, magicLevel)
					local min = 3 -- Minimum poison damage
					local max = 3 -- Maximum poison damage
					return -min, -max
				end
				-- Generate random values for poison condition parameters
				local minPoisonValue = math.random(-10, -160)
				local maxPoisonValue = math.random(-10, -350)
				local startPoisonValue = math.random(-3, -12)
				local tickInterval = math.random(2000, 4000)

				-- Print the generated values for debugging
				print("Generated Poison Condition Parameters:")
				print("Min Value:", minPoisonValue)
				print("Max Value:", maxPoisonValue)
				print("Start Value:", startPoisonValue)
				print("Tick Interval:", tickInterval)

				-- Create and configure the poison condition
				local crafterpoison = Condition(CONDITION_POISON)
				crafterpoison:setParameter(CONDITION_PARAM_DELAYED, true)
				crafterpoison:setParameter(CONDITION_PARAM_MINVALUE, minPoisonValue)
				crafterpoison:setParameter(CONDITION_PARAM_MAXVALUE, maxPoisonValue)
				crafterpoison:setParameter(CONDITION_PARAM_STARTVALUE, startPoisonValue)
				crafterpoison:setParameter(CONDITION_PARAM_TICKINTERVAL, tickInterval)
				crafterpoison:setParameter(CONDITION_PARAM_FORCEUPDATE, true)

				-- Add the poison condition to the target player
				target:addCondition(crafterpoison)
			
				poisonCombat:execute(player, Variant(target:getPosition()))	
				-- Add a 60-second CONDITION_INFIGHT condition to the player who poisoned
				if player ~= target then
					if not player:hasFlag(PlayerFlag_CanSkull) then
						print("Current Skull Time:", player:getSkullTime()) -- Debugging for current skull time
						--player:setSkullTime(60) -- Set the skull duration to 60 seconds
						print("Current Skull  Time:", player:getSkullTime()) -- Debugging for current skull time
						print(player:getName(), "has been skull marked due to poisoning.")
						print("Skull Time:", player:getSkullTime()) -- Debugging for updated skull time
						--player:setSkull(SKULL_WHITE) -- Add a white skull
						 -- Run poison combat
                
					end
					-- Add 60 seconds of in-fight time to the player who poisoned
					--player:addInFightTicks()
				end



            elseif item.type == FLUID_MANA then
				local plevel = player:getLevel()
				minmana = plevel/3 + 15
				maxmana = plevel + 100
                target:addMana(math.random(minmana, maxmana))
                toPosition:sendMagicEffect(13)
                -- Print the name of the player who had mana added
                print(target:getName(), "received mana boost.")
            elseif item.type == FLUID_LIFE then
                target:addHealth(math.random(20, 100))
                fromPosition:sendMagicEffect(14)
                -- Print the name of the player who was healed
                print(target:getName(), "was healed.")
            end
            target:say(fluidMessage[item.type] or "Gulp.", TALKTYPE_MONSTER_SAY)
            item:transform(item:getId(), FLUID_NONE)
        end
    else
        if item.type == FLUID_NONE then
            player:sendTextMessage(MESSAGE_STATUS_SMALL, "It is empty.")
        else
            -- Handle the case where the target is not a player
            -- For example, you could print a message or perform a different action
            print("Target is not a player.")
            -- Add more actions as needed
        end
    end
    
    return true
end
