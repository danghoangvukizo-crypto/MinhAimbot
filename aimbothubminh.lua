
-- ========== Rayfield ==========
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "MinhHub Only Aim",
    LoadingTitle = "Minhdz Script",
    LoadingSubtitle = "MinhHub ",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MinhHubHack",
        FileName = "config"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local function Notify(msg)
    Rayfield:Notify({
        Title = "MinhHub",
        Content = msg,
        Duration = 3,
        Image = 4483362458
    })
end

-- ========== Services & Locals ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== Settings (kept original but using safe types) ==========
local Settings = {
    Aimbot = {
        Enabled = false,
        SilentAim = true,
        Aimlock = true,
        AimKey = "MouseButton2", -- store as string for robust checking
        FOV = 100,
        Smoothness = 0.02,
        HitPart = "Head",
        Wallbang = true,
        TeamCheck = true,
        VisibleCheck = true
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Tracers = true,
        BoxColor = Color3.new(1, 0, 0),
        NameColor = Color3.new(1, 1, 1),
        TracerColor = Color3.new(1, 0, 0)
    },
    Chams = {
        Enabled = false,
        Color = Color3.new(0, 1, 0),
        Transparency = 0.5
    },
    Hitbox = {
        Enabled = false,
        Size = 7,
        Transparency = 0.5
    },
    Triggerbot = { Enabled = false },
    AntiAim = { Enabled = false, Speed = 10 },
    BunnyHop = { Enabled = false },
    Misc = { SpeedHack = false, SpeedValue = 50, Noclip = false }
}

-- ========== Internal State ==========
local Target = nil
local FOVCircle = nil
local ESPObjects = {}
local ChamsObjects = {}

-- ========== Helpers ==========
local DrawingSupported = pcall(function() return Drawing end)

local function SafeDrawing(kind)
    if not DrawingSupported then return nil end
    local ok, obj = pcall(function() return Drawing.new(kind) end)
    if ok then return obj end
    return nil
end

local function IsAimKeyDown(keyString)
    if not keyString then return false end
    if keyString == "MouseButton1" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif keyString == "MouseButton2" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    else
        local kc = Enum.KeyCode[keyString]
        if kc then return UserInputService:IsKeyDown(kc) end
    end
    return false
end

-- ========== FOV Circle ==========
if DrawingSupported then
    local c = SafeDrawing("Circle")
    if c then
        FOVCircle = c
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Thickness = 1
        FOVCircle.Filled = false
        FOVCircle.Color = Settings.ESP.BoxColor or Color3.new(1, 0, 0)
        FOVCircle.Visible = Settings.Aimbot.Enabled
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end

-- ========== Rayfield GUI (3 tabs: Aimbot, ESP, Misc) ==========
local AimbotTab = Window:CreateTab("🎯 Aimbot")
local ESPTab = Window:CreateTab("👁 ESP")
local MiscTab = Window:CreateTab("⚙️ Misc")

-- Aimbot Tab
AimbotTab:CreateToggle({ Name = "Enable Aimbot", CurrentValue = Settings.Aimbot.Enabled, Callback = function(v) Settings.Aimbot.Enabled = v; Notify(v and "✅ Aimbot Enabled" or "❌ Aimbot Disabled") end })
AimbotTab:CreateToggle({ Name = "Silent Aim", CurrentValue = Settings.Aimbot.SilentAim, Callback = function(v) Settings.Aimbot.SilentAim = v; Notify(v and "✅ Silent Aim On" or "❌ Silent Aim Off") end })
AimbotTab:CreateToggle({ Name = "Aimlock", CurrentValue = Settings.Aimbot.Aimlock, Callback = function(v) Settings.Aimbot.Aimlock = v; Notify(v and "✅ Aimlock On" or "❌ Aimlock Off") end })
AimbotTab:CreateDropdown({
    Name = "Aim Key",
    Options = {"MouseButton2","MouseButton1","Q","E","F"},
    CurrentOption = {Settings.Aimbot.AimKey},
    MultiSelection = false,
    Callback = function(opt) Settings.Aimbot.AimKey = opt[1] end
})
AimbotTab:CreateSlider({ Name = "FOV", Range = {50,200}, Increment = 1, CurrentValue = Settings.Aimbot.FOV, Callback = function(v) Settings.Aimbot.FOV = v end })
AimbotTab:CreateSlider({ Name = "Smoothness", Range = {0.01,0.2}, Increment = 0.01, CurrentValue = Settings.Aimbot.Smoothness, Callback = function(v) Settings.Aimbot.Smoothness = v end })
AimbotTab:CreateDropdown({ Name = "Hit Part", Options = {"Head","HumanoidRootPart","Torso"}, CurrentOption = {Settings.Aimbot.HitPart}, MultiSelection = false, Callback = function(v) Settings.Aimbot.HitPart = v[1] end })
AimbotTab:CreateToggle({ Name = "Wallbang", CurrentValue = Settings.Aimbot.Wallbang, Callback = function(v) Settings.Aimbot.Wallbang = v; Notify(v and "✅ Wallbang On" or "❌ Wallbang Off") end })
AimbotTab:CreateToggle({ Name = "Team Check", CurrentValue = Settings.Aimbot.TeamCheck, Callback = function(v) Settings.Aimbot.TeamCheck = v end })
AimbotTab:CreateToggle({ Name = "Visible Check", CurrentValue = Settings.Aimbot.VisibleCheck, Callback = function(v) Settings.Aimbot.VisibleCheck = v end })

