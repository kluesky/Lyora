-- =========================================================
-- LYORA SAMBUNG KATA - CUSTOM GUI + WHITELIST + AUTO FARM
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
-- WHITELIST SYSTEM
-- =========================
local WHITELIST_URL = "https://pastefy.app/EvFSBcDy/raw"
local DISCORD_INVITE = "cvaHe2rXnk"

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
Subtitle.Text = "Whitelist System • Premium"
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

-- PROFILE CARD
local ProfileCard = Instance.new("Frame")
ProfileCard.Parent = ContentFrame
ProfileCard.Size = UDim2.new(1, 0, 0, 90)
ProfileCard.Position = UDim2.new(0, 0, 0, 0)
ProfileCard.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
ProfileCard.BorderSizePixel = 0

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 10)
ProfileCorner.Parent = ProfileCard

-- Avatar
local AvatarBorder = Instance.new("Frame")
AvatarBorder.Parent = ProfileCard
AvatarBorder.Size = UDim2.new(0, 70, 0, 70)
AvatarBorder.Position = UDim2.new(0, 10, 0.5, -35)
AvatarBorder.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
AvatarBorder.BorderSizePixel = 0

local AvatarBorderCorner = Instance.new("UICorner")
AvatarBorderCorner.CornerRadius = UDim.new(0, 35)
AvatarBorderCorner.Parent = AvatarBorder

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

-- STATUS SECTION
local StatusCard = Instance.new("Frame")
StatusCard.Parent = ContentFrame
StatusCard.Size = UDim2.new(1, 0, 0, 60)
StatusCard.Position = UDim2.new(0, 0, 0, 100)
StatusCard.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
StatusCard.BorderSizePixel = 0

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = StatusCard

local StatusIcon = Instance.new("Frame")
StatusIcon.Parent = StatusCard
StatusIcon.Size = UDim2.new(0, 12, 0, 12)
StatusIcon.Position = UDim2.new(0, 20, 0.5, -6)
StatusIcon.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
StatusIcon.BorderSizePixel = 0

local StatusIconCorner = Instance.new("UICorner")
StatusIconCorner.CornerRadius = UDim.new(1, 0)
StatusIconCorner.Parent = StatusIcon

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

-- VERIFY BUTTON
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

-- INFO CARD
local InfoCard = Instance.new("Frame")
InfoCard.Parent = ContentFrame
InfoCard.Size = UDim2.new(1, 0, 0, 100)
InfoCard.Position = UDim2.new(0, 0, 0, 240)
InfoCard.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
InfoCard.BorderSizePixel = 0

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 10)
InfoCorner.Parent = InfoCard

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

local InfoContent = Instance.new("TextLabel")
InfoContent.Parent = InfoCard
InfoContent.Size = UDim2.new(1, -20, 0, 50)
InfoContent.Position = UDim2.new(0, 10, 0, 40)
InfoContent.BackgroundTransparency = 1
InfoContent.Text = "• Whitelist berlaku 7 jam\n• Auto detect username\n• Dapatkan whitelist di Discord"
InfoContent.Font = Enum.Font.Gotham
InfoContent.TextSize = 13
InfoContent.TextColor3 = Color3.fromRGB(220, 220, 220)
InfoContent.TextXAlignment = Enum.TextXAlignment.Left
InfoContent.TextYAlignment = Enum.TextYAlignment.Top

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

-- NOTIFICATION FUNCTION
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

-- VERIFY FUNCTION
VerifyBtn.MouseButton1Click:Connect(function()
    VerifyBtn:TweenSize(UDim2.new(1, -10, 0, 55), "Out", "Quad", 0.1, true)
    task.wait(0.1)
    VerifyBtn:TweenSize(UDim2.new(1, 0, 0, 60), "Out", "Quad", 0.1, true)
    
    StatusIcon.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    StatusText.Text = "⏳ Memverifikasi whitelist..."
    
    local result = checkWhitelist()
    
    if result.valid then
        userData.isWhitelisted = true
        userData.discordUser = result.discordUser
        userData.whitelistExpiry = result.expiresAt
        
        StatusIcon.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        StatusText.Text = "✅ " .. result.message
        showNotification("✅ Verifikasi berhasil!", true)
        
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        VerifyBtn.Text = "✓ VERIFIED"
        task.wait(0.5)
        
        ScreenGui:Destroy()
        createMainGUI()
        
    else
        StatusIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        StatusText.Text = "❌ " .. result.message
        showNotification(result.message, false)
        
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        task.wait(0.5)
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    end
end)

DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/" .. DISCORD_INVITE)
    showNotification("🔗 Link Discord dicopy ke clipboard!", true)
end)

-- =========================
-- LOAD WORDLIST
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
-- REMOTES
-- =========================
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local MatchUI = remotes:WaitForChild("MatchUI")
local SubmitWord = remotes:WaitForChild("SubmitWord")
local BillboardUpdate = remotes:WaitForChild("BillboardUpdate")
local BillboardEnd = remotes:WaitForChild("BillboardEnd")
local TypeSound = remotes:WaitForChild("TypeSound")
local UsedWordWarn = remotes:WaitForChild("UsedWordWarn")

-- =========================
-- STATE
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
-- LOGIC FUNCTIONS
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
-- AUTO ENGINE
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
-- CREATE MAIN GUI (CUSTOM)
-- =========================
function createMainGUI()
    -- Bersihkan ScreenGui
    for _, child in ipairs(ScreenGui:GetChildren()) do
        child:Destroy()
    end
    
    -- Ganti title
    Title.Text = "🎮 LYORA AUTO FARM"
    
    -- Recreate content untuk main GUI
    local MainContent = Instance.new("Frame")
    MainContent.Parent = ContentFrame
    MainContent.Size = UDim2.new(1, 0, 1, 0)
    MainContent.BackgroundTransparency = 1
    
    -- =========================
    -- TAB BUTTONS
    -- =========================
    local TabFrame = Instance.new("Frame")
    TabFrame.Parent = MainContent
    TabFrame.Size = UDim2.new(1, 0, 0, 40)
    TabFrame.Position = UDim2.new(0, 0, 0, 0)
    TabFrame.BackgroundTransparency = 1
    
    local tabs = {"🏠 MAIN", "⚙️ AUTO", "📊 INFO", "⚡ MISC"}
    local tabButtons = {}
    local tabContents = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Parent = TabFrame
        btn.Size = UDim2.new(0.25, -2, 1, 0)
        btn.Position = UDim2.new(0.25 * (i-1), 1, 0, 0)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(40, 42, 50)
        btn.Text = tabName
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BorderSizePixel = 0
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            for _, b in ipairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
            end
            btn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
            
            for _, content in pairs(tabContents) do
                content.Visible = false
            end
            if tabContents[tabName] then
                tabContents[tabName].Visible = true
            end
        end)
        
        table.insert(tabButtons, btn)
    end
    
    -- =========================
    -- TAB CONTENT FRAMES
    -- =========================
    local ContentArea = Instance.new("Frame")
    ContentArea.Parent = MainContent
    ContentArea.Size = UDim2.new(1, 0, 1, -50)
    ContentArea.Position = UDim2.new(0, 0, 0, 45)
    ContentArea.BackgroundTransparency = 1
    
    -- =========================
    -- MAIN TAB
    -- =========================
    local MainTab = Instance.new("Frame")
    MainTab.Parent = ContentArea
    MainTab.Size = UDim2.new(1, 0, 1, 0)
    MainTab.BackgroundTransparency = 1
    MainTab.Visible = true
    tabContents["🏠 MAIN"] = MainTab
    
    -- Status Card
    local StatusCard2 = Instance.new("Frame")
    StatusCard2.Parent = MainTab
    StatusCard2.Size = UDim2.new(1, 0, 0, 80)
    StatusCard2.Position = UDim2.new(0, 0, 0, 10)
    StatusCard2.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    StatusCard2.BorderSizePixel = 0
    
    local StatusCardCorner = Instance.new("UICorner")
    StatusCardCorner.CornerRadius = UDim.new(0, 8)
    StatusCardCorner.Parent = StatusCard2
    
    local MatchStatus = Instance.new("TextLabel")
    MatchStatus.Parent = StatusCard2
    MatchStatus.Size = UDim2.new(0.5, -10, 0, 25)
    MatchStatus.Position = UDim2.new(0, 10, 0, 10)
    MatchStatus.BackgroundTransparency = 1
    MatchStatus.Text = "🔴 Match: Waiting"
    MatchStatus.Font = Enum.Font.GothamBold
    MatchStatus.TextSize = 14
    MatchStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    MatchStatus.TextXAlignment = Enum.TextXAlignment.Left
    
    local TurnStatus = Instance.new("TextLabel")
    TurnStatus.Parent = StatusCard2
    TurnStatus.Size = UDim2.new(0.5, -10, 0, 25)
    TurnStatus.Position = UDim2.new(0.5, 0, 0, 10)
    TurnStatus.BackgroundTransparency = 1
    TurnStatus.Text = "⏳ Turn: -"
    TurnStatus.Font = Enum.Font.GothamBold
    TurnStatus.TextSize = 14
    TurnStatus.TextColor3 = Color3.fromRGB(255, 255, 0)
    TurnStatus.TextXAlignment = Enum.TextXAlignment.Left
    
    local CurrentWord = Instance.new("TextLabel")
    CurrentWord.Parent = StatusCard2
    CurrentWord.Size = UDim2.new(0.5, -10, 0, 25)
    CurrentWord.Position = UDim2.new(0, 10, 0, 40)
    CurrentWord.BackgroundTransparency = 1
    CurrentWord.Text = "📝 Word: -"
    CurrentWord.Font = Enum.Font.Gotham
    CurrentWord.TextSize = 13
    CurrentWord.TextColor3 = Color3.fromRGB(180, 180, 180)
    CurrentWord.TextXAlignment = Enum.TextXAlignment.Left
    
    local UsedCount = Instance.new("TextLabel")
    UsedCount.Parent = StatusCard2
    UsedCount.Size = UDim2.new(0.5, -10, 0, 25)
    UsedCount.Position = UDim2.new(0.5, 0, 0, 40)
    UsedCount.BackgroundTransparency = 1
    UsedCount.Text = "📋 Used: 0"
    UsedCount.Font = Enum.Font.Gotham
    UsedCount.TextSize = 13
    UsedCount.TextColor3 = Color3.fromRGB(180, 180, 180)
    UsedCount.TextXAlignment = Enum.TextXAlignment.Left
    
    -- User Info Card
    local UserCard = Instance.new("Frame")
    UserCard.Parent = MainTab
    UserCard.Size = UDim2.new(1, 0, 0, 60)
    UserCard.Position = UDim2.new(0, 0, 0, 100)
    UserCard.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    UserCard.BorderSizePixel = 0
    
    local UserCardCorner = Instance.new("UICorner")
    UserCardCorner.CornerRadius = UDim.new(0, 8)
    UserCardCorner.Parent = UserCard
    
    local DiscordLabel = Instance.new("TextLabel")
    DiscordLabel.Parent = UserCard
    DiscordLabel.Size = UDim2.new(1, -20, 0, 20)
    DiscordLabel.Position = UDim2.new(0, 10, 0, 10)
    DiscordLabel.BackgroundTransparency = 1
    DiscordLabel.Text = "💬 Discord: " .. userData.discordUser
    DiscordLabel.Font = Enum.Font.Gotham
    DiscordLabel.TextSize = 13
    DiscordLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ExpiryLabel = Instance.new("TextLabel")
    ExpiryLabel.Parent = UserCard
    ExpiryLabel.Size = UDim2.new(1, -20, 0, 20)
    ExpiryLabel.Position = UDim2.new(0, 10, 0, 35)
    ExpiryLabel.BackgroundTransparency = 1
    ExpiryLabel.Text = "⏰ Whitelist expires: " .. os.date("%H:%M", userData.whitelistExpiry/1000)
    ExpiryLabel.Font = Enum.Font.Gotham
    ExpiryLabel.TextSize = 13
    ExpiryLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    ExpiryLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- =========================
    -- AUTO TAB
    -- =========================
    local AutoTab = Instance.new("Frame")
    AutoTab.Parent = ContentArea
    AutoTab.Size = UDim2.new(1, 0, 1, 0)
    AutoTab.BackgroundTransparency = 1
    AutoTab.Visible = false
    tabContents["⚙️ AUTO"] = AutoTab
    
    -- Auto Toggle
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = AutoTab
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.Position = UDim2.new(0, 0, 0, 10)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    ToggleFrame.BorderSizePixel = 0
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.Size = UDim2.new(0, 200, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = "🤖 Auto Farm"
    ToggleLabel.Font = Enum.Font.GothamBold
    ToggleLabel.TextSize = 16
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Parent = ToggleFrame
    ToggleBg.Size = UDim2.new(0, 50, 0, 25)
    ToggleBg.Position = UDim2.new(1, -60, 0.5, -12.5)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleBg.BorderSizePixel = 0
    
    local ToggleBgCorner = Instance.new("UICorner")
    ToggleBgCorner.CornerRadius = UDim.new(0, 12)
    ToggleBgCorner.Parent = ToggleBg
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Parent = ToggleBg
    ToggleCircle.Size = UDim2.new(0, 21, 0, 21)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -10.5)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    
    local ToggleCircleCorner = Instance.new("UICorner")
    ToggleCircleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCircleCorner.Parent = ToggleCircle
    
    local ToggleState = false
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ToggleBg
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    
    ToggleBtn.MouseButton1Click:Connect(function()
        ToggleState = not ToggleState
        if ToggleState then
            ToggleBg.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
            ToggleCircle:TweenPosition(UDim2.new(0, 27, 0.5, -10.5), "Out", "Quad", 0.2)
            autoEnabled = true
            startUltraAI()
        else
            ToggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            ToggleCircle:TweenPosition(UDim2.new(0, 2, 0.5, -10.5), "Out", "Quad", 0.2)
            autoEnabled = false
        end
    end)
    
    -- Sliders
    local function createSlider(parent, name, min, max, default, posY, callback)
        local label = Instance.new("TextLabel")
        label.Parent = parent
        label.Size = UDim2.new(0, 100, 0, 20)
        label.Position = UDim2.new(0, 10, 0, posY)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. default
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextColor3 = Color3.fromRGB(180, 180, 180)
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Parent = parent
        sliderBg.Size = UDim2.new(0, 200, 0, 8)
        sliderBg.Position = UDim2.new(0, 120, 0, posY + 6)
        sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        sliderBg.BorderSizePixel = 0
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 4)
        sliderCorner.Parent = sliderBg
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Parent = sliderBg
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
        sliderFill.BorderSizePixel = 0
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 4)
        fillCorner.Parent = sliderFill
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Parent = parent
        valueLabel.Size = UDim2.new(0, 40, 0, 20)
        valueLabel.Position = UDim2.new(0, 330, 0, posY)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = default
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 13
        valueLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local dragging = false
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        
        sliderBg.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = sliderBg.AbsolutePosition
                local sliderSize = sliderBg.AbsoluteSize
                
                local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize.X)
                local percent = relativeX / sliderSize.X
                local value = math.floor(min + (percent * (max - min)))
                
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                valueLabel.Text = tostring(value)
                label.Text = name .. ": " .. value
                callback(value)
            end
        end)
    end
    
    createSlider(AutoTab, "Aggression", 0, 100, config.aggression, 70, function(v)
        config.aggression = v
    end)
    
    createSlider(AutoTab, "Min Delay", 50, 500, config.minDelay, 110, function(v)
        config.minDelay = v
    end)
    
    createSlider(AutoTab, "Max Delay", 200, 1500, config.maxDelay, 150, function(v)
        config.maxDelay = v
    end)
    
    createSlider(AutoTab, "Min Length", 1, 3, config.minLength, 190, function(v)
        config.minLength = v
    end)
    
    createSlider(AutoTab, "Max Length", 5, 20, config.maxLength, 230, function(v)
        config.maxLength = v
    end)
    
    -- =========================
    -- INFO TAB
    -- =========================
    local InfoTab = Instance.new("Frame")
    InfoTab.Parent = ContentArea
    InfoTab.Size = UDim2.new(1, 0, 1, 0)
    InfoTab.BackgroundTransparency = 1
    InfoTab.Visible = false
    tabContents["📊 INFO"] = InfoTab
    
    local InfoCard2 = Instance.new("Frame")
    InfoCard2.Parent = InfoTab
    InfoCard2.Size = UDim2.new(1, 0, 0, 150)
    InfoCard2.Position = UDim2.new(0, 0, 0, 10)
    InfoCard2.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    InfoCard2.BorderSizePixel = 0
    
    local InfoCardCorner = Instance.new("UICorner")
    InfoCardCorner.CornerRadius = UDim.new(0, 8)
    InfoCardCorner.Parent = InfoCard2
    
    local InfoText = Instance.new("TextLabel")
    InfoText.Parent = InfoCard2
    InfoText.Size = UDim2.new(1, -20, 1, -20)
    InfoText.Position = UDim2.new(0, 10, 0, 10)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "Lyora Sambung Kata\n\nVersion: 3.0\nAuthor: sazaraaax\nStatus: ✅ Whitelisted\n\nFitur:\n• Auto Farm dengan AI\n• Whitelist System (7 Jam)\n• Anti Ban Protection\n• Real-time Status"
    InfoText.Font = Enum.Font.Gotham
    InfoText.TextSize = 13
    InfoText.TextColor3 = Color3.fromRGB(220, 220, 220)
    InfoText.TextXAlignment = Enum.TextXAlignment.Left
    InfoText.TextYAlignment = Enum.TextYAlignment.Top
    
    -- =========================
    -- MISC TAB
    -- =========================
    local MiscTab = Instance.new("Frame")
    MiscTab.Parent = ContentArea
    MiscTab.Size = UDim2.new(1, 0, 1, 0)
    MiscTab.BackgroundTransparency = 1
    MiscTab.Visible = false
    tabContents["⚡ MISC"] = MiscTab
    
    local MiscCard = Instance.new("Frame")
    MiscCard.Parent = MiscTab
    MiscCard.Size = UDim2.new(1, 0, 0, 100)
    MiscCard.Position = UDim2.new(0, 0, 0, 10)
    MiscCard.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    MiscCard.BorderSizePixel = 0
    
    local MiscCorner = Instance.new("UICorner")
    MiscCorner.CornerRadius = UDim.new(0, 8)
    MiscCorner.Parent = MiscCard
    
    local MiscText = Instance.new("TextLabel")
    MiscText.Parent = MiscCard
    MiscText.Size = UDim2.new(1, -20, 1, -20)
    MiscText.Position = UDim2.new(0, 10, 0, 10)
    MiscText.BackgroundTransparency = 1
    MiscText.Text = "Used Words List:\n" .. (next(usedWordsList) and table.concat(usedWordsList, ", ") or "Belum ada kata terpakai")
    MiscText.Font = Enum.Font.Gotham
    MiscText.TextSize = 13
    MiscText.TextColor3 = Color3.fromRGB(220, 220, 220)
    MiscText.TextXAlignment = Enum.TextXAlignment.Left
    MiscText.TextYAlignment = Enum.TextYAlignment.Top
    
    local ResetBtn = Instance.new("TextButton")
    ResetBtn.Parent = MiscTab
    ResetBtn.Size = UDim2.new(1, 0, 0, 40)
    ResetBtn.Position = UDim2.new(0, 0, 0, 120)
    ResetBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    ResetBtn.Text = "🗑️ Reset Used Words"
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.TextSize = 14
    ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetBtn.BorderSizePixel = 0
    
    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 6)
    ResetCorner.Parent = ResetBtn
    
    ResetBtn.MouseButton1Click:Connect(function()
        resetUsedWords()
        MiscText.Text = "Used Words List:\n" .. (next(usedWordsList) and table.concat(usedWordsList, ", ") or "Belum ada kata terpakai")
        showNotification("✅ Used words direset!", true)
    end)
    
    -- =========================
    -- REMOTE EVENT HANDLERS
    -- =========================
    MatchUI.OnClientEvent:Connect(function(cmd, value)
        if cmd == "ShowMatchUI" then
            matchActive = true
            isMyTurn = false
            resetUsedWords()
            MatchStatus.Text = "🟢 Match: Active"
            MatchStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
        elseif cmd == "HideMatchUI" then
            matchActive = false
            isMyTurn = false
            serverLetter = ""
            resetUsedWords()
            MatchStatus.Text = "🔴 Match: Waiting"
            MatchStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            TurnStatus.Text = "⏳ Turn: -"
            CurrentWord.Text = "📝 Word: -"
        elseif cmd == "StartTurn" then
            isMyTurn = true
            TurnStatus.Text = "🎯 Turn: Your Turn"
            TurnStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            if autoEnabled then
                startUltraAI()
            end
        elseif cmd == "EndTurn" then
            isMyTurn = false
            TurnStatus.Text = "⏳ Turn: Opponent"
            TurnStatus.TextColor3 = Color3.fromRGB(255, 255, 0)
        elseif cmd == "UpdateServerLetter" then
            serverLetter = value or ""
            CurrentWord.Text = "📝 Word: " .. serverLetter
        end
    end)
    
    BillboardUpdate.OnClientEvent:Connect(function(word)
        if matchActive and not isMyTurn then
            opponentStreamWord = word or ""
        end
    end)
    
    UsedWordWarn.OnClientEvent:Connect(function(word)
        if word then
            addUsedWord(word)
            if MiscText then
                MiscText.Text = "Used Words List:\n" .. (next(usedWordsList) and table.concat(usedWordsList, ", ") or "Belum ada kata terpakai")
            end
            if autoEnabled and matchActive and isMyTurn then
                humanDelay()
                startUltraAI()
            end
        end
    end)
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
print("📌 WHITELIST URL: " .. WHITELIST_URL)
print("👤 User: " .. LocalPlayer.Name)
print("🔑 User ID: " .. LocalPlayer.UserId)
print("📱 Platform: " .. (UserInputService.TouchEnabled and "Android" or "PC"))