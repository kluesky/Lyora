-- =========================================================
-- LYORA ALL IN ONE - VERIFICATION + MAIN GUI
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
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================
-- CONFIG
-- =========================
local WHITELIST_URL = "https://pastefy.app/EvFSBcDy/raw"
local DISCORD_INVITE = "cvaHe2rXnk"

-- Data user (akan diisi setelah verifikasi)
local userData = {
    userId = tostring(LocalPlayer.UserId),
    username = LocalPlayer.Name,
    discordUser = "Not Verified",
    isWhitelisted = false
}

-- =========================
-- WORDLIST (untuk auto farm)
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
-- REMOTES (untuk auto farm)
-- =========================
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local MatchUI = remotes:WaitForChild("MatchUI")
local SubmitWord = remotes:WaitForChild("SubmitWord")
local BillboardUpdate = remotes:WaitForChild("BillboardUpdate")
local BillboardEnd = remotes:WaitForChild("BillboardEnd")
local TypeSound = remotes:WaitForChild("TypeSound")
local UsedWordWarn = remotes:WaitForChild("UsedWordWarn")

-- =========================
-- STATE (untuk auto farm)
-- =========================
local matchActive = false
local isMyTurn = false
local serverLetter = ""
local usedWords = {}
local usedWordsList = {}
local autoEnabled = false
local autoRunning = false

local matchData = {
    player1 = "",
    player2 = "",
    player1Score = 0,
    player2Score = 0
}

local config = {
    minDelay = 350,
    maxDelay = 650,
    aggression = 20,
    minLength = 2,
    maxLength = 12
}

-- =========================
-- LOGIC FUNCTIONS (auto farm)
-- =========================
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
-- FUNGSI CEK WHITELIST
-- =========================
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
    
    return true, entry.discordTag or entry.discordName or "User"
end

-- =========================
-- CREATE MAIN GUI (setelah verifikasi)
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "LyoraGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 380, 0, 520)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = false  -- Awalnya hidden, muncul setelah verifikasi

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

-- HEADER
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(255, 80, 140)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LYORA"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel")
Subtitle.Parent = Header
Subtitle.Size = UDim2.new(1, -80, 0, 15)
Subtitle.Position = UDim2.new(0, 12, 0, 25)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Loading..."
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 10
Subtitle.TextColor3 = Color3.fromRGB(220, 220, 220)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

-- Close Button
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

-- CONTENT
local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true

-- =========================
-- VERIFICATION GUI (di dalam MainFrame)
-- =========================
local VerifyFrame = Instance.new("Frame")
VerifyFrame.Parent = Content
VerifyFrame.Size = UDim2.new(1, 0, 1, 0)
VerifyFrame.BackgroundTransparency = 1
VerifyFrame.Visible = true

-- Avatar
local VerifyAvatar = Instance.new("ImageLabel")
VerifyAvatar.Parent = VerifyFrame
VerifyAvatar.Size = UDim2.new(0, 60, 0, 60)
VerifyAvatar.Position = UDim2.new(0.5, -30, 0, 20)
VerifyAvatar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
VerifyAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"

local VerifyAvatarCorner = Instance.new("UICorner")
VerifyAvatarCorner.CornerRadius = UDim.new(0, 30)
VerifyAvatarCorner.Parent = VerifyAvatar

-- Username
local VerifyName = Instance.new("TextLabel")
VerifyName.Parent = VerifyFrame
VerifyName.Size = UDim2.new(1, 0, 0, 25)
VerifyName.Position = UDim2.new(0, 0, 0, 90)
VerifyName.BackgroundTransparency = 1
VerifyName.Text = LocalPlayer.Name
VerifyName.Font = Enum.Font.GothamBold
VerifyName.TextSize = 16
VerifyName.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Status Box
local VerifyStatusBox = Instance.new("Frame")
VerifyStatusBox.Parent = VerifyFrame
VerifyStatusBox.Size = UDim2.new(1, -40, 0, 35)
VerifyStatusBox.Position = UDim2.new(0, 20, 0, 130)
VerifyStatusBox.BackgroundColor3 = Color3.fromRGB(25, 27, 35)

local VerifyStatusCorner = Instance.new("UICorner")
VerifyStatusCorner.CornerRadius = UDim.new(0, 8)
VerifyStatusCorner.Parent = VerifyStatusBox

