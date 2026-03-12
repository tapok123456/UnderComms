--[[
    GlitchLab | UnderComms — Chatbox UI
    
    v0.9.0 — ULTIMATE SETTINGS EDITION
    
    This file is thicc af. Like seriously, it's the
    backbone of the whole damn chat system.
    All settings actually work now. You're welcome.
]]

GlitchLab.Chatbox = GlitchLab.Chatbox or {}

local cfg = GlitchLab.Config
local chatbox = GlitchLab.Chatbox

-- Load subsystems
if not GlitchLab.InputHistory then include("glitchlab/cl_input_history.lua") end
if not GlitchLab.Autocomplete then include("glitchlab/cl_autocomplete.lua") end
if not GlitchLab.LinkParser then include("glitchlab/cl_links.lua") end
if not GlitchLab.Sprites then include("glitchlab/cl_sprites.lua") end

local sprites = GlitchLab.Sprites

-- ============================================
-- THEME HELPER
-- ============================================

local function T(key, fallback)
    local theme = GlitchLab.Theme
    if theme and theme[key] then
        return theme[key]
    end
    return fallback or Color(255, 255, 255)
end

local function GetStyleColors(styleName)
    local theme = GlitchLab.Theme
    if theme and theme.styles and theme.styles[styleName] then
        return theme.styles[styleName]
    end
    return {text = Color(255, 255, 255), name = nil}
end

-- ============================================
-- SETTINGS HELPERS (CACHED)
-- ============================================

local function S()
    if GlitchLab.Settings and GlitchLab.Settings.Cache then
        return GlitchLab.Settings.Cache
    end
    return {}
end

local function GetSetting(name)
    if GlitchLab.Settings and GlitchLab.Settings.GetBool then
        return GlitchLab.Settings.GetBool(name)
    end
    local cvar = GetConVar("uc_" .. name)
    return cvar and cvar:GetBool() or true
end

local function GetSettingInt(name)
    if GlitchLab.Settings and GlitchLab.Settings.GetInt then
        return GlitchLab.Settings.GetInt(name)
    end
    local cvar = GetConVar("uc_" .. name)
    return cvar and cvar:GetInt() or 0
end

local function GetSettingFloat(name)
    if GlitchLab.Settings and GlitchLab.Settings.GetFloat then
        return GlitchLab.Settings.GetFloat(name)
    end
    local cvar = GetConVar("uc_" .. name)
    return cvar and cvar:GetFloat() or 1.0
end

-- ============================================
-- SCALE HELPERS
-- ============================================

local function GetLineHeight()
    if GlitchLab.Settings and GlitchLab.Settings.GetLineHeight then
        return GlitchLab.Settings.GetLineHeight()
    end
    return 20
end

local function GetIconSize()
    if GlitchLab.Settings and GlitchLab.Settings.GetIconSize then
        return GlitchLab.Settings.GetIconSize()
    end
    return 16
end

local function GetAvatarSize()
    if GlitchLab.Settings and GlitchLab.Settings.GetAvatarSize then
        return GlitchLab.Settings.GetAvatarSize()
    end
    return 18
end

-- ============================================
-- LETTER STYLE COLORS
-- ============================================

local PAPER_COLORS = {
    background = Color(245, 235, 220, 250),
    border = Color(180, 150, 100, 200),
    lines = Color(200, 180, 160, 80),
    ink = Color(50, 35, 25),
    shadow = Color(30, 20, 15, 100),
}

-- ============================================
-- STATE
-- ============================================

chatbox.IsOpen = false
chatbox.IsTeamChat = false
chatbox.Messages = {}
chatbox.Frame = nil
chatbox.MessagePanel = nil
chatbox.InputPanel = nil
chatbox.BoxAlpha = 0
chatbox.Draft = ""
chatbox.UserScrolledUp = false

-- ============================================
-- SOUND SYSTEM
-- ============================================

local BLIP_SOUND = "chat/radio/hiss.wav"
local MORSE_SOUND = "chat/telegraph.wav"
local PAPER_SOUND = "physics/cardboard/cardboard_box_impact_soft1.wav"

local RADIO_BLIP_SOUNDS = {
    "chat/radio/radio_talk.wav",
}

local STATIC_SOUNDS = {
    "chat/radio/squelch-01.wav",
    "chat/radio/squelch-02.wav",
    "chat/radio/squelch-03.wav",
    "chat/radio/squelch-04.wav",
    "chat/radio/squelch-05.wav",
    "chat/radio/squelch-06.wav",
    "chat/radio/radio.wav",
    "chat/radio/beep.wav",
    "chat/radio/roger_beep.wav",
}

local BLIP_COOLDOWN = 0.015
local lastBlipTime = 0
local activeTypingMessages = 0
local MAX_TYPING_SOUNDS = 3
local activeRadioHiss = {}

-- ============================================
-- SOUND FUNCTIONS
-- ============================================

local function PlayBlip(pitch, volume, sound)
    if not GetSetting("blip_enabled") then return end
    if not pitch or pitch <= 0 then return end
    if not volume or volume <= 0 then return end
    
    if activeTypingMessages > MAX_TYPING_SOUNDS then return end
    
    local volMult = GetSettingInt("blip_volume") / 100
    volume = volume * volMult
    if volume <= 0.01 then return end
    
    local now = CurTime()
    local cooldown = GetSettingInt("blip_cooldown") / 1000
    if cooldown <= 0 then cooldown = 0.015 end
    if now - lastBlipTime < cooldown then return end
    lastBlipTime = now
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    sound = sound or BLIP_SOUND
    ply:EmitSound(sound, 50, pitch, volume, CHAN_STATIC)
end

local function PlayBlipForPlayer(senderPly, pitch, volume)
    if not GetSetting("blip_enabled") then return end
    
    local maxBlips = GetSettingInt("max_blips")
    if maxBlips <= 0 then maxBlips = 3 end
    if activeTypingMessages > maxBlips then return end
    
    local volMult = GetSettingInt("blip_volume") / 100
    volume = (volume or 0.3) * volMult
    if volume <= 0.01 then return end
    
    local cooldown = GetSettingInt("blip_cooldown") / 1000
    if cooldown <= 0 then cooldown = 0.015 end
    local now = CurTime()
    if now - lastBlipTime < cooldown then return end
    lastBlipTime = now
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    -- Get voice settings if available
    local voice, pitchOffset, volumeOffset
    local hearOthers = GetSetting("voice_hear_others")
    
    if IsValid(senderPly) and hearOthers and GlitchLab.GetPlayerVoiceClient then
        voice, pitchOffset, volumeOffset = GlitchLab.GetPlayerVoiceClient(senderPly)
    end
    
    if not voice or not voice.sound then
        ply:EmitSound(BLIP_SOUND, 50, pitch or 100, volume, CHAN_STATIC)
        return
    end
    
    pitchOffset = pitchOffset or 0
    volumeOffset = volumeOffset or 0
    
    local finalPitch = pitch or math.random(voice.pitchMin or 90, voice.pitchMax or 110)
    finalPitch = finalPitch + pitchOffset
    
    if voice.randomPitchPerChar then
        finalPitch = math.random(voice.pitchMin or 30, voice.pitchMax or 170) + pitchOffset
    end
    
    local finalVolume = math.Clamp(volume + volumeOffset, 0.05, 1.0)
    local soundPath = voice.sound or BLIP_SOUND
    
    ply:EmitSound(soundPath, 50, finalPitch, finalVolume, CHAN_STATIC)
end