-- ESP Tab
ESPTab:CreateToggle({ Name = "Enable ESP", CurrentValue = Settings.ESP.Enabled, Callback = function(v) Settings.ESP.Enabled = v; Notify(v and "✅ ESP Enabled" or "❌ ESP Disabled") end })
ESPTab:CreateToggle({ Name = "Boxes", CurrentValue = Settings.ESP.Boxes, Callback = function(v) Settings.ESP.Boxes = v end })
ESPTab:CreateToggle({ Name = "Names", CurrentValue = Settings.ESP.Names, Callback = function(v) Settings.ESP.Names = v end })
ESPTab:CreateToggle({ Name = "Tracers", CurrentValue = Settings.ESP.Tracers, Callback = function(v) Settings.ESP.Tracers = v end })
ESPTab:CreateToggle({ Name = "Chams", CurrentValue = Settings.Chams.Enabled, Callback = function(v) Settings.Chams.Enabled = v; Notify(v and "✅ Chams Enabled" or "❌ Chams Disabled") end })
ESPTab:CreateToggle({ Name = "Hitbox Expander", CurrentValue = Settings.Hitbox.Enabled, Callback = function(v) Settings.Hitbox.Enabled = v; Notify(v and "✅ Hitbox Enabled" or "❌ Hitbox Disabled") end })
ESPTab:CreateSlider({ Name = "Hitbox Size", Range = {2,12}, Increment = 0.5, CurrentValue = Settings.Hitbox.Size, Callback = function(v) Settings.Hitbox.Size = v end })
ESPTab:CreateSlider({ Name = "Hitbox Transparency", Range = {0,1}, Increment = 0.05, CurrentValue = Settings.Hitbox.Transparency, Callback = function(v) Settings.Hitbox.Transparency = v end })

-- Misc Tab
MiscTab:CreateToggle({ Name = "Triggerbot", CurrentValue = Settings.Triggerbot.Enabled, Callback = function(v) Settings.Triggerbot.Enabled = v; Notify(v and "✅ Triggerbot On" or "❌ Triggerbot Off") end })
MiscTab:CreateToggle({ Name = "Anti-Aim", CurrentValue = Settings.AntiAim.Enabled, Callback = function(v) Settings.AntiAim.Enabled = v; Notify(v and "✅ Anti-Aim On" or "❌ Anti-Aim Off") end })
MiscTab:CreateToggle({ Name = "Bunny Hop", CurrentValue = Settings.BunnyHop.Enabled, Callback = function(v) Settings.BunnyHop.Enabled = v; Notify(v and "✅ Bunny Hop On" or "❌ Bunny Hop Off") end })
MiscTab:CreateToggle({ Name = "Speed Hack", CurrentValue = Settings.Misc.SpeedHack, Callback = function(v) Settings.Misc.SpeedHack = v; Notify(v and "✅ SpeedHack On" or "❌ SpeedHack Off") end })
MiscTab:CreateSlider({ Name = "Speed Value", Range = {16,120}, Increment = 1, CurrentValue = Settings.Misc.SpeedValue, Callback = function(v) Settings.Misc.SpeedValue = v end })
MiscTab:CreateToggle({ Name = "Noclip", CurrentValue = Settings.Misc.Noclip, Callback = function(v) Settings.Misc.Noclip = v; Notify(v and "✅ Noclip On" or "❌ Noclip Off") end })

-- ========== Original Logic (fixed, kept behavior) ==========

-- Utility: valid target check (keeps original logic but safe)
local function IsValidTarget(player)
    local ok, result = pcall(function()
        if not player or not player.Character then return false end
        local hitPart = player.Character:FindFirstChild(Settings.Aimbot.HitPart)
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not hitPart or not humanoid or humanoid.Health <= 0 then return false end
        if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then return false end
        if Settings.Aimbot.VisibleCheck then
            local origin = Camera.CFrame.Position
            local direction = (hitPart.Position - origin).Unit * 200
            local ray = Ray.new(origin, direction)
            local partHit, _ = Workspace:FindPartOnRayWithIgnoreList(ray, { LocalPlayer.Character }, false, true)
            if partHit and partHit:IsDescendantOf(player.Character) then
                return true
            elseif Settings.Aimbot.Wallbang then
                return true
            end
            return false
        end
        return true
    end)
    return ok and result
