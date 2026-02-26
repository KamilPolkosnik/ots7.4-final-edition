--Adds 2 000 used mana points X rate
function onUse(cid, item, frompos, item2, topos)
	doRemoveItem(item.uid, 1)
	RATEMAGIC = getConfigValue("RateMag")
	for i=1, 100 do
	doPlayerAddManaSpent(cid, 100, RATEMAGIC)
	end
end