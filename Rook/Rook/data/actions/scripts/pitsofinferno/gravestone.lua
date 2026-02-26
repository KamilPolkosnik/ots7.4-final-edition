local newpos = {x = 32791, y = 32332, z = 10}
local splash = {x = 32791, y = 32334, z = 9}
function onUse(cid, item, fromPosition, itemEx, toPosition)
local blood = getTileItemById(splash, 2025)
if blood.uid > 0 and blood.type == 2 then
doRemoveItem(blood.uid)
doSendMagicEffect(getThingPos(cid), CONST_ME_DRAWBLOOD)
doTeleportThing(cid, newpos)
doCreatureSay(cid, 'Muahaha..',16)
doSendMagicEffect(newpos, CONST_ME_MORTAREA)
return 1
end
end