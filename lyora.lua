-- =========================================================
-- LYORA SIMPLE GUI + DISCORD KEY SYSTEM (FIX MINIMIZE)
-- =========================================================

-- 1. SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 2. KONFIGURASI BOT DISCORD (GANTI INI!)
local DISCORD_CONFIG = {
    apiUrl = "http://localhost:3000",  -- GANTI dengan URL bot lu
    botToken = "",  -- Token bot
    inviteCode = "YOUR_INVITE_CODE"  -- GANTI dengan invite code Discord lu
}

-- 3. DATA USER
local userData = {
    userId = LocalPlayer.UserId,
    username = LocalPlayer.Name,
    displayName = LocalPlayer.DisplayName,
    key = "",
    isVerified = false,
    discordUser = "",
    role = "user",
    premium = false
}

-- =========================================================
-- FUNGSI API KE BOT DISCORD
-- =========================================================

local function callDiscordAPI(endpoint, data)
    local success, response = pcall(function()
        local headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bot " .. DISCORD_CONFIG.botToken
        }
        
        local body = HttpService:JSONEncode(data)
        
        return HttpService:PostAsync(
            DISCORD_CONFIG.apiUrl .. endpoint,
            body,
            Enum.HttpContentType.ApplicationJson,
            false,
            headers
        )
    end)
    
    if success then
        return true, HttpService:JSONDecode(response)
    end
    return false, {message = "Gagal konek ke server"}
end

local function verifyKey(key)
    return callDiscordAPI("/verify-key", {
        userId = tostring(userData.userId),
        username = userData.username,
        key = key
    })
end

-- =========================================================
-- MEMBUAT GUI (PASTI MUNCUL!)
-- =========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "LyoraGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true  -- PENTING: biar pas minimize isinya keclip

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Parent = MainFrame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ZIndex = -1

-- HEADER
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔐 LYORA KEY SYSTEM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -90, 0.5, -17.5)
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 25
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BorderSizePixel = 0

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

-- =========================================================
-- CONTENT FRAME (SEMUA ISI DILETAKKAN DI SINI)
-- =========================================================

local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -20, 1, -70)
ContentFrame.Position = UDim2.new(0, 10, 0, 60)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- =========================================================
-- FUNGSI MINIMIZE (FIX!)
-- =========================================================

local minimized = false
local originalSize = MainFrame.Size
local originalContentVisible = true

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    
    if minimized then
        -- Minimize: kecilin frame, sembunyiin content
        MainFrame:TweenSize(UDim2.new(0, 450, 0, 50), "Out", "Quad", 0.2, true)
        ContentFrame.Visible = false
        MinBtn.Text = "□"
        MinBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    else
        -- Maximize: balikin ukuran, munculin content
        MainFrame:TweenSize(originalSize, "Out", "Quad", 0.2, true)
        task.wait(0.2)  -- Tunggu animasi selesai
        ContentFrame.Visible = true
        MinBtn.Text = "—"
        MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
end)

-- =========================================================
-- AVATAR SECTION (SESUAI SCREENSHOT)
-- =========================================================

local AvatarFrame = Instance.new("Frame")
AvatarFrame.Parent = ContentFrame
AvatarFrame.Size = UDim2.new(1, -20, 0, 80)
AvatarFrame.Position = UDim2.new(0, 10, 0, 10)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
AvatarFrame.BorderSizePixel = 0

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 8)
AvatarCorner.Parent = AvatarFrame

-- Avatar Image
local Avatar = Instance.new("ImageLabel")
Avatar.Parent = AvatarFrame
Avatar.Size = UDim2.new(0, 60, 0, 60)
Avatar.Position = UDim2.new(0, 10, 0.5, -30)
Avatar.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"

local AvatarImgCorner = Instance.new("UICorner")
AvatarImgCorner.CornerRadius = UDim.new(0, 30)
AvatarImgCorner.Parent = Avatar

