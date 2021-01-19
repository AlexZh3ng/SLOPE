local module = {}

local itemMod = require(game.ReplicatedStorage.Modules.itemInfo)

function module.Give(plr, item, amount)
	--print(plr, item, amount)
	if item == "Coins" then
		plr.stats.Coins.Value = plr.stats.Coins.Value + amount
	elseif item == "Gems" then
		plr.stats.Gems.Value = plr.stats.Gems.Value + amount
	else
		for itemName, info in pairs(itemMod.getAllItems()) do
			if item == itemName or item.Name == itemName then
				info.ItemFull:Clone().Parent = plr.stats.Inventory
				return
			end
		end
	end
end

return module
