local actionpaddlingbook = Action()

function actionpaddlingbook.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:getStorageValue(12001) ~= 1 then
        player:say("You have learned paddling.", TALKTYPE_MONSTER_SAY)
        player:setStorageValue(12001, 1)
        item:remove(1)
    else
        player:say("You have read the Paddling Book.", TALKTYPE_MONSTER_SAY)
    end
end


actionpaddlingbook:id(7939)
actionpaddlingbook:register()