-- Username (di screenshot: ITZ_Kyluesky)
local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Parent = AvatarFrame
UsernameLabel.Size = UDim2.new(0, 250, 0, 30)
UsernameLabel.Position = UDim2.new(0, 80, 0, 15)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = LocalPlayer.Name
UsernameLabel.Font = Enum.Font.GothamBold
UsernameLabel.TextSize = 20
UsernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- User ID (di screenshot: ID: 1345368053)
local UserIdLabel = Instance.new("TextLabel")
UserIdLabel.Parent = AvatarFrame
UserIdLabel.Size = UDim2.new(0, 250, 0, 20)
UserIdLabel.Position = UDim2.new(0, 80, 0, 45)
UserIdLabel.BackgroundTransparency = 1
UserIdLabel.Text = "ID: " .. LocalPlayer.UserId
UserIdLabel.Font = Enum.Font.Gotham
UserIdLabel.TextSize = 14
UserIdLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
UserIdLabel.TextXAlignment = Enum.TextXAlignment.Left

-- =========================================================
-- KEY INPUT SECTION (SESUAI SCREENSHOT)
-- =========================================================

local KeyFrame = Instance.new("Frame")
KeyFrame.Parent = ContentFrame
KeyFrame.Size = UDim2.new(1, -20, 0, 180)
KeyFrame.Position = UDim2.new(0, 10, 0, 100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
KeyFrame.BorderSizePixel = 0

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 8)
KeyCorner.Parent = KeyFrame

-- Key Title (di screenshot: VERIFIKASI KEY)
local KeyTitle = Instance.new("TextLabel")
KeyTitle.Parent = KeyFrame
KeyTitle.Size = UDim2.new(1, -20, 0, 30)
KeyTitle.Position = UDim2.new(0, 10, 0, 10)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "🔑 VERIFIKASI KEY"
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 16
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Key Description
local KeyDesc = Instance.new("TextLabel")
KeyDesc.Parent = KeyFrame
KeyDesc.Size = UDim2.new(1, -20, 0, 40)
KeyDesc.Position = UDim2.new(0, 10, 0, 40)
KeyDesc.BackgroundTransparency = 1
KeyDesc.Text = "Masukkan key yang didapat dari Discord bot\nuntuk mengaktifkan script"
KeyDesc.Font = Enum.Font.Gotham
KeyDesc.TextSize = 12
KeyDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
KeyDesc.TextXAlignment = Enum.TextXAlignment.Left
KeyDesc.TextYAlignment = Enum.TextYAlignment.Top

-- Key Input Box
local KeyInputFrame = Instance.new("Frame")
KeyInputFrame.Parent = KeyFrame
KeyInputFrame.Size = UDim2.new(1, -20, 0, 40)
KeyInputFrame.Position = UDim2.new(0, 10, 0, 85)
KeyInputFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
KeyInputFrame.BorderSizePixel = 0

local KeyInputCorner = Instance.new("UICorner")
KeyInputCorner.CornerRadius = UDim.new(0, 6)
KeyInputCorner.Parent = KeyInputFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Parent = KeyInputFrame
KeyInput.Size = UDim2.new(1, -10, 1, 0)
KeyInput.Position = UDim2.new(0, 5, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.PlaceholderText = "Contoh: LYORA-XXXX-XXXX"
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.ClearTextOnFocus = false

-- Verify Button (di screenshot: VERIFIKASI KEY)
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Parent = KeyFrame
VerifyBtn.Size = UDim2.new(1, -20, 0, 45)
VerifyBtn.Position = UDim2.new(0, 10, 0, 135)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
VerifyBtn.Text = "VERIFIKASI KEY"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 16
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.BorderSizePixel = 0

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 6)
VerifyCorner.Parent = VerifyBtn

-- =========================================================
-- DISCORD INFO SECTION (SESUAI SCREENSHOT)
-- =========================================================

local DiscordFrame = Instance.new("Frame")
DiscordFrame.Parent = ContentFrame
DiscordFrame.Size = UDim2.new(1, -20, 0, 140)
DiscordFrame.Position = UDim2.new(0, 10, 0, 290)
DiscordFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
DiscordFrame.BorderSizePixel = 0

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 8)
DiscordCorner.Parent = DiscordFrame

