LOCKEDDOOR = {60011, 60012, 60013, 60014, 60015, 60016, 60017, 60018, 60019, 60020, 60021, 60022, 60023, 60024, 60025, 60026, 60027, 60028, 60029, 60030}

function onUse(cid, item, frompos, item2, topos)

if item.uid == 60010 or item.actionid == 60010 or isInArray(LOCKEDDOOR, item.uid) == true then
if getPlayerStorageValue(cid, 60010) == 1 then
pos = getPlayerPosition(cid)

if pos.x == topos.x then
if pos.y < topos.y then
pos.y = topos.y + 1
else
pos.y = topos.y - 1
end
elseif pos.y == topos.y then
if pos.x < topos.x then
pos.x = topos.x + 1
else
pos.x = topos.x - 1
end
else
doPlayerSendTextMessage(cid,22,'Please stand in front of the door.')
return 1
end

doTeleportThing(cid,pos)
doSendMagicEffect(topos,12)
else
doPlayerSendTextMessage(cid,22,'It\'s Locked!')
end
return 1
else
return 0
end
end