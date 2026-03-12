--[[
    GlitchLab | UnderComms — Theme System
    
    v0.6.1 — THEMES EDITION
    
    One file to rule them all, one file to style them,
    One file to bring them all and in the darkness bind them.
    
    "Your fashion sense fills you with DETERMINATION"
]]

GlitchLab.Themes = GlitchLab.Themes or {}
GlitchLab.Theme = GlitchLab.Theme or {}

local themes = GlitchLab.Themes

-- ============================================
-- THEME: Undertale Classic (Default)
-- ============================================

themes.undertale = {
    id = "undertale",
    name = "Undertale Classic",
    author = "GlitchLab",
    description = "The original. Black and white. Determined.",
    
    -- ===== CHAT BOX =====
    chatBg = Color(10, 10, 10, 230),
    chatBorder = Color(255, 255, 255),
    chatBorderThickness = 2,
    chatAccent = Color(177, 102, 199),     -- purple corners
    chatCornerSize = 6,                      -- corner accent size multiplier
    
    -- ===== TEXT =====
    textDefault = Color(255, 255, 255),
    textShadow = Color(0, 0, 0, 180),
    textShadowOffset = 1,
    textTimestamp = Color(100, 100, 100, 180),

    selectionHighlight = Color(177, 102, 199, 100),  -- purple highlight
    
    -- ===== PLAYER NAMES =====
    playerName = Color(255, 255, 100),       -- yellow
    playerNameShadow = Color(0, 0, 0, 180),
    
    -- ===== SYSTEM MESSAGES =====
    systemMsg = Color(177, 102, 199),
    errorMsg = Color(255, 51, 51),
    
    -- ===== INPUT FIELD =====
    inputBg = Color(20, 20, 20, 240),
    inputBorder = Color(100, 100, 100),
    inputText = Color(255, 255, 255),
    inputPlaceholder = Color(100, 100, 100),
    inputCursor = Color(177, 102, 199),
    inputHighlight = Color(177, 102, 199, 100),
    
    -- ===== DRAFT INDICATOR =====
    draftBg = Color(50, 15, 15, 200),
    draftBorder = Color(255, 60, 60),
    draftText = Color(255, 120, 120),
    draftTextLight = Color(255, 220, 220),
    
    -- ===== SCROLLBAR =====
    scrollBg = Color(30, 30, 30, 180),
    scrollGrip = Color(177, 102, 199),
    
    -- ===== LINKS =====
    linkColor = Color(100, 150, 255),
    linkHover = Color(150, 200, 255),
    linkUnderline = true,
    
    -- ===== TYPEWRITER CURSOR =====
    cursorColor = Color(177, 102, 199),
    cursorBlink = true,
    
    -- ===== EVENTS =====
    eventBg = Color(10, 10, 10, 240),
    eventBorder = Color(255, 255, 255),
    eventCornerSize = 12,
    
    eventTypes = {
        info = {
            border = Color(100, 150, 255),
            title = Color(100, 150, 255),
            text = Color(255, 255, 255),
            icon = "ℹ",
            shake = false,
            shakeIntensity = 0,
        },
        warning = {
            border = Color(255, 200, 50),
            title = Color(255, 200, 50),
            text = Color(255, 255, 255),
            icon = "⚠",
            shake = true,
            shakeIntensity = 3,
        },
        error = {
            border = Color(255, 50, 50),
            title = Color(255, 50, 50),
            text = Color(255, 200, 200),
            icon = "✖",
            shake = true,
            shakeIntensity = 6,
        },
        story = {
            border = Color(177, 102, 199),
            title = Color(177, 102, 199),
            text = Color(255, 255, 255),
            icon = "★",
            shake = false,
            shakeIntensity = 0,
        },
        success = {
            border = Color(50, 255, 100),
            title = Color(50, 255, 100),
            text = Color(255, 255, 255),
            icon = "✓",
            shake = false,
            shakeIntensity = 0,
        },
    },
    
    -- ===== SETTINGS MENU =====
    menuBg = Color(15, 15, 15, 250),
    menuBorder = Color(255, 255, 255),
    menuAccent = Color(177, 102, 199),
    menuText = Color(255, 255, 255),
    menuTextDim = Color(150, 150, 150),
    menuSection = Color(25, 25, 25, 200),
    menuSliderBg = Color(40, 40, 40),
    menuSliderFill = Color(177, 102, 199),
    menuCheckOn = Color(100, 255, 100),
    menuCheckOff = Color(100, 100, 100),
    menuButtonBg = Color(40, 40, 40),
    menuButtonHover = Color(60, 60, 60),
    
    -- ===== MESSAGE STYLES (colors for /r, /t, etc) =====
    styles = {
        direct = {
            text = Color(255, 255, 255),
            name = nil,  -- use default playerName
        },
        letter = {
            text = Color(50, 35, 25),
            name = Color(70, 45, 35),
        },
        telegraph = {
            text = Color(255, 220, 150),
            name = Color(200, 180, 100),
        },
        radio = {
            text = Color(80, 255, 80),
            name = Color(60, 200, 60),
            glitchChars = Color(80, 255, 80),
        },
        whisper = {
            text = Color(180, 180, 180, 200),
            name = Color(150, 150, 150),
        },
        yell = {
            text = Color(255, 100, 100),
            name = Color(255, 80, 80),
        },
        action = {
            text = Color(255, 180, 100),
            name = Color(255, 180, 100),
        },
        ooc = {
            text = Color(150, 150, 150),
            name = Color(120, 120, 120),
        },
        looc = {
            text = Color(150, 150, 150),
            name = Color(120, 120, 120),
        },
    },
    
    -- ===== SOUNDS (optional overrides) =====
    sounds = {
        blip = "voices/voice_asriel_hyperdeath.wav",
        -- radioBlip uses default
        -- morse uses default
    },
    
    -- ===== EFFECTS =====
    crtEffect = false,           -- scanlines
    crtIntensity = 0.1,
    glowEffect = false,
    glowColor = Color(177, 102, 199, 30),
}

