-- =========================================================
-- LYORA CUSTOM GUI - SAMBUNG KATA (PASTI MUNCUL)
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Data user dari verify
local userData = _G.LyoraUserData or {
    discordUser = "User",
    username = LocalPlayer.Name
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
downloadWordlist()

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
local autoEnabled = false
local autoRunning = false

local config = {
    minDelay = 350,
    maxDelay = 650,
    aggression = 20,
    minLength = 2,
    maxLength = 12
}

-- Logic functions
local function isUsed(word) return usedWords[string.lower(word)] == true end
local function addUsedWord(word)
    local w = string.lower(word)
    if not usedWords[w] then
        usedWords[w] = true
        table.insert(usedWordsList, word)
    end
end
local function resetUsedWords() usedWords = {}; usedWordsList = {} end

local function getSmartWords(prefix)
    local results = {}
    local lowerPrefix = string.lower(prefix)
    for i = 1, #kataModule do
        local word = kataModule[i]
        if string.sub(word, 1, #lowerPrefix) == lowerPrefix and not isUsed(word) then
            local len = string.len(word)
            if len >= config.minLength and len <= config.maxLength then
                table.insert(results, word)
            end
        end
    end
    table.sort(results, function(a,b) return #a > #b end)
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
    if autoRunning or not autoEnabled or not matchActive or not isMyTurn or serverLetter == "" then return end
    autoRunning = true
    humanDelay()
    local words = getSmartWords(serverLetter)
    if #words == 0 then autoRunning = false; return end
    local selectedWord = words[1]
    if config.aggression < 100 then
        local topN = math.floor(#words * (1 - config.aggression/100))
        if topN < 1 then topN = 1 end
        selectedWord = words[math.random(1, math.min(topN, #words))]
    end
    local currentWord = serverLetter
    local remain = string.sub(selectedWord, #serverLetter + 1)
    for i = 1, string.len(remain) do
        if not matchActive or not isMyTurn then autoRunning = false; return end
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
-- CUSTOM GUI SEDERHANA
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "LyoraGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
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
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(255, 80, 140)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LYORA"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
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
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Content
local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1

-- =========================
-- TAB BUTTONS
-- =========================
local TabFrame = Instance.new("Frame")
TabFrame.Parent = Content
TabFrame.Size = UDim2.new(1, 0, 0, 35)
TabFrame.BackgroundTransparency = 1

local tabs = {"🏠", "⚙️", "📋", "ℹ️"}
local tabButtons = {}
local tabContents = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Parent = TabFrame
    btn.Size = UDim2.new(0.25, -2, 1, 0)
    btn.Position = UDim2.new(0.25 * (i-1), 1, 0, 0)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 80, 140) or Color3.fromRGB(40, 42, 50)
    btn.Text = tabName
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    table.insert(tabButtons, btn)
end

-- Container untuk konten tab
local TabContainer = Instance.new("Frame")
TabContainer.Parent = Content
TabContainer.Size = UDim2.new(1, 0, 1, -45)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundTransparency = 1

-- =========================
-- TAB 1: HOME
-- =========================
local HomeTab = Instance.new("Frame")
HomeTab.Parent = TabContainer
HomeTab.Size = UDim2.new(1, 0, 1, 0)
HomeTab.BackgroundTransparency = 1
tabContents["🏠"] = HomeTab

-- Profile
local ProfileBox = Instance.new("Frame")
ProfileBox.Parent = HomeTab
ProfileBox.Size = UDim2.new(1, 0, 0, 60)
ProfileBox.BackgroundColor3 = Color3.fromRGB(30, 32, 40)

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = ProfileBox

local Avatar = Instance.new("ImageLabel")
Avatar.Parent = ProfileBox
Avatar.Size = UDim2.new(0, 40, 0, 40)
Avatar.Position = UDim2.new(0, 10, 0.5, -20)
Avatar.BackgroundColor3 = Color3.fromRGB(50, 52, 60)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 20)
AvatarCorner.Parent = Avatar

local NameLabel = Instance.new("TextLabel")
NameLabel.Parent = ProfileBox
NameLabel.Size = UDim2.new(0, 200, 0, 20)
NameLabel.Position = UDim2.new(0, 60, 0, 15)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = LocalPlayer.Name
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextSize = 14
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.TextXAlignment = Enum.TextXAlignment.Left

local DiscordLabel = Instance.new("TextLabel")
DiscordLabel.Parent = ProfileBox
DiscordLabel.Size = UDim2.new(0, 200, 0, 20)
DiscordLabel.Position = UDim2.new(0, 60, 0, 35)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = userData.discordUser
DiscordLabel.Font = Enum.Font.Gotham
DiscordLabel.TextSize = 12
DiscordLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Status
local StatusBox = Instance.new("Frame")
StatusBox.Parent = HomeTab
StatusBox.Size = UDim2.new(1, 0, 0, 80)
StatusBox.Position = UDim2.new(0, 0, 0, 70)
StatusBox.BackgroundColor3 = Color3.fromRGB(30, 32, 40)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusBox

local function createStatusRow(parent, y, label, value)
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
    val.Text = value
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextColor3 = Color3.fromRGB(255, 255, 255)
    val.TextXAlignment = Enum.TextXAlignment.Left
    
    return val
end

local matchStatus = createStatusRow(StatusBox, 10, "Match:", "🔴 Waiting")
local turnStatus = createStatusRow(StatusBox, 35, "Turn:", "⏳ -")
local wordStatus = createStatusRow(StatusBox, 60, "Kata:", "📝 -")

-- =========================
-- TAB 2: AUTO
-- =========================
local AutoTab = Instance.new("Frame")
AutoTab.Parent = TabContainer
AutoTab.Size = UDim2.new(1, 0, 1, 0)
AutoTab.BackgroundTransparency = 1
AutoTab.Visible = false
tabContents["⚙️"] = AutoTab

-- Auto Toggle
local ToggleFrame = Instance.new("Frame")
ToggleFrame.Parent = AutoTab
ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleFrame

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Parent = ToggleFrame
ToggleLabel.Size = UDim2.new(0, 150, 1, 0)
ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "🤖 Auto Farm"
ToggleLabel.Font = Enum.Font.GothamBold
ToggleLabel.TextSize = 14
ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBg = Instance.new("Frame")
ToggleBg.Parent = ToggleFrame
ToggleBg.Size = UDim2.new(0, 44, 0, 22)
ToggleBg.Position = UDim2.new(1, -54, 0.5, -11)
ToggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local ToggleBgCorner = Instance.new("UICorner")
ToggleBgCorner.CornerRadius = UDim.new(0, 11)
ToggleBgCorner.Parent = ToggleBg

local ToggleCircle = Instance.new("Frame")
ToggleCircle.Parent = ToggleBg
ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
ToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

local ToggleCircleCorner = Instance.new("UICorner")
ToggleCircleCorner.CornerRadius = UDim.new(0, 9)
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
        TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 140)}):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 24, 0.5, -9)}):Play()
        autoEnabled = true
        if matchActive and isMyTurn then startUltraAI() end
    else
        TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        autoEnabled = false
    end
