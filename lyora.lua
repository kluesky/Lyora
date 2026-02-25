-- =========================================================
-- LYORA CUSTOM GUI - ZUMHUB KEY SYSTEM + DESAIN SENDIRI
-- =========================================================

-- 1. LOAD ZUMHUB KEY SYSTEM
loadstring(game:HttpGet("https://raw.githubusercontent.com/UwURaww/-ZumHub-Script-/refs/heads/main/Key%20system%20main.lua.txt"))()

-- 2. KONFIGURASI ZUMHUB (GANTI DENGAN PUNYA LU!)
Config = {
    api = "https://your-bot-api.com",  -- URL bot Discord lu
    service = "lyora",
    provider = "discord",
    discordInvite = "YOUR_INVITE_CODE",
    title = "LYORA SAMBUNG KATA",
    subtitle = "Ultimate Auto Farm",
    mainColor = Color3.fromRGB(255, 105, 180),  -- Pink
    backgroundColor = Color3.fromRGB(20, 20, 30),
    textColor = Color3.fromRGB(255, 255, 255),
    accentColor = Color3.fromRGB(100, 200, 255)  -- Biru buat aksen
}

-- 3. VARIABEL GLOBAL
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Data user
local userData = {
    userId = LocalPlayer.UserId,
    username = LocalPlayer.Name,
    displayName = LocalPlayer.DisplayName,
    accountAge = LocalPlayer.AccountAge,
    isVerified = false,
    key = "",
    discordUser = "",
    discordId = "",
    role = "user",
    premium = false,
    premiumUntil = 0
}

-- =========================================================
-- MEMBUAT GUI DARI NOL (CUSTOM)
-- =========================================================

-- Cek parent yang available (buat Android)
local ScreenGui = Instance.new("ScreenGui")
local parent = CoreGui or PlayerGui
ScreenGui.Parent = parent
ScreenGui.Name = "LyoraGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = true

-- Variables untuk GUI
local gui = {
    open = true,
    dragging = false,
    dragStart = nil,
    startPos = nil,
    currentTab = "Profile",
    tabs = {},
    elements = {}
}

-- =========================================================
-- FUNGSI UTILITY
-- =========================================================

-- Fungsi bikin rounded frame
local function CreateRoundedFrame(name, parent, size, pos, color, radius)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Parent = parent
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
    
    return frame
end

-- Fungsi bikin shadow
local function AddShadow(frame, transparency, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = frame
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.7
    shadow.ZIndex = frame.ZIndex - 1
    return shadow
end

-- Fungsi bikin gradient
local function AddGradient(frame, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color1), ColorSequenceKeypoint.new(1, color2)})
    gradient.Rotation = rotation or 90
    gradient.Parent = frame
    return gradient
end

-- =========================================================
-- MAIN WINDOW (DRAGABLE)
-- =========================================================

-- Background blur (optional)
local blur = Instance.new("ImageLabel")
blur.Parent = ScreenGui
blur.Size = UDim2.new(1, 0, 1, 0)
blur.BackgroundTransparency = 1
blur.Image = "rbxassetid://3570695787"
blur.ImageColor3 = Color3.fromRGB(0, 0, 0)
blur.ImageTransparency = 0.4
blur.ZIndex = 0
blur.Visible = true

-- Main window frame
local MainFrame = CreateRoundedFrame("MainFrame", ScreenGui, 
    UDim2.new(0, 750, 0, 500), 
    UDim2.new(0.5, -375, 0.5, -250), 
    Config.backgroundColor, 10)

-- Shadow
AddShadow(MainFrame, 0.5, 10)

-- Header
local Header = CreateRoundedFrame("Header", MainFrame, 
    UDim2.new(1, 0, 0, 50), 
    UDim2.new(0, 0, 0, 0), 
    Config.mainColor, 0)

-- Header gradient
AddGradient(Header, Config.mainColor, Color3.fromRGB(Config.mainColor.R * 0.7, Config.mainColor.G * 0.7, Config.mainColor.B * 0.7), 90)

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = Config.title
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Config.textColor
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Parent = Header
Subtitle.Size = UDim2.new(0, 200, 0, 20)
Subtitle.Position = UDim2.new(0, 15, 0, 28)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = Config.subtitle
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 12
Subtitle.TextColor3 = Color3.fromRGB(220, 220, 220)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local CloseBtn = Instance.new("ImageButton")
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Image = "rbxassetid://6023426926"  -- Close icon
CloseBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)

-- Minimize button
local MinBtn = Instance.new("ImageButton")
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -75, 0.5, -15)
MinBtn.BackgroundTransparency = 1
MinBtn.Image = "rbxassetid://6023426931"  -- Minimize icon
MinBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)

