function onSay(cid, words, param)
     local player = Player(cid)
     if not player:getGroup():getAccess() then
         return true
     end

     local t = param:split(",")
     local lookType = tonumber(t[1])
     if not lookType then
         lookType = MonsterType(t[1]) and MonsterType(t[1]):getOutfit().lookType
         if not lookType then
             player:sendCancelMessage("A monster with that name does not exist.")
             return false
         end
     end
     if t[2] then
         playerx, player = player, Player(t[2]:gsub("^%s*(.-)%s*$", "%1"))
         if not player then
             playerx:sendCancelMessage("A player with that name does not exist or is not online.")
             return false
         end
     end
     if lookType >= 0 then
         local playerOutfit = player:getOutfit()
         playerOutfit.lookType = lookType
         player:setOutfit(playerOutfit)
     else
         player = playerx or player
         player:sendCancelMessage("A look type with that id does not exist.")
     end
     return false
end