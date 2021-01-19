local DS2 = require(game.ServerScriptService.Modules:WaitForChild("DatastoreModule"))
local giveMod = require(game.ServerScriptService.Modules.GiveItem)
local itemMod = require(game.ReplicatedStorage.Modules.itemInfo)
local dsNames = require(game.ServerScriptService.Modules.DatastoreNames)
local shortcuts = require(game.ServerScriptService.Modules.Shortcuts)
local mapMod = require(game.ReplicatedStorage.Modules.mapInfo)
local bs = game:GetService("BadgeService")
local mps = game:GetService("MarketplaceService")

local rewardRE = game.ReplicatedStorage.REs.DailyRewards
local gamepassList = {["Double Coins"] = 7854576; ["Unlock Maps"] = 7854601;}

--local dailyRewardOrder = {{"Coins", 50}; {"Coins", 100}; {"Coins", 150}; {"Gems", 5}; {"Gems", 10}; {"Item", {"Rainbow Trail", "Rainbow Glow", "Lava Texture"}}}
local dailyRewardOrder = {{"Gems", 10}; {"Gems", 20}; {"Gems", 30}; {"Gems", 40}; {"Gems", 50};}
local badgeList = {["New Player"] = 2124498424; ["Stylish"] = 2124498425; ["Novice Surfer"] = 2124498427; ["New Heights"] = 2124498428; ["Veteran"] = 2124498507;}
--Join game, equip all, 50 pts, 250 pts, 100 games


local day = 86400

local storeName = dsNames.getMainStore()

