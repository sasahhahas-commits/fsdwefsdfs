-- Shared core references supplied by the main chunk.
local _GSHARED = (getgenv and getgenv()) or _G
local _GS = _GSHARED.GreyShaderBridge or {}
local Players = _GSHARED["Players"] ~= nil and _GSHARED["Players"] or _GS["Players"]
local UIS = _GSHARED["UIS"] ~= nil and _GSHARED["UIS"] or _GS["UIS"]
local RunService = _GSHARED["RunService"] ~= nil and _GSHARED["RunService"] or _GS["RunService"]
local VirtualUser = _GSHARED["VirtualUser"] ~= nil and _GSHARED["VirtualUser"] or _GS["VirtualUser"]
local ReplicatedStorage = _GSHARED["ReplicatedStorage"] ~= nil and _GSHARED["ReplicatedStorage"] or _GS["ReplicatedStorage"]
local TweenService = _GSHARED["TweenService"] ~= nil and _GSHARED["TweenService"] or _GS["TweenService"]
local VIM = _GSHARED["VIM"] ~= nil and _GSHARED["VIM"] or _GS["VIM"]
local CoreGui = _GSHARED["CoreGui"] ~= nil and _GSHARED["CoreGui"] or _GS["CoreGui"]
local HttpService = _GSHARED["HttpService"] ~= nil and _GSHARED["HttpService"] or _GS["HttpService"]
local StarterGui = _GSHARED["StarterGui"] ~= nil and _GSHARED["StarterGui"] or _GS["StarterGui"]
local player = _GSHARED["player"] ~= nil and _GSHARED["player"] or _GS["player"]
local Theme = _GSHARED["Theme"] ~= nil and _GSHARED["Theme"] or _GS["Theme"]
local ColorObjects = _GSHARED["ColorObjects"] ~= nil and _GSHARED["ColorObjects"] or _GS["ColorObjects"]
local isUnloaded = _GSHARED["isUnloaded"] ~= nil and _GSHARED["isUnloaded"] or _GS["isUnloaded"]
local strafeEnabled = _GSHARED["strafeEnabled"] ~= nil and _GSHARED["strafeEnabled"] or _GS["strafeEnabled"]
local resetEnabled = _GSHARED["resetEnabled"] ~= nil and _GSHARED["resetEnabled"] or _GS["resetEnabled"]
local autoReloadEnabled = _GSHARED["autoReloadEnabled"] ~= nil and _GSHARED["autoReloadEnabled"] or _GS["autoReloadEnabled"]
local autoClaimAllowanceEnabled = _GSHARED["autoClaimAllowanceEnabled"] ~= nil and _GSHARED["autoClaimAllowanceEnabled"] or _GS["autoClaimAllowanceEnabled"]
local uiVisible = _GSHARED["uiVisible"] ~= nil and _GSHARED["uiVisible"] or _GS["uiVisible"]
local toolLoopActive = _GSHARED["toolLoopActive"] ~= nil and _GSHARED["toolLoopActive"] or _GS["toolLoopActive"]
local RunningConnections = _GSHARED["RunningConnections"] ~= nil and _GSHARED["RunningConnections"] or _GS["RunningConnections"]
local Keybinds = _GSHARED["Keybinds"] ~= nil and _GSHARED["Keybinds"] or _GS["Keybinds"]
local toggle_states = _GSHARED["toggle_states"] ~= nil and _GSHARED["toggle_states"] or _GS["toggle_states"]
local successHUD = _GSHARED["successHUD"] ~= nil and _GSHARED["successHUD"] or _GS["successHUD"]
local pg = _GSHARED["pg"] ~= nil and _GSHARED["pg"] or _GS["pg"]
local coreGuiObj = _GSHARED["coreGuiObj"] ~= nil and _GSHARED["coreGuiObj"] or _GS["coreGuiObj"]
local setup_auto_reload = _GSHARED["setup_auto_reload"] ~= nil and _GSHARED["setup_auto_reload"] or _GS["setup_auto_reload"]
local MeleeAura_Disable = _GSHARED["MeleeAura_Disable"] ~= nil and _GSHARED["MeleeAura_Disable"] or _GS["MeleeAura_Disable"]
local MeleeAura_Enable = _GSHARED["MeleeAura_Enable"] ~= nil and _GSHARED["MeleeAura_Enable"] or _GS["MeleeAura_Enable"]
local DeactivateShadow = _GSHARED["DeactivateShadow"] ~= nil and _GSHARED["DeactivateShadow"] or _GS["DeactivateShadow"]
local ActivateShadow = _GSHARED["ActivateShadow"] ~= nil and _GSHARED["ActivateShadow"] or _GS["ActivateShadow"]
local startToolLoopForReset = _GSHARED["startToolLoopForReset"] ~= nil and _GSHARED["startToolLoopForReset"] or _GS["startToolLoopForReset"]
local UnloadCheat = _GSHARED["UnloadCheat"] ~= nil and _GSHARED["UnloadCheat"] or _GS["UnloadCheat"]

