local ts = game:GetService("TweenService")
local gameInfo = require(game.ReplicatedStorage.Modules.gameInfo):getInfo()
local mapInfo = require(game.ReplicatedStorage.Modules.mapInfo)
local mps = game:GetService("MarketplaceService")
local itemInfo = require(game.ReplicatedStorage.Modules.itemInfo)
local gameSetup = require(game.ServerScriptService.Modules.GameSetup)

local gameEvent = game.ReplicatedStorage.REs.GameChange
local coinEvent = game.ReplicatedStorage.REs.Coin

local coinMultiplier = 1
local coinGamepass = 1

for _, map in pairs(game.Workspace.Maps:GetChildren()) do
	if map:FindFirstChild("Start Point") then
		map["Start Point"].Touched:Connect(function(hit)
			gameSetup.start(hit, map, map.SpawnPoint.Spawnpoint["Spawn Point"], "Start", gameInfo.Speed)
		end)
	end
end