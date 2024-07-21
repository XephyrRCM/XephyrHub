--- All needed for UI ---------------------------------------------------------------------------------------------

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()


-----------------------------------------------------------------------------------------

----Functions---


---------------------------------------------------------------------------------------


-- UI --

local Window = Fluent:CreateWindow({
    Title = "XephyrHub",
    SubTitle = "Xephyr",
    TabWidth = 160,
    Size = UDim2.fromOffset(540, 300),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local Tabs = {
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "home" }),
    LocalPlayer = Window:AddTab({ Title = "Local Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "cog" }),
    Credits = Window:AddTab({ Title = "Credits & Info ", Icon = "info" })
}

-- Toggles ==

-- AutoFarm Toggle
Tabs.AutoFarm:AddToggle("Toggle AutoFarm", {
Title = "Toggle AutoFarm", 
Default = false, 
Callback = function(Value)
    getgenv().autofarm = Value
end
})
-- Local Player --

  -- FOV
  Tabs.LocalPlayer:AddSlider("FOV", {
    Title = "FOV",
    Default = 80,
    Min = 5,
    Max = 120,
    Rounding = 5,
    Callback = function(Value)
      game.Workspace.CurrentCamera.FieldOfView = Value
  end
  })

 -- Gravity
 Tabs.LocalPlayer:AddSlider("Gravity", {
    Title = "Gravity",
    Default = 100,
    Min = 40,
    Max = 200,
    Rounding = 10,
    Callback = function(Value)
        workspace.Gravity = Value
    end,
 })

  -- Fly
  getgenv().fly = false
  local FlySpeed = 100
  Tabs.LocalPlayer:AddSlider("Fly", {
    Title = "Fly",
    Default = 100,
    Min = 50,
    Max = 1000,
    Rounding = 10,
    Callback = function(Value) 
        FlySpeed = Value
    end,
 })

 -- WalkSpeed
local ws = 0.5
Tabs.LocalPlayer:AddSlider("WalkSpeed", {
Title = "WalkSpeed",
Default = 0.5,
Min = 0.5,
Max = 5,
Rounding = 1,
Callback = function(Value)
    ws = Value
end,
})

  -- Toggle Fly
  Tabs.LocalPlayer:AddToggle("Toggle Fly", {
    Title = "Toggle Fly", 
    Default = false, 
    Callback = function(Value)
        local Camera = workspace.CurrentCamera
		local UIS = game:GetService("UserInputService")
		getgenv().fly = Value
		if fly then
			spawn(function()
				local BodyGyro = Instance.new("BodyGyro",
					game:GetService("Players").LocalPlayer.Character.HumanoidRootPart)
				local BodyVelocity = Instance.new("BodyVelocity",
					game:GetService("Players").LocalPlayer.Character.HumanoidRootPart)
				BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				game:GetService("RunService").Heartbeat:Connect(function()
					BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
					BodyGyro.D = 50000
					BodyGyro.P = 150000000
					BodyGyro.CFrame = Camera.CFrame
				end)
				repeat
					task.wait()
					BodyVelocity.Velocity = Vector3.new()
					if UIS:IsKeyDown(Enum.KeyCode.W) then
						BodyVelocity.Velocity = BodyVelocity.Velocity + Camera.CFrame.LookVector
					end
					if UIS:IsKeyDown(Enum.KeyCode.A) then
						BodyVelocity.Velocity = BodyVelocity.Velocity - Camera.CFrame.RightVector
					end
					if UIS:IsKeyDown(Enum.KeyCode.S) then
						BodyVelocity.Velocity = BodyVelocity.Velocity - Camera.CFrame.LookVector
					end
					if UIS:IsKeyDown(Enum.KeyCode.D) then
						BodyVelocity.Velocity = BodyVelocity.Velocity + Camera.CFrame.RightVector
					end
					BodyVelocity.Velocity = BodyVelocity.Velocity * FlySpeed
					game.Players.LocalPlayer.Character.Humanoid.PlatformStand = true
				until fly == false
				game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
				BodyGyro:Destroy()
				BodyVelocity:Destroy()
			end)
		end
	end
})

-- Toggle WalkSpeed
Tabs.LocalPlayer:AddToggle("Toggle Undetected WalkSpeed", {
Title = "Toggle WalkSpeed", 
Default = false, 
Callback = function(Value)
    getgenv().undetectedwalkspeed = Value
    local UIS = game:GetService("UserInputService")
    task.spawn(function()
        while undetectedwalkspeed do
            task.wait()
            if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.D) then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character
                    .HumanoidRootPart.CFrame + game.Players.LocalPlayer.Character.Humanoid.MoveDirection * ws
            end
        end
    end)
end
})

  -- Infinite Jump
    Tabs.LocalPlayer:AddToggle("Infinite Jump", {
    Title = "Infinite Jump", 
    Default = false, 
    Callback = function(Value)
        getgenv().infiniteJump = Value
		local UserInputService = game:GetService("UserInputService")
		UserInputService.JumpRequest:Connect(function()
			if getgenv().infiniteJump == true then
				game:GetService "Players".LocalPlayer.Character:FindFirstChildOfClass 'Humanoid':ChangeState("Jumping")
			end
		end)
	end
})







 -- Credits --

 Tabs.Credits:AddParagraph({
    Title = "Script developed by: XephyrCM",
    --Content = "Discord: XephyrHub",
})

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()