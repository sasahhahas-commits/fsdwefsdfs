-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- [[ THEME CONFIG & OBJECT REGISTRY ]] --
local Theme = {
    MainBg = Color3.fromRGB(11, 13, 17),
    ContentBg = Color3.fromRGB(16, 19, 25),
    BorderBlue = Color3.fromRGB(92, 180, 255),
    TabActive = Color3.fromRGB(25, 31, 41),
    TabInactive = Color3.fromRGB(14, 17, 22),
    TextColor = Color3.fromRGB(236, 240, 248),
    OutlineColor = Color3.fromRGB(39, 48, 61),
    TextDim = Color3.fromRGB(139, 151, 168),
    Font = Enum.Font.Gotham
}

local ColorObjects = {
    MainBg = {},
    ContentBg = {},
    BorderBlue = {},
    TextColor = {},
    OutlineColor = {}
}

local currentPresetName = "Default"

local function updateThemeColor(themeKey, newColor)
    Theme[themeKey] = newColor
    for _, obj in ipairs(ColorObjects[themeKey]) do
        if obj and obj.Parent then
            if themeKey == "MainBg" or themeKey == "ContentBg" then
                obj.BackgroundColor3 = newColor
            elseif themeKey == "BorderBlue" or themeKey == "OutlineColor" then
                if obj:IsA("UIStroke") then
                    obj.Color = newColor
                elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    obj.TextColor3 = newColor
                else
                    obj.BackgroundColor3 = newColor
                end
            elseif themeKey == "TextColor" then
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    obj.TextColor3 = newColor
                end
            end
        end
    end
end

local Presets = {
    ["Obsidian"] = {
        MainBg = Color3.fromRGB(11, 13, 17),
        ContentBg = Color3.fromRGB(16, 19, 25),
        BorderBlue = Color3.fromRGB(92, 180, 255),
        OutlineColor = Color3.fromRGB(39, 48, 61),
        TextColor = Color3.fromRGB(236, 240, 248)
    },
    ["Crimson"] = {
        MainBg = Color3.fromRGB(18, 11, 14),
        ContentBg = Color3.fromRGB(25, 15, 19),
        BorderBlue = Color3.fromRGB(235, 82, 104),
        OutlineColor = Color3.fromRGB(67, 34, 42),
        TextColor = Color3.fromRGB(246, 232, 236)
    },
    ["Aurora"] = {
        MainBg = Color3.fromRGB(10, 16, 19),
        ContentBg = Color3.fromRGB(14, 23, 27),
        BorderBlue = Color3.fromRGB(70, 220, 190),
        OutlineColor = Color3.fromRGB(31, 64, 64),
        TextColor = Color3.fromRGB(229, 245, 243)
    },
    ["Violet"] = {
        MainBg = Color3.fromRGB(14, 11, 20),
        ContentBg = Color3.fromRGB(21, 16, 30),
        BorderBlue = Color3.fromRGB(168, 118, 255),
        OutlineColor = Color3.fromRGB(55, 42, 78),
        TextColor = Color3.fromRGB(239, 234, 250)
    }
}

local function applyPreset(name)
    local p = Presets[name]
    if not p then return end
    currentPresetName = name
    for k, color in pairs(p) do
        updateThemeColor(k, color)
    end
end

local CONFIG_FILE = "grey_shader_config.json"

local function saveDefaultTheme()
    local success, err = pcall(function()
        if writefile then
            local data = { DefaultTheme = currentPresetName }
            writefile(CONFIG_FILE, HttpService:JSONEncode(data))
        else
            warn("[GREYSHADER] Executor 'writefile' desteklemiyor.")
        end
    end)
    if not success then warn("[GREYSHADER] Kaydetme hatası:", err) end
end

local function loadDefaultTheme()
    pcall(function()
        if readfile and isfile and isfile(CONFIG_FILE) then
            local rawData = readfile(CONFIG_FILE)
            local data = HttpService:JSONDecode(rawData)
            if data and data.DefaultTheme and Presets[data.DefaultTheme] then
                task.spawn(function()
                    task.wait(0.1)
                    applyPreset(data.DefaultTheme)
                    if _G.UpdateDropdownText then _G.UpdateDropdownText(data.DefaultTheme) end
                end)
            end
        end
    end)
end

------------------------------------------------
-- VARIABLES & DATA STATE
------------------------------------------------
local isUnloaded = false
local strafeEnabled = false
local resetEnabled = false
local autoTP = false
local pressingE = false
local autoReloadEnabled = false 
local autoWalkEnabled = false
local adminCheckEnabled = false
local autoClaimAllowanceEnabled = false 
local adminConnection = nil
local uiVisible = true
local locations = {}
local selectedLocation = nil
local coordCount = 0
local lastHealth = 100
local toolLoopActive = false 
local menuBindKey = Enum.KeyCode.K