-- GUI CONSTRUCTION
------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "GreyShader_V8_Modern"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 100
gui.Parent = (successHUD and coreGuiObj) or pg
if not gui.Parent then
    warn("[GREYSHADER] PlayerGui/CoreGui bulunamadı.")
    return
end

local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
    return c
end

local function addPadding(obj, left, right, top, bottom)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.Parent = obj
    return p
end

local function tween(obj, duration, props, style, direction)
    local info = TweenInfo.new(
        duration or 0.22,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function hoverScale(button, normalSize, hoverSize)
    button.MouseEnter:Connect(function()
        tween(button, 0.14, {Size = hoverSize})
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.14, {Size = normalSize})
    end)
end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainWindow"
mainFrame.Size = UDim2.new(0, 760, 0, 520)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Theme.MainBg
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui
addCorner(mainFrame, 14)
mainFrame.Size = UDim2.new(0, 730, 0, 500)
mainFrame.BackgroundTransparency = 1
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 12)
table.insert(ColorObjects.MainBg, mainFrame)

local mainScale = Instance.new("UIScale")
mainScale.Scale = 0.96
mainScale.Parent = mainFrame

local menuAnimating = false

local function setMenuVisible(show)
    if menuAnimating or isUnloaded then return end
    menuAnimating = true

    if show then
        uiVisible = true
        mainFrame.Visible = true
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 10)
        mainFrame.BackgroundTransparency = 1
        mainScale.Scale = 0.96

        local t1 = tween(mainFrame, 0.25, {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 0
        }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        tween(mainScale, 0.25, {Scale = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        t1.Completed:Connect(function()
            menuAnimating = false
        end)
    else
        uiVisible = false

        local t1 = tween(mainFrame, 0.18, {
            Position = UDim2.new(0.5, 0, 0.5, 8),
            BackgroundTransparency = 1
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        tween(mainScale, 0.18, {Scale = 0.96}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        t1.Completed:Connect(function()
            if not uiVisible and mainFrame then
                mainFrame.Visible = false
                mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                mainFrame.BackgroundTransparency = 0
                mainScale.Scale = 1
            end
            menuAnimating = false
        end)
    end
end

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Theme.BorderBlue
mainStroke.Thickness = 1.2
mainStroke.Transparency = 0.25
mainStroke.Parent = mainFrame
table.insert(ColorObjects.BorderBlue, mainStroke)

-- Smooth startup: no full-screen image overlay, just a lightweight window tween.
task.defer(function()
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 10)
    mainScale.Scale = 0.96
    tween(mainFrame, 0.34, {
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    tween(mainScale, 0.34, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end)

-- External ImageLabel shadow intentionally removed: it can render a full-screen white overlay in some Roblox clients.
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 165, 1, 0)
sidebar.BackgroundColor3 = Theme.ContentBg
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3
sidebar.Parent = mainFrame
addPadding(sidebar, 12, 12, 14, 12)
table.insert(ColorObjects.ContentBg, sidebar)

local brand = Instance.new("TextLabel")
brand.Size = UDim2.new(1, 0, 0, 28)
brand.BackgroundTransparency = 1
brand.Text = "GREYSHADER"
brand.TextColor3 = Theme.TextColor
brand.Font = Enum.Font.GothamBold
brand.TextSize = 17
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.ZIndex = 4
brand.Parent = sidebar
table.insert(ColorObjects.TextColor, brand)

local brandSub = Instance.new("TextLabel")
brandSub.Size = UDim2.new(1, 0, 0, 18)
brandSub.Position = UDim2.new(0, 0, 0, 27)
brandSub.BackgroundTransparency = 1
brandSub.Text = "V8  •  CONTROL CENTER"
brandSub.TextColor3 = Theme.TextDim
brandSub.Font = Enum.Font.GothamMedium
brandSub.TextSize = 9
brandSub.TextXAlignment = Enum.TextXAlignment.Left
brandSub.ZIndex = 4
brandSub.Parent = sidebar
table.insert(ColorObjects.TextColor, brandSub)

local accent = Instance.new("Frame")
accent.Size = UDim2.new(0, 38, 0, 2)
accent.Position = UDim2.new(0, 0, 0, 52)
accent.BackgroundColor3 = Theme.BorderBlue
accent.BorderSizePixel = 0
accent.ZIndex = 4
accent.Parent = sidebar
addCorner(accent, 2)
table.insert(ColorObjects.BorderBlue, accent)

local nav = Instance.new("Frame")
nav.Name = "Navigation"
nav.Size = UDim2.new(1, 0, 1, -72)
nav.Position = UDim2.new(0, 0, 0, 68)
nav.BackgroundTransparency = 1
nav.ZIndex = 4
nav.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 6)
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Parent = nav

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -165, 1, 0)
contentFrame.Position = UDim2.new(0, 165, 0, 0)
contentFrame.BackgroundColor3 = Theme.MainBg
contentFrame.BorderSizePixel = 0
contentFrame.ZIndex = 3
contentFrame.Parent = mainFrame
table.insert(ColorObjects.MainBg, contentFrame)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 64)
topBar.BackgroundTransparency = 1
topBar.ZIndex = 4
topBar.Parent = contentFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "PageTitle"
titleLabel.Size = UDim2.new(1, -70, 0, 28)
titleLabel.Position = UDim2.new(0, 22, 0, 13)
titleLabel.Text = "Combat"
titleLabel.TextColor3 = Theme.TextColor
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 19
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.ZIndex = 5
titleLabel.Parent = topBar
table.insert(ColorObjects.TextColor, titleLabel)

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, -70, 0, 18)
subtitleLabel.Position = UDim2.new(0, 22, 0, 38)
subtitleLabel.Text = "Combat utilities and automation"
subtitleLabel.TextColor3 = Theme.TextDim
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 10
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.ZIndex = 5
subtitleLabel.Parent = topBar
table.insert(ColorObjects.TextColor, subtitleLabel)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -42, 0, 15)
closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.TextColor3 = Theme.TextDim
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.ZIndex = 5
closeButton.Parent = topBar
addCorner(closeButton, 8)
closeButton.MouseButton1Click:Connect(function()
    setMenuVisible(false)
end)

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -44, 0, 1)
divider.Position = UDim2.new(0, 22, 0, 63)
divider.BackgroundColor3 = Theme.OutlineColor
divider.BorderSizePixel = 0
divider.ZIndex = 4
divider.Parent = contentFrame
table.insert(ColorObjects.OutlineColor, divider)

local pageContainer = Instance.new("Frame")
pageContainer.Name = "Pages"
pageContainer.Size = UDim2.new(1, -44, 1, -80)
pageContainer.Position = UDim2.new(0, 22, 0, 72)
pageContainer.BackgroundTransparency = 1
pageContainer.ZIndex = 4
pageContainer.Parent = contentFrame

local pages, tabButtons = {}, {}
local activeTabButton = nil
local pageMeta = {
    Combat = {"⚔", "Combat utilities and automation"},
    Farm = {"◆", "Farming and automated actions"},
    Player = {"◉", "Movement and player controls"},
    Visual = {"◎", "ESP and visual player overlays"},
    Teleport = {"⌖", "Waypoints and teleport controls"},
    Misc = {"⚙", "Miscellaneous utilities"},
    Settings = {"☷", "Interface and theme settings"}
}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.BorderBlue
    page.ScrollBarImageTransparency = 0.35
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.ZIndex = 4
    page.Parent = pageContainer

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    addPadding(page, 2, 8, 2, 12)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)

    pages[name] = page

    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name .. "Tab"
    tabBtn.Size = UDim2.new(1, 0, 0, 38)
    tabBtn.BackgroundColor3 = Theme.TabInactive
    tabBtn.BackgroundTransparency = 0.35
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.ZIndex = 5
    tabBtn.Parent = nav
    addCorner(tabBtn, 8)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 28, 1, 0)
    icon.Position = UDim2.new(0, 8, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = pageMeta[name] and pageMeta[name][1] or "•"
    icon.TextColor3 = Theme.TextDim
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 14
    icon.ZIndex = 6
    icon.Parent = tabBtn

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -42, 1, 0)
    text.Position = UDim2.new(0, 38, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = name
    text.TextColor3 = Theme.TextDim
    text.Font = Enum.Font.GothamMedium
    text.TextSize = 12
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.ZIndex = 6
    text.Parent = tabBtn

    tabButtons[name] = tabBtn

    tabBtn.MouseEnter:Connect(function()
        if tabButtons[name] ~= activeTabButton then
            tween(tabBtn, 0.12, {BackgroundTransparency = 0.12})
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if tabButtons[name] ~= activeTabButton then
            tween(tabBtn, 0.12, {BackgroundTransparency = 0.35})
        end
    end)

    tabBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(pages) do
            if v ~= page then v.Visible = false end
        end
        for k, v in pairs(tabButtons) do
            v.BackgroundColor3 = Theme.TabInactive
            v.BackgroundTransparency = 0.35
            local labels = {}
            for _, child in ipairs(v:GetChildren()) do
                if child:IsA("TextLabel") then table.insert(labels, child) end
            end
            for _, child in ipairs(labels) do child.TextColor3 = Theme.TextDim end
        end

        activeTabButton = tabBtn
        page.Visible = true
        tabBtn.BackgroundColor3 = Theme.TabActive
        tabBtn.BackgroundTransparency = 0
        text.TextColor3 = Theme.TextColor
        icon.TextColor3 = Theme.BorderBlue
        titleLabel.Text = name
        subtitleLabel.Text = pageMeta[name] and pageMeta[name][2] or ""

        page.Position = UDim2.new(0, 12, 0, 0)
        tween(page, 0.22, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quart)
    end)
