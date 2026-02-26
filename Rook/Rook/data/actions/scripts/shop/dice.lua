function onUse(cid, item, fromPosition, itemEx, toPosition)
if exhaustion.get(cid, 101) then
doPlayerSendDefaultCancel(cid, RETURNVALUE_YOUAREEXHAUSTED)
return true
end
exhaustion.set(cid, 101, 1)
   if(fromPosition.x ~= CONTAINER_POSITION) then
     doSendMagicEffect(fromPosition, CONST_ME_CRAPS)
   end

   local value = math.random(5722, 5727)
   for i, pid in ipairs(getSpectators(getThingPosition(item.uid), 3, 3)) do
   end
   
     if(isPlayer(cid)) then
	   doPlayerSay(cid, getCreatureName(cid) .. ' rolled a ' .. value - 5721 .. '.', 16)
     end
	 
   doTransformItem(item.uid, value)
   return true
end