local RunningConnections = {}
local Keybinds = {}
local toggle_states = { FastPickup = false, Fly = false, PlayerESP = false, TeamCheck = false, ESPBox = false, ESPNames = false, ESPHealth = false, ESPDistance = false, ESPTracer = false, ESPChams = false, ESPSkeleton = false, ESPTool = false }

local flyMethod = "Velocity"
local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
local flyRemote = eventsFolder and eventsFolder:FindFirstChild("__RZDONL")

local Shadow_Active = false
local Shadow_Usable = true
local Char = player.Character or player.CharacterAdded:Wait()
local HMND = nil
local HRP = nil
local AnimTrack_Cache = nil

local CamoAnim = Instance.new("Animation")
CamoAnim.AnimationId = "rbxassetid://215384594"

local staffData = {
    groups = {
        [4165692] = {["Tester"] = true, ["Contributor"] = true, ["Developer"] = true, ["Owner"] = true},
        [32406137] = {["Junior"] = true, ["Moderator"] = true, ["Senior"] = true, ["Administrator"] = true, ["Manager"] = true},
        [8024440] = {["reshape enjoyer"] = true, ["i heart reshape"] = true},
        [14927228] = {["♞"] = true}
    },
    users = {3294804378, 93676120, 54087314, 81275825, 140837601, 1229486091, 46567801, 418086275, 29706395, 3717066084, 1424338327, 5046662686, 5046661126, 5046659439, 418199326, 1024216621, 1810535041, 63238912, 111250044, 63315426, 730176906, 141193516, 194512073, 193945439, 412741116, 195538733, 102045519, 955294, 957835150, 25689921, 366613818, 281593651, 455275714, 208929505, 96783330, 156152502, 93281166, 959606619, 142821118, 632886139, 175931803, 122209625, 278097946, 142989311, 1517131734, 446849296, 87189764, 67180844, 9212846, 47352513, 48058122, 155413858, 10497435, 513615792, 55893752, 55476024, 151691292, 136584758, 16983447, 3111449, 94693025, 271400893, 5005262660, 295331237, 64489098, 244844600, 114332275, 25048901, 69262878, 50801509, 92504899, 42066711, 50585425, 31365111, 166406495, 2457253857, 29761878, 21831137, 948293345, 439942262, 38578487, 1163048, 7713309208, 3659305297, 15598614, 34616594, 626833004, 198610386, 153835477, 3923114296, 3937697838, 102146039, 119861460, 371665775, 1206543842, 93428604, 1863173316, 90814576, 374665997, 423005063, 140172831, 42662179, 9066859, 438805620, 14855669, 727189337, 1871290386, 608073286}
}

local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
local reload_event = eventsFolder and eventsFolder:FindFirstChild("GNX_R") 

------------------------------------------------
-- AYAĞIN ALTINA PLATFORM KOYMA FONKSİYONU
------------------------------------------------
local targetPlatformInstance = nil
local function spawnTargetPlatformAtFeet()
    if targetPlatformInstance then
        targetPlatformInstance:Destroy()
    end
    
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    local part = Instance.new("Part")
    part.Size = Vector3.new(10, 1, 10)
    part.Anchored = true
    part.CanCollide = true
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 170, 0)
    
    if hrp then
        part.Position = hrp.Position - Vector3.new(0, 3.5, 0)
    else
        part.Position = Vector3.new(-4800.19, -414.89, 135.03)
    end
    
    part.Parent = workspace
    targetPlatformInstance = part
end

