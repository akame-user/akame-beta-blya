local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local colors = {
    bg = Color3.fromRGB(8, 10, 18),
    accent = Color3.fromRGB(230, 50, 50),
    text = Color3.fromRGB(255, 220, 220),
    textDim = Color3.fromRGB(180, 140, 140),
    dark = Color3.fromRGB(30, 20, 20),
    darker = Color3.fromRGB(18, 12, 12)
}

local settings = {
    aimbot = false,
    esp = false,
    thirdPerson = false,
    chinahat = false,
    fov = 150,
    minDist = 0,
    maxDist = 1000,
    checkVis = true,
    aimKey = Enum.UserInputType.MouseButton2,
    targetPart = "Head"
}

local menuVisible = true
local currentTab = "Combat"
local connection, espConn = nil, nil
local fps, ping = 60, 0
local lastTime, frameCount = tick(), 0
local chinahatObj = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AkameMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function addShadow(parent, sizeOffset, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, sizeOffset, 1, sizeOffset)
    shadow.Position = UDim2.new(0, -sizeOffset/2, 0, -sizeOffset/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = transparency or 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10,10,118,118)
    shadow.Parent = parent
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 240)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -120)
mainFrame.BackgroundColor3 = colors.bg
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 20)
addShadow(mainFrame, 30, 0.8)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = colors.darker
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 20)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "AKAME"
title.TextColor3 = colors.accent
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Parent = titleBar

local version = Instance.new("TextLabel")
version.Size = UDim2.new(0, 50, 1, 0)
version.Position = UDim2.new(1, -50, 0, 0)
version.BackgroundTransparency = 1
version.Text = "v2.3"
version.TextColor3 = colors.textDim
version.Font = Enum.Font.Gotham
version.TextSize = 14
version.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 7)
closeBtn.BackgroundColor3 = colors.dark
closeBtn.Text = "✕"
closeBtn.TextColor3 = colors.textDim
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
addShadow(closeBtn, 15, 0.7)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 40)
tabFrame.Position = UDim2.new(0, 10, 0, 50)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local function createTab(name, pos)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0.33, -4, 1, 0)
    tab.Position = UDim2.new(pos, 0, 0, 0)
    tab.BackgroundColor3 = colors.dark
    tab.Text = name
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 15
    tab.Parent = tabFrame
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 10)
    addShadow(tab, 10, 0.5)
    return tab
end

local combatTab = createTab("COMBAT", 0)
local visualsTab = createTab("VISUALS", 0.33)
local settingsTab = createTab("SETTINGS", 0.66)

