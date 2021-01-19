local rf = game.ReplicatedStorage.REs.SubmitCode
local giveMod = require(game.ServerScriptService.Modules.GiveItem)

local codes = {
	["day1"] = "Green Arrow";
}

local function checkCode(plr, code)
	if codes[code] ~= nil then
		if plr.stats.Inventory:FindFirstChild(codes[code]) then
			return "Already redeemed"
		else
			giveMod.Give(plr, codes[code])
			return "Item rewarded!"
		end
	else
		return "Wrong code"
	end
end

rf.OnServerInvoke = checkCode