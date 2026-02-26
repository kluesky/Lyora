-- =========================================================
-- LYORA VERIFICATION - CUSTOM GUI (SIMPLE)
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Config
local WHITELIST_URL = "https://pastefy.app/EvFSBcDy/raw"
local DISCORD_INVITE = "cvaHe2rXnk"
local CHEAT_SCRIPT_URL = "https://raw.githubusercontent.com/kluesky/Lyora/refs/heads/main/lyora.lua"  -- GANTI NANTI!

-- Data
local userData = {
    userId = tostring(LocalPlayer.UserId),
    username = LocalPlayer.Name,
    discordUser = "Unknown"
}

-- Fungsi cek whitelist
local function checkWhitelist()
    local success, res = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)
    if not success then return false, "Gagal konek" end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(res)
    end)
    if not success then return false, "Data error" end
    
    if not data or not data.whitelist then return false, "DB error" end
    
    local entry = data.whitelist[userData.userId]
    if not entry then return false, "Tidak terdaftar" end
    
    if os.time()*1000 > entry.expiresAt then return false, "Expired" end
    
    if entry.username ~= userData.username then return false, "Username salah" end
    
    return true, entry.discordTag or entry.discordName or "User"
end

-- Buat GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "LyoraVerify"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Parent = MainFrame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.8
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(255, 80, 140)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LYORA VERIFY"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Content
local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1

-- Avatar
local Avatar = Instance.new("ImageLabel")
Avatar.Parent = Content
Avatar.Size = UDim2.new(0, 60, 0, 60)
Avatar.Position = UDim2.new(0.5, -30, 0, 10)
Avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 30)
AvatarCorner.Parent = Avatar

-- Username
local Username = Instance.new("TextLabel")
Username.Parent = Content
Username.Size = UDim2.new(1, 0, 0, 25)
Username.Position = UDim2.new(0, 0, 0, 80)
Username.BackgroundTransparency = 1
Username.Text = LocalPlayer.Name
Username.Font = Enum.Font.GothamBold
Username.TextSize = 16
Username.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Status Box
local StatusBox = Instance.new("Frame")
StatusBox.Parent = Content
StatusBox.Size = UDim2.new(1, 0, 0, 40)
StatusBox.Position = UDim2.new(0, 0, 0, 115)
StatusBox.BackgroundColor3 = Color3.fromRGB(25, 27, 35)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusBox

local StatusText = Instance.new("TextLabel")
StatusText.Parent = StatusBox
StatusText.Size = UDim2.new(1, -10, 1, 0)
StatusText.Position = UDim2.new(0, 5, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "⚪ Ready to verify"
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 14
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)

-- Verify Button
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Parent = Content
VerifyBtn.Size = UDim2.new(1, 0, 0, 45)
VerifyBtn.Position = UDim2.new(0, 0, 0, 170)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 140)
VerifyBtn.Text = "VERIFY WHITELIST"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 14
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 8)
VerifyCorner.Parent = VerifyBtn

-- Discord Button
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Parent = Content
DiscordBtn.Size = UDim2.new(1, 0, 0, 40)
DiscordBtn.Position = UDim2.new(0, 0, 0, 225)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
DiscordBtn.Text = "🔗 JOIN DISCORD"
DiscordBtn.Font = Enum.Font.Gotham
DiscordBtn.TextSize = 13
DiscordBtn.TextColor3 = Color3.fromRGB(200, 200, 255)

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 8)
DiscordCorner.Parent = DiscordBtn

-- Info
local InfoText = Instance.new("TextLabel")
InfoText.Parent = Content
InfoText.Size = UDim2.new(1, 0, 0, 30)
InfoText.Position = UDim2.new(0, 0, 0, 275)
InfoText.BackgroundTransparency = 1
InfoText.Text = "whitelist 7 jam • /whitelist"
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 11
InfoText.TextColor3 = Color3.fromRGB(140, 140, 140)

-- Notif function
local function notif(msg, good)
    local n = Instance.new("Frame")
    n.Parent = ScreenGui
    n.Size = UDim2.new(0, 250, 0, 35)
    n.Position = UDim2.new(0.5, -125, 0, 10)
    n.BackgroundColor3 = good and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(180, 0, 0)
    n.ZIndex = 10
    
    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 8)
    nCorner.Parent = n
    
    local nText = Instance.new("TextLabel")
    nText.Parent = n
    nText.Size = UDim2.new(1, -10, 1, 0)
    nText.Position = UDim2.new(0, 5, 0, 0)
    nText.BackgroundTransparency = 1
    nText.Text = msg
    nText.Font = Enum.Font.GothamBold
    nText.TextSize = 13
    nText.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    task.wait(2)
    n:Destroy()
end

-- Verify button click
VerifyBtn.MouseButton1Click:Connect(function()
    StatusText.Text = "⏳ Verifying..."
    VerifyBtn.Text = "..."
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    
    local valid, res = checkWhitelist()
    
    if valid then
        userData.discordUser = res
        StatusText.Text = "✅ Verified!"
        VerifyBtn.Text = "✓ DONE"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
        notif("✅ Whitelist verified!", true)
        
        -- Simpan data
        _G.LyoraUserData = userData
        
        -- Load cheat script
        task.wait(1)
        ScreenGui:Destroy()
        
        local cheat = game:HttpGet(CHEAT_SCRIPT_URL)
        if cheat then
            loadstring(cheat)()
        end
    else
        StatusText.Text = "❌ " .. res
        VerifyBtn.Text = "VERIFY WHITELIST"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 140)
        notif("❌ " .. res, false)
    end
end)

-- Discord button
DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/" .. DISCORD_INVITE)
    notif("🔗 Link Discord dicopy!", true)
end)

-- Keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("✅ LYORA VERIFY LOADED")