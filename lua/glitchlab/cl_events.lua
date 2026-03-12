--[[
    GlitchLab | UnderComms — Events System (Client)
    
    v0.6.0 — EVENTS EDITION
    
    Undertale-style popup notifications that make players
    shit their pants when "WARNING" appears on screen
    
    "* You felt your sins crawling on your back."
]]

GlitchLab.Events = GlitchLab.Events or {}

local events = GlitchLab.Events
local cfg = GlitchLab.Config

-- Theme helper
local function T(key, fallback)
    local theme = GlitchLab.Theme
    if theme and theme[key] then
        return theme[key]
    end
    return fallback or Color(255, 255, 255)
end

local function GetEventType(typeName)
    local theme = GlitchLab.Theme
    if theme and theme.eventTypes and theme.eventTypes[typeName] then
        return theme.eventTypes[typeName]
    end
    -- Fallback to hardcoded
    return events.Types[typeName] or events.Types.info
end

-- Safe color getter (because nil checks are for winners)
local function SafeColor(col, fallback)
    if col and col.r and col.g and col.b then
        return col
    end
    return fallback or Color(255, 255, 255)
end

-- ============================================
-- EVENT TYPES CONFIG
-- ============================================

-- Fallback types (used if theme doesn't have them)
events.TypesFallback = {
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
}

-- ============================================
-- STATE
-- ============================================

events.Queue = {}           -- queued events waiting to display
events.Current = nil        -- currently displaying event
events.Panel = nil          -- the VGUI panel
events.ShakeOffset = {x = 0, y = 0}
events.ShakeEndTime = 0

-- ============================================
-- SETTINGS HELPERS
-- ============================================

local function GetSetting(name)
    if GlitchLab.Settings and GlitchLab.Settings.GetBool then
        return GlitchLab.Settings.GetBool(name)
    end
    return true
end

local function GetSettingFloat(name)
    if GlitchLab.Settings and GlitchLab.Settings.GetFloat then
        return GlitchLab.Settings.GetFloat(name)
    end
    return 1.0
end

-- ============================================
-- SCREEN SHAKE
-- ============================================

local function StartShake(intensity, duration)
    if not GetSetting("shake") then return end
    
    events.ShakeEndTime = CurTime() + duration
    events.ShakeIntensity = intensity
end

local function UpdateShake()
    if CurTime() < events.ShakeEndTime then
        local intensity = events.ShakeIntensity or 3
        local remaining = events.ShakeEndTime - CurTime()
        local factor = math.min(remaining, 1)
        
        events.ShakeOffset = {
            x = math.random(-intensity, intensity) * factor,
            y = math.random(-intensity, intensity) * factor
        }
    else
        events.ShakeOffset = {x = 0, y = 0}
    end
end

-- ============================================
-- PLAY EVENT SOUND
-- ============================================

local function PlayEventSound(eventType)
    local typeData = GetEventType(eventType or "info")
    
    -- Play custom sound if defined
    if typeData and typeData.sound then
        surface.PlaySound(typeData.sound)
        return
    end
    
    -- Fallback: play blip sound
    local ply = LocalPlayer()
    if IsValid(ply) then
        local vol = GetSettingFloat("blip_volume")
        ply:EmitSound("chat/event.wav", 50, 100, vol * 0.5, CHAN_STATIC)
    end
end

-- ============================================
-- CREATE EVENT PANEL
-- ============================================

local function CreateEventPanel()
    if IsValid(events.Panel) then
        events.Panel:Remove()
    end
    
    local scrW, scrH = ScrW(), ScrH()
    
    local panelW = math.min(600, scrW * 0.5)
    local panelH = 160
    local panelX = (scrW - panelW) / 2
    local panelY = scrH * 0.25
    
    local panel = vgui.Create("DPanel")
    panel:SetPos(panelX, panelY)
    panel:SetSize(panelW, panelH)
    panel:SetAlpha(0)
    panel:MakePopup()
    panel:SetKeyboardInputEnabled(false)
    panel:SetMouseInputEnabled(false)
    
    -- Animation state
    panel.AnimState = "fade_in"  -- fade_in, typing, display, fade_out
    panel.AnimStart = CurTime()
    panel.CharsShown = 0
    panel.TypewriterSpeed = 40
    panel.DisplayDuration = 3
    panel.FadeDuration = 0.3
    
    panel.EventData = nil
    panel.TypeData = nil
    panel.TitleChars = {}
    panel.TextChars = {}
    
    panel.Paint = function(self, w, h)
        if not self.EventData then return end

        local data = self.EventData
        local typeData = GetEventType(data.type or "info")

        -- Safe color helper
        local function SC(col, fallback)
            if col and col.r and col.g and col.b then
                return col
            end
            return fallback or Color(255, 255, 255)
        end

        UpdateShake()
        local shakeX = events.ShakeOffset.x
        local shakeY = events.ShakeOffset.y

        -- Background with shake
        local bgX = shakeX
        local bgY = shakeY

        -- Main background
        local bgCol = SC(T("eventBg"), Color(10, 10, 10, 240))
        draw.RoundedBox(0, bgX, bgY, w, h, bgCol)

        -- Border
        local borderCol = SC(typeData.border, SC(T("eventBorder"), Color(255, 255, 255)))
        surface.SetDrawColor(borderCol.r, borderCol.g, borderCol.b, 255)

        -- Outer border
        surface.DrawOutlinedRect(bgX, bgY, w, h, 2)

        -- Inner decorative border
        surface.DrawOutlinedRect(bgX + 6, bgY + 6, w - 12, h - 12, 1)

        -- Corner accents
        local cs = T("eventCornerSize") or 12
        if type(cs) ~= "number" then cs = 12 end
        surface.DrawRect(bgX, bgY, cs, cs)
        surface.DrawRect(bgX + w - cs, bgY, cs, cs)
        surface.DrawRect(bgX, bgY + h - cs, cs, cs)
        surface.DrawRect(bgX + w - cs, bgY + h - cs, cs, cs)

        -- Calculate visible characters based on animation
        local visibleTitleChars = 0
        local visibleTextChars = 0

        if self.AnimState == "fade_in" then
            visibleTitleChars = 0
            visibleTextChars = 0
        elseif self.AnimState == "typing" then
            local elapsed = CurTime() - self.TypeStart
            local totalChars = math.floor(elapsed * self.TypewriterSpeed)

            visibleTitleChars = math.min(totalChars, #self.TitleChars)
            visibleTextChars = math.max(0, totalChars - #self.TitleChars)
            visibleTextChars = math.min(visibleTextChars, #self.TextChars)

            if visibleTitleChars >= #self.TitleChars and visibleTextChars >= #self.TextChars then
                self.AnimState = "display"
                self.DisplayStart = CurTime()
            end
        else
            visibleTitleChars = #self.TitleChars
            visibleTextChars = #self.TextChars
        end

        -- Draw title
        surface.SetFont("GlitchLab_Large")
        local titleText = ""
        for i = 1, visibleTitleChars do
            titleText = titleText .. (self.TitleChars[i] or "")
        end

        -- Icon + Title
        local icon = typeData.icon or ""
        local fullTitle = icon .. " " .. titleText .. " " .. icon
        local titleW = surface.GetTextSize(fullTitle)
        local titleX = bgX + (w - titleW) / 2
        local titleY = bgY + 25

        -- Title shadow
        surface.SetTextColor(0, 0, 0, 200)
        surface.SetTextPos(titleX + 2, titleY + 2)
        surface.DrawText(fullTitle)

        -- Title color
        local titleCol = SC(typeData.title, SC(typeData.border, Color(255, 255, 255)))
        surface.SetTextColor(titleCol.r, titleCol.g, titleCol.b, 255)
        surface.SetTextPos(titleX, titleY)
        surface.DrawText(fullTitle)

        -- Draw text
        surface.SetFont("GlitchLab_Main")
        local msgText = ""
        for i = 1, visibleTextChars do
            msgText = msgText .. (self.TextChars[i] or "")
        end

        local textW = surface.GetTextSize(msgText)
        local textX = bgX + (w - textW) / 2
        local textY = bgY + 75

        -- Text shadow
        surface.SetTextColor(0, 0, 0, 180)
        surface.SetTextPos(textX + 1, textY + 1)
        surface.DrawText(msgText)

        -- Text color
        local textCol = SC(typeData.text, SC(T("textDefault"), Color(255, 255, 255)))
        surface.SetTextColor(textCol.r, textCol.g, textCol.b, 255)
        surface.SetTextPos(textX, textY)
        surface.DrawText(msgText)

        -- Typing cursor
        if self.AnimState == "typing" then
            if math.floor(CurTime() * 4) % 2 == 0 then
                local cursorX = textX + textW
                surface.SetTextColor(borderCol.r, borderCol.g, borderCol.b, 255)
                surface.SetTextPos(cursorX, textY)
                surface.DrawText("_")
            end
        end

        -- Decorative line under title
        surface.SetDrawColor(borderCol.r, borderCol.g, borderCol.b, 150)
        local lineY = bgY + 60
        local lineW = w * 0.6
        local lineX = bgX + (w - lineW) / 2
        surface.DrawRect(lineX, lineY, lineW, 1)

        -- Progress bar at bottom
        if self.AnimState == "display" then
            local elapsed = CurTime() - self.DisplayStart
            local progress = 1 - (elapsed / self.DisplayDuration)
            progress = math.Clamp(progress, 0, 1)

            local barH = 3
            local barY = bgY + h - 15
            local barW = (w - 40) * progress
            local barX = bgX + 20

            surface.SetDrawColor(50, 50, 50, 200)
            surface.DrawRect(barX, barY, w - 40, barH)

            surface.SetDrawColor(borderCol.r, borderCol.g, borderCol.b, 200)
            surface.DrawRect(barX, barY, barW, barH)
        end
    end
    
    panel.Think = function(self)
        local now = CurTime()
        
        if self.AnimState == "fade_in" then
            local elapsed = now - self.AnimStart
            local alpha = math.Clamp(elapsed / self.FadeDuration, 0, 1) * 255
            self:SetAlpha(alpha)
            
            if elapsed >= self.FadeDuration then
                self.AnimState = "typing"
                self.TypeStart = now
            end
            
        elseif self.AnimState == "display" then
            local elapsed = now - self.DisplayStart
            
            if elapsed >= self.DisplayDuration then
                self.AnimState = "fade_out"
                self.FadeOutStart = now
            end
            
        elseif self.AnimState == "fade_out" then
            local elapsed = now - self.FadeOutStart
            local alpha = (1 - math.Clamp(elapsed / self.FadeDuration, 0, 1)) * 255
            self:SetAlpha(alpha)
            
            if elapsed >= self.FadeDuration then
                events.Current = nil
                self:Remove()
                events.Panel = nil
                
                -- Process next event in queue
                events.ProcessQueue()
            end
        end
    end
    
    events.Panel = panel
    return panel
end

-- ============================================
-- UTF-8 HELPER
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

-- ============================================
-- SHOW EVENT
-- ============================================

local function ShowEvent(eventData)
    events.Current = eventData
    
    local panel = CreateEventPanel()
    
    local typeData = GetEventType(eventData.type or "info")
    
    panel.EventData = eventData
    panel.TypeData = typeData
    panel.TitleChars = UTF8ToTable(eventData.title or "")
    panel.TextChars = UTF8ToTable(eventData.text or "")
    panel.DisplayDuration = eventData.duration or 3
    panel.TypewriterSpeed = eventData.speed or 40
    
    -- Play sound
    if eventData.sound ~= false then
        PlayEventSound(eventData.type)
    end
    
    -- Start shake
    if eventData.shake ~= false and typeData.shake then
        StartShake(typeData.shakeIntensity, 0.5)
    end
end

-- ============================================
-- PROCESS QUEUE
-- ============================================

function events.ProcessQueue()
    if events.Current then return end -- already showing something
    
    if #events.Queue > 0 then
        local nextEvent = table.remove(events.Queue, 1)
        ShowEvent(nextEvent)
    end
end

-- ============================================
-- PUBLIC API: Trigger Event
-- ============================================

function GlitchLab.Event(title, text, options)
    options = options or {}
    
    local eventData = {
        title = title or "EVENT",
        text = text or "",
        type = options.type or "info",
        duration = options.duration or 3,
        speed = options.speed or 40,
        shake = options.shake,
        sound = options.sound,
    }
    
    -- Add to queue
    table.insert(events.Queue, eventData)
    
    -- Try to process immediately
    events.ProcessQueue()
end

-- Alias
GlitchLab.TriggerEvent = GlitchLab.Event

-- ============================================
-- CLOSE CURRENT EVENT
-- ============================================

function events.Close()
    if IsValid(events.Panel) then
        events.Panel.AnimState = "fade_out"
        events.Panel.FadeOutStart = CurTime()
    end
end

function events.CloseAll()
    events.Queue = {}
    events.Close()
end

-- ============================================
-- NETWORK RECEIVE
-- ============================================

net.Receive("GlitchLab_Event", function()
    local title = net.ReadString()
    local text = net.ReadString()
    local eventType = net.ReadString()
    local duration = net.ReadFloat()
    local shake = net.ReadBool()
    local sound = net.ReadBool()
    
    GlitchLab.Event(title, text, {
        type = eventType,
        duration = duration,
        shake = shake,
        sound = sound,
    })
end)

-- ============================================
-- CONSOLE COMMANDS (for testing)
-- ============================================

concommand.Add("uc_event", function(ply, cmd, args)
    local title = args[1] or "TEST EVENT"
    local text = args[2] or "This is a test event message."
    local eventType = args[3] or "info"
    
    GlitchLab.Event(title, text, {type = eventType})
end, nil, "Trigger a test event: uc_event <title> <text> <type>")

concommand.Add("uc_event_info", function()
    GlitchLab.Event("INFORMATION", "This is an info event.", {type = "info"})
end)

concommand.Add("uc_event_warning", function()
    GlitchLab.Event("WARNING", "Something requires your attention!", {type = "warning"})
end)

concommand.Add("uc_event_error", function()
    GlitchLab.Event("ERROR", "Something went terribly wrong!", {type = "error"})
end)

concommand.Add("uc_event_story", function()
    GlitchLab.Event("CHAPTER 1", "* The journey begins...", {type = "story", duration = 5})
end)

concommand.Add("uc_event_success", function()
    GlitchLab.Event("SUCCESS", "Operation completed successfully!", {type = "success"})
end)

concommand.Add("uc_event_close", function()
    events.Close()
end)

concommand.Add("uc_event_clear", function()
    events.CloseAll()
end)

-- ============================================
-- CLEANUP
-- ============================================

hook.Add("ShutDown", "GlitchLab_EventsCleanup", function()
    if IsValid(events.Panel) then
        events.Panel:Remove()
    end
end)

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), "Events system loaded (v0.6.0)\n")