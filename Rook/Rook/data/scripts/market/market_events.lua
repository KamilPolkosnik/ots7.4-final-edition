local MarketStartup = GlobalEvent("MarketStartup")
function MarketStartup.onStartup()
	if MarketSystem and MarketSystem.onStartup then
		MarketSystem.onStartup()
	end
	return true
end
MarketStartup:register()

local MarketThink = GlobalEvent("MarketThink")
function MarketThink.onThink(interval)
	if MarketSystem and MarketSystem.onThink then
		MarketSystem.onThink()
	end
	return true
end
MarketThink:interval(1000)
MarketThink:register()

local MarketLogin = CreatureEvent("MarketLogin")
function MarketLogin.onLogin(player)
	if MarketSystem and MarketSystem.onLogin then
		return MarketSystem.onLogin(player)
	end
	return true
end
MarketLogin:type("login")
MarketLogin:register()

local MarketLogout = CreatureEvent("MarketLogout")
function MarketLogout.onLogout(player)
	if MarketSystem and MarketSystem.onLogout then
		return MarketSystem.onLogout(player)
	end
	return true
end
MarketLogout:type("logout")
MarketLogout:register()

local MarketTicketAction = Action()
function MarketTicketAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not MarketSystem or not MarketSystem.activateTicket then
		return true
	end
	return MarketSystem.activateTicket(player, item)
end
MarketTicketAction:aid(65048)
MarketTicketAction:register()

local MarketTicketItemAction = Action()
function MarketTicketItemAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not MarketSystem or not MarketSystem.activateTicket then
		return true
	end
	return MarketSystem.activateTicket(player, item)
end
MarketTicketItemAction:id(2329)
MarketTicketItemAction:register()

local MarketTicketUsedAction = Action()
function MarketTicketUsedAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not MarketSystem or not MarketSystem.activateTicket then
		return true
	end
	return MarketSystem.activateTicket(player, item)
end
MarketTicketUsedAction:aid(65049)
MarketTicketUsedAction:register()