-- ============================================
-- THEME: Deltarune Cyber
-- ============================================

themes.deltarune_cyber = {
    id = "deltarune_cyber",
    name = "Deltarune Cyber",
    author = "GlitchLab",
    description = "Neon lights in the Cyber World. Pink and cyan dreams.",
    
    chatBg = Color(5, 5, 25, 240),
    chatBorder = Color(0, 255, 255),
    chatBorderThickness = 2,
    chatAccent = Color(255, 0, 255),
    chatCornerSize = 8,
    
    textDefault = Color(255, 255, 255),
    textShadow = Color(0, 0, 0, 200),
    textShadowOffset = 1,
    textTimestamp = Color(0, 200, 200, 150),

    selectionHighlight = Color(177, 102, 199, 100),  -- purple highlight
    
    playerName = Color(255, 100, 255),
    playerNameShadow = Color(0, 0, 0, 180),
    
    systemMsg = Color(0, 255, 255),
    errorMsg = Color(255, 50, 100),
    
    inputBg = Color(10, 10, 30, 240),
    inputBorder = Color(0, 200, 200),
    inputText = Color(255, 255, 255),
    inputPlaceholder = Color(0, 150, 150),
    inputCursor = Color(255, 0, 255),
    inputHighlight = Color(255, 0, 255, 100),
    
    draftBg = Color(50, 10, 50, 200),
    draftBorder = Color(255, 50, 150),
    draftText = Color(255, 100, 200),
    draftTextLight = Color(255, 200, 255),
    
    scrollBg = Color(20, 20, 40, 180),
    scrollGrip = Color(255, 0, 255),
    
    linkColor = Color(0, 255, 255),
    linkHover = Color(150, 255, 255),
    linkUnderline = true,
    
    cursorColor = Color(0, 255, 255),
    cursorBlink = true,
    
    eventBg = Color(5, 5, 25, 245),
    eventBorder = Color(0, 255, 255),
    eventCornerSize = 12,
    
    eventTypes = {
        info = {
            border = Color(0, 200, 255),
            title = Color(0, 200, 255),
            text = Color(255, 255, 255),
            icon = "◆",
            shake = false,
            shakeIntensity = 0,
        },
        warning = {
            border = Color(255, 255, 0),
            title = Color(255, 255, 0),
            text = Color(255, 255, 200),
            icon = "◆",
            shake = true,
            shakeIntensity = 3,
        },
        error = {
            border = Color(255, 0, 100),
            title = Color(255, 0, 100),
            text = Color(255, 150, 200),
            icon = "◆",
            shake = true,
            shakeIntensity = 6,
        },
        story = {
            border = Color(255, 0, 255),
            title = Color(255, 0, 255),
            text = Color(255, 255, 255),
            icon = "♦",
            shake = false,
            shakeIntensity = 0,
        },
        success = {
            border = Color(0, 255, 150),
            title = Color(0, 255, 150),
            text = Color(255, 255, 255),
            icon = "◆",
            shake = false,
            shakeIntensity = 0,
        },
    },
    
    menuBg = Color(10, 10, 30, 250),
    menuBorder = Color(0, 255, 255),
    menuAccent = Color(255, 0, 255),
    menuText = Color(255, 255, 255),
    menuTextDim = Color(100, 150, 150),
    menuSection = Color(15, 15, 40, 200),
    menuSliderBg = Color(30, 30, 60),
    menuSliderFill = Color(255, 0, 255),
    menuCheckOn = Color(0, 255, 200),
    menuCheckOff = Color(80, 80, 100),
    menuButtonBg = Color(30, 30, 60),
    menuButtonHover = Color(50, 50, 80),
    
    styles = {
        direct = { text = Color(255, 255, 255), name = nil },
        telegraph = { text = Color(255, 255, 100), name = Color(200, 200, 50) },
        letter = {text = Color(50, 35, 25), name = Color(70, 45, 35) },
        radio = { text = Color(0, 255, 150), name = Color(0, 200, 100), glitchChars = Color(0, 255, 255) },
        whisper = { text = Color(150, 150, 200, 200), name = Color(120, 120, 180) },
        yell = { text = Color(255, 50, 150), name = Color(255, 0, 100) },
        action = { text = Color(255, 150, 255), name = Color(255, 150, 255) },
        ooc = { text = Color(100, 150, 150), name = Color(80, 120, 120) },
        looc = { text = Color(100, 150, 150), name = Color(80, 120, 120) },
    },
    
    sounds = {},
    
    crtEffect = true,
    crtIntensity = 0.05,
    glowEffect = true,
    glowColor = Color(0, 255, 255, 20),
}

