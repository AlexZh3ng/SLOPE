local plr = game.Players.LocalPlayer
local rewardMenu = script.Parent:WaitForChild("MainUI"):WaitForChild("Menus"):WaitForChild("DailyRewards")
local tutorialMenu = script.Parent.MainUI.Menus.Tutorial
local menuMod = require(game.ReplicatedStorage.Modules.menuHandler)
local soundMod = require(game.ReplicatedStorage.Modules.soundHandler)
local re = game.ReplicatedStorage.REs.DailyRewards
local tutorialRE = game.ReplicatedStorage.REs.TutorialRE
local money = script.Parent.MainUI:WaitForChild("Money")
local rewarded = 0

rewardMenu.Content.Close.MouseButton1Down:Connect(function()
	rewardMenu.Visible = false
	money:WaitForChild("GemValue").Text = tostring(money.GemValue.Text) + rewarded
	soundMod.playSound("GemFX")
end)

re.OnClientEvent:Connect(function(day)
	--menuMod.openMenu("DailyRewards", true)
	rewardMenu.Visible = true
	for i = 1, day do
		rewardMenu.Content.Rewards:FindFirstChild(i).BackgroundColor3 = Color3.new(62/255, 1, 68/255)
	end
	rewarded = day * 10 
	money:WaitForChild("GemValue").Text = tostring(money.GemValue.Text) - rewarded
end)

tutorialMenu.Content.Close.MouseButton1Down:Connect(function()
	tutorialMenu.Visible = false
	tutorialRE:FireServer()
end)

tutorialRE.OnClientEvent:Connect(function()
	tutorialMenu.Visible = true
end)

plr:WaitForChild("stats"):WaitForChild("Coins").Changed:Connect(function(v)
	money:WaitForChild("CoinValue").Text = v
end)

plr.stats:WaitForChild("Gems").Changed:Connect(function(v)
	money:WaitForChild("GemValue").Text = v
end)

money:WaitForChild("CoinValue").Text = plr.stats.Coins.Value
money:WaitForChild("GemValue").Text = plr.stats.Gems.Value