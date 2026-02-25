-- =========================================================
-- ULTRA SMART AUTO KATA + CUSTOM GUI + PASTEFY KEY SYSTEM
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
-- PASTEFY KEY SYSTEM
-- =========================
local PASTE_ID = "EvFSBcDy"  -- << GANTI DENGAN ID PASTE LU!
local DISCORD_INVITE = "cvaHe2rXnk"  -- GANTI DENGAN INVITE DISCORD LU

local userData = {
    userId = tostring(LocalPlayer.UserId),
    username = LocalPlayer.Name,
    key = "",
    isVerified = false,
    discordUser = "",
    role = "user",
    premium = false
}

local function verifyKey(key)
    if not key:match("^LYORA%-%w%w%w%w%-%w%w%w%w$") then
        return { valid = false, message = "❌ Format key salah! Harus LYORA-XXXX-XXXX" }
    end
    
    local success, response = pcall(function()
        return game:HttpGet("https://pastefy.app/raw/" .. PASTE_ID)
    end)
    
    if not success then
        return { valid = false, message = "❌ Gagal memuat database key" }
    end
    
    local db = HttpService:JSONDecode(response)
    local keyData = db.keys and db.keys[key]
    
    if not keyData then
        return { valid = false, message = "❌ Key tidak terdaftar!" }
    end
    
    if os.time() * 1000 > keyData.expiresAt then
        return { valid = false, message = "⏰ Key sudah expired! (3 jam)" }
    end
    
    if keyData.userId ~= userData.userId then
        return { valid = false, message = "❌ User ID tidak cocok!" }
    end
    
    if keyData.used then
        return { valid = false, message = "❌ Key sudah digunakan!" }
    end
    
    return {
        valid = true,
        discordUser = keyData.discordUser,
        expiresAt = keyData.expiresAt,
        message = "✅ Selamat datang " .. keyData.discordUser .. "!"
    }
end

-- =========================
-- CREATE KEY GUI
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "LyoraGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Parent = MainFrame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ZIndex = -1

-- HEADER
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔐 LYORA KEY SYSTEM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
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
CloseBtn.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -90, 0.5, -17.5)
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 25
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BorderSizePixel = 0

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

-- CONTENT FRAME
local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -20, 1, -70)
ContentFrame.Position = UDim2.new(0, 10, 0, 60)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- MINIMIZE FUNCTION
local minimized = false
local originalSize = MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 450, 0, 50), "Out", "Quad", 0.2, true)
        ContentFrame.Visible = false
        MinBtn.Text = "□"
        MinBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    else
        MainFrame:TweenSize(originalSize, "Out", "Quad", 0.2, true)
        task.wait(0.2)
        ContentFrame.Visible = true
        MinBtn.Text = "—"
        MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
end)

-- AVATAR SECTION
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Parent = ContentFrame
AvatarFrame.Size = UDim2.new(1, -20, 0, 80)
AvatarFrame.Position = UDim2.new(0, 10, 0, 10)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
AvatarFrame.BorderSizePixel = 0

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 8)
AvatarCorner.Parent = AvatarFrame

-- Avatar Image
local Avatar = Instance.new("ImageLabel")
Avatar.Parent = AvatarFrame
Avatar.Size = UDim2.new(0, 60, 0, 60)
Avatar.Position = UDim2.new(0, 10, 0.5, -30)
Avatar.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"

local AvatarImgCorner = Instance.new("UICorner")
AvatarImgCorner.CornerRadius = UDim.new(0, 30)
AvatarImgCorner.Parent = Avatar