-- ============================================
-- THEME: Terminal Green
-- ============================================

themes.terminal = {
    id = "terminal",
    name = "Classic Terminal",
    author = "GlitchLab",
    description = "Old school hacker vibes. Green on black.",
    
    chatBg = Color(0, 0, 0, 250),
    chatBorder = Color(0, 255, 0),
    chatBorderThickness = 1,
    chatAccent = Color(0, 255, 0),
    chatCornerSize = 4,
    
    textDefault = Color(0, 255, 0),
    textShadow = Color(0, 100, 0, 100),
    textShadowOffset = 1,
    textTimestamp = Color(0, 150, 0, 180),

    selectionHighlight = Color(177, 102, 199, 100),  -- purple highlight
    
    playerName = Color(0, 255, 100),
    playerNameShadow = Color(0, 50, 0, 150),
    
    systemMsg = Color(0, 200, 0),
    errorMsg = Color(255, 50, 50),
    
    inputBg = Color(0, 10, 0, 240),
    inputBorder = Color(0, 200, 0),
    inputText = Color(0, 255, 0),
    inputPlaceholder = Color(0, 100, 0),
    inputCursor = Color(0, 255, 0),
    inputHighlight = Color(0, 255, 0, 50),
    
    draftBg = Color(30, 10, 0, 200),
    draftBorder = Color(255, 100, 0),
    draftText = Color(255, 150, 0),
    draftTextLight = Color(255, 200, 100),
    
    scrollBg = Color(0, 30, 0, 180),
    scrollGrip = Color(0, 255, 0),
    
    linkColor = Color(100, 255, 100),
    linkHover = Color(150, 255, 150),
    linkUnderline = true,
    
    cursorColor = Color(0, 255, 0),
    cursorBlink = true,
    
    eventBg = Color(0, 0, 0, 250),
    eventBorder = Color(0, 255, 0),
    eventCornerSize = 8,
    
    eventTypes = {
        info = {
            border = Color(0, 200, 255),
            title = Color(0, 200, 255),
            text = Color(0, 255, 0),
            icon = ">",
            shake = false,
            shakeIntensity = 0,
        },
        warning = {
            border = Color(255, 255, 0),
            title = Color(255, 255, 0),
            text = Color(0, 255, 0),
            icon = "!",
            shake = true,
            shakeIntensity = 2,
        },
        error = {
            border = Color(255, 0, 0),
            title = Color(255, 0, 0),
            text = Color(255, 100, 100),
            icon = "X",
            shake = true,
            shakeIntensity = 4,
        },
        story = {
            border = Color(0, 255, 0),
            title = Color(0, 255, 0),
            text = Color(0, 255, 0),
            icon = "*",
            shake = false,
            shakeIntensity = 0,
        },
        success = {
            border = Color(0, 255, 100),
            title = Color(0, 255, 100),
            text = Color(0, 255, 0),
            icon = "+",
            shake = false,
            shakeIntensity = 0,
        },
    },
    
    menuBg = Color(0, 5, 0, 250),
    menuBorder = Color(0, 255, 0),
    menuAccent = Color(0, 255, 0),
    menuText = Color(0, 255, 0),
    menuTextDim = Color(0, 150, 0),
    menuSection = Color(0, 20, 0, 200),
    menuSliderBg = Color(0, 40, 0),
    menuSliderFill = Color(0, 255, 0),
    menuCheckOn = Color(0, 255, 0),
    menuCheckOff = Color(0, 80, 0),
    menuButtonBg = Color(0, 30, 0),
    menuButtonHover = Color(0, 50, 0),
    
    styles = {
        direct = { text = Color(0, 255, 0), name = nil },
        telegraph = { text = Color(200, 200, 0), name = Color(150, 150, 0) },
        letter = {text = Color(50, 35, 25), name = Color(70, 45, 35) },
        radio = { text = Color(0, 255, 100), name = Color(0, 200, 80), glitchChars = Color(0, 255, 0) },
        whisper = { text = Color(0, 150, 0, 200), name = Color(0, 120, 0) },
        yell = { text = Color(255, 100, 0), name = Color(255, 80, 0) },
        action = { text = Color(100, 255, 100), name = Color(100, 255, 100) },
        ooc = { text = Color(0, 120, 0), name = Color(0, 100, 0) },
        looc = { text = Color(0, 120, 0), name = Color(0, 100, 0) },
    },
    
    sounds = {},
    
    crtEffect = true,
    crtIntensity = 0.15,
    glowEffect = false,
    glowColor = Color(0, 255, 0, 20),
}

