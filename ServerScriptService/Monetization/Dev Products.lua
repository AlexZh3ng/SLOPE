local MPS = game:GetService("MarketplaceService")
local shortcuts = require(game.ServerScriptService.Modules.Shortcuts)
local gameInfo = require(game.ReplicatedStorage.Modules.gameInfo):getInfo()
local itemInfo = require(game.ReplicatedStorage.Modules.itemInfo)
local gameSetup = require(game.ServerScriptService.Modules.GameSetup)
local giveMod = require(game.ServerScriptService.Modules.GiveItem)
local gameEvents = game.ReplicatedStorage.REs.GameChange

local devFolder = game.Workspace.DevProducts

local maps = {
	[724704875] = "Quick Move";
	[724705678] = "Sky Fall";
	[724707216] = "Sonic Speed";
	[724707679] = "Hydra Slope";
}
local misc = {
	[724701900] = "Revive";
}

local currency = {
	[724724316] = {"Coins", 100};
	[724729092] = {"Coins", 500};
	[724730137] = {"Coins", 1000};
	[724721169] = {"Gems", 25};
	[724722068] = {"Gems", 100};
	[724722845] = {"Gems", 250};
}

local equips = { --Unnecessary to have 3 different dev products but just for name of dev product/future price changes
	[724737220] = "Marble";
	[724734894] = "Particle";
	[724734316] = "Trail";
}

local gamepasses = {
	[7854576] = "Double Coins"; 
	[7854601] = "Unlock Maps";	
}

MPS.ProcessReceipt = function(Info)
	local plrId = Info.PlayerId
	local purchaseId = Info.ProductId
	local plr = game.Players:GetPlayerByUserId(plrId)
	if maps[purchaseId] and plr then
		shortcuts.createMapInfo(plr, maps[purchaseId])
	elseif misc[purchaseId] and plr then
		if misc[purchaseId] == "Revive" then
			--Make a module for the marble spawning
			print("Player purchased a revive:", plr)
			local playerData = gameSetup.getData(plr)
			if plr:FindFirstChild("stats") and playerData then
				local score = plr.stats.Score.Value
				gameEvents:FireClient(plr, "Revive")
				gameSetup.start(playerData[1], playerData[2], playerData[2].Checkpoints:FindFirstChild(tostring(score)).Value.Value, "Revive", playerData[3])
			else
				print("Error purchasing Revive: plr stats not found or playerData not found ",plr)
			end
			
		end
	elseif currency[purchaseId] and plr then
		plr.stats:FindFirstChild(currency[purchaseId][1]).Value = plr.stats:FindFirstChild(currency[purchaseId][1]).Value + currency[purchaseId][2]
	elseif equips[purchaseId] and plr then
		local item = devFolder:FindFirstChild(plr.Name).Value
		giveMod.Give(plr, item)
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MPS.PromptGamePassPurchaseFinished:Connect(function(plr, gamePassId, wasPurchased)
	if wasPurchased and gamepasses[gamePassId] and plr then
		local passName = gamepasses[gamePassId]
		shortcuts.createGamepass(plr, passName)
	end
end)
	