combatTab.TextColor3 = colors.accent
visualsTab.TextColor3 = colors.textDim
settingsTab.TextColor3 = colors.textDim

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 0, 130)
contentFrame.Position = UDim2.new(0, 10, 0, 95)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local function createSwitch(parent, yPos, label, get, set)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 38)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundColor3 = colors.darker
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)
    addShadow(container, 15, 0.5)

    local labelObj = Instance.new("TextLabel")
    labelObj.Size = UDim2.new(0.5, -15, 1, 0)
    labelObj.Position = UDim2.new(0, 15, 0, 0)
    labelObj.BackgroundTransparency = 1
    labelObj.Text = label
    labelObj.TextColor3 = colors.text
    labelObj.TextXAlignment = Enum.TextXAlignment.Left
    labelObj.Font = Enum.Font.Gotham
    labelObj.TextSize = 15
    labelObj.Parent = container

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 48, 0, 24)
    bg.Position = UDim2.new(1, -68, 0.5, -12)
    bg.BackgroundColor3 = colors.dark
    bg.BorderSizePixel = 0
    bg.Parent = container
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    addShadow(bg, 8, 0.4)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = colors.text
    knob.BorderSizePixel = 0
    knob.Parent = bg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = container

    local function update()
        if get() then
            bg.BackgroundColor3 = colors.accent
            knob:TweenPosition(UDim2.new(0, 26, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        else
            bg.BackgroundColor3 = colors.dark
            knob:TweenPosition(UDim2.new(0, 2, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        end
    end
    update()

    hitbox.MouseButton1Click:Connect(function()
        set(not get())
        update()
        updateBinds()
        if label == "China Hat" then
            updateChinahat()
        end
    end)
end

local function createSlider(parent, yPos, label, minVal, maxVal, get, set, format)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 38)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundColor3 = colors.darker
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)
    addShadow(container, 15, 0.5)

    local labelObj = Instance.new("TextLabel")
    labelObj.Size = UDim2.new(0.5, -15, 0.5, 0)
    labelObj.Position = UDim2.new(0, 15, 0, 4)
    labelObj.BackgroundTransparency = 1
    labelObj.Text = label
    labelObj.TextColor3 = colors.text
    labelObj.TextXAlignment = Enum.TextXAlignment.Left
    labelObj.Font = Enum.Font.Gotham
    labelObj.TextSize = 14
    labelObj.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.5, -15, 0.5, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(get())
    valueLabel.TextColor3 = colors.accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.Parent = container

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -30, 0, 8)
    bg.Position = UDim2.new(0, 15, 0, 25)
    bg.BackgroundColor3 = colors.dark
    bg.BorderSizePixel = 0
    bg.Parent = container
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((get()-minVal)/(maxVal-minVal), 0, 1, 0)
    fill.BackgroundColor3 = colors.accent
    fill.BorderSizePixel = 0
    fill.Parent = bg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((get()-minVal)/(maxVal-minVal), -8, 0.5, -8)
    knob.BackgroundColor3 = colors.text
    knob.Text = ""
    knob.Parent = bg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    addShadow(knob, 8, 0.3)

    local dragging = false
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UIS:GetMouseLocation()
            local absPos, absSize = bg.AbsolutePosition, bg.AbsoluteSize.X
            local rel = math.clamp((mousePos.X - absPos.X) / absSize, 0, 1)
            local newVal = minVal + rel * (maxVal - minVal)
            if format then newVal = format(newVal) end
            set(newVal)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -8, 0.5, -8)
            valueLabel.Text = tostring(get())
        end
    end)
end

local combatContent = Instance.new("Frame")
combatContent.Size = UDim2.new(1, 0, 1, 0)
combatContent.BackgroundTransparency = 1
combatContent.Visible = true
combatContent.Parent = contentFrame

createSwitch(combatContent, 0, "Aimbot", function() return settings.aimbot end, function(v) settings.aimbot = v end)
createSlider(combatContent, 45, "FOV", 90, 200, function() return settings.fov end, function(v) settings.fov = v end, math.floor)
createSlider(combatContent, 90, "Min Dist", 0, 500, function() return settings.minDist end, function(v) settings.minDist = v end, math.floor)
createSlider(combatContent, 135, "Max Dist", 100, 2000, function() return settings.maxDist end, function(v) settings.maxDist = v end, math.floor)
createSwitch(combatContent, 180, "Check Vis", function() return settings.checkVis end, function(v) settings.checkVis = v end)

local visualsContent = Instance.new("Frame")
visualsContent.Size = UDim2.new(1, 0, 1, 0)
visualsContent.BackgroundTransparency = 1
visualsContent.Visible = false
visualsContent.Parent = contentFrame

createSwitch(visualsContent, 0, "ESP", function() return settings.esp end, function(v) settings.esp = v end)
createSwitch(visualsContent, 45, "China Hat", function() return settings.chinahat end, function(v) settings.chinahat = v end)

local settingsContent = Instance.new("Frame")
settingsContent.Size = UDim2.new(1, 0, 1, 0)
settingsContent.BackgroundTransparency = 1
settingsContent.Visible = false
settingsContent.Parent = contentFrame

createSwitch(settingsContent, 0, "Third Person", function() return settings.thirdPerson end, function(v) settings.thirdPerson = v end)