end

createPage("Combat")
createPage("Farm")
createPage("Player")
createPage("Visual")
createPage("Teleport")
createPage("Misc")
createPage("Settings")
pages["Combat"].Visible = true
activeTabButton = tabButtons["Combat"]
tabButtons["Combat"].BackgroundColor3 = Theme.TabActive
tabButtons["Combat"].BackgroundTransparency = 0
tabButtons["Combat"]:FindFirstChildWhichIsA("TextLabel").TextColor3 = Theme.TextColor
local combatIcon = tabButtons["Combat"]:FindFirstChildWhichIsA("TextLabel")
if combatIcon then combatIcon.TextColor3 = Theme.BorderBlue end

pages["Teleport"]:ClearAllChildren()
pages["Settings"]:ClearAllChildren()

------------------------------------------------
-- MODERN TOGGLE / CHECKBOX CREATOR
------------------------------------------------
local function createCheckbox(parentPage, text, callback, useKeybind)
    local container = Instance.new("Frame")
    container.Name = "Option_" .. text:gsub("%W", "")
    container.Size = UDim2.new(1, -4, 0, useKeybind and 58 or 48)
    container.BackgroundColor3 = Theme.ContentBg
    container.BackgroundTransparency = 0.15
    container.BorderSizePixel = 0
    container.Parent = parentPage
    container.ZIndex = 5
    addCorner(container, 9)
    table.insert(ColorObjects.ContentBg, container)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.OutlineColor
    stroke.Thickness = 1
    stroke.Transparency = 0.25
    stroke.Parent = container
    table.insert(ColorObjects.OutlineColor, stroke)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -145, 0, 22)
    label.Position = UDim2.new(0, 16, 0, useKeybind and 8 or 13)
    label.Text = text
    label.TextColor3 = Theme.TextColor
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ZIndex = 6
    label.Parent = container
    table.insert(ColorObjects.TextColor, label)

    local active = false
    local currentKey = nil
    local listening = false

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 42, 0, 22)
    box.Position = UDim2.new(1, -58, 0, 13)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    box.BorderSizePixel = 0
    box.Text = ""
    box.AutoButtonColor = false
    box.ZIndex = 7
    box.Parent = container
    addCorner(box, 11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(210, 210, 215)
    knob.BorderSizePixel = 0
    knob.ZIndex = 8
    knob.Parent = box
    addCorner(knob, 8)

    local function toggleState(forcedState)
        if isUnloaded then return end
        if forcedState ~= nil then active = forcedState else active = not active end

        if active then
            box.BackgroundColor3 = Theme.BorderBlue
            TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -19, 0.5, -8)
            }):Play()
        else
            box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 3, 0.5, -8)
            }):Play()
        end
        callback(active)
    end

    box.MouseButton1Click:Connect(function() toggleState() end)

    if useKeybind then
        local bindBtn = Instance.new("TextButton")
        bindBtn.Size = UDim2.new(0, 90, 0, 20)
        bindBtn.Position = UDim2.new(0, 16, 0, 32)
        bindBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        bindBtn.BorderSizePixel = 0
        bindBtn.Text = "KEYBIND: NONE"
        bindBtn.TextColor3 = Theme.TextDim
        bindBtn.Font = Enum.Font.GothamMedium
        bindBtn.TextSize = 9
        bindBtn.AutoButtonColor = false
        bindBtn.ZIndex = 7
        bindBtn.Parent = container
        addCorner(bindBtn, 6)

        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0, 20, 0, 20)
        cancelBtn.Position = UDim2.new(0, 112, 0, 32)
        cancelBtn.BackgroundColor3 = Color3.fromRGB(80, 35, 40)
        cancelBtn.BorderSizePixel = 0
        cancelBtn.Text = "×"
        cancelBtn.TextColor3 = Color3.fromRGB(235, 180, 185)
        cancelBtn.Font = Enum.Font.GothamBold
        cancelBtn.TextSize = 12
        cancelBtn.Visible = false
        cancelBtn.ZIndex = 7
        cancelBtn.Parent = container
        addCorner(cancelBtn, 6)

        bindBtn.MouseButton1Click:Connect(function()
            if listening or isUnloaded then return end
            listening = true
            bindBtn.Text = "PRESS A KEY..."
            bindBtn.TextColor3 = Theme.BorderBlue
        end)

        cancelBtn.MouseButton1Click:Connect(function()
            if currentKey then Keybinds[currentKey] = nil; currentKey = nil end
            listening = false
            bindBtn.Text = "KEYBIND: NONE"
            bindBtn.TextColor3 = Theme.TextDim
            cancelBtn.Visible = false
        end)

        local cBind = UIS.InputBegan:Connect(function(input, gpe)
            if listening and not gpe and not isUnloaded and input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                if currentKey then Keybinds[currentKey] = nil end
                currentKey = input.KeyCode
                bindBtn.Text = "KEYBIND: " .. currentKey.Name:upper()
                bindBtn.TextColor3 = Theme.TextColor
                cancelBtn.Visible = true
                Keybinds[currentKey] = function() toggleState() end
            end
        end)
        table.insert(RunningConnections, cBind)
    end

    return box
