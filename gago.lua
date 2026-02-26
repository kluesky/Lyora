-- =========================================================
-- LYORA CHEAT SCRIPT (LOADED AFTER VERIFICATION)
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
-- LOAD LIBRARY (GANTI SESUAI KEINGINAN)
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
-- CREATE MAIN GUI (AXION UI)
-- =========================
local Window = Library:CreateWindow({
    Name = "LYORA SAMBUNG KATA",
    Subtitle = "Premium Auto Farm | " .. userData.discordUser,
    Size = UDim2.new(0, 650, 0, 450),
    Position = UDim2.new(0.5, -325, 0.5, -225),
    Theme = "Default",
    Draggable = true,
    MinimizeEnabled = true
})

-- HOME TAB
local HomeTab = Window:CreateTab("🏠 Home")

HomeTab:CreateParagraph({
    Title = "Welcome",
    Content = "User: " .. userData.discordUser .. "\nStatus: ✅ Whitelisted"
})

-- AUTO TAB
local AutoTab = Window:CreateTab("⚙️ Auto Farm")

-- Status Panel
local StatusPanel = AutoTab:CreateSection("Game Status")

local MatchStatus = StatusPanel:AddElement("TextLabel", {
    Position = UDim2.new(0, 10, 0, 10),
    Text = "🔴 Match: Waiting",
    TextColor = Color3.fromRGB(255, 100, 100)
})

local TurnStatus = StatusPanel:AddElement("TextLabel", {
    Position = UDim2.new(0, 10, 0, 40),
    Text = "⏳ Turn: -",
    TextColor = Color3.fromRGB(255, 255, 0)
})

local CurrentWord = StatusPanel:AddElement("TextLabel", {
    Position = UDim2.new(0, 10, 0, 70),
    Text = "📝 Word: -",
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
    Min = 0, Max = 100,
    Default = config.aggression,
    Callback = function(v) config.aggression = v end
})

AutoSection:AddSlider({
    Name = "Min Delay (ms)",
    Min = 50, Max = 500,
    Default = config.minDelay,
    Callback = function(v) config.minDelay = v end
})

AutoSection:AddSlider({
    Name = "Max Delay (ms)",
    Min = 200, Max = 1500,
    Default = config.maxDelay,
    Callback = function(v) config.maxDelay = v end
})

AutoSection:AddSlider({
    Name = "Min Word Length",
    Min = 1, Max = 3,
    Default = config.minLength,
    Callback = function(v) config.minLength = v end
})

AutoSection:AddSlider({
    Name = "Max Word Length",
    Min = 5, Max = 20,
    Default = config.maxLength,
    Callback = function(v) config.maxLength = v end
})

-- WORDS TAB
local WordsTab = Window:CreateTab("📋 Words")

local UsedList = WordsTab:AddElement("TextLabel", {
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

-- INFO TAB
local InfoTab = Window:CreateTab("ℹ️ Info")

InfoTab:CreateParagraph({
    Title = "Script Information",
    Content = string.format(
        "Lyora Sambung Kata\nVersion: 3.0\nAuthor: sazaraaax\nUser: %s\nDiscord: %s",
        LocalPlayer.Name,
        userData.discordUser
    )
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
        if autoEnabled then startUltraAI() end
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
        local displayText = "Used Words:\n"
        for i, w in ipairs(usedWordsList) do
            displayText = displayText .. w .. (i < #usedWordsList and ", " or "")
        end
        UsedList.Text = displayText
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

print("✅ LYORA CHEAT SCRIPT LOADED")