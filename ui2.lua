-- ADVANCED PLAYER ESP
--------------------------------------------------
local playerEspObjects = {}
local espMaxDistance = 3000

local espGui = Instance.new("ScreenGui")
espGui.Name = "GreyShader_ESP"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espGui.DisplayOrder = 95
espGui.Parent = (successHUD and coreGuiObj) or player:FindFirstChildOfClass("PlayerGui")

local espLayer = Instance.new("Frame")
espLayer.Name = "ESP_Layer"
espLayer.Size = UDim2.fromScale(1, 1)
espLayer.BackgroundTransparency = 1
espLayer.BorderSizePixel = 0
espLayer.Parent = espGui

local function setLine(frame, fromPos, toPos, thickness)
    local delta = toPos - fromPos
    local length = delta.Magnitude
    if length < 1 then
        frame.Visible = false
        return
    end
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.fromOffset((fromPos.X + toPos.X) / 2, (fromPos.Y + toPos.Y) / 2)
    frame.Size = UDim2.fromOffset(length, thickness or 2)
    frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
    frame.Visible = true
end

local function makeEspLine()
    local f = Instance.new("Frame")
    f.BackgroundColor3 = Theme.BorderBlue
    f.BorderSizePixel = 0
    f.Visible = false
    f.ZIndex = 3
    f.Parent = espLayer
    return f
end

local function makeEspBox()
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.ZIndex = 2
    box.Parent = espLayer

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Theme.BorderBlue
    stroke.Parent = box

    local hpBack = Instance.new("Frame")
    hpBack.Name = "HealthBack"
    hpBack.Size = UDim2.new(0, 4, 1, 0)
    hpBack.Position = UDim2.new(0, -8, 0, 0)
    hpBack.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    hpBack.BorderSizePixel = 0
    hpBack.Visible = false
    hpBack.Parent = box

    local hpFill = Instance.new("Frame")
    hpFill.Name = "HealthFill"
    hpFill.AnchorPoint = Vector2.new(0, 1)
    hpFill.Position = UDim2.new(0, 0, 1, 0)
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(80, 220, 110)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBack

    return box, stroke, hpBack, hpFill
end

local function cleanupEspPlayer(plr)
    local data = playerEspObjects[plr]
    if not data then return end

    if data.info then pcall(function() data.info:Destroy() end) end
    if data.highlight then pcall(function() data.highlight:Destroy() end) end
    if data.box then pcall(function() data.box:Destroy() end) end
    if data.tracer then pcall(function() data.tracer:Destroy() end) end
    if data.skeleton then
        for _, line in pairs(data.skeleton) do
            pcall(function() line:Destroy() end)
        end
    end
    playerEspObjects[plr] = nil
end

local function cleanupAllEsp()
    for plr in pairs(playerEspObjects) do
        cleanupEspPlayer(plr)
    end
end

local function getEspData(plr)
    local data = playerEspObjects[plr]
    if data then return data end

    local info = Instance.new("BillboardGui")
    info.Name = "Info"
    info.Size = UDim2.fromOffset(190, 52)
    info.StudsOffsetWorldSpace = Vector3.new(0, 3.4, 0)
    info.AlwaysOnTop = true
    info.Enabled = false
    info.Parent = espGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Theme.Font
    label.TextSize = 11
    label.TextColor3 = Theme.TextColor
    label.TextStrokeTransparency = 0.25
    label.TextWrapped = true
    label.Parent = info

    local box, boxStroke, hpBack, hpFill = makeEspBox()
    local tracer = makeEspLine()
    tracer.ZIndex = 1

    local skeleton = {}
    for i = 1, 5 do
        skeleton[i] = makeEspLine()
        skeleton[i].ZIndex = 2
    end

    data = {
        info = info,
        label = label,
        box = box,
        boxStroke = boxStroke,
        hpBack = hpBack,
        hpFill = hpFill,
        tracer = tracer,
        skeleton = skeleton,
        highlight = nil
    }
    playerEspObjects[plr] = data
    return data
end

local function hideEspData(data)
    if not data then return end
    if data.info then data.info.Enabled = false end
    if data.box then data.box.Visible = false end
    if data.tracer then data.tracer.Visible = false end
    if data.hpBack then data.hpBack.Visible = false end
    for _, line in pairs(data.skeleton or {}) do
        line.Visible = false
    end
    if data.highlight then data.highlight.Enabled = false end
end

createCheckbox(pages["Visual"], "Player ESP", function(state)
    toggle_states.PlayerESP = state
    if not state then cleanupAllEsp() end
end, true)

createCheckbox(pages["Visual"], "Team Check", function(state)
    toggle_states.TeamCheck = state
end, true)

createCheckbox(pages["Visual"], "ESP Box", function(state)
    toggle_states.ESPBox = state
end)

createCheckbox(pages["Visual"], "ESP Names", function(state)
    toggle_states.ESPNames = state
end)

createCheckbox(pages["Visual"], "ESP Health", function(state)
    toggle_states.ESPHealth = state
end)

createCheckbox(pages["Visual"], "ESP Distance", function(state)
    toggle_states.ESPDistance = state
end)

createCheckbox(pages["Visual"], "ESP Tracer", function(state)
    toggle_states.ESPTracer = state
end)

createCheckbox(pages["Visual"], "ESP Chams", function(state)
    toggle_states.ESPChams = state
    if not state then
        for _, data in pairs(playerEspObjects) do
            if data.highlight then
                data.highlight.Enabled = false
            end
        end
    end
end)

createCheckbox(pages["Visual"], "ESP Skeleton", function(state)
    toggle_states.ESPSkeleton = state
end)