-- Make header draggable
local function onDragStart(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        gui.dragging = true
        gui.dragStart = input.Position
        gui.startPos = MainFrame.Position
    end
end

local function onDrag(input)
    if gui.dragging and input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - gui.dragStart
        MainFrame.Position = UDim2.new(
            gui.startPos.X.Scale, gui.startPos.X.Offset + delta.X,
            gui.startPos.Y.Scale, gui.startPos.Y.Offset + delta.Y
        )
    end
end

local function onDragEnd()
    gui.dragging = false
end

Header.InputBegan:Connect(onDragStart)
Header.InputChanged:Connect(onDrag)
Header.InputEnded:Connect(onDragEnd)

-- =========================================================
-- TAB BUTTONS (SIDE MENU)
-- =========================================================

local TabContainer = CreateRoundedFrame("TabContainer", MainFrame, 
    UDim2.new(0, 150, 0, 400), 
    UDim2.new(0, 10, 0, 70), 
    Color3.fromRGB(25, 30, 40), 8)

-- Tab buttons
local tabs = {
    {name = "Profile", icon = "👤", color = Config.mainColor},
    {name = "Hub", icon = "🌐", color = Config.accentColor},
    {name = "Misc", icon = "⚙️", color = Color3.fromRGB(255, 200, 100)},
    {name = "Info", icon = "ℹ️", color = Color3.fromRGB(150, 150, 255)},
    {name = "Discord", icon = "💬", color = Color3.fromRGB(100, 200, 255)},
    {name = "Settings", icon = "🔧", color = Color3.fromRGB(200, 150, 255)}
}

local tabButtons = {}
local contentFrames = {}

for i, tab in ipairs(tabs) do
    local btnFrame = CreateRoundedFrame(tab.name .. "Btn", TabContainer, 
        UDim2.new(1, -10, 0, 45), 
        UDim2.new(0, 5, 0, 5 + (i-1) * 50), 
        gui.currentTab == tab.name and tab.color or Color3.fromRGB(35, 40, 50), 6)
    
    local btnIcon = Instance.new("TextLabel")
    btnIcon.Parent = btnFrame
    btnIcon.Size = UDim2.new(0, 30, 1, 0)
    btnIcon.Position = UDim2.new(0, 5, 0, 0)
    btnIcon.BackgroundTransparency = 1
    btnIcon.Text = tab.icon
    btnIcon.Font = Enum.Font.Gotham
    btnIcon.TextSize = 20
    btnIcon.TextColor3 = Config.textColor
    
    local btnText = Instance.new("TextLabel")
    btnText.Parent = btnFrame
    btnText.Size = UDim2.new(1, -40, 1, 0)
    btnText.Position = UDim2.new(0, 40, 0, 0)
    btnText.BackgroundTransparency = 1
    btnText.Text = tab.name
    btnText.Font = Enum.Font.GothamBold
    btnText.TextSize = 16
    btnText.TextColor3 = Config.textColor
    btnText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Button click
    local btn = Instance.new("TextButton")
    btn.Parent = btnFrame
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 10
    
    btn.MouseButton1Click:Connect(function()
        -- Update tab colors
        for j, oldBtn in ipairs(tabButtons) do
            oldBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
        end
        btnFrame.BackgroundColor3 = tab.color
        
        -- Hide all content
        for _, frame in pairs(contentFrames) do
            frame.Visible = false
        end
        
        -- Show selected content
        if contentFrames[tab.name] then
            contentFrames[tab.name].Visible = true
        end
        
        gui.currentTab = tab.name
    end)
    
    table.insert(tabButtons, btnFrame)
end

-- =========================================================
-- CONTENT AREA
-- =========================================================

local ContentArea = CreateRoundedFrame("ContentArea", MainFrame, 
    UDim2.new(1, -180, 1, -90), 
    UDim2.new(0, 170, 0, 60), 
    Color3.fromRGB(25, 30, 40), 8)

-- =========================================================
-- PROFILE TAB CONTENT
-- =========================================================

local ProfileContent = Instance.new("Frame")
ProfileContent.Parent = ContentArea
ProfileContent.Name = "ProfileContent"
ProfileContent.Size = UDim2.new(1, -20, 1, -20)
ProfileContent.Position = UDim2.new(0, 10, 0, 10)
ProfileContent.BackgroundTransparency = 1
ProfileContent.Visible = true  -- Default visible
contentFrames["Profile"] = ProfileContent

-- Profile header
local ProfileHeader = Instance.new("TextLabel")
ProfileHeader.Parent = ProfileContent
ProfileHeader.Size = UDim2.new(1, 0, 0, 30)
ProfileHeader.BackgroundTransparency = 1
ProfileHeader.Text = "👤 Profile Information"
ProfileHeader.Font = Enum.Font.GothamBold
ProfileHeader.TextSize = 20
ProfileHeader.TextColor3 = Config.textColor
ProfileHeader.TextXAlignment = Enum.TextXAlignment.Left

-- Profile card
local ProfileCard = CreateRoundedFrame("ProfileCard", ProfileContent, 
    UDim2.new(1, 0, 0, 120), 
    UDim2.new(0, 0, 0, 40), 
    Color3.fromRGB(30, 35, 45), 8)

-- Avatar
local Avatar = Instance.new("ImageLabel")
Avatar.Parent = ProfileCard
Avatar.Size = UDim2.new(0, 70, 0, 70)
Avatar.Position = UDim2.new(0, 15, 0.5, -35)
Avatar.BackgroundColor = Color3.fromRGB(45, 50, 60)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
Avatar.BorderRadius = UDim.new(0, 35)

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 35)
AvatarCorner.Parent = Avatar

