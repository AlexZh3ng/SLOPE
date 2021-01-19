local plr = game.Players.LocalPlayer
local maps = plr:WaitForChild("stats"):WaitForChild("Maps")
maps:WaitForChild("Ramps")
local mapMenu = script.Parent.MainUI.Menus.Maps
local mapOrder = mapMenu.MapList
local mapInfo = require(game.ReplicatedStorage.Modules.mapInfo)
local menuMod = require(game.ReplicatedStorage.Modules.menuHandler)
local mps = game:GetService("MarketplaceService")

local function createLabel(map)
	local physicalMap = game.Workspace.Maps:FindFirstChild(map.Name)
	if not physicalMap then return end
	physicalMap:WaitForChild("Start Point").SurfaceGui.Title.Text = map.Name
	physicalMap["Start Point"].SurfaceGui.Title.Shadow.Text = map.Name
	local label = game.ReplicatedStorage.Assets.MapLabel:Clone()
	label.Parent = mapOrder
	label.Tele.MouseButton1Down:Connect(function()
		plr.Character.HumanoidRootPart.CFrame = map.Spawn.CFrame * CFrame.new(0, 3, 0)
		menuMod.closeMenu()
	end)
	label.MapName.Text = map.Name
	label.LayoutOrder = mapInfo.getMapOrder(map.Name)
	
	if maps:FindFirstChild(map.Name) then
		physicalMap["Start Point"].SurfaceGui.Lock.Visible = false
		label.Lock.Visible = false
		local highScore = maps:FindFirstChild(map.Name).HighScore
		label.HighScore.Text = "High Score: "..highScore.Value
		
		highScore:GetPropertyChangedSignal("Value"):Connect(function()
			label.HighScore.Text = "High Score: "..highScore.Value
		end)
	else
		label.Lock.LockText.Text = string.upper(map.Name)
		local mapReq, scoreReq = mapInfo.getRequirements(map.Name)
		label.Lock.InfoText.Text = "Unlocked by getting a high score of "..scoreReq.." on "..mapReq
		physicalMap["Start Point"].SurfaceGui.Lock.InfoText.Text = "Unlocked by getting a high score of "..scoreReq.." on "..mapReq
		physicalMap["Start Point"].SurfaceGui.Lock.InfoText.Shadow.Text = "Unlocked by getting a high score of "..scoreReq.." on "..mapReq
		label.Lock.MouseButton1Down:Connect(function()
			mps:PromptProductPurchase(plr, mapInfo.getDeveloperProduct(map.Name))
		end)
		maps.ChildAdded:Connect(function(child)
			if child.Name == map.Name then
				label.Lock.Visible = false
				physicalMap["Start Point"].SurfaceGui.Lock.Visible = false
				local highScore = child:WaitForChild("HighScore")
				label.HighScore.Text = "High Score: "..highScore.Value
				label.LayoutOrder = mapInfo.getMapOrder(map.Name)
				highScore:GetPropertyChangedSignal("Value"):Connect(function()
					label.HighScore.Text = "High Score: "..highScore.Value
				end)
			end
		end)
	end
end

for _, map in pairs(game.Workspace.Maps:GetChildren()) do
	createLabel(map)
end