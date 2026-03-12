--[[
    GlitchLab | UnderComms — Client Init
    
    v0.6.1 — THEMES EDITION
]]

-- Config first
include("glitchlab/sh_config.lua")
include("glitchlab/sh_voices.lua")

-- Theme system (LOAD EARLY!)
include("glitchlab/cl_themes.lua")

-- Settings system
include("glitchlab/cl_settings.lua")
include("glitchlab/cl_settings_menu.lua")


-- Fonts
include("glitchlab/cl_fonts.lua")
GlitchLab.Fonts.Register()

-- Subsystems
include("glitchlab/cl_input_history.lua")
include("glitchlab/cl_autocomplete.lua")
include("glitchlab/cl_links.lua")
include("glitchlab/cl_sprites.lua")

-- Chatbox
include("glitchlab/cl_chatbox.lua")

-- Input handling  
include("glitchlab/cl_input.lua")

-- Events system
include("glitchlab/cl_events.lua")

include("glitchlab/cl_voices.lua")

-- ============================================
-- HIDE DEFAULT CHAT
-- ============================================

hook.Add("HUDShouldDraw", "GlitchLab_HideDefaultChat", function(name)
    if name == "CHudChat" then
        return false
    end
end)

-- ============================================
-- INTERCEPT CHAT KEYS
-- ============================================

hook.Add("PlayerBindPress", "GlitchLab_InterceptChat", function(ply, bind, pressed)
    if not pressed then return end
    
    if string.find(bind, "messagemode") then
        local isTeam = string.find(bind, "messagemode2") ~= nil
        
        if GlitchLab.Chatbox and GlitchLab.Chatbox.Open then
            GlitchLab.Chatbox.Open(isTeam)
        end
        
        return true
    end
end)

-- ============================================
-- STARTUP
-- ============================================

hook.Add("InitPostEntity", "GlitchLab_ClientReady", function()
    timer.Simple(0.5, function()
        if not GlitchLab.Fonts.Registered then
            GlitchLab.Fonts.Register()
        end
        
        GlitchLab.Settings.Apply()
    end)
    
    MsgC(Color(177, 102, 199), "[GlitchLab] ")
    MsgC(Color(255, 255, 255), "UnderComms v0.6.1 loaded.\n")
    MsgC(Color(100, 100, 100), "[GlitchLab] Try: uc_theme_list, uc_theme_set <name>\n")
end)