combatTab.MouseButton1Click:Connect(function()
    currentTab = "Combat"
    combatTab.TextColor3 = colors.accent
    visualsTab.TextColor3 = colors.textDim
    settingsTab.TextColor3 = colors.textDim
    combatContent.Visible = true
    visualsContent.Visible = false
    settingsContent.Visible = false
end)
visualsTab.MouseButton1Click:Connect(function()
    currentTab = "Visuals"
    combatTab.TextColor3 = colors.textDim
    visualsTab.TextColor3 = colors.accent
    settingsTab.TextColor3 = colors.textDim
    combatContent.Visible = false
    visualsContent.Visible = true
    settingsContent.Visible = false
end)
settingsTab.MouseButton1Click:Connect(function()
    currentTab = "Settings"
    combatTab.TextColor3 = colors.textDim
    visualsTab.TextColor3 = colors.textDim
    settingsTab.TextColor3 = colors.accent
    combatContent.Visible = false
    visualsContent.Visible = false
    settingsContent.Visible = true
end)

local watermark = Instance.new("Frame")
watermark.Size = UDim2.new(0, 260, 0, 40)
watermark.Position = UDim2.new(1, -270, 0, 15)
watermark.BackgroundColor3 = colors.bg
watermark.BackgroundTransparency = 0.2
watermark.BorderSizePixel = 0
watermark.Active = true
watermark.Draggable = true
watermark.Parent = screenGui
Instance.new("UICorner", watermark).CornerRadius = UDim.new(0, 16)
addShadow(watermark, 25, 0.7)

local wmTitle = Instance.new("TextLabel")
wmTitle.Size = UDim2.new(0.4, 0, 1, 0)
wmTitle.Position = UDim2.new(0, 12, 0, 0)
wmTitle.BackgroundTransparency = 1
wmTitle.Text = "AKAME"
wmTitle.TextColor3 = colors.accent
wmTitle.TextXAlignment = Enum.TextXAlignment.Left
wmTitle.Font = Enum.Font.GothamBold
wmTitle.TextSize = 20
wmTitle.Parent = watermark

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0.3, 0, 1, 0)
pingLabel.Position = UDim2.new(0.4, 0, 0, 0)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: 0ms"
pingLabel.TextColor3 = colors.text
pingLabel.Font = Enum.Font.Gotham
pingLabel.TextSize = 14
pingLabel.Parent = watermark

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0.3, 0, 1, 0)
fpsLabel.Position = UDim2.new(0.7, 0, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 60"
fpsLabel.TextColor3 = colors.text
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 14
fpsLabel.Parent = watermark

local bindsFrame = Instance.new("Frame")
bindsFrame.Size = UDim2.new(0, 220, 0, 50)
bindsFrame.Position = UDim2.new(1, -230, 0, 65)
bindsFrame.BackgroundColor3 = colors.bg
bindsFrame.BackgroundTransparency = 0.2
bindsFrame.BorderSizePixel = 0
bindsFrame.Active = true
bindsFrame.Draggable = true
bindsFrame.Parent = screenGui
Instance.new("UICorner", bindsFrame).CornerRadius = UDim.new(0, 16)
addShadow(bindsFrame, 25, 0.7)

local bindsHeader = Instance.new("TextLabel")
bindsHeader.Size = UDim2.new(1, -20, 0, 24)
bindsHeader.Position = UDim2.new(0, 10, 0, 6)
bindsHeader.BackgroundTransparency = 1
bindsHeader.Text = "ACTIVE BINDS"
bindsHeader.TextColor3 = colors.accent
bindsHeader.TextXAlignment = Enum.TextXAlignment.Left
bindsHeader.Font = Enum.Font.GothamBold
bindsHeader.TextSize = 16
bindsHeader.Parent = bindsFrame

local separator = Instance.new("Frame")
separator.Size = UDim2.new(1, -20, 0, 2)
separator.Position = UDim2.new(0, 10, 0, 30)
separator.BackgroundColor3 = colors.accent
separator.BackgroundTransparency = 0.3
separator.BorderSizePixel = 0
separator.Parent = bindsFrame
Instance.new("UICorner", separator).CornerRadius = UDim.new(0, 1)

local bindsList = Instance.new("Frame")
bindsList.Size = UDim2.new(1, -20, 0, 0)
bindsList.Position = UDim2.new(0, 10, 0, 36)
bindsList.BackgroundTransparency = 1
bindsList.Parent = bindsFrame

local function updateBinds()
    for _, child in ipairs(bindsList:GetChildren()) do
        child:Destroy()
    end

    local binds = {}
    if settings.aimbot then table.insert(binds, "M2 Aimbot") end
    if settings.esp then table.insert(binds, "ESP") end
    if settings.thirdPerson then table.insert(binds, "Third Person") end
    if settings.chinahat then table.insert(binds, "China Hat") end

    local yOffset = 0
    for _, bind in ipairs(binds) do
        local marker = Instance.new("Frame")
        marker.Size = UDim2.new(0, 6, 0, 6)
        marker.Position = UDim2.new(0, 0, 0, yOffset + 4)
        marker.BackgroundColor3 = colors.accent
        marker.BorderSizePixel = 0
        marker.Parent = bindsList
        Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 18)
        label.Position = UDim2.new(0, 12, 0, yOffset)
        label.BackgroundTransparency = 1
        label.Text = bind
        label.TextColor3 = colors.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = bindsList

        yOffset = yOffset + 22
    end

    bindsList.Size = UDim2.new(1, -20, 0, yOffset)
    bindsFrame.Size = UDim2.new(0, 220, 0, 40 + yOffset)
