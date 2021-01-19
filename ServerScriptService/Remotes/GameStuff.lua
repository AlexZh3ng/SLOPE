local re = game.ReplicatedStorage.REs.Music
local tutorialRE = game.ReplicatedStorage.REs.TutorialRE

re.OnServerEvent:Connect(function(plr, setting, value)
	plr.stats:FindFirstChild(setting).Value = value
end)

tutorialRE.OnServerEvent:Connect(function(plr)
	plr.Character.HumanoidRootPart.CFrame = game.Workspace.Maps.Ramps["Start Point"].CFrame
end)