-- ============================================
-- THEME: Blood Red (Dark/Horror)
-- ============================================

themes.blood = {
    id = "blood",
    name = "Crimson Night",
    author = "GlitchLab",
    description = "For darker servers. Blood red aesthetic.",
    
    chatBg = Color(10, 5, 5, 240),
    chatBorder = Color(150, 0, 0),
    chatBorderThickness = 2,
    chatAccent = Color(255, 0, 0),
    chatCornerSize = 6,
    
    textDefault = Color(255, 220, 220),
    textShadow = Color(50, 0, 0, 180),
    textShadowOffset = 1,
    textTimestamp = Color(150, 80, 80, 180),

    selectionHighlight = Color(177, 102, 199, 100),  -- purple highlight
    
    playerName = Color(255, 100, 100),
    playerNameShadow = Color(50, 0, 0, 180),
    
    systemMsg = Color(255, 50, 50),
    errorMsg = Color(255, 0, 0),
    
    inputBg = Color(20, 10, 10, 240),
    inputBorder = Color(150, 50, 50),
    inputText = Color(255, 220, 220),
    inputPlaceholder = Color(120, 60, 60),
    inputCursor = Color(255, 0, 0),
    inputHighlight = Color(255, 0, 0, 80),
    
    draftBg = Color(60, 10, 10, 200),
    draftBorder = Color(255, 0, 0),
    draftText = Color(255, 100, 100),
    draftTextLight = Color(255, 180, 180),
    
    scrollBg = Color(40, 15, 15, 180),
    scrollGrip = Color(200, 0, 0),
    
    linkColor = Color(255, 150, 150),
    linkHover = Color(255, 200, 200),
    linkUnderline = true,
    
    cursorColor = Color(255, 0, 0),
    cursorBlink = true,
    
    eventBg = Color(15, 5, 5, 245),
    eventBorder = Color(200, 0, 0),
    eventCornerSize = 10,
    
    eventTypes = {
        info = {
            border = Color(200, 100, 100),
            title = Color(200, 100, 100),
            text = Color(255, 220, 220),
            icon = "†",
            shake = false,
            shakeIntensity = 0,
        },
        warning = {
            border = Color(255, 150, 0),
            title = Color(255, 150, 0),
            text = Color(255, 220, 220),
            icon = "⚠",
            shake = true,
            shakeIntensity = 4,
        },
        error = {
            border = Color(255, 0, 0),
            title = Color(255, 0, 0),
            text = Color(255, 150, 150),
            icon = "✖",
            shake = true,
            shakeIntensity = 8,
        },
        story = {
            border = Color(150, 0, 50),
            title = Color(200, 50, 100),
            text = Color(255, 220, 220),
            icon = "❖",
            shake = false,
            shakeIntensity = 0,
        },
        success = {
            border = Color(150, 200, 100),
            title = Color(150, 200, 100),
            text = Color(255, 255, 220),
            icon = "✓",
            shake = false,
            shakeIntensity = 0,
        },
    },
    
    menuBg = Color(15, 8, 8, 250),
    menuBorder = Color(200, 0, 0),
    menuAccent = Color(255, 50, 50),
    menuText = Color(255, 220, 220),
    menuTextDim = Color(150, 100, 100),
    menuSection = Color(30, 15, 15, 200),
    menuSliderBg = Color(50, 25, 25),
    menuSliderFill = Color(200, 0, 0),
    menuCheckOn = Color(255, 100, 100),
    menuCheckOff = Color(100, 50, 50),
    menuButtonBg = Color(50, 25, 25),
    menuButtonHover = Color(80, 40, 40),
    
    styles = {
        direct = { text = Color(255, 220, 220), name = nil },
        telegraph = { text = Color(255, 200, 150), name = Color(200, 150, 100) },
        letter = {text = Color(50, 35, 25), name = Color(70, 45, 35) },
        radio = { text = Color(200, 255, 200), name = Color(150, 200, 150), glitchChars = Color(255, 100, 100) },
        whisper = { text = Color(180, 150, 150, 200), name = Color(150, 120, 120) },
        yell = { text = Color(255, 50, 50), name = Color(255, 0, 0) },
        action = { text = Color(255, 180, 150), name = Color(255, 180, 150) },
        ooc = { text = Color(150, 120, 120), name = Color(120, 100, 100) },
        looc = { text = Color(150, 120, 120), name = Color(120, 100, 100) },
    },
    
    sounds = {},
    
    crtEffect = false,
    crtIntensity = 0,
    glowEffect = true,
    glowColor = Color(255, 0, 0, 15),
}