------------------------------------------------
-- AUTO RELOAD ENGINE LOGIC
------------------------------------------------
local function setup_auto_reload()
    if not autoReloadEnabled or isUnloaded then return end
    local character = player.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if not tool or not tool:FindFirstChild("IsGun") then
            local cChild = character.ChildAdded:Connect(function(child)
                local new_tool = child
                if new_tool:IsA("Tool") and new_tool:FindFirstChild("IsGun") then
                    local values = new_tool:FindFirstChild("Values")
                    local ammo = values and values:FindFirstChild("SERVER_Ammo")
                    local stored = values and values:FindFirstChild("SERVER_StoredAmmo")
                    
                    if ammo and stored then
                        local cStored = stored:GetPropertyChangedSignal("Value"):Connect(function()
                            if autoReloadEnabled and reload_event then
                                reload_event:FireServer(tick(), "KLWE89U0", new_tool)
                            end
                        end)
                        table.insert(RunningConnections, cStored)
                        
                        if stored.Value ~= 0 and autoReloadEnabled and reload_event then
                            reload_event:FireServer(tick(), "KLWE89U0", new_tool)
                        end
                        
                        local cAmmo = ammo:GetPropertyChangedSignal("Value"):Connect(function()
                            if autoReloadEnabled and stored.Value ~= 0 and reload_event then
                                reload_event:FireServer(tick(), "KLWE89U0", new_tool)
                            end
                        end)
                        table.insert(RunningConnections, cAmmo)
                    end
                end
            end)
            table.insert(RunningConnections, cChild)
        else
            local values = tool:FindFirstChild("Values")
            local ammo = values and values:FindFirstChild("SERVER_Ammo")
            local stored = values and values:FindFirstChild("SERVER_StoredAmmo")
            
            if ammo and stored then
                local cStored = stored:GetPropertyChangedSignal("Value"):Connect(function()
                    if autoReloadEnabled and reload_event then
                        reload_event:FireServer(tick(), "KLWE89U0", tool)
                    end
                end)
                table.insert(RunningConnections, cStored)
                
                if stored.Value ~= 0 and autoReloadEnabled and reload_event then
                    reload_event:FireServer(tick(), "KLWE89U0", tool)
                end
                
                local cAmmo = ammo:GetPropertyChangedSignal("Value"):Connect(function()
                    if autoReloadEnabled and stored.Value ~= 0 and reload_event then
                        reload_event:FireServer(tick(), "KLWE89U0", tool)
                    end
                end)
                table.insert(RunningConnections, cAmmo)
            end
        end
        
        local cCharAdded = player.CharacterAdded:Connect(function(new_char)
            if not new_char then return end
            local parent = new_char.Parent
            repeat
                task.wait()
                if new_char then parent = new_char.Parent end
            until parent
            
            local cNewChild = new_char.ChildAdded:Connect(function(child)
                local new_tool = child
                if new_tool:IsA("Tool") and new_tool:FindFirstChild("IsGun") then
                    local values = new_tool:FindFirstChild("Values")
                    local ammo = values and values:FindFirstChild("SERVER_Ammo")
                    local stored = values and values:FindFirstChild("SERVER_StoredAmmo")
                    
                    if ammo and stored then
                        local cStored = stored:GetPropertyChangedSignal("Value"):Connect(function()
                            if autoReloadEnabled and reload_event then
                                reload_event:FireServer(tick(), "KLWE89U0", new_tool)
                            end
                        end)
                        table.insert(RunningConnections, cStored)
                        
                        if stored.Value ~= 0 and autoReloadEnabled and reload_event then
                            reload_event:FireServer(tick(), "KLWE89U0", new_tool)
                        end
                        
                        local cAmmo = ammo:GetPropertyChangedSignal("Value"):Connect(function()
                            if autoReloadEnabled and stored.Value ~= 0 and reload_event then
                                reload_event:FireServer(tick(), "KLWE89U0", new_tool)
                            end
                        end)
                        table.insert(RunningConnections, cAmmo)
                    end
                end
            end)
            table.insert(RunningConnections, cNewChild)
        end)
        table.insert(RunningConnections, cCharAdded)
    end
end

------------------------------------------------
-- MELEE AURA ENGINE LOGIC
------------------------------------------------
local MeleeAura_Enabled = false
local MeleeAura_Connection = nil

local function MeleeAura_Disable()
    if not MeleeAura_Enabled then return end
    MeleeAura_Enabled = false
    if MeleeAura_Connection and MeleeAura_Connection.Connected then 
        MeleeAura_Connection:Disconnect()
        MeleeAura_Connection = nil
    end
end

local function runAttackLoop()
    local remoteFunctionPath = "XMHH.2" 
    local remoteEventPath = "XMHH2.2"
    local maxdist = 5

    local function Attack(target)
        if not (target and target:FindFirstChild("Head")) then return end

        local char = player.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        local rEvents = ReplicatedStorage:FindFirstChild("Events")
        if not rEvents then return end
        
        local remote1 = rEvents:FindFirstChild(remoteFunctionPath)
        local remote2 = rEvents:FindFirstChild(remoteEventPath)

        if not remote1 or not remote1:IsA("RemoteFunction") or not remote2 or not remote2:IsA("RemoteEvent") then
            MeleeAura_Disable() 
            return
        end

        local arg1 = { "🍞", tick(), tool, "43TRFWX", "Normal", tick(), true }
        local success1, result = pcall(function()
            return remote1:InvokeServer(unpack(arg1))
        end)

        if not success1 then return end
        task.wait(0.1) 

        local Handle = tool and (tool:FindFirstChild("WeaponHandle") or tool:FindFirstChild("Handle")) or (char and char:FindFirstChild("Right Arm"))
        local head = target:FindFirstChild("Head")

        if Handle and head and hrp then
            local arg2 = { "🍞", tick(), tool, "2389ZFX34", result, false, Handle, head, target, hrp.Position, head.Position }
            pcall(function()
                remote2:FireServer(unpack(arg2))
            end)
        end
    end

    return RunService.RenderStepped:Connect(function()
        if not MeleeAura_Enabled or isUnloaded then return end 
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then 
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then
                    local c = plr.Character
                    local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
                    local hum = c and c:FindFirstChildOfClass("Humanoid")
                    
                    if hrp2 and hum then
                        local dist = (hrp.Position - hrp2.Position).Magnitude
                        if dist < maxdist and hum.Health > 15 and not c:FindFirstChildOfClass("ForceField") then
                            Attack(c)
                        end
                    end
                end
            end
        end
    end)
