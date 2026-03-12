--[[
    GlitchLab | UnderComms — Settings System
    
    v0.9.0 — ALL SETTINGS WORK EDITION
    
    Every single convar actually does something now.
    No more placebo settings, this shit is REAL.
]]

GlitchLab = GlitchLab or {}
GlitchLab.Settings = GlitchLab.Settings or {}

-- ============================================
-- ALL CONVARS WITH PROPER DEFAULTS
-- ============================================

local CONVARS = {
    -- ========== VOICE ==========
    {name = "uc_voice", default = "default", flags = FCVAR_ARCHIVE},
    {name = "uc_voice_pitch", default = "0", min = -50, max = 50, flags = FCVAR_ARCHIVE},
    {name = "uc_voice_volume", default = "0", min = -30, max = 30, flags = FCVAR_ARCHIVE},
    {name = "uc_voice_sync", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_voice_hear_others", default = "1", flags = FCVAR_ARCHIVE},
    
    -- ========== SOUND ==========
    {name = "uc_blip_enabled", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_blip_volume", default = "50", min = 0, max = 100, flags = FCVAR_ARCHIVE},
    {name = "uc_max_blips", default = "3", min = 1, max = 5, flags = FCVAR_ARCHIVE},
    {name = "uc_blip_cooldown", default = "15", min = 5, max = 100, flags = FCVAR_ARCHIVE},
    {name = "uc_radio_static", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_radio_volume", default = "50", min = 0, max = 100, flags = FCVAR_ARCHIVE},
    {name = "uc_radio_crackle", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_telegraph_enabled", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_telegraph_volume", default = "50", min = 0, max = 100, flags = FCVAR_ARCHIVE},
    {name = "uc_paper_enabled", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_paper_volume", default = "50", min = 0, max = 100, flags = FCVAR_ARCHIVE},
    {name = "uc_mention_sound", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_mention_volume", default = "70", min = 0, max = 100, flags = FCVAR_ARCHIVE},
    {name = "uc_newmsg_sound", default = "0", flags = FCVAR_ARCHIVE},
    
    -- ========== VISUAL - TYPEWRITER ==========
    {name = "uc_type_speed", default = "60", min = 10, max = 300, flags = FCVAR_ARCHIVE},
    {name = "uc_instant_messages", default = "0", flags = FCVAR_ARCHIVE},
    {name = "uc_show_cursor", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_cursor_speed", default = "4", min = 1, max = 10, flags = FCVAR_ARCHIVE},
    
    -- ========== VISUAL - EFFECTS ==========
    {name = "uc_effects", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_glitch_intensity", default = "50", min = 0, max = 100, flags = FCVAR_ARCHIVE},
    {name = "uc_shake", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_shake_intensity", default = "50", min = 0, max = 100, flags = FCVAR_ARCHIVE},
    {name = "uc_scanlines", default = "0", flags = FCVAR_ARCHIVE},
    {name = "uc_scanline_opacity", default = "20", min = 0, max = 100, flags = FCVAR_ARCHIVE},
    {name = "uc_glow", default = "0", flags = FCVAR_ARCHIVE},
    {name = "uc_glow_intensity", default = "30", min = 0, max = 100, flags = FCVAR_ARCHIVE},
    
    -- ========== VISUAL - TEXT ==========
    {name = "uc_timestamps", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_timestamp_format", default = "1", min = 1, max = 3, flags = FCVAR_ARCHIVE},
    {name = "uc_text_shadows", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_shadow_opacity", default = "60", min = 0, max = 100, flags = FCVAR_ARCHIVE},
    
    -- ========== POSITION ==========
    {name = "uc_chat_x", default = "24", min = 0, max = 2000, flags = FCVAR_ARCHIVE},
    {name = "uc_chat_y", default = "140", min = 0, max = 1500, flags = FCVAR_ARCHIVE},
    {name = "uc_chat_width", default = "620", min = 200, max = 1500, flags = FCVAR_ARCHIVE},
    {name = "uc_chat_height", default = "300", min = 100, max = 1000, flags = FCVAR_ARCHIVE},
    {name = "uc_ui_scale", default = "100", min = 50, max = 200, flags = FCVAR_ARCHIVE},
    {name = "uc_text_scale", default = "100", min = 50, max = 200, flags = FCVAR_ARCHIVE},
    {name = "uc_icon_scale", default = "100", min = 50, max = 200, flags = FCVAR_ARCHIVE},
    {name = "uc_avatar_size", default = "18", min = 8, max = 64, flags = FCVAR_ARCHIVE},
    {name = "uc_icon_size", default = "16", min = 8, max = 48, flags = FCVAR_ARCHIVE},
    {name = "uc_line_height", default = "20", min = 12, max = 50, flags = FCVAR_ARCHIVE},
    {name = "uc_input_height", default = "32", min = 20, max = 60, flags = FCVAR_ARCHIVE},
    {name = "uc_border_thickness", default = "2", min = 1, max = 6, flags = FCVAR_ARCHIVE},
    
    -- ========== THEME ==========
    {name = "uc_theme", default = "undertale", flags = FCVAR_ARCHIVE},
    {name = "uc_avatar_mode", default = "1", min = 0, max = 2, flags = FCVAR_ARCHIVE},
    {name = "uc_avatar_sprite", default = "frisk", flags = FCVAR_ARCHIVE},
    {name = "uc_avatar_shape", default = "square", flags = FCVAR_ARCHIVE},
    {name = "uc_avatar_border", default = "0", flags = FCVAR_ARCHIVE},
    {name = "uc_show_style_icons", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_custom_colors", default = "0", flags = FCVAR_ARCHIVE},
    {name = "uc_color_bg_r", default = "10", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_color_bg_g", default = "10", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_color_bg_b", default = "10", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_color_border_r", default = "255", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_color_border_g", default = "255", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_color_border_b", default = "255", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_color_accent_r", default = "177", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_color_accent_g", default = "102", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_color_accent_b", default = "199", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_color_text_r", default = "255", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_color_text_g", default = "255", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_color_text_b", default = "255", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_bg_opacity", default = "90", min = 0, max = 100, flags = FCVAR_ARCHIVE},
    
    -- ========== MESSAGES ==========
    {name = "uc_fade_time", default = "10", min = 1, max = 120, flags = FCVAR_ARCHIVE},
    {name = "uc_fade_duration", default = "2", min = 0, max = 10, flags = FCVAR_ARCHIVE},
    {name = "uc_max_messages", default = "128", min = 10, max = 500, flags = FCVAR_ARCHIVE},
    {name = "uc_show_system", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_show_joinleave", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_show_death", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_show_admin", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_highlight_own", default = "0", flags = FCVAR_ARCHIVE},
    {name = "uc_own_r", default = "200", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_own_g", default = "200", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_own_b", default = "255", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_highlight_mentions", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_mention_r", default = "255", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_mention_g", default = "255", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_mention_b", default = "100", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_clickable_links", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_link_r", default = "100", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_link_g", default = "150", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_link_b", default = "255", min = 0, max = 255, flags = FCVAR_ARCHIVE},
    {name = "uc_underline_links", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_link_previews", default = "0", flags = FCVAR_ARCHIVE},
    
    -- ========== INPUT ==========
    {name = "uc_save_draft", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_history_size", default = "50", min = 5, max = 200, flags = FCVAR_ARCHIVE},
    {name = "uc_autocomplete", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_autocomplete_key", default = "tab", flags = FCVAR_ARCHIVE},
    {name = "uc_show_placeholder", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_dynamic_placeholder", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_close_escape", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_close_click", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_close_send", default = "1", flags = FCVAR_ARCHIVE},
    
    -- ========== ADVANCED ==========
    {name = "uc_performance_mode", default = "0", flags = FCVAR_ARCHIVE},
    {name = "uc_no_animations", default = "0", flags = FCVAR_ARCHIVE},
    {name = "uc_max_gif_size", default = "2", min = 1, max = 10, flags = FCVAR_ARCHIVE},
    {name = "uc_render_distance", default = "800", min = 100, max = 5000, flags = FCVAR_ARCHIVE},
    {name = "uc_net_compression", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_antispam", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_spam_cooldown", default = "500", min = 100, max = 5000, flags = FCVAR_ARCHIVE},
    {name = "uc_log_messages", default = "0", flags = FCVAR_ARCHIVE},
    {name = "uc_log_timestamps", default = "1", flags = FCVAR_ARCHIVE},
    {name = "uc_debug", default = "0", flags = FCVAR_ARCHIVE},
    {name = "uc_show_fps", default = "0", flags = FCVAR_ARCHIVE},
}

-- Store defaults for reset
GlitchLab.Settings.Defaults = {}

-- ============================================
-- CREATE CONVARS
-- ============================================

for _, cv in ipairs(CONVARS) do
    GlitchLab.Settings.Defaults[cv.name] = cv.default
    
    if not ConVarExists(cv.name) then
        CreateClientConVar(cv.name, cv.default, true, false, "", cv.min, cv.max)
    end
end

-- ============================================
-- CACHED VALUES (for performance)
-- Rebuild cache when settings change
-- ============================================

GlitchLab.Settings.Cache = {}
local cacheTime = 0
local CACHE_LIFETIME = 0.1  -- Refresh every 100ms max

local function RefreshCache()
    local now = CurTime()
    if now - cacheTime < CACHE_LIFETIME then return end
    cacheTime = now
    
    local c = GlitchLab.Settings.Cache
    
    -- Sound
    c.blip_enabled = GetConVar("uc_blip_enabled"):GetBool()
    c.blip_volume = GetConVar("uc_blip_volume"):GetInt() / 100
    c.max_blips = GetConVar("uc_max_blips"):GetInt()
    c.blip_cooldown = GetConVar("uc_blip_cooldown"):GetInt() / 1000
    c.radio_static = GetConVar("uc_radio_static"):GetBool()
    c.radio_volume = GetConVar("uc_radio_volume"):GetInt() / 100
    c.radio_crackle = GetConVar("uc_radio_crackle"):GetBool()
    c.telegraph_enabled = GetConVar("uc_telegraph_enabled"):GetBool()
    c.telegraph_volume = GetConVar("uc_telegraph_volume"):GetInt() / 100
    c.paper_enabled = GetConVar("uc_paper_enabled"):GetBool()
    c.paper_volume = GetConVar("uc_paper_volume"):GetInt() / 100
    c.mention_sound = GetConVar("uc_mention_sound"):GetBool()
    c.mention_volume = GetConVar("uc_mention_volume"):GetInt() / 100
    
    -- Visual
    c.type_speed = GetConVar("uc_type_speed"):GetInt()
    c.instant_messages = GetConVar("uc_instant_messages"):GetBool()
    c.show_cursor = GetConVar("uc_show_cursor"):GetBool()
    c.cursor_speed = GetConVar("uc_cursor_speed"):GetInt()
    c.effects = GetConVar("uc_effects"):GetBool()
    c.glitch_intensity = GetConVar("uc_glitch_intensity"):GetInt() / 100
    c.shake = GetConVar("uc_shake"):GetBool()
    c.shake_intensity = GetConVar("uc_shake_intensity"):GetInt() / 100
    c.scanlines = GetConVar("uc_scanlines"):GetBool()
    c.scanline_opacity = GetConVar("uc_scanline_opacity"):GetInt() / 100
    c.glow = GetConVar("uc_glow"):GetBool()
    c.glow_intensity = GetConVar("uc_glow_intensity"):GetInt() / 100
    c.timestamps = GetConVar("uc_timestamps"):GetBool()
    c.timestamp_format = GetConVar("uc_timestamp_format"):GetInt()
    c.text_shadows = GetConVar("uc_text_shadows"):GetBool()
    c.shadow_opacity = GetConVar("uc_shadow_opacity"):GetInt() / 100
    
    -- Position & Scale
    c.chat_x = GetConVar("uc_chat_x"):GetInt()
    c.chat_y = GetConVar("uc_chat_y"):GetInt()
    c.chat_width = GetConVar("uc_chat_width"):GetInt()
    c.chat_height = GetConVar("uc_chat_height"):GetInt()
    c.ui_scale = GetConVar("uc_ui_scale"):GetInt() / 100
    c.text_scale = GetConVar("uc_text_scale"):GetInt() / 100
    c.icon_scale = GetConVar("uc_icon_scale"):GetInt() / 100
    c.avatar_size = GetConVar("uc_avatar_size"):GetInt()
    c.icon_size = GetConVar("uc_icon_size"):GetInt()
    c.line_height = GetConVar("uc_line_height"):GetInt()
    c.input_height = GetConVar("uc_input_height"):GetInt()
    c.border_thickness = GetConVar("uc_border_thickness"):GetInt()
    
    -- Theme
    c.avatar_mode = GetConVar("uc_avatar_mode"):GetInt()
    c.avatar_shape = GetConVar("uc_avatar_shape"):GetString()
    c.avatar_border = GetConVar("uc_avatar_border"):GetBool()
    c.show_style_icons = GetConVar("uc_show_style_icons"):GetBool()
    c.custom_colors = GetConVar("uc_custom_colors"):GetBool()
    c.bg_opacity = GetConVar("uc_bg_opacity"):GetInt() / 100
    
    -- Custom colors
    if c.custom_colors then
        c.color_bg = Color(
            GetConVar("uc_color_bg_r"):GetInt(),
            GetConVar("uc_color_bg_g"):GetInt(),
            GetConVar("uc_color_bg_b"):GetInt(),
            math.floor(c.bg_opacity * 255)
        )
        c.color_border = Color(
            GetConVar("uc_color_border_r"):GetInt(),
            GetConVar("uc_color_border_g"):GetInt(),
            GetConVar("uc_color_border_b"):GetInt()
        )
        c.color_accent = Color(
            GetConVar("uc_color_accent_r"):GetInt(),
            GetConVar("uc_color_accent_g"):GetInt(),
            GetConVar("uc_color_accent_b"):GetInt()
        )
        c.color_text = Color(
            GetConVar("uc_color_text_r"):GetInt(),
            GetConVar("uc_color_text_g"):GetInt(),
            GetConVar("uc_color_text_b"):GetInt()
        )
    end
    
    -- Messages
    c.fade_time = GetConVar("uc_fade_time"):GetInt()
    c.fade_duration = GetConVar("uc_fade_duration"):GetInt()
    c.max_messages = GetConVar("uc_max_messages"):GetInt()
    c.show_system = GetConVar("uc_show_system"):GetBool()
    c.show_joinleave = GetConVar("uc_show_joinleave"):GetBool()
    c.highlight_own = GetConVar("uc_highlight_own"):GetBool()
    c.highlight_mentions = GetConVar("uc_highlight_mentions"):GetBool()
    c.clickable_links = GetConVar("uc_clickable_links"):GetBool()
    
    c.own_color = Color(
        GetConVar("uc_own_r"):GetInt(),
        GetConVar("uc_own_g"):GetInt(),
        GetConVar("uc_own_b"):GetInt()
    )
    c.mention_color = Color(
        GetConVar("uc_mention_r"):GetInt(),
        GetConVar("uc_mention_g"):GetInt(),
        GetConVar("uc_mention_b"):GetInt()
    )
    c.link_color = Color(
        GetConVar("uc_link_r"):GetInt(),
        GetConVar("uc_link_g"):GetInt(),
        GetConVar("uc_link_b"):GetInt()
    )
    
    -- Input
    c.save_draft = GetConVar("uc_save_draft"):GetBool()
    c.history_size = GetConVar("uc_history_size"):GetInt()
    c.autocomplete = GetConVar("uc_autocomplete"):GetBool()
    c.show_placeholder = GetConVar("uc_show_placeholder"):GetBool()
    c.dynamic_placeholder = GetConVar("uc_dynamic_placeholder"):GetBool()
    c.close_escape = GetConVar("uc_close_escape"):GetBool()
    c.close_click = GetConVar("uc_close_click"):GetBool()
    c.close_send = GetConVar("uc_close_send"):GetBool()
    
    -- Advanced
    c.performance_mode = GetConVar("uc_performance_mode"):GetBool()
    c.no_animations = GetConVar("uc_no_animations"):GetBool()
    c.debug = GetConVar("uc_debug"):GetBool()
    
    -- Voice
    c.voice_id = GetConVar("uc_voice"):GetString()
    c.voice_pitch = GetConVar("uc_voice_pitch"):GetInt()
    c.voice_volume = GetConVar("uc_voice_volume"):GetInt() / 100
    c.voice_sync = GetConVar("uc_voice_sync"):GetBool()
    c.voice_hear_others = GetConVar("uc_voice_hear_others"):GetBool()
end

-- ============================================
-- PUBLIC API
-- These are the functions other files should use
-- ============================================

-- Get cached value (fast, for rendering)
function GlitchLab.Settings.Get(key)
    RefreshCache()
    return GlitchLab.Settings.Cache[key]
end

-- Get bool directly from convar
function GlitchLab.Settings.GetBool(name)
    local fullName = string.StartWith(name, "uc_") and name or ("uc_" .. name)
    local cvar = GetConVar(fullName)
    return cvar and cvar:GetBool() or false
end

-- Get int directly from convar
function GlitchLab.Settings.GetInt(name)
    local fullName = string.StartWith(name, "uc_") and name or ("uc_" .. name)
    local cvar = GetConVar(fullName)
    return cvar and cvar:GetInt() or 0
end

-- Get float directly from convar
function GlitchLab.Settings.GetFloat(name)
    local fullName = string.StartWith(name, "uc_") and name or ("uc_" .. name)
    local cvar = GetConVar(fullName)
    return cvar and cvar:GetFloat() or 0
end

-- Get string directly from convar
function GlitchLab.Settings.GetString(name)
    local fullName = string.StartWith(name, "uc_") and name or ("uc_" .. name)
    local cvar = GetConVar(fullName)
    return cvar and cvar:GetString() or ""
end

-- Get color from 3 convars
function GlitchLab.Settings.GetColor(baseName)
    local r = GlitchLab.Settings.GetInt(baseName .. "_r")
    local g = GlitchLab.Settings.GetInt(baseName .. "_g")
    local b = GlitchLab.Settings.GetInt(baseName .. "_b")
    return Color(r, g, b)
end

-- Set a setting
function GlitchLab.Settings.Set(name, value)
    local fullName = string.StartWith(name, "uc_") and name or ("uc_" .. name)
    RunConsoleCommand(fullName, tostring(value))
    cacheTime = 0  -- Force cache refresh
end

-- Reset all to defaults
function GlitchLab.Settings.ResetAll()
    for name, default in pairs(GlitchLab.Settings.Defaults) do
        RunConsoleCommand(name, default)
    end
    cacheTime = 0
    
    timer.Simple(0.1, function()
        if GlitchLab.Chatbox and GlitchLab.Chatbox.Build then
            GlitchLab.Chatbox.Build()
        end
    end)
end

-- Apply settings (rebuild UI)
function GlitchLab.Settings.Apply()
    cacheTime = 0  -- Force cache refresh
    RefreshCache()
    
    -- Apply theme
    local themeName = GetConVar("uc_theme"):GetString()
    if GlitchLab.SetTheme then
        GlitchLab.SetTheme(themeName)
    end
    
    -- Rebuild chat
    if GlitchLab.Chatbox and GlitchLab.Chatbox.Build then
        GlitchLab.Chatbox.Build()
    end
    
    -- Sync voice
    if GlitchLab.SendMyVoice then
        GlitchLab.SendMyVoice()
    end
end

-- ============================================
-- SHORTHAND FUNCTIONS FOR COMMON SETTINGS
-- These are used a LOT so make them fast
-- ============================================

function GlitchLab.Settings.BlipEnabled()
    RefreshCache()
    return GlitchLab.Settings.Cache.blip_enabled
end

function GlitchLab.Settings.BlipVolume()
    RefreshCache()
    return GlitchLab.Settings.Cache.blip_volume
end

function GlitchLab.Settings.EffectsEnabled()
    RefreshCache()
    return GlitchLab.Settings.Cache.effects and not GlitchLab.Settings.Cache.performance_mode
end

function GlitchLab.Settings.ShakeEnabled()
    RefreshCache()
    return GlitchLab.Settings.Cache.shake and not GlitchLab.Settings.Cache.performance_mode
end

function GlitchLab.Settings.TimestampsEnabled()
    RefreshCache()
    return GlitchLab.Settings.Cache.timestamps
end

function GlitchLab.Settings.GetTypeSpeed()
    RefreshCache()
    if GlitchLab.Settings.Cache.instant_messages or GlitchLab.Settings.Cache.no_animations then
        return 9999  -- Instant
    end
    return GlitchLab.Settings.Cache.type_speed
end

function GlitchLab.Settings.GetFadeTime()
    RefreshCache()
    return GlitchLab.Settings.Cache.fade_time
end

function GlitchLab.Settings.GetFadeDuration()
    RefreshCache()
    return GlitchLab.Settings.Cache.fade_duration
end

function GlitchLab.Settings.GetChatPosition()
    RefreshCache()
    local c = GlitchLab.Settings.Cache
    local scrW, scrH = ScrW(), ScrH()
    return c.chat_x, scrH - c.chat_height - c.chat_y, c.chat_width, c.chat_height
end

function GlitchLab.Settings.GetLineHeight()
    RefreshCache()
    return math.floor(GlitchLab.Settings.Cache.line_height * GlitchLab.Settings.Cache.ui_scale)
end

function GlitchLab.Settings.GetIconSize()
    RefreshCache()
    return math.floor(GlitchLab.Settings.Cache.icon_size * GlitchLab.Settings.Cache.icon_scale * GlitchLab.Settings.Cache.ui_scale)
end

function GlitchLab.Settings.GetAvatarSize()
    RefreshCache()
    return math.floor(GlitchLab.Settings.Cache.avatar_size * GlitchLab.Settings.Cache.icon_scale * GlitchLab.Settings.Cache.ui_scale)
end

function GlitchLab.Settings.GetMaxMessages()
    RefreshCache()
    return GlitchLab.Settings.Cache.max_messages
end

function GlitchLab.Settings.DebugMode()
    RefreshCache()
    return GlitchLab.Settings.Cache.debug
end

-- ============================================
-- INITIAL CACHE BUILD
-- ============================================

timer.Simple(0, RefreshCache)

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), "Settings system loaded (" .. #CONVARS .. " settings)\n")