createCheckbox(pages["Visual"], "ESP Tool", function(state)
    toggle_states.ESPTool = state
end)

local playerEspConnection = RunService.RenderStepped:Connect(function()
    if isUnloaded then return end

    if not toggle_states.PlayerESP then
        for _, data in pairs(playerEspObjects) do hideEspData(data) end
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then
            cleanupEspPlayer(plr)
            continue
        end

        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")

        local sameTeam = toggle_states.TeamCheck
            and player.Team ~= nil
            and plr.Team ~= nil
            and player.Team == plr.Team

        if not char or not hum or not hrp or not head or hum.Health <= 0 or sameTeam then
            hideEspData(playerEspObjects[plr])
            continue
        end

        local distance = (cam.CFrame.Position - hrp.Position).Magnitude
        if distance > espMaxDistance then
            hideEspData(playerEspObjects[plr])
            continue
        end

        local top3, topOn = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
        local bottom3, bottomOn = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        local hrp3, hrpOn = cam:WorldToViewportPoint(hrp.Position)

        local data = getEspData(plr)
        local visible = topOn and bottomOn and hrpOn

        if not visible then
            hideEspData(data)
            continue
        end

        local top = Vector2.new(top3.X, top3.Y)
        local bottom = Vector2.new(bottom3.X, bottom3.Y)
        local height = math.max(12, math.abs(bottom.Y - top.Y))
        local width = math.max(8, height * 0.48)
        local boxPos = Vector2.new((top.X + bottom.X) / 2 - width / 2, top.Y)

        if toggle_states.ESPBox then
            data.box.Position = UDim2.fromOffset(boxPos.X, boxPos.Y)
            data.box.Size = UDim2.fromOffset(width, height)
            data.boxStroke.Color = plr.TeamColor.Color
            data.box.Visible = true
        else
            data.box.Visible = false
        end

        if toggle_states.ESPHealth then
            local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            data.hpBack.Visible = true
            data.hpFill.Size = UDim2.new(1, 0, ratio, 0)
            data.hpFill.BackgroundColor3 = Color3.fromHSV(ratio * 0.33, 1, 1)
        else
            data.hpBack.Visible = false
        end

        local parts = {}
        if toggle_states.ESPNames or toggle_states.ESPDistance or toggle_states.ESPTool then
            local textParts = {}
            if toggle_states.ESPNames then
                table.insert(textParts, plr.DisplayName ~= plr.Name
                    and (plr.DisplayName .. "  @" .. plr.Name)
                    or plr.Name)
            end
            if toggle_states.ESPHealth then
                table.insert(textParts, "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth))
            end
            if toggle_states.ESPDistance then
                table.insert(textParts, math.floor(distance) .. "m")
            end
            if toggle_states.ESPTool then
                local tool = char:FindFirstChildOfClass("Tool")
                table.insert(textParts, "Tool: " .. (tool and tool.Name or "None"))
            end

            data.label.Text = table.concat(textParts, "\n")
            data.label.TextColor3 = plr.TeamColor.Color
            data.info.Adornee = head
            data.info.Enabled = #textParts > 0
        else
            data.info.Enabled = false
        end

        if toggle_states.ESPTracer then
            setLine(
                data.tracer,
                Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y - 4),
                Vector2.new(hrp3.X, hrp3.Y),
                1.5
            )
            data.tracer.BackgroundColor3 = plr.TeamColor.Color
        else
            data.tracer.Visible = false
        end

        if toggle_states.ESPSkeleton then
            local r15 = {
                Head = head,
                UpperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
                LowerTorso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso"),
                LeftUpperArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
                LeftLowerArm = char:FindFirstChild("LeftLowerArm") or char:FindFirstChild("Left Arm"),
                RightUpperArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
                RightLowerArm = char:FindFirstChild("RightLowerArm") or char:FindFirstChild("Right Arm"),
                LeftUpperLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
                LeftLowerLeg = char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("Left Leg"),
                RightUpperLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
                RightLowerLeg = char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("Right Leg")
            }

            local chains = {
                {r15.Head, r15.UpperTorso},
                {r15.UpperTorso, r15.LowerTorso},
                {r15.UpperTorso, r15.LeftUpperArm},
                {r15.LeftUpperArm, r15.LeftLowerArm},
                {r15.UpperTorso, r15.RightUpperArm},
                {r15.RightUpperArm, r15.RightLowerArm},
                {r15.LowerTorso, r15.LeftUpperLeg},
                {r15.LeftUpperLeg, r15.LeftLowerLeg},
                {r15.LowerTorso, r15.RightUpperLeg},
                {r15.RightUpperLeg, r15.RightLowerLeg}
            }

            for i, line in ipairs(data.skeleton) do
                local pair = chains[i]
                if pair and pair[1] and pair[2] then
                    local a3, aOn = cam:WorldToViewportPoint(pair[1].Position)
                    local b3, bOn = cam:WorldToViewportPoint(pair[2].Position)
                    if aOn and bOn then
                        setLine(line, Vector2.new(a3.X, a3.Y), Vector2.new(b3.X, b3.Y), 1.2)
                        line.BackgroundColor3 = plr.TeamColor.Color
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(data.skeleton) do line.Visible = false end
        end

        if toggle_states.ESPChams then
            if not data.highlight or data.highlight.Parent ~= char then
                if data.highlight then pcall(function() data.highlight:Destroy() end) end
                data.highlight = Instance.new("Highlight")
                data.highlight.Name = "GreyShaderESPHighlight"
                data.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                data.highlight.OutlineTransparency = 0
                data.highlight.FillTransparency = 0.55
                data.highlight.Parent = char
            end
            data.highlight.FillColor = plr.TeamColor.Color
            data.highlight.OutlineColor = Theme.BorderBlue
            data.highlight.Enabled = true
        elseif data.highlight then
            data.highlight.Enabled = false
        end
    end
end)
table.insert(RunningConnections, playerEspConnection)

