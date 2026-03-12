--[[
    GlitchLab | UnderComms — Server Init
    
    v0.6.0 — EVENTS EDITION
]]

-- Shared config
AddCSLuaFile("glitchlab/sh_config.lua")
include("glitchlab/sh_config.lua")
AddCSLuaFile("glitchlab/sh_voices.lua")
include("glitchlab/sh_voices.lua")

-- Client files
AddCSLuaFile("glitchlab/cl_settings.lua")
AddCSLuaFile("glitchlab/cl_settings_menu.lua")
AddCSLuaFile("glitchlab/cl_fonts.lua")
AddCSLuaFile("glitchlab/cl_input_history.lua")
AddCSLuaFile("glitchlab/cl_autocomplete.lua")
AddCSLuaFile("glitchlab/cl_links.lua")
AddCSLuaFile("glitchlab/cl_chatbox.lua")
AddCSLuaFile("glitchlab/cl_input.lua")
AddCSLuaFile("glitchlab/cl_events.lua")  -- NEW v0.6.0
AddCSLuaFile("glitchlab/cl_themes.lua")  -- NEW v0.6.1
AddCSLuaFile("glitchlab/cl_sprites.lua")  -- NEW v0.7.0
AddCSLuaFile("glitchlab/cl_voices.lua")

-- Server files
include("glitchlab/sv_chat.lua")
include("glitchlab/sv_logging.lua")
include("glitchlab/sv_events.lua")  -- NEW v0.6.0
include("glitchlab/sv_voices.lua")

-- Network strings
for name, netStr in pairs(GlitchLab.Config.NetStrings) do
    util.AddNetworkString(netStr)
end

-- NEW: Event network string
util.AddNetworkString("GlitchLab_Event")

-- Resource files
resource.AddFile("resource/fonts/undertale.ttf")

-- Startup banner
local function PrintBanner()
    MsgC(Color(177, 102, 199), [[
    
     ██████╗ ██╗     ██╗████████╗ ██████╗██╗  ██╗██╗      █████╗ ██████╗ 
    ██╔════╝ ██║     ██║╚══██╔══╝██╔════╝██║  ██║██║     ██╔══██╗██╔══██╗
    ██║  ███╗██║     ██║   ██║   ██║     ███████║██║     ███████║██████╔╝
    ██║   ██║██║     ██║   ██║   ██║     ██╔══██║██║     ██╔══██║██╔══██╗
    ╚██████╔╝███████╗██║   ██║   ╚██████╗██║  ██║███████╗██║  ██║██████╔╝
     ╚═════╝ ╚══════╝╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝
    
    ]])
    MsgC(Color(255, 255, 255), "    UnderComms v0.6.7 — SARBAZON Edition\n")
    MsgC(Color(100, 100, 100), "    \"Reality is just a bug waiting to happen.\"\n\n")
end

PrintBanner()

if GlitchLab.Log and GlitchLab.Log.Info then
    GlitchLab.Log.Info("Server initialized. UnderComms v0.6.7")
end