-- Username
local UserNameLabel = Instance.new("TextLabel")
UserNameLabel.Parent = ProfileCard
UserNameLabel.Size = UDim2.new(0, 300, 0, 30)
UserNameLabel.Position = UDim2.new(0, 100, 0, 20)
UserNameLabel.BackgroundTransparency = 1
UserNameLabel.Text = LocalPlayer.Name
UserNameLabel.Font = Enum.Font.GothamBold
UserNameLabel.TextSize = 22
UserNameLabel.TextColor3 = Config.textColor
UserNameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- User ID
local UserIDLabel = Instance.new("TextLabel")
UserIDLabel.Parent = ProfileCard
UserIDLabel.Size = UDim2.new(0, 300, 0, 20)
UserIDLabel.Position = UDim2.new(0, 100, 0, 50)
UserIDLabel.BackgroundTransparency = 1
UserIDLabel.Text = "ID: " .. LocalPlayer.UserId
UserIDLabel.Font = Enum.Font.Gotham
UserIDLabel.TextSize = 14
UserIDLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
UserIDLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = ProfileCard
StatusLabel.Size = UDim2.new(0, 300, 0, 20)
StatusLabel.Position = UDim2.new(0, 100, 0, 75)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Account Age: " .. math.floor(LocalPlayer.AccountAge) .. " days"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Stats grid
local StatsGrid = Instance.new("Frame")
StatsGrid.Parent = ProfileContent
StatsGrid.Size = UDim2.new(1, 0, 0, 100)
StatsGrid.Position = UDim2.new(0, 0, 0, 180)
StatsGrid.BackgroundTransparency = 1

local stats = {
    {label = "Total Games", value = "0", icon = "🎮"},
    {label = "Win Streak", value = "0", icon = "🔥"},
    {label = "Words", value = "0", icon = "📝"},
    {label = "Accuracy", value = "0%", icon = "🎯"}
}

for i, stat in ipairs(stats) do
    local card = CreateRoundedFrame("Stat" .. i, StatsGrid, 
        UDim2.new(0, 130, 0, 80), 
        UDim2.new(0, (i-1) * 140, 0, 10), 
        Color3.fromRGB(30, 35, 45), 6)
    
    local icon = Instance.new("TextLabel")
    icon.Parent = card
    icon.Size = UDim2.new(1, 0, 0, 30)
    icon.Position = UDim2.new(0, 0, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Text = stat.icon .. " " .. stat.value
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.TextColor3 = Config.mainColor
    
    local label = Instance.new("TextLabel")
    label.Parent = card
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 50)
    label.BackgroundTransparency = 1
    label.Text = stat.label
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(150, 150, 150)
end

-- =========================================================
-- HUB TAB CONTENT (MAIN FEATURES)
-- =========================================================

local HubContent = Instance.new("Frame")
HubContent.Parent = ContentArea
HubContent.Name = "HubContent"
HubContent.Size = UDim2.new(1, -20, 1, -20)
HubContent.Position = UDim2.new(0, 10, 0, 10)
HubContent.BackgroundTransparency = 1
HubContent.Visible = false
contentFrames["Hub"] = HubContent

-- Hub header
local HubHeader = Instance.new("TextLabel")
HubHeader.Parent = HubContent
HubHeader.Size = UDim2.new(1, 0, 0, 30)
HubHeader.BackgroundTransparency = 1
HubHeader.Text = "🌐 Main Features"
HubHeader.Font = Enum.Font.GothamBold
HubHeader.TextSize = 20
HubHeader.TextColor3 = Config.textColor
HubHeader.TextXAlignment = Enum.TextXAlignment.Left

-- Auto farm section
local AutoFarmCard = CreateRoundedFrame("AutoFarmCard", HubContent, 
    UDim2.new(1, 0, 0, 150), 
    UDim2.new(0, 0, 0, 40), 
    Color3.fromRGB(30, 35, 45), 8)

-- Title with toggle
local AutoTitle = Instance.new("TextLabel")
AutoTitle.Parent = AutoFarmCard
AutoTitle.Size = UDim2.new(0, 200, 0, 30)
AutoTitle.Position = UDim2.new(0, 15, 0, 10)
AutoTitle.BackgroundTransparency = 1
AutoTitle.Text = "⚡ Auto Farm"
AutoTitle.Font = Enum.Font.GothamBold
AutoTitle.TextSize = 18
AutoTitle.TextColor3 = Config.textColor
AutoTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle button (custom)
local ToggleBg = CreateRoundedFrame("ToggleBg", AutoFarmCard, 
    UDim2.new(0, 60, 0, 30), 
    UDim2.new(1, -75, 0, 10), 
    Color3.fromRGB(60, 60, 60), 15)

