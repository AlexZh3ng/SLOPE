local mainGui = script.Parent.MainUI
local buttons = mainGui.Buttons
local menus = mainGui.Menus
local menuMod = require(game.ReplicatedStorage.Modules.menuHandler)

for _, button in pairs(buttons:GetChildren()) do
	if button:IsA("GuiObject") and menus:FindFirstChild(button.Name) then
		button.MouseButton1Down:Connect(function()
			menuMod.openMenu(button.Name, true)
		end)
	end
end

for _, menu in pairs(menus:GetChildren()) do
	if menu:FindFirstChild("Close") then
		menu.Close.MouseButton1Down:Connect(function()
			menuMod.closeMenu()
		end)
	elseif menu:FindFirstChild("Back") then
		menu.Back.MouseButton1Down:Connect(function()
			menuMod.openMenu("Back", false)
		end)
	end
end