local playerRemovedConn = Players.PlayerRemoving:Connect(function(plr)
    cleanupEspPlayer(plr)
end)
table.insert(RunningConnections, playerRemovedConn)

--------------------------------------------------
-- Fly
--------------------------------------------------

createCheckbox(pages["Player"], "Fly", function(state)

    toggle_states.Fly = state

    if RunningConnections["Fly"] then
        RunningConnections["Fly"]:Disconnect()
        RunningConnections["Fly"] = nil
    end

    if not state then
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.zero
            end
        end
        return
    end

    local function StartFly(hrp)

        RunningConnections["Fly"] = RunService.RenderStepped:Connect(function()

            if not toggle_states.Fly then
                return
            end

            if not hrp or not hrp.Parent then
                return
            end

            local speed = flyMethod == "Velocity" and 40 or 60
            local vel = Vector3.zero
            local cam = workspace.CurrentCamera

            if UIS:IsKeyDown(Enum.KeyCode.W) then
                vel += cam.CFrame.LookVector * speed
            end

            if UIS:IsKeyDown(Enum.KeyCode.S) then
                vel -= cam.CFrame.LookVector * speed
            end

            if UIS:IsKeyDown(Enum.KeyCode.A) then
                vel -= cam.CFrame.RightVector * speed
            end

            if UIS:IsKeyDown(Enum.KeyCode.D) then
                vel += cam.CFrame.RightVector * speed
            end

            hrp.Velocity = vel

            if flyMethod == "Bypass" and flyRemote then
                flyRemote:FireServer(
                    "__---r",
                    Vector3.zero,
                    hrp.CFrame,
                    false
                )
            end

        end)

    end

    local char = player.Character

    if char and char:FindFirstChild("HumanoidRootPart") then
        StartFly(char.HumanoidRootPart)
    end

end, true)

--------------------------------------------------
-- Fly Method
--------------------------------------------------
local methodCard = Instance.new("Frame")
methodCard.Name = "FlyMethodCard"
methodCard.Size = UDim2.new(1, -4, 0, 54)
methodCard.BackgroundColor3 = Theme.ContentBg
methodCard.BackgroundTransparency = 0.08
methodCard.BorderSizePixel = 0
methodCard.Parent = pages["Player"]
methodCard.ZIndex = 5
addCorner(methodCard, 9)
table.insert(ColorObjects.ContentBg, methodCard)

local methodStroke = Instance.new("UIStroke")
methodStroke.Color = Theme.OutlineColor
methodStroke.Thickness = 1
methodStroke.Transparency = 0.2
methodStroke.Parent = methodCard
table.insert(ColorObjects.OutlineColor, methodStroke)

local methodLabel = Instance.new("TextLabel")
methodLabel.Size = UDim2.new(0.55, 0, 0, 19)
methodLabel.Position = UDim2.new(0, 14, 0, 7)
methodLabel.Text = "Fly Method"
methodLabel.Font = Enum.Font.GothamMedium
methodLabel.TextSize = 12
methodLabel.TextColor3 = Theme.TextColor
methodLabel.TextXAlignment = Enum.TextXAlignment.Left
methodLabel.BackgroundTransparency = 1
methodLabel.Parent = methodCard
table.insert(ColorObjects.TextColor, methodLabel)

local methodHint = Instance.new("TextLabel")
methodHint.Size = UDim2.new(0.55, 0, 0, 14)
methodHint.Position = UDim2.new(0, 14, 0, 29)
methodHint.Text = "Movement mode used while Fly is enabled"
methodHint.Font = Enum.Font.Gotham
methodHint.TextSize = 9
methodHint.TextColor3 = Theme.TextDim
methodHint.TextXAlignment = Enum.TextXAlignment.Left
methodHint.BackgroundTransparency = 1
methodHint.Parent = methodCard

local MethodButton = Instance.new("TextButton")
MethodButton.Size = UDim2.new(0, 108, 0, 30)
MethodButton.Position = UDim2.new(1, -122, 0.5, -15)
MethodButton.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
MethodButton.BorderSizePixel = 0
MethodButton.Text = flyMethod
MethodButton.Font = Enum.Font.GothamMedium
MethodButton.TextSize = 10
MethodButton.TextColor3 = Theme.TextColor
MethodButton.AutoButtonColor = false
MethodButton.Parent = methodCard
MethodButton.ZIndex = 7
addCorner(MethodButton, 7)
local methodBtnStroke = Instance.new("UIStroke")
methodBtnStroke.Color = Theme.OutlineColor
methodBtnStroke.Transparency = 0.05
methodBtnStroke.Parent = MethodButton
table.insert(ColorObjects.OutlineColor, methodBtnStroke)
table.insert(ColorObjects.TextColor, MethodButton)

MethodButton.MouseButton1Click:Connect(function()
    flyMethod = flyMethod == "Velocity" and "Bypass" or "Velocity"
    MethodButton.Text = flyMethod
end)


-- MISC PAGE
createCheckbox(pages["Misc"], "Staff Detector (Auto Kick)", function(state)
    adminCheckEnabled = state
    if adminCheckEnabled then
        for _, p in ipairs(Players:GetPlayers()) do checkAndKick(p) end
        adminConnection = Players.PlayerAdded:Connect(checkAndKick); table.insert(RunningConnections, adminConnection)
    elseif adminConnection then adminConnection:Disconnect() end
end, false)