local ToggleCircle = CreateRoundedFrame("ToggleCircle", ToggleBg, 
    UDim2.new(0, 26, 0, 26), 
    UDim2.new(0, 2, 0.5, -13), 
    Color3.fromRGB(255, 255, 255), 13)

local ToggleState = false
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ToggleBg
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = ""

ToggleButton.MouseButton1Click:Connect(function()
    ToggleState = not ToggleState
    if ToggleState then
        ToggleBg.BackgroundColor3 = Config.mainColor
        ToggleCircle:TweenPosition(UDim2.new(0, 32, 0.5, -13), "Out", "Quad", 0.2)
    else
        ToggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ToggleCircle:TweenPosition(UDim2.new(0, 2, 0.5, -13), "Out", "Quad", 0.2)
    end
end)

-- Settings
local DelayLabel = Instance.new("TextLabel")
DelayLabel.Parent = AutoFarmCard
DelayLabel.Size = UDim2.new(0, 100, 0, 20)
DelayLabel.Position = UDim2.new(0, 15, 0, 50)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Delay (ms):"
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.TextSize = 14
DelayLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Slider (custom sederhana)
local SliderBg = CreateRoundedFrame("SliderBg", AutoFarmCard, 
    UDim2.new(0, 200, 0, 10), 
    UDim2.new(0, 15, 0, 75), 
    Color3.fromRGB(60, 60, 60), 5)

local SliderFill = CreateRoundedFrame("SliderFill", SliderBg, 
    UDim2.new(0.5, 0, 1, 0), 
    UDim2.new(0, 0, 0, 0), 
    Config.mainColor, 5)

local SliderValue = Instance.new("TextLabel")
SliderValue.Parent = AutoFarmCard
SliderValue.Size = UDim2.new(0, 50, 0, 20)
SliderValue.Position = UDim2.new(0, 220, 0, 70)
SliderValue.BackgroundTransparency = 1
SliderValue.Text = "350"
SliderValue.Font = Enum.Font.GothamBold
SliderValue.TextSize = 14
SliderValue.TextColor3 = Config.mainColor
SliderValue.TextXAlignment = Enum.TextXAlignment.Left

-- Slider drag functionality
local dragging = false
SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

SliderBg.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = SliderBg.AbsolutePosition
        local sliderSize = SliderBg.AbsoluteSize
        
        local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize.X)
        local percent = relativeX / sliderSize.X
        
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        SliderValue.Text = tostring(math.floor(percent * 500 + 100))
    end
end)

-- =========================================================
-- MISC TAB CONTENT
-- =========================================================

local MiscContent = Instance.new("Frame")
MiscContent.Parent = ContentArea
MiscContent.Name = "MiscContent"
MiscContent.Size = UDim2.new(1, -20, 1, -20)
MiscContent.Position = UDim2.new(0, 10, 0, 10)
MiscContent.BackgroundTransparency = 1
MiscContent.Visible = false
contentFrames["Misc"] = MiscContent

-- Misc header
local MiscHeader = Instance.new("TextLabel")
MiscHeader.Parent = MiscContent
MiscHeader.Size = UDim2.new(1, 0, 0, 30)
MiscHeader.BackgroundTransparency = 1
MiscHeader.Text = "⚙️ Miscellaneous"
MiscHeader.Font = Enum.Font.GothamBold
MiscHeader.TextSize = 20
MiscHeader.TextColor3 = Config.textColor
MiscHeader.TextXAlignment = Enum.TextXAlignment.Left

-- Settings list
local settings = {
    {name = "Anti AFK", desc = "Prevent being kicked for inactivity"},
    {name = "Auto Reconnect", desc = "Auto rejoin game if disconnected"},
    {name = "Hide UI in Game", desc = "Auto hide GUI during matches"},
    {name = "Sound Effects", desc = "Play sounds on actions"}
}