end
-- PAGES CONTENT INTERFACES
------------------------------------------------
createCheckbox(pages["Combat"], "Auto Reload", function(state) 
    autoReloadEnabled = state 
    if autoReloadEnabled then
        setup_auto_reload()
    end
end, true)

createCheckbox(pages["Combat"], "Melee Aura", function(state) 
    if state then
        MeleeAura_Enable()
    else
        MeleeAura_Disable()
    end
end, true)

------------------------------------------------
-- AIM ASSIST (DÜZELTİLMİŞ LAYOUT)
------------------------------------------------
local aimEnabled = false
local aimTeamCheck = true
local aimWallCheck = true
local aimPartName = "Head"
local aimTarget = nil
local aimHolding = false
local aimConnection = nil

local function aimTargetVisible(part, character)
    if not aimWallCheck then return true end
    local camera = workspace.CurrentCamera
    if not camera or not part or not character then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character, character}
    params.IgnoreWater = true

    return workspace:Raycast(camera.CFrame.Position, part.Position - camera.CFrame.Position, params) == nil
end

local function findAimTarget()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local mousePos = UIS:GetMouseLocation()
    local closest, closestDistance = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(aimPartName)

            local sameTeam = aimTeamCheck and player.Team and plr.Team and player.Team == plr.Team

            if not sameTeam and hum and hum.Health > 0 and part and aimTargetVisible(part, char) then
                local screen, onScreen = camera:WorldToScreenPoint(part.Position)
                if onScreen then
                    local distance = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closest = plr
                    end
                end
            end
        end
    end

    return closest
