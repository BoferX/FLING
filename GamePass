local w = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local me = Players.LocalPlayer

local Struggle = rs.CharacterEvents.Struggle

local ViewEscape  = me.PlayerGui.ControlsGui.PCFrame.Escape
local ViewTime = me.PlayerGui.ControlsGui.PCFrame.EscapeTimer.TimeToEscape
local Timer = 3
local HaveOwner = false
local time = tick()

me.Character.Head.ChildAdded:Connect(function(PartOwner)
	if PartOwner.Name == "PartOwner" then
		HaveOwner = true
		time = tick()
		while true do
			if Timer > 0 then
				if PartOwner.Parent then
					if tick()-time <= 1 then
						task.wait()
					else
						Timer = Timer - 1
						time = tick()
						continue
					end
				else
					break
				end
			else
				break
			end
		end
	end
end)

me.Character.Head.ChildRemoved:Connect(function(PartOwner)
	if PartOwner.Name == "PartOwner" then
		HaveOwner = false
		time = tick()
		task.defer(function()
			while ViewTime.Parent.Visible do
				ViewTime.Text = tostring(Timer)
				task.wait()
			end
		end)
		while true do
			if Timer < 3 then
				local char = me.Character or me.CharacterAdded:Wait()
				local head = char:WaitForChild("Head")
				if not(head:FindFirstChild("PartOwner")) then
					if tick()-time <= 1 then
						task.wait()
					else
						Timer = Timer + 1
						time = tick()
						continue
					end
				else
					break
				end
			else
				break
			end
		end
	end
end)

me.CharacterAdded:Connect(function(char)
	local Head = char:WaitForChild("Head")
	local PCFrame = me.PlayerGui:WaitForChild("ControlsGui"):WaitForChild("PCFrame")
	ViewEscape  = PCFrame:WaitForChild("Escape")
	ViewTime = PCFrame:WaitForChild("EscapeTimer"):WaitForChild("TimeToEscape")
	Head.ChildAdded:Connect(function(PartOwner)
		if PartOwner.Name == "PartOwner" then
			HaveOwner = true
			time = tick()
			while true do
				if Timer > 0 then
					if PartOwner.Parent then
						if tick()-time <= 1 then
							task.wait()
						else
							Timer = Timer - 1
							time = tick()
							continue
						end
					else
						break
					end
				else
					break
				end
			end
		end
	end)

	Head.ChildRemoved:Connect(function(PartOwner)
		if PartOwner.Name == "PartOwner" then
			HaveOwner = false
			time = tick()
			task.defer(function()
				while ViewTime.Parent.Visible do
					ViewTime.Text = tostring(Timer)
					task.wait()
				end
			end)
			while true do
				if Timer < 3 then
					if not HaveOwner then
						if tick()-time <= 1 then
							task.wait()
						else
							Timer = Timer + 1
							time = tick()
							continue
						end
					else
						break
					end
				else
					break
				end
			end
		end
	end)
end)

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space and ViewEscape.Visible then
		Struggle:FireServer(me)
	end
end)

while true do
	if HaveOwner then
		if Timer > 0 then
			if ViewTime then ViewTime.Text = tostring(Timer) end
			task.wait()
		else
			if ViewEscape then ViewEscape.Visible = true end
			if ViewTime and ViewTime.Parent then ViewTime.Parent.Visible = false end
			task.wait()
		end
	else
		if ViewEscape then ViewEscape.Visible = false end
		task.wait()
	end
end
