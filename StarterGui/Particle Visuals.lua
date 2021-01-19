local catalogPositions = {
	CFrame.new(-26.5 , 6.5, -60),
	CFrame.new(-8.9 , 6.5, -60),
	CFrame.new(8.8, 6.5, -60),
	CFrame.new(26.4, 6.5, -60),
	CFrame.new(-26.5 , -10, -60),
	CFrame.new(-8.9 , -10, -60),
	CFrame.new(8.8, -10, -60),
	CFrame.new(26.4, -10, -60),
}

--Trail, particle
local customizePositions = {
	CFrame.new(15.5, 0, -40);
	CFrame.new(0, 0, -50);
}

local inventoryPositions = {
	CFrame.new(-18.5 , 20, -115);
	CFrame.new(4, 20, -115);
	CFrame.new(27, 20, -115);
	CFrame.new(49.5 , 20, -115);
	CFrame.new(-41.5 , -2, -115);
	CFrame.new(-18.5 , -2, -115);
	CFrame.new(4, -2, -115);
	CFrame.new(27, -2, -115);
	CFrame.new(49.5 , -2, -115);
	CFrame.new(-41.5 , -24.5, -115);
	CFrame.new(-18.5 , -24.5, -115);
	CFrame.new(4, -24.5, -115);
	CFrame.new(27, -24.5, -115);
	CFrame.new(49.5 , -24.5, -115);
	
	}

local randomPosition = CFrame.new(100000, 100000, 100000)
local menu = script.Parent.MainUI.Menus
local visuals = game.Workspace:WaitForChild("localVisuals")

function identifyPart(particle, i, list) 
	if particle:IsA("Model") then
		particle:SetPrimaryPartCFrame(workspace.CurrentCamera.CFrame * list[i])
	else
		particle.CFrame = workspace.CurrentCamera.CFrame * list[i]
	end
end

function moveElsewhere(particle)
	if particle:IsA("Model") then
		particle:SetPrimaryPartCFrame(randomPosition)
	else
		particle.CFrame = randomPosition
	end
end

game:GetService("RunService").RenderStepped:Connect(function()
	for i, particle in pairs(visuals.Shop:GetChildren()) do
		if menu.Catalog.Visible then
			identifyPart(particle, particle.Value.Value, catalogPositions)
		else
			moveElsewhere(particle)
		end
	end
	for i, particle in pairs(visuals.Customization:GetChildren()) do
		if menu.Customize.Visible then
			identifyPart(particle, particle.Value.Value, customizePositions)
		else
			moveElsewhere(particle)
		end
	end
	for i, particle in pairs(visuals.Inventory.Particle:GetChildren()) do
		if menu.Particle.Visible then
			identifyPart(particle, particle.Value.Value, inventoryPositions)
		else
			moveElsewhere(particle)
		end
	end
	for i, particle in pairs(visuals.Inventory.Trail:GetChildren()) do
		if menu.Trail.Visible then
			identifyPart(particle, particle.Value.Value, inventoryPositions)
		else
			moveElsewhere(particle)
		end
	end
end)