-- TELEPORT PAGE CONSTRUCTION
------------------------------------------------
local tpLayout = Instance.new("UIListLayout")
tpLayout.FillDirection = Enum.FillDirection.Vertical
tpLayout.Padding = UDim.new(0, 8)
tpLayout.Parent = pages["Teleport"]

local function makeSectionCard(parent, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -4, 0, height)
    card.BackgroundColor3 = Theme.ContentBg
    card.BackgroundTransparency = 0.08
    card.BorderSizePixel = 0
    card.Parent = parent
    card.ZIndex = 5
    addCorner(card, 9)
    table.insert(ColorObjects.ContentBg, card)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.OutlineColor
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    stroke.Parent = card
    table.insert(ColorObjects.OutlineColor, stroke)
    return card
end

local tpCoordCard = makeSectionCard(pages["Teleport"], 54)
local xyzTitle = Instance.new("TextLabel")
xyzTitle.Size = UDim2.new(0, 105, 0, 18)
xyzTitle.Position = UDim2.new(0, 14, 0, 7)
xyzTitle.Text = "Current Position"
xyzTitle.TextColor3 = Theme.TextColor
xyzTitle.Font = Enum.Font.GothamMedium
xyzTitle.TextSize = 12
xyzTitle.TextXAlignment = Enum.TextXAlignment.Left
xyzTitle.BackgroundTransparency = 1
xyzTitle.Parent = tpCoordCard
table.insert(ColorObjects.TextColor, xyzTitle)

local xyzLabel = Instance.new("TextLabel")
xyzLabel.Size = UDim2.new(0, 210, 0, 16)
xyzLabel.Position = UDim2.new(0, 14, 0, 29)
xyzLabel.Text = "0, 0, 0"
xyzLabel.TextColor3 = Theme.BorderBlue
xyzLabel.Font = Theme.Font
xyzLabel.TextSize = 11
xyzLabel.TextXAlignment = Enum.TextXAlignment.Left
xyzLabel.BackgroundTransparency = 1
xyzLabel.Parent = tpCoordCard
table.insert(ColorObjects.BorderBlue, xyzLabel)

local copyCoordsBtn = Instance.new("TextButton")
copyCoordsBtn.Size = UDim2.new(0, 82, 0, 30)
copyCoordsBtn.Position = UDim2.new(1, -96, 0.5, -15)
copyCoordsBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
copyCoordsBtn.BorderSizePixel = 0
copyCoordsBtn.Text = "Copy"
copyCoordsBtn.TextColor3 = Theme.TextColor
copyCoordsBtn.Font = Enum.Font.GothamMedium
copyCoordsBtn.TextSize = 10
copyCoordsBtn.Parent = tpCoordCard
addCorner(copyCoordsBtn, 7)
local copyStroke = Instance.new("UIStroke")
copyStroke.Color = Theme.OutlineColor
copyStroke.Transparency = 0.05
copyStroke.Parent = copyCoordsBtn
table.insert(ColorObjects.OutlineColor, copyStroke)
table.insert(ColorObjects.TextColor, copyCoordsBtn)

copyCoordsBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = player.Character.HumanoidRootPart.Position
        local coordStr = string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
        pcall(function() setclipboard(coordStr) end)
        copyCoordsBtn.Text = "Copied"
        task.delay(1, function()
            if copyCoordsBtn and copyCoordsBtn.Parent then copyCoordsBtn.Text = "Copy" end
        end)
    end
end)

createCheckbox(pages["Teleport"], "Auto Walk", function(state)
    autoWalkEnabled = state
    if not autoWalkEnabled then
        pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game) end)
    end
end, true)

createCheckbox(pages["Teleport"], "Loop Teleport", function(state)
    autoTP = state
end, false)

local tpMainArea = makeSectionCard(pages["Teleport"], 245)

local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(0.48, -28, 0, 20)
listTitle.Position = UDim2.new(0, 14, 0, 9)
listTitle.Text = "Saved Waypoints"
listTitle.TextColor3 = Theme.TextColor
listTitle.Font = Enum.Font.GothamMedium
listTitle.TextSize = 12
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.BackgroundTransparency = 1
listTitle.Parent = tpMainArea
table.insert(ColorObjects.TextColor, listTitle)

local tpListFrame = Instance.new("ScrollingFrame")
tpListFrame.Size = UDim2.new(0.48, -22, 1, -42)
tpListFrame.Position = UDim2.new(0, 10, 0, 34)
tpListFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 19)
tpListFrame.BorderSizePixel = 0
tpListFrame.ScrollBarThickness = 3
tpListFrame.ScrollBarImageColor3 = Theme.BorderBlue
tpListFrame.Parent = tpMainArea
addCorner(tpListFrame, 7)

local tpListStroke = Instance.new("UIStroke")
tpListStroke.Color = Theme.OutlineColor
tpListStroke.Transparency = 0.15
tpListStroke.Parent = tpListFrame
table.insert(ColorObjects.OutlineColor, tpListStroke)

