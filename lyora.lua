-- =========================================================
-- LYORA SAMBUNG KATA - AXION UI + WHITELIST + AUTO FARM
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end

-- =========================
-- LOAD AXION UI LIBRARY
-- =========================
local AxionLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/adamowaissi22-boop/Axom-Scripts-/refs/heads/main/Axion%20Ui%20Library"))()

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
-- CREATE VERIFICATION GUI (MANUAL DULU)
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "LyoraGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME VERIF
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(255, 105, 180)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LYORA WHITELIST SYSTEM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
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

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -20, 1, -80)
ContentFrame.Position = UDim2.new(0, 10, 0, 70)
ContentFrame.BackgroundTransparency = 1

-- Profile Card
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

local UserIdLabel = Instance.new("TextLabel")
UserIdLabel.Parent = ProfileCard
UserIdLabel.Size = UDim2.new(0, 250, 0, 20)
UserIdLabel.Position = UDim2.new(0, 80, 0, 45)
UserIdLabel.BackgroundTransparency = 1
UserIdLabel.Text = "ID: " .. LocalPlayer.UserId
UserIdLabel.Font = Enum.Font.Gotham
UserIdLabel.TextSize = 12
UserIdLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
UserIdLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Status
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

-- Verify Button
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

-- Info Card
local InfoCard = Instance.new("Frame")
InfoCard.Parent = ContentFrame
InfoCard.Size = UDim2.new(1, 0, 0, 80)
InfoCard.Position = UDim2.new(0, 0, 0, 220)
InfoCard.BackgroundColor3 = Color3.fromRGB(30, 32, 40)

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = InfoCard

local InfoText = Instance.new("TextLabel")
InfoText.Parent = InfoCard
InfoText.Size = UDim2.new(1, -20, 1, -10)
InfoText.Position = UDim2.new(0, 10, 0, 5)
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
    notifText.TextWrapped = true

    task.wait(3)
    notif:Destroy()
end

-- VERIFY FUNCTION
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
        showNotification("✅ Verifikasi berhasil!", true)
        
        task.wait(1)
        ScreenGui:Destroy()
        createMainGUI()
        
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

local function addUsedWord(word)
    local w = string.lower(word)
    if usedWords[w] == nil then
        usedWords[w] = true
        table.insert(usedWordsList, word)
    end
end