end

local function stopAimAssist()
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
    aimTarget = nil
end

local function startAimAssist()
    stopAimAssist()

    aimConnection = RunService.RenderStepped:Connect(function()
        if not aimEnabled or not aimHolding or isUnloaded then return end

        local camera = workspace.CurrentCamera
        if not camera then return end

        if not aimTarget or not aimTarget.Character then
            aimTarget = findAimTarget()
        end

        local char = aimTarget and aimTarget.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local part = char and char:FindFirstChild(aimPartName)

        if not hum or hum.Health <= 0 or not part or not aimTargetVisible(part, char) then
            aimTarget = findAimTarget()
            char = aimTarget and aimTarget.Character
            part = char and char:FindFirstChild(aimPartName)
        end

        if part then
            local predicted = part.Position
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                predicted = predicted + root.AssemblyLinearVelocity * 0.08
            end
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, predicted)
        end
    end)
end

-- [[ DÜZELTİLMİŞ AIM ASSIST KARTI ]] --
local aimCard = createCheckbox(pages["Combat"], "Aim Assist", function(state)
    aimEnabled = state
    if state then
        startAimAssist()
    else
        stopAimAssist()
    end
end, false)

-- 1. Container'ı (Frame) büyüt
local container = aimCard.Parent
container.Size = UDim2.new(1, -4, 0, 72)