local function refreshWaypointList()
    for _, v in pairs(tpListFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    local yOffset = 6
    for id, pos in pairs(locations) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -12, 0, 34)
        row.Position = UDim2.new(0, 6, 0, yOffset)
        row.BackgroundColor3 = selectedLocation == id and Color3.fromRGB(34, 34, 38) or Color3.fromRGB(22, 22, 24)
        row.BorderSizePixel = 0
        row.Parent = tpListFrame
        addCorner(row, 6)

        local lbl = Instance.new("TextButton")
        lbl.Size = UDim2.new(1, -88, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.Text = string.format("Point %d   %.0f, %.0f, %.0f", id, pos.X, pos.Y, pos.Z)
        lbl.TextColor3 = Theme.TextColor
        lbl.Font = Theme.Font
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.Parent = row
        table.insert(ColorObjects.TextColor, lbl)
        lbl.MouseButton1Click:Connect(function()
            selectedLocation = id
            refreshWaypointList()
        end)

        local goBtn = Instance.new("TextButton")
        goBtn.Size = UDim2.new(0, 30, 0, 22)
        goBtn.Position = UDim2.new(1, -68, 0.5, -11)
        goBtn.BackgroundColor3 = Theme.BorderBlue
        goBtn.Text = "GO"
        goBtn.TextColor3 = Color3.new(1,1,1)
        goBtn.Font = Enum.Font.GothamBold
        goBtn.TextSize = 9
        goBtn.Parent = row
        addCorner(goBtn, 5)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 30, 0, 22)
        delBtn.Position = UDim2.new(1, -34, 0.5, -11)
        delBtn.BackgroundColor3 = Color3.fromRGB(75, 32, 36)
        delBtn.Text = "×"
        delBtn.TextColor3 = Color3.fromRGB(240, 205, 208)
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 12
        delBtn.Parent = row
        addCorner(delBtn, 5)

        goBtn.MouseButton1Click:Connect(function()
            local h = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if h then h.CFrame = CFrame.new(pos) end
        end)
        delBtn.MouseButton1Click:Connect(function()
            locations[id] = nil
            if selectedLocation == id then selectedLocation = nil end
            refreshWaypointList()
        end)
        yOffset = yOffset + 40
    end
    tpListFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

local rightControlsFrame = Instance.new("Frame")
rightControlsFrame.Size = UDim2.new(0.52, -18, 1, -34)
rightControlsFrame.Position = UDim2.new(0.48, 8, 0, 34)
rightControlsFrame.BackgroundTransparency = 1
rightControlsFrame.Parent = tpMainArea

local controlsLayout = Instance.new("UIListLayout")
controlsLayout.Padding = UDim.new(0, 7)
controlsLayout.Parent = rightControlsFrame