end

local function MeleeAura_Enable()
    if MeleeAura_Enabled or isUnloaded then return end
    MeleeAura_Enabled = true
    if MeleeAura_Connection and MeleeAura_Connection.Connected then
        MeleeAura_Connection:Disconnect()
    end
    MeleeAura_Connection = runAttackLoop()
end

------------------------------------------------
-- UTILITY LOGIC
------------------------------------------------
local function checkAndKick(p)
    if not adminCheckEnabled or p == player or isUnloaded then return end
    for _, id in ipairs(staffData.users) do
        if p.UserId == id then
            player:Kick("STAFF JOINED")
            break
        end
    end
end

local function RefreshCharRefs()
    Char = player.Character
    if Char then
        HRP = Char:FindFirstChild("HumanoidRootPart")
        HMND = Char:FindFirstChildOfClass("Humanoid")
    else HRP = nil; HMND = nil end
end

local function CheckGrounded() return HMND and HMND:IsDescendantOf(workspace) and HMND.FloorMaterial ~= Enum.Material.Air end

pcall(function()
    local pg = player:FindFirstChildOfClass("PlayerGui")
    if pg and pg:FindFirstChild("GreyShader_V8_Modern") then
        pg.GreyShader_V8_Modern:Destroy()
    end
    if CoreGui and CoreGui:FindFirstChild("GreyShader_V8_Modern") then
        CoreGui.GreyShader_V8_Modern:Destroy()
    end
    if CoreGui and CoreGui:FindFirstChild("ShadowWarningHUD") then
        CoreGui.ShadowWarningHUD:Destroy()
    end
end)

local HUD = Instance.new("ScreenGui")
HUD.Name = "ShadowWarningHUD"
local successHUD, coreGuiObj = pcall(function() return game:GetService("CoreGui") end)
local pg = player:FindFirstChildOfClass("PlayerGui")
HUD.Parent = (successHUD and coreGuiObj) or pg
HUD.ResetOnSpawn = false
HUD.IgnoreGuiInset = true
HUD.DisplayOrder = 90

local WarningText = Instance.new("TextLabel", HUD)
WarningText.Text = "⚠️You are visible⚠️"
WarningText.Visible = false
WarningText.Size = UDim2.new(0, 200, 0, 30)
WarningText.Position = UDim2.new(0.5, -100, 0.85, 0)
WarningText.BackgroundTransparency = 1
WarningText.Font = Enum.Font.GothamSemibold
WarningText.TextSize = 24
WarningText.TextColor3 = Color3.fromRGB(255, 255, 0)
WarningText.TextStrokeTransparency = 0.5

local function CacheAnimTrack()
    if AnimTrack_Cache then pcall(function() AnimTrack_Cache:Stop() end); AnimTrack_Cache = nil end
    if HMND then
        local success, result = pcall(function() return HMND:LoadAnimation(CamoAnim) end)
        if success then AnimTrack_Cache = result; AnimTrack_Cache.Priority = Enum.AnimationPriority.Action4 else AnimTrack_Cache = nil end
    end
end

local function DeactivateShadow()
    if not Shadow_Active then return end
    Shadow_Active = false
    if AnimTrack_Cache then pcall(function() AnimTrack_Cache:Stop() end) end
    if HMND then workspace.CurrentCamera.CameraSubject = HMND end
    if Char then
        for _, v in pairs(Char:GetDescendants()) do if v:IsA("BasePart") and v.Transparency == 0.5 then v.Transparency = 0 end end
    end
    WarningText.Visible = false
end

local function ActivateShadow()
    if Shadow_Active or not Shadow_Usable or isUnloaded then return end
    RefreshCharRefs()
    if not Char or not HMND or not HRP then return end
    if not Char:FindFirstChild("Torso") then return end
    Shadow_Active = true
    workspace.CurrentCamera.CameraSubject = HRP
    CacheAnimTrack()
end