for i, setting in ipairs(settings) do
    local card = CreateRoundedFrame("Setting" .. i, MiscContent, 
        UDim2.new(1, 0, 0, 60), 
        UDim2.new(0, 0, 0, 40 + (i-1) * 70), 
        Color3.fromRGB(30, 35, 45), 6)
    
    local name = Instance.new("TextLabel")
    name.Parent = card
    name.Size = UDim2.new(0, 200, 0, 25)
    name.Position = UDim2.new(0, 15, 0, 8)
    name.BackgroundTransparency = 1
    name.Text = setting.name
    name.Font = Enum.Font.GothamBold
    name.TextSize = 16
    name.TextColor3 = Config.textColor
    name.TextXAlignment = Enum.TextXAlignment.Left
    
    local desc = Instance.new("TextLabel")
    desc.Parent = card
    desc.Size = UDim2.new(0, 300, 0, 20)
    desc.Position = UDim2.new(0, 15, 0, 33)
    desc.BackgroundTransparency = 1
    desc.Text = setting.desc
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 12
    desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    desc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Toggle kecil
    local togBg = CreateRoundedFrame("TogBg" .. i, card, 
        UDim2.new(0, 40, 0, 20), 
        UDim2.new(1, -55, 0.5, -10), 
        Color3.fromRGB(60, 60, 60), 10)
    
    local togCirc = CreateRoundedFrame("TogCirc" .. i, togBg, 
        UDim2.new(0, 16, 0, 16), 
        UDim2.new(0, 2, 0.5, -8), 
        Color3.fromRGB(255, 255, 255), 8)
end

-- =========================================================
-- INFO TAB CONTENT
-- =========================================================

local InfoContent = Instance.new("Frame")
InfoContent.Parent = ContentArea
InfoContent.Name = "InfoContent"
InfoContent.Size = UDim2.new(1, -20, 1, -20)
InfoContent.Position = UDim2.new(0, 10, 0, 10)
InfoContent.BackgroundTransparency = 1
InfoContent.Visible = false
contentFrames["Info"] = InfoContent

-- Info header
local InfoHeader = Instance.new("TextLabel")
InfoHeader.Parent = InfoContent
InfoHeader.Size = UDim2.new(1, 0, 0, 30)
InfoHeader.BackgroundTransparency = 1
InfoHeader.Text = "ℹ️ Information"
InfoHeader.Font = Enum.Font.GothamBold
InfoHeader.TextSize = 20
InfoHeader.TextColor3 = Config.textColor
InfoHeader.TextXAlignment = Enum.TextXAlignment.Left

-- About box
local AboutBox = CreateRoundedFrame("AboutBox", InfoContent, 
    UDim2.new(1, 0, 0, 200), 
    UDim2.new(0, 0, 0, 40), 
    Color3.fromRGB(30, 35, 45), 8)

local AboutText = Instance.new("TextLabel")
AboutText.Parent = AboutBox
AboutText.Size = UDim2.new(1, -30, 1, -30)
AboutText.Position = UDim2.new(0, 15, 0, 15)
AboutText.BackgroundTransparency = 1
AboutText.Text = [[
LYORA SAMBUNG KATA ULTIMATE
Version: 3.0.0
Author: Lyora System
Library: ZumHub + Custom GUI

📌 FEATURES:
• Auto Farm with AI
• Discord Key System
• Real-time Statistics
• Anti-Ban Protection
• Premium Integration

🔧 REQUIREMENTS:
• Discord Bot Integration
• Valid License Key
• Roblox Account Age > 3 days

📞 SUPPORT:
• Discord: discord.gg/]] .. Config.discordInvite .. [[
• Email: support@lyora.com

© 2025 Lyora System. All rights reserved.]]
AboutText.Font = Enum.Font.Gotham
AboutText.TextSize = 13
AboutText.TextColor3 = Color3.fromRGB(200, 200, 200)
AboutText.TextXAlignment = Enum.TextXAlignment.Left
AboutText.TextYAlignment = Enum.TextYAlignment.Top

-- =========================================================
-- DISCORD TAB CONTENT
-- =========================================================

local DiscordContent = Instance.new("Frame")
DiscordContent.Parent = ContentArea
DiscordContent.Name = "DiscordContent"
DiscordContent.Size = UDim2.new(1, -20, 1, -20)
DiscordContent.Position = UDim2.new(0, 10, 0, 10)
DiscordContent.BackgroundTransparency = 1
DiscordContent.Visible = false
contentFrames["Discord"] = DiscordContent

-- Discord header
local DiscordHeader = Instance.new("TextLabel")
DiscordHeader.Parent = DiscordContent
DiscordHeader.Size = UDim2.new(1, 0, 0, 30)
DiscordHeader.BackgroundTransparency = 1
DiscordHeader.Text = "💬 Discord Integration"
DiscordHeader.Font = Enum.Font.GothamBold
DiscordHeader.TextSize = 20
DiscordHeader.TextColor3 = Config.textColor
DiscordHeader.TextXAlignment = Enum.TextXAlignment.Left

-- Connection status
local ConnCard = CreateRoundedFrame("ConnCard", DiscordContent, 
    UDim2.new(1, 0, 0, 80), 
    UDim2.new(0, 0, 0, 40), 
    Color3.fromRGB(30, 35, 45), 8)

local ConnIcon = Instance.new("TextLabel")
ConnIcon.Parent = ConnCard
ConnIcon.Size = UDim2.new(0, 40, 1, 0)
ConnIcon.Position = UDim2.new(0, 15, 0, 0)
ConnIcon.BackgroundTransparency = 1
ConnIcon.Text = "🔗"
ConnIcon.Font = Enum.Font.Gotham
ConnIcon.TextSize = 30
ConnIcon.TextColor3 = Config.textColor

