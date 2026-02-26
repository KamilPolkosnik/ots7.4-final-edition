-- Define a function to check if the player is wearing any equipment
local function hasEquipment(player)
    return player:getSlotItem(CONST_SLOT_HEAD) or 
           player:getSlotItem(CONST_SLOT_NECKLACE) or  -- Added necklace slot check
           player:getSlotItem(CONST_SLOT_ARMOR) or 
           player:getSlotItem(CONST_SLOT_LEGS) or 
           player:getSlotItem(CONST_SLOT_FEET) or 
           player:getSlotItem(CONST_SLOT_LEFT) or 
           player:getSlotItem(CONST_SLOT_RIGHT) or 
           player:getSlotItem(CONST_SLOT_RING_LEFT) or 
           player:getSlotItem(CONST_SLOT_RING_RIGHT)
end




-- Register red gem (ID: 2156)
local redGem = Action()
redGem:id(2156)

function redGem.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if hasEquipment(player) then
        player:say("You need to take off your equipment to use the gem.", TALKTYPE_MONSTER_SAY)
        return false
    end

    if not player:hasFlag("red_gem_bonus_applied") then
        player:setMaxHealth(player:getMaxHealth() + 1)
        --player:addFlag("red_gem_bonus_applied")
        player:say("You gained +1 maximum health!", TALKTYPE_MONSTER_SAY)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        item:remove(1)
        return true
    else
        player:say("You have already received the bonus from this gem.", TALKTYPE_MONSTER_SAY)
        return false
    end
end

redGem:register()

-- Register blue gem (ID: 2158)
local blueGem = Action()
blueGem:id(2158)

function blueGem.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if hasEquipment(player) then
        player:say("You need to take off your equipment to use the gem.", TALKTYPE_MONSTER_SAY)
        return false
    end

    if not player:hasFlag("blue_gem_bonus_applied") then
        player:setMaxMana(player:getMaxMana() + 1)
        --player:addFlag("blue_gem_bonus_applied")
        player:say("You gained +1 maximum mana!", TALKTYPE_MONSTER_SAY)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        item:remove(1)
        return true
    else
        player:say("You have already received the bonus from this gem.", TALKTYPE_MONSTER_SAY)
        return false
    end
end

blueGem:register()

-- Register yellow gem (ID: 2154)
local yellowGem = Action()
yellowGem:id(2154)

function yellowGem.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if hasEquipment(player) then
        player:say("You need to take off your equipment to use the gem.", TALKTYPE_MONSTER_SAY)
        return false
    end

    if not player:hasFlag("yellow_gem_bonus_applied") then
        local tries = math.random(50, 250)
        player:addSkillTries(SKILL_DISTANCE, tries)
        --player:addFlag("yellow_gem_bonus_applied")
        player:say("You gained " .. tries .. " distance skill tries!", TALKTYPE_MONSTER_SAY)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        item:remove(1)
        return true
    else
        player:say("You have already received the bonus from this gem.", TALKTYPE_MONSTER_SAY)
        return false
    end
end

yellowGem:register()

-- Register green gem (ID: 2155)
local greenGem = Action()
greenGem:id(2155)

function greenGem.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if hasEquipment(player) then
        player:say("You need to take off your equipment to use the gem.", TALKTYPE_MONSTER_SAY)
        return false
    end

    -- Create a table with skill types
    local skills = {
        [SKILL_CLUB] = player:getSkillLevel(SKILL_CLUB),
        [SKILL_AXE] = player:getSkillLevel(SKILL_AXE),
        [SKILL_SWORD] = player:getSkillLevel(SKILL_SWORD)
    }

    local highestSkill = 0
    local highestSkillType
    local secondHighestSkill = 0
    local secondHighestSkillType

    -- Find the highest and second highest skill levels and their types
    for skillType, skillLevel in pairs(skills) do
        if skillLevel > highestSkill then
            secondHighestSkill = highestSkill
            secondHighestSkillType = highestSkillType
            highestSkill = skillLevel
            highestSkillType = skillType
        elseif skillLevel > secondHighestSkill then
            secondHighestSkill = skillLevel
            secondHighestSkillType = skillType
        end
    end

    local tries = math.random(100, 1000)

    -- Calculate tries distribution
    local highestTries = tries
    local secondHighestTries = tries * 0.25
    local thirdHighestTries = tries * 0.25

    -- Apply tries to the skills
    player:addSkillTries(highestSkillType, highestTries)
    player:addSkillTries(secondHighestSkillType, secondHighestTries)
    for skillType, skillLevel in pairs(skills) do
        if skillType ~= highestSkillType and skillType ~= secondHighestSkillType then
            player:addSkillTries(skillType, thirdHighestTries)
        end
    end

    player:say("You gained combat skill tries!", TALKTYPE_MONSTER_SAY)

    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)

    item:remove(1)

    return true
end



greenGem:register()
