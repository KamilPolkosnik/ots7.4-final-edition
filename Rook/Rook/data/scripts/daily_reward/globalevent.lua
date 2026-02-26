local dailyRewardInit = GlobalEvent("dailyRewardInit")
function dailyRewardInit.onStartup()
	initDailyReward()
end
dailyRewardInit:register()