-- Discord Title
local DiscordTitle = Instance.new("TextLabel")
DiscordTitle.Parent = DiscordFrame
DiscordTitle.Size = UDim2.new(1, -20, 0, 30)
DiscordTitle.Position = UDim2.new(0, 10, 0, 10)
DiscordTitle.BackgroundTransparency = 1
DiscordTitle.Text = "💬 BELUM PUNYA KEY?"
DiscordTitle.Font = Enum.Font.GothamBold
DiscordTitle.TextSize = 16
DiscordTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Instructions
local Instructions = Instance.new("TextLabel")
Instructions.Parent = DiscordFrame
Instructions.Size = UDim2.new(1, -20, 0, 50)
Instructions.Position = UDim2.new(0, 10, 0, 40)
Instructions.BackgroundTransparency = 1
Instructions.Text = "1. Join Discord server\n2. Ketik /getkey " .. LocalPlayer.UserId .. "\n3. Copy key dari bot"
Instructions.Font = Enum.Font.Gotham
Instructions.TextSize = 12
Instructions.TextColor3 = Color3.fromRGB(180, 180, 180)
Instructions.TextXAlignment = Enum.TextXAlignment.Left
Instructions.TextYAlignment = Enum.TextYAlignment.Top

-- Buttons
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Parent = DiscordFrame
ButtonFrame.Size = UDim2.new(1, -20, 0, 35)
ButtonFrame.Position = UDim2.new(0, 10, 0, 95)
ButtonFrame.BackgroundTransparency = 1

-- Copy ID Button
local CopyIdBtn = Instance.new("TextButton")
CopyIdBtn.Parent = ButtonFrame
CopyIdBtn.Size = UDim2.new(0, 120, 1, 0)
CopyIdBtn.Position = UDim2.new(0, 0, 0, 0)
CopyIdBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
CopyIdBtn.Text = "📋 Copy ID"
CopyIdBtn.Font = Enum.Font.GothamBold
CopyIdBtn.TextSize = 12
CopyIdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyIdBtn.BorderSizePixel = 0

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyIdBtn

-- Join Discord Button
local JoinBtn = Instance.new("TextButton")
JoinBtn.Parent = ButtonFrame
JoinBtn.Size = UDim2.new(0, 130, 1, 0)
JoinBtn.Position = UDim2.new(0, 130, 0, 0)
JoinBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)  -- Discord color
JoinBtn.Text = "🔗 Join Discord"
JoinBtn.Font = Enum.Font.GothamBold
JoinBtn.TextSize = 12
JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinBtn.BorderSizePixel = 0

local JoinCorner = Instance.new("UICorner")
JoinCorner.CornerRadius = UDim.new(0, 6)
JoinCorner.Parent = JoinBtn

-- STATUS LABEL
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = ContentFrame
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 440)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
StatusLabel.Text = "⏳ Menunggu input key..."
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

-- =========================================================
-- FUNGSI NOTIFIKASI
-- =========================================================

local function showNotification(message, isSuccess)
    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.5, -150, 0, 10)
    notif.BackgroundColor3 = isSuccess and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 70, 70)
    notif.BorderSizePixel = 0
    notif.ZIndex = 100

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notif

    local notifText = Instance.new("TextLabel")
    notifText.Parent = notif
    notifText.Size = UDim2.new(1, -20, 1, 0)
    notifText.Position = UDim2.new(0, 10, 0, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = message
    notifText.Font = Enum.Font.GothamBold
    notifText.TextSize = 14
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextWrapped = true

    task.wait(3)
    notif:Destroy()
end

-- =========================================================
-- FUNGSI VERIFIKASI
-- =========================================================

VerifyBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    if key == "" then
        showNotification("❌ Masukkan key terlebih dahulu!", false)
        return
    end
    
    StatusLabel.Text = "⏳ Memverifikasi key..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local success, result = verifyKey(key)
    
    if success and result.valid then
        userData.isVerified = true
        userData.key = key
        userData.discordUser = result.discordUser
        userData.role = result.role
        userData.premium = result.premium
        
        StatusLabel.Text = "✅ VERIFIKASI BERHASIL! Selamat datang " .. userData.discordUser
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        showNotification("✅ Verifikasi berhasil! Mengaktifkan fitur...", true)
        
        -- GANTI TAMPILAN JADI MAIN MENU
        loadMainMenu()
        
    else
        StatusLabel.Text = "❌ Key tidak valid! Coba lagi."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
        showNotification("❌ Key salah! Dapatkan key di Discord", false)
    end
end)

