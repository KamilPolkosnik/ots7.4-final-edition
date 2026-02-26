-- Define the onAdvance function
function onAdvance(player, skill, oldLevel, newLevel)
    -- Check if the skill being advanced is the player's level
    if skill == SKILL_LEVEL then
        -- Save player data after advancing level
        player:save()
        print("Player " .. player:getName() .. " advanced to level " .. newLevel)
		player:say("Saved on Advanced.", TALKTYPE_MONSTER_SAY)
    end
    return true
end