local function PlayRadioBlip(pitch, volume)
    if not GetSetting("blip_enabled") then return end
    if not GetSetting("radio_static") then return end
    if not pitch or pitch <= 0 then return end
    if not volume or volume <= 0 then return end
    
    local volMult = GetSettingInt("radio_volume") / 100
    volume = volume * volMult
    if volume <= 0.01 then return end
    
    local now = CurTime()
    if now - lastBlipTime < BLIP_COOLDOWN then return end
    lastBlipTime = now
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local blipSound = RADIO_BLIP_SOUNDS[math.random(#RADIO_BLIP_SOUNDS)]
    ply:EmitSound(blipSound, 45, pitch, volume * 0.8, CHAN_STATIC)
    
    if GetSetting("radio_crackle") and math.random() > 0.85 then
        local crackle = STATIC_SOUNDS[math.random(#STATIC_SOUNDS)]
        ply:EmitSound(crackle, 25, math.random(80, 120), volume * 0.15, CHAN_AUTO)
    end
end

local function PlayMorseBeep(long, pitchMin, pitchMax, volume)
    if not GetSetting("telegraph_enabled") then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    pitchMin = pitchMin or 400
    pitchMax = pitchMax or 600
    volume = volume or 0.25
    
    local volMult = GetSettingInt("telegraph_volume") / 100
    volume = volume * volMult
    if volume <= 0.01 then return end
    
    local basePitch = long and pitchMin or pitchMax
    local pitch = basePitch + math.random(-20, 20)
    
    ply:EmitSound(MORSE_SOUND, 40, pitch, volume, CHAN_STATIC)
end

local function StartRadioHiss(msgId)
    if not GetSetting("radio_static") then return end
    if not msgId then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    if activeRadioHiss[msgId] then return end
    
    local timerName = "RadioHiss_" .. tostring(msgId)
    activeRadioHiss[msgId] = timerName
    
    local radioVol = GetSettingInt("radio_volume") / 100
    if radioVol <= 0.01 then return end
    
    timer.Create(timerName, 0.08, 0, function()
        if not GetSetting("radio_static") then
            timer.Remove(timerName)
            activeRadioHiss[msgId] = nil
            return
        end
        
        if not IsValid(ply) then
            timer.Remove(timerName)
            activeRadioHiss[msgId] = nil
            return
        end
        
        if not activeRadioHiss[msgId] then
            timer.Remove(timerName)
            return
        end
        
        local vol = GetSettingInt("radio_volume") / 100
        
        if math.random() > 0.6 then
            local pitch = math.random(40, 100)
            local v = (0.01 + math.random() * 0.02) * vol
            ply:EmitSound(STATIC_SOUNDS[math.random(#STATIC_SOUNDS)], 15, pitch, v, CHAN_AUTO)
        end
    end)
end

local function StopRadioHiss(msgId)
    if not msgId then return end
    
    local timerName = activeRadioHiss[msgId]
    if timerName then
        timer.Remove(timerName)
        activeRadioHiss[msgId] = nil
    end
end

local function PlayStaticBurst(duration)
    if not GetSetting("radio_static") then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local vol = GetSettingInt("radio_volume") / 100
    if vol <= 0.01 then return end
    
    duration = duration or 0.5
    
    local staticSound = STATIC_SOUNDS[math.random(#STATIC_SOUNDS)]
    ply:EmitSound(staticSound, 45, math.random(85, 115), 0.25 * vol, CHAN_STATIC)
    
    local numCrackles = math.floor(duration / 0.08)
    for i = 1, numCrackles do
        timer.Simple(i * 0.06 + math.random() * 0.04, function()
            if not GetSetting("radio_static") then return end
            if not IsValid(ply) then return end
            
            local v = GetSettingInt("radio_volume") / 100
            local crackleSound = STATIC_SOUNDS[math.random(#STATIC_SOUNDS)]
            local pitch = math.random(60, 140)
            local crackleVol = (0.08 + math.random() * 0.12) * v
            ply:EmitSound(crackleSound, 35, pitch, crackleVol, CHAN_STATIC)
        end)
    end
end

local function StartRadioStatic(duration)
    if not GetSetting("radio_static") then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    PlayStaticBurst(duration)
    
    local endTime = CurTime() + duration
    local timerName = "RadioStatic_" .. tostring(CurTime()) .. "_" .. math.random(1000, 9999)
    
    timer.Create(timerName, 0.025, 0, function()
        if CurTime() > endTime then
            timer.Remove(timerName)
            return
        end
        
        if not GetSetting("radio_static") then
            timer.Remove(timerName)
            return
        end
        
        if not IsValid(ply) then
            timer.Remove(timerName)
            return
        end
        
        local vol = GetSettingInt("radio_volume") / 100
        
        if math.random() > 0.5 then
            local pitch = math.random(40, 160)
            local v = (0.03 + math.random() * 0.06) * vol
            ply:EmitSound(STATIC_SOUNDS[math.random(#STATIC_SOUNDS)], 25, pitch, v, CHAN_AUTO)
        end
    end)
end

-- ============================================
-- ADAPTIVE SPEED
-- ============================================

local function CalculateAdaptiveSpeed(textLength, styleMult)
    local baseSpeed = GetSettingInt("type_speed")
    if baseSpeed <= 0 then baseSpeed = 60 end
    
    -- Instant mode
    if GetSetting("instant_messages") or GetSetting("no_animations") then
        return 9999
    end
    
    local minLen = cfg.ShortMessageLength or 10
    local maxLen = cfg.LongMessageLength or 150
    local minSpeed = 15
    local maxSpeed = baseSpeed
    
    local clampedLen = math.Clamp(textLength, minLen, maxLen)
    local t = (clampedLen - minLen) / (maxLen - minLen)
    local speed = Lerp(t, minSpeed, maxSpeed)
    
    return speed * (styleMult or 1.0)
end

-- ============================================
-- GLITCH CHARS
-- ============================================

local GLITCH_CHARS = {"#", "@", "!", "%", "&", "?", "/", "\\", "|", "~", "^", "*", "$"}

local function GetRandomGlitchChar()
    return GLITCH_CHARS[math.random(#GLITCH_CHARS)]
end

-- ============================================
-- DEBUG
-- ============================================

local function dbg(...)
    if GetSetting("debug") then
        MsgC(Color(177, 102, 199), "[GlitchLab] ")
        MsgC(Color(255, 255, 255), string.format(...) .. "\n")
    end
end

-- ============================================
-- UTF-8 HELPERS
-- ============================================

local function UTF8ToTable(str)
    local chars = {}
    if not str then return chars end
    
    local i = 1
    local len = #str
    
    while i <= len do
        local byte = string.byte(str, i)
        local charLen = 1
        
        if byte >= 0 and byte <= 127 then
            charLen = 1
        elseif byte >= 192 and byte <= 223 then
            charLen = 2
        elseif byte >= 224 and byte <= 239 then
            charLen = 3
        elseif byte >= 240 and byte <= 247 then
            charLen = 4
        end
        
        local char = string.sub(str, i, i + charLen - 1)
        table.insert(chars, char)
        i = i + charLen
    end
    
    return chars
end

local function UTF8Len(str)
    if not str then return 0 end
    return #UTF8ToTable(str)
end

local function UTF8Sub(str, startChar, endChar)
    local chars = UTF8ToTable(str)
    local result = {}
    endChar = endChar or #chars
    for i = startChar, math.min(endChar, #chars) do
        if chars[i] then table.insert(result, chars[i]) end
    end
    return table.concat(result)
end

-- ============================================
-- SCROLL
-- ============================================

local function ForceScrollToBottom()
    if not IsValid(chatbox.MessagePanel) then return end
    local vbar = chatbox.MessagePanel:GetVBar()
    if vbar then
        chatbox.MessagePanel:InvalidateLayout(true)
        chatbox.MessagePanel:GetCanvas():InvalidateLayout(true)
        vbar:SetScroll(vbar.CanvasSize + 9999)
    end
end

local function IsAtBottom()
    if not IsValid(chatbox.MessagePanel) then return true end
    local vbar = chatbox.MessagePanel:GetVBar()
    if not vbar then return true end
    return (vbar.CanvasSize - vbar:GetScroll()) < 50
end

local function SmartScroll()
    if chatbox.UserScrolledUp then return end
    ForceScrollToBottom()
end

-- ============================================
-- WRAP TEXT
-- ============================================

local function WrapText(text, font, maxWidth)
    if not text or text == "" then return {{chars = {}}} end
    if not maxWidth or maxWidth <= 0 then maxWidth = 400 end
    
    surface.SetFont(font)
    
    local allChars = UTF8ToTable(text)
    local lines = {}
    local currentLineChars = {}
    local currentWidth = 0
    local currentWordChars = {}
    local currentWordWidth = 0
    
    local function PushLine()
        if #currentLineChars > 0 then
            table.insert(lines, {chars = currentLineChars})
            currentLineChars = {}
            currentWidth = 0
        end
    end
    
    local function PushWord()
        if #currentWordChars == 0 then return end
        
        local spaceW = surface.GetTextSize(" ")
        local neededWidth = #currentLineChars == 0 
            and currentWordWidth 
            or (currentWidth + spaceW + currentWordWidth)
        
        if neededWidth <= maxWidth then
            if #currentLineChars > 0 then
                table.insert(currentLineChars, " ")
                currentWidth = currentWidth + spaceW
            end
            for _, c in ipairs(currentWordChars) do
                table.insert(currentLineChars, c)
            end
            currentWidth = currentWidth + currentWordWidth
        elseif currentWordWidth <= maxWidth then
            PushLine()
            for _, c in ipairs(currentWordChars) do
                table.insert(currentLineChars, c)
            end
            currentWidth = currentWordWidth
        else
            if #currentLineChars > 0 then PushLine() end
            for _, c in ipairs(currentWordChars) do
                local cw = surface.GetTextSize(c)
                if currentWidth + cw > maxWidth and #currentLineChars > 0 then
                    PushLine()
                end
                table.insert(currentLineChars, c)
                currentWidth = currentWidth + cw
            end
        end
        
        currentWordChars = {}
        currentWordWidth = 0
    end
    
    for _, char in ipairs(allChars) do
        if char == " " then
            PushWord()
        else
            table.insert(currentWordChars, char)
            currentWordWidth = currentWordWidth + surface.GetTextSize(char)
        end
    end
    
    PushWord()
    PushLine()
    
    return #lines > 0 and lines or {{chars = {}}}
end

-- ============================================
-- ADD MESSAGE
-- ============================================

function chatbox.AddMessage(sender, senderColor, text, textColor, isSystem, styleName, senderPly)
    local style = cfg.Styles[styleName] or cfg.Styles.direct
    
    local textLen = UTF8Len(text)
    local speed = CalculateAdaptiveSpeed(textLen, style.speedMult or 1.0)
    
    local msgId = tostring(CurTime()) .. "_" .. math.random(10000, 99999)
    
    local postGlitches = {}
    if style.radio then
        local numGlitches = math.random(2, 3)
        local glitchWindowStart = 5
        local glitchWindowEnd = math.random(15, 20)
        
        for i = 1, numGlitches do
            local glitchTime = glitchWindowStart + math.random() * (glitchWindowEnd - glitchWindowStart)
            table.insert(postGlitches, {
                time = glitchTime,
                triggered = false,
                duration = 0.3 + math.random() * 0.4
            })
        end
        
        table.sort(postGlitches, function(a, b) return a.time < b.time end)
    end
    
    local themeStyle = GetStyleColors(styleName or "direct")
    
    local msg = {
        sender = sender,
        senderPly = senderPly,
        senderColor = senderColor or themeStyle.name or T("playerName", Color(255, 255, 100)),
        text = text or "",
        textColor = textColor or themeStyle.text or style.textColor or T("textDefault", Color(255, 255, 255)),
        timestamp = CurTime(),
        realtime = os.time(),
        isSystem = isSystem or false,
        fullyDisplayed = false,
        finishedTime = nil,
        lastPlayedChar = 0,
        
        styleName = styleName or "direct",
        style = style,
        noColon = style.noColon or false,
        
        typeSpeed = speed,
        pitchMin = style.pitchMin or 90,
        pitchMax = style.pitchMax or 110,
        blipVolume = style.volume or 0.3,
        
        isTelegraph = style.telegraph or false,
        isRadio = style.radio or false,
        
        telegraphChunks = {},
        telegraphCurrentChunk = 0,
        
        glitchActive = false,
        glitchStartTime = 0,
        glitchDuration = 0,
        lastGlitchCheck = 0,
        shakeOffset = {x = 0, y = 0},
        
        postGlitches = postGlitches,
        glitchesFinished = not style.radio,
        
        msgId = msgId,
        radioHissStarted = false,
    }
    
    if msg.isTelegraph then
        local chars = UTF8ToTable(text)
        local chunkSize = style.chunkSize or 3
        local chunks = {}
        local currentChunk = {}
        
        for i, char in ipairs(chars) do
            table.insert(currentChunk, char)
            
            local thisChunkSize = chunkSize + math.random(-1, 1)
            thisChunkSize = math.max(1, thisChunkSize)
            
            if #currentChunk >= thisChunkSize or char == " " or char == "." then
                table.insert(chunks, table.concat(currentChunk))
                currentChunk = {}
            end
        end
        
        if #currentChunk > 0 then
            table.insert(chunks, table.concat(currentChunk))
        end
        
        msg.telegraphChunks = chunks
        msg.typeSpeed = 999
    end
    
    table.insert(chatbox.Messages, msg)
    
    -- Use settings for max messages
    local maxMsg = GetSettingInt("max_messages")
    if maxMsg <= 0 then maxMsg = 128 end
    while #chatbox.Messages > maxMsg do
        table.remove(chatbox.Messages, 1)
    end
    
    chatbox.UserScrolledUp = false
    
    dbg("Message [%s]: len=%d speed=%.1f id=%s", styleName, textLen, speed, msgId)
    
    return msg
end

-- ============================================
-- POSITION
-- ============================================

local function GetChatPosition()
    if GlitchLab.Settings and GlitchLab.Settings.GetChatPosition then
        return GlitchLab.Settings.GetChatPosition()
    end
    local scrW, scrH = ScrW(), ScrH()
    return cfg.ChatX, scrH - cfg.ChatHeight - cfg.ChatY, cfg.ChatWidth, cfg.ChatHeight
end

-- ============================================
-- MOUSE IN FRAME
-- ============================================

local function IsMouseInFrame()
    if not IsValid(chatbox.Frame) then return false end
    local mx, my = gui.MousePos()
    local fx, fy = chatbox.Frame:GetPos()
    local fw, fh = chatbox.Frame:GetSize()
    return mx >= fx and mx <= fx + fw and my >= fy and my <= fy + fh
end

-- ============================================
-- REFOCUS
-- ============================================

local function RefocusInput()
    if chatbox.IsOpen and IsValid(chatbox.InputPanel) then
        chatbox.InputPanel:RequestFocus()
    end
end

-- ============================================
-- SAFE CLOSE
-- ============================================

local function SafeClose()
    chatbox.IsOpen = false
    
    if IsValid(chatbox.Frame) then
        chatbox.Frame:SetMouseInputEnabled(false)
        chatbox.Frame:SetKeyboardInputEnabled(false)
    end
    
    if IsValid(chatbox.InputPanel) then
        chatbox.InputPanel:SetVisible(false)
        chatbox.InputPanel:KillFocus()
    end
    
    gui.EnableScreenClicker(false)
end

-- ============================================
-- BUILD
-- ============================================

function chatbox.Build()
    SafeClose()
    
    if IsValid(chatbox.Frame) then
        chatbox.Frame:Remove()
        chatbox.Frame = nil
    end
    
    local x, y, w, h = GetChatPosition()
    local borderThickness = GetSettingInt("border_thickness")
    if borderThickness <= 0 then borderThickness = 2 end
    local inputHeight = GetSettingInt("input_height")
    if inputHeight <= 0 then inputHeight = 32 end
    
    local frame = vgui.Create("DFrame")
    frame:SetPos(x, y)
    frame:SetSize(w, h)
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetDeleteOnClose(false)
    frame:SetMouseInputEnabled(false)
    frame:SetKeyboardInputEnabled(false)
    
    frame.Paint = function(self, pw, ph)
        if chatbox.BoxAlpha < 0.01 then return end

        local alpha = chatbox.BoxAlpha
        local customColors = GetSetting("custom_colors")
        
        -- Background
        local bgCol
        if customColors then
            local r = GetSettingInt("color_bg_r")
            local g = GetSettingInt("color_bg_g")
            local b = GetSettingInt("color_bg_b")
            local opacity = GetSettingInt("bg_opacity") / 100
            bgCol = Color(r, g, b, 255 * opacity)
        else
            bgCol = T("chatBg", Color(10, 10, 10, 230))
        end
        
        draw.RoundedBox(0, 0, 0, pw, ph, Color(bgCol.r, bgCol.g, bgCol.b, bgCol.a * alpha))

        -- Border
        local bt = borderThickness
        local borderCol
        if customColors then
            local r = GetSettingInt("color_border_r")
            local g = GetSettingInt("color_border_g")
            local b = GetSettingInt("color_border_b")
            borderCol = Color(r, g, b)
        else
            borderCol = T("chatBorder", Color(255, 255, 255))
        end
        
        surface.SetDrawColor(borderCol.r, borderCol.g, borderCol.b, 255 * alpha)
        surface.DrawRect(0, 0, pw, bt)
        surface.DrawRect(0, ph - bt, pw, bt)
        surface.DrawRect(0, 0, bt, ph)
        surface.DrawRect(pw - bt, 0, bt, ph)

        -- Accent corners
        local accentCol
        if customColors then
            local r = GetSettingInt("color_accent_r")
            local g = GetSettingInt("color_accent_g")
            local b = GetSettingInt("color_accent_b")
            accentCol = Color(r, g, b)
        else
            accentCol = T("chatAccent", Color(177, 102, 199))
        end
        
        surface.SetDrawColor(accentCol.r, accentCol.g, accentCol.b, 255 * alpha)
        local cs = bt * 3
        surface.DrawRect(0, 0, cs, cs)
        surface.DrawRect(pw - cs, 0, cs, cs)
        surface.DrawRect(0, ph - cs, cs, cs)
        surface.DrawRect(pw - cs, ph - cs, cs, cs)

        -- Glow effect
        if GetSetting("glow") and not GetSetting("performance_mode") then
            local glowIntensity = GetSettingInt("glow_intensity") / 100
            local glowAlpha = glowIntensity * 50 * alpha
            surface.SetDrawColor(accentCol.r, accentCol.g, accentCol.b, glowAlpha)
            surface.DrawRect(bt, bt, pw - bt*2, 2)
            surface.DrawRect(bt, ph - bt - 2, pw - bt*2, 2)
        end
        
        -- Scanlines
        if GetSetting("scanlines") and not GetSetting("performance_mode") then
            local scanOpacity = GetSettingInt("scanline_opacity") / 100
            local scanAlpha = scanOpacity * 100 * alpha
            surface.SetDrawColor(0, 0, 0, scanAlpha)
            for sy = 0, ph, 4 do
                surface.DrawRect(0, sy, pw, 1)
            end
        end
    end
    
    frame.OnMousePressed = function(self, keyCode)
        RefocusInput()
    end
    
    chatbox.Frame = frame
    
    local padding = 8
    local bt = borderThickness
    
    -- Message panel
    local msgPanel = vgui.Create("DScrollPanel", frame)
    msgPanel:SetPos(bt + padding, bt + padding)
    msgPanel:SetSize(w - (bt + padding) * 2, h - (bt * 2) - inputHeight - (padding * 3))
    
    local sbar = msgPanel:GetVBar()
    sbar:SetWide(6)
    sbar.Paint = function(s, pw, ph)
        if chatbox.BoxAlpha < 0.5 then return end
        draw.RoundedBox(0, 0, 0, pw, ph, T("scrollBg", Color(30, 30, 30, 180)))
    end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function(s, pw, ph)
        if chatbox.BoxAlpha < 0.5 then return end
        draw.RoundedBox(3, 0, 0, pw, ph, T("scrollGrip", Color(177, 102, 199)))
    end
    
    sbar.OnMousePressed = function(self, keyCode)
        timer.Simple(0.05, RefocusInput)
    end
    sbar.btnGrip.OnMousePressed = function(self, keyCode)
        timer.Simple(0.05, RefocusInput)
    end
    
    msgPanel.OnMouseWheeled = function(self, delta)
        if delta > 0 then
            chatbox.UserScrolledUp = true
        end
        
        local vb = self:GetVBar()
        if vb then
            vb:SetScroll(vb:GetScroll() - delta * 50)
        end
        
        if IsAtBottom() then
            chatbox.UserScrolledUp = false
        end
        
        return true
    end
    
    msgPanel.OnMousePressed = function(self, keyCode)
        RefocusInput()
    end
    
    msgPanel:GetCanvas().OnMousePressed = function(self, keyCode)
        RefocusInput()
    end
    
    chatbox.MessagePanel = msgPanel
    chatbox.MaxTextWidth = w - (bt + padding) * 2 - 20
    
    -- Input panel
    local inputPanel = vgui.Create("DTextEntry", frame)
    inputPanel:SetPos(bt + padding, h - bt - padding - inputHeight)
    inputPanel:SetSize(w - (bt + padding) * 2, inputHeight)
    inputPanel:SetFont(cfg.FontNameInput)
    inputPanel:SetTextColor(T("inputText", Color(255, 255, 255)))
    inputPanel:SetCursorColor(T("inputCursor", Color(177, 102, 199)))
    inputPanel:SetHighlightColor(T("inputHighlight", Color(177, 102, 199, 100)))
    inputPanel:SetPlaceholderColor(T("inputPlaceholder", Color(100, 100, 100)))
    inputPanel:SetDrawLanguageID(false)

    if GetSetting("show_placeholder") then
        inputPanel:SetPlaceholderText("* Type message... (Tab for names)")
    else
        inputPanel:SetPlaceholderText("")
    end

    if GetSetting("dynamic_placeholder") then
        inputPanel.Think = function(self)
            local text = self:GetText() or ""
            local prefix = string.lower(string.match(text, "^%S+") or "")

            local hints = {
                ["/t"] = "* Telegraph — STOP",
                ["/r"] = "* Radio — glitches & static",
                ["/w"] = "* Whisper — quiet",
                ["/y"] = "* Yell — LOUD",
                ["/me"] = "* Action",
                ["/ooc"] = "* Out of character",
                ["//"] = "* OOC shortcut",
                ["/looc"] = "* Local OOC",
            }

            self:SetPlaceholderText(hints[prefix] or "* Type message... (Tab for names)")
        end
    end

    inputPanel.Paint = function(self, pw, ph)
        draw.RoundedBox(0, 0, 0, pw, ph, T("inputBg", Color(20, 20, 20, 240)))
        surface.SetDrawColor(T("inputBorder", Color(100, 100, 100)))
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)
        self:DrawTextEntryText(
            T("inputText", Color(255, 255, 255)),
            T("inputCursor", Color(177, 102, 199)),
            T("inputText", Color(255, 255, 255))
        )
    end

    local function DoSendMessage(self)
        local text = self:GetText()

        if text and string.Trim(text) ~= "" then
            if GlitchLab.InputHistory and GlitchLab.InputHistory.Add then
                GlitchLab.InputHistory.Add(text)
            end

            chatbox.SendMessage(text)
            chatbox.Draft = ""
        end

        self:SetText("")

        if GlitchLab.InputHistory and GlitchLab.InputHistory.Reset then
            GlitchLab.InputHistory.Reset()
        end
        if GlitchLab.Autocomplete and GlitchLab.Autocomplete.Reset then
            GlitchLab.Autocomplete.Reset()
        end

        if GetSetting("close_send") then
            chatbox.Close()
        end
    end

    inputPanel.OnKeyCodeTyped = function(self, key)
        if key == KEY_ENTER or key == KEY_PAD_ENTER then
            DoSendMessage(self)
            return true
        end

        if key == KEY_UP then
            if GlitchLab.InputHistory and GlitchLab.InputHistory.Up then
                local msg = GlitchLab.InputHistory.Up()
                if msg then
                    self:SetText(msg)
                    self:SetCaretPos(#msg)
                end
            end
            return true
        end

        if key == KEY_DOWN then
            if GlitchLab.InputHistory and GlitchLab.InputHistory.Down then
                local msg = GlitchLab.InputHistory.Down()
                if msg then
                    self:SetText(msg)
                    self:SetCaretPos(#msg)
                end
            end
            return true
        end

        if key == KEY_TAB and GetSetting("autocomplete") then
            if GlitchLab.Autocomplete and GlitchLab.Autocomplete.Complete then
                local currentText = self:GetText()
                local cursorPos = self:GetCaretPos()

                local newText, newCursor = GlitchLab.Autocomplete.Complete(currentText, cursorPos)

                if newText then
                    self:SetText(newText)
                    self:SetCaretPos(newCursor)
                end
            end
            return true
        end

        return false
    end

    inputPanel.OnEnter = function(self)
        DoSendMessage(self)
    end

    inputPanel.OnTextChanged = function(self)
        if GlitchLab.InputHistory and GlitchLab.InputHistory.CurrentIndex == 0 then
            if GlitchLab.Autocomplete and GlitchLab.Autocomplete.Reset then
                GlitchLab.Autocomplete.Reset()
            end
        end
    end

    inputPanel:SetVisible(false)
    chatbox.InputPanel = inputPanel
    
    -- Draft indicator
    local draftPanel = vgui.Create("DPanel", frame)
    draftPanel:SetPos(bt + padding, h - bt - padding - inputHeight)
    draftPanel:SetSize(w - (bt + padding) * 2, inputHeight)
    draftPanel.Paint = function(self, pw, ph)
        if chatbox.IsOpen then return end
        if not chatbox.Draft or chatbox.Draft == "" then return end

        local blink = math.abs(math.sin(CurTime() * 1.5)) * 0.5 + 0.5

        local draftBg = T("draftBg", Color(50, 15, 15, 200))
        local draftBorder = T("draftBorder", Color(255, 60, 60))
        local draftText = T("draftText", Color(255, 120, 120))
        local draftTextLight = T("draftTextLight", Color(255, 220, 220))

        draw.RoundedBox(0, 0, 0, pw, ph, Color(draftBg.r, draftBg.g, draftBg.b, draftBg.a * blink))
        surface.SetDrawColor(draftBorder.r, draftBorder.g, draftBorder.b, 255 * blink)
        surface.DrawOutlinedRect(0, 0, pw, ph, 2)

        surface.SetFont(cfg.FontNameInput)
        local preview = UTF8Len(chatbox.Draft) > 40 
            and UTF8Sub(chatbox.Draft, 1, 37) .. "..." 
            or chatbox.Draft

        surface.SetTextColor(draftText.r, draftText.g, draftText.b, 255 * blink)
        surface.SetTextPos(10, ph / 2 - 8)
        surface.DrawText("DRAFT: ")

        local lw = surface.GetTextSize("DRAFT: ")
        surface.SetTextColor(draftTextLight.r, draftTextLight.g, draftTextLight.b, 255 * blink)
        surface.SetTextPos(10 + lw, ph / 2 - 8)
        surface.DrawText(preview)
    end
    
    chatbox.RebuildMessagePanels()
    
    dbg("Chatbox built")
end

-- ============================================
-- THINK
-- ============================================

local lastEscapeState = false
local lastMouseState = false

hook.Add("Think", "GlitchLab_ChatThink", function()
    if not IsValid(chatbox.Frame) then
        chatbox.Build()
        return
    end
    
    -- Alpha animation
    local target = chatbox.IsOpen and 1 or 0
    local diff = target - chatbox.BoxAlpha
    if math.abs(diff) > 0.01 then
        local speed = GetSetting("no_animations") and 100 or 10
        chatbox.BoxAlpha = chatbox.BoxAlpha + diff * FrameTime() * speed
    else
        chatbox.BoxAlpha = target
    end
    
    -- Escape key
    local escapeDown = input.IsKeyDown(KEY_ESCAPE)
    if chatbox.IsOpen and escapeDown and not lastEscapeState then
        if GetSetting("close_escape") then
            if IsValid(chatbox.InputPanel) then
                local t = chatbox.InputPanel:GetText()
                if t and string.Trim(t) ~= "" and GetSetting("save_draft") then
                    chatbox.Draft = t
                else
                    chatbox.Draft = ""
                end
            end
            chatbox.Close()
        end
    end
    lastEscapeState = escapeDown

    -- Click outside
    local mouseDown = input.IsMouseDown(MOUSE_LEFT)
    if chatbox.IsOpen and mouseDown and not lastMouseState then
        if GetSetting("close_click") and not IsMouseInFrame() then
            if IsValid(chatbox.InputPanel) then
                local t = chatbox.InputPanel:GetText()
                if t and string.Trim(t) ~= "" and GetSetting("save_draft") then
                    chatbox.Draft = t
                else
                    chatbox.Draft = ""
                end
            end
            chatbox.Close()
        end
    end
    lastMouseState = mouseDown
end)

-- ============================================
-- OPEN
-- ============================================

function chatbox.Open(isTeam)
    if chatbox.IsOpen then
        RefocusInput()
        return
    end
    
    if not IsValid(chatbox.Frame) then
        chatbox.Build()
    end
    
    chatbox.IsOpen = true
    chatbox.IsTeamChat = isTeam or false
    chatbox.UserScrolledUp = false
    
    chatbox.Frame:SetMouseInputEnabled(true)
    chatbox.Frame:SetKeyboardInputEnabled(true)
    chatbox.Frame:MakePopup()
    chatbox.Frame:SetKeyboardInputEnabled(true)
    
    chatbox.InputPanel:SetVisible(true)
    
    if chatbox.Draft and chatbox.Draft ~= "" and GetSetting("save_draft") then
        chatbox.InputPanel:SetText(chatbox.Draft)
        chatbox.InputPanel:SetCaretPos(#chatbox.Draft)
    else
        chatbox.InputPanel:SetText("")
    end
    
    chatbox.InputPanel:RequestFocus()
    timer.Simple(0.01, function()
        if IsValid(chatbox.InputPanel) and chatbox.IsOpen then
            chatbox.InputPanel:RequestFocus()
        end
    end)
    
    chatbox.InputPanel:SetPlaceholderText(isTeam and "* Team chat..." or "* Type message... (Tab for names)")
    
    ForceScrollToBottom()
    
    dbg("Chat opened (team: %s)", tostring(isTeam))
end

-- ============================================
-- CLOSE
-- ============================================

function chatbox.Close()
    if not chatbox.IsOpen then return end
    
    if IsValid(chatbox.InputPanel) then
        local text = chatbox.InputPanel:GetText()
        if text and string.Trim(text) ~= "" and GetSetting("save_draft") then
            chatbox.Draft = text
        else
            chatbox.Draft = ""
        end
    end
    
    SafeClose()
    
    if GlitchLab.InputHistory then GlitchLab.InputHistory.Reset() end
    if GlitchLab.Autocomplete then GlitchLab.Autocomplete.Reset() end
    
    dbg("Chat closed")
end

-- ============================================
-- SEND
-- ============================================

function chatbox.SendMessage(text)
    if not text or string.Trim(text) == "" then return end
    text = string.sub(text, 1, cfg.MaxMessageLength)
    
    local isOurCommand = false
    local lowerText = string.lower(text)
    
    for styleName, style in pairs(cfg.Styles) do
        if style.prefix then
            local prefix = string.lower(style.prefix)
            if string.StartWith(lowerText, prefix .. " ") or lowerText == prefix then
                isOurCommand = true
                break
            end
        end
        if style.altPrefix then
            local altPrefix = string.lower(style.altPrefix)
            if string.StartWith(lowerText, altPrefix .. " ") or lowerText == altPrefix then
                isOurCommand = true
                break
            end
        end
    end
    
    if not string.StartWith(text, "/") and not string.StartWith(text, "!") and not string.StartWith(text, "@") then
        isOurCommand = true
    end
    
    if isOurCommand then
        net.Start(cfg.NetStrings.SendMessage)
            net.WriteString(text)
            net.WriteBool(chatbox.IsTeamChat)
        net.SendToServer()
    else
        if chatbox.IsTeamChat then
            RunConsoleCommand("say_team", text)
        else
            RunConsoleCommand("say", text)
        end
    end
end

-- ============================================
-- CREATE MESSAGE PANEL
-- ============================================

function chatbox.CreateMessagePanel(msg)
    if not IsValid(chatbox.MessagePanel) then return end
    
    local style = cfg.Styles[msg.styleName] or cfg.Styles.direct
    local letterPadding = style.letter and 24 or 0
    local maxWidth = chatbox.MaxTextWidth - 10 - letterPadding
    
    surface.SetFont(cfg.FontName)
    
    local iconsWidth = 0
    
    if msg.styleName ~= "direct" and GlitchLab.Sprites and GetSetting("show_style_icons") then
        local iconSize = GetIconSize()
        iconsWidth = iconsWidth + iconSize + 4
    end
    
    local avatarMode = GetSettingInt("avatar_mode")
    if avatarMode > 0 and not msg.isSystem and msg.sender and msg.sender ~= "" then
        if not style.letter then
            local avatarSize = GetAvatarSize()
            iconsWidth = iconsWidth + avatarSize + 4
        end
    end
    
    local prefixText = ""
    local prefixWidth = 0
    
    if msg.sender and msg.sender ~= "" then
        if msg.noColon then
            prefixText = msg.sender .. " "
        else
            prefixText = msg.sender .. ": "
        end
        prefixWidth = surface.GetTextSize(prefixText)
    end
    
    local firstLineMax = maxWidth - prefixWidth - iconsWidth
    if firstLineMax < 50 then
        firstLineMax = 50
    end
    
    local wrappedLines = WrapText(msg.text, cfg.FontName, maxWidth)
    
    if #wrappedLines > 0 and prefixWidth > 0 then
        local firstText = table.concat(wrappedLines[1].chars)
        local firstW = surface.GetTextSize(firstText)
        
        if firstW > firstLineMax then
            wrappedLines = {}
            local temp = WrapText(msg.text, cfg.FontName, firstLineMax)
            if #temp > 0 then
                table.insert(wrappedLines, temp[1])
                
                local usedChars = #temp[1].chars
                local allChars = UTF8ToTable(msg.text)
                local remaining = {}
                
                for i = usedChars + 1, #allChars do
                    if i == usedChars + 1 and allChars[i] == " " then
                    else
                        table.insert(remaining, allChars[i])
                    end
                end
                
                if #remaining > 0 then
                    local restText = table.concat(remaining)
                    local restLines = WrapText(restText, cfg.FontName, maxWidth)
                    for _, l in ipairs(restLines) do
                        table.insert(wrappedLines, l)
                    end
                end
            end
        end
    end
    
    local totalChars = 0
    for _, line in ipairs(wrappedLines) do
        totalChars = totalChars + #line.chars
    end
    
    msg.wrappedLines = wrappedLines
    msg.totalChars = totalChars
    msg.lastPlayedChar = 0
    
    local lineH = GetLineHeight()
    local avatarSize = GetAvatarSize()
    local iconSize = GetIconSize()
    local minHeight = math.max(lineH, avatarSize, iconSize) + 8
    
    if style.letter then
        minHeight = minHeight + 8
    end
    
    local container = vgui.Create("DPanel", chatbox.MessagePanel)
    container:Dock(TOP)
    container:DockMargin(0, 0, 0, style.letter and 8 or 4)
    container:SetTall(minHeight)
    
    container.MsgData = msg
    container.StartTime = CurTime()
    container.LastHeight = 0
    container.PrefixText = prefixText
    container.PrefixWidth = prefixWidth
    container.LinkRegions = {}
    container.MouseHovering = false
    
    -- Mouse events
    container.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_RIGHT then
            local data = self.MsgData
            if data then
                local fullText = ""
                if data.sender and data.sender ~= "" then
                    fullText = data.sender .. ": "
                end
                fullText = fullText .. (data.text or "")
                
                SetClipboardText(fullText)
                surface.PlaySound("buttons/button15.wav")
                
                MsgC(Color(177, 102, 199), "[UnderComms] ")
                MsgC(Color(255, 255, 255), "Copied: " .. fullText .. "\n")
            end
            return
        end
        
        RefocusInput()
    end
    
    container.OnCursorEntered = function(self)
        self.MouseHovering = true
    end
    
    container.OnCursorExited = function(self)
        self.MouseHovering = false
    end
    
    -- Think
    container.Think = function(self)
        local data = self.MsgData
        if not data or not data.wrappedLines then return end

        local now = CurTime()
        local elapsed = now - self.StartTime

        local charsToShow = 0

        if data.isTelegraph then
            local style = data.style
            local chunkDelay = style.chunkDelay or 0.15

            local chunksToShow = math.floor(elapsed / chunkDelay) + 1
            chunksToShow = math.min(chunksToShow, #data.telegraphChunks)

            if chunksToShow > data.telegraphCurrentChunk then
                data.telegraphCurrentChunk = chunksToShow
                PlayMorseBeep(
                    math.random() > 0.7,
                    data.pitchMin,
                    data.pitchMax,
                    data.blipVolume
                )
            end

            for i = 1, chunksToShow do
                charsToShow = charsToShow + UTF8Len(data.telegraphChunks[i])
            end

            if chunksToShow >= #data.telegraphChunks then
                charsToShow = data.totalChars
            end
        else
            local speed = data.typeSpeed or 60
            charsToShow = math.floor(elapsed * speed)
        end

        if data.isRadio then
            if not data.radioHissStarted and charsToShow > 0 then
                data.radioHissStarted = true
                StartRadioHiss(data.msgId)
            end

            if data.fullyDisplayed and data.glitchesFinished then
                StopRadioHiss(data.msgId)
            end
        end

        if charsToShow >= data.totalChars then
            charsToShow = data.totalChars
            if not data.fullyDisplayed then
                data.fullyDisplayed = true
                data.finishedTime = now

                if data.isRadio and (not data.postGlitches or #data.postGlitches == 0) then
                    StopRadioHiss(data.msgId)
                end
            end
        end

        if data.isRadio and not data.fullyDisplayed then
            local style = data.style
            local glitchChance = style.glitchChance or 0.15
            local glitchIntensity = GetSettingInt("glitch_intensity") / 100

            if not data.glitchActive and now - data.lastGlitchCheck > 0.3 then
                data.lastGlitchCheck = now

                if math.random() < glitchChance * glitchIntensity then
                    data.glitchActive = true
                    data.glitchStartTime = now
                    data.glitchDuration = 0.3 + math.random() * 0.4
                    StartRadioStatic(data.glitchDuration)
                end
            end
        end

        if data.isRadio and data.fullyDisplayed and not data.glitchesFinished then
            local timeSinceFinish = now - data.finishedTime

            local allTriggered = true
            for _, pg in ipairs(data.postGlitches) do
                if not pg.triggered then
                    allTriggered = false
                    if timeSinceFinish >= pg.time and not data.glitchActive then
                        pg.triggered = true
                        data.glitchActive = true
                        data.glitchStartTime = now
                        data.glitchDuration = pg.duration
                        StartRadioStatic(data.glitchDuration)
                        break
                    end
                end
            end

            if allTriggered then
                data.glitchesFinished = true
                StopRadioHiss(data.msgId)
            end
        end

        if data.glitchActive then
            local glitchElapsed = now - data.glitchStartTime
            if glitchElapsed >= data.glitchDuration then
                data.glitchActive = false
                data.shakeOffset = {x = 0, y = 0}
            else
                if GetSetting("shake") and not GetSetting("performance_mode") then
                    local shakeIntensity = GetSettingInt("shake_intensity") / 100
                    local intensity = 3 * shakeIntensity * (1 - glitchElapsed / data.glitchDuration)
                    data.shakeOffset = {
                        x = math.random(-intensity, intensity),
                        y = math.random(-intensity, intensity)
                    }
                else
                    data.shakeOffset = {x = 0, y = 0}
                end
            end
        end

        data.currentCharsToShow = charsToShow

        local charCount = 0
        local currentLine = 1

        for li, ld in ipairs(data.wrappedLines) do
            local lineCharCount = #ld.chars
            if charCount + lineCharCount >= charsToShow then
                currentLine = li
                break
            end
            charCount = charCount + lineCharCount
            currentLine = li
        end

        if charsToShow >= data.totalChars then
            currentLine = #data.wrappedLines
        end

        local lineH = GetLineHeight()
        local avatarSize = GetAvatarSize()
        local iconSize = GetIconSize()
        local rowHeight = math.max(lineH, avatarSize, iconSize)

        local extraPadding = (data.style and data.style.letter) and 12 or 0
        local targetHeight = currentLine * rowHeight + 8 + extraPadding

        if targetHeight ~= self.LastHeight then
            self.LastHeight = targetHeight
            self:SetTall(targetHeight)

            if IsValid(chatbox.MessagePanel) then
                chatbox.MessagePanel:GetCanvas():InvalidateLayout(true)
                chatbox.MessagePanel:InvalidateLayout(true)
                SmartScroll()
            end
        end
    end
    
    -- Paint
    container.Paint = function(self, pw, ph)
        local data = self.MsgData
        if not data or not data.wrappedLines then return end
        
        local lineH = GetLineHeight()
        local iconSize = GetIconSize()
        local avatarSize = GetAvatarSize()
        local rowHeight = math.max(lineH, avatarSize, iconSize)
        
        -- Fade
        local msgAlpha = 255
        if not chatbox.IsOpen then
            local fadeTime = GetSettingInt("fade_time")
            if fadeTime <= 0 then fadeTime = 10 end
            local fadeDuration = GetSettingInt("fade_duration")
            if fadeDuration <= 0 then fadeDuration = 2 end
            
            if data.fullyDisplayed and data.finishedTime then
                local waitForGlitches = data.isRadio and not data.glitchesFinished
                if not waitForGlitches then
                    local age = CurTime() - data.finishedTime
                    if age > fadeTime then
                        local fade = (age - fadeTime) / math.max(fadeDuration, 0.1)
                        msgAlpha = 255 * (1 - math.Clamp(fade, 0, 1))
                    end
                end
            end
        end
        if msgAlpha < 1 then return end

        -- Letter background
        if data.style and data.style.letter then
            local padding = 6
            local alphaMultiplier = msgAlpha / 255

            local paperCol = PAPER_COLORS.background
            surface.SetDrawColor(paperCol.r, paperCol.g, paperCol.b, paperCol.a * alphaMultiplier)
            surface.DrawRect(0, 0, pw, ph)

            local edgeCol = PAPER_COLORS.border
            surface.SetDrawColor(edgeCol.r, edgeCol.g, edgeCol.b, edgeCol.a * alphaMultiplier)
            surface.DrawOutlinedRect(1, 1, pw - 2, ph - 2, 1)

            local lineCol = PAPER_COLORS.lines
            surface.SetDrawColor(lineCol.r, lineCol.g, lineCol.b, lineCol.a * alphaMultiplier)
            local lineSpacing = 14
            for ly = lineSpacing + padding, ph - padding, lineSpacing do
                surface.DrawRect(padding, ly, pw - padding * 2, 1)
            end

            local foldSize = 10
            surface.SetDrawColor(230, 220, 200, 220 * alphaMultiplier)
            surface.DrawRect(pw - foldSize, 0, foldSize, foldSize)
            surface.SetDrawColor(200, 180, 150, 180 * alphaMultiplier)
            surface.DrawLine(pw - foldSize, 0, pw, foldSize)
        end

        local charsToShow = data.currentCharsToShow or 0

        -- Play sounds
        if not data.isTelegraph and charsToShow > data.lastPlayedChar and not data.fullyDisplayed then
            local charIndex = 0
            for _, ld in ipairs(data.wrappedLines) do
                for _, char in ipairs(ld.chars) do
                    charIndex = charIndex + 1
                    if charIndex > data.lastPlayedChar and charIndex <= charsToShow then
                        if char ~= " " then
                            local pitch = math.random(data.pitchMin or 90, data.pitchMax or 110)

                            if data.isRadio then
                                PlayRadioBlip(pitch, data.blipVolume or 0.3)
                            elseif data.style and data.style.letter then
                                if GetSetting("paper_enabled") and math.random() > 0.7 then
                                    local paperVol = GetSettingInt("paper_volume") / 100
                                    PlayBlip(pitch, (data.blipVolume or 0.2) * paperVol, PAPER_SOUND)
                                end
                            else
                                PlayBlipForPlayer(data.senderPly, pitch, data.blipVolume or 0.3)
                            end
                        end
                    end
                end
            end
            data.lastPlayedChar = charsToShow
        end

        -- Shake
        local shakeX = data.shakeOffset and data.shakeOffset.x or 0
        local shakeY = data.shakeOffset and data.shakeOffset.y or 0

        local letterPadding = (data.style and data.style.letter) and 10 or 0
        local xOff = 4 + shakeX + letterPadding
        local yOff = 4 + shakeY + letterPadding

        -- Timestamp
        if chatbox.IsOpen and GetSetting("timestamps") then
            surface.SetFont(cfg.FontNameSmall)
            
            local format = GetSettingInt("timestamp_format")
            local ts
            if format == 2 then
                ts = os.date("[%H:%M:%S] ", data.realtime)
            elseif format == 3 then
                ts = os.date("[%M:%S] ", data.realtime)
            else
                ts = os.date("[%H:%M] ", data.realtime)
            end
            
            local tsCol = T("textTimestamp", Color(100, 100, 100, 180))
            surface.SetTextColor(tsCol.r, tsCol.g, tsCol.b, msgAlpha * 0.7)
            surface.SetTextPos(xOff, yOff + 2)
            surface.DrawText(ts)
            xOff = xOff + surface.GetTextSize(ts)
        end

        surface.SetFont(cfg.FontName)
        local _, textH = surface.GetTextSize("Ay")
        local baseY = yOff + 2
        local maxElement = math.max(iconSize, avatarSize, textH)
        local verticalCenter = baseY + maxElement / 2
        
        local textX = xOff
        local spriteOffset = 0

        -- Style icon
        local styleName = data.styleName or "direct"
        if sprites and GetSetting("show_style_icons") and styleName ~= "direct" then
            local iconY = verticalCenter - iconSize / 2
            local iconWidth = sprites.DrawStyleIcon(styleName, textX, iconY, iconSize, msgAlpha)
            if iconWidth and iconWidth > 0 then
                textX = textX + iconWidth
                spriteOffset = spriteOffset + iconWidth
            end
        end
        
        -- Avatar
        local skipAvatar = data.style and data.style.letter
        local avatarMode = GetSettingInt("avatar_mode")
        
        if not data.isSystem and data.sender and data.sender ~= "" and not skipAvatar and avatarMode > 0 then
            if sprites and sprites.DrawAvatar then
                local avatarY = yOff + (rowHeight - avatarSize) / 2
                local screenX, screenY = self:LocalToScreen(textX, avatarY)

                local chatBounds = nil
                if IsValid(chatbox.MessagePanel) then
                    local panelX, panelY = chatbox.MessagePanel:LocalToScreen(0, 0)
                    local panelW, panelH = chatbox.MessagePanel:GetSize()
                    chatBounds = {panelX, panelY, panelX + panelW, panelY + panelH}
                end

                local avatarWidth = sprites.DrawAvatar(data.senderPly, screenX, screenY, avatarSize, msgAlpha, textX, avatarY, chatBounds)

                if avatarWidth and avatarWidth > 0 then
                    textX = textX + avatarWidth
                    spriteOffset = spriteOffset + avatarWidth
                end
            end
        end
        
        -- Name
        local textBaseY = verticalCenter - textH / 2
        
        local nameAlpha = msgAlpha
        if data.styleName == "whisper" then
            nameAlpha = msgAlpha * 0.7
        end
        
        local drawShadow = GetSetting("text_shadows")
        local shadowOpacity = GetSettingInt("shadow_opacity") / 100

        if self.PrefixText and self.PrefixText ~= "" then
            if drawShadow then
                surface.SetTextColor(0, 0, 0, nameAlpha * shadowOpacity)
                surface.SetTextPos(textX + 1, textBaseY + 1)
                surface.DrawText(self.PrefixText)
            end
            
            local nc = data.senderColor
            if data.style and data.style.letter then
                nc = PAPER_COLORS.ink
            end
            surface.SetTextColor(nc.r, nc.g, nc.b, nameAlpha)
            surface.SetTextPos(textX, textBaseY)
            surface.DrawText(self.PrefixText)
            
            textX = textX + self.PrefixWidth
        end
        
        local firstLineX = textX
        local otherLinesX = 4 + shakeX + letterPadding
        
        local charIndex = 0
        local effectsEnabled = GetSetting("effects") and not GetSetting("performance_mode")
        local glitchIntensity = GetSettingInt("glitch_intensity") / 100

        -- Text
        for li, ld in ipairs(data.wrappedLines) do
            local lineY = baseY + (li - 1) * rowHeight + (maxElement - textH) / 2
            local lineX = li == 1 and firstLineX or otherLinesX

            local lineChars = ld.chars
            local currentX = lineX

            for ci, char in ipairs(lineChars) do
                charIndex = charIndex + 1
                
                if charIndex > charsToShow then
                    local showCursor = GetSetting("show_cursor")
                    if not data.fullyDisplayed and showCursor then
                        local cursorSpeed = GetSettingInt("cursor_speed")
                        if cursorSpeed <= 0 then cursorSpeed = 4 end
                        if math.floor(CurTime() * cursorSpeed) % 2 == 0 then
                            local cursorColor = data.isRadio and Color(80, 255, 80) or T("cursorColor", Color(177, 102, 199))
                            surface.SetTextColor(cursorColor.r, cursorColor.g, cursorColor.b, msgAlpha)
                            surface.SetTextPos(currentX, lineY)
                            surface.DrawText("_")
                        end
                    end
                    break
                end

                local displayChar = char
                
                if data.glitchActive and data.isRadio and effectsEnabled then
                    if math.random() < 0.3 * glitchIntensity then
                        displayChar = GetRandomGlitchChar()
                    end
                end

                local charW = surface.GetTextSize(displayChar)

                local tc = data.textColor
                if data.style and data.style.letter then
                    tc = PAPER_COLORS.ink
                end
                
                if data.glitchActive and data.isRadio and effectsEnabled then
                    tc = Color(
                        math.Clamp(tc.r + math.random(-50, 50) * glitchIntensity, 0, 255),
                        math.Clamp(tc.g + math.random(-30, 30) * glitchIntensity, 0, 255),
                        math.Clamp(tc.b + math.random(-50, 50) * glitchIntensity, 0, 255)
                    )
                end

                local textAlpha = msgAlpha
                if data.styleName == "whisper" then
                    textAlpha = msgAlpha * 0.7
                end

                if drawShadow then
                    surface.SetTextColor(0, 0, 0, textAlpha * shadowOpacity)
                    surface.SetTextPos(currentX + 1, lineY + 1)
                    surface.DrawText(displayChar)
                end

                surface.SetTextColor(tc.r, tc.g, tc.b, textAlpha)
                surface.SetTextPos(currentX, lineY)
                surface.DrawText(displayChar)

                currentX = currentX + charW
            end

            if charIndex >= charsToShow and charIndex < data.totalChars then
                break
            end
        end

        -- Static overlay
        if data.glitchActive and data.isRadio and effectsEnabled then
            local glitchAlpha = 30 * glitchIntensity * (1 - (CurTime() - data.glitchStartTime) / data.glitchDuration)
            surface.SetDrawColor(80, 255, 80, glitchAlpha)

            for i = 1, math.floor(3 * glitchIntensity) do
                local sy = math.random(0, ph)
                surface.DrawRect(0, sy, pw, 1)
            end
        end

        if self.MouseHovering then
            self:SetCursor("arrow")
        end
    end
    
    return container
end

-- ============================================
-- REBUILD
-- ============================================

function chatbox.RebuildMessagePanels()
    if not IsValid(chatbox.MessagePanel) then return end
    
    for msgId, timerName in pairs(activeRadioHiss) do
        timer.Remove(timerName)
    end
    activeRadioHiss = {}
    
    chatbox.MessagePanel:GetCanvas():Clear()
    
    for _, msg in ipairs(chatbox.Messages) do
        msg.fullyDisplayed = true
        msg.finishedTime = msg.timestamp
        msg.lastPlayedChar = msg.totalChars or 0
        msg.telegraphCurrentChunk = #(msg.telegraphChunks or {})
        msg.glitchActive = false
        msg.glitchesFinished = true
        msg.radioHissStarted = true
        msg.shakeOffset = {x = 0, y = 0}
        chatbox.CreateMessagePanel(msg)
    end
    
    ForceScrollToBottom()
end

-- ============================================
-- NET
-- ============================================

net.Receive(cfg.NetStrings.ReceiveMessage, function()
    local senderName = net.ReadString()
    local senderColor = net.ReadColor()
    local text = net.ReadString()
    local textColor = net.ReadColor()
    local isSystem = net.ReadBool()
    local styleName = net.ReadString()
    
    local distance = 0
    local distanceAlpha = 255
    local senderEntIndex = 0
    
    local success = pcall(function()
        distance = net.ReadFloat()
        distanceAlpha = net.ReadUInt(8)
        senderEntIndex = net.ReadUInt(16)
    end)
    
    if not success then
        distance = 0
        distanceAlpha = 255
        senderEntIndex = 0
    end
    
    if not distanceAlpha or distanceAlpha <= 0 then
        distanceAlpha = 255
    end
    
    if distanceAlpha < 255 then
        local alphaMultiplier = distanceAlpha / 255
        senderColor = Color(senderColor.r, senderColor.g, senderColor.b, math.floor(255 * alphaMultiplier))
        textColor = Color(textColor.r, textColor.g, textColor.b, math.floor(255 * alphaMultiplier))
    end
    
    local senderPly = nil
    if senderEntIndex and senderEntIndex > 0 then
        senderPly = Entity(senderEntIndex)
        if not IsValid(senderPly) or not senderPly:IsPlayer() then
            senderPly = nil
        end
    end

    if not IsValid(senderPly) and senderName and senderName ~= "" then
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Nick() == senderName then
                senderPly = ply
                break
            end
        end
    end

    if IsValid(senderPly) and GlitchLab.Sprites and GlitchLab.Sprites.PreloadAvatar then
        GlitchLab.Sprites.PreloadAvatar(senderPly)
    end
    
    local msg = chatbox.AddMessage(senderName, senderColor, text, textColor, isSystem, styleName, senderPly)
    
    if msg then
        msg.distance = distance
        msg.distanceAlpha = distanceAlpha
    end
    
    if IsValid(chatbox.MessagePanel) then
        chatbox.CreateMessagePanel(msg)
        ForceScrollToBottom()
    end
end)

-- ============================================
-- INIT
-- ============================================

hook.Add("InitPostEntity", "GlitchLab_BuildChatbox", function()
    timer.Simple(1, chatbox.Build)
end)

hook.Add("OnScreenSizeChanged", "GlitchLab_RebuildOnResize", function()
    timer.Simple(0.1, chatbox.Build)
end)

-- ============================================
-- HIDE DEFAULT CHAT & INTERCEPT
-- ============================================

hook.Add("HUDShouldDraw", "GlitchLab_HideDefaultChat", function(name)
    if name == "CHudChat" then
        return false
    end
end)

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
-- INTERCEPT chat.AddText
-- ============================================

local oldChatAddText = chat.AddText

function chat.AddText(...)
    oldChatAddText(...)
    
    local args = {...}
    if #args == 0 then return end
    
    local segments = {}
    local currentColor = T("textDefault", Color(255, 255, 255))
    local senderPly = nil
    local senderName = nil
    local senderColor = nil
    local fullText = ""
    local firstColor = nil
    
    for i, arg in ipairs(args) do
        if IsColor(arg) then
            currentColor = arg
            if not firstColor then firstColor = arg end
        elseif type(arg) == "Player" and IsValid(arg) then
            senderPly = arg
            senderName = arg:Nick()
            senderColor = team.GetColor(arg:Team())
            if not senderColor or (senderColor.r == 0 and senderColor.g == 0 and senderColor.b == 0) then
                senderColor = T("playerName", Color(255, 255, 100))
            end
        elseif type(arg) == "string" then
            fullText = fullText .. arg
        elseif type(arg) == "table" and arg.r and arg.g and arg.b then
            currentColor = Color(arg.r, arg.g, arg.b, arg.a or 255)
            if not firstColor then firstColor = currentColor end
        end
    end
    
    fullText = string.Trim(fullText)
    if fullText == "" and not senderName then return end
    
    if senderName then
        if string.StartWith(fullText, ": ") then
            fullText = string.sub(fullText, 3)
        elseif string.StartWith(fullText, ":") then
            fullText = string.sub(fullText, 2)
        end
        fullText = string.Trim(fullText)
    end
    
    local isSystem = (senderName == nil)
    local textColor = firstColor or currentColor
    
    if fullText == "" then return end
    
    local msg = chatbox.AddMessage(
        senderName or "",
        senderColor or T("systemMsg", Color(177, 102, 199)),
        fullText,
        textColor,
        isSystem,
        "direct",
        senderPly
    )
    
    if IsValid(chatbox.MessagePanel) then
        chatbox.CreateMessagePanel(msg)
        ForceScrollToBottom()
    end
end

-- ============================================
-- COMMANDS
-- ============================================

concommand.Add("uc_rebuild", function()
    chatbox.Build()
    print("[UnderComms] Chat rebuilt")
end)

concommand.Add("uc_styles", function()
    print("\n=== UnderComms Message Styles ===")
    for name, style in pairs(cfg.Styles) do
        local prefix = style.prefix or "none"
        local alt = style.altPrefix and (" or " .. style.altPrefix) or ""
        print(string.format("  %s%s — %s", prefix, alt, style.name or name))
    end
    print("================================\n")
end)

-- ============================================
-- CLEANUP
-- ============================================

hook.Add("ShutDown", "GlitchLab_ChatboxCleanup", function()
    for msgId, timerName in pairs(activeRadioHiss) do
        timer.Remove(timerName)
    end
    
    if IsValid(chatbox.Frame) then
        chatbox.Frame:Remove()
    end
end)

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), "Chatbox v0.9.0 loaded\n")