-- Username
local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Parent = AvatarFrame
UsernameLabel.Size = UDim2.new(0, 250, 0, 30)
UsernameLabel.Position = UDim2.new(0, 80, 0, 15)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = LocalPlayer.Name
UsernameLabel.Font = Enum.Font.GothamBold
UsernameLabel.TextSize = 20
UsernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- User ID
local UserIdLabel = Instance.new("TextLabel")
UserIdLabel.Parent = AvatarFrame
UserIdLabel.Size = UDim2.new(0, 250, 0, 20)
UserIdLabel.Position = UDim2.new(0, 80, 0, 45)
UserIdLabel.BackgroundTransparency = 1
UserIdLabel.Text = "ID: " .. LocalPlayer.UserId
UserIdLabel.Font = Enum.Font.Gotham
UserIdLabel.TextSize = 14
UserIdLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
UserIdLabel.TextXAlignment = Enum.TextXAlignment.Left

-- KEY INPUT SECTION
local KeyFrame = Instance.new("Frame")
KeyFrame.Parent = ContentFrame
KeyFrame.Size = UDim2.new(1, -20, 0, 180)
KeyFrame.Position = UDim2.new(0, 10, 0, 100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
KeyFrame.BorderSizePixel = 0

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 8)
KeyCorner.Parent = KeyFrame

-- Key Title
local KeyTitle = Instance.new("TextLabel")
KeyTitle.Parent = KeyFrame
KeyTitle.Size = UDim2.new(1, -20, 0, 30)
KeyTitle.Position = UDim2.new(0, 10, 0, 10)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "🔑 VERIFIKASI KEY"
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 16
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Key Description
local KeyDesc = Instance.new("TextLabel")
KeyDesc.Parent = KeyFrame
KeyDesc.Size = UDim2.new(1, -20, 0, 40)
KeyDesc.Position = UDim2.new(0, 10, 0, 40)
KeyDesc.BackgroundTransparency = 1
KeyDesc.Text = "Masukkan key yang didapat dari Discord bot\nuntuk mengaktifkan script"
KeyDesc.Font = Enum.Font.Gotham
KeyDesc.TextSize = 12
KeyDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
KeyDesc.TextXAlignment = Enum.TextXAlignment.Left
KeyDesc.TextYAlignment = Enum.TextYAlignment.Top

-- Key Input Box
local KeyInputFrame = Instance.new("Frame")
KeyInputFrame.Parent = KeyFrame
KeyInputFrame.Size = UDim2.new(1, -20, 0, 40)
KeyInputFrame.Position = UDim2.new(0, 10, 0, 85)
KeyInputFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
KeyInputFrame.BorderSizePixel = 0

local KeyInputCorner = Instance.new("UICorner")
KeyInputCorner.CornerRadius = UDim.new(0, 6)
KeyInputCorner.Parent = KeyInputFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Parent = KeyInputFrame
KeyInput.Size = UDim2.new(1, -10, 1, 0)
KeyInput.Position = UDim2.new(0, 5, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.PlaceholderText = "Contoh: LYORA-XXXX-XXXX"
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.ClearTextOnFocus = false

-- Verify Button
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Parent = KeyFrame
VerifyBtn.Size = UDim2.new(1, -20, 0, 45)
VerifyBtn.Position = UDim2.new(0, 10, 0, 135)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
VerifyBtn.Text = "VERIFIKASI KEY"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 16
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.BorderSizePixel = 0

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 6)
VerifyCorner.Parent = VerifyBtn

-- DISCORD INFO SECTION
local DiscordFrame = Instance.new("Frame")
DiscordFrame.Parent = ContentFrame
DiscordFrame.Size = UDim2.new(1, -20, 0, 140)
DiscordFrame.Position = UDim2.new(0, 10, 0, 290)
DiscordFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
DiscordFrame.BorderSizePixel = 0

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 8)
DiscordCorner.Parent = DiscordFrame

