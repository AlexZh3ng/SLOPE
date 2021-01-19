local maps = game.Workspace.Maps
local mapInfo = {
	["Ramps"] = {"Lava Tunnel", "Lava Random Block", "Lava Dice Pattern", "Ramp Jump", "Lava Sliding Block"};
	["Quick Move"] = {"Lava Tunnel", "Lava Random Block", "Lava Dice Pattern", "Ramp Jump", "Lava Sliding Block", "Ramp Jump Left", "Ramp Jump Right"};
	["Sky Fall"] = {"Lava Tunnel", "Lava Random Block", "Lava Dice Pattern", "Ramp Jump", "Lava Sliding Block", "Ramp Jump Left", "Ramp Jump Right", "Lava Vertical Slide"};
	["Sonic Speed"] = {"Lava Tunnel", "Lava Random Block", "Lava Dice Pattern", "Ramp Jump", "Lava Sliding Block", "Ramp Jump Left", "Ramp Jump Right", "Lava Vertical Slide"};
	["Hydra Slope"] = {"Lava Tunnel", "Lava Random Block", "Lava Dice Pattern", "Ramp Jump", "Lava Sliding Block", "Ramp Jump Left", "Ramp Jump Right", "Lava Vertical Slide", "Lava Paths"};
	["Sugar Boost"] = {"Lava Tunnel", "Lava Random Block", "Lava Dice Pattern", "Ramp Jump", "Lava Sliding Block"};
}

local rampInfo = {
	["Ramps"] = {"Ramp"};
	["Quick Move"] = {"Ramp"};
	["Sky Fall"] = {"Ramp"};
	["Sonic Speed"] = {"Ramp", "Ramp", "Ramp", "Ramp Left", "Ramp Right", "Ramp Mid"};
	["Hydra Slope"] = {"Ramp", "Ramp", "Ramp", "Ramp Left", "Ramp Right", "Ramp Mid"};
	["Sugar Boost"] = {"Ramp", "Ramp", "Ramp", "Ramp Left", "Ramp Right", "Ramp Mid"};
}

local getMapNumber = {["Ramps"] = 0; ["Quick Move"] = 0; ["Sky Fall"] = 0; ["Sonic Speed"] = 0; ["Hydra Slope"] = 0; ["Sugar Boost"] = 0;}
local currentlyGenerating = {false, false, false, false, false}
--local getMapName = {"Ramps", "QuickMove", "SkyFall", "Sonic Speed", "Hydra Slope", "SugarBoost"}
local rampList = {["Ramp"] = 0, ["Ramp Left"] = 0 , ["Ramp Right"] = 0}
local rampJumpList = {["Ramp Jump"] = 0; ["Ramp Jump Left"] = 0; ["Ramp Jump Right"] = 0;}
local prevObjs
local prevObj
local lastCheckPoint = {0,0,0,0,0}
local lastObj = {}
local checkpoint = 0
local displacement = CFrame.new(0, 0, 0)
local mapNumber = 1

local coin = game.ServerStorage.Coin