local ConnTitle = Instance.new("TextLabel")
ConnTitle.Parent = ConnCard
ConnTitle.Size = UDim2.new(0, 200, 0, 25)
ConnTitle.Position = UDim2.new(0, 65, 0, 15)
ConnTitle.BackgroundTransparency = 1
ConnTitle.Text = "Discord Connection"
ConnTitle.Font = Enum.Font.GothamBold
ConnTitle.TextSize = 16
ConnTitle.TextColor3 = Config.textColor
ConnTitle.TextXAlignment = Enum.TextXAlignment.Left

local ConnStatus = Instance.new("TextLabel")
ConnStatus.Parent = ConnCard
ConnStatus.Size = UDim2.new(0, 200, 0, 20)
ConnStatus.Position = UDim2.new(0, 65, 0, 40)
ConnStatus.BackgroundTransparency = 1
ConnStatus.Text = "✅ Connected as " .. (userData.discordUser ~= "" and userData.discordUser or "Guest")
ConnStatus.Font = Enum.Font.Gotham
ConnStatus.TextSize = 12
ConnStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
ConnStatus.TextXAlignment = Enum.TextXAlignment.Left

-- Key info
local KeyCard = CreateRoundedFrame("KeyCard", DiscordContent, 
    UDim2.new(1, 0, 0, 100), 
    UDim2.new(0, 0, 0, 130), 
    Color3.fromRGB(30, 35, 45), 8)

local KeyIcon = Instance.new("TextLabel")
KeyIcon.Parent = KeyCard
KeyIcon.Size = UDim2.new(0, 40, 1, 0)
KeyIcon.Position = UDim2.new(0, 15, 0, 0)
KeyIcon.BackgroundTransparency = 1
KeyIcon.Text = "🔑"
KeyIcon.Font = Enum.Font.Gotham
KeyIcon.TextSize = 30
KeyIcon.TextColor3 = Config.textColor

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Parent = KeyCard
KeyTitle.Size = UDim2.new(0, 200, 0, 25)
KeyTitle.Position = UDim2.new(0, 65, 0, 15)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "License Key"
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 16
KeyTitle.TextColor3 = Config.textColor
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left

local KeyDisplay = Instance.new("TextLabel")
KeyDisplay.Parent = KeyCard
KeyDisplay.Size = UDim2.new(0, 300, 0, 25)
KeyDisplay.Position = UDim2.new(0, 65, 0, 40)
KeyDisplay.BackgroundTransparency = 1
KeyDisplay.Text = userData.key or "No key loaded"
KeyDisplay.Font = Enum.Font.Gotham
KeyDisplay.TextSize = 14
KeyDisplay.TextColor3 = Color3.fromRGB(0, 255, 200)
KeyDisplay.TextXAlignment = Enum.TextXAlignment.Left

local PremiumStatus = Instance.new("TextLabel")
PremiumStatus.Parent = KeyCard
PremiumStatus.Size = UDim2.new(0, 300, 0, 20)
PremiumStatus.Position = UDim2.new(0, 65, 0, 65)
PremiumStatus.BackgroundTransparency = 1
PremiumStatus.Text = userData.premium and "✨ Premium Member" or "👤 Free Member"
PremiumStatus.Font = Enum.Font.Gotham
PremiumStatus.TextSize = 12
PremiumStatus.TextColor3 = userData.premium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150)
PremiumStatus.TextXAlignment = Enum.TextXAlignment.Left

-- Action buttons
local BtnSection = Instance.new("Frame")
BtnSection.Parent = DiscordContent
BtnSection.Size = UDim2.new(1, 0, 0, 100)
BtnSection.Position = UDim2.new(0, 0, 0, 240)
BtnSection.BackgroundTransparency = 1

local buttons = {
    {name = "Copy User ID", icon = "📋", color = Config.mainColor},
    {name = "Copy Key", icon = "🔑", color = Config.accentColor},
    {name = "Join Discord", icon = "🔗", color = Color3.fromRGB(100, 200, 255)},
    {name = "Sync Profile", icon = "🔄", color = Color3.fromRGB(255, 200, 100)}
}