-- ============================================
-- CURRENT THEME (default)
-- ============================================

GlitchLab.Theme = table.Copy(themes.undertale)

-- ============================================
-- THEME API
-- ============================================

function GlitchLab.SetTheme(themeId)
    local theme = themes[themeId]
    
    if not theme then
        MsgC(Color(255, 100, 100), "[GlitchLab] ")
        MsgC(Color(255, 255, 255), "Theme not found: " .. tostring(themeId) .. "\n")
        return false
    end
    
    -- Copy theme to active
    GlitchLab.Theme = table.Copy(theme)
    
    -- Save preference
    if GlitchLab.Settings and GlitchLab.Settings.Set then
        RunConsoleCommand("uc_theme", themeId)
    end
    
    -- Rebuild UI
    timer.Simple(0.1, function()
        if GlitchLab.Chatbox and GlitchLab.Chatbox.Build then
            GlitchLab.Chatbox.Build()
        end
    end)
    
    MsgC(Color(177, 102, 199), "[GlitchLab] ")
    MsgC(Color(255, 255, 255), "Theme set to: " .. theme.name .. "\n")
    
    return true
end

function GlitchLab.GetTheme()
    return GlitchLab.Theme
end

function GlitchLab.GetThemeList()
    local list = {}
    for id, theme in pairs(themes) do
        table.insert(list, {
            id = id,
            name = theme.name,
            author = theme.author,
            description = theme.description,
        })
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