end

-- GetClosestPlayer (fixed iteration and checks)
local function GetClosestPlayer()
    local closestPlayer = nil
    local closestDistance = Settings.Aimbot.FOV or math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsValidTarget(player) and player.Character then
            local part = player.Character:FindFirstChild(Settings.Aimbot.HitPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- Silent Aim Hook (uses table.unpack and safer checks)
local oldNamecall
if hookmetamethod then
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = { ... }
        if Settings.Aimbot.SilentAim and getnamecallmethod() == "FindPartOnRayWithIgnoreList" and Target and Target.Character and Target.Character:FindFirstChild(Settings.Aimbot.HitPart) then
            local ok = pcall(function()
                args[1] = Ray.new(Camera.CFrame.Position, (Target.Character[Settings.Aimbot.HitPart].Position - Camera.CFrame.Position).Unit * 200)
            end)
            if not ok then
                return oldNamecall(self, ...)
            end
        end
        return oldNamecall(self, table.unpack(args))
    end)
else
    warn("Silent Aim disabled: hookmetamethod not supported.")
end

-- ESP: Create / Update / Remove
local function CreateESP(player)
    if not player or player == LocalPlayer or not player.Character then return end
    local esp = {}

    if Settings.ESP.Boxes then
        local box = SafeDrawing("Square")
        if box then
            box.Thickness = 1
            box.Color = Settings.ESP.BoxColor
            box.Filled = false
            box.Visible = false
            esp.Box = box
        end
    end

    if Settings.ESP.Names then
        local name = SafeDrawing("Text")
        if name then
            name.Size = 16
            name.Color = Settings.ESP.NameColor
            name.Text = player.Name
            name.Visible = false
            esp.Name = name
        end
    end

    if Settings.ESP.Tracers then
        local tracer = SafeDrawing("Line")
        if tracer then
            tracer.Thickness = 1
            tracer.Color = Settings.ESP.TracerColor
            tracer.Visible = false
            esp.Tracer = tracer
        end
    end

    ESPObjects[player] = esp
end

local function RemoveESP(player)
    if ESPObjects[player] then
        local esp = ESPObjects[player]
        if esp.Box and esp.Box.Remove then pcall(function() esp.Box:Remove() end) end
        if esp.Name and esp.Name.Remove then pcall(function() esp.Name:Remove() end) end
        if esp.Tracer and esp.Tracer.Remove then pcall(function() esp.Tracer:Remove() end) end
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    for player, esp in pairs(ESPObjects) do
        local ok, _ = pcall(function()
            if not player then return end
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen and Settings.ESP.Enabled then
                    if esp.Box and player.Character:FindFirstChild("Head") then
                        local headPos = Camera:WorldToViewportPoint(player.Character.Head.Position)
                        local torsoPos = Camera:WorldToViewportPoint(root.Position)
                        local depth = math.max(0.0001, torsoPos.Z)
                        esp.Box.Size = Vector2.new(1000 / depth, math.abs(headPos.Y - torsoPos.Y))
                        esp.Box.Position = Vector2.new(torsoPos.X - esp.Box.Size.X / 2, torsoPos.Y)
                        esp.Box.Visible = true
                    elseif esp.Box then
                        esp.Box.Visible = false
                    end

                    if esp.Name then
                        esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                        esp.Name.Visible = true
                    end

                    if esp.Tracer then
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        esp.Tracer.Visible = true
                    end
                else
                    if esp.Box then esp.Box.Visible = false end
                    if esp.Name then esp.Name.Visible = false end
                    if esp.Tracer then esp.Tracer.Visible = false end
                end
            else
                if esp.Box then esp.Box.Visible = false end
                if esp.Name then esp.Name.Visible = false end
                if esp.Tracer then esp.Tracer.Visible = false end
            end
        end)
        if not ok then
            local pn = (type(player) == "userdata" and player.Name) or "Unknown"
            warn("ESP update failed for player: " .. tostring(pn))
        end
    end
end

-- Chams: Create / Update
local function CreateChams(player)
    if not player or player == LocalPlayer or not player.Character then return end
    local chams = {}
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Settings.Chams.Color
            highlight.FillTransparency = Settings.Chams.Transparency
            highlight.OutlineTransparency = 1
            highlight.Parent = part
            highlight.Enabled = Settings.Chams.Enabled or false
            chams[part] = highlight
        end
    end
    ChamsObjects[player] = chams
