-- =========================================================
-- LYORA VERIFICATION SYSTEM
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================
-- WHITELIST CONFIG
-- =========================
local WHITELIST_URL = "https://pastefy.app/EvFSBcDy/raw"
local DISCORD_INVITE = "cvaHe2rXnk"
local CHEAT_SCRIPT_URL = "https://pastebin.com/raw/XXXXXXXX"  -- GANTI DENGAN URL RAW CHEAT LU!

local userData = {
    userId = tostring(LocalPlayer.UserId),
    username = LocalPlayer.Name,
    displayName = LocalPlayer.DisplayName,
    isWhitelisted = false,
    discordUser = "",
    whitelistExpiry = 0
}

-- =========================
-- FUNGSI CEK WHITELIST
-- =========================
local function checkWhitelist()
    print("📌 Reading from: " .. WHITELIST_URL)
    
    local success, response = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)
    
    if not success then
        return { valid = false, message = "❌ Gagal mengambil data whitelist" }
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if not success then
        return { valid = false, message = "❌ Gagal parse data" }
    end
    
    if not data or not data.whitelist then
        return { valid = false, message = "❌ Database whitelist rusak" }
    end
    
    local whitelistEntry = data.whitelist[userData.userId]
    
    if not whitelistEntry then
        return { valid = false, message = "❌ Kamu belum terdaftar dalam whitelist!" }
    end
    
    if os.time() * 1000 > whitelistEntry.expiresAt then
        return { valid = false, message = "⏰ Whitelist sudah expired! (7 jam)" }
    end
    
    if string.lower(whitelistEntry.username) ~= string.lower(userData.username) then
        return { valid = false, message = "❌ Username tidak cocok dengan database!" }
    end
    
    return {
        valid = true,
        discordUser = whitelistEntry.discordTag or whitelistEntry.discordName or "User",
        discordName = whitelistEntry.discordName,
        expiresAt = whitelistEntry.expiresAt,
        message = "✅ Selamat datang " .. (whitelistEntry.discordName or "User") .. "!"
    }
end

-- =========================
-- CREATE VERIFICATION GUI
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "LyoraVerify"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Parent = MainFrame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.8
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)

-- HEADER
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = Color3.fromRGB(255, 105, 180)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 105, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 80, 150))
})
HeaderGradient.Rotation = 90
HeaderGradient.Parent = Header

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "LYORA VERIFICATION"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Parent = Header
Subtitle.Size = UDim2.new(1, -20, 0, 20)
Subtitle.Position = UDim2.new(0, 10, 0, 45)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Whitelist System • 7 Jam"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 12
Subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
Subtitle.TextTransparency = 0.3
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

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

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- CONTENT FRAME
local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -20, 1, -90)
ContentFrame.Position = UDim2.new(0, 10, 0, 80)
ContentFrame.BackgroundTransparency = 1

-- PROFILE CARD
local ProfileCard = Instance.new("Frame")
ProfileCard.Parent = ContentFrame
ProfileCard.Size = UDim2.new(1, 0, 0, 80)
ProfileCard.BackgroundColor3 = Color3.fromRGB(30, 32, 40)

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 8)
ProfileCorner.Parent = ProfileCard

-- Avatar
local Avatar = Instance.new("ImageLabel")
Avatar.Parent = ProfileCard
Avatar.Size = UDim2.new(0, 60, 0, 60)
Avatar.Position = UDim2.new(0, 10, 0.5, -30)
Avatar.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 30)
AvatarCorner.Parent = Avatar

-- Username
local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Parent = ProfileCard
UsernameLabel.Size = UDim2.new(0, 250, 0, 25)
UsernameLabel.Position = UDim2.new(0, 80, 0, 15)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = LocalPlayer.Name
UsernameLabel.Font = Enum.Font.GothamBold
UsernameLabel.TextSize = 18
UsernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Display Name
local DisplayNameLabel = Instance.new("TextLabel")
DisplayNameLabel.Parent = ProfileCard
DisplayNameLabel.Size = UDim2.new(0, 250, 0, 20)
DisplayNameLabel.Position = UDim2.new(0, 80, 0, 40)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text = LocalPlayer.DisplayName
DisplayNameLabel.Font = Enum.Font.Gotham
DisplayNameLabel.TextSize = 12
DisplayNameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- User ID
local UserIdLabel = Instance.new("TextLabel")
UserIdLabel.Parent = ProfileCard
UserIdLabel.Size = UDim2.new(0, 250, 0, 20)
UserIdLabel.Position = UDim2.new(0, 80, 0, 60)
UserIdLabel.BackgroundTransparency = 1
UserIdLabel.Text = "ID: " .. LocalPlayer.UserId
UserIdLabel.Font = Enum.Font.Gotham
UserIdLabel.TextSize = 12
UserIdLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
UserIdLabel.TextXAlignment = Enum.TextXAlignment.Left

