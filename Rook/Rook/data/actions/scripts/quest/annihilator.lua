 -- Annihilator script by GriZzm0
 -- Room check and monster removal by Tworn
 
 --Variables used:

 -- player?pos  = The position of the players before teleport.
 -- player?  = Get the thing from playerpos.
 --player?level = Get the players levels.
 --questslevel  = The level you have to be to do this quest.
 --questtatus?  = Get the quest status of the players.
 --demon?pos  = The position of the demons.
 --nplayer?pos  = The position where the players should be teleported too.
 --trash= position to send the demons to when clearing, 1 sqm in middle of nowhere is enough
 -- starting = Upper left point of the annihilator room area.
 -- ending = Bottom right point of the annihilator room area.
 
 --UniqueIDs used:

 --5000 = The switch.
 --5001 = Demon Armor chest.
 --5002 = Magic Sword chest.
 --5003 = Stonecutter Axe chest.
 --5004 = Present chest.


local function isRoomOccupied()
	local minX, maxX = 33219, 33236
	local minY, maxY = 31656, 31662
	local z = 13

	local centerPos = {x = 33228, y = 31659, z = z}
	local rangeX = maxX - centerPos.x
	local rangeY = maxY - centerPos.y

	local spectators = getSpectators(centerPos, rangeX, rangeY, false, true)
	if spectators then
		for i = 1, #spectators do
			local pos = spectators[i]:getPosition()
			if pos.z == z and pos.x >= minX and pos.x <= maxX and pos.y >= minY and pos.y <= maxY then
				return true
			end
		end
	else
		for x = minX, maxX do
			for y = minY, maxY do
				local thing = getThingfromPos({x = x, y = y, z = z, stackpos = 253})
				if thing.uid > 0 and isPlayer(thing.uid) then
					return true
				end
			end
		end
	end
	return false
end

local function isGM(cid)
	local gid = getPlayerGroupId(cid)
	return gid and gid >= 4
end

local demonArmorQuest = {
	storageValue = 203,
	item = {id = 2494, count = 1}, -- demon armor
	message = "You have found a demon armor."
}

local magicSwordQuest = {
	storageValue = 203,
	item = {id = 2400, count = 1}, -- magic sword
	message = "You have found a magic sword."
}

local stonecutterAxeQuest = {
	storageValue = 203,
	item = {id = 2431, count = 1}, -- stonecutter axe
	message = "You have found a stonecutter axe."
}

local annihilationBearQuest = {
	storageValue = 203,
	item = {id = 1990, count = 1}, -- present
	content = {
		{id = 2326, count = 1}, -- annihilation bear
	},
	message = "You have found a present."
}

local function giveQuestReward(cid, item, quest)
	if onUseQuest then
		local player = Player(cid)
		local itemObj = Item(item.uid)
		if player and itemObj then
			return onUseQuest(player, itemObj, quest)
		end
	end

	if not isGM(cid) and getPlayerStorageValue(cid, quest.storageValue) ~= -1 then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "It is empty.")
		return true
	end

	if quest.content then
		local containerUid = doPlayerAddItem(cid, quest.item.id, quest.item.count or 1)
		if containerUid and containerUid > 0 then
			for _, nextReward in ipairs(quest.content) do
				doAddContainerItem(containerUid, nextReward.id, nextReward.count or 1)
			end
		end
	else
		doPlayerAddItem(cid, quest.item.id, quest.item.count or 1)
	end

	doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, quest.message or "You have found an item.")
	setPlayerStorageValue(cid, quest.storageValue, 1)
	return true
end

function onUse(cid, item, frompos, item2, topos)
if item.actionid == 1203 then
	if frompos.x == 33227 and frompos.y == 31656 and frompos.z == 13 then
		return giveQuestReward(cid, item, demonArmorQuest)
	elseif frompos.x == 33229 and frompos.y == 31656 and frompos.z == 13 then
		return giveQuestReward(cid, item, magicSwordQuest)
	elseif frompos.x == 33231 and frompos.y == 31656 and frompos.z == 13 then
		return giveQuestReward(cid, item, stonecutterAxeQuest)
	elseif frompos.x == 33233 and frompos.y == 31656 and frompos.z == 13 then
		return giveQuestReward(cid, item, annihilationBearQuest)
	end