local function createTpCtrlButton(text, clickCallback, accent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = accent and Theme.BorderBlue or Color3.fromRGB(25, 25, 28)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = accent and Color3.new(1,1,1) or Theme.TextColor
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 10
    btn.Parent = rightControlsFrame
    addCorner(btn, 7)
    local stroke = Instance.new("UIStroke")
    stroke.Color = accent and Theme.BorderBlue or Theme.OutlineColor
    stroke.Transparency = 0.1
    stroke.Parent = btn
    if accent then table.insert(ColorObjects.BorderBlue, stroke) else table.insert(ColorObjects.OutlineColor, stroke) end
    table.insert(ColorObjects.TextColor, btn)
    btn.MouseButton1Click:Connect(clickCallback)
end

createTpCtrlButton("Save Current Position", function()
    local h = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if h then
        coordCount += 1
        locations[coordCount] = h.Position
        selectedLocation = coordCount
        refreshWaypointList()
    end
end, true)

createTpCtrlButton("Update Selected", function()
    local h = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if h and selectedLocation then
        locations[selectedLocation] = h.Position
        refreshWaypointList()
    end
end)

local manualInput = Instance.new("TextBox")
manualInput.Size = UDim2.new(1, 0, 0, 32)
manualInput.BackgroundColor3 = Color3.fromRGB(17, 17, 19)
manualInput.BorderSizePixel = 0
manualInput.Text = ""
manualInput.PlaceholderText = "X, Y, Z"
manualInput.PlaceholderColor3 = Theme.TextDim
manualInput.TextColor3 = Theme.TextColor
manualInput.Font = Theme.Font
manualInput.TextSize = 10
manualInput.ClearTextOnFocus = false
manualInput.Parent = rightControlsFrame
addCorner(manualInput, 7)
local manualStroke = Instance.new("UIStroke")
manualStroke.Color = Theme.OutlineColor
manualStroke.Parent = manualInput
table.insert(ColorObjects.OutlineColor, manualStroke)
table.insert(ColorObjects.TextColor, manualInput)

createTpCtrlButton("Teleport to Coordinates", function()
    local input = manualInput.Text:gsub(",", " ")
    local coords = {}
    for num in string.gmatch(input, "%S+") do
        table.insert(coords, tonumber(num))
    end
    if #coords == 3 and coords[1] and coords[2] and coords[3] then
        local h = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if h then h.CFrame = CFrame.new(coords[1], coords[2], coords[3]) end
    end
end)

createTpCtrlButton("Spawn Platform", function()
    spawnTargetPlatformAtFeet()
end)

------------------------------------------------
-- [[ SAFE UNLOAD / CLEANUP ]] --
------------------------------------------------
local function UnloadCheat()
    if isUnloaded then return end
    isUnloaded = true

    -- Stop feature loops first.
    strafeEnabled = false
    resetEnabled = false
    autoTP = false
    pressingE = false
    autoReloadEnabled = false
    autoWalkEnabled = false
    adminCheckEnabled = false
    autoClaimAllowanceEnabled = false
    toolLoopActive = false
    MeleeAura_Enabled = false
    Shadow_Active = false

    -- Stop custom keybind actions.
    table.clear(Keybinds)

    -- Disconnect every tracked connection.
    for key, connection in pairs(RunningConnections) do
        pcall(function()
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end)
        RunningConnections[key] = nil
    end

    -- Stop the dedicated melee connection if it was not in the registry.
    if MeleeAura_Connection then
        pcall(function()
            if MeleeAura_Connection.Connected then
                MeleeAura_Connection:Disconnect()
            end
        end)
        MeleeAura_Connection = nil
    end

    -- Restore character/camera state.
    pcall(function() DeactivateShadow() end)
    pcall(function() stopPressingE() end)

    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if humanoid then
            humanoid.CameraOffset = Vector3.zero
        end
        if hrp then
            hrp.Velocity = Vector3.zero
        end
        for _, obj in ipairs(character:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Transparency == 0.5 then
                obj.Transparency = 0
            end
        end
    end

    -- Remove ESP objects and both GUI layers.
    pcall(function() cleanupAllEsp() end)
    pcall(function()
        if espGui and espGui.Parent then espGui:Destroy() end
    end)
    pcall(function()
        if WarningText and WarningText.Parent then WarningText.Parent:Destroy() end
    end)
    pcall(function()
        if gui and gui.Parent then gui:Destroy() end
    end)

    print("[GREYSHADER] Unloaded successfully.")
end

------------------------------------------------
-- [[ SETTINGS PAGE - MODERN / CLEAN ]] --
------------------------------------------------
local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Size = UDim2.new(1, 0, 1, 0)
settingsScroll.BackgroundTransparency = 1
settingsScroll.BorderSizePixel = 0
settingsScroll.ScrollBarThickness = 3
settingsScroll.ScrollBarImageColor3 = Theme.BorderBlue
settingsScroll.Parent = pages["Settings"]
addPadding(settingsScroll, 2, 8, 2, 14)

local setLayout = Instance.new("UIListLayout")
setLayout.Padding = UDim.new(0, 12)
setLayout.SortOrder = Enum.SortOrder.LayoutOrder
setLayout.Parent = settingsScroll

local function makeSettingsCard(title, subtitle, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -4, 0, height)
    card.BackgroundColor3 = Theme.ContentBg
    card.BorderSizePixel = 0
    card.Parent = settingsScroll
    addCorner(card, 12)
    table.insert(ColorObjects.ContentBg, card)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.OutlineColor
    stroke.Thickness = 1
    stroke.Transparency = 0.18
    stroke.Parent = card
    table.insert(ColorObjects.OutlineColor, stroke)

    local titleLabel2 = Instance.new("TextLabel")
    titleLabel2.Size = UDim2.new(1, -28, 0, 20)
    titleLabel2.Position = UDim2.new(0, 14, 0, 10)
    titleLabel2.BackgroundTransparency = 1
    titleLabel2.Text = title
    titleLabel2.TextColor3 = Theme.TextColor
    titleLabel2.Font = Enum.Font.GothamBold
    titleLabel2.TextSize = 13
    titleLabel2.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel2.Parent = card
    table.insert(ColorObjects.TextColor, titleLabel2)

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -28, 0, 16)
    sub.Position = UDim2.new(0, 14, 0, 31)
    sub.BackgroundTransparency = 1
    sub.Text = subtitle
    sub.TextColor3 = Theme.TextDim
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 10
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = card
    table.insert(ColorObjects.TextColor, sub)

    return card
end

local interfaceCard = makeSettingsCard(
    "Interface",
    "Control the menu visibility and keyboard shortcut.",
    126
)

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, -28, 0, 34)
unloadBtn.Position = UDim2.new(0, 14, 0, 58)
unloadBtn.BackgroundColor3 = Theme.TabInactive
unloadBtn.BorderSizePixel = 0
unloadBtn.Text = "Unload interface"
unloadBtn.TextColor3 = Theme.TextColor
unloadBtn.Font = Enum.Font.GothamMedium
unloadBtn.TextSize = 11
unloadBtn.AutoButtonColor = false
unloadBtn.Parent = interfaceCard
addCorner(unloadBtn, 8)
table.insert(ColorObjects.TextColor, unloadBtn)
unloadBtn.MouseEnter:Connect(function()
    tween(unloadBtn, 0.12, {BackgroundColor3 = Theme.OutlineColor})
end)
unloadBtn.MouseLeave:Connect(function()
    tween(unloadBtn, 0.12, {BackgroundColor3 = Theme.TabInactive})
end)
unloadBtn.MouseButton1Click:Connect(function()
    pcall(UnloadCheat)
end)

local bindLabel = Instance.new("TextLabel")
bindLabel.Size = UDim2.new(0.55, 0, 0, 18)
bindLabel.Position = UDim2.new(0, 14, 0, 97)
bindLabel.BackgroundTransparency = 1
bindLabel.Text = "Menu shortcut"
bindLabel.TextColor3 = Theme.TextDim
bindLabel.Font = Enum.Font.GothamMedium
bindLabel.TextSize = 10
bindLabel.TextXAlignment = Enum.TextXAlignment.Left
bindLabel.Parent = interfaceCard
table.insert(ColorObjects.TextColor, bindLabel)

local menuBindBtn = Instance.new("TextButton")
menuBindBtn.Size = UDim2.new(0, 82, 0, 24)
menuBindBtn.Position = UDim2.new(1, -112, 0, 94)
menuBindBtn.BackgroundColor3 = Theme.TabInactive
menuBindBtn.BorderSizePixel = 0
menuBindBtn.Text = menuBindKey.Name:upper()
menuBindBtn.TextColor3 = Theme.TextColor
menuBindBtn.Font = Enum.Font.GothamBold
menuBindBtn.TextSize = 10
menuBindBtn.AutoButtonColor = false
menuBindBtn.Parent = interfaceCard
addCorner(menuBindBtn, 7)
table.insert(ColorObjects.TextColor, menuBindBtn)

local menuBindCancel = Instance.new("TextButton")
menuBindCancel.Size = UDim2.new(0, 22, 0, 22)
menuBindCancel.Position = UDim2.new(1, -25, 0, 95)
menuBindCancel.BackgroundColor3 = Theme.TabInactive
menuBindCancel.BorderSizePixel = 0
menuBindCancel.Text = "×"
menuBindCancel.TextColor3 = Theme.TextDim
menuBindCancel.Font = Enum.Font.GothamBold
menuBindCancel.TextSize = 14
menuBindCancel.Parent = interfaceCard
addCorner(menuBindCancel, 7)