-- 2. Toggle butonunun boyutunu eski haline getir (42x22)
aimCard.Size = UDim2.new(0, 42, 0, 22)
-- [[ DÜZELTME SONU ]] --

local aimInfo = Instance.new("TextLabel")
aimInfo.Size = UDim2.new(0, 160, 0, 16)
aimInfo.Position = UDim2.new(0, 16, 0, 43) -- Container içinde
aimInfo.BackgroundTransparency = 1
aimInfo.Text = "Hold RMB  •  " .. aimPartName
aimInfo.TextColor3 = Theme.TextDim
aimInfo.Font = Enum.Font.GothamMedium
aimInfo.TextSize = 9
aimInfo.TextXAlignment = Enum.TextXAlignment.Left
aimInfo.ZIndex = 7
aimInfo.Parent = container -- Ebeveyn container

local function aimOption(text, x, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 68, 0, 22)
    btn.Position = UDim2.new(1, x, 0, 40) -- Container içinde
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Theme.TextDim
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 9
    btn.AutoButtonColor = false
    btn.ZIndex = 8
    btn.Parent = container -- Ebeveyn container
    addCorner(btn, 6)
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

aimOption("Team: ON", -220, function(btn)
    aimTeamCheck = not aimTeamCheck
    btn.Text = "Team: " .. (aimTeamCheck and "ON" or "OFF")
end)

aimOption("Wall: ON", -145, function(btn)
    aimWallCheck = not aimWallCheck
    btn.Text = "Wall: " .. (aimWallCheck and "ON" or "OFF")
end)

aimOption("Part: Head", -70, function(btn)
    aimPartName = aimPartName == "Head" and "HumanoidRootPart" or "Head"
    btn.Text = aimPartName == "Head" and "Part: Head" or "Part: Root"
    aimInfo.Text = "Hold RMB  •  " .. aimPartName
end)

local cAimDown = UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimHolding = true
        if aimEnabled then
            aimTarget = findAimTarget()
        end
    end
end)

local cAimUp = UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimHolding = false
        aimTarget = nil
    end
end)

table.insert(RunningConnections, cAimDown)
table.insert(RunningConnections, cAimUp)

local strafeCard = createCheckbox(pages["Farm"], "Player Strafe", function(state)
    strafeEnabled = state
end, true)

local targetCard = Instance.new("Frame")
targetCard.Name = "TargetPlayerCard"
targetCard.Size = UDim2.new(1, -4, 0, 48)
targetCard.BackgroundColor3 = Theme.ContentBg
targetCard.BackgroundTransparency = 0.08
targetCard.BorderSizePixel = 0
targetCard.Parent = pages["Farm"]
targetCard.ZIndex = 5
targetCard.Position = UDim2.new(0, 0, 0, -8)
addCorner(targetCard, 9)
table.insert(ColorObjects.ContentBg, targetCard)

local targetStroke = Instance.new("UIStroke")
targetStroke.Color = Theme.OutlineColor
targetStroke.Thickness = 1
targetStroke.Transparency = 0.2
targetStroke.Parent = targetCard
table.insert(ColorObjects.OutlineColor, targetStroke)

local targetTitle = Instance.new("TextLabel")
targetTitle.Size = UDim2.new(0.42, 0, 0, 18)
targetTitle.Position = UDim2.new(0, 14, 0, 5)
targetTitle.Text = "Target Player"
targetTitle.TextColor3 = Theme.TextColor
targetTitle.Font = Enum.Font.GothamMedium
targetTitle.TextSize = 12
targetTitle.TextXAlignment = Enum.TextXAlignment.Left
targetTitle.BackgroundTransparency = 1
targetTitle.Parent = targetCard
targetTitle.ZIndex = 6
table.insert(ColorObjects.TextColor, targetTitle)