end
if item.uid == 5000 or item.actionid == 2015 then
 if item.itemid == 1946 then
 if isRoomOccupied() then
  doPlayerSendCancel(cid,"Someone is already inside the quest room.")
  return 1
 end

 playerPositions = {
  {x=33225, y=31671, z=13, stackpos=253},
  {x=33224, y=31671, z=13, stackpos=253},
  {x=33223, y=31671, z=13, stackpos=253},
  {x=33222, y=31671, z=13, stackpos=253}
 }

 targetPositions = {
  {x=33222, y=31659, z=13},
  {x=33221, y=31659, z=13},
  {x=33220, y=31659, z=13},
  {x=33219, y=31659, z=13}
 }

 players = {}
 for i = 1, #playerPositions do
  local p = getThingfromPos(playerPositions[i])
  players[i] = p
 end

 local isGM = getPlayerGroupId(cid) >= 4

 local hasAllPlayers = true
 local hasAnyPlayer = false
 for i = 1, #players do
  if players[i].itemid > 0 then
   hasAnyPlayer = true
  else
   hasAllPlayers = false
  end
 end

 if (not isGM and not hasAllPlayers) then
  doPlayerSendCancel(cid,"You need 4 players in your team.")
  return 1
 end

 if (isGM and not hasAnyPlayer) then
  doPlayerSendCancel(cid,"You need at least 1 player on the quest tiles.")
  return 1
 end

 if not isGM then
  player1level = getPlayerLevel(players[1].uid)
  player2level = getPlayerLevel(players[2].uid)
  player3level = getPlayerLevel(players[3].uid)
  player4level = getPlayerLevel(players[4].uid)

  questlevel = 100

  if player1level < questlevel or player2level < questlevel or player3level < questlevel or player4level < questlevel then
   doPlayerSendCancel(cid,"Your level is too low")
   return 1
  end

  queststatus1 = getPlayerStorageValue(players[1].uid,8160)
  queststatus2 = getPlayerStorageValue(players[2].uid,8160)
  queststatus3 = getPlayerStorageValue(players[3].uid,8160)
  queststatus4 = getPlayerStorageValue(players[4].uid,8160)

  if queststatus1 ~= -1 or queststatus2 ~= -1 or queststatus3 ~= -1 or queststatus4 ~= -1 then
   doPlayerSendCancel(cid,"Someone has already done this quest")
   return 1
  end
 end

 demon1pos = {x=33219, y=31657, z=13}
 demon2pos = {x=33221, y=31657, z=13}
 demon3pos = {x=33220, y=31661, z=13}
 demon4pos = {x=33222, y=31661, z=13}
 demon5pos = {x=33223, y=31659, z=13}
 demon6pos = {x=33224, y=31659, z=13}

 doSummonCreature("Demon", demon1pos)
 doSummonCreature("Demon", demon2pos)
 doSummonCreature("Demon", demon3pos)
 doSummonCreature("Demon", demon4pos)
 doSummonCreature("Demon", demon5pos)
 doSummonCreature("Demon", demon6pos)

 for i = 1, #players do
  if players[i].itemid > 0 then
   doSendMagicEffect(playerPositions[i],2)
   doTeleportThing(players[i].uid, targetPositions[i])
   doSendMagicEffect(targetPositions[i],10)
  end
 end

 doTransformItem(item.uid,1946)
 end
 if item.itemid == 1945 then
doTransformItem(item.uid,1946)
end
end
if item.uid == 5001 then
 queststatus = getPlayerStorageValue(cid,100)
 if queststatus == -1 then
 if getPlayerFreeCap(cid) <= 100 then
doPlayerSendTextMessage(cid,22,"You need 100 cap or more to loot this!")
return TRUE
end
  doPlayerSendTextMessage(cid,22,"You have found a demon armor.")
  doPlayerAddItem(cid,2494,1)
  setPlayerStorageValue(cid,100,1)
 else
  doPlayerSendTextMessage(cid,22,"It is empty.")
 end
end
if item.uid == 5002 then
 queststatus = getPlayerStorageValue(cid,100)
 if queststatus ~= 1 then
 if getPlayerFreeCap(cid) <= 100 then
doPlayerSendTextMessage(cid,22,"You need 100 cap or more to loot this!")
return TRUE
end
  doPlayerSendTextMessage(cid,22,"You have found a magic sword.")
  doPlayerAddItem(cid,2400,1)
  setPlayerStorageValue(cid,100,1)
 else
  doPlayerSendTextMessage(cid,22,"It is empty.")
 end
end
if item.uid == 5003 then
 queststatus = getPlayerStorageValue(cid,100)
 if queststatus ~= 1 then
 if getPlayerFreeCap(cid) <= 100 then
doPlayerSendTextMessage(cid,22,"You need 100 cap or more to loot this!")
return TRUE
end
  doPlayerSendTextMessage(cid,22,"You have found a stonecutter axe.")
  doPlayerAddItem(cid,2431,1)
  setPlayerStorageValue(cid,100,1)
 else
  doPlayerSendTextMessage(cid,22,"It is empty.")
 end
end
if item.uid == 5004 then
 queststatus = getPlayerStorageValue(cid,100)
 if queststatus ~= 1 then
 if getPlayerFreeCap(cid) <= 100 then
doPlayerSendTextMessage(cid,22,"You need 100 cap or more to loot this!")
return TRUE
end
  doPlayerSendTextMessage(cid,22,"You have found a present.")
  doPlayerAddItem(cid,2326,1)
  setPlayerStorageValue(cid,100,1)
 else
  doPlayerSendTextMessage(cid,22,"It is empty.")
 end
 end
 return 1
end