local function randomObstacle(map)
	local index = math.random(2, #mapInfo[map])
	return {index, mapInfo[map][index]}
end

local function randomRamp(map)
	local index = math.random(1, #rampInfo[map])
	return {index, rampInfo[map][index]}
end

local function createObstacle(map, obstacleName, isSpawnPoint)
	local obstacle = game.ServerStorage.Obstacles:FindFirstChild(obstacleName):Clone()
	
	if obstacle:FindFirstChild("PreRamp") then
		if prevObj.Name == "Gap" then
			for i = 0, obstacle.PreRamp.Value, 1 do
				local ramp = randomRamp(map.Name)
				createObstacle(map, ramp[2], isSpawnPoint)
			end
		end
	end
	
	if obstacleName == "Gap" then 
		displacement = CFrame.new(0, -2, 0)
	else
		displacement = CFrame.new(0, 0, 0)
	end
	if obstacle and obstacle:FindFirstChild("Load Point") and obstacle:FindFirstChild("End Point") then
		if rampJumpList[obstacleName] == nil or math.random(1, 3) == 3 then
			obstacle["Load Point"].Transparency = 1
			obstacle["End Point"].Transparency = 1
			obstacle.PrimaryPart = obstacle["Load Point"]
			obstacle:SetPrimaryPartCFrame(prevObj["End Point"].CFrame * displacement)
			if not isSpawnPoint then
				obstacle.Parent = map.Obstacles
			else
				obstacle.Parent = map.SpawnPoint
			end
			
			prevObj = obstacle
				--Checkpoint
			if rampList[obstacleName] == nil and obstacleName ~= "Gap" then --Filter out obstacles that don't add to your checkpoint
				local checkPoint = obstacle["End Point"]:Clone()
				checkPoint.Transparency = 1
				--checkpoint = checkpoint + 1
				lastCheckPoint[mapNumber] = lastCheckPoint[mapNumber] + 1
				checkPoint.Name = lastCheckPoint[mapNumber]
				checkPoint.Size = checkPoint.Size + Vector3.new(0, 1000, map["Load Point"].Size.Z * 1.5)
				checkPoint.CFrame = checkPoint.CFrame * CFrame.new(0, 500, 0)
				checkPoint.Parent = map.Checkpoints
				
				local startPoint = Instance.new("ObjectValue", checkPoint)
				startPoint.Value = obstacle["Load Point"]
			end
		--
		end
		
		if obstacle:FindFirstChild("BaseGap") then
			
			for loop = 0, obstacle.BaseGap.Value, 1 do
				createObstacle(map, "Gap", isSpawnPoint)
			end
			
			local gapCheckpoint = 1.4
			
			if math.floor(lastCheckPoint[mapNumber] * 0.11) > 0 then
				--for loop = 1, math.floor(checkpoint * 0.1), 1 do
					createObstacle(map, "Gap", isSpawnPoint)
				--end
			end
		end
	end
	
	if obstacle:FindFirstChild("SubRamp") then
		for i = 0, obstacle.SubRamp.Value, 1 do
			createObstacle(map, "Ramp", isSpawnPoint)
		end
	end
	if obstacle:FindFirstChild("RewardSpawns") then
		local spawns = obstacle.RewardSpawns:GetChildren()
		local randCoin = coin:Clone()
		randCoin.CFrame = spawns[math.random(1, #spawns)].CFrame 
		randCoin.Parent = obstacle
	end
end

function generateObstacle(map) 
	local chosenObj
	if lastCheckPoint[mapNumber] == 10 or (lastCheckPoint[mapNumber] - 4) % 16 == 0 then 
		chosenObj = "Lava Tunnel"
	else
		repeat 
			chosenObj = randomObstacle(map.Name)[2]
		until chosenObj ~= prevObj.Name
	end
	if game.ServerStorage.Obstacles:FindFirstChild(chosenObj):FindFirstChild("Repetitions") then
		for i = 1, game.ServerStorage.Obstacles:FindFirstChild(chosenObj).Repetitions.Value, 1 do
			createObstacle(map, chosenObj, false)
		end
	else
		createObstacle(map, chosenObj, false)
	end
end

for mapName, _ in pairs(mapInfo) do
	if maps:FindFirstChild(mapName) and #mapInfo[mapName] > 0 then
		prevObjs = {}
		local mapSpawn = {"Lava Tunnel", randomObstacle(mapName)[2], randomObstacle(mapName)[2], "Lava Tunnel"}
		local map = maps:FindFirstChild(mapName)
		local spawnPoint = game.ServerStorage.Obstacles.Spawnpoint:Clone()
		spawnPoint:SetPrimaryPartCFrame(map["Load Point"].CFrame)
		spawnPoint.Parent = map.SpawnPoint
		
		prevObj = spawnPoint
		--checkpoint = 0
		
		for __, spawnObstacle in pairs(mapSpawn) do
			createObstacle(map, spawnObstacle, true)
		end

		for obstacles = 0, 20, 1 do 
			generateObstacle(map)
			--wait()
			--[[
			local chosenObj
			if lastCheckPoint[mapNumber] == 10 or (lastCheckPoint[mapNumber] - 4) % 16 == 0 then 
				chosenObj = "Lava Tunnel"
			else
				repeat 
					chosenObj = randomObstacle(map.Name)[2]
				until chosenObj ~= prevObj.Name
			end
			if game.ServerStorage.Obstacles:FindFirstChild(chosenObj):FindFirstChild("Repetitions") then
				for i = 1, game.ServerStorage.Obstacles:FindFirstChild(chosenObj).Repetitions.Value, 1 do
					createObstacle(map, chosenObj, false)
				end
			else
				createObstacle(map, chosenObj, false)
			end]]
		end
		lastObj[mapNumber] = prevObj
		getMapNumber[mapName] = mapNumber
		mapNumber = mapNumber + 1
		
		local localHighscore = map.LocalHighscore
		--print(map, localHighscore.Value)
		localHighscore.Changed:Connect(function(val)
			mapNumber = getMapNumber[localHighscore.Parent.Name]
			if lastCheckPoint[mapNumber] - 10 == val and not currentlyGenerating[mapNumber] then
				currentlyGenerating[mapNumber] = true
				prevObj = lastObj[mapNumber]
				for i = 1, 10 do 
					generateObstacle(localHighscore.Parent)
				end
				lastObj[mapNumber] = prevObj
				currentlyGenerating[mapNumber] = false
			end
		end)

		--lastObj = prevObjs[#prevObjs]
	end
end

game.Workspace.Server.Value = true