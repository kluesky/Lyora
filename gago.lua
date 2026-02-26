-- =========================================================
-- LYORA CHEAT SCRIPT - AXION UI (FIXED)
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end

-- AMBIL USER DATA DARI VERIFICATION
local userData = _G.LyoraUserData or {
    userId = tostring(game.Players.LocalPlayer.UserId),
    username = game.Players.LocalPlayer.Name,
    discordUser = "Unknown"
}

print("✅ Cheat script loaded for: " .. userData.discordUser)

-- =========================
-- LOAD AXION UI LIBRARY
-- =========================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/adamowaissi22-boop/Axom-Scripts-/refs/heads/main/Axion%20Ui%20Library"))()

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- WORDLIST
-- =========================
local kataModule = {}

local function downloadWordlist()
    local response = game:HttpGet("https://raw.githubusercontent.com/danzzy1we/roblox-script-dump/refs/heads/main/WordListDump/Dump_IndonesianWords.lua")
    if not response then return false end

    local content = string.match(response, "return%s*(.+)")
    if not content then return false end

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
    if min > max then min = max end
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
-- CREATE MAIN GUI (AXION UI) - FIXED SYNTAX
-- =========================
local Window = Library:CreateWindow({
    Name = "✨ LYORA SAMBUNG KATA",
    Subtitle = "Premium Auto Farm | " .. userData.discordUser,
    Size = UDim2.new(0, 650, 0, 500),
    Position = UDim2.new(0.5, -325, 0.5, -250),
    Theme = "Dark",
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

-- Avatar (manual karena AddElement mungkin belum support ImageLabel)
local Avatar = Instance.new("ImageLabel")
Avatar.Parent = ProfileCard
Avatar.Size = UDim2.new(0, 60, 0, 60)
Avatar.Position = UDim2.new(0, 10, 0.5, -30)
Avatar.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
Avatar.BorderSizePixel = 0

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 30)
AvatarCorner.Parent = Avatar

local NameLabel = Instance.new("TextLabel")
NameLabel.Parent = ProfileCard
NameLabel.Size = UDim2.new(0, 200, 0, 25)
NameLabel.Position = UDim2.new(0, 80, 0, 15)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = LocalPlayer.Name
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextSize = 18
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.TextXAlignment = Enum.TextXAlignment.Left

local DiscordLabel = Instance.new("TextLabel")
DiscordLabel.Parent = ProfileCard
DiscordLabel.Size = UDim2.new(0, 200, 0, 20)
DiscordLabel.Position = UDim2.new(0, 80, 0, 45)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = "💬 " .. userData.discordUser
DiscordLabel.Font = Enum.Font.Gotham
DiscordLabel.TextSize = 12
DiscordLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Stats Section
local StatsSection = HomeTab:CreateSection("Statistics")

local stats = {
    {label = "Games", value = "0", icon = "🎮"},
    {label = "Streak", value = "0", icon = "🔥"},
    {label = "Words", value = "0", icon = "📝"},
    {label = "Acc", value = "0%", icon = "🎯"}
}

for i, stat in ipairs(stats) do
    local card = StatsSection:AddElement("Frame", {
        Size = UDim2.new(0, 140, 0, 80),
        Position = UDim2.new(0, (i-1) * 150, 0, 0),
        BackgroundColor = Color3.fromRGB(25, 30, 40),
        BorderRadius = 8
    })
    
    local icon = card:AddElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 10),
        Text = stat.icon,
        Font = "Gotham",
        TextSize = 20,
        TextColor = Color3.fromRGB(255, 105, 180)
    })
    
    local value = card:AddElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 40),
        Text = stat.value,
        Font = "GothamBold",
        TextSize = 18,
        TextColor = Color3.fromRGB(255, 255, 255)
    })
    
    local label = card:AddElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 65),
        Text = stat.label,
        Font = "Gotham",
        TextSize = 11,
        TextColor = Color3.fromRGB(150, 150, 150)
    })
end

-- =========================
-- AUTO TAB
-- =========================
local AutoTab = Window:CreateTab("⚙️ Auto Farm")

-- Status Section
local StatusSection = AutoTab:CreateSection("Live Status")

-- Status Panel (manual karena AddElement mungkin terbatas)
local StatusFrame = StatusSection:AddElement("Frame", {
    Size = UDim2.new(1, -20, 0, 100),
    BackgroundColor = Color3.fromRGB(25, 30, 40),
    BorderRadius = 8
})

