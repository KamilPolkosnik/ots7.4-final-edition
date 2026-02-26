local wall1pos = {x=32851, y=32333, z=12, stackpos=1}
local wall2pos = {x=32852, y=32333, z=12, stackpos=1}
local leverpos1 = {x=32846, y=32318, z=12, stackpos=1}
local leverpos2 = {x=32850, y=32366, z=13, stackpos=1}
local leverpos3 = {x=32860, y=32364, z=13, stackpos=1}
local leverpos4 = {x=32843, y=32352, z=14, stackpos=1}
local leverpos5 = {x=32874, y=32365, z=13, stackpos=1}
local leverpos6 = {x=32887, y=32355, z=13, stackpos=1}
local leverpos7 = {x=32853, y=32359, z=14, stackpos=1}
local leverpos8 = {x=32843, y=32359, z=12, stackpos=1}
local leverpos9 = {x=32874, y=32354, z=14, stackpos=1}
local leverpos10 = {x=32891, y=32328, z=14, stackpos=1}
local leverpos11 = {x=32889, y=32349, z=15, stackpos=1}
local leverpos12 = {x=32874, y=32334, z=12, stackpos=1}
local leverpos13 = {x=32887, y=32330, z=12, stackpos=1}
local leverpos14 = {x=32886, y=32337, z=13, stackpos=1}

function onUse(cid, item, frompos, item2, topos)

local wall1 = getThingfromPos(wall1pos)
local wall2 = getThingfromPos(wall2pos)

local lever1 = getThingfromPos(leverpos1)
local lever2 = getThingfromPos(leverpos2)
local lever3 = getThingfromPos(leverpos3)
local lever4 = getThingfromPos(leverpos4)
local lever5 = getThingfromPos(leverpos5)
local lever6 = getThingfromPos(leverpos6)
local lever7 = getThingfromPos(leverpos7)
local lever8 = getThingfromPos(leverpos8)
local lever9 = getThingfromPos(leverpos9)
local lever10 = getThingfromPos(leverpos10)
local lever11 = getThingfromPos(leverpos11)
local lever12 = getThingfromPos(leverpos12)
local lever13 = getThingfromPos(leverpos13)
local lever14 = getThingfromPos(leverpos14)

if (item.itemid == 1946 and lever1.itemid == 1946 and lever2.itemid == 1946 and lever3.itemid == 1946 and lever4.itemid == 1946 and lever5.itemid == 1946 and lever6.itemid == 1946 and lever7.itemid == 1946 and lever8.itemid == 1946 and lever9.itemid == 1946 and lever10.itemid == 1946 and lever11.itemid == 1946 and lever12.itemid == 1946 and lever13.itemid == 1946 and lever14.itemid == 1946) then
doSendMagicEffect(wall1pos, 13)
doSendMagicEffect(wall2pos, 13)
doCreateItem(1304,1,wall1pos)
doCreateItem(1304,1,wall2pos)
    doTransformItem(item.uid,1945)
elseif (item.itemid == 1945 and  lever1.itemid == 1946 and lever2.itemid == 1946 and lever3.itemid == 1946 and lever4.itemid == 1946 and lever5.itemid == 1946 and lever6.itemid == 1946 and lever7.itemid == 1946 and lever8.itemid == 1946 and lever9.itemid == 1946 and lever10.itemid == 1946 and lever11.itemid == 1946 and lever12.itemid == 1946 and lever13.itemid == 1946 and lever14.itemid == 1946) then
doSendMagicEffect(wall1pos, 2)
doSendMagicEffect(wall2pos, 2)
doRemoveItem(wall1.uid,1)
doRemoveItem(wall2.uid,1)
    doTransformItem(item.uid,1946)
else 
doPlayerSendCancel(cid,"You have not pulled all 15 levers.") 
	end
   return 1
end



