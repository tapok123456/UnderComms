--[[
    GlitchLab | UnderComms — Server Chat Handler
    
    v0.8.0 — REFACTORED EDITION
    
    Removed 400 lines of duplicate code because
    copy-paste is the devil's programming pattern
    
    "DRY or die trying" — Every senior dev ever
]]

GlitchLab.Chat = GlitchLab.Chat or {}

local cfg = GlitchLab.Config

local function dbg(...)
    if cfg.DebugMode then
        MsgC(Color(177, 102, 199), "[GlitchLab:SV] ")
        MsgC(Color(255, 255, 255), string.format(...) .. "\n")
    end
end

-- ============================================
-- AUTOMATIC COMMAND DETECTION
-- ============================================

-- Our style prefixes (we handle these)
local OUR_PREFIXES = {}

local function BuildOurPrefixes()
    OUR_PREFIXES = {}
    
    for styleName, style in pairs(cfg.Styles) do
        if style.prefix then
            OUR_PREFIXES[string.lower(style.prefix)] = true
        end
        if style.altPrefix then
            OUR_PREFIXES[string.lower(style.altPrefix)] = true
        end
    end
    
    dbg("Built our prefixes: %d total", table.Count(OUR_PREFIXES))
end

-- Build on load and when config changes
hook.Add("Initialize", "GlitchLab_BuildPrefixes", function()
    timer.Simple(0.1, BuildOurPrefixes)
end)
BuildOurPrefixes()

-- Check if this is one of OUR commands
local function IsOurCommand(text)
    local lowerText = string.lower(text)
    
    for prefix, _ in pairs(OUR_PREFIXES) do
        if string.StartWith(lowerText, prefix .. " ") or lowerText == prefix then
            return true
        end
    end
    
    return false
end

-- ============================================
-- DARKRP COMMAND DETECTION (automatic)
-- ============================================

local function IsDarkRPCommand(text)
    if not DarkRP then return false end
    
    local lowerText = string.lower(text)
    
    -- Check if starts with /
    if not string.StartWith(lowerText, "/") then return false end
    
    -- Extract command name
    local cmd = string.match(lowerText, "^(/[a-z0-9_]+)")
    if not cmd then return false end
    
    -- Skip if it's our command
    if OUR_PREFIXES[cmd] then return false end
    
    -- Check DarkRP chat commands
    if DarkRP.chatCommands then
        local cmdName = string.sub(cmd, 2)  -- remove /
        if DarkRP.chatCommands[cmdName] then
            return true, cmd
        end
    end
    
    -- Check DarkRP definedChatCommands (older versions)
    if DarkRP.definedChatCommands then
        local cmdName = string.sub(cmd, 2)
        if DarkRP.definedChatCommands[cmdName] then
            return true, cmd
        end
    end
    
    -- Fallback: check common DarkRP commands that might not be in table
    local commonDarkRP = {
        "/advert", "/ad", "/broadcast",
        "/g", "/group", "/pm",
        "/911", "/999", "/cr",
        "/wanted", "/unwanted", "/warrant", "/unwarrant",
        "/lockdown", "/unlockdown",
        "/job", "/buy", "/sell", "/drop", "/give",
        "/cheque", "/check", "/lottery",
        "/report", "/demote", "/vote",
        "/roll", "/it", "/act", "/e", "/emote",
        "/help", "/motd", "/rules",
        "/addmoney", "/setmoney", "/money",
        "/arrest", "/unarrest", "/jailpos",
        "/setjailpos", "/addentity", "/removeentity",
    }
    
    for _, darkCmd in ipairs(commonDarkRP) do
        if string.StartWith(lowerText, darkCmd .. " ") or lowerText == darkCmd then
            return true, darkCmd
        end
    end
    
    return false
end

-- ============================================
-- TTT COMPATIBILITY
-- ============================================

local function IsTTTActive()
    return engine.ActiveGamemode() == "terrortown" or 
           (GAMEMODE and GAMEMODE.Name == "Trouble in Terrorist Town")
end

