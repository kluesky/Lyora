-- =========================================================
-- ULTRA SMART AUTO KATA + CUSTOM GUI + PASTEFY WHITELIST
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================
-- WHITELIST SYSTEM (PAKAI RAW URL)
-- =========================
local WHITELIST_URL = "https://pastefy.app/EvFSBcDy/raw"  -- URL RAW yang bener
local DISCORD_INVITE = "cvaHe2rXnk"  -- invite Discord lu

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
-- CREATE GUI
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "LyoraGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Shadow Modern
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

-- HEADER GRADIENT
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
Header.BorderSizePixel = 0

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
Title.Text = "LYORA SAMBUNG KATA"
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
Subtitle.Text = "Whitelist System • Auto Verify"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 12
Subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextTransparency = 0.3

-- Close Button
local CloseBtn = Instance.new("ImageButton")
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Image = "rbxassetid://6031094678"
CloseBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinBtn = Instance.new("ImageButton")
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -90, 0.5, -17.5)
MinBtn.BackgroundTransparency = 1
MinBtn.Image = "rbxassetid://6031094678"
MinBtn.ImageRectOffset = Vector2.new(30, 0)
MinBtn.ImageRectSize = Vector2.new(30, 30)

-- CONTENT FRAME
local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -40, 1, -100)
ContentFrame.Position = UDim2.new(0, 20, 0, 85)
ContentFrame.BackgroundTransparency = 1

-- MINIMIZE FUNCTION
local minimized = false
local originalSize = MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 450, 0, 70), "Out", "Quad", 0.2, true)
        ContentFrame.Visible = false
        MinBtn.ImageRectOffset = Vector2.new(0, 0)
    else
        MainFrame:TweenSize(originalSize, "Out", "Quad", 0.2, true)
        task.wait(0.2)
        ContentFrame.Visible = true
        MinBtn.ImageRectOffset = Vector2.new(30, 0)
    end
end)

-- =========================
-- PROFILE CARD
-- =========================
local ProfileCard = Instance.new("Frame")
ProfileCard.Parent = ContentFrame
ProfileCard.Size = UDim2.new(1, 0, 0, 90)
ProfileCard.Position = UDim2.new(0, 0, 0, 0)
ProfileCard.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
ProfileCard.BorderSizePixel = 0

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 10)
ProfileCorner.Parent = ProfileCard

-- Avatar dengan border
local AvatarBorder = Instance.new("Frame")
AvatarBorder.Parent = ProfileCard
AvatarBorder.Size = UDim2.new(0, 70, 0, 70)
AvatarBorder.Position = UDim2.new(0, 10, 0.5, -35)
AvatarBorder.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
AvatarBorder.BorderSizePixel = 0

local AvatarBorderCorner = Instance.new("UICorner")
AvatarBorderCorner.CornerRadius = UDim.new(0, 35)
AvatarBorderCorner.Parent = AvatarBorder

-- Avatar Image
local Avatar = Instance.new("ImageLabel")
Avatar.Parent = AvatarBorder
Avatar.Size = UDim2.new(1, -4, 1, -4)
Avatar.Position = UDim2.new(0, 2, 0, 2)
Avatar.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 33)
AvatarCorner.Parent = Avatar

-- Username
local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Parent = ProfileCard
UsernameLabel.Size = UDim2.new(0, 250, 0, 30)
UsernameLabel.Position = UDim2.new(0, 90, 0, 20)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = LocalPlayer.Name
UsernameLabel.Font = Enum.Font.GothamBold
UsernameLabel.TextSize = 20
UsernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Display Name
local DisplayNameLabel = Instance.new("TextLabel")
DisplayNameLabel.Parent = ProfileCard
DisplayNameLabel.Size = UDim2.new(0, 250, 0, 20)
DisplayNameLabel.Position = UDim2.new(0, 90, 0, 50)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text = LocalPlayer.DisplayName
DisplayNameLabel.Font = Enum.Font.Gotham
DisplayNameLabel.TextSize = 14
DisplayNameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- User ID
local UserIdLabel = Instance.new("TextLabel")
UserIdLabel.Parent = ProfileCard
UserIdLabel.Size = UDim2.new(0, 250, 0, 16)
UserIdLabel.Position = UDim2.new(0, 90, 0, 70)
UserIdLabel.BackgroundTransparency = 1
UserIdLabel.Text = "ID: " .. LocalPlayer.UserId
UserIdLabel.Font = Enum.Font.Gotham
UserIdLabel.TextSize = 12
UserIdLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
UserIdLabel.TextXAlignment = Enum.TextXAlignment.Left

