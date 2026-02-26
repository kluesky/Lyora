-- =========================================================
-- LYORA SAMBUNG KATA - AUTO FARM (RAYFIELD)
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Ambil data user dari verification
local userData = _G.LyoraUserData or {
    discordUser = "Unknown",
    username = LocalPlayer.Name
}

-- Load wordlist
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

downloadWordlist()
print("Wordlist Loaded:", #kataModule)

-- Remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local MatchUI = remotes:WaitForChild("MatchUI")
local SubmitWord = remotes:WaitForChild("SubmitWord")
local BillboardUpdate = remotes:WaitForChild("BillboardUpdate")
local BillboardEnd = remotes:WaitForChild("BillboardEnd")
local TypeSound = remotes:WaitForChild("TypeSound")
local UsedWordWarn = remotes:WaitForChild("UsedWordWarn")

-- State
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

-- Logic Functions
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

-- Auto Engine
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

-- Create Main Window
local Window = Rayfield:CreateWindow({
    Name = "LYORA SAMBUNG KATA",
    LoadingTitle = "Auto Farm System",
    LoadingSubtitle = "Welcome " .. userData.discordUser,
    ConfigurationSaving = { Enabled = true }
})

-- Main Tab
local MainTab = Window:CreateTab("🏠 Main", "home")

MainTab:CreateParagraph("👤 Account", 
    string.format("Discord: %s\nRoblox: %s\nStatus: ✅ Whitelisted",
        userData.discordUser,
        LocalPlayer.Name
    )
)

-- Status
local StatusSection = MainTab:CreateSection("Game Status")

local MatchStatus = MainTab:CreateParagraph("Match", "🔴 Waiting")
local TurnStatus = MainTab:CreateParagraph("Turn", "⏳ -")
local WordStatus = MainTab:CreateParagraph("Current Word", "📝 -")
local UsedCount = MainTab:CreateParagraph("Used Words", "📋 0")

-- Auto Tab
local AutoTab = Window:CreateTab("⚙️ Auto Farm", "settings")

AutoTab:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        autoEnabled = v
        if v and matchActive and isMyTurn then
            startUltraAI()
        end
    end
})

AutoTab:CreateSlider({
    Name = "Aggression",
    Range = {0, 100},
    Increment = 5,
    CurrentValue = config.aggression,
    Callback = function(v)
        config.aggression = v
    end
})

AutoTab:CreateSlider({
    Name = "Min Delay (ms)",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = config.minDelay,
    Callback = function(v)
        config.minDelay = v
    end
})

AutoTab:CreateSlider({
    Name = "Max Delay (ms)",
    Range = {200, 1500},
    Increment = 10,
    CurrentValue = config.maxDelay,
    Callback = function(v)
        config.maxDelay = v
    end
})

AutoTab:CreateSlider({
    Name = "Min Word Length",
    Range = {1, 3},
    Increment = 1,
    CurrentValue = config.minLength,
    Callback = function(v)
        config.minLength = v
    end
})

AutoTab:CreateSlider({
    Name = "Max Word Length",
    Range = {5, 20},
    Increment = 1,
    CurrentValue = config.maxLength,
    Callback = function(v)
        config.maxLength = v
    end
})

-- Words Tab
local WordsTab = Window:CreateTab("📋 Words", "list")

local UsedDropdown = WordsTab:CreateDropdown({
    Name = "Used Words List",
    Options = usedWordsList,
    CurrentOption = "",
    Callback = function() end
})

WordsTab:CreateButton({
    Name = "Reset Used Words",
    Callback = function()
        resetUsedWords()
        UsedDropdown:Set({})
        Rayfield:Notify({
            Title = "Reset",
            Content = "Used words has been reset",
            Duration = 2
        })
    end
})

-- Info Tab
local InfoTab = Window:CreateTab("ℹ️ Info", "info")

InfoTab:CreateParagraph("Script Info",
    string.format(
        "Lyora Sambung Kata\nVersion: 3.0\nAuthor: sazaraaax\n\nUser: %s\nDiscord: %s\nWordlist: %d words",
        LocalPlayer.Name,
        userData.discordUser,
        #kataModule
    )
)

-- Remote Events
MatchUI.OnClientEvent:Connect(function(cmd, value)
    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        resetUsedWords()
        MatchStatus:Set("🟢 Active")
    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        resetUsedWords()
        MatchStatus:Set("🔴 Waiting")
        TurnStatus:Set("⏳ -")
        WordStatus:Set("📝 -")
    elseif cmd == "StartTurn" then
        isMyTurn = true
        TurnStatus:Set("🎯 Your Turn")
        if autoEnabled then startUltraAI() end
    elseif cmd == "EndTurn" then
        isMyTurn = false
        TurnStatus:Set("⏳ Opponent")
    elseif cmd == "UpdateServerLetter" then
        serverLetter = value or ""
        WordStatus:Set("📝 " .. serverLetter)
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
        UsedCount:Set("📋 " .. #usedWordsList)
        UsedDropdown:Set(usedWordsList)
        if autoEnabled and matchActive and isMyTurn then
            humanDelay()
            startUltraAI()
        end
    end
end)

-- Keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Window:Toggle()
    end
end)

print("✅ CHEAT SCRIPT LOADED FOR: " .. userData.discordUser)