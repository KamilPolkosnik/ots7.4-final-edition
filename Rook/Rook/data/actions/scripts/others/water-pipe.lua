function onUse(cid, item, fromPosition, itemEx, toPosition)
	-- TODO: Different music effect for different instruments.
	doSendMagicEffect(fromPosition, CONST_ME_POFF)
	return TRUE
end