--[[
    GlitchLab | UnderComms — Voice System (Server)
    
    v0.8.0 — VOICE EDITION
    
    Handles voice storage, sync, and persistence.
    Players pick their voice, server remembers it,
    and broadcasts to everyone so they hear the right sounds.
]]

GlitchLab = GlitchLab or {}
GlitchLab.PlayerVoices = GlitchLab.PlayerVoices or {}

local VOICE_SAVE_DIR = "glitchlab/voices"

-- ============================================
-- PERSISTENCE — Save/Load voice settings
-- ============================================

local function GetPlayerFileName(ply)
    if not IsValid(ply) then return nil end
    local steamId = ply:SteamID64() or "unknown"
    return VOICE_SAVE_DIR .. "/" .. steamId .. ".txt"
end

local function SavePlayerVoice(ply, voiceData)
    if not IsValid(ply) then return end
    
    local fileName = GetPlayerFileName(ply)
    if not fileName then return end
    
    -- Ensure directory exists
    if not file.IsDir(VOICE_SAVE_DIR, "DATA") then
        file.CreateDir(VOICE_SAVE_DIR)
    end
    
    local json = util.TableToJSON(voiceData, true)
    file.Write(fileName, json)
    
    MsgC(Color(177, 102, 199), "[GlitchLab] ")
    MsgC(Color(255, 255, 255), "Saved voice for " .. ply:Nick() .. ": " .. voiceData.voiceId .. "\n")
end

local function LoadPlayerVoice(ply)
    if not IsValid(ply) then return nil end
    
    local fileName = GetPlayerFileName(ply)
    if not fileName then return nil end
    
    if not file.Exists(fileName, "DATA") then
        return {voiceId = "default", pitchOffset = 0, volumeOffset = 0}
    end
    
    local content = file.Read(fileName, "DATA")
    if not content then return nil end
    
    local data = util.JSONToTable(content)
    return data
end

-- ============================================
-- VOICE MANAGEMENT
-- ============================================

function GlitchLab.SetPlayerVoice(ply, voiceId, pitchOffset, volumeOffset)
    if not IsValid(ply) then return end
    
    -- Validate voice exists
    if not GlitchLab.Voices.List[voiceId] then
        voiceId = "default"
    end
    
    pitchOffset = math.Clamp(pitchOffset or 0, -50, 50)
    volumeOffset = math.Clamp(volumeOffset or 0, -0.3, 0.3)
    
    local voiceData = {
        voiceId = voiceId,
        pitchOffset = pitchOffset,
        volumeOffset = volumeOffset,
    }
    
    -- Store in memory
    GlitchLab.PlayerVoices[ply:SteamID64()] = voiceData
    
    -- Save to file
    SavePlayerVoice(ply, voiceData)
    
    -- Broadcast to all clients
    GlitchLab.BroadcastVoice(ply, voiceData)
end

function GlitchLab.GetPlayerVoice(ply)
    if not IsValid(ply) then 
        return {voiceId = "default", pitchOffset = 0, volumeOffset = 0}
    end
    
    local steamId = ply:SteamID64()
    
    if GlitchLab.PlayerVoices[steamId] then
        return GlitchLab.PlayerVoices[steamId]
    end
    
    return {voiceId = "default", pitchOffset = 0, volumeOffset = 0}
end

-- ============================================
-- NETWORK — Sync voices between clients
-- ============================================

function GlitchLab.BroadcastVoice(ply, voiceData)
    if not IsValid(ply) then return end
    
    net.Start("GlitchLab_VoiceSync")
        net.WriteUInt(ply:EntIndex(), 16)
        net.WriteString(voiceData.voiceId or "default")
        net.WriteInt(voiceData.pitchOffset or 0, 8)
        net.WriteFloat(voiceData.volumeOffset or 0)
    net.Broadcast()
end

