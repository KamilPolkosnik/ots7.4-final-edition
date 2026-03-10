function onUse(cid, item, frompos, item2, topos)
if item.uid == 15201 then
 queststatus = getPlayerStorageValue(cid,15201)
 if queststatus == -1 then
  doPlayerSendTextMessage(cid,22,"You have found a sword ring.")
  us_AddQuestReward(cid,2207,1)
  setPlayerStorageValue(cid,15201,1)
 else
  doPlayerSendTextMessage(cid,22,"It is empty.")
 end
end
if item.uid == 15202 then
 queststatus = getPlayerStorageValue(cid,15201)
 if queststatus ~= 1 then
  doPlayerSendTextMessage(cid,22,"You have found a axe ring.")
  us_AddQuestReward(cid,2208,1)
  setPlayerStorageValue(cid,15201,1)
 else
  doPlayerSendTextMessage(cid,22,"It is empty.")
 end
end
if item.uid == 15203 then
 queststatus = getPlayerStorageValue(cid,15201)
 if queststatus ~= 1 then
  doPlayerSendTextMessage(cid,22,"You have found a club ring.")
  us_AddQuestReward(cid,2209,1)
  setPlayerStorageValue(cid,15201,1)
 else
  doPlayerSendTextMessage(cid,22,"It is empty.")
 end
end
if item.uid == 15204 then
 queststatus = getPlayerStorageValue(cid,15201)
 if queststatus ~= 1 then
  doPlayerSendTextMessage(cid,22,"You have found a power ring.")
  us_AddQuestReward(cid,2166,1)
  setPlayerStorageValue(cid,15201,1)
 else
  doPlayerSendTextMessage(cid,22,"It is empty.")
 end
 end
if item.uid == 15205 then
 queststatus = getPlayerStorageValue(cid,15201)
 if queststatus ~= 1 then
  doPlayerSendTextMessage(cid,22,"You have found a magic ring.")
  us_AddQuestReward(cid,2357,1)
  setPlayerStorageValue(cid,15201,1)
 else
  doPlayerSendTextMessage(cid,22,"It is empty.")
 end
end
if item.uid == 15206 then
 queststatus = getPlayerStorageValue(cid,15201)
 if queststatus ~= 1 then
  doPlayerSendTextMessage(cid,22,"You have found a distance ring.")
  us_AddQuestReward(cid,6300,1)
  setPlayerStorageValue(cid,15201,1)
 else
  doPlayerSendTextMessage(cid,22,"It is empty.")
 end
end
 return 1
end