local targetHint = Instance.new("TextLabel")
targetHint.Size = UDim2.new(0.42, 0, 0, 15)
targetHint.Position = UDim2.new(0, 14, 0, 24)
targetHint.Text = "Username to follow"
targetHint.TextColor3 = Theme.TextDim
targetHint.Font = Enum.Font.Gotham
targetHint.TextSize = 9
targetHint.TextXAlignment = Enum.TextXAlignment.Left
targetHint.BackgroundTransparency = 1
targetHint.Parent = targetCard
targetHint.ZIndex = 6

local targetBox = Instance.new("TextBox")
targetBox.Size = UDim2.new(0, 190, 0, 30)
targetBox.Position = UDim2.new(1, -204, 0.5, -15)
targetBox.BackgroundColor3 = Color3.fromRGB(17, 17, 19)
targetBox.BorderSizePixel = 0
targetBox.Text = ""
targetBox.PlaceholderText = "Enter username..."
targetBox.PlaceholderColor3 = Theme.TextDim
targetBox.TextColor3 = Theme.TextColor
targetBox.Font = Enum.Font.Gotham
targetBox.TextSize = 11
targetBox.ClearTextOnFocus = false
targetBox.Parent = targetCard
targetBox.ZIndex = 7
addCorner(targetBox, 7)
local targetBoxStroke = Instance.new("UIStroke")
targetBoxStroke.Color = Theme.OutlineColor
targetBoxStroke.Transparency = 0.1
targetBoxStroke.Parent = targetBox
table.insert(ColorObjects.OutlineColor, targetBoxStroke)
table.insert(ColorObjects.TextColor, targetBox)

createCheckbox(pages["Farm"], "Auto Reset Loop", function(state)
    resetEnabled = state
    if resetEnabled and player.Character then toolLoopActive = false; task.spawn(startToolLoopForReset, player.Character) else toolLoopActive = false end
end, true)

createCheckbox(pages["Farm"], "Auto claim allowance", function(state)
    autoClaimAllowanceEnabled = state
    if not autoClaimAllowanceEnabled then
        if RunningConnections["AutoClaimAllowance"] then
            RunningConnections["AutoClaimAllowance"]:Disconnect()
            RunningConnections["AutoClaimAllowance"] = nil
        end
    else
        local find_nearest_atm = function(max_distance)
            local closest_part = nil
            local atmFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("ATMz")
            if not atmFolder then return nil end
            for _, atm in ipairs(atmFolder:GetChildren()) do
                if atm:FindFirstChild("MainPart") and (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                    local distance = (player.Character.HumanoidRootPart.Position - atm:FindFirstChild("MainPart").Position).Magnitude
                    if distance < max_distance then
                        closest_part = atm:FindFirstChild("MainPart")
                        max_distance = distance
                    end
                end
            end
            return closest_part
        end
        
        local connection = RunService.RenderStepped:Connect(function()
            if not autoClaimAllowanceEnabled then return end
            local dataFolder = ReplicatedStorage:FindFirstChild("PlayerbaseData2")
            if dataFolder and dataFolder:FindFirstChild(player.Name) then
                local nextAllowance = dataFolder[player.Name]:FindFirstChild("NextAllowance")
                if nextAllowance and nextAllowance.Value == 0 then
                    local atm_part = find_nearest_atm(math.huge)
                    if atm_part then
                        local events = ReplicatedStorage:FindFirstChild("Events")
                        if events and events:FindFirstChild("CLMZALOW") then
                            events.CLMZALOW:InvokeServer(atm_part)
                        end
                    end
                end
            end
        end)
        RunningConnections["AutoClaimAllowance"] = connection
    end
end, true)

createCheckbox(pages["Player"], "Fast pickup", function(state, ...)
    toggle_states.FastPickup = state;
    game.DescendantAdded:Connect(function(descendant, ...)
        local prompt = descendant;
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0;
            prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function(...)
                if toggle_states.FastPickup then
                    prompt.HoldDuration = 0;
                end;
                return;
            end);
        end;
        return;
    end);
    return;
end, true)

local noclipOriginalCollision = {}