function GlitchLab.SendAllVoices(ply)
    if not IsValid(ply) then return end
    
    -- Send all known voices to this player
    for steamId, voiceData in pairs(GlitchLab.PlayerVoices) do
        -- Find player by steamId
        for _, p in ipairs(player.GetAll()) do
            if IsValid(p) and p:SteamID64() == steamId then
                net.Start("GlitchLab_VoiceSync")
                    net.WriteUInt(p:EntIndex(), 16)
                    net.WriteString(voiceData.voiceId or "default")
                    net.WriteInt(voiceData.pitchOffset or 0, 8)
                    net.WriteFloat(voiceData.volumeOffset or 0)
                net.Send(ply)
                break
            end
        end
    end
end

-- ============================================
-- NET RECEIVERS
-- ============================================

-- Player updates their voice
net.Receive("GlitchLab_VoiceUpdate", function(len, ply)
    if not IsValid(ply) then return end
    
    local voiceId = net.ReadString()
    local pitchOffset = net.ReadInt(8)
    local volumeOffset = net.ReadFloat()
    
    -- Rate limiting - prevent spam
    ply.LastVoiceUpdate = ply.LastVoiceUpdate or 0
    if CurTime() - ply.LastVoiceUpdate < 1 then
        return  -- Too fast, ignore
    end
    ply.LastVoiceUpdate = CurTime()
    
    GlitchLab.SetPlayerVoice(ply, voiceId, pitchOffset, volumeOffset)
    
    MsgC(Color(177, 102, 199), "[GlitchLab] ")
    MsgC(Color(100, 255, 100), ply:Nick() .. " changed voice to: " .. voiceId .. "\n")
end)

-- Player requests all voices (on join)
net.Receive("GlitchLab_VoiceRequest", function(len, ply)
    if not IsValid(ply) then return end
    GlitchLab.SendAllVoices(ply)
end)

-- ============================================
-- PLAYER HOOKS
-- ============================================

hook.Add("PlayerInitialSpawn", "GlitchLab_LoadVoice", function(ply)
    if not IsValid(ply) then return end
    
    timer.Simple(2, function()
        if not IsValid(ply) then return end
        
        -- Load saved voice
        local voiceData = LoadPlayerVoice(ply)
        if voiceData then
            GlitchLab.PlayerVoices[ply:SteamID64()] = voiceData
            GlitchLab.BroadcastVoice(ply, voiceData)
            
            MsgC(Color(177, 102, 199), "[GlitchLab] ")
            MsgC(Color(255, 255, 255), "Loaded voice for " .. ply:Nick() .. ": " .. voiceData.voiceId .. "\n")
        end
        
        -- Send all voices to this player
        GlitchLab.SendAllVoices(ply)
    end)
end)

hook.Add("PlayerDisconnected", "GlitchLab_CleanupVoice", function(ply)
    -- Keep in memory for reconnects, will be overwritten anyway
end)

-- ============================================
-- CONSOLE COMMANDS (Admin)
-- ============================================

concommand.Add("uc_voice_list_players", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[UnderComms] Admin only!")
        return
    end
    
    print("\n=== Player Voices ===")
    for _, p in ipairs(player.GetAll()) do
        local voice = GlitchLab.GetPlayerVoice(p)
        print(string.format("  %s: %s (pitch %+d, vol %+.2f)", 
            p:Nick(), 
            voice.voiceId, 
            voice.pitchOffset, 
            voice.volumeOffset
        ))
    end
    print("=====================\n")
end)

concommand.Add("uc_voice_reset", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[UnderComms] Admin only!")
        return
    end
    
    local target = args[1]
    if not target then
        print("Usage: uc_voice_reset <name or steamid>")
        return
    end
    
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Nick()), string.lower(target)) or p:SteamID64() == target then
            GlitchLab.SetPlayerVoice(p, "default", 0, 0)
            print("[UnderComms] Reset voice for " .. p:Nick())
            return
        end
    end
    
    print("[UnderComms] Player not found: " .. target)
end)

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), "Voice server system initialized\n")