local VerifyStatus = Instance.new("TextLabel")
VerifyStatus.Parent = VerifyStatusBox
VerifyStatus.Size = UDim2.new(1, -10, 1, 0)
VerifyStatus.Position = UDim2.new(0, 5, 0, 0)
VerifyStatus.BackgroundTransparency = 1
VerifyStatus.Text = "⚪ Ready to verify"
VerifyStatus.Font = Enum.Font.Gotham
VerifyStatus.TextSize = 13
VerifyStatus.TextColor3 = Color3.fromRGB(200, 200, 200)

-- Verify Button
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Parent = VerifyFrame
VerifyBtn.Size = UDim2.new(1, -40, 0, 40)
VerifyBtn.Position = UDim2.new(0, 20, 0, 180)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 140)
VerifyBtn.Text = "VERIFY WHITELIST"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 14
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local VerifyBtnCorner = Instance.new("UICorner")
VerifyBtnCorner.CornerRadius = UDim.new(0, 8)
VerifyBtnCorner.Parent = VerifyBtn

-- Discord Button
local VerifyDiscord = Instance.new("TextButton")
VerifyDiscord.Parent = VerifyFrame
VerifyDiscord.Size = UDim2.new(1, -40, 0, 35)
VerifyDiscord.Position = UDim2.new(0, 20, 0, 230)
VerifyDiscord.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
VerifyDiscord.Text = "🔗 Join Discord"
VerifyDiscord.Font = Enum.Font.Gotham
VerifyDiscord.TextSize = 13
VerifyDiscord.TextColor3 = Color3.fromRGB(200, 200, 255)

local VerifyDiscordCorner = Instance.new("UICorner")
VerifyDiscordCorner.CornerRadius = UDim.new(0, 8)
VerifyDiscordCorner.Parent = VerifyDiscord

-- Info Text
local VerifyInfo = Instance.new("TextLabel")
VerifyInfo.Parent = VerifyFrame
VerifyInfo.Size = UDim2.new(1, -20, 0, 40)
VerifyInfo.Position = UDim2.new(0, 10, 0, 280)
VerifyInfo.BackgroundTransparency = 1
VerifyInfo.Text = "whitelist 7 jam • dapatkan di Discord\n/whitelist <username>"
VerifyInfo.Font = Enum.Font.Gotham
VerifyInfo.TextSize = 11
VerifyInfo.TextColor3 = Color3.fromRGB(140, 140, 140)

-- =========================
-- MAIN GUI (setelah verifikasi) - akan diisi nanti
-- =========================
local MainContent = Instance.new("Frame")
MainContent.Parent = Content
MainContent.Size = UDim2.new(1, 0, 1, 0)
MainContent.BackgroundTransparency = 1
MainContent.Visible = false

-- (nanti tab-tab auto farm akan dibuat di sini setelah verifikasi)

-- =========================
-- MINIMIZE FUNCTION
-- =========================
local minimized = false
local originalSize = MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 380, 0, 45), "Out", "Quad", 0.2, true)
        Content.Visible = false
        MinBtn.Text = "□"
        MinBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    else
        Content.Visible = true
        MainFrame:TweenSize(originalSize, "Out", "Quad", 0.2, true)
        MinBtn.Text = "—"
        MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    end
end)

-- =========================
-- NOTIFICATION FUNCTION
-- =========================
local function notif(teks, sukses)
    local n = Instance.new("Frame")
    n.Parent = ScreenGui
    n.Size = UDim2.new(0, 200, 0, 35)
    n.Position = UDim2.new(0.5, -100, 0, 10)
    n.BackgroundColor3 = sukses and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(180, 0, 0)
    n.ZIndex = 10
    
    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 8)
    nCorner.Parent = n
    
    local nText = Instance.new("TextLabel")
    nText.Parent = n
    nText.Size = UDim2.new(1, -10, 1, 0)
    nText.Position = UDim2.new(0, 5, 0, 0)
    nText.BackgroundTransparency = 1
    nText.Text = teks
    nText.Font = Enum.Font.GothamBold
    nText.TextSize = 13
    nText.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    task.wait(2)
    n:Destroy()
end

-- =========================
-- DISCORD BUTTON FUNCTION
-- =========================
VerifyDiscord.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/" .. DISCORD_INVITE)
    notif("🔗 Link Discord dicopy!", true)