createCheckbox(pages["Player"], "Noclip", function(state)
    toggle_states.Noclip = state

    if RunningConnections["Noclip"] then
        RunningConnections["Noclip"]:Disconnect()
        RunningConnections["Noclip"] = nil
    end

    local char = player.Character

    if not state then
        for part, original in pairs(noclipOriginalCollision) do
            if part and part.Parent and part:IsA("BasePart") then
                part.CanCollide = original
            end
        end
        table.clear(noclipOriginalCollision)
        return
    end

    if char then
        for _, descendant in ipairs(char:GetDescendants()) do
            if descendant:IsA("BasePart") and noclipOriginalCollision[descendant] == nil then
                noclipOriginalCollision[descendant] = descendant.CanCollide
            end
        end
    end

    RunningConnections["Noclip"] = RunService.Stepped:Connect(function()
        if not toggle_states.Noclip then return end
        local currentChar = player.Character
        if not currentChar then return end

        for _, descendant in ipairs(currentChar:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if noclipOriginalCollision[descendant] == nil then
                    noclipOriginalCollision[descendant] = descendant.CanCollide
                end
                descendant.CanCollide = false
            end
        end
    end)
end, true)

createCheckbox(pages["Player"], "Infinity Stamina", function(state)
    toggle_states.InfStamina = state

    if not hook_table then
        hook_table = {}
    end

    if hook_table.InfStamina then
        return
    end

    local stamina_function = getrenv()._G.S_Take
    if not stamina_function then
        return
    end

    local upvalue_table = getupvalue(stamina_function, 2)
    if not upvalue_table then
        return
    end

    for _, upvalue in pairs(getupvalues(upvalue_table)) do
        if type(upvalue) == "function" then
            local info = debug.getinfo(upvalue)

            if info and info.name == "Upt_S" then
                hook_table.InfStamina = hookfunction(upvalue, function(...)
                    if toggle_states.InfStamina then
                        getupvalue(upvalue_table, 7).S = 100
                    end

                    return hook_table.InfStamina(...)
                end)

                break
            end
        end
    end
end, true)

createCheckbox(pages["Player"], "Shadow Mode", function(state) if state then ActivateShadow() else DeactivateShadow() end end, true)

local visualLayout = Instance.new("UIListLayout")
visualLayout.Padding = UDim.new(0, 8)
visualLayout.Parent = pages["Visual"]

local visualInfo = Instance.new("Frame")
visualInfo.Size = UDim2.new(1, -4, 0, 56)
visualInfo.BackgroundColor3 = Theme.ContentBg
visualInfo.BackgroundTransparency = 0.08
visualInfo.BorderSizePixel = 0
visualInfo.Parent = pages["Visual"]
addCorner(visualInfo, 9)
table.insert(ColorObjects.ContentBg, visualInfo)

local visualInfoTitle = Instance.new("TextLabel")
visualInfoTitle.Size = UDim2.new(1, -28, 0, 20)
visualInfoTitle.Position = UDim2.new(0, 14, 0, 8)
visualInfoTitle.Text = "Player Visuals"
visualInfoTitle.TextColor3 = Theme.TextColor
visualInfoTitle.Font = Enum.Font.GothamBold
visualInfoTitle.TextSize = 13
visualInfoTitle.TextXAlignment = Enum.TextXAlignment.Left
visualInfoTitle.BackgroundTransparency = 1
visualInfoTitle.Parent = visualInfo
table.insert(ColorObjects.TextColor, visualInfoTitle)

local visualInfoSub = Instance.new("TextLabel")
visualInfoSub.Size = UDim2.new(1, -28, 0, 16)
visualInfoSub.Position = UDim2.new(0, 14, 0, 29)
visualInfoSub.Text = "Name, health, distance and team filtering."
visualInfoSub.TextColor3 = Theme.TextDim
visualInfoSub.Font = Enum.Font.Gotham
visualInfoSub.TextSize = 10
visualInfoSub.TextXAlignment = Enum.TextXAlignment.Left
visualInfoSub.BackgroundTransparency = 1
visualInfoSub.Parent = visualInfo

--------------------------------------------------

-- Export UI1 objects/functions for the second UI chunk
local _GS = _G.GreyShaderBridge or {}
_G.GreyShaderBridge = _GS
_GS['gui'] = gui
_G['gui'] = gui
_GS['addCorner'] = addCorner
_G['addCorner'] = addCorner
_GS['addPadding'] = addPadding
_G['addPadding'] = addPadding
_GS['tween'] = tween
_G['tween'] = tween
_GS['mainFrame'] = mainFrame
_G['mainFrame'] = mainFrame
_GS['setMenuVisible'] = setMenuVisible
_G['setMenuVisible'] = setMenuVisible
_GS['accent'] = accent
_G['accent'] = accent
_GS['pages'] = pages
_G['pages'] = pages
_GS['createCheckbox'] = createCheckbox
_G['createCheckbox'] = createCheckbox
_GS['targetBox'] = targetBox
_G['targetBox'] = targetBox