-- STATUS CARD
local StatusCard = Instance.new("Frame")
StatusCard.Parent = ContentFrame
StatusCard.Size = UDim2.new(1, 0, 0, 60)
StatusCard.Position = UDim2.new(0, 0, 0, 90)
StatusCard.BackgroundColor3 = Color3.fromRGB(30, 32, 40)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusCard

local StatusIcon = Instance.new("Frame")
StatusIcon.Parent = StatusCard
StatusIcon.Size = UDim2.new(0, 12, 0, 12)
StatusIcon.Position = UDim2.new(0, 15, 0.5, -6)
StatusIcon.BackgroundColor3 = Color3.fromRGB(255, 200, 0)

local StatusIconCorner = Instance.new("UICorner")
StatusIconCorner.CornerRadius = UDim.new(1, 0)
StatusIconCorner.Parent = StatusIcon

local StatusText = Instance.new("TextLabel")
StatusText.Parent = StatusCard
StatusText.Size = UDim2.new(1, -40, 1, 0)
StatusText.Position = UDim2.new(0, 35, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Menunggu verifikasi..."
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 14
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.TextXAlignment = Enum.TextXAlignment.Left

-- VERIFY BUTTON
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Parent = ContentFrame
VerifyBtn.Size = UDim2.new(1, 0, 0, 50)
VerifyBtn.Position = UDim2.new(0, 0, 0, 160)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
VerifyBtn.Text = "VERIFIKASI WHITELIST"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 16
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 8)
VerifyCorner.Parent = VerifyBtn

-- INFO CARD
local InfoCard = Instance.new("Frame")
InfoCard.Parent = ContentFrame
InfoCard.Size = UDim2.new(1, 0, 0, 100)
InfoCard.Position = UDim2.new(0, 0, 0, 220)
InfoCard.BackgroundColor3 = Color3.fromRGB(30, 32, 40)

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = InfoCard

local InfoText = Instance.new("TextLabel")
InfoText.Parent = InfoCard
InfoText.Size = UDim2.new(1, -20, 0, 50)
InfoText.Position = UDim2.new(0, 10, 0, 10)
InfoText.BackgroundTransparency = 1
InfoText.Text = "• Whitelist berlaku 7 jam\n• Dapatkan whitelist di Discord\n• Gunakan /whitelist di bot"
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 13
InfoText.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top

-- Discord Button
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Parent = InfoCard
DiscordBtn.Size = UDim2.new(0, 130, 0, 30)
DiscordBtn.Position = UDim2.new(1, -140, 1, -35)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordBtn.Text = "🔗 Join Discord"
DiscordBtn.Font = Enum.Font.GothamBold
DiscordBtn.TextSize = 12
DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 6)
DiscordCorner.Parent = DiscordBtn

-- =========================
-- NOTIFICATION FUNCTION
-- =========================
local function showNotification(message, isSuccess)
    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.5, -150, 0, 10)
    notif.BackgroundColor3 = isSuccess and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 70, 70)
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

    task.wait(3)
    notif:Destroy()
end

-- =========================
-- VERIFY FUNCTION
-- =========================
VerifyBtn.MouseButton1Click:Connect(function()
    StatusIcon.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    StatusText.Text = "⏳ Memverifikasi whitelist..."
    
    local result = checkWhitelist()
    
    if result.valid then
        userData.isWhitelisted = true
        userData.discordUser = result.discordUser
        userData.whitelistExpiry = result.expiresAt
        
        StatusIcon.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        StatusText.Text = "✅ " .. result.message
        showNotification("Verifikasi berhasil!", true)
        
        -- SIMPAN DATA USER SEMENTARA (pake shared table)
        _G.LyoraUserData = userData
        
        -- LOAD CHEAT SCRIPT
        task.wait(1)
        ScreenGui:Destroy()
        
        local cheatScript = game:HttpGet(CHEAT_SCRIPT_URL)
        if cheatScript then
            loadstring(cheatScript)()
        end
        
    else
        StatusIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        StatusText.Text = "❌ " .. result.message
        showNotification(result.message, false)
    end
end)

DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/" .. DISCORD_INVITE)
    showNotification("🔗 Link Discord dicopy ke clipboard!", true)
end)

-- =========================
-- KEYBIND TOGGLE
-- =========================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("✅ LYORA VERIFICATION SYSTEM LOADED")
print("👤 User: " .. LocalPlayer.Name)