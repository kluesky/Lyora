-- =========================================================
-- LYORA VERIFICATION - MINI EDITION (AUTO EXECUTE GAGO)
-- =========================================================

-- Tunggu game load
repeat wait() until game:IsLoaded()

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Config
local WHITELIST_URL = "https://pastefy.app/EvFSBcDy/raw"
local DISCORD_INVITE = "cvaHe2rXnk"
local GAGO_SCRIPT_URL = "https://raw.githubusercontent.com/kluesky/Lyora/refs/heads/main/gago.lua"

-- Data
local userData = {
    userId = tostring(LocalPlayer.UserId),
    username = LocalPlayer.Name
}

-- Fungsi cek whitelist
local function cekWhitelist()
    local sukses, res = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)
    if not sukses then return false, "Gagal konek" end
    
    local sukses, data = pcall(function()
        return HttpService:JSONDecode(res)
    end)
    if not sukses then return false, "Data error" end
    
    if not data or not data.whitelist then return false, "DB error" end
    
    local entry = data.whitelist[userData.userId]
    if not entry then return false, "Tidak terdaftar" end
    
    if os.time()*1000 > entry.expiresAt then return false, "Expired" end
    
    if entry.username ~= userData.username then return false, "Username salah" end
    
    return true, entry.discordTag or "User"
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = PlayerGui
gui.Name = "LyoraVerify"
gui.ResetOnSpawn = false

-- Frame utama
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 260, 0, 280)
frame.Position = UDim2.new(0.5, -130, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Header
local header = Instance.new("Frame")
header.Parent = frame
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(255, 80, 140)

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Parent = header
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "LYORA"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = "Left"

local close = Instance.new("TextButton")
close.Parent = header
close.Size = UDim2.new(0, 20, 0, 20)
close.Position = UDim2.new(1, -25, 0.5, -10)
close.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
close.Text = "✕"
close.Font = Enum.Font.GothamBold
close.TextSize = 12
close.TextColor3 = Color3.new(1, 1, 1)

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = close

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Content
local content = Instance.new("Frame")
content.Parent = frame
content.Size = UDim2.new(1, -20, 1, -40)
content.Position = UDim2.new(0, 10, 0, 35)
content.BackgroundTransparency = 1

-- Avatar
local avatar = Instance.new("ImageLabel")
avatar.Parent = content
avatar.Size = UDim2.new(0, 45, 0, 45)
avatar.Position = UDim2.new(0.5, -22.5, 0, 5)
avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(0, 23)
avatarCorner.Parent = avatar

-- Nama
local nameLabel = Instance.new("TextLabel")
nameLabel.Parent = content
nameLabel.Size = UDim2.new(1, 0, 0, 20)
nameLabel.Position = UDim2.new(0, 0, 0, 55)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = LocalPlayer.Name
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 12
nameLabel.TextColor3 = Color3.new(1, 1, 1)

-- Status box
local statusBox = Instance.new("Frame")
statusBox.Parent = content
statusBox.Size = UDim2.new(1, 0, 0, 28)
statusBox.Position = UDim2.new(0, 0, 0, 80)
statusBox.BackgroundColor3 = Color3.fromRGB(25, 25, 33)

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 5)
statusCorner.Parent = statusBox

local statusText = Instance.new("TextLabel")
statusText.Parent = statusBox
statusText.Size = UDim2.new(1, -10, 1, 0)
statusText.Position = UDim2.new(0, 5, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "⚪ Ready"
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 11
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)

-- Tombol verify
local verifyBtn = Instance.new("TextButton")
verifyBtn.Parent = content
verifyBtn.Size = UDim2.new(1, 0, 0, 32)
verifyBtn.Position = UDim2.new(0, 0, 0, 115)
verifyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 140)
verifyBtn.Text = "VERIFY"
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.TextSize = 12
verifyBtn.TextColor3 = Color3.new(1, 1, 1)

local verifyCorner = Instance.new("UICorner")
verifyCorner.CornerRadius = UDim.new(0, 5)
verifyCorner.Parent = verifyBtn

-- Tombol discord
local dcBtn = Instance.new("TextButton")
dcBtn.Parent = content
dcBtn.Size = UDim2.new(1, 0, 0, 28)
dcBtn.Position = UDim2.new(0, 0, 0, 155)
dcBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
dcBtn.Text = "🔗 Discord"
dcBtn.Font = Enum.Font.Gotham
dcBtn.TextSize = 11
dcBtn.TextColor3 = Color3.fromRGB(200, 200, 255)

local dcCorner = Instance.new("UICorner")
dcCorner.CornerRadius = UDim.new(0, 5)
dcCorner.Parent = dcBtn

-- Info
local infoText = Instance.new("TextLabel")
infoText.Parent = content
infoText.Size = UDim2.new(1, 0, 0, 20)
infoText.Position = UDim2.new(0, 0, 0, 190)
infoText.BackgroundTransparency = 1
infoText.Text = "whitelist 7 jam • /whitelist"
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 9
infoText.TextColor3 = Color3.fromRGB(120, 120, 120)

-- Notif
local function notif(teks, sukses)
    local n = Instance.new("Frame")
    n.Parent = gui
    n.Size = UDim2.new(0, 180, 0, 28)
    n.Position = UDim2.new(0.5, -90, 0, 10)
    n.BackgroundColor3 = sukses and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(180, 0, 0)
    n.ZIndex = 10
    
    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 5)
    nCorner.Parent = n
    
    local nText = Instance.new("TextLabel")
    nText.Parent = n
    nText.Size = UDim2.new(1, -10, 1, 0)
    nText.Position = UDim2.new(0, 5, 0, 0)
    nText.BackgroundTransparency = 1
    nText.Text = teks
    nText.Font = Enum.Font.GothamBold
    nText.TextSize = 11
    nText.TextColor3 = Color3.new(1, 1, 1)
    
    task.wait(2)
    n:Destroy()
end

-- =========================================================
-- VERIFY FUNCTION - AUTO EXECUTE GAGO SCRIPT
-- =========================================================
verifyBtn.MouseButton1Click:Connect(function()
    statusText.Text = "⏳ Verifying..."
    verifyBtn.Text = "..."
    verifyBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    
    local valid, res = cekWhitelist()
    
    if valid then
        userData.discordUser = res
        statusText.Text = "✅ Verified"
        verifyBtn.Text = "DONE"
        verifyBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
        notif("✅ Verified! Loading script...", true)
        
        -- 🔥 AUTO EXECUTE GAGO SCRIPT
        task.wait(0.5)
        gui:Destroy()
        
        local success, script = pcall(function()
            return game:HttpGet(GAGO_SCRIPT_URL)
        end)
        
        if success and script then
            loadstring(script)()
        else
            warn("❌ Gagal load script gago.lua")
        end
        
    else
        statusText.Text = "❌ " .. res
        verifyBtn.Text = "VERIFY"
        verifyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 140)
        notif("❌ " .. res, false)
    end
end)

-- Tombol discord
dcBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/" .. DISCORD_INVITE)
    notif("🔗 Link Discord dicopy!", true)
end)

-- Keybind toggle
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)

print("✅ Lyora Verify Mini - Auto Load gago.lua")
print("🔗 Script: " .. GAGO_SCRIPT_URL)