end
updateBinds()

local function hasBinds()
    return settings.aimbot or settings.esp or settings.thirdPerson or settings.chinahat
end

local function updateWidgets()
    if menuVisible then
        watermark.Visible = false
        bindsFrame.Visible = false
    else
        watermark.Visible = true
        bindsFrame.Visible = hasBinds()
    end
end
updateWidgets()

-- Новая реализация China Hat (3D конус)
local HAT_MESH_ID = "rbxassetid://785967755"
local HAT_COLOR = Color3.fromRGB(230, 50, 50)
local HAT_SCALE = Vector3.new(3, 6, 3)

local function removeHat(char)
    if char then
        local oldHat = char:FindFirstChild("ChinaHat")
        if oldHat then
            oldHat:Destroy()
        end
    end
end

local function addHat(char)
    removeHat(char)
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    local hat = Instance.new("Part")
    hat.Name = "ChinaHat"
    hat.Size = Vector3.new(1, 1, 1)
    hat.Material = Enum.Material.Neon
    hat.Color = HAT_COLOR
    hat.CanCollide = false
    hat.Anchored = false
    hat.Parent = workspace

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = HAT_MESH_ID
    mesh.Scale = HAT_SCALE
    mesh.Parent = hat

    local headAtt = Instance.new("Attachment")
    headAtt.Name = "ChinaHatAtt"
    headAtt.Position = Vector3.new(0, 1.5, 0)
    headAtt.Parent = head

    local hatAtt = Instance.new("Attachment")
    hatAtt.Position = Vector3.new(0, -2.8, 0)
    hatAtt.Parent = hat

    local alignPos = Instance.new("AlignPosition")
    alignPos.Attachment0 = headAtt
    alignPos.Attachment1 = hatAtt
    alignPos.RigidityEnabled = true
    alignPos.MaxForce = math.huge
    alignPos.Responsiveness = 200
    alignPos.Parent = hat

    local alignOri = Instance.new("AlignOrientation")
    alignOri.Attachment0 = headAtt
    alignOri.Attachment1 = hatAtt
    alignOri.RigidityEnabled = true
    alignOri.MaxTorque = math.huge
    alignOri.Responsiveness = 200
    alignOri.Parent = hat

    return hat
end

local function updateChinahat()
    if chinahatObj then
        chinahatObj:Destroy()
        chinahatObj = nil
    end
    if not settings.chinahat then return end
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    chinahatObj = addHat(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function()
    if settings.chinahat then
        task.wait(0.5)
        updateChinahat()
    end
end)

if LocalPlayer.Character then
    task.wait(0.5)
    updateChinahat()
end

local function updateStats()
    frameCount = frameCount + 1
    local t = tick()
    if t - lastTime >= 1 then
        fps = frameCount
        frameCount = 0
        lastTime = t
    end
    ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    pingLabel.Text = "Ping: " .. ping .. "ms"
    fpsLabel.Text = "FPS: " .. fps
end

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = settings.fov
fovCircle.Thickness = 2
fovCircle.Color = colors.accent
fovCircle.NumSides = 64
fovCircle.Filled = false