-- Discord Title
local DiscordTitle = Instance.new("TextLabel")
DiscordTitle.Parent = DiscordFrame
DiscordTitle.Size = UDim2.new(1, -20, 0, 30)
DiscordTitle.Position = UDim2.new(0, 10, 0, 10)
DiscordTitle.BackgroundTransparency = 1
DiscordTitle.Text = "💬 BELUM PUNYA KEY?"
DiscordTitle.Font = Enum.Font.GothamBold
DiscordTitle.TextSize = 16
DiscordTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Instructions
local Instructions = Instance.new("TextLabel")
Instructions.Parent = DiscordFrame
Instructions.Size = UDim2.new(1, -20, 0, 50)
Instructions.Position = UDim2.new(0, 10, 0, 40)
Instructions.BackgroundTransparency = 1
Instructions.Text = "1. Buka Discord dan ketik /getkey " .. LocalPlayer.UserId .. "\n2. Copy key dari bot\n3. Masukkan key di atas"
Instructions.Font = Enum.Font.Gotham
Instructions.TextSize = 12
Instructions.TextColor3 = Color3.fromRGB(180, 180, 180)
Instructions.TextXAlignment = Enum.TextXAlignment.Left
Instructions.TextYAlignment = Enum.TextYAlignment.Top

-- Buttons
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Parent = DiscordFrame
ButtonFrame.Size = UDim2.new(1, -20, 0, 35)
ButtonFrame.Position = UDim2.new(0, 10, 0, 95)
ButtonFrame.BackgroundTransparency = 1

-- Copy ID Button
local CopyIdBtn = Instance.new("TextButton")
CopyIdBtn.Parent = ButtonFrame
CopyIdBtn.Size = UDim2.new(0, 120, 1, 0)
CopyIdBtn.Position = UDim2.new(0, 0, 0, 0)
CopyIdBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
CopyIdBtn.Text = "📋 Copy ID"
CopyIdBtn.Font = Enum.Font.GothamBold
CopyIdBtn.TextSize = 12
CopyIdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyIdBtn.BorderSizePixel = 0

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyIdBtn

-- Join Discord Button
local JoinBtn = Instance.new("TextButton")
JoinBtn.Parent = ButtonFrame
JoinBtn.Size = UDim2.new(0, 130, 1, 0)
JoinBtn.Position = UDim2.new(0, 130, 0, 0)
JoinBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
JoinBtn.Text = "🔗 Join Discord"
JoinBtn.Font = Enum.Font.GothamBold
JoinBtn.TextSize = 12
JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinBtn.BorderSizePixel = 0

local JoinCorner = Instance.new("UICorner")
JoinCorner.CornerRadius = UDim.new(0, 6)
JoinCorner.Parent = JoinBtn

-- STATUS LABEL
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = ContentFrame
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 440)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
StatusLabel.Text = "⏳ Masukkan key untuk verifikasi..."
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

-- NOTIFICATION FUNCTION
local function showNotification(message, isSuccess)
    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.5, -150, 0, 10)
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

-- VERIFY BUTTON FUNCTION
VerifyBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    if key == "" then
        showNotification("❌ Masukkan key terlebih dahulu!", false)
        return
    end
    
    StatusLabel.Text = "⏳ Memverifikasi key ke Pastefy..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local result = verifyKey(key)
    
    if result.valid then
        userData.isVerified = true
        userData.key = key
        userData.discordUser = result.discordUser
        
        StatusLabel.Text = "✅ " .. result.message
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        showNotification("✅ Verifikasi berhasil!", true)
        
        -- Hapus GUI key dan mulai main GUI
        task.wait(1)
        ScreenGui:Destroy()
        startMainGUI()
        
    else
        StatusLabel.Text = result.message
        StatusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
        showNotification(result.message, false)
    end
end)

-- BUTTON FUNCTIONS
CopyIdBtn.MouseButton1Click:Connect(function()
    setclipboard(userData.userId)
    showNotification("✅ User ID dicopy ke clipboard!", true)
end)

