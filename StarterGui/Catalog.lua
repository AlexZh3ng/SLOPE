local plr = game.Players.LocalPlayer
local stats = plr:WaitForChild("stats")
local inventory = stats:WaitForChild("Inventory")
local menus = script.Parent.MainUI.Menus
local menu = menus.Catalog
local rf = game.ReplicatedStorage.REs.BuyItem
local visuals = game.Workspace.localVisuals

local itemMod = require(game.ReplicatedStorage.Modules.itemInfo)
local catalogMod = require(game.ReplicatedStorage.Modules.catalogChange)
local particleMod = require(game.ReplicatedStorage.Modules.particleMaker)
local soundMod = require(game.ReplicatedStorage.Modules.soundHandler)

--Initial seed
local dateInfo = os.date("!*t", os.time())
local day = dateInfo.year..dateInfo.month..dateInfo.day
local seed = math.randomseed(day)
--

--Dev products
local mps = game:GetService("MarketplaceService")
local purchases = { --Unnecessary to have 3 different dev products but just for name of dev product/future price changes
	["Marble"] = 724737220;
	["Particle"] = 724734894;
	["Trail"] = 724734316;
}
local re = game.ReplicatedStorage.REs.Equip
--

local currentShopDay = nil

local function setupShop()
	local itemList = math.random(1, #catalogMod.getCatalogList())
	--Previous
	seed = math.randomseed(day - 1)
	local prevList = math.random(1, #catalogMod.getCatalogList())
	--New, make sure not equal to previous
	seed = math.randomseed(day)
	local newList = math.random(1, #catalogMod.getCatalogList())
	if newList == prevList then
		if newList == #catalogMod.getCatalogList() then
			newList = newList - 1
		elseif newList == 1 then
			newList = newList + 1
		else
			newList = newList - 1
		end
	end
	--Clear all the old items
	for _, label in pairs(menu.ItemList:GetChildren()) do
		if label:IsA("Frame") then
			label:Destroy()
		end
	end
	visuals.Shop:ClearAllChildren()
	local itemList = catalogMod.getItemList(newList)
	for i, item in pairs(itemList) do
		
		local itemInfo = itemMod.getItem(item)
		local label = game.ReplicatedStorage.Assets.ShopLabel:Clone()
		local assetClone = game.ReplicatedStorage.Items:FindFirstChild(itemInfo.ItemCategory):FindFirstChild(itemInfo.ItemName):Clone() 
		local viewportCamera = Instance.new("Camera", label.ViewportFrame)
		if plr.stats.Inventory:FindFirstChild(item) then
			label.BuyButton.Text = "Owned"
		else
			label.BuyButton.Text = itemInfo.Cost[2].." "..itemInfo.Cost[1]
			
			label.Buy.MouseButton1Down:Connect(function()
				if plr.stats.Inventory:FindFirstChild(item) then return end
				if plr.stats:FindFirstChild(itemInfo.Cost[1]).Value < itemInfo.Cost[2] then 
					re:FireServer("Unowned", itemInfo.ItemName)
					mps:PromptProductPurchase(plr, purchases[itemInfo.ItemCategory])
					--[[prompt the developer product purchase]] 
					return 
				end
				
				local status = rf:InvokeServer(item)
				print(status)
				if status == "Owned" then
					label.BuyButton.Text = status
				end
			end)
		end
		
		label.Name = itemInfo.ItemName
		label.ItemCategory.Text = itemInfo.ItemCategory
		label.ItemName.Text = itemInfo.ItemName
		
		label.Parent = menu.ItemList
		
		label.ViewportFrame.CurrentCamera = viewportCamera
		assetClone.Parent = label.ViewportFrame
		viewportCamera.CFrame = CFrame.new(Vector3.new(0, 2, 12), assetClone.Position)
		viewportCamera.FieldOfView = 3
		
		--Create 2d visual instances of particle emitters/trails
		particleMod.createInstance(itemInfo.ItemCategory, itemInfo.ItemName, visuals.Shop, i)
		if itemInfo.ItemCategory == "Trail" then
			label.ViewportFrame:Destroy()
		end
	end
	currentShopDay = day
end

setupShop()

spawn(function()
	while true do
		wait(1)
		
		dateInfo = os.date("!*t", os.time())
		day = dateInfo.year..dateInfo.month..dateInfo.day
		seed = math.randomseed(day)
		if day ~= currentShopDay then
			setupShop()
		end
		
		local hours = (23 - dateInfo.hour)
		local minutes = (59 - dateInfo.min)
		local seconds = (59 - dateInfo.sec)
		
		if string.len(seconds) == 1 then
			seconds = "0"..seconds
		end
		if string.len(minutes) == 1 then
			minutes = "0"..minutes
		end
		if string.len(hours) == 1 then
			hours = "0"..hours
		end
		
		menu.Header.Timer.Text = "Shop change in "..hours..":"..minutes..":"..seconds
		
	end
end)

menu.Header.Coins.Text = stats.Coins.Value
menu.Header.Gems.Text = stats.Gems.Value

stats.Coins:GetPropertyChangedSignal("Value"):Connect(function()
	menu.Header.Coins.Text = stats.Coins.Value
end)

stats.Gems:GetPropertyChangedSignal("Value"):Connect(function()
	menu.Header.Gems.Text = stats.Gems.Value
end)

stats.Inventory.ChildAdded:Connect(function(child) --For dev product purchases
	soundMod.playSound("CashRegister")
	if menu.ItemList:FindFirstChild(child.Name) then
		menu.ItemList:FindFirstChild(child.Name).BuyButton.Text = "Owned"
	end
end)