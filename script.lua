local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

-- 1. ЗАЩИТА ОТ ПОВТОРНОГО ЗАПУСКА
if playerGui:FindFirstChild("CloudHub") then
    playerGui:FindFirstChild("CloudHub"):Destroy() 
end

-- 2. ОСНОВНОЙ КОНТЕЙНЕР
local CloudHub = Instance.new("ScreenGui")
CloudHub.Name = "CloudHub"
CloudHub.DisplayOrder = 999
CloudHub.ResetOnSpawn = false
CloudHub.Parent = playerGui

-- 3. ГЛАВНЫЙ ФРЕЙМ
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 360) 
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = CloudHub

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 30)
mainCorner.Parent = MainFrame

-- 4. ШАПКА
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 25, 0, 0)
Title.Text = "VISUAL CHANGER" 
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(50, 50, 60)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local ArrowBtn = Instance.new("TextButton")
ArrowBtn.Size = UDim2.new(0, 40, 0, 40)
ArrowBtn.Position = UDim2.new(1, -50, 0, 10)
ArrowBtn.BackgroundTransparency = 1
ArrowBtn.Text = "▼"
ArrowBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
ArrowBtn.TextSize = 20
ArrowBtn.Font = Enum.Font.GothamBold
ArrowBtn.Parent = Header

-- КОНТЕЙНЕР ДЛЯ ЭЛЕМЕНТОВ
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -75)
Content.Position = UDim2.new(0, 0, 0, 70)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 0
Content.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Content
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.Padding = UDim.new(0, 12)

-- --- ФУНКЦИИ КОНСТРУКТОРА ГУИ ---

local function AddSlider(name, min, max, startVal, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.9, 0, 0, 75)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(250, 250, 252)
    SliderFrame.Parent = Content
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 15)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextColor3 = Color3.fromRGB(120, 120, 130)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = SliderFrame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0.9, 0, 0, 30)
    Bar.Position = UDim2.new(0.05, 0, 0, 35)
    Bar.BackgroundColor3 = Color3.fromRGB(230, 235, 245)
    Bar.Parent = SliderFrame
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 8)

    local ValueDisplay = Instance.new("TextLabel")
    ValueDisplay.Size = UDim2.new(1, 0, 1, 0)
    ValueDisplay.Text = tostring(startVal)
    ValueDisplay.Font = Enum.Font.GothamBold
    ValueDisplay.TextColor3 = Color3.fromRGB(80, 110, 180)
    ValueDisplay.TextSize = 16
    ValueDisplay.BackgroundTransparency = 1
    ValueDisplay.Parent = Bar

    local dragging = false
    local function update()
        local mousePos = UserInputService:GetMouseLocation().X
        local barPos = Bar.AbsolutePosition.X
        local barWidth = Bar.AbsoluteSize.X
        local perc = math.clamp((mousePos - barPos) / barWidth, 0, 1)
        local val = math.floor(min + (max - min) * perc)
        ValueDisplay.Text = tostring(val)
        callback(val)
    end
    Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update() end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local function AddDropdown(name, options, callback)
    local isDropped = false
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(0.9, 0, 0, 45)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(250, 250, 252)
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.Parent = Content
    Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 12)

    local HeaderBtn = Instance.new("TextButton")
    HeaderBtn.Size = UDim2.new(1, 0, 0, 45)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = name .. " ▼"
    HeaderBtn.Font = Enum.Font.GothamMedium
    HeaderBtn.TextColor3 = Color3.fromRGB(80, 100, 150)
    HeaderBtn.TextSize = 14
    HeaderBtn.Parent = DropdownFrame

    local OptionContainer = Instance.new("Frame")
    OptionContainer.Size = UDim2.new(1, 0, 0, #options * 35)
    OptionContainer.Position = UDim2.new(0, 0, 0, 45)
    OptionContainer.BackgroundTransparency = 1
    OptionContainer.Parent = DropdownFrame
    Instance.new("UIListLayout", OptionContainer)

    for _, opt in pairs(options) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 35)
        b.BackgroundTransparency = 1
        b.Text = opt
        b.TextColor3 = Color3.fromRGB(150, 150, 160)
        b.Font = Enum.Font.Gotham
        b.Parent = OptionContainer
        b.MouseButton1Click:Connect(function()
            HeaderBtn.Text = name .. " : " .. opt
            callback(opt)
            isDropped = false
            TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.9, 0, 0, 45)}):Play()
        end)
    end

    HeaderBtn.MouseButton1Click:Connect(function()
        isDropped = not isDropped
        local target = isDropped and (45 + (#options * 35)) or 45
        TweenService:Create(DropdownFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0.9, 0, 0, target)}):Play()
    end)
end

