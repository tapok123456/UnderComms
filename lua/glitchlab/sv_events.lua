--[[
    GlitchLab | UnderComms — Events System (Server)
    
    v0.6.0 — EVENTS EDITION
    
    Server-side API to trigger events for players
    "All your players are belong to us"
]]

GlitchLab.Events = GlitchLab.Events or {}

local events = GlitchLab.Events

-- ============================================
-- TRIGGER EVENT FOR PLAYERS
-- ============================================

function GlitchLab.Event(title, text, options, recipients)
    options = options or {}
    recipients = recipients or player.GetAll()
    
    -- Handle single player (FIXED type check)
    if IsValid(recipients) and recipients:IsPlayer() then
        recipients = {recipients}
    end
    
    -- Validate recipients
    if not recipients or type(recipients) ~= "table" or #recipients == 0 then
        if GlitchLab.Log and GlitchLab.Log.Warn then
            GlitchLab.Log.Warn("Event triggered with no valid recipients: " .. (title or "Unknown"))
        end
        return
    end
    
    local eventType = options.type or "info"
    local duration = options.duration or 3
    local shake = options.shake ~= false
    local sound = options.sound ~= false
    
    net.Start("GlitchLab_Event")
        net.WriteString(title or "EVENT")
        net.WriteString(text or "")
        net.WriteString(eventType)
        net.WriteFloat(duration)
        net.WriteBool(shake)
        net.WriteBool(sound)
    net.Send(recipients)
    
    -- Log
    if GlitchLab.Log and GlitchLab.Log.Info then
        local recipientCount = #recipients
        GlitchLab.Log.Info(string.format("Event triggered: [%s] %s (to %d players)", 
            eventType, title, recipientCount))
    end
end

-- Alias
GlitchLab.TriggerEvent = GlitchLab.Event

-- ============================================
-- BROADCAST TO ALL
-- ============================================

function GlitchLab.EventBroadcast(title, text, options)
    GlitchLab.Event(title, text, options, player.GetAll())
end

-- ============================================
-- SEND TO SPECIFIC PLAYER
-- ============================================

function GlitchLab.EventToPlayer(ply, title, text, options)
    if not IsValid(ply) then return end
    GlitchLab.Event(title, text, options, {ply})
end

-- ============================================
-- SEND TO TEAM
-- ============================================

function GlitchLab.EventToTeam(teamId, title, text, options)
    local players = team.GetPlayers(teamId)
    if #players > 0 then
        GlitchLab.Event(title, text, options, players)
    end
end

-- ============================================
-- CONSOLE COMMANDS (admin only)
-- ============================================

concommand.Add("uc_sv_event", function(ply, cmd, args)
    -- Check if server console or admin
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[UnderComms] You need admin privileges for this.")
        return
    end
    
    local title = args[1] or "SERVER EVENT"
    local text = args[2] or "This is a server event."
    local eventType = args[3] or "info"
    
    GlitchLab.EventBroadcast(title, text, {type = eventType})
    
    print("[UnderComms] Event broadcast: " .. title)
end, nil, "Broadcast event to all players (admin)")

concommand.Add("uc_sv_event_warning", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    GlitchLab.EventBroadcast("⚠ SERVER WARNING ⚠", "The server will restart in 5 minutes!", {
        type = "warning",
        duration = 5
    })
end)

concommand.Add("uc_sv_event_story", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    GlitchLab.EventBroadcast("CHAPTER 1", "* A new adventure begins...", {
        type = "story",
        duration = 5
    })
end)

-- ============================================
-- EXAMPLE HOOKS (uncomment to use)
-- ============================================

--[[
-- Player death event
hook.Add("PlayerDeath", "GlitchLab_DeathEvent", function(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim then
        GlitchLab.EventToPlayer(attacker, "KILL", victim:Nick() .. " was eliminated.", {
            type = "success",
            duration = 2
        })
    end
end)

-- Round start (TTT example)
hook.Add("TTTBeginRound", "GlitchLab_RoundStart", function()
    GlitchLab.EventBroadcast("ROUND START", "Find the traitors!", {
        type = "warning",
        duration = 3
    })
end)
]]

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), "Server events API loaded (v0.6.0)\n")