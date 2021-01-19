local module = {}

local mapModule = require(game.ReplicatedStorage.Modules.mapInfo)

function module.createMapInfo(plr, mapName, attemptsValue, highscoreValue)
	if plr:IsA("Player") and plr:FindFirstChild("stats") then
		local mapFolder = Instance.new("Folder")
		mapFolder.Name = mapName
		local highScore = Instance.new("IntValue")
		highScore.Name = "HighScore"
		highScore.Value = highscoreValue or 0
		highScore.Parent = mapFolder
		local attempts = Instance.new("IntValue")
		attempts.Name = "Attempts"
		attempts.Value = attemptsValue or 0
		attempts.Parent = mapFolder
		mapFolder.Parent = plr.stats.Maps
		return highScore, attempts
	end
end

function module.createGamepass(plr, name)
	if plr:IsA("Player") and plr:FindFirstChild("Gamepasses") then
		local newGamepass = Instance.new("StringValue")
		newGamepass.Name = name 
		newGamepass.Parent = plr.Gamepasses
		if name == "Unlock Maps" then
			local mapList = mapModule.getMapList()
			for i, v in pairs(mapList) do
				if plr:FindFirstChild("stats") and not plr.stats.Maps:FindFirstChild(i) then
					module.createMapInfo(plr, i)
				end
			end
		end
	end
end

return module