-- =========================
-- STATUS SECTION
-- =========================
local StatusCard = Instance.new("Frame")
StatusCard.Parent = ContentFrame
StatusCard.Size = UDim2.new(1, 0, 0, 60)
StatusCard.Position = UDim2.new(0, 0, 0, 100)
StatusCard.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
StatusCard.BorderSizePixel = 0

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = StatusCard

-- Status Icon
local StatusIcon = Instance.new("Frame")
StatusIcon.Parent = StatusCard
StatusIcon.Size = UDim2.new(0, 12, 0, 12)
StatusIcon.Position = UDim2.new(0, 20, 0.5, -6)
StatusIcon.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
StatusIcon.BorderSizePixel = 0

local StatusIconCorner = Instance.new("UICorner")
StatusIconCorner.CornerRadius = UDim.new(1, 0)
StatusIconCorner.Parent = StatusIcon

-- Status Text
local StatusText = Instance.new("TextLabel")
StatusText.Parent = StatusCard
StatusText.Size = UDim2.new(1, -40, 1, 0)
StatusText.Position = UDim2.new(0, 40, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Menunggu verifikasi..."
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 14
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.TextXAlignment = Enum.TextXAlignment.Left

-- =========================
-- VERIFY BUTTON
-- =========================
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Parent = ContentFrame
VerifyBtn.Size = UDim2.new(1, 0, 0, 60)
VerifyBtn.Position = UDim2.new(0, 0, 0, 170)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
VerifyBtn.Text = "VERIFIKASI WHITELIST"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 18
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.BorderSizePixel = 0

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 10)
VerifyCorner.Parent = VerifyBtn

local VerifyGradient = Instance.new("UIGradient")
VerifyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 105, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 90, 160))
})
VerifyGradient.Rotation = 90
VerifyGradient.Parent = VerifyBtn

-- =========================
-- INFO CARD
-- =========================
local InfoCard = Instance.new("Frame")
InfoCard.Parent = ContentFrame
InfoCard.Size = UDim2.new(1, 0, 0, 100)
InfoCard.Position = UDim2.new(0, 0, 0, 240)
InfoCard.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
InfoCard.BorderSizePixel = 0

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 10)
InfoCorner.Parent = InfoCard

-- Info Title
local InfoTitle = Instance.new("TextLabel")
InfoTitle.Parent = InfoCard
InfoTitle.Size = UDim2.new(1, -20, 0, 30)
InfoTitle.Position = UDim2.new(0, 10, 0, 10)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "ℹ️ INFORMASI"
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.TextSize = 14
InfoTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Info Content
local InfoContent = Instance.new("TextLabel")
InfoContent.Parent = InfoCard
InfoContent.Size = UDim2.new(1, -20, 0, 50)
InfoContent.Position = UDim2.new(0, 10, 0, 40)
InfoContent.BackgroundTransparency = 1
InfoContent.Text = "• Whitelist berlaku 7 jam\n• Auto detect username Roblox\n• Dapatkan whitelist di Discord"
InfoContent.Font = Enum.Font.Gotham
InfoContent.TextSize = 13
InfoContent.TextColor3 = Color3.fromRGB(220, 220, 220)
InfoContent.TextXAlignment = Enum.TextXAlignment.Left
InfoContent.TextYAlignment = Enum.TextYAlignment.Top