-- =========================================================
-- BUTTON FUNCTIONS
-- =========================================================

CopyIdBtn.MouseButton1Click:Connect(function()
    setclipboard(tostring(LocalPlayer.UserId))
    showNotification("✅ User ID dicopy ke clipboard!", true)
end)

JoinBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/" .. DISCORD_CONFIG.inviteCode)
    showNotification("🔗 Link Discord dicopy ke clipboard!", true)
end)

-- =========================================================
-- LOAD MAIN MENU (SETELAH VERIFIKASI)
-- =========================================================

function loadMainMenu()
    -- Bersihkan content frame
    for _, child in ipairs(ContentFrame:GetChildren()) do
        child:Destroy()
    end
    
    -- Ganti title
    Title.Text = "🎀 LYORA SAMBUNG KATA"
    
    -- Profile Section
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Parent = ContentFrame
    ProfileFrame.Size = UDim2.new(1, -20, 0, 70)
    ProfileFrame.Position = UDim2.new(0, 10, 0, 10)
    ProfileFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    ProfileFrame.BorderSizePixel = 0
    
    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 8)
    ProfileCorner.Parent = ProfileFrame
    
    local AvatarSmall = Instance.new("ImageLabel")
    AvatarSmall.Parent = ProfileFrame
    AvatarSmall.Size = UDim2.new(0, 50, 0, 50)
    AvatarSmall.Position = UDim2.new(0, 10, 0.5, -25)
    AvatarSmall.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
    AvatarSmall.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
    
    local AvatarSmallCorner = Instance.new("UICorner")
    AvatarSmallCorner.CornerRadius = UDim.new(0, 25)
    AvatarSmallCorner.Parent = AvatarSmall
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Parent = ProfileFrame
    NameLabel.Size = UDim2.new(0, 200, 0, 25)
    NameLabel.Position = UDim2.new(0, 70, 0, 15)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = LocalPlayer.Name
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 18
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local RoleLabel = Instance.new("TextLabel")
    RoleLabel.Parent = ProfileFrame
    RoleLabel.Size = UDim2.new(0, 200, 0, 20)
    RoleLabel.Position = UDim2.new(0, 70, 0, 40)
    RoleLabel.BackgroundTransparency = 1
    RoleLabel.Text = userData.premium and "✨ Premium Member" or "👤 Free Member"
    RoleLabel.Font = Enum.Font.Gotham
    RoleLabel.TextSize = 12
    RoleLabel.TextColor3 = userData.premium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(180, 180, 180)
    RoleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Stats Grid
    local StatsFrame = Instance.new("Frame")
    StatsFrame.Parent = ContentFrame
    StatsFrame.Size = UDim2.new(1, -20, 0, 80)
    StatsFrame.Position = UDim2.new(0, 10, 0, 90)
    StatsFrame.BackgroundTransparency = 1
    
    local stats = {
        {label = "Games", value = "0", icon = "🎮"},
        {label = "Streak", value = "0", icon = "🔥"},
        {label = "Words", value = "0", icon = "📝"},
        {label = "Acc", value = "0%", icon = "🎯"}
    }
    
    for i, stat in ipairs(stats) do
        local card = Instance.new("Frame")
        card.Parent = StatsFrame
        card.Size = UDim2.new(0, 100, 1, 0)
        card.Position = UDim2.new(0, (i-1) * 105, 0, 0)
        card.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
        card.BorderSizePixel = 0
        
        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 6)
        cardCorner.Parent = card
        
        local icon = Instance.new("TextLabel")
        icon.Parent = card
        icon.Size = UDim2.new(1, 0, 0, 25)
        icon.Position = UDim2.new(0, 0, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Text = stat.icon .. " " .. stat.value
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 16
        icon.TextColor3 = Color3.fromRGB(255, 105, 180)
        
        local label = Instance.new("TextLabel")
        label.Parent = card
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, 45)
        label.BackgroundTransparency = 1
        label.Text = stat.label
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
    
    -- Auto Farm Section
    local AutoFrame = Instance.new("Frame")
    AutoFrame.Parent = ContentFrame
    AutoFrame.Size = UDim2.new(1, -20, 0, 100)
    AutoFrame.Position = UDim2.new(0, 10, 0, 180)
    AutoFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    AutoFrame.BorderSizePixel = 0
    
    local AutoCorner = Instance.new("UICorner")
    AutoCorner.CornerRadius = UDim.new(0, 8)
    AutoCorner.Parent = AutoFrame
    
    local AutoTitle = Instance.new("TextLabel")
    AutoTitle.Parent = AutoFrame
    AutoTitle.Size = UDim2.new(1, -20, 0, 30)
    AutoTitle.Position = UDim2.new(0, 10, 0, 10)
    AutoTitle.BackgroundTransparency = 1
    AutoTitle.Text = "⚡ AUTO FARM"
    AutoTitle.Font = Enum.Font.GothamBold
    AutoTitle.TextSize = 16
    AutoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Toggle
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Parent = AutoFrame
    ToggleBg.Size = UDim2.new(0, 50, 0, 25)
    ToggleBg.Position = UDim2.new(1, -60, 0, 10)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleBg.BorderSizePixel = 0
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleBg
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Parent = ToggleBg
    ToggleCircle.Size = UDim2.new(0, 21, 0, 21)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -10.5)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    
    local ToggleCircleCorner = Instance.new("UICorner")
    ToggleCircleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCircleCorner.Parent = ToggleCircle
    
    local toggleState = false
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ToggleBg
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    
    ToggleBtn.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        if toggleState then
            ToggleBg.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
            ToggleCircle:TweenPosition(UDim2.new(0, 27, 0.5, -10.5), "Out", "Quad", 0.2)
        else
            ToggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            ToggleCircle:TweenPosition(UDim2.new(0, 2, 0.5, -10.5), "Out", "Quad", 0.2)
        end
    end)
    
    -- Delay Slider
    local DelayLabel = Instance.new("TextLabel")
    DelayLabel.Parent = AutoFrame
    DelayLabel.Size = UDim2.new(0, 100, 0, 20)
    DelayLabel.Position = UDim2.new(0, 10, 0, 50)
    DelayLabel.BackgroundTransparency = 1
    DelayLabel.Text = "Delay: 350ms"
    DelayLabel.Font = Enum.Font.Gotham
    DelayLabel.TextSize = 12
    DelayLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Discord Info
    local DiscordInfo = Instance.new("TextLabel")
    DiscordInfo.Parent = AutoFrame
    DiscordInfo.Size = UDim2.new(1, -20, 0, 20)
    DiscordInfo.Position = UDim2.new(0, 10, 0, 75)
    DiscordInfo.BackgroundTransparency = 1
    DiscordInfo.Text = "💬 Discord: " .. userData.discordUser .. " | Role: " .. userData.role
    DiscordInfo.Font = Enum.Font.Gotham
    DiscordInfo.TextSize = 11
    DiscordInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
    DiscordInfo.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Version
    local Version = Instance.new("TextLabel")
    Version.Parent = ContentFrame
    Version.Size = UDim2.new(1, -20, 0, 30)
    Version.Position = UDim2.new(0, 10, 0, 290)
    Version.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    Version.Text = "Lyora Sambung Kata v3.0 • Premium: " .. (userData.premium and "✅" or "❌")
    Version.Font = Enum.Font.Gotham
    Version.TextSize = 11
    Version.TextColor3 = Color3.fromRGB(150, 150, 150)
    
    local VersionCorner = Instance.new("UICorner")
    VersionCorner.CornerRadius = UDim.new(0, 6)
    VersionCorner.Parent = Version
end

-- =========================================================
-- KEYBIND TOGGLE (RightShift)
-- =========================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- =========================================================
-- INIT
-- =========================================================

print("✅ LYORA GUI + KEY SYSTEM LOADED")
print("👤 User: " .. LocalPlayer.Name)
print("🔑 User ID: " .. LocalPlayer.UserId)
print("📱 Platform: " .. (UserInputService.TouchEnabled and "Android" or "PC"))