local function FilterTTTRecipients(sender, recipientData)
    if not IsTTTActive() then return recipientData end
    
    local filtered = {}
    local senderAlive = IsValid(sender) and sender:Alive()
    local senderSpec = IsValid(sender) and (sender.IsSpec and sender:IsSpec() or false)
    
    for _, data in ipairs(recipientData) do
        local ply = data.player
        if not IsValid(ply) then continue end
        
        local plyAlive = ply:Alive()
        local plySpec = ply.IsSpec and ply:IsSpec() or false
        
        if not senderAlive or senderSpec then
            if not plyAlive or plySpec then
                table.insert(filtered, data)
            end
        else
            table.insert(filtered, data)
        end
    end
    
    return filtered
end

-- ============================================
-- ULX/ULIB COMMAND DETECTION (automatic)
-- ============================================

local function IsULXCommand(text)
    -- ! commands
    if string.StartWith(text, "!") then
        -- Check if ULib knows this command
        if ULib and ULib.cmds and ULib.cmds.translatedCmds then
            local cmd = string.match(text, "^!([a-z0-9_]+)")
            if cmd and ULib.cmds.translatedCmds["ulx " .. cmd] then
                return true
            end
        end
        -- Even without ULib table, ! prefix usually means admin command
        return true
    end
    
    -- @ admin chat
    if string.StartWith(text, "@") then
        return true
    end
    
    -- /ulx commands
    if string.StartWith(string.lower(text), "/ulx") then
        return true
    end
    
    return false
end

-- ============================================
-- SAM COMMAND DETECTION
-- ============================================

