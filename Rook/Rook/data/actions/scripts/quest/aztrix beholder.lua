function onUse(cid, item, frompos, item2, topos)
if item.uid == 25018 then
  queststatus = getPlayerStorageValue(cid,25018)
  if queststatus == -1 or queststatus == 0 then
   doPlayerSendTextMessage(cid,22,"You have found a bag.")
container = us_AddQuestReward(cid, 1987, 1)
us_AddQuestContainerReward(container, cid, 4851, 1)
us_AddQuestContainerReward(container, cid, 2168, 1)
us_AddQuestContainerReward(container, cid, 2006, 7)

   setPlayerStorageValue(cid,25018,1)

  else
   doPlayerSendTextMessage(cid,22,"it\'s empty.")
  end
else
  return 0
end
return 1
end