end)

-- Slider function
local function createSlider(parent, name, min, max, default, y, callback)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.Size = UDim2.new(0, 150, 0, 20)
    label.Position = UDim2.new(0, 10, 0, y)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = parent
    sliderBg.Size = UDim2.new(0, 200, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, y + 20)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 52, 60)
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 3)
    sliderCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBg
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 80, 140)
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = parent
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(0, 220, 0, y)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = default
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = Color3.fromRGB(255, 80, 140)
    
    local dragging = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    sliderBg.InputEnded:Connect(function()
        dragging = false
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBg.AbsolutePosition
            local sliderSize = sliderBg.AbsoluteSize.X
            local percent = math.clamp((mousePos.X - sliderPos.X) / sliderSize, 0, 1)
            local value = math.floor(min + percent * (max - min))
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Text = value
            label.Text = name .. ": " .. value
            callback(value)
        end
    end)
end

createSlider(AutoTab, "Agresivitas", 0, 100, config.aggression, 50, function(v) config.aggression = v end)
createSlider(AutoTab, "Min Delay", 50, 500, config.minDelay, 100, function(v) config.minDelay = v end)
createSlider(AutoTab, "Max Delay", 200, 1500, config.maxDelay, 150, function(v) config.maxDelay = v end)
createSlider(AutoTab, "Min Panjang", 1, 3, config.minLength, 200, function(v) config.minLength = v end)
createSlider(AutoTab, "Max Panjang", 5, 20, config.maxLength, 250, function(v) config.maxLength = v end)

-- =========================
-- TAB 3: WORDS
-- =========================
local WordsTab = Instance.new("Frame")
WordsTab.Parent = TabContainer
WordsTab.Size = UDim2.new(1, 0, 1, 0)
WordsTab.BackgroundTransparency = 1
WordsTab.Visible = false
tabContents["📋"] = WordsTab

