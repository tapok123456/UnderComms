--[[
    GlitchLab | UnderComms — Font System
    
    v0.2.4 — PIXEL FONT EDITION
    
    Registers custom pixel fonts for that authentic Undertale feel.
    Falls back to system fonts if custom font not found.
    
    "* But it refused to use Arial"
]]

GlitchLab.Fonts = GlitchLab.Fonts or {}

local cfg = GlitchLab.Config

-- ============================================
-- FONT CONFIGURATION
-- ============================================

-- Primary font (custom Undertale-style)
local CUSTOM_FONT = "Press Start 2P"  -- Name after registration

-- Fallback fonts (in order of preference)
local FALLBACK_FONTS = {
    "Determination Mono",
    "Press Start 2P", 
    "VT323",
    "Perfect DOS VGA 437",
    "Pixelated",
    "Courier New",
    "Lucida Console",
}

-- ============================================
-- FIND BEST AVAILABLE FONT
-- ============================================

local function FindBestFont()
    -- Try custom font first
    surface.CreateFont("GlitchLab_Test", {
        font = CUSTOM_FONT,
        size = 16,
    })
    
    surface.SetFont("GlitchLab_Test")
    local w, h = surface.GetTextSize("Test")
    
    -- If custom font works (returns reasonable size)
    if w > 0 and h > 0 then
        return CUSTOM_FONT
    end
    
    -- Try fallbacks
    for _, fontName in ipairs(FALLBACK_FONTS) do
        surface.CreateFont("GlitchLab_Test_" .. fontName, {
            font = fontName,
            size = 16,
        })
        
        surface.SetFont("GlitchLab_Test_" .. fontName)
        w, h = surface.GetTextSize("Test")
        
        if w > 0 and h > 10 then
            MsgC(Color(255, 200, 100), "[GlitchLab] ")
            MsgC(Color(255, 255, 255), "Using fallback font: " .. fontName .. "\n")
            return fontName
        end
    end
    
    -- Ultimate fallback
    MsgC(Color(255, 100, 100), "[GlitchLab] ")
    MsgC(Color(255, 255, 255), "No pixel fonts found, using Lucida Console\n")
    return "Lucida Console"
end

-- ============================================
-- REGISTER ALL FONTS
-- ============================================

function GlitchLab.Fonts.Register()
    local bestFont = FindBestFont()
    
    -- Get text scale
    local textScale = 1.0
    local cvar = GetConVar("uc_text_scale")
    if cvar then
        textScale = cvar:GetFloat()
    end
    
    local uiScale = 1.0
    local uiCvar = GetConVar("uc_ui_scale")
    if uiCvar then
        uiScale = uiCvar:GetFloat()
    end
    
    local scale = (textScale * uiScale) / 10000
    
    MsgC(Color(177, 102, 199), "[GlitchLab] ")
    MsgC(Color(255, 255, 255), "Registering fonts with: " .. bestFont .. " (scale: " .. scale .. ")\n")
    
    -- Main chat font
    surface.CreateFont(cfg.FontName, {
        font = bestFont,
        size = math.floor((cfg.FontSize or 16) * scale),
        weight = 500,
        antialias = false,
        shadow = false,
        extended = true,
    })
    
    -- Small font (timestamps)
    surface.CreateFont(cfg.FontNameSmall, {
        font = bestFont,
        size = math.floor((cfg.FontSizeSmall or 12) * scale),
        weight = 400,
        antialias = false,
        shadow = false,
        extended = true,
    })
    
    -- Input font
    surface.CreateFont(cfg.FontNameInput, {
        font = bestFont,
        size = math.floor((cfg.FontSizeInput or 16) * scale),
        weight = 500,
        antialias = false,
        shadow = false,
        extended = true,
    })
    
    -- Bold variant
    surface.CreateFont("GlitchLab_Bold", {
        font = bestFont,
        size = math.floor((cfg.FontSize or 16) * scale),
        weight = 700,
        antialias = false,
        shadow = false,
        extended = true,
    })
    
    -- Large font (events)
    surface.CreateFont("GlitchLab_Large", {
        font = bestFont,
        size = math.floor(24 * scale),
        weight = 600,
        antialias = false,
        shadow = false,
        extended = true,
    })
    
    -- Extra large
    surface.CreateFont("GlitchLab_XLarge", {
        font = bestFont,
        size = math.floor(32 * scale),
        weight = 700,
        antialias = false,
        shadow = false,
        extended = true,
    })
    
    GlitchLab.Fonts.Current = bestFont
    GlitchLab.Fonts.Registered = true
    GlitchLab.Fonts.Scale = scale
    
    MsgC(Color(100, 255, 100), "[GlitchLab] ")
    MsgC(Color(255, 255, 255), "Fonts registered successfully!\n")
end

-- ============================================
-- RELOAD FONTS (for settings changes)
-- ============================================

function GlitchLab.Fonts.Reload()
    GlitchLab.Fonts.Registered = false
    GlitchLab.Fonts.Register()
    
    -- Rebuild chatbox to apply new fonts
    if GlitchLab.Chatbox and GlitchLab.Chatbox.Build then
        GlitchLab.Chatbox.Build()
    end
end

-- ============================================
-- CONSOLE COMMANDS
-- ============================================

concommand.Add("uc_fonts_reload", function()
    GlitchLab.Fonts.Reload()
    print("[UnderComms] Fonts reloaded")
end, nil, "Reload UnderComms fonts")

concommand.Add("uc_fonts_info", function()
    print("\n=== UnderComms Fonts ===")
    print("Current font: " .. (GlitchLab.Fonts.Current or "Unknown"))
    print("Registered: " .. tostring(GlitchLab.Fonts.Registered))
    print("========================\n")
end, nil, "Show font info")