-- ============================================
-- HELPER: Get color with fallback
-- ============================================

function GlitchLab.GetThemeColor(key, fallback)
    local T = GlitchLab.Theme
    if T and T[key] then
        return T[key]
    end
    return fallback or Color(255, 255, 255)
end

-- Shorthand
function GlitchLab.TC(key, fallback)
    return GlitchLab.GetThemeColor(key, fallback)
end

-- ============================================
-- CONVAR FOR THEME
-- ============================================

CreateClientConVar("uc_theme", "undertale", true, false, "UnderComms theme")

-- ============================================
-- CONSOLE COMMANDS
-- ============================================

concommand.Add("uc_theme_set", function(ply, cmd, args)
    local themeId = args[1]
    if not themeId then
        print("Usage: uc_theme_set <theme_id>")
        print("Available themes:")
        for _, t in ipairs(GlitchLab.GetThemeList()) do
            print("  " .. t.id .. " — " .. t.name)
        end
        return
    end
    
    GlitchLab.SetTheme(themeId)
end, nil, "Set chat theme")

concommand.Add("uc_theme_list", function()
    print("\n=== UnderComms Themes ===")
    for _, t in ipairs(GlitchLab.GetThemeList()) do
        local current = GlitchLab.Theme.id == t.id and " [ACTIVE]" or ""
        print(string.format("  %s — %s%s", t.id, t.name, current))
        print(string.format("      by %s: %s", t.author, t.description))
    end
    print("=========================\n")
end, nil, "List available themes")

concommand.Add("uc_theme_reload", function()
    local currentId = GlitchLab.Theme.id or "undertale"
    GlitchLab.SetTheme(currentId)
end, nil, "Reload current theme")

-- ============================================
-- LOAD SAVED THEME ON INIT
-- ============================================

hook.Add("InitPostEntity", "GlitchLab_LoadTheme", function()
    timer.Simple(0.3, function()
        local savedTheme = GetConVar("uc_theme"):GetString()
        if savedTheme and themes[savedTheme] then
            GlitchLab.SetTheme(savedTheme)
        else
            -- Fallback to default if invalid
            GlitchLab.SetTheme("undertale")
        end
    end)
end)

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), string.format("Theme system loaded (%d themes available)\n", table.Count(themes)))