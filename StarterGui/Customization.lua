local plr = game.Players.LocalPlayer
local stats = plr:WaitForChild("stats")
local inventory = stats:WaitForChild("Inventory")
local equipped = stats:WaitForChild("Equipped")
local menuMod = require(game.ReplicatedStorage.Modules.menuHandler)
local particleMod = require(game.ReplicatedStorage.Modules.particleMaker)
local menus = script.Parent.MainUI.Menus
local menu = menus.Customize
local itemList = menu.ItemList
local visuals = game.Workspace:WaitForChild("localVisuals")

local marbleViewport = itemList.Marble.ViewportFrame

local mps = game:GetService("MarketplaceService")

local currentEquips = {
	["Marble"] = "";
	["Particle"] = "";
	["Trail"] = "";
}

local purchases = { --Unnecessary to have 3 different dev products but just for name of dev product/future price changes
	["Marble"] = 724737220;
	["Particle"] = 724734894;
	["Trail"] = 724734316;
	}
local inventoryMenus = {menus.Marble, menus.Particle, menus.Trail}


function createViewport(name, parent)
	local assetClone = game.ReplicatedStorage.Items.Marble:FindFirstChild(name):Clone() 
	assetClone.Parent = parent
	local marbleCamera = Instance.new("Camera", parent) --Must create new instance because camera don't duplicate in startergui
	marbleCamera.FieldOfView = 45
	marbleCamera.CFrame = assetClone.CFrame * CFrame.new(0, 0, 12)
	parent.CurrentCamera = marbleCamera
end

--Defaults 
createViewport(equipped.Marble.Value, marbleViewport)
particleMod.createInstance("Particle", equipped.Particle.Value, visuals.Customization, 2)
particleMod.createInstance("Trail", equipped.Trail.Value, visuals.Customization, 1)

for i, category in pairs(equipped:GetChildren()) do
	if category:IsA("ValueBase") then
		currentEquips[category.Name] = category.Value
		category:GetPropertyChangedSignal("Value"):Connect(function()
			itemList:FindFirstChild(category.Name).ItemLabel.Text = category.Value
			if category.Name == "Marble" then
				marbleViewport:ClearAllChildren()
				createViewport(category.Value, marbleViewport)
			else
				particleMod.createInstance(category.Name, category.Value, visuals.Customization, i)
				equipped = visuals.Customization:FindFirstChild(currentEquips[category.Name])
				if equipped then equipped:Destroy() end
			end
			currentEquips[category.Name] = category.Value
		end)
	end
end

for _, itemFrame in pairs(itemList:GetChildren()) do
	if itemFrame:FindFirstChild("Select") and itemFrame:FindFirstChild("ItemLabel") then
		itemFrame.ItemLabel.Text = equipped:FindFirstChild(itemFrame.Name).Value
		itemFrame.Select.MouseButton1Down:Connect(function()
			if menus:FindFirstChild(itemFrame.Name) then
				menuMod.openMenu(itemFrame.Name, false)
			end
		end)
	end
end

local itemMenus = {menus.Marble, menus.Particle, menus.Trail}
local re = game.ReplicatedStorage.REs.Equip
local itemModule = require(game.ReplicatedStorage.Modules.itemInfo)

for _, itemInfo in pairs(itemModule.getAllItems()) do
	
	local category = itemInfo.ItemCategory
	
	local itemLabel = game.ReplicatedStorage.Assets.ItemLabel:Clone()
	itemLabel.ItemName.Text = itemInfo.ItemName
	itemLabel.Name = itemInfo.ItemName
	itemLabel.Parent = menus:FindFirstChild(category):FindFirstChild("ItemList")
	
	itemLabel.Equip.MouseButton1Down:Connect(function()
		if inventory:FindFirstChild(itemInfo.ItemName) then
			menuMod.openMenu("Back", false)
			re:FireServer("Equip", itemInfo.ItemName)
		else
			re:FireServer("Unowned", itemInfo.ItemName)
			mps:PromptProductPurchase(plr, purchases[category])
		end
	end)
end

for i, item in pairs(inventory:GetChildren()) do
	local info = itemModule.getItem(item.Name)
	local category = info.ItemCategory
	
	if menus[category].ItemList:FindFirstChild(item.Name) then
		frame = menus[category].ItemList:FindFirstChild(item.Name)
		frame.ItemName.BackgroundColor3 = Color3.new(189/255, 252/255, 1)
	end
end

for _, category in pairs(inventoryMenus) do
	local count = 0
	for i, item in pairs(category.ItemList:GetChildren()) do
		if item:IsA("Frame") then
			if item.Name == "Default Marble" or item.Name == "No Particle" or item.Name == "No Trail" then
				item.LayoutOrder = 0
			else
				count = count + 1
				item.LayoutOrder = count
			end
			if category.Name == "Marble" then
				createViewport(item.Name, item.ViewportFrame)
			else
				particleMod.createInstance(category.Name, item.Name, visuals.Inventory:FindFirstChild(category.Name), count)
			end
		end
	end
end

inventory.ChildAdded:Connect(function(item)
	local info = itemModule.getItem(item.Name)
	local category = info.ItemCategory
	
	if menus[category].ItemList:FindFirstChild(item.Name) then
		menus[category].ItemList:FindFirstChild(item.Name).ItemName.BackgroundColor3 = Color3.new(189/255, 252/255, 1)
	end
end)