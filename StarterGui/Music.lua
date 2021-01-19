local ts = game:GetService("TweenService")
local plr = game.Players.LocalPlayer
local stats = plr:WaitForChild("stats")
local musicMenu = script.Parent.MainUI.Music
local buttons = musicMenu.Buttons
local music = game.ReplicatedStorage:WaitForChild("Music"):GetChildren()
local play = true
local mute = plr.stats.Mute.Value
local volume = plr.stats.Volume.Value

local i = 0
local currentSong
local tween 

local playImage = "http://www.roblox.com/asset/?id=3950724759"
local pauseImage = "http://www.roblox.com/asset/?id=3950723805"
local speakerImage = "rbxgameasset://Images/speaker (1)"
local muteImage = "rbxgameasset://Images/mute"

local re = game.ReplicatedStorage.REs.Music

function playSong() 
	if currentSong and currentSong.IsPlaying then currentSong:Stop() end 
	i = i % #music + 1
	currentSong = music[i]
	currentSong:Play()	
	currentSong.PlaybackSpeed = 1
	musicMenu.SongName.Text = currentSong.Name
	musicMenu.BarFill.Size = UDim2.new(0, 0, 0, 2)
	musicMenu.CurrentTime.Seconds.Value = 0
	musicMenu.CurrentTime.Minutes.Value = 0 
	local ti = TweenInfo.new(currentSong.TimeLength, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false)
	tween = ts:Create(musicMenu.BarFill, ti, {["Size"] = UDim2.new(musicMenu.Bar.Size.X.Scale, 0, 0, 2)})
	tween:Play()
	local seconds = math.floor(currentSong.TimeLength%60) 
	if seconds == 0 then
		seconds = "00"
	elseif seconds < 10 then
		seconds = "0"..tostring(seconds)
	else
		seconds = tostring(seconds)
	end
	musicMenu.SongTime.Text = tostring(math.floor(currentSong.TimeLength/60)) .. ":" .. seconds
end

function updateSound(length) 
	if length < 0 then 
		length = 0 
	elseif length > musicMenu.SoundBar.AbsoluteSize.X then
		length = musicMenu.SoundBar.AbsoluteSize.X 
	end 
	musicMenu.SoundBarFill.BackgroundColor3 = Color3.new(234, 234, 234)
	musicMenu.SoundBarFill.Size = UDim2.new(0, length, 0, 6)
	musicMenu.Speaker.Image = speakerImage
	volume = length/musicMenu.SoundBar.AbsoluteSize.X
	currentSong.Volume = volume
end

buttons.Play.MouseButton1Down:Connect(function()
	play = not play 
	if play then
		buttons.Play.Image = playImage
		tween:Play()
		currentSong:Resume()
	else
		buttons.Play.Image = pauseImage
		tween:Pause()
		currentSong:Pause()
	end
end)

buttons.Skip.MouseButton1Down:Connect(playSong)

buttons.Back.MouseButton1Down:Connect(function()
	if currentSong.TimePosition >= 4 then
		currentSong:Stop()
		currentSong:Play()
	else
		if i == 1 then
			i = #music - 1
		else
			i = i - 2
		end
		playSong()
	end
end)

local drag = false
local mouse = plr:GetMouse()
local left = musicMenu.SoundBar.AbsolutePosition.X
local right = left + musicMenu.SoundBar.AbsoluteSize.X

mouse.Button1Up:Connect(function()
	wait()
	drag = false
end)

musicMenu.Speaker.MouseButton1Down:Connect(function()
	mute = not mute
	if mute then
		currentSong.Volume = 0 
		musicMenu.Speaker.Image = muteImage
		musicMenu.SoundBarFill.BackgroundColor3 = musicMenu.SoundBar.BackgroundColor3
	else
		currentSong.Volume = volume
		musicMenu.Speaker.Image = speakerImage
		musicMenu.SoundBarFill.BackgroundColor3 = Color3.new(234, 234, 234)
	end
	re:FireServer("Mute", mute)
end)

musicMenu.SoundBarFill.MouseButton1Down:Connect(function(x, y)
	updateSound(x - left)
	drag = true 
	while drag do
		updateSound(mouse.X - left)
		wait()
	end
	re:FireServer("Volume", volume)
	if mute then 
		mute = false
		re:FireServer("Mute", mute)
	end
end)

musicMenu.SoundBar.MouseButton1Down:Connect(function(x, y)
	updateSound(x - left)
	drag = true 
	while drag do
		updateSound(mouse.X - left)
		wait()
	end
	re:FireServer("Volume", volume)
	if mute then 
		mute = false
		re:FireServer("Mute", mute)
	end
end)

script.Parent.MainUI.Buttons.Music.MouseButton1Down:Connect(function()
	musicMenu.Visible = not musicMenu.Visible	
end)

for i, v in pairs(music) do
	v.Ended:Connect(playSong)
end

playSong()

while true do
	wait(1)
	local secondsValue = musicMenu.CurrentTime.Seconds
	local minutesValue = musicMenu.CurrentTime.Minutes
	secondsValue.Value = (secondsValue.Value + 1) % 60
	if secondsValue.Value == 0 then
		minutesValue.Value = minutesValue.Value + 1
	end
	local seconds = tostring(secondsValue.Value)
	if secondsValue.Value < 10 then
		seconds = "0".. seconds
	end
	musicMenu.CurrentTime.Text = tostring(minutesValue.Value)..":"..seconds
end

