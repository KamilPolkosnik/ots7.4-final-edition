function onUse(cid, item, fromPosition, item2, toPosition)
if( getPlayerSex(cid) == 0 )then
doPlayerSetSex(cid, 1)
doRemoveItem(item.uid, 1) 
doSendMagicEffect(getPlayerPosition(cid), CONST_ME_MAGIC_RED)
doPlayerSendTextMessage(cid,22,"Your sex have been changed.")
else
if( getPlayerSex(cid) == 1 ) then
doPlayerSetSex(cid, 0) 
doRemoveItem(item.uid, 1) 
doSendMagicEffect(getPlayerPosition(cid), CONST_ME_MAGIC_RED) 
doPlayerSendTextMessage(cid,22,"Your sex have been changed.")
end
return true
end
end