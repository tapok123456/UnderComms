--[[
    GlitchLab | UnderComms
    Shared Configuration
    
    v0.3.1 — TELEGRAPH & RADIO GLITCH
]]

GlitchLab = GlitchLab or {}
GlitchLab.Config = GlitchLab.Config or {}

-- ============================================
-- CHAT POSITION
-- ============================================

GlitchLab.Config.ChatX = 24
GlitchLab.Config.ChatY = 140
GlitchLab.Config.ChatWidth = 620
GlitchLab.Config.ChatHeight = 300

-- ============================================
-- TIMING
-- ============================================

GlitchLab.Config.MessageFadeTime = 10
GlitchLab.Config.FadeAnimDuration = 2
GlitchLab.Config.MaxMessages = 128

-- Base typewriter speed (will be adjusted by message length)
GlitchLab.Config.TypewriterSpeed = 60

-- Adaptive speed settings
GlitchLab.Config.MinSpeed = 15          -- minimum chars per second (for short messages)
GlitchLab.Config.MaxSpeed = 60          -- maximum chars per second (for long messages)
GlitchLab.Config.ShortMessageLength = 10 -- messages shorter than this get MinSpeed
GlitchLab.Config.LongMessageLength = 150 -- messages longer than this get MaxSpeed

-- ============================================
-- COLORS
-- ============================================

GlitchLab.Config.Colors = {
    Background      = Color(10, 10, 10, 230),
    Border          = Color(255, 255, 255, 255),
    BorderAccent    = Color(177, 102, 199, 255),
    Text            = Color(255, 255, 255, 255),
    TextShadow      = Color(0, 0, 0, 180),
    PlayerName      = Color(255, 255, 100, 255),
    ServerMsg       = Color(177, 102, 199, 255),
    ErrorMsg        = Color(255, 51, 51, 255),
    InputBg         = Color(20, 20, 20, 240),
    InputBorder     = Color(100, 100, 100, 255),
    InputText       = Color(255, 255, 255, 255),
    Timestamp       = Color(100, 100, 100, 180),
}

GlitchLab.Config.BorderThickness = 2

-- ============================================
-- FONTS
-- ============================================

GlitchLab.Config.FontName = "GlitchLab_Main"
GlitchLab.Config.FontNameSmall = "GlitchLab_Small"
GlitchLab.Config.FontNameInput = "GlitchLab_Input"

-- Font sizes (adjust for different fonts)
GlitchLab.Config.FontSize = 16        -- Main text
GlitchLab.Config.FontSizeSmall = 12   -- Timestamps
GlitchLab.Config.FontSizeInput = 16   -- Input field

-- If you want to force a specific font (bypasses auto-detection)
-- GlitchLab.Config.ForceFont = "Press Start 2P"

-- ============================================
-- MESSAGE STYLES
-- ============================================

GlitchLab.Config.Styles = {
    -- Direct (default, normal chat)
    direct = {
        prefix = "/d",
        name = "Direct",
        textColor = Color(255, 255, 255),
        nameColor = nil,
        speedMult = 1.0,
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        format = function(sender, text) 
            return sender, text 
        end,
        -- Proximity settings
        proximity = true,           -- uses distance check
        hearDistance = 600,         -- units (roughly 6 meters)
        fadeDistance = 800,         -- starts fading after this
    },

    -- Letter — handwritten note with paper texture (GLOBAL)
    letter = {
        prefix = "/l",
        name = "Letter",
        textColor = Color(60, 40, 30),
        nameColor = Color(80, 50, 40),
        speedMult = 0.5,
        pitchMin = 70,
        pitchMax = 90,
        volume = 0.2,
        icon = "✉",
        format = function(sender, text)
            return "From: " .. sender, text
        end,
        letter = true,
        paperBackground = true,
        noColon = true,
        -- Proximity: GLOBAL
        proximity = false,
        global = true,
    },
    
    -- Telegraph — chunks appear with morse beeps (GLOBAL)
    telegraph = {
        prefix = "/t",
        name = "Telegraph",
        textColor = Color(255, 220, 150),
        nameColor = Color(200, 180, 100),
        speedMult = 0.8,
        pitchMin = 60,
        pitchMax = 100,
        volume = 0.3,
        icon = "",  -- or sprite later
        format = function(sender, text)
            return ">> " .. sender, string.upper(text or "") .. " STOP"
        end,
        telegraph = true,
        chunkSize = 3,
        chunkDelay = 0.15,
        -- Proximity: GLOBAL (long range communication)
        proximity = false,
        global = true,
    },
    
    -- Radio — with glitches and static (GLOBAL)
    radio = {
        prefix = "/r",
        name = "Radio",
        textColor = Color(80, 255, 80),
        nameColor = Color(60, 200, 60),
        speedMult = 1.2,
        pitchMin = 85,
        pitchMax = 95,
        volume = 0.35,
        icon = "",  -- or sprite later
        format = function(sender, text)
            return "[RADIO] " .. sender, text
        end,
        radio = true,
        glitchChance = 0.15,
        glitchDuration = 0.5,
        staticChars = {"#", "@", "!", "%", "&", "?", "/", "\\", "|", "~", "^"},
        -- Proximity: GLOBAL (long range communication)
        proximity = false,
        global = true,
    },
    
    -- Whisper (very short range)
    whisper = {
        prefix = "/w",
        name = "Whisper",
        textColor = Color(180, 180, 180, 200),
        nameColor = Color(150, 150, 150),
        speedMult = 0.6,
        pitchMin = 60,
        pitchMax = 80,
        volume = 0.15,
        icon = "",
        format = function(sender, text)
            return sender, text
        end,
        -- Proximity: VERY SHORT
        proximity = true,
        hearDistance = 150,         -- whisper range
        fadeDistance = 200,
    },
    
    -- Yell / Shout (long range local)
    yell = {
        prefix = "/y",
        name = "Yell",
        textColor = Color(255, 100, 100),
        nameColor = Color(255, 80, 80),
        speedMult = 1.5,
        pitchMin = 120,
        pitchMax = 140,
        volume = 0.5,
        icon = "",
        format = function(sender, text)
            return sender, string.upper(text or "")
        end,
        -- Proximity: LONG but still local
        proximity = true,
        hearDistance = 1200,        -- yelling range
        fadeDistance = 1500,
    },
    
    -- Action / Me (same as direct)
    action = {
        prefix = "/me",
        name = "Action",
        textColor = Color(255, 180, 100),
        nameColor = Color(255, 180, 100),
        speedMult = 0.8,
        pitchMin = 85,
        pitchMax = 100,
        volume = 0.25,
        format = function(sender, text)
            return "* " .. sender, string.lower(text or "")
        end,
        noColon = true,
        -- Proximity: same as direct
        proximity = true,
        hearDistance = 600,
        fadeDistance = 800,
    },
    
    -- OOC (GLOBAL - out of character)
    ooc = {
        prefix = "/ooc",
        altPrefix = "//",
        name = "OOC",
        textColor = Color(150, 150, 150),
        nameColor = Color(120, 120, 120),
        speedMult = 1.5,
        pitchMin = 0,
        pitchMax = 0,
        volume = 0,
        format = function(sender, text)
            return "[OOC] " .. sender, text
        end,
        -- Proximity: GLOBAL (OOC is always global)
        proximity = false,
        global = true,
    },
    
    -- Local OOC (short range OOC)
    looc = {
        prefix = "/looc",
        altPrefix = ".//",
        name = "LOOC",
        textColor = Color(150, 150, 150),
        nameColor = Color(120, 120, 120),
        speedMult = 1.5,
        pitchMin = 0,
        pitchMax = 0,
        volume = 0,
        format = function(sender, text)
            return "[LOOC] " .. sender, text
        end,
        -- Proximity: LOCAL OOC
        proximity = true,
        hearDistance = 400,
        fadeDistance = 500,
    },
}