local function createStatusLabel(parent, y, label, default)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.Size = UDim2.new(0, 80, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local val = Instance.new("TextLabel")
    val.Parent = parent
    val.Size = UDim2.new(0, 150, 0, 20)
    val.Position = UDim2.new(0, 100, 0, y)
    val.BackgroundTransparency = 1
    val.Text = default
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextColor3 = Color3.fromRGB(255, 255, 255)
    val.TextXAlignment = Enum.TextXAlignment.Left
    
    return val
end

local MatchStatus = createStatusLabel(StatusFrame, 10, "Match:", "🔴 Waiting")
local TurnStatus = createStatusLabel(StatusFrame, 40, "Turn:", "⏳ -")
local WordStatus = createStatusLabel(StatusFrame, 70, "Kata:", "📝 -")

-- Settings Section
local SettingsSection = AutoTab:CreateSection("Pengaturan Auto")

SettingsSection:AddToggle({
    Name = "Aktifkan Auto Farm",
    Default = false,
    Callback = function(state)
        autoEnabled = state
        if state and matchActive and isMyTurn then
            startUltraAI()
        end
    end
})

SettingsSection:AddSlider({
    Name = "Agresivitas",
    Min = 0,
    Max = 100,
    Default = config.aggression,
    Callback = function(v)
        config.aggression = v
    end
})

SettingsSection:AddSlider({
    Name = "Min Delay (ms)",
    Min = 50,
    Max = 500,
    Default = config.minDelay,
    Callback = function(v)
        config.minDelay = v
    end
})

SettingsSection:AddSlider({
    Name = "Max Delay (ms)",
    Min = 200,
    Max = 1500,
    Default = config.maxDelay,
    Callback = function(v)
        config.maxDelay = v
    end
})

SettingsSection:AddSlider({
    Name = "Min Panjang Kata",
    Min = 1,
    Max = 3,
    Default = config.minLength,
    Callback = function(v)
        config.minLength = v
    end
})

SettingsSection:AddSlider({
    Name = "Max Panjang Kata",
    Min = 5,
    Max = 20,
    Default = config.maxLength,
    Callback = function(v)
        config.maxLength = v
    end
})

-- =========================
-- WORDS TAB
-- =========================
local WordsTab = Window:CreateTab("📋 Words")

local WordsFrame = WordsTab:AddElement("Frame", {
    Size = UDim2.new(1, -20, 0, 150),
    BackgroundColor = Color3.fromRGB(25, 30, 40),
    BorderRadius = 8
})

local WordsList = Instance.new("TextLabel")
WordsList.Parent = WordsFrame
WordsList.Size = UDim2.new(1, -20, 1, -20)
WordsList.Position = UDim2.new(0, 10, 0, 10)
WordsList.BackgroundTransparency = 1
WordsList.Text = "Belum ada kata terpakai"
WordsList.Font = Enum.Font.Gotham
WordsList.TextSize = 13
WordsList.TextColor3 = Color3.fromRGB(180, 180, 180)
WordsList.TextWrapped = true
WordsList.TextXAlignment = Enum.TextXAlignment.Left
WordsList.TextYAlignment = Enum.TextYAlignment.Top

WordsTab:AddButton({
    Name = "Reset Used Words",
    Callback = function()
        resetUsedWords()
        WordsList.Text = "Belum ada kata terpakai"
    end
})

-- =========================
-- INFO TAB
-- =========================
local InfoTab = Window:CreateTab("ℹ️ Info")

local InfoFrame = InfoTab:AddElement("Frame", {
    Size = UDim2.new(1, -20, 0, 200),
    BackgroundColor = Color3.fromRGB(25, 30, 40),
    BorderRadius = 8
})

local InfoText = Instance.new("TextLabel")
InfoText.Parent = InfoFrame
InfoText.Size = UDim2.new(1, -20, 1, -20)
InfoText.Position = UDim2.new(0, 10, 0, 10)
InfoText.BackgroundTransparency = 1
InfoText.Text = string.format(
[[✨ LYORA SAMBUNG KATA
━━━━━━━━━━━━━━━━━━━━
Version    : 3.0
Author     : Lyora Community
Wordlist   : %d kata

👤 User     : %s
💬 Discord  : %s
📊 Status   : ✅ Whitelisted

⚡ Fitur:
• Auto Farm dengan AI
• Real-time status
• Filter panjang kata
• Anti kata berulang

📌 Cara Pakai:
1. Aktifkan Auto Farm
2. Atur agresivitas
3. Biarkan bot bekerja
]], #kataModule, LocalPlayer.Name, userData.discordUser)
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 13
InfoText.TextColor3 = Color3.fromRGB(220, 220, 220)
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top

-- =========================
-- REMOTE EVENT HANDLERS
-- =========================
MatchUI.OnClientEvent:Connect(function(cmd, value)
    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        resetUsedWords()
        MatchStatus.Text = "🟢 In Game"
    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        resetUsedWords()
        MatchStatus.Text = "🔴 Waiting"
        TurnStatus.Text = "⏳ -"
        WordStatus.Text = "📝 -"
    elseif cmd == "StartTurn" then
        isMyTurn = true
        TurnStatus.Text = "🎯 Giliran Anda"
        if autoEnabled then
            startUltraAI()
        end
    elseif cmd == "EndTurn" then
        isMyTurn = false
        TurnStatus.Text = "⏳ Opponent"
    elseif cmd == "UpdateServerLetter" then
        serverLetter = value or ""
        WordStatus.Text = "📝 " .. serverLetter
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
        local displayText = "📋 Kata terpakai:\n"
        for i, w in ipairs(usedWordsList) do
            displayText = displayText .. w
            if i < #usedWordsList then displayText = displayText .. ", " end
            if i % 5 == 0 then displayText = displayText .. "\n" end
        end
        WordsList.Text = displayText
        if autoEnabled and matchActive and isMyTurn then
            humanDelay()
            startUltraAI()
        end
    end
end)

-- =========================
-- KEYBIND
-- =========================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Window:Toggle()
    end
end)

-- =========================
-- WELCOME
-- =========================
print("✅ LYORA AXION UI LOADED - Welcome " .. userData.discordUser)