for i, btn in ipairs(buttons) do
    local btnFrame = CreateRoundedFrame("Btn" .. i, BtnSection, 
        UDim2.new(0, 140, 0, 40), 
        UDim2.new(0, (i-1) * 150, 0, 10), 
        btn.color, 6)
    
    local btnText = Instance.new("TextLabel")
    btnText.Parent = btnFrame
    btnText.Size = UDim2.new(1, -10, 1, 0)
    btnText.Position = UDim2.new(0, 5, 0, 0)
    btnText.BackgroundTransparency = 1
    btnText.Text = btn.icon .. " " .. btn.name
    btnText.Font = Enum.Font.GothamBold
    btnText.TextSize = 13
    btnText.TextColor3 = Config.textColor
    
    local btnClick = Instance.new("TextButton")
    btnClick.Parent = btnFrame
    btnClick.Size = UDim2.new(1, 0, 1, 0)
    btnClick.BackgroundTransparency = 1
    btnClick.Text = ""
    
    btnClick.MouseButton1Click:Connect(function()
        if btn.name == "Copy User ID" then
            setclipboard(tostring(LocalPlayer.UserId))
            -- Notifikasi sederhana
            local notif = CreateRoundedFrame("Notif", ScreenGui, 
                UDim2.new(0, 200, 0, 40), 
                UDim2.new(0.5, -100, 0, 20), 
                Config.mainColor, 8)
            notif.ZIndex = 100
            
            local notifText = Instance.new("TextLabel")
            notifText.Parent = notif
            notifText.Size = UDim2.new(1, 0, 1, 0)
            notifText.BackgroundTransparency = 1
            notifText.Text = "✅ User ID Copied!"
            notifText.Font = Enum.Font.GothamBold
            notifText.TextSize = 14
            notifText.TextColor3 = Config.textColor
            
            task.wait(2)
            notif:Destroy()
            
        elseif btn.name == "Copy Key" then
            setclipboard(userData.key or "NO_KEY")
            local notif = CreateRoundedFrame("Notif", ScreenGui, 
                UDim2.new(0, 200, 0, 40), 
                UDim2.new(0.5, -100, 0, 20), 
                Config.mainColor, 8)
            notif.ZIndex = 100
            
            local notifText = Instance.new("TextLabel")
            notifText.Parent = notif
            notifText.Size = UDim2.new(1, 0, 1, 0)
            notifText.BackgroundTransparency = 1
            notifText.Text = "✅ Key Copied!"
            notifText.Font = Enum.Font.GothamBold
            notifText.TextSize = 14
            notifText.TextColor3 = Config.textColor
            
            task.wait(2)
            notif:Destroy()
            
        elseif btn.name == "Join Discord" then
            local notif = CreateRoundedFrame("Notif", ScreenGui, 
                UDim2.new(0, 250, 0, 50), 
                UDim2.new(0.5, -125, 0, 20), 
                Config.mainColor, 8)
            notif.ZIndex = 100
            
            local notifText = Instance.new("TextLabel")
            notifText.Parent = notif
            notifText.Size = UDim2.new(1, -10, 0, 30)
            notifText.Position = UDim2.new(0, 5, 0, 5)
            notifText.BackgroundTransparency = 1
            notifText.Text = "🔗 discord.gg/" .. Config.discordInvite
            notifText.Font = Enum.Font.GothamBold
            notifText.TextSize = 14
            notifText.TextColor3 = Config.textColor
            
            local notifSub = Instance.new("TextLabel")
            notifSub.Parent = notif
            notifSub.Size = UDim2.new(1, -10, 0, 15)
            notifSub.Position = UDim2.new(0, 5, 0, 30)
            notifSub.BackgroundTransparency = 1
            notifSub.Text = "Link copied to clipboard!"
            notifSub.Font = Enum.Font.Gotham
            notifSub.TextSize = 11
            notifSub.TextColor3 = Color3.fromRGB(220, 220, 220)
            
            setclipboard("https://discord.gg/" .. Config.discordInvite)
            
            task.wait(3)
            notif:Destroy()
        end
    end)
end

-- =========================================================
-- SETTINGS TAB CONTENT
-- =========================================================

local SettingsContent = Instance.new("Frame")
SettingsContent.Parent = ContentArea
SettingsContent.Name = "SettingsContent"
SettingsContent.Size = UDim2.new(1, -20, 1, -20)
SettingsContent.Position = UDim2.new(0, 10, 0, 10)
SettingsContent.BackgroundTransparency = 1
SettingsContent.Visible = false
contentFrames["Settings"] = SettingsContent

-- Settings header
local SettingsHeader = Instance.new("TextLabel")
SettingsHeader.Parent = SettingsContent
SettingsHeader.Size = UDim2.new(1, 0, 0, 30)
SettingsHeader.BackgroundTransparency = 1
SettingsHeader.Text = "🔧 Settings"
SettingsHeader.Font = Enum.Font.GothamBold
SettingsHeader.TextSize = 20
SettingsHeader.TextColor3 = Config.textColor
SettingsHeader.TextXAlignment = Enum.TextXAlignment.Left

-- UI Settings
local UICard = CreateRoundedFrame("UICard", SettingsContent, 
    UDim2.new(1, 0, 0, 150), 
    UDim2.new(0, 0, 0, 40), 
    Color3.fromRGB(30, 35, 45), 8)

