local rf = game.ReplicatedStorage.REs.BuyItem
local giveMod = require(game.ServerScriptService.Modules.GiveItem)
local itemMod = require(game.ReplicatedStorage.Modules.itemInfo)

local function purchase(plr, item)
	local itemInfo = itemMod.getItem(item)
	
	if plr.stats.Inventory:FindFirstChild(item) then return "Owned" end
	
	if plr.stats:FindFirstChild(itemInfo.Cost[1]) and plr.stats[itemInfo.Cost[1]].Value >= itemInfo.Cost[2] then
		plr.stats[itemInfo.Cost[1]].Value = plr.stats[itemInfo.Cost[1]].Value - itemInfo.Cost[2]
		giveMod.Give(plr, item)
		return "Owned"
	end
	
end

rf.OnServerInvoke = purchase