local function ShadowStep(deltaTime)
    if isUnloaded or not Char or not HMND or not HRP or not HMND:IsDescendantOf(workspace) or HMND.Health <= 0 then WarningText.Visible = false; return end
    WarningText.Visible = not CheckGrounded()
    local walk_speed = 12
    if HMND.MoveDirection.Magnitude > 0 then HRP.CFrame = HRP.CFrame + (HMND.MoveDirection * walk_speed * deltaTime) end
    local InitialCFrame, InitialCamOffset = HRP.CFrame, HMND.CameraOffset
    local _, yaw_angle = workspace.CurrentCamera.CFrame:ToOrientation()
    HRP.CFrame = CFrame.new(HRP.CFrame.Position) * CFrame.fromOrientation(0, yaw_angle, 0) * CFrame.Angles(math.rad(90), 0, 0)
    HMND.CameraOffset = Vector3.new(0, 1.44, 0)
    if AnimTrack_Cache then
        pcall(function() if not AnimTrack_Cache.IsPlaying then AnimTrack_Cache:Play() end; AnimTrack_Cache:AdjustSpeed(0); AnimTrack_Cache.TimePosition = 0.3 end)
    else CacheAnimTrack() end
    RunService.RenderStepped:Wait()
    if HMND and HMND:IsDescendantOf(workspace) then HMND.CameraOffset = InitialCamOffset end
    if HRP and HRP:IsDescendantOf(workspace) then HRP.CFrame = InitialCFrame end
    if AnimTrack_Cache then pcall(function() AnimTrack_Cache:Stop() end) end
    if HRP and HRP:IsDescendantOf(workspace) then
        local LookVec = workspace.CurrentCamera.CFrame.LookVector
        local FlatLook = Vector3.new(LookVec.X, 0, LookVec.Z).Unit
        if FlatLook.Magnitude > 0.1 then HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + FlatLook) end
    end
    if Char then
        for _, v in pairs(Char:GetDescendants()) do if v:IsA("BasePart") and v.Transparency ~= 1 then v.Transparency = 0.5 end end
    end
end

local function startPressingE()
    if pressingE or isUnloaded then return end
    pressingE = true
    task.spawn(function()
        while pressingE and not isUnloaded do
            pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.1); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
            task.wait(0.1)
        end
    end)
end

local function stopPressingE() pressingE = false end

local function startToolLoopForReset(char)
    if not resetEnabled or isUnloaded then return end
    toolLoopActive = true
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then pcall(function() humanoid:EquipTool(tool) end) end
    end
    task.wait(2) 
    task.spawn(function()
        while toolLoopActive and resetEnabled and not isUnloaded and char and char.Parent and humanoid and humanoid.Health > 0 do
            local bp = player:FindFirstChild("Backpack")
            if bp then
                local tool = bp:FindFirstChildOfClass("Tool")
                if tool then pcall(function() humanoid:EquipTool(tool) end) end
            end
            task.wait(0.1)
            if char:FindFirstChildOfClass("Tool") then pcall(function() humanoid:UnequipTools() end) end
            task.wait(0.1)
        end
    end)
end

------------------------------------------------
-- 2 SANIYE SONRA SİLAH/YUMRUK ELE ALMA MANTIĞI (SADECE AUTO RESET AÇIKKEN)
------------------------------------------------
local function equipToolAfterDelay(char)
    if not resetEnabled then return end 
    task.spawn(function()
        task.wait(2)
        if isUnloaded or not resetEnabled or not char or not char.Parent then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local backpack = player:FindFirstChild("Backpack")
        if humanoid and backpack then
            local tool = backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function()
                    humanoid:EquipTool(tool)
                end)
            end
        end
    end)
end

------------------------------------------------
-- 3 SANİYE BOYUNCA KORUMA KALKANI (FORCEFIELD) GİTMEZSE RESET MANTIĞI
------------------------------------------------
local function checkForceFieldAndReset(char)
    task.spawn(function()
        task.wait(3) 
        if isUnloaded or not resetEnabled or not char or not char.Parent then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        
        local forceField = char:FindFirstChildOfClass("ForceField")
        if forceField then
            humanoid.Health = 0
        end
    end)
end

local function setupCharacter(char)
    if isUnloaded then return end
    stopPressingE()
    toolLoopActive = false
    local hum = char:WaitForChild("Humanoid")
    lastHealth = hum.Health
    
    RefreshCharRefs()
    if Shadow_Active then
        if Char and Char:FindFirstChild("Torso") and HRP then
            workspace.CurrentCamera.CameraSubject = HRP
            CacheAnimTrack()
        else
            DeactivateShadow()
        end
    end
    
    equipToolAfterDelay(char)
    checkForceFieldAndReset(char)
    
    task.spawn(startToolLoopForReset, char)
    local c1 = hum.HealthChanged:Connect(function(h) if resetEnabled and h < lastHealth then hum.Health = 0 end; lastHealth = h end)
    local c2 = hum.Died:Connect(function() toolLoopActive = false; if resetEnabled then startPressingE() end end)
    table.insert(RunningConnections, c1)
    table.insert(RunningConnections, c2)
end

local cAdd = player.CharacterAdded:Connect(setupCharacter)
table.insert(RunningConnections, cAdd)
if player.Character then setupCharacter(player.Character) end