-- ФУНКЦИЯ ДЛЯ ТУМБЛЕРА (ВКЛ/ВЫКЛ)
local function AddToggle(name, startState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0.9, 0, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(250, 250, 252)
    ToggleFrame.Parent = Content
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 12)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextColor3 = Color3.fromRGB(120, 120, 130)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 40, 0, 20)
    Button.Position = UDim2.new(1, -55, 0.5, -10)
    Button.BackgroundColor3 = startState and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(200, 200, 200)
    Button.Text = ""
    Button.Parent = ToggleFrame
    Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)

    local state = startState
    Button.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(200, 200, 200)}):Play()
    end)
end

-- --- ПЕРФОРМАНС СТАТС ОКНО (КАК НА ФОТО) ---

local PerfStats = Instance.new("Frame")
PerfStats.Name = "PerformanceStats"
PerfStats.Size = UDim2.new(0, 180, 0, 75)
PerfStats.Position = UDim2.new(0.05, 0, 0.05, 0)
PerfStats.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PerfStats.BackgroundTransparency = 0.5 -- 50% прозрачности
PerfStats.BorderSizePixel = 0
PerfStats.Visible = false -- Изначально скрыто
PerfStats.Active = true
PerfStats.Parent = CloudHub

local perfCorner = Instance.new("UICorner")
perfCorner.CornerRadius = UDim.new(0, 12)
perfCorner.Parent = PerfStats

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -30, 1, 0)
StatsLabel.Position = UDim2.new(0, 15, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextSize = 16
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = PerfStats

-- ЛОГИКА ОБНОВЛЕНИЯ ДАННЫХ (ЗАМЕДЛЕННАЯ)
local lastUpdate = 0
local updateInterval = 0.5 -- Обновление раз в полсекунды

RunService.RenderStepped:Connect(function(dt)
    if PerfStats.Visible then
        lastUpdate = lastUpdate + dt
        if lastUpdate >= updateInterval then
            lastUpdate = 0
            local fps = math.floor(1/dt)
            local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
            StatsLabel.Text = "PING: " .. ping .. " ms\nFPS: " .. fps
        end
    end
end)

-- ДРАГ ДЛЯ ОКНА СТАТИСТИКИ
local pd, pds, psp
PerfStats.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then pd = true pds = i.Position psp = PerfStats.Position end end)
UserInputService.InputChanged:Connect(function(i) if pd and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - pds
    PerfStats.Position = UDim2.new(psp.X.Scale, psp.X.Offset + delta.X, psp.Y.Scale, psp.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then pd = false end end)

-- --- НАПОЛНЕНИЕ МЕНЮ ---

AddSlider("Field of View", 70, 120, 70, function(v) camera.FieldOfView = v end)

AddDropdown("Graphics", {"default", "Neon", "Midnight", "Vintage"}, function(selected)
    local oldBloom = Lighting:FindFirstChild("NeonBloom")
    if oldBloom then oldBloom:Destroy() end
    
    Lighting.Brightness = 2
    Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    Lighting.ExposureCompensation = 0
    Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
    Lighting.FogEnd = 100000

    if selected == "default" then
        Lighting.ClockTime = 14
        Lighting.Brightness = 3
    elseif selected == "Neon" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0
        Lighting.ExposureCompensation = 0.5
        Lighting.OutdoorAmbient = Color3.fromRGB(45, 0, 80)
        Lighting.Ambient = Color3.fromRGB(30, 0, 50)
        Lighting.ColorShift_Top = Color3.fromRGB(120, 0, 255)
        local b = Instance.new("BloomEffect", Lighting)
        b.Name = "NeonBloom" b.Intensity = 1.3 b.Size = 24 b.Threshold = 0.8
    elseif selected == "Midnight" then
        Lighting.ClockTime = 0
        Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 60)
    elseif selected == "Vintage" then
        Lighting.ClockTime = 17
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 110, 80)
        Lighting.FogColor = Color3.fromRGB(100, 90, 70) 
        Lighting.FogEnd = 2800
    end
end)

AddSlider("Time", 0, 24, 14, function(v) Lighting.ClockTime = v end)

-- ВКЛЮЧАЛКА СТАТИСТИКИ
AddToggle("Performance Stats", false, function(state)
    PerfStats.Visible = state
end)

-- --- СИСТЕМНАЯ ЛОГИКА ГЛАВНОГО ОКНА ---

local isMenuOpened = true
ArrowBtn.MouseButton1Click:Connect(function()
    isMenuOpened = not isMenuOpened
    local targetSize = isMenuOpened and UDim2.new(0, 350, 0, 360) or UDim2.new(0, 350, 0, 60)
    local targetRot = isMenuOpened and 0 or -90
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    TweenService:Create(ArrowBtn, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Rotation = targetRot}):Play()
end)

local d, ds, sp
Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - ds
    MainFrame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