JoinBtn.MouseButton1Click:Connect(function()
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
-- MAIN GUI (CUSTOM DESIGN)
-- =========================
function startMainGUI()
    -- Bersihkan ScreenGui yang lama
    for _, child in ipairs(ScreenGui:GetChildren()) do
        child:Destroy()
    end
    
    -- Ganti title
    Title.Text = "🎀 LYORA SAMBUNG KATA"
    
    -- Recreate content frame untuk main GUI
    local MainContent = Instance.new("Frame")
    MainContent.Parent = ContentFrame
    MainContent.Size = UDim2.new(1, 0, 1, 0)
    MainContent.BackgroundTransparency = 1
    
    -- Profile Section
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Parent = MainContent
    ProfileFrame.Size = UDim2.new(1, -20, 0, 70)
    ProfileFrame.Position = UDim2.new(0, 10, 0, 10)
    ProfileFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    ProfileFrame.BorderSizePixel = 0
    
    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 8)
    ProfileCorner.Parent = ProfileFrame
    
    local AvatarSmall = Instance.new("ImageLabel")
    AvatarSmall.Parent = ProfileFrame
    AvatarSmall.Size = UDim2.new(0, 50, 0, 50)
    AvatarSmall.Position = UDim2.new(0, 10, 0.5, -25)
    AvatarSmall.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
    AvatarSmall.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
    
    local AvatarSmallCorner = Instance.new("UICorner")
    AvatarSmallCorner.CornerRadius = UDim.new(0, 25)
    AvatarSmallCorner.Parent = AvatarSmall
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Parent = ProfileFrame
    NameLabel.Size = UDim2.new(0, 200, 0, 25)
    NameLabel.Position = UDim2.new(0, 70, 0, 15)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = LocalPlayer.Name
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 18
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local DiscordName = Instance.new("TextLabel")
    DiscordName.Parent = ProfileFrame
    DiscordName.Size = UDim2.new(0, 200, 0, 20)
    DiscordName.Position = UDim2.new(0, 70, 0, 40)
    DiscordName.BackgroundTransparency = 1
    DiscordName.Text = "💬 " .. userData.discordUser
    DiscordName.Font = Enum.Font.Gotham
    DiscordName.TextSize = 12
    DiscordName.TextColor3 = Color3.fromRGB(180, 180, 180)
    DiscordName.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Auto Farm Section
    local AutoFrame = Instance.new("Frame")
    AutoFrame.Parent = MainContent
    AutoFrame.Size = UDim2.new(1, -20, 0, 180)
    AutoFrame.Position = UDim2.new(0, 10, 0, 90)
    AutoFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    AutoFrame.BorderSizePixel = 0
    
    local AutoCorner = Instance.new("UICorner")
    AutoCorner.CornerRadius = UDim.new(0, 8)
    AutoCorner.Parent = AutoFrame
    
    local AutoTitle = Instance.new("TextLabel")
    AutoTitle.Parent = AutoFrame
    AutoTitle.Size = UDim2.new(1, -20, 0, 30)
    AutoTitle.Position = UDim2.new(0, 10, 0, 10)
    AutoTitle.BackgroundTransparency = 1
    AutoTitle.Text = "⚡ AUTO FARM"
    AutoTitle.Font = Enum.Font.GothamBold
    AutoTitle.TextSize = 16
    AutoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Auto Toggle
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Parent = AutoFrame
    ToggleBg.Size = UDim2.new(0, 50, 0, 25)
    ToggleBg.Position = UDim2.new(1, -60, 0, 10)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleBg.BorderSizePixel = 0
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleBg
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Parent = ToggleBg
    ToggleCircle.Size = UDim2.new(0, 21, 0, 21)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -10.5)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    
    local ToggleCircleCorner = Instance.new("UICorner")
    ToggleCircleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCircleCorner.Parent = ToggleCircle
    
    local toggleState = false
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ToggleBg
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    
    ToggleBtn.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        if toggleState then
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
        label.TextSize = 12
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
        valueLabel.TextSize = 12
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
        
        return {label = label, fill = sliderFill, value = valueLabel}
    end
    
    -- Create sliders
    createSlider(AutoFrame, "Aggression", 0, 100, config.aggression, 50, function(v)
        config.aggression = v
    end)
    
    createSlider(AutoFrame, "Min Delay", 10, 500, config.minDelay, 80, function(v)
        config.minDelay = v
    end)
    
    createSlider(AutoFrame, "Max Delay", 100, 1500, config.maxDelay, 110, function(v)
        config.maxDelay = v
    end)
    
    createSlider(AutoFrame, "Min Length", 1, 3, config.minLength, 140, function(v)
        config.minLength = v
    end)
    
    -- Status Section
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Parent = MainContent
    StatusFrame.Size = UDim2.new(1, -20, 0, 120)
    StatusFrame.Position = UDim2.new(0, 10, 0, 280)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    StatusFrame.BorderSizePixel = 0
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusFrame
    
    local StatusTitle = Instance.new("TextLabel")
    StatusTitle.Parent = StatusFrame
    StatusTitle.Size = UDim2.new(1, -20, 0, 30)
    StatusTitle.Position = UDim2.new(0, 10, 0, 10)
    StatusTitle.BackgroundTransparency = 1
    StatusTitle.Text = "📊 STATUS GAME"
    StatusTitle.Font = Enum.Font.GothamBold
    StatusTitle.TextSize = 16
    StatusTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local MatchStatus = Instance.new("TextLabel")
    MatchStatus.Parent = StatusFrame
    MatchStatus.Size = UDim2.new(0.5, -15, 0, 25)
    MatchStatus.Position = UDim2.new(0, 10, 0, 45)
    MatchStatus.BackgroundTransparency = 1
    MatchStatus.Text = "🔴 Match: Waiting"
    MatchStatus.Font = Enum.Font.Gotham
    MatchStatus.TextSize = 13
    MatchStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    MatchStatus.TextXAlignment = Enum.TextXAlignment.Left
    
    local TurnStatus = Instance.new("TextLabel")
    TurnStatus.Parent = StatusFrame
    TurnStatus.Size = UDim2.new(0.5, -15, 0, 25)
    TurnStatus.Position = UDim2.new(0.5, 5, 0, 45)
    TurnStatus.BackgroundTransparency = 1
    TurnStatus.Text = "⏳ Turn: -"
    TurnStatus.Font = Enum.Font.Gotham
    TurnStatus.TextSize = 13
    TurnStatus.TextColor3 = Color3.fromRGB(255, 255, 0)
    TurnStatus.TextXAlignment = Enum.TextXAlignment.Left
    
    local CurrentWordLabel = Instance.new("TextLabel")
    CurrentWordLabel.Parent = StatusFrame
    CurrentWordLabel.Size = UDim2.new(0.5, -15, 0, 25)
    CurrentWordLabel.Position = UDim2.new(0, 10, 0, 75)
    CurrentWordLabel.BackgroundTransparency = 1
    CurrentWordLabel.Text = "📝 Word: -"
    CurrentWordLabel.Font = Enum.Font.Gotham
    CurrentWordLabel.TextSize = 13
    CurrentWordLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    CurrentWordLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local UsedCount = Instance.new("TextLabel")
    UsedCount.Parent = StatusFrame
    UsedCount.Size = UDim2.new(0.5, -15, 0, 25)
    UsedCount.Position = UDim2.new(0.5, 5, 0, 75)
    UsedCount.BackgroundTransparency = 1
    UsedCount.Text = "📋 Used: 0"
    UsedCount.Font = Enum.Font.Gotham
    UsedCount.TextSize = 13
    UsedCount.TextColor3 = Color3.fromRGB(180, 180, 180)
    UsedCount.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Remote event handlers
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
            CurrentWordLabel.Text = "📝 Word: -"
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
            CurrentWordLabel.Text = "📝 Word: " .. serverLetter
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
            UsedCount.Text = "📋 Used: " .. #usedWordsList
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
print("✅ LYORA CUSTOM GUI + PASTEFY KEY SYSTEM LOADED")
print("📌 PASTE ID: " .. PASTE_ID)
print("👤 User: " .. LocalPlayer.Name)
print("🔑 User ID: " .. LocalPlayer.UserId)