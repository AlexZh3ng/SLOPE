local codeMenu = script.Parent:WaitForChild("MainUI").Menus.Codes.Info
local input = codeMenu.CodeBox
local submit = codeMenu.Submit
local rf = game.ReplicatedStorage.REs.SubmitCode

submit.MouseButton1Down:Connect(function()
	local codeStatus = rf:InvokeServer(input.Text)
	input.Text = ""
	input.PlaceholderText = codeStatus
end)