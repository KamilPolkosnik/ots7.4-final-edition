local pos = { x=32840, y=32248, z=10}
local from = { x=32828, y=32249, z=10}
local to = { x=32841, y=32255, z=10}
local pos1 = { x=32840, y=32249, z=10}
local pos2 = { x=32840, y=32248, z=10}

function onUse(cid, item, fromPosition, itemEx, toPosition)
if(item.uid == 7874 and item.itemid == 1213) then
search = false
for t = from.x, to.x do
for f = from.y, to.y do
pos = {x=t,y=f,z=10}
pid = getTopCreature(pos).uid
if isMonster(pid) then
search = true
end
end
end

if search == true then
doPlayerSendTextMessage(cid, 19,"All monsters have to be dead in this room!")
else
doTransformItem(item.uid, item.itemid + 1)
doSendMagicEffect(pos1,6)
doSendMagicEffect(pos2,6)
doDecayItemTo(toPosition, itemEx.itemid, 90)
return true
end
else

end
return true
end
