-- =========================================================
-- LYORA VERIFICATION SYSTEM (RAYFIELD)
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Config
local WHITELIST_URL = "https://pastefy.app/EvFSBcDy/raw"
local DISCORD_INVITE = "cvaHe2rXnk"
local CHEAT_SCRIPT_URL = "https://pastebin.com/raw/XXXXXXXX"  -- GANTI NANTI!

-- Data user
local userData = {
    userId = tostring(LocalPlayer.UserId),
    username = LocalPlayer.Name,
    displayName = LocalPlayer.DisplayName,
    isWhitelisted = false,
    discordUser = "",
    whitelistExpiry = 0
}

-- Fungsi cek whitelist
local function checkWhitelist()
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

-- Buat Window Verifikasi
local Window = Rayfield:CreateWindow({
    Name = "LYORA VERIFICATION",
    LoadingTitle = "Whitelist System",
    LoadingSubtitle = "by Lyora",
    ConfigurationSaving = { Enabled = false },
    Discord = {
        Enabled = true,
        Invite = DISCORD_INVITE,
        RememberJoins = true
    }
})

-- Tab Utama
local MainTab = Window:CreateTab("🔐 Verifikasi", "shield")

-- Profile Card
MainTab:CreateParagraph("👤 Profile", 
    string.format("Username: %s\nUser ID: %s\nDisplay Name: %s",
        LocalPlayer.Name,
        LocalPlayer.UserId,
        LocalPlayer.DisplayName
    )
)

-- Status
local StatusLabel = MainTab:CreateParagraph("📊 Status", "Menunggu verifikasi...")

-- Verify Button
MainTab:CreateButton({
    Name = "✅ VERIFIKASI WHITELIST",
    Callback = function()
        StatusLabel:Set("⏳ Memverifikasi...")
        
        local result = checkWhitelist()
        
        if result.valid then
            userData.isWhitelisted = true
            userData.discordUser = result.discordUser
            userData.whitelistExpiry = result.expiresAt
            
            StatusLabel:Set("✅ " .. result.message)
            
            Rayfield:Notify({
                Title = "Verifikasi Berhasil!",
                Content = "Selamat datang " .. result.discordUser,
                Duration = 3
            })
            
            -- Simpan data
            _G.LyoraUserData = userData
            
            -- Load cheat script
            task.wait(1)
            Window:Destroy()
            
            local cheatScript = game:HttpGet(CHEAT_SCRIPT_URL)
            if cheatScript then
                loadstring(cheatScript)()
            end
            
        else
            StatusLabel:Set("❌ " .. result.message)
            Rayfield:Notify({
                Title = "Verifikasi Gagal",
                Content = result.message,
                Duration = 3
            })
        end
    end
})

-- Info
MainTab:CreateParagraph("ℹ️ Info",
    "• Whitelist berlaku 7 jam\n" ..
    "• Dapatkan whitelist di Discord\n" ..
    "• Gunakan /whitelist di bot"
)

print("✅ VERIFICATION SYSTEM LOADED")