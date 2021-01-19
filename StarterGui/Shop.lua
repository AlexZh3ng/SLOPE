local shop = script.Parent.MainUI.Menus.Shop
local header = shop.Header
local plr = game.Players.LocalPlayer

local mps = game:GetService("MarketplaceService")


local currency = {
	["25Gems"] = 724721169;
	["100Gems"] = 724722068;
	["250Gems"] = 724722845;
	["100Coins"] = 724724316;
	["500Coins"] = 724729092;
	["1000Coins"] = 724730137;
}

local gamepasses = {
	["Unlock Maps"] = 7854601;
	["Double Coins"] = 7854576;
}
function notVisible()
	shop.Money.Visible = false
	shop.Gamepasses.Visible = false
	shop.Specials.Visible = false
end

for i, v in pairs(header:GetChildren()) do
	if v:IsA("TextButton") then
		v.MouseButton1Down:Connect(function()
			notVisible()
			shop:FindFirstChild(v.Name).Visible = true
		end)
	end
end

for i, v in pairs(shop.Money:GetChildren()) do
	if v:FindFirstChild("Buy") then
		v.Buy.MouseButton1Down:Connect(function()
			mps:PromptProductPurchase(plr, currency[v.Name])
		end)
	end
end

for i, v in pairs(shop.Gamepasses:GetChildren()) do
	if v:FindFirstChild("Buy") then
		v.Buy.MouseButton1Down:Connect(function()
			mps:PromptGamePassPurchase(plr, gamepasses[v.Name])
		end)
	end
end