------------------------------------------------
-- Shared bridge for split UI chunks
local _GS = _G.GreyShaderBridge or {}
_G.GreyShaderBridge = _GS
_GS['Players'] = Players
_G['Players'] = Players
_GS['UIS'] = UIS
_G['UIS'] = UIS
_GS['RunService'] = RunService
_G['RunService'] = RunService
_GS['ReplicatedStorage'] = ReplicatedStorage
_G['ReplicatedStorage'] = ReplicatedStorage
_GS['TweenService'] = TweenService
_G['TweenService'] = TweenService
_GS['CoreGui'] = CoreGui
_G['CoreGui'] = CoreGui
_GS['player'] = player
_G['player'] = player
_GS['Theme'] = Theme
_G['Theme'] = Theme
_GS['ColorObjects'] = ColorObjects
_G['ColorObjects'] = ColorObjects
_GS['isUnloaded'] = isUnloaded
_G['isUnloaded'] = isUnloaded
_GS['strafeEnabled'] = strafeEnabled
_G['strafeEnabled'] = strafeEnabled
_GS['resetEnabled'] = resetEnabled
_G['resetEnabled'] = resetEnabled
_GS['autoReloadEnabled'] = autoReloadEnabled
_G['autoReloadEnabled'] = autoReloadEnabled
_GS['autoClaimAllowanceEnabled'] = autoClaimAllowanceEnabled
_G['autoClaimAllowanceEnabled'] = autoClaimAllowanceEnabled
_GS['uiVisible'] = uiVisible
_G['uiVisible'] = uiVisible
_GS['toolLoopActive'] = toolLoopActive
_G['toolLoopActive'] = toolLoopActive
_GS['RunningConnections'] = RunningConnections
_G['RunningConnections'] = RunningConnections
_GS['Keybinds'] = Keybinds
_G['Keybinds'] = Keybinds
_GS['toggle_states'] = toggle_states
_G['toggle_states'] = toggle_states
_GS['setup_auto_reload'] = setup_auto_reload
_G['setup_auto_reload'] = setup_auto_reload
_GS['MeleeAura_Disable'] = MeleeAura_Disable
_G['MeleeAura_Disable'] = MeleeAura_Disable
_GS['MeleeAura_Enable'] = MeleeAura_Enable
_G['MeleeAura_Enable'] = MeleeAura_Enable
_GS['successHUD'] = successHUD
_G['successHUD'] = successHUD
_GS['pg'] = pg
_G['pg'] = pg
_GS['DeactivateShadow'] = DeactivateShadow
_G['DeactivateShadow'] = DeactivateShadow
_GS['ActivateShadow'] = ActivateShadow
_G['ActivateShadow'] = ActivateShadow
_GS['startToolLoopForReset'] = startToolLoopForReset
_G['startToolLoopForReset'] = startToolLoopForReset




