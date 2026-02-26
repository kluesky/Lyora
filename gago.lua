-- =========================================================
-- LYORA SAMBUNG KATA - ULTIMATE EDITION
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end

-- =========================
-- LOAD RAYFIELD
-- =========================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- =========================
-- SERVICES
-- =========================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- USER DATA (DARI VERIFY)
-- =========================
local userData = _G.LyoraUserData or {
    discordUser = "Unknown",
    username = LocalPlayer.Name,
    userId = tostring(LocalPlayer.UserId)
}

-- =========================
-- LOAD WORDLIST
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
    Rayfield:Notify({
        Title = "Error",
        Content = "Gagal load wordlist!",
        Duration = 3
    })
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
    if not usedWords[w] then
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

    table.sort(results, function(a, b)
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
-- CREATE WINDOW (DESAIN FRESH)
-- =========================
local Window = Rayfield:CreateWindow({
    Name = "✨ LYORA SAMBUNG KATA",
    LoadingTitle = "Auto Farm System",
    LoadingSubtitle = "Welcome " .. userData.discordUser,
    ConfigurationSaving = { Enabled = true },
    Discord = {
        Enabled = true,
        Invite = "cvaHe2rXnk",
        RememberJoins = true
    }
})

-- =========================
-- TAB HOME
-- =========================
local HomeTab = Window:CreateTab("🏠 Home", "home")

-- Profile Card
HomeTab:CreateParagraph("👤 Account Info",
    string.format("Discord: %s\nRoblox: %s\nUser ID: %s\nStatus: ✅ Whitelisted",
        userData.discordUser,
        LocalPlayer.Name,
        userData.userId
    )
)

-- Status Section
local StatusSection = HomeTab:CreateSection("📊 Live Status")

local MatchStatus = HomeTab:CreateParagraph("Match Status", "🔴 Waiting")
local TurnStatus = HomeTab:CreateParagraph("Turn", "⏳ -")
local WordStatus = HomeTab:CreateParagraph("Current Letter", "📝 -")
local UsedCount = HomeTab:CreateParagraph("Used Words", "📋 0")
local WordlistCount = HomeTab:CreateParagraph("Wordlist", "📚 " .. #kataModule .. " kata")

-- =========================
-- TAB AUTO FARM
-- =========================
local AutoTab = Window:CreateTab("⚙️ Auto Farm", "settings")

AutoTab:CreateToggle({
    Name = "🤖 Aktifkan Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        autoEnabled = v
        if v and matchActive and isMyTurn then
            startUltraAI()
        end
    end
})

AutoTab:CreateSlider({
    Name = "🎯 Agresivitas",
    Range = {0, 100},
    Increment = 5,
    CurrentValue = config.aggression,
    Callback = function(v)
        config.aggression = v
    end
})

AutoTab:CreateSlider({
    Name = "⏱️ Min Delay (ms)",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = config.minDelay,
    Callback = function(v)
        config.minDelay = v
    end
})

AutoTab:CreateSlider({
    Name = "⏱️ Max Delay (ms)",
    Range = {200, 1500},
    Increment = 10,
    CurrentValue = config.maxDelay,
    Callback = function(v)
        config.maxDelay = v
    end
})

AutoTab:CreateSlider({
    Name = "📏 Min Panjang Kata",
    Range = {1, 3},
    Increment = 1,
    CurrentValue = config.minLength,
    Callback = function(v)
        config.minLength = v
    end
})

AutoTab:CreateSlider({
    Name = "📏 Max Panjang Kata",
    Range = {5, 20},
    Increment = 1,
    CurrentValue = config.maxLength,
    Callback = function(v)
        config.maxLength = v
    end
})

-- =========================
-- TAB WORDS
-- =========================
local WordsTab = Window:CreateTab("📋 Words", "list")

local UsedDropdown = WordsTab:CreateDropdown({
    Name = "📋 Daftar Kata Terpakai",
    Options = usedWordsList,
    CurrentOption = "",
    Callback = function() end
})

WordsTab:CreateButton({
    Name = "🔄 Reset Used Words",
    Callback = function()
        resetUsedWords()
        UsedDropdown:Set({})
        UsedCount:Set("📋 0")
        Rayfield:Notify({
            Title = "Reset",
            Content = "Used words cleared",
            Duration = 2
        })
    end
})

-- =========================
-- TAB INFO (BARU!)
-- =========================
local InfoTab = Window:CreateTab("ℹ️ Info", "info")

-- Informasi Script
InfoTab:CreateParagraph("📌 Script Information",
    string.format([[
✨ LYORA SAMBUNG KATA
━━━━━━━━━━━━━━━━━━
Version    : 1.0.0
Author     : Lyora Community
Library    : Rayfield
Wordlist   : %d kata

👤 User Info
━━━━━━━━━━━━━━━━━━
Discord    : %s
Roblox     : %s
User ID    : %s
Status     : ✅ Whitelisted
]],
        #kataModule,
        userData.discordUser,
        LocalPlayer.Name,
        userData.userId
    )
)

-- Cara Penggunaan
InfoTab:CreateParagraph("📖 Cara Penggunaan",
    [[
1️⃣ Dapatkan whitelist via Discord
   • Join Discord server
   • Ketik /whitelist <username>

2️⃣ Verifikasi di GUI mini
   • Klik VERIFY
   • Otomatis load script ini

3️⃣ Aktifkan Auto Farm
   • Toggle ON di tab Auto
   • Atur agresivitas & delay
   • Biarkan script bekerja!

4️⃣ Pantau Status
   • Live status di tab Home
   • Daftar kata terpakai
   ]]
)

-- Fitur
InfoTab:CreateParagraph("⚡ Fitur Unggulan",
    [[
✅ Auto Farm dengan AI
   • Cari kata terbaik
   • Delay seperti manusia
   • Agresivitas adjustable

✅ Wordlist Indonesia
   • 1000+ kata
   • Filter panjang kata
   • Anti kata berulang

✅ Real-time Status
   • Monitor pertandingan
   • Lihat giliran
   • Track kata terpakai

✅ Sistem Whitelist
   • 7 jam masa aktif
   • Terintegrasi Discord
   • Aman & terpercaya
   ]]
)

-- Informasi Update
InfoTab:CreateParagraph("🆕 What's New v3.0",
    [[
✨ Desain UI baru
✨ Menu informasi lengkap
✨ Status live lebih detail
✨ Optimasi untuk Android
✨ Fix bug & error
   ]]
)

-- Credits
InfoTab:CreateParagraph("🙏 Credits",
    [[
Terima kasih kepada:
• Lyora Community
• Semua user Lyora

━━━━━━━━━━━━━━━━━━
© 2025 Lyora System
All rights reserved
   ]]
)

-- =========================
-- TAB SETTINGS
-- =========================
local SettingsTab = Window:CreateTab("⚙️ Settings", "settings")

SettingsTab:CreateParagraph("🔧 Pengaturan",
    "Toggle GUI: RightShift\nDrag: Tahan header"
)

SettingsTab:CreateButton({
    Name = "🗑️ Unload Script",
    Callback = function()
        Window:Destroy()
    end
})

-- =========================
-- REMOTE EVENT HANDLERS
-- =========================
MatchUI.OnClientEvent:Connect(function(cmd, value)
    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        resetUsedWords()
        MatchStatus:Set("🟢 In Game")
    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        resetUsedWords()
        MatchStatus:Set("🔴 Waiting")
        TurnStatus:Set("⏳ -")
        WordStatus:Set("📝 -")
        UsedCount:Set("📋 0")
        UsedDropdown:Set({})
    elseif cmd == "StartTurn" then
        isMyTurn = true
        TurnStatus:Set("🎯 Your Turn")
        if autoEnabled then
            startUltraAI()
        end
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
Rayfield:Notify({
    Title = "✨ Lyora Sambung Kata",
    Content = "Selamat datang " .. userData.discordUser .. "!",
    Duration = 3
})

print("✅ LYORA SCRIPT LOADED - Welcome " .. userData.discordUser)