game.Players.PlayerAdded:Connect(function(plr)
	local statsStore = DS2(storeName, plr)
	local savedStats = statsStore:GetTable({game.Workspace.Version.Value, 50, 75, 0, {"No Particle", "No Trail", "Default Marble", "Baller", "Force Field"}, {["Trail"] = "No Trail", ["Particle"] = "No Particle", ["Marble"] = "Default Marble"}, {["Ramps"] = {0, 0}}, {os.time(), 1}, true, {false, 0.5}, {} }) --coins, gems, inventory, equipped:{trail, particles, marble}, maps:{ownership, attempts, high score}, daily:{prev reward time, streak}, first join, music settings, hats
	
	local versionSave = savedStats[1]
	local currency1Save = savedStats[2]
	local currency2Save = savedStats[3]
	local specialEvent = savedStats[4]
	local inventorySave = savedStats[5]
	local equippedSave = savedStats[6]
	local mapSave = savedStats[7]
	local prevDailyReward = savedStats[8]
	local firstTime = savedStats[9]
	local musicSettings = savedStats[10]
	local hats = savedStats[11]
	
	local function saveStats()
		statsStore:Set({versionSave, currency1Save, currency2Save, specialEvent, inventorySave, equippedSave, mapSave, prevDailyReward, firstTime, musicSettings, hats})
	end
	
	if game.Workspace.Version.Value ~= versionSave then
		versionSave = game.Workspace.Version.Value
		--prompt the update message
	end
	
	local stats = Instance.new("Folder")
	stats.Name = "stats"
	stats.Parent = plr
	--Current Game Stats
	local curMap = Instance.new("ObjectValue")
	curMap.Name = "Map"
	curMap.Parent = stats
	
	local curScore = Instance.new("IntValue")
	curScore.Name = "Score"
	curScore.Value = 0
	curScore.Parent = stats
	
	--Saveable Stats
	local currency1 = Instance.new("IntValue")
	currency1.Value = currency1Save
	currency1.Name = "Coins"
	currency1.Parent = stats
	
	local currency2 = Instance.new("IntValue")
	currency2.Value = currency2Save
	currency2.Name = "Gems"
	currency2.Parent = stats
	
	local mute = Instance.new("BoolValue")
	mute.Value = musicSettings[1]
	mute.Name = "Mute"
	mute.Parent = stats
	
	local volume = Instance.new("NumberValue")
	volume.Value = musicSettings[2]
	volume.Name = "Volume"
	volume.Parent = stats
	
	local mapInfo = Instance.new("Folder")
	mapInfo.Name = "Maps"
	mapInfo.Parent = stats
	
	local gamepasses = Instance.new("Folder")
	gamepasses.Name = "Gamepasses"
	gamepasses.Parent = plr
	
	local hasBadge1 = bs:UserHasBadgeAsync(plr.UserId, badgeList["New Player"])
	local hasBadge2 = bs:UserHasBadgeAsync(plr.UserId, badgeList["Stylish"])
	local hasBadge3 = bs:UserHasBadgeAsync(plr.UserId, badgeList["Novice Surfer"])
	local hasBadge4 = bs:UserHasBadgeAsync(plr.UserId, badgeList["New Heights"])
	local hasBadge5 = bs:UserHasBadgeAsync(plr.UserId, badgeList["Veteran"])
	
	for map, info in pairs(mapSave) do
		if game.Workspace.Maps:FindFirstChild(map) then
			
			local highScore, attempts = shortcuts.createMapInfo(plr, map, info[1], info[2])
			
			attempts:GetPropertyChangedSignal("Value"):Connect(function()
				mapSave[map][1] = attempts.Value
				saveStats()
				if attempts.Value >= 100 and not hasBadge5 then
					hasBadge5 = true
					bs:AwardBadge(plr.UserId, badgeList["Veteran"])
				end
			end)
			
			highScore:GetPropertyChangedSignal("Value"):Connect(function()
				--if highScore.Value > mapSave[map][2] then
					mapSave[map][2] = highScore.Value
					saveStats()
				--else
				--	print("datastore error...")
				--end
				if highScore.Value >= 50 and not hasBadge3 then
					hasBadge3 = true
					bs:AwardBadge(plr.UserId, badgeList["Novice Surfer"])
				end
				if highScore.Value >= 250 and not hasBadge4 then
					hasBadge4 = true
					bs:AwardBadge(plr.UserId, badgeList["New Heights"])
				end
			end)
			
			plr.RespawnLocation = game.Workspace.Maps:FindFirstChild(map).Spawn
			
		end
	end
	
	mapInfo.ChildAdded:Connect(function(map)
		if game.Workspace.Maps:FindFirstChild(map.Name) then
			
			if map:FindFirstChild("Attempts") and map:FindFirstChild("HighScore") then
				map.Attempts:GetPropertyChangedSignal("Value"):Connect(function()
					mapSave[map.Name][1] = map.Attempts.Value
					saveStats()
				end)	
				
				map.HighScore:GetPropertyChangedSignal("Value"):Connect(function()
					mapSave[map.Name][2] = map.HighScore.Value
					saveStats()
				end)
				
				mapSave[map.Name] = {map.Attempts.Value, map.HighScore.Value}
				
				for _, WSmap in pairs(game.Workspace.Maps:GetChildren()) do
					if not mapInfo:FindFirstChild(WSmap.Name) then --If they don't have a map
						
						local mapReq, scoreReq = mapMod.getRequirements(WSmap.Name)
						
						if mapInfo:FindFirstChild(mapReq) then
							
							local mapValue = mapInfo:FindFirstChild(mapReq)
							
							mapValue.HighScore:GetPropertyChangedSignal("Value"):Connect(function()
								if mapValue.HighScore.Value >= scoreReq then
									mapMod.rewardMap(plr, WSmap.Name)
								end
							end)
						end
						
					end
				end
				
			end
		end
	end)
	
	for _, WSmap in pairs(game.Workspace.Maps:GetChildren()) do
		if not mapInfo:FindFirstChild(WSmap.Name) then --If they don't have a map
			
			local mapReq, scoreReq = mapMod.getRequirements(WSmap.Name)
			
			if mapInfo:FindFirstChild(mapReq) then
				
				local mapValue = mapInfo:FindFirstChild(mapReq)
				
				mapValue.HighScore:GetPropertyChangedSignal("Value"):Connect(function()
					if mapValue.HighScore.Value >= scoreReq then
						mapMod.rewardMap(plr, WSmap.Name)
					end
				end)
			end
			
		end
	end
	
	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = stats
	
	for _, item in pairs(inventorySave) do
		giveMod.Give(plr, item)
	end
	
	inventory.ChildAdded:Connect(function(item)
		table.insert(inventorySave, item.Name)
		saveStats()
	end)
	
	local equipped = Instance.new("Folder")
	equipped.Name = "Equipped"
	equipped.Parent = stats
	
	for category, value in pairs(equippedSave) do
		local storage = Instance.new("StringValue")
		storage.Name = category
		if inventory:FindFirstChild(value) then
			storage.Value = value
		else
			storage.Value = nil
		end
		storage.Parent = equipped
		storage:GetPropertyChangedSignal("Value"):Connect(function()
			equippedSave[category] = storage.Value
			saveStats()
			if not hasBadge2 and equipped.Marble.Value and equipped.Marble.Value ~= "Default Marble" and equipped.Particle.Value and equipped.Particle.Value ~= "No Particle" and equipped.Trail.Value and equipped.Trail.Value ~= "No Trail" then
				hasBadge2 = true
				bs:AwardBadge(plr.UserId, badgeList["Stylish"])
			end
		end)
	end
	
	if os.time() - prevDailyReward[1] >= day and os.time() - prevDailyReward[1] <= day * 2 then
		
		local rewardIndex = prevDailyReward[2] % #dailyRewardOrder + 1
		
		--if rewardIndex == 0 then rewardIndex = 1 end
		
		local reward = dailyRewardOrder[rewardIndex]
		
		if type(reward[2]) == "table" then
			reward[1] = reward[1][math.random(1, #reward[2])]
			reward[2] = 1
		end
		
		giveMod.Give(plr, reward[1], reward[2])
		prevDailyReward[2] = rewardIndex
		prevDailyReward[1] = os.time()
		saveStats()
		
		rewardRE:FireClient(plr, rewardIndex)--fire the remote to prompt the reward gui
	elseif os.time() - prevDailyReward[1] >= day * 2 or firstTime then
		prevDailyReward[2] = 1
		prevDailyReward[1] = os.time()
		giveMod.Give(plr, dailyRewardOrder[prevDailyReward[2]][1], dailyRewardOrder[prevDailyReward[2]][2])
		saveStats()
		rewardRE:FireClient(plr, 1)--fire the remote to prompt the reward gui
	end
	
	currency1:GetPropertyChangedSignal("Value"):Connect(function()
		currency1Save = currency1.Value
		saveStats()
	end)
	
	currency2:GetPropertyChangedSignal("Value"):Connect(function()
		currency2Save = currency2.Value
		saveStats()
	end)
	
	mute:GetPropertyChangedSignal("Value"):Connect(function()
		musicSettings[1] = mute.Value
		saveStats()
	end)
	
	volume:GetPropertyChangedSignal("Value"):Connect(function()
		musicSettings[2] = volume.Value
		saveStats()
	end)
	
	if firstTime or plr.Name == "WildAsians" then
		if not hasBadge1 then
			hasBadge1 = true
			bs:AwardBadge(plr.UserId, badgeList["New Player"])
		end
		firstTime = false
		--prompt the update message
		plr.RespawnLocation = game.Workspace.Maps.Ramps.Spawn
		game.ReplicatedStorage.REs.TutorialRE:FireClient(plr)
	end
	
	for i, v in pairs(gamepassList) do
		if mps:UserOwnsGamePassAsync(plr.UserId, v) then
			shortcuts.createGamepass(plr, i)
		end
	end
end)