-- [[ GREYSHADER UI BRIDGE ]] --
-- Export core state/functions so the separately loaded UI chunks can access them.
_G.GreyShaderBridge = _G.GreyShaderBridge or {}
_G.GreyShaderBridge['Players'] = Players
_G['Players'] = Players
_G.GreyShaderBridge['UIS'] = UIS
_G['UIS'] = UIS
_G.GreyShaderBridge['RunService'] = RunService
_G['RunService'] = RunService
_G.GreyShaderBridge['VirtualUser'] = VirtualUser
_G['VirtualUser'] = VirtualUser
_G.GreyShaderBridge['ReplicatedStorage'] = ReplicatedStorage
_G['ReplicatedStorage'] = ReplicatedStorage
_G.GreyShaderBridge['TweenService'] = TweenService
_G['TweenService'] = TweenService
_G.GreyShaderBridge['VIM'] = VIM
_G['VIM'] = VIM
_G.GreyShaderBridge['CoreGui'] = CoreGui
_G['CoreGui'] = CoreGui
_G.GreyShaderBridge['HttpService'] = HttpService
_G['HttpService'] = HttpService
_G.GreyShaderBridge['StarterGui'] = StarterGui
_G['StarterGui'] = StarterGui
_G.GreyShaderBridge['player'] = player
_G['player'] = player
_G.GreyShaderBridge['Theme'] = Theme
_G['Theme'] = Theme
_G.GreyShaderBridge['ColorObjects'] = ColorObjects
_G['ColorObjects'] = ColorObjects
_G.GreyShaderBridge['currentPresetName'] = currentPresetName
_G['currentPresetName'] = currentPresetName
_G.GreyShaderBridge['Presets'] = Presets
_G['Presets'] = Presets
_G.GreyShaderBridge['CONFIG_FILE'] = CONFIG_FILE
_G['CONFIG_FILE'] = CONFIG_FILE
_G.GreyShaderBridge['isUnloaded'] = isUnloaded
_G['isUnloaded'] = isUnloaded
_G.GreyShaderBridge['strafeEnabled'] = strafeEnabled
_G['strafeEnabled'] = strafeEnabled
_G.GreyShaderBridge['resetEnabled'] = resetEnabled
_G['resetEnabled'] = resetEnabled
_G.GreyShaderBridge['autoTP'] = autoTP
_G['autoTP'] = autoTP
_G.GreyShaderBridge['pressingE'] = pressingE
_G['pressingE'] = pressingE
_G.GreyShaderBridge['autoReloadEnabled'] = autoReloadEnabled
_G['autoReloadEnabled'] = autoReloadEnabled
_G.GreyShaderBridge['autoWalkEnabled'] = autoWalkEnabled
_G['autoWalkEnabled'] = autoWalkEnabled
_G.GreyShaderBridge['adminCheckEnabled'] = adminCheckEnabled
_G['adminCheckEnabled'] = adminCheckEnabled
_G.GreyShaderBridge['autoClaimAllowanceEnabled'] = autoClaimAllowanceEnabled
_G['autoClaimAllowanceEnabled'] = autoClaimAllowanceEnabled
_G.GreyShaderBridge['adminConnection'] = adminConnection
_G['adminConnection'] = adminConnection
_G.GreyShaderBridge['uiVisible'] = uiVisible
_G['uiVisible'] = uiVisible
_G.GreyShaderBridge['locations'] = locations
_G['locations'] = locations
_G.GreyShaderBridge['selectedLocation'] = selectedLocation
_G['selectedLocation'] = selectedLocation
_G.GreyShaderBridge['coordCount'] = coordCount
_G['coordCount'] = coordCount
_G.GreyShaderBridge['lastHealth'] = lastHealth
_G['lastHealth'] = lastHealth
_G.GreyShaderBridge['toolLoopActive'] = toolLoopActive
_G['toolLoopActive'] = toolLoopActive
_G.GreyShaderBridge['menuBindKey'] = menuBindKey
_G['menuBindKey'] = menuBindKey
_G.GreyShaderBridge['RunningConnections'] = RunningConnections
_G['RunningConnections'] = RunningConnections
_G.GreyShaderBridge['Keybinds'] = Keybinds
_G['Keybinds'] = Keybinds
_G.GreyShaderBridge['toggle_states'] = toggle_states
_G['toggle_states'] = toggle_states
_G.GreyShaderBridge['flyMethod'] = flyMethod
_G['flyMethod'] = flyMethod
_G.GreyShaderBridge['eventsFolder'] = eventsFolder
_G['eventsFolder'] = eventsFolder
_G.GreyShaderBridge['flyRemote'] = flyRemote
_G['flyRemote'] = flyRemote
_G.GreyShaderBridge['Shadow_Active'] = Shadow_Active
_G['Shadow_Active'] = Shadow_Active
_G.GreyShaderBridge['Shadow_Usable'] = Shadow_Usable
_G['Shadow_Usable'] = Shadow_Usable
_G.GreyShaderBridge['Char'] = Char
_G['Char'] = Char
_G.GreyShaderBridge['HMND'] = HMND
_G['HMND'] = HMND
_G.GreyShaderBridge['HRP'] = HRP
_G['HRP'] = HRP
_G.GreyShaderBridge['AnimTrack_Cache'] = AnimTrack_Cache
_G['AnimTrack_Cache'] = AnimTrack_Cache
_G.GreyShaderBridge['CamoAnim'] = CamoAnim
_G['CamoAnim'] = CamoAnim
_G.GreyShaderBridge['staffData'] = staffData
_G['staffData'] = staffData
_G.GreyShaderBridge['reload_event'] = reload_event
_G['reload_event'] = reload_event
_G.GreyShaderBridge['targetPlatformInstance'] = targetPlatformInstance
_G['targetPlatformInstance'] = targetPlatformInstance
_G.GreyShaderBridge['MeleeAura_Enabled'] = MeleeAura_Enabled
_G['MeleeAura_Enabled'] = MeleeAura_Enabled
_G.GreyShaderBridge['MeleeAura_Connection'] = MeleeAura_Connection
_G['MeleeAura_Connection'] = MeleeAura_Connection
_G.GreyShaderBridge['HUD'] = HUD
_G['HUD'] = HUD
_G.GreyShaderBridge['successHUD'] = successHUD
_G['successHUD'] = successHUD
_G.GreyShaderBridge['pg'] = pg
_G['pg'] = pg
_G.GreyShaderBridge['WarningText'] = WarningText
_G['WarningText'] = WarningText
_G.GreyShaderBridge['cAdd'] = cAdd
_G['cAdd'] = cAdd
_G.GreyShaderBridge['_GS'] = _GS
_G['_GS'] = _GS
_G.GreyShaderBridge['updateThemeColor'] = updateThemeColor
_G['updateThemeColor'] = updateThemeColor
_G.GreyShaderBridge['applyPreset'] = applyPreset
_G['applyPreset'] = applyPreset
_G.GreyShaderBridge['saveDefaultTheme'] = saveDefaultTheme
_G['saveDefaultTheme'] = saveDefaultTheme
_G.GreyShaderBridge['loadDefaultTheme'] = loadDefaultTheme
_G['loadDefaultTheme'] = loadDefaultTheme
_G.GreyShaderBridge['spawnTargetPlatformAtFeet'] = spawnTargetPlatformAtFeet
_G['spawnTargetPlatformAtFeet'] = spawnTargetPlatformAtFeet
_G.GreyShaderBridge['setup_auto_reload'] = setup_auto_reload
_G['setup_auto_reload'] = setup_auto_reload
_G.GreyShaderBridge['MeleeAura_Disable'] = MeleeAura_Disable
_G['MeleeAura_Disable'] = MeleeAura_Disable
_G.GreyShaderBridge['runAttackLoop'] = runAttackLoop
_G['runAttackLoop'] = runAttackLoop
_G.GreyShaderBridge['MeleeAura_Enable'] = MeleeAura_Enable
_G['MeleeAura_Enable'] = MeleeAura_Enable
_G.GreyShaderBridge['checkAndKick'] = checkAndKick
_G['checkAndKick'] = checkAndKick
_G.GreyShaderBridge['RefreshCharRefs'] = RefreshCharRefs
_G['RefreshCharRefs'] = RefreshCharRefs
_G.GreyShaderBridge['CheckGrounded'] = CheckGrounded
_G['CheckGrounded'] = CheckGrounded
_G.GreyShaderBridge['CacheAnimTrack'] = CacheAnimTrack
_G['CacheAnimTrack'] = CacheAnimTrack
_G.GreyShaderBridge['DeactivateShadow'] = DeactivateShadow
_G['DeactivateShadow'] = DeactivateShadow
_G.GreyShaderBridge['ActivateShadow'] = ActivateShadow
_G['ActivateShadow'] = ActivateShadow
_G.GreyShaderBridge['ShadowStep'] = ShadowStep
_G['ShadowStep'] = ShadowStep
_G.GreyShaderBridge['startPressingE'] = startPressingE
_G['startPressingE'] = startPressingE
_G.GreyShaderBridge['stopPressingE'] = stopPressingE
_G['stopPressingE'] = stopPressingE
_G.GreyShaderBridge['startToolLoopForReset'] = startToolLoopForReset
_G['startToolLoopForReset'] = startToolLoopForReset
_G.GreyShaderBridge['equipToolAfterDelay'] = equipToolAfterDelay
_G['equipToolAfterDelay'] = equipToolAfterDelay
_G.GreyShaderBridge['checkForceFieldAndReset'] = checkForceFieldAndReset
_G['checkForceFieldAndReset'] = checkForceFieldAndReset
_G.GreyShaderBridge['setupCharacter'] = setupCharacter
_G['setupCharacter'] = setupCharacter