local function resetUsedWords()
    usedWords = {}
    usedWordsList = {}
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
-- CREATE MAIN GUI (AXION UI)
-- =========================
function createMainGUI()
    -- Cleanup existing GUI
    for _, child in ipairs(ScreenGui:GetChildren()) do
        child:Destroy()
    end
    
    -- Create Axion Window
    local Window = AxionLibrary:CreateWindow({
        Name = "LYORA SAMBUNG KATA",
        Subtitle = "Premium Auto Farm System",
        Size = UDim2.new(0, 650, 0, 450),
        Position = UDim2.new(0.5, -325, 0.5, -225),
        Theme = "Default",
        Draggable = true,
        MinimizeEnabled = true
    })
    
    -- =========================
    -- HOME TAB
    -- =========================
    local HomeTab = Window:CreateTab("🏠 Home")
    
    -- Profile Section
    local ProfileSection = HomeTab:CreateSection("Profile")
    
    local ProfileCard = ProfileSection:AddElement("Frame", {
        Size = UDim2.new(1, -20, 0, 80),
        BackgroundColor = Color3.fromRGB(30, 35, 45),
        BorderRadius = 8
    })
    
    local AvatarImg = ProfileCard:AddElement("ImageLabel", {
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0, 10, 0.5, -30),
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420",
        BorderRadius = 30
    })
    
    ProfileCard:AddElement("TextLabel", {
        Size = UDim2.new(0, 200, 0, 25),
        Position = UDim2.new(0, 80, 0, 15),
        Text = LocalPlayer.Name,
        Font = "GothamBold",
        TextSize = 18,
        TextColor = Color3.fromRGB(255, 255, 255)
    })
    
    ProfileCard:AddElement("TextLabel", {
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 80, 0, 45),
        Text = "ID: " .. LocalPlayer.UserId,
        Font = "Gotham",
        TextSize = 12,
        TextColor = Color3.fromRGB(180, 180, 180)
    })
    
    -- Stats Section
    local StatsSection = HomeTab:CreateSection("Statistics")
    
    local stats = {
        {label = "Games", value = "0"},
        {label = "Streak", value = "0"},
        {label = "Words", value = "0"},
        {label = "Accuracy", value = "0%"}
    }
    
    for i, stat in ipairs(stats) do
        local card = StatsSection:AddElement("Frame", {
            Size = UDim2.new(0, 140, 0, 70),
            Position = UDim2.new(0, (i-1) * 150, 0, 0),
            BackgroundColor = Color3.fromRGB(25, 30, 40),
            BorderRadius = 6
        })
        
        card:AddElement("TextLabel", {
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0, 0, 0, 10),
            Text = stat.value,
            Font = "GothamBold",
            TextSize = 20,
            TextColor = Color3.fromRGB(255, 105, 180)
        })
        
        card:AddElement("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 40),
            Text = stat.label,
            Font = "Gotham",
            TextSize = 12,
            TextColor = Color3.fromRGB(150, 150, 150)
        })
    end
    
    -- Discord Info
    local DiscordSection = HomeTab:CreateSection("Discord")
    
    DiscordSection:AddParagraph({
        Title = "Connected Account",
        Content = "Discord: " .. userData.discordUser .. "\nExpires: " .. os.date("%H:%M %d/%m", userData.whitelistExpiry/1000)
    })
    
    -- =========================
    -- AUTO TAB
    -- =========================
    local AutoTab = Window:CreateTab("⚙️ Auto Farm")
    
    -- Status Panel
    local StatusPanel = AutoTab:CreateSection("Game Status")
    
    local MatchStatus = StatusPanel:AddElement("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 10),
        Text = "🔴 Match: Waiting",
        Font = "Gotham",
        TextSize = 14,
        TextColor = Color3.fromRGB(255, 100, 100)
    })
    
    local TurnStatus = StatusPanel:AddElement("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 40),
        Text = "⏳ Turn: -",
        Font = "Gotham",
        TextSize = 14,
        TextColor = Color3.fromRGB(255, 255, 0)
    })
    
    local CurrentWord = StatusPanel:AddElement("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 70),
        Text = "📝 Word: -",
        Font = "Gotham",
        TextSize = 14,
        TextColor = Color3.fromRGB(180, 180, 180)
    })
    
    -- Auto Settings
    local AutoSection = AutoTab:CreateSection("Auto Settings")
    
    AutoSection:AddToggle({
        Name = "Enable Auto Farm",
        Default = false,
        Callback = function(state)
            autoEnabled = state
            if state and matchActive and isMyTurn then
                startUltraAI()
            end
        end
    })
    
    AutoSection:AddSlider({
        Name = "Aggression",
        Min = 0,
        Max = 100,
        Default = config.aggression,
        Callback = function(val)
            config.aggression = val
        end
    })
    
    AutoSection:AddSlider({
        Name = "Min Delay (ms)",
        Min = 50,
        Max = 500,
        Default = config.minDelay,
        Callback = function(val)
            config.minDelay = val
        end
    })
    
    AutoSection:AddSlider({
        Name = "Max Delay (ms)",
        Min = 200,
        Max = 1500,
        Default = config.maxDelay,
        Callback = function(val)
            config.maxDelay = val
        end
    })
    
    AutoSection:AddSlider({
        Name = "Min Word Length",
        Min = 1,
        Max = 3,
        Default = config.minLength,
        Callback = function(val)
            config.minLength = val
        end
    })
    
    AutoSection:AddSlider({
        Name = "Max Word Length",
        Min = 5,
        Max = 20,
        Default = config.maxLength,
        Callback = function(val)
            config.maxLength = val
        end
    })
    
    -- =========================
    -- WORDS TAB
    -- =========================
    local WordsTab = Window:CreateTab("📋 Words")
    
    local UsedSection = WordsTab:CreateSection("Used Words")
    
    local UsedList = UsedSection:AddElement("TextLabel", {
        Size = UDim2.new(1, -20, 0, 100),
        BackgroundColor = Color3.fromRGB(20, 25, 35),
        Text = "No words used yet",
        Font = "Gotham",
        TextSize = 13,
        TextColor = Color3.fromRGB(180, 180, 180)
    })
    
    WordsTab:CreateButton({
        Name = "Reset Used Words",
        Callback = function()
            resetUsedWords()
            UsedList.Text = "No words used yet"
        end
    })
    
    -- =========================
    -- INFO TAB
    -- =========================
    local InfoTab = Window:CreateTab("ℹ️ Info")
    
    InfoTab:CreateParagraph({
        Title = "Script Information",
        Content = string.format(
            "Lyora Sambung Kata\nVersion: 3.0\nAuthor: sazaraaax\nLibrary: Axion UI\n\nStatus: ✅ Whitelisted\nUser: %s\nDiscord: %s\n\nFitur:\n• Auto Farm AI\n• Real-time Status\n• Word Filter\n• Whitelist System",
            LocalPlayer.Name,
            userData.discordUser
        )
    })
    
    InfoTab:CreateParagraph({
        Title = "How to Use",
        Content = "1. Get whitelist via Discord\n2. Verify automatically\n3. Enable Auto Farm\n4. Let the bot play!"
    })
    
    -- =========================
    -- REMOTE EVENT HANDLERS
    -- =========================
    MatchUI.OnClientEvent:Connect(function(cmd, value)
        if cmd == "ShowMatchUI" then
            matchActive = true
            isMyTurn = false
            resetUsedWords()
            MatchStatus.Text = "🟢 Match: Active"
            MatchStatus.TextColor = Color3.fromRGB(0, 255, 0)
        elseif cmd == "HideMatchUI" then
            matchActive = false
            isMyTurn = false
            serverLetter = ""
            resetUsedWords()
            MatchStatus.Text = "🔴 Match: Waiting"
            MatchStatus.TextColor = Color3.fromRGB(255, 100, 100)
            TurnStatus.Text = "⏳ Turn: -"
            CurrentWord.Text = "📝 Word: -"
        elseif cmd == "StartTurn" then
            isMyTurn = true
            TurnStatus.Text = "🎯 Turn: Your Turn"
            TurnStatus.TextColor = Color3.fromRGB(0, 255, 0)
            if autoEnabled then
                startUltraAI()
            end
        elseif cmd == "EndTurn" then
            isMyTurn = false
            TurnStatus.Text = "⏳ Turn: Opponent"
            TurnStatus.TextColor = Color3.fromRGB(255, 255, 0)
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
            if UsedList then
                local displayText = "Used Words:\n"
                for i, w in ipairs(usedWordsList) do
                    displayText = displayText .. w .. (i < #usedWordsList and ", " or "")
                    if i % 5 == 0 then
                        displayText = displayText .. "\n"
                    end
                end
                UsedList.Text = displayText
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
        if ScreenGui and ScreenGui.Parent then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end
end)

-- =========================
-- INIT
-- =========================
print("✅ LYORA AXION UI + WHITELIST SYSTEM LOADED")
print("📌 User: " .. LocalPlayer.Name)
print("🔑 User ID: " .. LocalPlayer.UserId)