end)

-- =========================
-- VERIFY BUTTON FUNCTION
-- =========================
VerifyBtn.MouseButton1Click:Connect(function()
    VerifyStatus.Text = "⏳ Verifying..."
    VerifyBtn.Text = "..."
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    
    local valid, res = cekWhitelist()
    
    if valid then
        userData.isWhitelisted = true
        userData.discordUser = res
        Subtitle.Text = res
        
        VerifyStatus.Text = "✅ Verified!"
        VerifyBtn.Text = "✓ DONE"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
        notif("✅ Whitelist verified!", true)
        
        -- Sembunyikan verify frame, tampilkan main GUI
        task.wait(0.5)
        VerifyFrame.Visible = false
        MainContent.Visible = true
        
        -- Panggil fungsi setup main GUI
        setupMainGUI()
        
    else
        VerifyStatus.Text = "❌ " .. res
        VerifyBtn.Text = "VERIFY"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 140)
        notif("❌ " .. res, false)
    end
end)

-- =========================
-- SETUP MAIN GUI (setelah verifikasi)
-- =========================
function setupMainGUI()
    -- =========================
    -- LIVE MATCH VIEW
    -- =========================
    local LiveFrame = Instance.new("Frame")
    LiveFrame.Parent = MainContent
    LiveFrame.Size = UDim2.new(1, 0, 0, 110)
    LiveFrame.Position = UDim2.new(0, 0, 0, 0)
    LiveFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 35)

    local LiveCorner = Instance.new("UICorner")
    LiveCorner.CornerRadius = UDim.new(0, 8)
    LiveCorner.Parent = LiveFrame

    -- Player 1
    local Player1Box = Instance.new("Frame")
    Player1Box.Parent = LiveFrame
    Player1Box.Size = UDim2.new(0.5, -15, 0, 70)
    Player1Box.Position = UDim2.new(0, 10, 0, 10)
    Player1Box.BackgroundColor3 = Color3.fromRGB(35, 37, 45)

    local Player1Corner = Instance.new("UICorner")
    Player1Corner.CornerRadius = UDim.new(0, 6)
    Player1Corner.Parent = Player1Box

    local Player1Name = Instance.new("TextLabel")
    Player1Name.Parent = Player1Box
    Player1Name.Size = UDim2.new(1, 0, 0, 25)
    Player1Name.Position = UDim2.new(0, 5, 0, 5)
    Player1Name.BackgroundTransparency = 1
    Player1Name.Text = "Menunggu..."
    Player1Name.Font = Enum.Font.GothamBold
    Player1Name.TextSize = 14
    Player1Name.TextColor3 = Color3.fromRGB(255, 255, 255)

    local Player1Score = Instance.new("TextLabel")
    Player1Score.Parent = Player1Box
    Player1Score.Size = UDim2.new(1, 0, 0, 25)
    Player1Score.Position = UDim2.new(0, 5, 0, 35)
    Player1Score.BackgroundTransparency = 1
    Player1Score.Text = "0"
    Player1Score.Font = Enum.Font.GothamBold
    Player1Score.TextSize = 20
    Player1Score.TextColor3 = Color3.fromRGB(255, 80, 140)

    -- Player 2
    local Player2Box = Instance.new("Frame")
    Player2Box.Parent = LiveFrame
    Player2Box.Size = UDim2.new(0.5, -15, 0, 70)
    Player2Box.Position = UDim2.new(0.5, 5, 0, 10)
    Player2Box.BackgroundColor3 = Color3.fromRGB(35, 37, 45)

    local Player2Corner = Instance.new("UICorner")
    Player2Corner.CornerRadius = UDim.new(0, 6)
    Player2Corner.Parent = Player2Box

    local Player2Name = Instance.new("TextLabel")
    Player2Name.Parent = Player2Box
    Player2Name.Size = UDim2.new(1, 0, 0, 25)
    Player2Name.Position = UDim2.new(0, 5, 0, 5)
    Player2Name.BackgroundTransparency = 1
    Player2Name.Text = "Menunggu..."
    Player2Name.Font = Enum.Font.GothamBold
    Player2Name.TextSize = 14
    Player2Name.TextColor3 = Color3.fromRGB(255, 255, 255)

    local Player2Score = Instance.new("TextLabel")
    Player2Score.Parent = Player2Box
    Player2Score.Size = UDim2.new(1, 0, 0, 25)
    Player2Score.Position = UDim2.new(0, 5, 0, 35)
    Player2Score.BackgroundTransparency = 1
    Player2Score.Text = "0"
    Player2Score.Font = Enum.Font.GothamBold
    Player2Score.TextSize = 20
    Player2Score.TextColor3 = Color3.fromRGB(255, 80, 140)

    -- Status Match
    local MatchStatus2 = Instance.new("TextLabel")
    MatchStatus2.Parent = LiveFrame
    MatchStatus2.Size = UDim2.new(1, -20, 0, 20)
    MatchStatus2.Position = UDim2.new(0, 10, 0, 85)
    MatchStatus2.BackgroundTransparency = 1
    MatchStatus2.Text = "🔴 Tidak dalam match"
    MatchStatus2.Font = Enum.Font.Gotham
    MatchStatus2.TextSize = 12
    MatchStatus2.TextColor3 = Color3.fromRGB(180, 180, 180)

    -- =========================
    -- TAB BUTTONS
    -- =========================
    local TabFrame = Instance.new("Frame")
    TabFrame.Parent = MainContent
    TabFrame.Size = UDim2.new(1, 0, 0, 35)
    TabFrame.Position = UDim2.new(0, 0, 0, 120)
    TabFrame.BackgroundTransparency = 1

    local Tabs = {"🏠", "⚙️", "📋", "ℹ️"}
    local TabButtons = {}
    local TabContents = {}

    for i, tabName in ipairs(Tabs) do
        local btn = Instance.new("TextButton")
        btn.Parent = TabFrame
        btn.Size = UDim2.new(0.25, -2, 1, 0)
        btn.Position = UDim2.new(0.25 * (i-1), 1, 0, 0)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 80, 140) or Color3.fromRGB(35, 35, 45)
        btn.Text = tabName
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        TabButtons[i] = btn
    end

    -- Container for tab content
    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = MainContent
    TabContainer.Size = UDim2.new(1, 0, 1, -165)
    TabContainer.Position = UDim2.new(0, 0, 0, 160)
    TabContainer.BackgroundTransparency = 1

    -- =========================
    -- HOME TAB
    -- =========================
    local HomeTab = Instance.new("Frame")
    HomeTab.Parent = TabContainer
    HomeTab.Size = UDim2.new(1, 0, 1, 0)
    HomeTab.BackgroundTransparency = 1
    TabContents["🏠"] = HomeTab

    -- Profile Card
    local ProfileCard = Instance.new("Frame")
    ProfileCard.Parent = HomeTab
    ProfileCard.Size = UDim2.new(1, 0, 0, 70)
    ProfileCard.BackgroundColor3 = Color3.fromRGB(25, 27, 35)

    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 8)
    ProfileCorner.Parent = ProfileCard

    local HomeAvatar = Instance.new("ImageLabel")
    HomeAvatar.Parent = ProfileCard
    HomeAvatar.Size = UDim2.new(0, 50, 0, 50)
    HomeAvatar.Position = UDim2.new(0, 10, 0.5, -25)
    HomeAvatar.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
    HomeAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"

    local HomeAvatarCorner = Instance.new("UICorner")
    HomeAvatarCorner.CornerRadius = UDim.new(0, 25)
    HomeAvatarCorner.Parent = HomeAvatar

    local HomeName = Instance.new("TextLabel")
    HomeName.Parent = ProfileCard
    HomeName.Size = UDim2.new(0, 200, 0, 22)
    HomeName.Position = UDim2.new(0, 70, 0, 15)
    HomeName.BackgroundTransparency = 1
    HomeName.Text = LocalPlayer.Name
    HomeName.Font = Enum.Font.GothamBold
    HomeName.TextSize = 15
    HomeName.TextColor3 = Color3.fromRGB(255, 255, 255)
    HomeName.TextXAlignment = Enum.TextXAlignment.Left

    local HomeDiscord = Instance.new("TextLabel")
    HomeDiscord.Parent = ProfileCard
    HomeDiscord.Size = UDim2.new(0, 200, 0, 18)
    HomeDiscord.Position = UDim2.new(0, 70, 0, 40)
    HomeDiscord.BackgroundTransparency = 1
    HomeDiscord.Text = "💬 " .. userData.discordUser
    HomeDiscord.Font = Enum.Font.Gotham
    HomeDiscord.TextSize = 12
    HomeDiscord.TextColor3 = Color3.fromRGB(180, 180, 180)
    HomeDiscord.TextXAlignment = Enum.TextXAlignment.Left

    -- Status Card
    local HomeStatus = Instance.new("Frame")
    HomeStatus.Parent = HomeTab
    HomeStatus.Size = UDim2.new(1, 0, 0, 80)
    HomeStatus.Position = UDim2.new(0, 0, 0, 80)
    HomeStatus.BackgroundColor3 = Color3.fromRGB(25, 27, 35)

    local HomeStatusCorner = Instance.new("UICorner")
    HomeStatusCorner.CornerRadius = UDim.new(0, 8)
    HomeStatusCorner.Parent = HomeStatus

    local function createStatusRow(parent, y, label, default)
        local lbl = Instance.new("TextLabel")
        lbl.Parent = parent
        lbl.Size = UDim2.new(0, 70, 0, 20)
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
        val.Position = UDim2.new(0, 90, 0, y)
        val.BackgroundTransparency = 1
        val.Text = default
        val.Font = Enum.Font.GothamBold
        val.TextSize = 12
        val.TextColor3 = Color3.fromRGB(255, 255, 255)
        val.TextXAlignment = Enum.TextXAlignment.Left
        
        return val
    end

    local HomeMatch = createStatusRow(HomeStatus, 10, "Match:", "🔴 Waiting")
    local HomeTurn = createStatusRow(HomeStatus, 35, "Turn:", "⏳ -")
    local HomeWord = createStatusRow(HomeStatus, 60, "Word:", "📝 -")

    -- =========================
    -- AUTO TAB
    -- =========================
    local AutoTab = Instance.new("Frame")
    AutoTab.Parent = TabContainer
    AutoTab.Size = UDim2.new(1, 0, 1, 0)
    AutoTab.BackgroundTransparency = 1
    AutoTab.Visible = false
    TabContents["⚙️"] = AutoTab

    -- Auto Toggle
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = AutoTab
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 35)

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
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

    -- Sliders
    local function createSlider(parent, name, min, max, default, y, callback)
        local label = Instance.new("TextLabel")
        label.Parent = parent
        label.Size = UDim2.new(0, 150, 0, 20)
        label.Position = UDim2.new(0, 10, 0, y)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. default
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextColor3 = Color3.fromRGB(150, 150, 150)
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Parent = parent
        sliderBg.Size = UDim2.new(0, 200, 0, 6)
        sliderBg.Position = UDim2.new(0, 10, 0, y + 18)
        sliderBg.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
        
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
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        
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
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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

    createSlider(AutoTab, "Agresivitas", 0, 100, config.aggression, 55, function(v) config.aggression = v end)
    createSlider(AutoTab, "Min Delay", 50, 500, config.minDelay, 110, function(v) config.minDelay = v end)
    createSlider(AutoTab, "Max Delay", 200, 1500, config.maxDelay, 165, function(v) config.maxDelay = v end)
    createSlider(AutoTab, "Min Panjang", 1, 3, config.minLength, 220, function(v) config.minLength = v end)
    createSlider(AutoTab, "Max Panjang", 5, 20, config.maxLength, 275, function(v) config.maxLength = v end)

    -- =========================
    -- WORDS TAB
    -- =========================
    local WordsTab = Instance.new("Frame")
    WordsTab.Parent = TabContainer
    WordsTab.Size = UDim2.new(1, 0, 1, 0)
    WordsTab.BackgroundTransparency = 1
    WordsTab.Visible = false
    TabContents["📋"] = WordsTab

    local WordsBox = Instance.new("Frame")
    WordsBox.Parent = WordsTab
    WordsBox.Size = UDim2.new(1, 0, 0, 150)
    WordsBox.BackgroundColor3 = Color3.fromRGB(25, 27, 35)

    local WordsCorner = Instance.new("UICorner")
    WordsCorner.CornerRadius = UDim.new(0, 8)
    WordsCorner.Parent = WordsBox

    local WordsList = Instance.new("TextLabel")
    WordsList.Parent = WordsBox
    WordsList.Size = UDim2.new(1, -20, 1, -20)
    WordsList.Position = UDim2.new(0, 10, 0, 10)
    WordsList.BackgroundTransparency = 1
    WordsList.Text = "📋 Belum ada kata terpakai"
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
    ResetBtn.Text = "🔄 Reset Kata Terpakai"
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.TextSize = 12
    ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 8)
    ResetCorner.Parent = ResetBtn

    ResetBtn.MouseButton1Click:Connect(function()
        resetUsedWords()
        WordsList.Text = "📋 Belum ada kata terpakai"
    end)

    -- =========================
    -- INFO TAB
    -- =========================
    local InfoTab = Instance.new("Frame")
    InfoTab.Parent = TabContainer
    InfoTab.Size = UDim2.new(1, 0, 1, 0)
    InfoTab.BackgroundTransparency = 1
    InfoTab.Visible = false
    TabContents["ℹ️"] = InfoTab

    local InfoBox = Instance.new("Frame")
    InfoBox.Parent = InfoTab
    InfoBox.Size = UDim2.new(1, 0, 0, 220)
    InfoBox.BackgroundColor3 = Color3.fromRGB(25, 27, 35)

    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 8)
    InfoCorner.Parent = InfoBox

    local InfoText = Instance.new("TextLabel")
    InfoText.Parent = InfoBox
    InfoText.Size = UDim2.new(1, -20, 1, -20)
    InfoText.Position = UDim2.new(0, 10, 0, 10)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = string.format(
[[✨ LYORA SAMBUNG KATA
━━━━━━━━━━━━━━━━━━
Version   : 3.0
Author    : sazaraaax
Wordlist  : %d kata

👤 Roblox   : %s
💬 Discord  : %s
📊 Status   : ✅ Whitelisted

⚡ FITUR:
• Auto Farm dengan AI
• Real-time match view
• Filter panjang kata
• Anti kata berulang
• 4 Tab menu
• Minimizable GUI

📌 CARA PAKAI:
1. Verifikasi whitelist
2. Aktifkan Auto Farm
3. Atur agresivitas
4. Pantau di Live Match
]], #kataModule, LocalPlayer.Name, userData.discordUser)
    InfoText.Font = Enum.Font.Gotham
    InfoText.TextSize = 12
    InfoText.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoText.TextXAlignment = Enum.TextXAlignment.Left
    InfoText.TextYAlignment = Enum.TextYAlignment.Top

    -- =========================
    -- TAB NAVIGATION
    -- =========================
    for i, btn in ipairs(TabButtons) do
        btn.MouseButton1Click:Connect(function()
            for _, b in ipairs(TabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            end
            btn.BackgroundColor3 = Color3.fromRGB(255, 80, 140)
            
            for name, frame in pairs(TabContents) do
                frame.Visible = false
            end
            TabContents[btn.Text].Visible = true
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
            MatchStatus2.Text = "🟢 Dalam Match"
            HomeMatch.Text = "🟢 In Game"
        elseif cmd == "HideMatchUI" then
            matchActive = false
            isMyTurn = false
            serverLetter = ""
            resetUsedWords()
            MatchStatus2.Text = "🔴 Tidak dalam match"
            HomeMatch.Text = "🔴 Waiting"
            HomeTurn.Text = "⏳ -"
            HomeWord.Text = "📝 -"
        elseif cmd == "StartTurn" then
            isMyTurn = true
            HomeTurn.Text = "🎯 Your Turn"
            if autoEnabled then startUltraAI() end
        elseif cmd == "EndTurn" then
            isMyTurn = false
            HomeTurn.Text = "⏳ Opponent"
        elseif cmd == "UpdateServerLetter" then
            serverLetter = value or ""
            HomeWord.Text = "📝 " .. serverLetter
        end
    end)

    UsedWordWarn.OnClientEvent:Connect(function(word)
        if word then
            addUsedWord(word)
            local display = "📋 Kata terpakai:\n"
            for i, w in ipairs(usedWordsList) do
                display = display .. w
                if i < #usedWordsList then display = display .. ", " end
                if i % 5 == 0 then display = display .. "\n" end
            end
            WordsList.Text = display
            if autoEnabled and matchActive and isMyTurn then
                humanDelay()
                startUltraAI()
            end
        end
    end)
end

-- =========================
-- KEYBIND
-- =========================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- =========================
-- FINISH
-- =========================
print("✅ LYORA ALL IN ONE LOADED")