local function isPlayerVisible(player)
    if not player.Character then return false end
    local head = player.Character:FindFirstChild("Head")
    if head then
        local ray = Ray.new(Camera.CFrame.Position, head.Position - Camera.CFrame.Position)
        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        if hit and hit:IsDescendantOf(player.Character) then return true end
    end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local ray = Ray.new(Camera.CFrame.Position, root.Position - Camera.CFrame.Position)
        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        if hit and hit:IsDescendantOf(player.Character) then return true end
    end
    return false
end

local function getClosestTarget()
    local closest, shortest = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(settings.targetPart) then
            local head = p.Character[settings.targetPart]
            local worldDist = (head.Position - Camera.CFrame.Position).Magnitude
            if worldDist < settings.minDist or worldDist > settings.maxDist then continue end
            if settings.checkVis and not isPlayerVisible(p) then continue end
            local scr, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(scr.X, scr.Y) - center).Magnitude
                if dist <= settings.fov and dist < shortest then
                    shortest, closest = dist, head
                end
            end
        end
    end
    return closest
end

connection = RunService.RenderStepped:Connect(function()
    updateStats()
    fovCircle.Visible = settings.aimbot
    if settings.aimbot then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Radius = settings.fov
        if UIS:IsMouseButtonPressed(settings.aimKey) then
            local target = getClosestTarget()
            if target then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end
    end
    if settings.thirdPerson and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraType = Enum.CameraType.Follow
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
    else
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = nil
    end
end)

local espCorners = {}

local function createESP(player)
    if player == LocalPlayer or espCorners[player] then return end
    local lines = {}
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 2
        line.Color = colors.accent
        table.insert(lines, line)
    end
    local healthBg = Drawing.new("Square")
    healthBg.Visible = false
    healthBg.Thickness = 1
    healthBg.Filled = true
    healthBg.Color = colors.darker

    local healthFill = Drawing.new("Square")
    healthFill.Visible = false
    healthFill.Thickness = 1
    healthFill.Filled = true

    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = colors.text
    name.Size = 16
    name.Center = true
    name.Outline = true

    espCorners[player] = {lines = lines, healthBg = healthBg, healthFill = healthFill, name = name}
end

local function removeESP(player)
    if espCorners[player] then
        for _, line in ipairs(espCorners[player].lines) do line:Remove() end
        espCorners[player].healthBg:Remove()
        espCorners[player].healthFill:Remove()
        espCorners[player].name:Remove()
        espCorners[player] = nil
    end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
for _, p in ipairs(Players:GetPlayers()) do createESP(p) end