-- Discord Button
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Parent = InfoCard
DiscordBtn.Size = UDim2.new(0, 140, 0, 35)
DiscordBtn.Position = UDim2.new(1, -150, 1, -45)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordBtn.Text = "🔗 Join Discord"
DiscordBtn.Font = Enum.Font.GothamBold
DiscordBtn.TextSize = 12
DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordBtn.BorderSizePixel = 0

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 6)
DiscordCorner.Parent = DiscordBtn

DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/" .. DISCORD_INVITE)
    showNotification("🔗 Link Discord dicopy ke clipboard!", true)
end)

-- =========================
-- NOTIFICATION FUNCTION
-- =========================
local function showNotification(message, isSuccess)
    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.Size = UDim2.new(0, 320, 0, 50)
    notif.Position = UDim2.new(0.5, -160, 0, 20)
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

-- =========================
-- VERIFY FUNCTION
-- =========================
VerifyBtn.MouseButton1Click:Connect(function()
    VerifyBtn:TweenSize(UDim2.new(1, -10, 0, 55), "Out", "Quad", 0.1, true)
    task.wait(0.1)
    VerifyBtn:TweenSize(UDim2.new(1, 0, 0, 60), "Out", "Quad", 0.1, true)
    
    StatusIcon.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    StatusText.Text = "⏳ Memverifikasi whitelist..."
    
    print("🔍 Verifying for user: " .. userData.username)
    print("📌 User ID: " .. userData.userId)
    
    local result = checkWhitelist()
    
    if result.valid then
        userData.isWhitelisted = true
        userData.discordUser = result.discordUser
        userData.whitelistExpiry = result.expiresAt
        
        StatusIcon.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        StatusText.Text = "✅ " .. result.message
        
        showNotification("✅ Verifikasi berhasil! Selamat datang " .. result.discordUser, true)
        
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        VerifyBtn.Text = "✓ VERIFIED"
        task.wait(0.5)
        
        ScreenGui:Destroy()
        startMainGUI()
        
    else
        StatusIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        StatusText.Text = "❌ " .. result.message
        showNotification(result.message, false)
        
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        task.wait(0.5)
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    end
end)

-- =========================
-- LOAD WORDLIST (LOGIC CHEAT - TIDAK BERUBAH)
-- =========================
local kataModule = {}

local function downloadWordlist()
    local response = game:HttpGet("https://raw.githubusercontent.com/danzzy1we/roblox-script-dump/refs/heads/main/WordListDump/Dump_IndonesianWords.lua")
    if not response then
        return false
    end

    local content = string.match(response, "return%s*(.+)")
    if not content then
        return false
    end

    content = string.gsub(content, "^%s*{", "")
    content = string.gsub(content, "}%s*$", "")

    for word in string.gmatch(content, '"([^"]+)"') do
        local w = string.lower(word)
        if string.len(w) > 1 then
            table.insert(kataModule, w)
        end
    end

    return true
end

local wordOk = downloadWordlist()
if not wordOk or #kataModule == 0 then
    warn("Wordlist gagal dimuat!")
    return
end