local function IsSAMCommand(text)
    if not sam then return false end
    
    -- ! commands
    if string.StartWith(text, "!") then
        return true
    end
    
    -- . commands (but not .// which is our LOOC)
    if string.StartWith(text, ".") and not string.StartWith(text, ".//") then
        if #text > 1 and string.match(text, "^%.[a-zA-Z]") then
            return true
        end
    end
    
    return false
end

-- ============================================
-- SERVERGUARD COMMAND DETECTION
-- ============================================

local function IsServerGuardCommand(text)
    if not serverguard then return false end
    
    if string.StartWith(text, "!") then return true end
    if string.StartWith(string.lower(text), "/sg") then return true end
    
    return false
end

-- ============================================
-- MAESTRO COMMAND DETECTION
-- ============================================

local function IsMaestroCommand(text)
    if not maestro then return false end
    if string.StartWith(text, "!") then return true end
    return false
end

-- ============================================
-- GENERIC SLASH COMMAND DETECTION
-- For any addon that registers / commands
-- ============================================

local function IsGenericSlashCommand(text)
    if not string.StartWith(text, "/") then return false end
    
    -- Skip if it's our command
    local lowerText = string.lower(text)
    for prefix, _ in pairs(OUR_PREFIXES) do
        if string.StartWith(lowerText, prefix .. " ") or lowerText == prefix then
            return false
        end
    end
    
    -- Check concommand exists
    local cmd = string.match(text, "^/([a-z0-9_]+)")
    if cmd then
        -- Many addons register say commands as concommands
        if concommand.GetTable()["say_" .. cmd] then
            return true
        end
        if concommand.GetTable()[cmd] then
            return true
        end
    end
    
    -- If it starts with / and is not ours, assume it might be another addon
    -- Better to let it through than block it
    local cmdPart = string.match(text, "^(/[a-z0-9_]+)")
    if cmdPart and not OUR_PREFIXES[string.lower(cmdPart)] then
        -- Check if there are any hooks that might handle it
        -- This is a heuristic - if in doubt, let it through
        return true
    end
    
    return false
end

-- ============================================
-- MAIN EXTERNAL COMMAND CHECK
-- ============================================

local function IsExternalCommand(text)
    -- First, check if it's definitely ours
    if IsOurCommand(text) then
        return false, nil
    end
    
    -- Check each addon system
    if IsDarkRPCommand(text) then return true, "DarkRP" end
    if IsULXCommand(text) then return true, "ULX" end
    if IsSAMCommand(text) then return true, "SAM" end
    if IsServerGuardCommand(text) then return true, "ServerGuard" end
    if IsMaestroCommand(text) then return true, "Maestro" end
    
    -- Generic fallback for unknown / commands
    if IsGenericSlashCommand(text) then return true, "Unknown" end
    
    return false, nil
end

-- ============================================
-- SANITIZE
-- ============================================

local function SanitizeMessage(text)
    if not text or type(text) ~= "string" then return "" end
    text = string.Trim(text)
    text = string.gsub(text, "%z", "")
    text = string.gsub(text, "[\r\n\t]", " ")
    text = string.gsub(text, "%s+", " ")
    if #text > cfg.MaxMessageLength then
        text = string.sub(text, 1, cfg.MaxMessageLength)
    end
    return text
end

-- ============================================
-- RATE LIMITER
-- ============================================

local rateLimits = {}
local RATE_WINDOW = 5
local RATE_MAX = 5

local function CheckRateLimit(ply)
    if not IsValid(ply) then return false end
    
    local sid = ply:SteamID()
    local now = CurTime()
    
    if not rateLimits[sid] then
        rateLimits[sid] = { lastMsg = now, count = 1 }
        return true
    end
    
    local data = rateLimits[sid]
    
    if now - data.lastMsg > RATE_WINDOW then
        data.count = 1
        data.lastMsg = now
        return true
    end
    
    data.count = data.count + 1
    data.lastMsg = now
    
    return data.count <= RATE_MAX
end

hook.Add("PlayerDisconnected", "GlitchLab_CleanRateLimit", function(ply)
    if IsValid(ply) then
        rateLimits[ply:SteamID()] = nil
    end
end)

-- ============================================
-- PARSE STYLE FROM MESSAGE
-- ============================================

local function ParseMessageStyle(text)
    if not text or text == "" then return "direct", text end
    
    local lowerText = string.lower(text)
    
    for styleName, style in pairs(cfg.Styles) do
        local prefix = style.prefix
        if prefix then
            local prefixLower = string.lower(prefix)
            local prefixLen = #prefix
            
            if string.sub(lowerText, 1, prefixLen + 1) == prefixLower .. " " then
                local cleanText = string.Trim(string.sub(text, prefixLen + 2))
                return styleName, cleanText
            end
            
            if lowerText == prefixLower then
                return styleName, ""
            end
        end
        
        local altPrefix = style.altPrefix
        if altPrefix then
            local altLower = string.lower(altPrefix)
            local altLen = #altPrefix
            
            if string.sub(lowerText, 1, altLen + 1) == altLower .. " " then
                local cleanText = string.Trim(string.sub(text, altLen + 2))
                return styleName, cleanText
            end
            
            if string.sub(text, 1, altLen) == altPrefix then
                local cleanText = string.Trim(string.sub(text, altLen + 1))
                return styleName, cleanText
            end
        end
    end
    
    return "direct", text
end

-- ============================================
-- PROXIMITY: GET RECIPIENTS BY DISTANCE
-- ============================================

local function GetProximityRecipients(sender, style, isTeam)
    local proximityCfg = cfg.Proximity or {}
    local recipients = {}
    
    -- DEBUG: Print what's happening
    print("[PROXIMITY DEBUG]")
    print("  Style:", style.name or "unknown")
    print("  proximityCfg.Enabled:", proximityCfg.Enabled)
    print("  style.global:", style.global)
    print("  style.proximity:", style.proximity)
    print("  style.hearDistance:", style.hearDistance)
    
    local playersToCheck = isTeam and team.GetPlayers(sender:Team()) or player.GetAll()
    
    -- If proximity disabled or global style, everyone gets the message
    if not proximityCfg.Enabled or style.global or not style.proximity then
        print("  RESULT: Global (everyone receives)")
        for _, ply in ipairs(playersToCheck) do
            if IsValid(ply) then
                table.insert(recipients, {
                    player = ply,
                    distance = 0,
                    inRange = true,
                })
            end
        end
        return recipients
    end
    
    local hearDistance = style.hearDistance or proximityCfg.DefaultDistance or 600
    local senderPos = sender:GetPos()
    
    for _, ply in ipairs(playersToCheck) do
        if not IsValid(ply) then continue end
        
        if ply == sender then
            table.insert(recipients, {
                player = ply,
                distance = 0,
                inRange = true,
            })
            continue
        end
        
        if proximityCfg.DeadCanHearAll and not ply:Alive() then
            table.insert(recipients, {
                player = ply,
                distance = 0,
                inRange = true,
                isDead = true,
            })
            continue
        end
        
        if proximityCfg.AdminCanHearAll and ply:IsAdmin() then
            table.insert(recipients, {
                player = ply,
                distance = 0,
                inRange = true,
                isAdmin = true,
            })
            continue
        end
        
        local distance = senderPos:Distance(ply:GetPos())
        
        if distance <= hearDistance then
            table.insert(recipients, {
                player = ply,
                distance = distance,
                inRange = true,
            })
        elseif proximityCfg.ShowOutOfRange then
            table.insert(recipients, {
                player = ply,
                distance = distance,
                inRange = false,
            })
        end
    end
    
    return recipients
end

-- ============================================
-- CALCULATE DISTANCE ALPHA
-- ============================================

local function CalculateDistanceAlpha(distance, style)
    local proximityCfg = cfg.Proximity or {}
    
    if not proximityCfg.FadeEnabled then return 255 end
    if not style.proximity then return 255 end
    
    local hearDistance = style.hearDistance or 600
    local fadeDistance = style.fadeDistance or (hearDistance * 1.3)
    
    if distance <= hearDistance then
        return 255
    elseif distance <= fadeDistance then
        local fadeProgress = (distance - hearDistance) / (fadeDistance - hearDistance)
        return math.floor(255 * (1 - fadeProgress * 0.5))
    else
        return 128
    end
end

-- ============================================
-- PROCESS CHAT MESSAGE (UNIFIED FUNCTION)
-- No more copy-paste bullshit
-- ============================================

local function ProcessChatMessage(ply, text, isTeam, source)
    if not IsValid(ply) then return false end
    
    -- Sanitize
    text = SanitizeMessage(text)
    if text == "" then return false end
    
    -- Check if external command
    local isExternal, addonName = IsExternalCommand(text)
    if isExternal then
        dbg("[%s] External command (%s), passing through: %s", source, addonName, text)
        return false  -- signal to pass through
    end
    
    -- Rate limit
    if not CheckRateLimit(ply) then
        net.Start(cfg.NetStrings.ReceiveMessage)
            net.WriteString("")
            net.WriteColor(Color(255, 51, 51))
            net.WriteString("* Slow down! You're sending messages too fast.")
            net.WriteColor(Color(255, 51, 51))
            net.WriteBool(true)
            net.WriteString("direct")
            net.WriteFloat(0)
            net.WriteUInt(255, 8)
            net.WriteUInt(0, 16)
        net.Send(ply)
        return true  -- handled (rate limited)
    end
    
    -- Parse style
    local styleName, cleanText = ParseMessageStyle(text)
    
    if cleanText == "" then
        dbg("[%s] Empty message after style parse from %s", source, ply:Nick())
        return true  -- handled (empty)
    end
    
    local style = cfg.Styles[styleName] or cfg.Styles.direct
    
    -- Format (apply string.upper/lower etc)
    local displayName = ply:Nick()
    local displayText = cleanText
    
    if style.format then
        -- Safely call format function with nil protection
        local success, formattedName, formattedText = pcall(style.format, ply:Nick(), cleanText)
        
        if success and formattedName and formattedText then
            displayName = formattedName
            displayText = formattedText
        else
            -- Format failed, log error
            if cfg.DebugMode then
                dbg("[%s] Format function failed for style %s: %s", source, styleName, tostring(formattedName))
            end
        end
    end
    
    -- Colors
    local nameColor = style.nameColor or team.GetColor(ply:Team())
    if not nameColor or (nameColor.r == 0 and nameColor.g == 0 and nameColor.b == 0) then
        nameColor = Color(255, 255, 100)
    end
    
    local textColor = style.textColor or Color(255, 255, 255)
    
    -- Get recipients
    local recipientData = GetProximityRecipients(ply, style, isTeam)
    
    -- TTT filter
    if IsTTTActive() then
        recipientData = FilterTTTRecipients(ply, recipientData)
    end
    
    -- Send to recipients
    for _, data in ipairs(recipientData) do
        if not IsValid(data.player) then continue end
        
        local alpha = CalculateDistanceAlpha(data.distance, style)
        
        local finalText = displayText
        if not data.inRange and cfg.Proximity and cfg.Proximity.ShowOutOfRange then
            finalText = "[inaudible]"
            alpha = 100
        end
        
        net.Start(cfg.NetStrings.ReceiveMessage)
            net.WriteString(displayName)
            net.WriteColor(nameColor)
            net.WriteString(finalText)
            net.WriteColor(textColor)
            net.WriteBool(false)
            net.WriteString(styleName)
            net.WriteFloat(data.distance)
            net.WriteUInt(alpha, 8)
            net.WriteUInt(ply:EntIndex(), 16)
        net.Send(data.player)
    end
    
    -- Log
    local recipientCount = #recipientData
    local rangeInfo = style.proximity and string.format(" (range: %d)", style.hearDistance or 600) or " (global)"
    dbg("[%s][%s] %s: %s — sent to %d players%s", 
        source, string.upper(styleName), ply:Nick(), cleanText, recipientCount, rangeInfo)
    
    if GlitchLab.Log and GlitchLab.Log.ChatMessage then
        GlitchLab.Log.ChatMessage(ply, "[" .. styleName .. "] " .. cleanText, isTeam)
    end
    
    -- Fire custom hook
    hook.Run("GlitchLab_PlayerSay", ply, text, isTeam, styleName, cleanText)
    
    return true  -- handled successfully
end

-- ============================================
-- MAIN CHAT HANDLER (PlayerSay hook)
-- ============================================

hook.Add("PlayerSay", "GlitchLab_ChatHandler", function(ply, text, isTeam)
    if not IsValid(ply) then return end
    
    local handled = ProcessChatMessage(ply, text, isTeam, "SAY")
    
    if handled == false then
        -- External command, let it through
        return
    end
    
    -- Suppress default chat
    return ""
end)

-- ============================================
-- NET RECEIVE (for long messages)
-- ============================================

net.Receive(cfg.NetStrings.SendMessage, function(len, ply)
    if not IsValid(ply) then return end
    
    local text = net.ReadString()
    local isTeam = net.ReadBool()
    
    ProcessChatMessage(ply, text, isTeam, "NET")
end)

-- ============================================
-- BROADCAST UTILITY
-- ============================================

function GlitchLab.Chat.Broadcast(text, textColor, recipients, styleName)
    textColor = textColor or Color(177, 102, 199)
    recipients = recipients or player.GetAll()
    styleName = styleName or "direct"
    
    net.Start(cfg.NetStrings.ReceiveMessage)
        net.WriteString("")
        net.WriteColor(Color(177, 102, 199))
        net.WriteString(text)
        net.WriteColor(textColor)
        net.WriteBool(true)
        net.WriteString(styleName)
        net.WriteFloat(0)
        net.WriteUInt(255, 8)
        net.WriteUInt(0, 16)
    net.Send(recipients)
end

function GlitchLab.Chat.BroadcastInRange(pos, range, text, textColor, styleName)
    textColor = textColor or Color(177, 102, 199)
    styleName = styleName or "direct"
    
    local recipients = {}
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetPos():Distance(pos) <= range then
            table.insert(recipients, ply)
        end
    end
    
    if #recipients > 0 then
        GlitchLab.Chat.Broadcast(text, textColor, recipients, styleName)
    end
end

-- ============================================
-- WELCOME MESSAGE
-- ============================================

hook.Add("PlayerInitialSpawn", "GlitchLab_WelcomeMessage", function(ply)
    timer.Simple(3, function()
        if not IsValid(ply) then return end
        
        net.Start(cfg.NetStrings.ReceiveMessage)
            net.WriteString("")
            net.WriteColor(Color(177, 102, 199))
            net.WriteString("* Welcome to UnderComms. Stay determined.")
            net.WriteColor(Color(177, 102, 199))
            net.WriteBool(true)
            net.WriteString("direct")
            net.WriteFloat(0)
            net.WriteUInt(255, 8)
            net.WriteUInt(0, 16)
        net.Send(ply)
    end)
end)

-- ============================================
-- CONSOLE COMMANDS
-- ============================================

concommand.Add("uc_proximity_toggle", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[UnderComms] SuperAdmin only!")
        return
    end
    
    cfg.Proximity.Enabled = not cfg.Proximity.Enabled
    local status = cfg.Proximity.Enabled and "ENABLED" or "DISABLED"
    
    GlitchLab.Chat.Broadcast("* Proximity chat " .. status, Color(255, 200, 100))
    
    print("[UnderComms] Proximity chat: " .. status)
end, nil, "Toggle proximity chat system")

concommand.Add("uc_proximity_status", function(ply)
    print("\n=== Proximity Chat Status ===")
    print("Enabled:", cfg.Proximity.Enabled)
    print("Default Distance:", cfg.Proximity.DefaultDistance)
    print("Fade Enabled:", cfg.Proximity.FadeEnabled)
    print("Dead Hear All:", cfg.Proximity.DeadCanHearAll)
    print("Admin Hear All:", cfg.Proximity.AdminCanHearAll)
    print("\nStyle Distances:")
    for name, style in pairs(cfg.Styles) do
        if style.proximity then
            print(string.format("  %s: %d units", name, style.hearDistance or 600))
        else
            print(string.format("  %s: GLOBAL", name))
        end
    end
    print("=============================\n")
end, nil, "Show proximity chat status")

concommand.Add("uc_compat_status", function(ply)
    print("\n=== Addon Compatibility Status ===")
    print("DarkRP:", DarkRP and "DETECTED" or "not found")
    print("ULX/ULib:", ULib and "DETECTED" or "not found")
    print("SAM:", sam and "DETECTED" or "not found")
    print("ServerGuard:", serverguard and "DETECTED" or "not found")
    print("Maestro:", maestro and "DETECTED" or "not found")
    print("TTT:", IsTTTActive() and "ACTIVE" or "not active")
    print("==================================\n")
end, nil, "Show addon compatibility status")

-- ============================================
-- STARTUP
-- ============================================

hook.Add("Initialize", "GlitchLab_CompatCheck", function()
    timer.Simple(1, function()
        local detected = {}
        
        if DarkRP then 
            table.insert(detected, "DarkRP")
            
            -- Count DarkRP commands
            local cmdCount = 0
            if DarkRP.chatCommands then
                cmdCount = table.Count(DarkRP.chatCommands)
            elseif DarkRP.definedChatCommands then
                cmdCount = table.Count(DarkRP.definedChatCommands)
            end
            
            if cmdCount > 0 then
                MsgC(Color(177, 102, 199), "[GlitchLab] ")
                MsgC(Color(255, 255, 255), string.format("Found %d DarkRP commands\n", cmdCount))
            end
        end
        
        if ULib then 
            table.insert(detected, "ULX")
            
            if ULib.cmds and ULib.cmds.translatedCmds then
                local cmdCount = table.Count(ULib.cmds.translatedCmds)
                MsgC(Color(177, 102, 199), "[GlitchLab] ")
                MsgC(Color(255, 255, 255), string.format("Found %d ULX commands\n", cmdCount))
            end
        end
        
        if sam then table.insert(detected, "SAM") end
        if serverguard then table.insert(detected, "ServerGuard") end
        if maestro then table.insert(detected, "Maestro") end
        
        if #detected > 0 then
            MsgC(Color(177, 102, 199), "[GlitchLab] ")
            MsgC(Color(100, 255, 100), "Detected addons: " .. table.concat(detected, ", ") .. "\n")
        end
        
        if IsTTTActive() then
            MsgC(Color(177, 102, 199), "[GlitchLab] ")
            MsgC(Color(100, 255, 100), "TTT gamemode detected, dead chat filtering enabled\n")
        end
        
        MsgC(Color(177, 102, 199), "[GlitchLab] ")
        MsgC(Color(255, 255, 255), string.format("Our prefixes: %s\n", table.concat(table.GetKeys(OUR_PREFIXES), ", ")))
    end)
end)

dbg("sv_chat.lua v0.8.0 loaded — refactored, no duplicates")