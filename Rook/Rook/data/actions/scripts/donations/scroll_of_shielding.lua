--Adds 2 000(* skillrate) attacks with weapon
function onUse(cid, item, frompos, item2, topos)
	doRemoveItem(item.uid, 1)
	RATESKILL = getConfigValue("RateSkill")
	for i=1, 100 do
	doPlayerAddSkillTry(cid, 5, 20, RATESKILL)
	end
end