end

local function UpdateChams()
    for player, chams in pairs(ChamsObjects) do
        local ok, _ = pcall(function()
            if player and player.Character and Settings.Chams.Enabled then
                for part, highlight in pairs(chams) do
                    if part and part.Parent then
                        highlight.Enabled = true
                    else
                        pcall(function() highlight:Destroy() end)
                        chams[part] = nil
                    end
                end
            else
                for part, highlight in pairs(chams) do
                    pcall(function() highlight:Destroy() end)
                end
                ChamsObjects[player] = nil
            end
        end)
        if not ok then
            local pn = (type(player) == "userdata" and player.Name) or "Unknown"
            warn("Chams update failed for player: " .. tostring(pn))
        end
    end
end

-- Hitbox Expansion
local function UpdateHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        local ok, _ = pcall(function()
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                if Settings.Hitbox.Enabled then
                    local randomSize = Settings.Hitbox.Size + (math.random() - 0.5)
                    head.Size = Vector3.new(randomSize, randomSize, randomSize)
                    head.Transparency = Settings.Hitbox.Transparency
                    head.CanCollide = false
                else
                    pcall(function()
                        head.Size = Vector3.new(2, 1, 1)
                        head.Transparency = 0
                        head.CanCollide = true
                    end)
                end
            end
        end)
        if not ok then
            local pn = (type(player) == "userdata" and player.Name) or "Unknown"
            warn("Hitbox update failed for player: " .. tostring(pn))
        end
    end
end

-- Triggerbot
local function ApplyTriggerbot()
    local ok, _ = pcall(function()
        if Settings.Triggerbot.Enabled then
            local target = GetClosestPlayer()
            if target and target.Character and mouse1click then
                pcall(mouse1click)
            end
        end
    end)
    if not ok then warn("Triggerbot failed") end
end

-- Anti-Aim
local function ApplyAntiAim()
    local ok, _ = pcall(function()
        if Settings.AntiAim.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
            local head = LocalPlayer.Character.Head
            head.CFrame = head.CFrame * CFrame.Angles(math.rad(math.random(-10, 10)), math.rad(math.random(-180, 180)), 0)
        end
    end)
    if not ok then warn("Anti-Aim failed") end
end

-- Bunny Hop
local function ApplyBunnyHop()
    local ok, _ = pcall(function()
        if Settings.BunnyHop.Enabled and LocalPlayer.Character and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            task.wait(0.1 + math.random() * 0.05)
        end
    end)
    if not ok then warn("Bunny Hop failed") end
end

-- Misc (Speed)
local function ApplyMisc()
    local ok, _ = pcall(function()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if Settings.Misc.SpeedHack then
                    humanoid.WalkSpeed = Settings.Misc.SpeedValue + math.random(-2, 2)
                else
                    humanoid.WalkSpeed = 16
                end
            end
        end
    end)
    if not ok then warn("Misc hacks failed") end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- update FOV circle
    if FOVCircle then
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Visible = Settings.Aimbot.Enabled
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end

    -- aimbot logic (uses IsAimKeyDown)
    if Settings.Aimbot.Enabled and IsAimKeyDown(Settings.Aimbot.AimKey) then
        Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(Settings.Aimbot.HitPart) then
            local targetPart = Target.Character[Settings.Aimbot.HitPart]
            local screenPos = Camera:WorldToViewportPoint(targetPart.Position)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local newPos = (Vector2.new(screenPos.X, screenPos.Y) - mousePos) * Settings.Aimbot.Smoothness
            pcall(function() mousemoverel(newPos.X, newPos.Y) end)
            if Settings.Aimbot.Aimlock then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
        end
    else
        Target = nil
    end

    -- updates + misc
    UpdateESP()
    UpdateChams()
    UpdateHitboxes()
    ApplyTriggerbot()
    ApplyAntiAim()
    ApplyBunnyHop()
    ApplyMisc()
end)

-- Noclip (Stepped)
RunService.Stepped:Connect(function()
    if Settings.Misc.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Player Added / Removing
Players.PlayerAdded:Connect(function(player)
    -- create esp/chams (pcall inside)
    pcall(function() CreateESP(player); CreateChams(player) end)
end)

Players.PlayerRemoving:Connect(function(player)
    pcall(function()
        RemoveESP(player)
        if ChamsObjects[player] then
            for _, highlight in pairs(ChamsObjects[player]) do pcall(function() highlight:Destroy() end) end
            ChamsObjects[player] = nil
        end
    end)
end)

-- Initialize for existing players
for _, player in ipairs(Players:GetPlayers()) do
    pcall(function() CreateESP(player); CreateChams(player) end)
end