espConn = RunService.RenderStepped:Connect(function()
    if not settings.esp then
        for _, data in pairs(espCorners) do
            for _, line in ipairs(data.lines) do line.Visible = false end
            data.healthBg.Visible = false
            data.healthFill.Visible = false
            data.name.Visible = false
        end
        return
    end

    for p, data in pairs(espCorners) do
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local humanoid = p.Character.Humanoid
            local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
            local anyOnScreen = false

            for _, child in ipairs(p.Character:GetChildren()) do
                if child:IsA("BasePart") then
                    local scr, onScreen = Camera:WorldToViewportPoint(child.Position)
                    if onScreen then
                        anyOnScreen = true
                        if scr.X < minX then minX = scr.X end
                        if scr.X > maxX then maxX = scr.X end
                        if scr.Y < minY then minY = scr.Y end
                        if scr.Y > maxY then maxY = scr.Y end
                    end
                end
            end

            if anyOnScreen then
                local pad = 8
                local x1 = minX - pad
                local y1 = minY - pad
                local x2 = maxX + pad
                local y2 = maxY + pad
                local cornerLen = 12

                data.lines[1].From = Vector2.new(x1, y1)
                data.lines[1].To = Vector2.new(x1 + cornerLen, y1)
                data.lines[2].From = Vector2.new(x1, y1)
                data.lines[2].To = Vector2.new(x1, y1 + cornerLen)

                data.lines[3].From = Vector2.new(x2, y1)
                data.lines[3].To = Vector2.new(x2 - cornerLen, y1)
                data.lines[4].From = Vector2.new(x2, y1)
                data.lines[4].To = Vector2.new(x2, y1 + cornerLen)

                data.lines[5].From = Vector2.new(x1, y2)
                data.lines[5].To = Vector2.new(x1 + cornerLen, y2)
                data.lines[6].From = Vector2.new(x1, y2)
                data.lines[6].To = Vector2.new(x1, y2 - cornerLen)

                data.lines[7].From = Vector2.new(x2, y2)
                data.lines[7].To = Vector2.new(x2 - cornerLen, y2)
                data.lines[8].From = Vector2.new(x2, y2)
                data.lines[8].To = Vector2.new(x2, y2 - cornerLen)

                for i = 1, 8 do data.lines[i].Visible = true end

                data.name.Position = Vector2.new((x1 + x2)/2, y1 - 20)
                data.name.Text = p.Name
                data.name.Visible = true

                local barWidth = 5
                local barX = x1 - barWidth - 6
                local barY = y1
                local barHeight = y2 - y1

                data.healthBg.Size = Vector2.new(barWidth, barHeight)
                data.healthBg.Position = Vector2.new(barX, barY)
                data.healthBg.Visible = true

                local hp = humanoid.Health / humanoid.MaxHealth
                local fillHeight = barHeight * hp
                local fillY = barY + (barHeight - fillHeight)
                local hue = hp * 0.33
                data.healthFill.Color = Color3.fromHSV(hue, 1, 1)
                data.healthFill.Size = Vector2.new(barWidth, fillHeight)
                data.healthFill.Position = Vector2.new(barX, fillY)
                data.healthFill.Visible = true
            else
                for _, line in ipairs(data.lines) do line.Visible = false end
                data.healthBg.Visible = false
                data.healthFill.Visible = false
                data.name.Visible = false
            end
        else
            for _, line in ipairs(data.lines) do line.Visible = false end
            data.healthBg.Visible = false
            data.healthFill.Visible = false
            data.name.Visible = false
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    connection:Disconnect()
    espConn:Disconnect()
    fovCircle:Remove()
    if chinahatObj then chinahatObj:Destroy() end
    for _, data in pairs(espCorners) do
        for _, line in ipairs(data.lines) do line:Remove() end
        data.healthBg:Remove()
        data.healthFill:Remove()
        data.name:Remove()
    end
    screenGui:Destroy()
end)

UIS.InputBegan:Connect(function(i, g)
    if g or i.KeyCode ~= Enum.KeyCode.RightShift then return end
    menuVisible = not menuVisible
    local goal = {}
    if menuVisible then
        goal.Size = UDim2.new(0, 340, 0, 240)
        goal.Position = UDim2.new(0.5, -170, 0.5, -120)
        goal.BackgroundTransparency = 0.1
    else
        goal.Size = UDim2.new(0, 0, 0, 0)
        goal.Position = UDim2.new(0.5, 0, 0.5, 0)
        goal.BackgroundTransparency = 1
    end
    TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), goal):Play()
    updateWidgets()

    if not menuVisible then
        updateBinds()
        local widgetsToShow = {watermark}
        if hasBinds() then table.insert(widgetsToShow, bindsFrame) end
        for _, w in ipairs(widgetsToShow) do
            w.Visible = true
            w.BackgroundTransparency = 1
            for _, c in ipairs(w:GetChildren()) do if c:IsA("TextLabel") then c.TextTransparency = 1 end end
            TweenService:Create(w, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {BackgroundTransparency = 0.2}):Play()
            for _, c in ipairs(w:GetChildren()) do if c:IsA("TextLabel") then TweenService:Create(c, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {TextTransparency = 0}):Play() end end
        end
    else
        for _, w in ipairs({watermark, bindsFrame}) do
            TweenService:Create(w, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
            for _, c in ipairs(w:GetChildren()) do if c:IsA("TextLabel") then TweenService:Create(c, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {TextTransparency = 1}):Play() end end
            w.Visible = false
        end
    end
end)

mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundTransparency = 1
TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 340, 0, 240),
    Position = UDim2.new(0.5, -170, 0.5, -120),
    BackgroundTransparency = 0.1
}):Play()