print("Wordlist Loaded:", #kataModule)

-- =========================
-- REMOTES (LOGIC CHEAT - TIDAK BERUBAH)
-- =========================
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local MatchUI = remotes:WaitForChild("MatchUI")
local SubmitWord = remotes:WaitForChild("SubmitWord")
local BillboardUpdate = remotes:WaitForChild("BillboardUpdate")
local BillboardEnd = remotes:WaitForChild("BillboardEnd")
local TypeSound = remotes:WaitForChild("TypeSound")
local UsedWordWarn = remotes:WaitForChild("UsedWordWarn")

-- =========================
-- STATE (LOGIC CHEAT - TIDAK BERUBAH)
-- =========================
local matchActive = false
local isMyTurn = false
local serverLetter = ""

local usedWords = {}
local usedWordsList = {}
local opponentStreamWord = ""

local autoEnabled = false
local autoRunning = false

local config = {
    minDelay = 350,
    maxDelay = 650,
    aggression = 20,
    minLength = 2,
    maxLength = 12
}

-- =========================
-- LOGIC FUNCTIONS (LOGIC CHEAT - TIDAK BERUBAH)
-- =========================
local function isUsed(word)
    return usedWords[string.lower(word)] == true
end

local usedWordsDropdown = nil

local function addUsedWord(word)
    local w = string.lower(word)
    if usedWords[w] == nil then
        usedWords[w] = true
        table.insert(usedWordsList, word)
        if usedWordsDropdown ~= nil then
            usedWordsDropdown:Set(usedWordsList)
        end
    end
end

local function resetUsedWords()
    usedWords = {}
    usedWordsList = {}
    if usedWordsDropdown ~= nil then
        usedWordsDropdown:Set({})
    end
end

local function getSmartWords(prefix)
    local results = {}
    local lowerPrefix = string.lower(prefix)

    for i = 1, #kataModule do
        local word = kataModule[i]
        if string.sub(word, 1, #lowerPrefix) == lowerPrefix then
            if not isUsed(word) then
                local len = string.len(word)
                if len >= config.minLength and len <= config.maxLength then
                    table.insert(results, word)
                end
            end
        end
    end

    table.sort(results, function(a,b)
        return string.len(a) > string.len(b)
    end)

    return results
end

local function humanDelay()
    local min = config.minDelay
    local max = config.maxDelay
    if min > max then
        min = max
    end
    task.wait(math.random(min, max) / 1000)
end

-- =========================
-- AUTO ENGINE (LOGIC CHEAT - TIDAK BERUBAH)
-- =========================
local function startUltraAI()
    if autoRunning then return end
    if not autoEnabled then return end
    if not matchActive then return end
    if not isMyTurn then return end
    if serverLetter == "" then return end

    autoRunning = true

    humanDelay()

    local words = getSmartWords(serverLetter)
    if #words == 0 then
        autoRunning = false
        return
    end

    local selectedWord = words[1]

    if config.aggression < 100 then
        local topN = math.floor(#words * (1 - config.aggression/100))
        if topN < 1 then topN = 1 end
        if topN > #words then topN = #words end
        selectedWord = words[math.random(1, topN)]
    end

    local currentWord = serverLetter
    local remain = string.sub(selectedWord, #serverLetter + 1)

    for i = 1, string.len(remain) do
        if not matchActive or not isMyTurn then
            autoRunning = false
            return
        end

        currentWord = currentWord .. string.sub(remain, i, i)

        TypeSound:FireServer()
        BillboardUpdate:FireServer(currentWord)

        humanDelay()
    end

    humanDelay()

    SubmitWord:FireServer(selectedWord)
    addUsedWord(selectedWord)

    humanDelay()
    BillboardEnd:FireServer()

    autoRunning = false
end

-- =========================
-- MAIN GUI (SETELAH VERIFY)
-- =========================
function startMainGUI()
    print("✅ MAIN GUI AKTIF UNTUK: " .. userData.discordUser)
    showNotification("✅ Selamat datang " .. userData.discordUser .. "!", true)
    
    -- =========================
    -- UI (RAYFIELD) - TIDAK BERUBAH
    -- =========================
    local Window = Rayfield:CreateWindow({
        Name = "Sambung-kata | " .. userData.discordUser,
        LoadingTitle = "Loading Gui...",
        LoadingSubtitle = "automate by sazaraaax",
        ConfigurationSaving = {Enabled = false}
    })

    local MainTab = Window:CreateTab("Main")
    
    MainTab:CreateParagraph({
        Title = "👤 Account Info",
        Content = "User: " .. userData.discordUser .. "\nStatus: ✅ Whitelisted"
    })

    MainTab:CreateToggle({
        Name = "Aktifkan Auto",
        CurrentValue = false,
        Callback = function(Value)
            autoEnabled = Value
            if Value then
                startUltraAI()
            end
        end
    })

    MainTab:CreateSlider({
        Name = "Aggression",
        Range = {0,100},
        Increment = 5,
        CurrentValue = config.aggression,
        Callback = function(Value)
            config.aggression = Value
        end
    })
    
    MainTab:CreateSlider({
        Name = "Min Delay (ms)",
        Range = {10, 500},
        Increment = 5,
        CurrentValue = config.minDelay,
        Callback = function(Value)
            config.minDelay = Value
        end
    })

    MainTab:CreateSlider({
        Name = "Max Delay (ms)",
        Range = {100, 1000},
        Increment = 5,
        CurrentValue = config.maxDelay,
        Callback = function(Value)
            config.maxDelay = Value
        end
    })
    
    MainTab:CreateSlider({
        Name = "Min Word Length",
        Range = {1, 2},
        Increment = 1,
        CurrentValue = config.minLength,
        Callback = function(Value)
            config.minLength = Value
        end
    })

    MainTab:CreateSlider({
        Name = "Max Word Length",
        Range = {5, 20},
        Increment = 1,
        CurrentValue = config.maxLength,
        Callback = function(Value)
            config.maxLength = Value
        end
    })

    usedWordsDropdown = MainTab:CreateDropdown({
        Name = "Used Words",
        Options = usedWordsList,
        CurrentOption = "",
        Callback = function() end
    })

    local opponentParagraph = MainTab:CreateParagraph({
        Title = "Status Opponent",
        Content = "Menunggu..."
    })

    local startLetterParagraph = MainTab:CreateParagraph({
        Title = "Kata Start",
        Content = "-"
    })

    -- Update functions
    local function updateOpponentStatus()
        local content = ""
        if matchActive then
            if isMyTurn then
                content = "Giliran Anda"
            else
                if opponentStreamWord ~= nil and opponentStreamWord ~= "" then
                    content = "Opponent mengetik: " .. tostring(opponentStreamWord)
                else
                    content = "Giliran Opponent"
                end
            end
        else
            content = "Match tidak aktif"
        end
        opponentParagraph:Set(content)
    end

    local function updateStartLetter()
        local content = serverLetter ~= "" and "Kata Start: " .. serverLetter or "Kata Start: -"
        startLetterParagraph:Set(content)
    end

    -- About Tab
    local AboutTab = Window:CreateTab("About")
    
    AboutTab:CreateParagraph({
        Title = "Informasi Script",
        Content = "Auto Kata\nVersi: 3.0 (Whitelist)\nby sazaraaax\nDiscord: " .. userData.discordUser
    })
    
    AboutTab:CreateParagraph({
        Title = "Cara Penggunaan",
        Content = "1. Dapatkan whitelist di Discord\n2. Verifikasi otomatis\n3. Aktifkan Auto\n4. Menang terus!"
    })

    -- Remote events
    MatchUI.OnClientEvent:Connect(function(cmd, value)
        if cmd == "ShowMatchUI" then
            matchActive = true
            isMyTurn = false
            resetUsedWords()
        elseif cmd == "HideMatchUI" then
            matchActive = false
            isMyTurn = false
            serverLetter = ""
            resetUsedWords()
        elseif cmd == "StartTurn" then
            isMyTurn = true
            updateOpponentStatus()
            if autoEnabled then
                startUltraAI()
            end
        elseif cmd == "EndTurn" then
            isMyTurn = false
            updateOpponentStatus()
        elseif cmd == "UpdateServerLetter" then
            serverLetter = value or ""
            updateStartLetter()
        end
    end)

    BillboardUpdate.OnClientEvent:Connect(function(word)
        if matchActive and not isMyTurn then
            opponentStreamWord = word or ""
            updateOpponentStatus()
        end
    end)

    UsedWordWarn.OnClientEvent:Connect(function(word)
        if word then
            addUsedWord(word)
            if autoEnabled and matchActive and isMyTurn then
                humanDelay()
                startUltraAI()
            end
        end
    end)

    print("✅ MAIN GUI LOADED FOR: " .. userData.discordUser)
end

-- =========================
-- KEYBIND TOGGLE
-- =========================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- =========================
-- INIT
-- =========================
print("✅ LYORA WHITELIST SYSTEM LOADED")
print("👤 User: " .. LocalPlayer.Name)
print("🔑 User ID: " .. LocalPlayer.UserId)
print("📱 Platform: " .. (UserInputService.TouchEnabled and "Android" or "PC"))