function onUse(cid, item, frompos, item2, topos)

local fragticks = getPlayerRedSkullTicks(cid)

if (fragticks > 1) then
doPlayerSetRedSkullTicks(cid, 0)
db.executeQuery("UPDATE `players` SET `redskull` = 0 WHERE `id` = " .. getPlayerGUID(cid) .. ";")
doCreatureSetSkullType(cid,0)
doPlayerSendTextMessage(cid, 20, 'Your frags and your skull have been removed!')

doSendMagicEffect(getPlayerPosition(cid),CONST_ME_MAGIC_RED)
doRemoveItem(item.uid, 1)
doPlayerSetSkullEnd(cid, 0, getPlayerSkullType(cid))
doPlayerSave(cid, true)
else
doPlayerSendCancel(cid,"You do not have any unjustified kills.")
return TRUE
end
end