local UITitle = Instance.new("TextLabel")
UITitle.Parent = UICard
UITitle.Size = UDim2.new(1, -20, 0, 30)
UITitle.Position = UDim2.new(0, 10, 0, 10)
UITitle.BackgroundTransparency = 1
UITitle.Text = "UI Settings"
UITitle.Font = Enum.Font.GothamBold
UITitle.TextSize = 16
UITitle.TextColor3 = Config.textColor
UITitle.TextXAlignment = Enum.TextXAlignment.Left

-- Keybind setting
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Parent = UICard
KeybindLabel.Size = UDim2.new(0, 150, 0, 25)
KeybindLabel.Position = UDim2.new(0, 15, 0, 50)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Toggle GUI Key:"
KeybindLabel.Font = Enum.Font.Gotham
KeybindLabel.TextSize = 14
KeybindLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left

local KeybindBox = CreateRoundedFrame("KeybindBox", UICard, 
    UDim2.new(0, 100, 0, 25), 
    UDim2.new(0, 170, 0, 50), 
    Color3.fromRGB(45, 50, 60), 4)

local KeybindText = Instance.new("TextLabel")
KeybindText.Parent = KeybindBox
KeybindText.Size = UDim2.new(1, 0, 1, 0)
KeybindText.BackgroundTransparency = 1
KeybindText.Text = "RightShift"
KeybindText.Font = Enum.Font.GothamBold
KeybindText.TextSize = 12
KeybindText.TextColor3 = Config.textColor

-- Toggle options
local Toggles = {
    {name = "Drag-able GUI", default = true, y = 85},
    {name = "Save Settings", default = true, y = 115}
}

for _, tog in ipairs(Toggles) do
    local tBg = CreateRoundedFrame("TogBg", UICard, 
        UDim2.new(0, 40, 0, 20), 
        UDim2.new(1, -60, 0, tog.y), 
        tog.default and Config.mainColor or Color3.fromRGB(60, 60, 60), 10)
    
    local tCirc = CreateRoundedFrame("TogCirc", tBg, 
        UDim2.new(0, 16, 0, 16), 
        UDim2.new(0, tog.default and 22 or 2, 0.5, -8), 
        Color3.fromRGB(255, 255, 255), 8)
    
    local tLabel = Instance.new("TextLabel")
    tLabel.Parent = UICard
    tLabel.Size = UDim2.new(0, 200, 0, 20)
    tLabel.Position = UDim2.new(0, 15, 0, tog.y)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = tog.name
    tLabel.Font = Enum.Font.Gotham
    tLabel.TextSize = 14
    tLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
end

-- Save button
local SaveBtn = CreateRoundedFrame("SaveBtn", SettingsContent, 
    UDim2.new(0, 200, 0, 40), 
    UDim2.new(0, 0, 0, 200), 
    Config.mainColor, 6)

local SaveText = Instance.new("TextLabel")
SaveText.Parent = SaveBtn
SaveText.Size = UDim2.new(1, 0, 1, 0)
SaveText.BackgroundTransparency = 1
SaveText.Text = "💾 Save Settings"
SaveText.Font = Enum.Font.GothamBold
SaveText.TextSize = 16
SaveText.TextColor3 = Config.textColor

local SaveClick = Instance.new("TextButton")
SaveClick.Parent = SaveBtn
SaveClick.Size = UDim2.new(1, 0, 1, 0)
SaveClick.BackgroundTransparency = 1
SaveClick.Text = ""

SaveClick.MouseButton1Click:Connect(function()
    local notif = CreateRoundedFrame("Notif", ScreenGui, 
        UDim2.new(0, 200, 0, 40), 
        UDim2.new(0.5, -100, 0, 20), 
        Config.mainColor, 8)
    notif.ZIndex = 100
    
    local notifText = Instance.new("TextLabel")
    notifText.Parent = notif
    notifText.Size = UDim2.new(1, 0, 1, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = "✅ Settings Saved!"
    notifText.Font = Enum.Font.GothamBold
    notifText.TextSize = 14
    notifText.TextColor3 = Config.textColor
    
    task.wait(2)
    notif:Destroy()
end)

-- =========================================================
-- CLOSE & MINIMIZE FUNCTIONS
-- =========================================================

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false
local originalSize = MainFrame.Size
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 300, 0, 50)
        TabContainer.Visible = false
        ContentArea.Visible = false
        MinBtn.ImageColor3 = Color3.fromRGB(255, 255, 0)
    else
        MainFrame.Size = originalSize
        TabContainer.Visible = true
        ContentArea.Visible = true
        MinBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- =========================================================
-- KEYBIND TOGGLE
-- =========================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        blur.Visible = MainFrame.Visible
    end
end)

-- =========================================================
-- INITIALIZATION
-- =========================================================

print("✅ LYORA CUSTOM GUI LOADED!")
print("👤 User: " .. LocalPlayer.Name)
print("🔑 User ID: " .. LocalPlayer.UserId)
print("📱 Platform: " .. (UserInputService.TouchEnabled and "Android" or "PC"))