local menuListening = false
menuBindBtn.MouseButton1Click:Connect(function()
    if menuListening or isUnloaded then return end
    menuListening = true
    menuBindBtn.Text = "PRESS KEY"
    menuBindBtn.TextColor3 = Theme.BorderBlue
end)

menuBindCancel.MouseButton1Click:Connect(function()
    menuBindKey = Enum.KeyCode.Unknown
    menuBindBtn.Text = "NONE"
    menuBindBtn.TextColor3 = Theme.TextDim
end)

local cMenuKey = UIS.InputBegan:Connect(function(input, gpe)
    if menuListening and not gpe and not isUnloaded and input.UserInputType == Enum.UserInputType.Keyboard then
        menuListening = false
        menuBindKey = input.KeyCode
        menuBindBtn.Text = menuBindKey.Name:upper()
        menuBindBtn.TextColor3 = Theme.TextColor
    end
end)
table.insert(RunningConnections, cMenuKey)

local appearanceCard = makeSettingsCard(
    "Appearance",
    "Pick an accent and switch the entire interface style.",
    248
)
appearanceCard.ClipsDescendants = false

local themePreview = Instance.new("Frame")
themePreview.Size = UDim2.new(1, -28, 0, 54)
themePreview.Position = UDim2.new(0, 14, 0, 57)
themePreview.BackgroundColor3 = Theme.MainBg
themePreview.BorderSizePixel = 0
themePreview.Parent = appearanceCard
addCorner(themePreview, 9)
table.insert(ColorObjects.MainBg, themePreview)

local previewAccent = Instance.new("Frame")
previewAccent.Size = UDim2.new(0, 4, 1, 0)
previewAccent.BackgroundColor3 = Theme.BorderBlue
previewAccent.BorderSizePixel = 0
previewAccent.Parent = themePreview
addCorner(previewAccent, 3)
table.insert(ColorObjects.BorderBlue, previewAccent)

local previewTitle = Instance.new("TextLabel")
previewTitle.Size = UDim2.new(1, -24, 0, 18)
previewTitle.Position = UDim2.new(0, 14, 0, 9)
previewTitle.BackgroundTransparency = 1
previewTitle.Text = "GREYSHADER"
previewTitle.TextColor3 = Theme.TextColor
previewTitle.Font = Enum.Font.GothamBold
previewTitle.TextSize = 11
previewTitle.TextXAlignment = Enum.TextXAlignment.Left
previewTitle.Parent = themePreview
table.insert(ColorObjects.TextColor, previewTitle)

local previewSub = Instance.new("TextLabel")
previewSub.Size = UDim2.new(1, -24, 0, 16)
previewSub.Position = UDim2.new(0, 14, 0, 28)
previewSub.BackgroundTransparency = 1
previewSub.Text = "Modern • Smooth • Minimal"
previewSub.TextColor3 = Theme.TextDim
previewSub.Font = Enum.Font.Gotham
previewSub.TextSize = 9
previewSub.TextXAlignment = Enum.TextXAlignment.Left
previewSub.Parent = themePreview
table.insert(ColorObjects.TextColor, previewSub)

local themeLabel = Instance.new("TextLabel")
themeLabel.Size = UDim2.new(0.45, 0, 0, 18)
themeLabel.Position = UDim2.new(0, 14, 0, 120)
themeLabel.BackgroundTransparency = 1
themeLabel.Text = "Theme preset"
themeLabel.TextColor3 = Theme.TextDim
themeLabel.Font = Enum.Font.GothamMedium
themeLabel.TextSize = 10
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.Parent = appearanceCard
table.insert(ColorObjects.TextColor, themeLabel)

local ddBox = Instance.new("TextButton")
ddBox.Size = UDim2.new(0, 190, 0, 28)
ddBox.Position = UDim2.new(1, -218, 0, 115)
ddBox.ZIndex = 20
ddBox.BackgroundColor3 = Theme.TabInactive
ddBox.BorderSizePixel = 0
ddBox.Text = "  Obsidian"
ddBox.TextColor3 = Theme.TextColor
ddBox.Font = Enum.Font.GothamMedium
ddBox.TextSize = 10
ddBox.TextXAlignment = Enum.TextXAlignment.Left
ddBox.AutoButtonColor = false
ddBox.Parent = appearanceCard
addCorner(ddBox, 8)
table.insert(ColorObjects.TextColor, ddBox)

local arrow = Instance.new("TextLabel")
arrow.Size = UDim2.new(0, 25, 1, 0)
arrow.Position = UDim2.new(1, -28, 0, 0)
arrow.BackgroundTransparency = 1
arrow.Text = "⌄"
arrow.TextColor3 = Theme.TextDim
arrow.Font = Enum.Font.GothamBold
arrow.TextSize = 13
arrow.Parent = ddBox

local ddMenu = Instance.new("Frame")
ddMenu.Size = UDim2.new(0, 190, 0, 116)
ddMenu.Position = UDim2.new(0, 0, 1, 6)
ddMenu.ZIndex = 30
ddMenu.BackgroundColor3 = Theme.ContentBg
ddMenu.BorderSizePixel = 0
ddMenu.Visible = false
ddMenu.ZIndex = 30
ddMenu.Parent = ddBox
addCorner(ddMenu, 8)
local ddStroke = Instance.new("UIStroke")
ddStroke.Color = Theme.OutlineColor
ddStroke.Thickness = 1
ddStroke.Parent = ddMenu

