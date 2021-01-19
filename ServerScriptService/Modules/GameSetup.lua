local module = {}

local ts = game:GetService("TweenService")
local gameInfo = require(game.ReplicatedStorage.Modules.gameInfo):getInfo()
local mapInfo = require(game.ReplicatedStorage.Modules.mapInfo)
local mps = game:GetService("MarketplaceService")
local itemInfo = require(game.ReplicatedStorage.Modules.itemInfo)

local gameEvent = game.ReplicatedStorage.REs.GameChange
local coinEvent = game.ReplicatedStorage.REs.Coin


local coinMultiplier = 1
local coinGamepass = 1

local gameData = {}

function module.start(hit, map, spawnPoint, attempt, lastSpeed)
	if not hit.Parent then return end
	if not game.Players:GetPlayerFromCharacter(hit.Parent) then return end
	if game.Workspace.Marbles:FindFirstChild(hit.Parent.Name) then return end
	
	local chr = hit.Parent
	local plr = game.Players:GetPlayerFromCharacter(chr)
	if not plr.stats.Maps:FindFirstChild(map.Name) then mps:PromptProductPurchase(plr, mapInfo.getDeveloperProduct(map.Name)) chr.HumanoidRootPart.CFrame = map.Spawn.CFrame * CFrame.new(0, 3, 0) return end
	if game.Workspace.Marbles:FindFirstChild(chr.Name) then return end
	gameEvent:FireClient(game.Players:GetPlayerFromCharacter(hit.Parent), "Transparency", map.Name)
	if lastSpeed < gameInfo.Speed then
		lastSpeed = gameInfo.Speed
	end
	chr.HumanoidRootPart.CFrame = map.Spawn.CFrame * CFrame.new(0, 3, 0)
	
	plr.stats.Maps[map.Name].Attempts.Value = plr.stats.Maps[map.Name].Attempts.Value + 1
	
	plr.stats.Map.Value = map
	plr.RespawnLocation = map.Spawn
	gameData[plr.Name] = {hit, map}
	--Marble Setup
	local marble = game.ServerStorage.Marble:Clone()
	marble.Name = chr.Name
	marble.Parent = game.Workspace.Marbles
	marble:SetNetworkOwner(plr)
	local nameTag = game.ReplicatedStorage.Assets.BillboardGui:Clone()
	nameTag.Parent = marble
	nameTag.PlayerToHideFrom = plr 
	nameTag.Username.Text = plr.Name
	
	local checkPointY = spawnPoint.Position.Y
	
	for _, equipped in pairs(plr.stats.Equipped:GetChildren()) do
		if equipped.Value ~= nil and plr.stats.Inventory:FindFirstChild(equipped.Value) then
			local info = itemInfo.getItem(equipped.Value)
			local instances = info["ItemInstance"]
			for _, obj in pairs(instances) do
				local clone = obj:Clone()
				clone.Parent = marble
				if clone:IsA("Trail") then
					clone.Attachment0 = marble.TopAttach
					clone.Attachment1 = marble.BotAttach
				end
			end
		end
	end
	
	local hasGamepass = plr.Gamepasses:FindFirstChild("Double Coins")
	if hasGamepass then
		coinGamepass = 2
	end
	
	gameEvent:FireClient(plr, "Start")
	--Interactions
	local function playerDied()
		if marble:FindFirstChild("AngularVelocity") then
			if marble.AngularVelocity.AngularVelocity.Z < lastSpeed then
				marble.AngularVelocity.AngularVelocity = Vector3.new(0, 0,lastSpeed)
			end
			gameData[plr.Name][3] = marble.AngularVelocity.AngularVelocity.Z
		else
			gameData[plr.Name][3] = 70	
		end
		gameEvent:FireClient(plr, "Died")
		chr.HumanoidRootPart.CFrame = map.Spawn.CFrame * CFrame.new(0, 3, 0)
		marble:Destroy()
	end
	
	local function checkDied()
		if checkPointY - marble.Position.Y >= 2000 then
			playerDied()
			print(marble.Position.Y)
			return true
		end
	end
	marble.Touched:Connect(function(hit)
		if plr ~= nil and plr.Parent ~= nil then
			if tonumber(hit.Name) == plr.stats.Score.Value + 1 and hit:IsDescendantOf(map.Checkpoints) then
				plr.stats.Score.Value = tonumber(hit.Name)
				if plr.stats.Maps:FindFirstChild(map.Name) and plr.stats.Maps[map.Name].HighScore.Value < plr.stats.Score.Value then
					plr.stats.Maps[map.Name].HighScore.Value = plr.stats.Score.Value
				end
				if plr.stats.Score.Value > map.LocalHighscore.Value then 
					map.LocalHighscore.Value = plr.stats.Score.Value
				end
				checkPointY = hit.Position.Y - 500
				marble.AngularVelocity.AngularVelocity = marble.AngularVelocity.AngularVelocity + Vector3.new(0, 0, (gameInfo.desiredVelocity-marble.AngularVelocity.AngularVelocity.Z)/50)
			elseif hit.Name == "Speed" and (hit:IsDescendantOf(map.Obstacles) or hit:IsDescendantOf(map.SpawnPoint)) then
				gameEvent:FireClient(plr, "Sound", "SpeedBoost")
				marble.AngularVelocity.AngularVelocity = marble.AngularVelocity.AngularVelocity *gameInfo.SpeedBoost--+ Vector3.new(0, 0, gameInfo.SpeedBoost)
				wait(gameInfo.BoostTime)
				if marble ~= nil and marble:FindFirstChild("AngularVelocity") then
					marble.AngularVelocity.AngularVelocity = marble.AngularVelocity.AngularVelocity *gameInfo.SpeedBoost--+ Vector3.new(0, 0, -gameInfo.SpeedBoost)
				end
			elseif hit.Name == "Slow" and (hit:IsDescendantOf(map.Obstacles) or hit:IsDescendantOf(map.SpawnPoint)) then
				--marble.AngularVelocity.AngularVelocity = marble.AngularVelocity.AngularVelocity / gameInfo.SlowBoost
				--wait(gameInfo.BoostTime)
				if marble ~= nil and (hit:IsDescendantOf(map.Obstacles) or hit:IsDescendantOf(map.SpawnPoint)) then
					marble.AngularVelocity.AngularVelocity = marble.AngularVelocity.AngularVelocity *gameInfo.SlowBoost
				end
			elseif hit.Name == "Coin" then
				gameEvent:FireClient(plr, "Sound", "Coin")
				local coinsEarned = 1 * coinMultiplier * coinGamepass
				plr.stats.Coins.Value = plr.stats.Coins.Value + coinsEarned
				coinEvent:FireClient(plr, hit, coinsEarned)
			elseif hit.Name == "Die" and (hit:IsDescendantOf(map.Obstacles) or hit:IsDescendantOf(map.SpawnPoint)) then
				playerDied()
				--plr.stats.Score.Value = 0
				--plr.stats.Map.Value = nil
			end
			if marble:FindFirstChild("AngularVelocity") and marble.AngularVelocity.AngularVelocity.Z > gameInfo.maxVelocity then 
				marble.AngularVelocity.AngularVelocity = Vector3.new(0, 0, gameInfo.maxVelocity)
			end
		end
	end)
	
	if attempt == "Start" then
		plr.stats.Score.Value = 0
		marble.CFrame = spawnPoint.CFrame
		marble.AngularVelocity.AngularVelocity = Vector3.new(0,0,gameInfo.Speed)
	elseif attempt == "Revive" then
		marble.CFrame = spawnPoint.CFrame * CFrame.new(-5, 0, 0)
		for speed = 1, lastSpeed do
			wait(20/lastSpeed)
			if checkDied() then break end
			if marble:FindFirstChild("AngularVelocity") then
				marble.AngularVelocity.AngularVelocity = Vector3.new(0, 0, speed)
			end
		end
	end
	
	while not checkDied() and marble do
		wait(.1)
	end
end

function module.getData(plr)
	return gameData[plr.Name]
end

return module