-- ============================================
-- PROXIMITY SETTINGS
-- ============================================

GlitchLab.Config.Proximity = {
    Enabled = true,                  -- master toggle
    DefaultDistance = 600,           -- default hear distance
    FadeEnabled = true,              -- fade text alpha by distance
    ShowOutOfRange = false,          -- show "[too far]" indicator
    DeadCanHearAll = true,           -- dead players hear everything
    AdminCanHearAll = false,          -- admins hear everything
}

-- ============================================
-- NETWORK
-- ============================================

GlitchLab.Config.NetStrings = {
    SendMessage     = "GlitchLab_SendMsg",
    ReceiveMessage  = "GlitchLab_RecvMsg",
}

GlitchLab.Config.MaxMessageLength = 4096

-- ============================================
-- LOGGING
-- ============================================

GlitchLab.Config.EnableLogging = true
GlitchLab.Config.LogPath = "glitchlab/logs/"

-- ============================================
-- DEBUG
-- ============================================

GlitchLab.Config.DebugMode = true

-- ============================================
-- SECURITY: Allowed URL Domains
-- ============================================

GlitchLab.Config.AllowedDomains = {
    -- Image hosting
    "imgur.com",
    "i.imgur.com",
    "gyazo.com",
    "prnt.sc",
    "prntscr.com",
    
    -- Steam
    "steamcommunity.com",
    "steampowered.com",
    "steamstatic.com",
    
    -- Discord
    "discord.com",
    "discord.gg",
    "cdn.discordapp.com",
    "media.discordapp.net",
    
    -- Video
    "youtube.com",
    "youtu.be",
    "twitch.tv",
    
    -- Dev / Code
    "github.com",
    "githubusercontent.com",
    "gitlab.com",
    "gist.github.com",
    
    -- GMod related
    "facepunch.com",
    "gmodstore.com",
    "scriptfodder.com",
    
    -- Other common
    "reddit.com",
    "i.redd.it",
    "twitter.com",
    "x.com",
}

-- Set to false to allow ALL domains (not recommended)
GlitchLab.Config.EnforceWhitelist = true

-- ============================================
-- VOICE SYSTEM CONFIG
-- ============================================

GlitchLab.Config.Voice = {
    -- Enable/disable voice system
    Enabled = true,
    
    -- Default voice for new players
    DefaultVoice = "default",
    
    -- Allow custom pitch/volume adjustments
    AllowPitchAdjust = true,
    AllowVolumeAdjust = true,
    
    -- Pitch adjustment limits
    PitchMin = -50,
    PitchMax = 50,
    
    -- Volume adjustment limits
    VolumeMin = -0.3,
    VolumeMax = 0.3,
    
    -- Sync voices to other players
    SyncEnabled = true,
    
    -- Categories shown in menu
    EnabledCategories = {
        "Classic",
        "Deltarune",
        "Special",
        "Meme",
    },
}

-- Network strings for voice system
GlitchLab.Config.NetStrings.VoiceUpdate = "GlitchLab_VoiceUpdate"
GlitchLab.Config.NetStrings.VoiceSync = "GlitchLab_VoiceSync"
GlitchLab.Config.NetStrings.VoiceRequest = "GlitchLab_VoiceRequest"