local ddLayout = Instance.new("UIListLayout")
ddLayout.Padding = UDim.new(0, 2)
ddLayout.Parent = ddMenu

_G.UpdateDropdownText = function(text)
    ddBox.Text = "  " .. text
end

local function createDropdownItem(name)
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, -8, 0, 26)
    item.Position = UDim2.new(0, 4, 0, 0)
    item.BackgroundColor3 = Theme.ContentBg
    item.BorderSizePixel = 0
    item.Text = "  " .. name
    item.TextColor3 = Theme.TextColor
    item.Font = Enum.Font.GothamMedium
    item.TextSize = 10
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.AutoButtonColor = false
    item.ZIndex = 31
    item.Parent = ddMenu
    addCorner(item, 6)
    item.MouseEnter:Connect(function()
        tween(item, 0.1, {BackgroundColor3 = Theme.TabActive})
    end)
    item.MouseLeave:Connect(function()
        tween(item, 0.1, {BackgroundColor3 = Theme.ContentBg})
    end)
    item.MouseButton1Click:Connect(function()
        ddBox.Text = "  " .. name
        ddMenu.Visible = false
        dropdownOpen = false
        arrow.Text = "⌄"
        applyPreset(name)
        tween(themePreview, 0.22, {BackgroundColor3 = Theme.MainBg})
    end)
end

createDropdownItem("Obsidian")
createDropdownItem("Crimson")
createDropdownItem("Aurora")
createDropdownItem("Violet")

local dropdownOpen = false
ddBox.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    ddMenu.Visible = dropdownOpen
    arrow.Text = dropdownOpen and "⌃" or "⌄"
    if dropdownOpen then
        ddMenu.BackgroundTransparency = 1
        tween(ddMenu, 0.16, {BackgroundTransparency = 0})
    end
end)

local saveDefaultBtn = Instance.new("TextButton")
saveDefaultBtn.Size = UDim2.new(1, -28, 0, 32)
saveDefaultBtn.Position = UDim2.new(0, 14, 0, 198)
saveDefaultBtn.BackgroundColor3 = Theme.BorderBlue
saveDefaultBtn.BorderSizePixel = 0
saveDefaultBtn.Text = "Save current theme as default"
saveDefaultBtn.TextColor3 = Color3.fromRGB(7, 12, 18)
saveDefaultBtn.Font = Enum.Font.GothamBold
saveDefaultBtn.TextSize = 10
saveDefaultBtn.AutoButtonColor = false
saveDefaultBtn.Parent = appearanceCard
addCorner(saveDefaultBtn, 8)
saveDefaultBtn.MouseEnter:Connect(function()
    tween(saveDefaultBtn, 0.12, {BackgroundTransparency = 0.12})
end)
saveDefaultBtn.MouseLeave:Connect(function()
    tween(saveDefaultBtn, 0.12, {BackgroundTransparency = 0})
end)
saveDefaultBtn.MouseButton1Click:Connect(function()
    saveDefaultTheme()
    saveDefaultBtn.Text = "Saved ✓"
    task.delay(1.2, function()
        if saveDefaultBtn and saveDefaultBtn.Parent then
            saveDefaultBtn.Text = "Save current theme as default"
        end
    end)
end)

settingsScroll.CanvasSize = UDim2.new(0, 0, 0, 390)

------------------------------------------------
-- GLOBAL KEYBIND & ENGINE LISTENERS
------------------------------------------------
local cGlobalKey = UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.Keyboard and not isUnloaded then
        if Keybinds[input.KeyCode] then Keybinds[input.KeyCode]() end
    end
end)
table.insert(RunningConnections, cGlobalKey)

local cHb = RunService.Heartbeat:Connect(function(deltaTime)
    if isUnloaded then return end
    if not Shadow_Active or not Shadow_Usable then
        if not Shadow_Active and Char then
            for _, v in pairs(Char:GetDescendants()) do if v:IsA("BasePart") and v.Transparency == 0.5 then v.Transparency = 0 end end
        end
        WarningText.Visible = false; return
    end
    ShadowStep(deltaTime)
end)
table.insert(RunningConnections, cHb)

local cRs = RunService.RenderStepped:Connect(function()
    if isUnloaded or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrpObj = player.Character.HumanoidRootPart
    xyzLabel.Text = string.format("%.0f, %.0f, %.0f", hrpObj.Position.X, hrpObj.Position.Y, hrpObj.Position.Z)
    
    if autoWalkEnabled and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
        pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game) end)
    end
    if strafeEnabled then
        local target = Players:FindFirstChild(targetBox.Text)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then 
            hrpObj.CFrame = target.Character.HumanoidRootPart.CFrame + (target.Character.HumanoidRootPart.CFrame.LookVector * 3) 
        end
    end
    if autoTP and selectedLocation and locations[selectedLocation] then hrpObj.CFrame = CFrame.new(locations[selectedLocation]) end
end)
table.insert(RunningConnections, cRs)

local dragging, dragStart, startPos
local cDrag1 = mainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = mainFrame.Position end end)
local cDrag2 = UIS.InputChanged:Connect(function(i) 
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end 
end)
local cDrag3 = UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
table.insert(RunningConnections, cDrag1) table.insert(RunningConnections, cDrag2) table.insert(RunningConnections, cDrag3)

local cIdle = player.Idled:Connect(function() if isUnloaded then return end; pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end)
table.insert(RunningConnections, cIdle)

local cToggle = UIS.InputBegan:Connect(function(i, gpe)
    if not gpe and i.KeyCode == menuBindKey and not isUnloaded and menuBindKey ~= Enum.KeyCode.Unknown then
        setMenuVisible(not uiVisible)
    end
end)
table.insert(RunningConnections, cToggle)

loadDefaultTheme()
