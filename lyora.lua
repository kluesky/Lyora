-- =========================================================
-- LYORA VERIFICATION - MINIMALIS CUSTOM
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
-- CONFIG
-- =========================
local WHITELIST_URL = "https://pastefy.app/EvFSBcDy/raw"
local DISCORD_INVITE = "cvaHe2rXnk"
local CHEAT_SCRIPT_URL = "https://pastebin.com/raw/XXXXXXXX"  -- GANTI NANTI!

local userData = {
    userId = tostring(LocalPlayer.UserId),
    username = LocalPlayer.Name,
    isWhitelisted = false,
    discordUser = ""
}

-- =========================
-- FUNGSI CEK WHITELIST
-- =========================
local function checkWhitelist()
    local success, response = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)
    
    if not success then
        return { valid = false, msg = "Gagal ambil data" }
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if not success then
        return { valid = false, msg = "Data rusak" }
    end
    
    if not data or not data.whitelist then
        return { valid = false, msg = "Database error" }
    end
    
    local entry = data.whitelist[userData.userId]
    
    if not entry then
        return { valid = false, msg = "Tidak terdaftar" }
    end
    
    if os.time() * 1000 > entry.expiresAt then
        return { valid = false, msg = "Expired" }
    end
    
    if string.lower(entry.username) ~= string.lower(userData.username) then
        return { valid = false, msg = "Username salah" }
    end
    
    return {
        valid = true,
        discordUser = entry.discordTag or entry.discordName or "User",
        msg = "Selamat datang!"
    }
end

-- =========================
-- GUI MINI
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "LyoraVerify"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME (KECIL)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Header Mini
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(255, 90, 160)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LYORA"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- CONTENT
local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1

-- Avatar Mini
local Avatar = Instance.new("ImageLabel")
Avatar.Parent = Content
Avatar.Size = UDim2.new(0, 50, 0, 50)
Avatar.Position = UDim2.new(0.5, -25, 0, 5)
Avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 25)
AvatarCorner.Parent = Avatar

-- Username
local Username = Instance.new("TextLabel")
Username.Parent = Content
Username.Size = UDim2.new(1, 0, 0, 20)
Username.Position = UDim2.new(0, 0, 0, 65)
Username.BackgroundTransparency = 1
Username.Text = LocalPlayer.Name
Username.Font = Enum.Font.GothamBold
Username.TextSize = 14
Username.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Status Box
local StatusBox = Instance.new("Frame")
StatusBox.Parent = Content
StatusBox.Size = UDim2.new(1, 0, 0, 30)
StatusBox.Position = UDim2.new(0, 0, 0, 95)
StatusBox.BackgroundColor3 = Color3.fromRGB(25, 25, 33)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusBox

local StatusText = Instance.new("TextLabel")
StatusText.Parent = StatusBox
StatusText.Size = UDim2.new(1, -10, 1, 0)
StatusText.Position = UDim2.new(0, 5, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "⚪ Menunggu"
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 12
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)

-- Verify Button
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Parent = Content
VerifyBtn.Size = UDim2.new(1, 0, 0, 35)
VerifyBtn.Position = UDim2.new(0, 0, 0, 135)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 90, 160)
VerifyBtn.Text = "VERIFIKASI"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 13
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 6)
VerifyCorner.Parent = VerifyBtn

-- Discord Button
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Parent = Content
DiscordBtn.Size = UDim2.new(1, 0, 0, 30)
DiscordBtn.Position = UDim2.new(0, 0, 0, 180)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
DiscordBtn.Text = "🔗 Discord"
DiscordBtn.Font = Enum.Font.Gotham
DiscordBtn.TextSize = 12
DiscordBtn.TextColor3 = Color3.fromRGB(200, 200, 255)

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 6)
DiscordCorner.Parent = DiscordBtn

-- Info kecil
local Info = Instance.new("TextLabel")
Info.Parent = Content
Info.Size = UDim2.new(1, 0, 0, 40)
Info.Position = UDim2.new(0, 0, 0, 220)
Info.BackgroundTransparency = 1
Info.Text = "whitelist 7jam • /whitelist"
Info.Font = Enum.Font.Gotham
Info.TextSize = 10
Info.TextColor3 = Color3.fromRGB(140, 140, 140)

-- =========================
-- NOTIF SEDERHANA
-- =========================
local function notif(msg, good)
    local notifFrame = Instance.new("Frame")
    notifFrame.Parent = ScreenGui
    notifFrame.Size = UDim2.new(0, 200, 0, 30)
    notifFrame.Position = UDim2.new(0.5, -100, 0, 10)
    notifFrame.BackgroundColor3 = good and Color3.fromRGB(40, 180, 90) or Color3.fromRGB(200, 60, 60)
    notifFrame.ZIndex = 10

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 6)
    notifCorner.Parent = notifFrame

    local notifText = Instance.new("TextLabel")
    notifText.Parent = notifFrame
    notifText.Size = UDim2.new(1, -10, 1, 0)
    notifText.Position = UDim2.new(0, 5, 0, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = msg
    notifText.Font = Enum.Font.GothamBold
    notifText.TextSize = 12
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)

    task.wait(2)
    notifFrame:Destroy()
end

-- =========================
-- VERIFY
-- =========================
VerifyBtn.MouseButton1Click:Connect(function()
    StatusText.Text = "⏳ Verifying..."
    VerifyBtn.Text = "..."
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
    
    local result = checkWhitelist()
    
    if result.valid then
        userData.isWhitelisted = true
        userData.discordUser = result.discordUser
        
        StatusText.Text = "✅ Verified"
        StatusText.TextColor3 = Color3.fromRGB(100, 255, 120)
        VerifyBtn.Text = "✓ DONE"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
        
        notif("✅ " .. result.msg, true)
        
        -- Simpan & load cheat
        _G.LyoraUserData = userData
        
        task.wait(1)
        ScreenGui:Destroy()
        
        local cheat = game:HttpGet(CHEAT_SCRIPT_URL)
        if cheat then
            loadstring(cheat)()
        end
    else
        StatusText.Text = "❌ " .. result.msg
        StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        VerifyBtn.Text = "VERIFIKASI"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 90, 160)
        notif("❌ " .. result.msg, false)
    end
end)

-- Discord button
DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/" .. DISCORD_INVITE)
    notif("🔗 Link Discord dicopy", true)
end)

-- Keybind toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("✅ LYORA VERIF MINI LOADED")