-- Shared executor environment bridge for separately loaded UI chunks.
local _GSHARED = (getgenv and getgenv()) or _G
_GSHARED.GreyShaderBridge = _GSHARED.GreyShaderBridge or {}
local function _publish(name, value)
    _GSHARED.GreyShaderBridge[name] = value
    _GSHARED[name] = value
end

_publish("Players", Players)
_publish("UIS", UIS)
_publish("RunService", RunService)
_publish("VirtualUser", VirtualUser)
_publish("ReplicatedStorage", ReplicatedStorage)
_publish("TweenService", TweenService)
_publish("VIM", VIM)
_publish("CoreGui", CoreGui)
_publish("HttpService", HttpService)
_publish("StarterGui", StarterGui)
_publish("player", player)
_publish("Theme", Theme)
_publish("ColorObjects", ColorObjects)
_publish("isUnloaded", isUnloaded)
_publish("strafeEnabled", strafeEnabled)
_publish("resetEnabled", resetEnabled)
_publish("autoReloadEnabled", autoReloadEnabled)
_publish("autoClaimAllowanceEnabled", autoClaimAllowanceEnabled)
_publish("uiVisible", uiVisible)
_publish("toolLoopActive", toolLoopActive)
_publish("RunningConnections", RunningConnections)
_publish("Keybinds", Keybinds)
_publish("toggle_states", toggle_states)
_publish("successHUD", successHUD)
_publish("pg", pg)
_publish("coreGuiObj", coreGuiObj)
_publish("setup_auto_reload", setup_auto_reload)
_publish("MeleeAura_Disable", MeleeAura_Disable)
_publish("MeleeAura_Enable", MeleeAura_Enable)
_publish("DeactivateShadow", DeactivateShadow)
_publish("ActivateShadow", ActivateShadow)
_publish("startToolLoopForReset", startToolLoopForReset)
_publish("UnloadCheat", UnloadCheat)

-- [[ SPLIT UI LOADER ]] --
local UI1_URL = "https://raw.githubusercontent.com/sasahhahas-commits/asdasdasd/refs/heads/main/greyshader_ui1.lua"
local UI2_URL = "https://raw.githubusercontent.com/sasahhahas-commits/fsdwefsdfs/refs/heads/main/ui2.lua"

local function loadRemoteChunk(url)
    local ok, result = pcall(function()
        local source = game:HttpGet(url)
        local fn, err = loadstring(source)
        if not fn then error(err, 2) end
        return fn()
    end)
    if not ok then error(result, 2) end
    return result
end

loadRemoteChunk(UI1_URL)
loadRemoteChunk(UI2_URL)
