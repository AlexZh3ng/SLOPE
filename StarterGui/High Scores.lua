local plr = game.Players.LocalPlayer
local maps = plr:WaitForChild("stats"):WaitForChild("Maps")
local scoreMenu = script.Parent:WaitForChild("MainUI"):WaitForChild("Menus"):WaitForChild("Scores")
local scores = scoreMenu.ScoreList
local menuMod = require(game.ReplicatedStorage.Modules.menuHandler)

local function createLabel(ownership)
	local label = game.ReplicatedStorage.Assets.ScoreLabel:Clone()
	label.Parent = scores
	label.MapName.Text = ownership.Name
	local attempts = ownership:WaitForChild("Attempts")
	local highScore = ownership:WaitForChild("HighScore")
	label.HighScore.Text = "High Score: "..highScore.Value
	
	label.Attempts.Text = "Attempts: "..attempts.Value
	label.LayoutOrder = -highScore.Value
	attempts:GetPropertyChangedSignal("Value"):Connect(function()
		label.Attempts.Text = "Attempts: "..attempts.Value
	end)
	highScore:GetPropertyChangedSignal("Value"):Connect(function()
		label.HighScore.Text = "High Scores: "..highScore.Value
	end)
end

for _, ownership in pairs(maps:GetChildren()) do
	createLabel(ownership)
end

maps.ChildAdded:Connect(function(child)
	createLabel(child)
end)