local WordsBox = Instance.new("Frame")
WordsBox.Parent = WordsTab
WordsBox.Size = UDim2.new(1, 0, 0, 150)
WordsBox.BackgroundColor3 = Color3.fromRGB(30, 32, 40)

local WordsCorner = Instance.new("UICorner")
WordsCorner.CornerRadius = UDim.new(0, 6)
WordsCorner.Parent = WordsBox

local WordsList = Instance.new("TextLabel")
WordsList.Parent = WordsBox
WordsList.Size = UDim2.new(1, -20, 1, -20)
WordsList.Position = UDim2.new(0, 10, 0, 10)
WordsList.BackgroundTransparency = 1
WordsList.Text = "Belum ada kata terpakai"
WordsList.Font = Enum.Font.Gotham
WordsList.TextSize = 12
WordsList.TextColor3 = Color3.fromRGB(180, 180, 180)
WordsList.TextWrapped = true
WordsList.TextXAlignment = Enum.TextXAlignment.Left
WordsList.TextYAlignment = Enum.TextYAlignment.Top

local ResetBtn = Instance.new("TextButton")
ResetBtn.Parent = WordsTab
ResetBtn.Size = UDim2.new(1, 0, 0, 35)
ResetBtn.Position = UDim2.new(0, 0, 0, 160)
ResetBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 140)
ResetBtn.Text = "🔄 Reset Used Words"
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 12
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 6)
ResetCorner.Parent = ResetBtn

ResetBtn.MouseButton1Click:Connect(function()
    resetUsedWords()
    WordsList.Text = "Belum ada kata terpakai"
end)

-- =========================
-- TAB 4: INFO
-- =========================
local InfoTab = Instance.new("Frame")
InfoTab.Parent = TabContainer
InfoTab.Size = UDim2.new(1, 0, 1, 0)
InfoTab.BackgroundTransparency = 1
InfoTab.Visible = false
tabContents["ℹ️"] = InfoTab

local InfoBox = Instance.new("Frame")
InfoBox.Parent = InfoTab
InfoBox.Size = UDim2.new(1, 0, 0, 200)
InfoBox.BackgroundColor3 = Color3.fromRGB(30, 32, 40)

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 6)
InfoCorner.Parent = InfoBox

local InfoText = Instance.new("TextLabel")
InfoText.Parent = InfoBox
InfoText.Size = UDim2.new(1, -20, 1, -20)
InfoText.Position = UDim2.new(0, 10, 0, 10)
InfoText.BackgroundTransparency = 1
InfoText.Text = string.format(
[[✨ LYORA SAMBUNG KATA
━━━━━━━━━━━━━━━━
Versi    : 3.0
Author   : sazaraaax
Wordlist : %d kata

👤 %s
💬 %s

⚡ Fitur:
• Auto Farm AI
• Filter kata
• Real-time status
• Whitelist system

🔹 /whitelist di Discord
🔹 Berlaku 7 jam
]], #kataModule, LocalPlayer.Name, userData.discordUser)
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 12
InfoText.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top

-- =========================
-- TAB NAVIGATION
-- =========================
for i, btn in ipairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 80, 140)
        
        for name, frame in pairs(tabContents) do
            frame.Visible = false
        end
        tabContents[btn.Text].Visible = true
    end)
end

-- =========================
-- REMOTE HANDLERS
-- =========================
MatchUI.OnClientEvent:Connect(function(cmd, value)
    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        resetUsedWords()
        matchStatus.Text = "🟢 In Game"
    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        resetUsedWords()
        matchStatus.Text = "🔴 Waiting"
        turnStatus.Text = "⏳ -"
        wordStatus.Text = "📝 -"
    elseif cmd == "StartTurn" then
        isMyTurn = true
        turnStatus.Text = "🎯 Your Turn"
        if autoEnabled then startUltraAI() end
    elseif cmd == "EndTurn" then
        isMyTurn = false
        turnStatus.Text = "⏳ Opponent"
    elseif cmd == "UpdateServerLetter" then
        serverLetter = value or ""
        wordStatus.Text = "📝 " .. serverLetter
    end
end)

UsedWordWarn.OnClientEvent:Connect(function(word)
    if word then
        addUsedWord(word)
        WordsList.Text = "📋 Kata terpakai:\n" .. table.concat(usedWordsList, ", ")
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
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("✅ LYORA CUSTOM GUI LOADED")