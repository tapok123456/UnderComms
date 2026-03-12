--[[
    GlitchLab | UnderComms — Server Logging
    
    v0.8.0 — FIXED RACE CONDITIONS
]]

GlitchLab = GlitchLab or {}
GlitchLab.Log = GlitchLab.Log or {}

-- ============================================
-- CONFIG GETTERS (avoid race conditions)
-- ============================================

local function GetLogPath()
    local cfg = GlitchLab.Config or {}
    return (cfg.LogPath and cfg.LogPath ~= "") and cfg.LogPath or "glitchlab/logs/"
end

local function IsLoggingEnabled()
    local cfg = GlitchLab.Config or {}
    return cfg.EnableLogging ~= false  -- default true
end

local function IsDebugMode()
    local cfg = GlitchLab.Config or {}
    return cfg.DebugMode == true
end

-- ============================================
-- ENSURE LOG DIRECTORY EXISTS
-- ============================================

local function EnsureLogDir()
    -- Always create glitchlab parent folder
    if not file.IsDir("glitchlab", "DATA") then
        file.CreateDir("glitchlab")
    end
    
    -- Always create logs subfolder (hardcoded for safety)
    if not file.IsDir("glitchlab/logs", "DATA") then
        file.CreateDir("glitchlab/logs")
    end
end

-- Safe init
local initSuccess, initError = pcall(EnsureLogDir)
if not initSuccess then
    MsgC(Color(255, 100, 100), "[GlitchLab:Log] Failed to create log directory: " .. tostring(initError) .. "\n")
end

-- ============================================
-- GET LOG FILE NAME
-- ============================================

local function GetLogFileName()
    return GetLogPath() .. os.date("%Y-%m-%d") .. ".txt"
end

-- ============================================
-- WRITE TO LOG
-- ============================================

local function WriteLog(line)
    if not IsLoggingEnabled() then return end
    
    local success, err = pcall(function()
        local filename = GetLogFileName()
        local timestamp = os.date("[%H:%M:%S]")
        local fullLine = timestamp .. " " .. line .. "\n"
        file.Append(filename, fullLine)
    end)
    
    if not success and IsDebugMode() then
        MsgC(Color(255, 100, 100), "[GlitchLab:Log] Write failed: " .. tostring(err) .. "\n")
    end
end

-- ============================================
-- PUBLIC API
-- ============================================

function GlitchLab.Log.Info(message)
    WriteLog("[INFO] " .. tostring(message))
    
    if IsDebugMode() then
        MsgC(Color(100, 200, 100), "[GlitchLab] ")
        MsgC(Color(255, 255, 255), "[INFO] " .. tostring(message) .. "\n")
    end
end

function GlitchLab.Log.Warn(message)
    WriteLog("[WARN] " .. tostring(message))
    
    if IsDebugMode() then
        MsgC(Color(255, 200, 50), "[GlitchLab] ")
        MsgC(Color(255, 255, 255), "[WARN] " .. tostring(message) .. "\n")
    end
end

function GlitchLab.Log.Error(message)
    WriteLog("[ERROR] " .. tostring(message))
    
    -- Always print errors to console (even if debug off)
    MsgC(Color(255, 50, 50), "[GlitchLab] ")
    MsgC(Color(255, 255, 255), "[ERROR] " .. tostring(message) .. "\n")
end

function GlitchLab.Log.ChatMessage(ply, text, isTeam)
    if not IsValid(ply) then return end
    
    local chatType = isTeam and "TEAM" or "GLOBAL"
    local logLine = string.format("[CHAT:%s] %s (%s): %s",
        chatType,
        ply:Nick(),
        ply:SteamID(),
        text
    )
    
    WriteLog(logLine)
end

function GlitchLab.Log.PlayerEvent(ply, event)
    if not IsValid(ply) then return end
    
    local logLine = string.format("[PLAYER] %s (%s) — %s",
        ply:Nick(),
        ply:SteamID(),
        tostring(event)
    )
    
    WriteLog(logLine)
end

-- ============================================
-- PLAYER EVENT HOOKS
-- ============================================

hook.Add("PlayerInitialSpawn", "GlitchLab_LogConnect", function(ply)
    GlitchLab.Log.PlayerEvent(ply, "CONNECTED")
end)

hook.Add("PlayerDisconnected", "GlitchLab_LogDisconnect", function(ply)
    GlitchLab.Log.PlayerEvent(ply, "DISCONNECTED")
end)

-- ============================================
-- STARTUP
-- ============================================

-- Delayed init to ensure config is loaded
timer.Simple(0.5, function()
    GlitchLab.Log.Info("========================================")
    GlitchLab.Log.Info("UnderComms Logging System Started")
    GlitchLab.Log.Info("Log path: data/" .. GetLogPath())
    GlitchLab.Log.Info("========================================")
    
    if IsDebugMode() then
        MsgC(Color(177, 102, 199), "[GlitchLab] ")
        MsgC(Color(255, 255, 255), "sv_logging.lua loaded (v0.8.0)\n")
    end
end)