local re = game.ReplicatedStorage.REs.Equip
local devFolder = game.Workspace.DevProducts
local itemModule = require(game.ReplicatedStorage.Modules.itemInfo)

re.OnServerEvent:Connect(function(plr, event, item)
	local itemInfo = itemModule.getItem(item)
	if itemInfo == nil then return end
	if event == "Equip" then
		if plr.stats.Inventory:FindFirstChild(itemInfo.ItemName) then
			plr.stats.Equipped:FindFirstChild(itemInfo.ItemCategory).Value = itemInfo.ItemName
		end
	elseif event == "Unowned" then
		if devFolder:FindFirstChild(plr.Name) then
			devFolder:FindFirstChild(plr.Name):Destroy()
		end
		local item = Instance.new("StringValue", devFolder)
		item.Value = itemInfo.ItemName
		item.Name = plr.Name
	end
end)