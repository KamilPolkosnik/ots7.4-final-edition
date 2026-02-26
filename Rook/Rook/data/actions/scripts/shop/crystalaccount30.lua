local sevenDays = 30 -- 7 days of golden account
function onUse(cid, item, frompos, item2, topos)
local lossPs = getPlayerLossPercent(cid, PLAYERLOSS_EXPERIENCE)
	if getGoldenAccountDays(cid) < 365 then
		doAddGoldenDays(cid, sevenDays)
		doCreatureSetStorage(cid, 133, 110)
		doPlayerSetRate(cid, SKILL__LEVEL, 1.1)
		doPlayerSetLossPercent(cid, PLAYERLOSS_EXPERIENCE, lossPs - 2)
		doSendMagicEffect(getThingPos(cid), 13)
		doPlayerSendTextMessage(cid, 22, "You have upgrade your account to golden account for 30 days.")
		doRemoveItem(item.uid, 1)
	else
		doPlayerSendTextMessage(cid, 22, "You cannot have more than 365 days of golden account.")
	end
		
	return true
end