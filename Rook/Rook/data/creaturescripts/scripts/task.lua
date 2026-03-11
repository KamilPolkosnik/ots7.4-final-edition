function onKill(cid, target)
    local player = Player(cid)
    if not player then
        return true
    end

    local targetName = getCreatureName(target)
    local monsterTarget = Monster(target)
    if monsterTarget then
        targetName = monsterTarget:getName() or targetName
    end

    if isMonster(target) then
        if BestiarySystem and BestiarySystem.onKill then
            BestiarySystem.onKill(player, targetName)
        end

        TaskSystem.handleKill(player, targetName)
    end

    return true
end
