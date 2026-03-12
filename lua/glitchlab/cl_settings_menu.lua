--[[
    GlitchLab | UnderComms — Settings Menu GUI
    
    v0.9.0 — ULTIMATE SETTINGS EDITION
    
    "* You opened the settings. All possible options lay before you."
    
    No symbols were harmed in the making of this menu.
    Because they don't fucking work in Source engine fonts.
]]

local settings = GlitchLab.Settings
local cfg = GlitchLab.Config

local PANEL_WIDTH = 580
local PANEL_HEIGHT = 700

-- Theme-aware colors
local function GetMenuColors()
    local theme = GlitchLab.Theme or {}
    return {
        bg = theme.menuBg or Color(15, 15, 15, 250),
        border = theme.menuBorder or Color(255, 255, 255),
        accent = theme.menuAccent or Color(177, 102, 199),
        text = theme.menuText or Color(255, 255, 255),
        textDim = theme.menuTextDim or Color(150, 150, 150),
        sliderBg = theme.menuSliderBg or Color(40, 40, 40),
        sliderFill = theme.menuSliderFill or Color(177, 102, 199),
        checkOn = theme.menuCheckOn or Color(100, 255, 100),
        checkOff = theme.menuCheckOff or Color(100, 100, 100),
        buttonBg = theme.menuButtonBg or Color(40, 40, 40),
        buttonHover = theme.menuButtonHover or Color(60, 60, 60),
        sectionBg = theme.menuSection or Color(25, 25, 25, 200),
        categoryBg = theme.menuCategoryBg or Color(35, 35, 40, 220),
        warning = Color(255, 200, 100),
        error = Color(255, 100, 100),
        success = Color(100, 255, 100),
    }
end

local colors = {}

-- ============================================
-- TABS SYSTEM (NO EMOJIS!)
-- ============================================

local TABS = {
    {id = "voice",    name = "Voice",    shortName = "VOC"},
    {id = "sound",    name = "Sound",    shortName = "SND"},
    {id = "visual",   name = "Visual",   shortName = "VIS"},
    {id = "position", name = "Position", shortName = "POS"},
    {id = "theme",    name = "Theme",    shortName = "THM"},
    {id = "messages", name = "Messages", shortName = "MSG"},
    {id = "input",    name = "Input",    shortName = "INP"},
    {id = "advanced", name = "Advanced", shortName = "ADV"},
}

local currentTab = "voice"

-- ============================================
-- HELPERS
-- ============================================

local function CreateSection(parent, text)
    local section = vgui.Create("DPanel", parent)
    section:Dock(TOP)
    section:DockMargin(0, 10, 0, 5)
    section:SetTall(28)
    
    section.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colors.sectionBg)
        surface.SetDrawColor(colors.accent)
        surface.DrawRect(0, h - 2, w, 2)
        
        surface.SetFont("GlitchLab_Main")
        surface.SetTextColor(colors.accent)
        surface.SetTextPos(10, 6)
        surface.DrawText(text)
    end
    
    return section
end

local function CreateCheckbox(parent, text, cvarName, tooltip)
    local container = vgui.Create("DPanel", parent)
    container:Dock(TOP)
    container:DockMargin(10, 4, 10, 0)
    container:SetTall(24)
    container.Paint = function() end
    
    local check = vgui.Create("DButton", container)
    check:SetPos(0, 2)
    check:SetSize(20, 20)
    check:SetText("")
    if tooltip then check:SetTooltip(tooltip) end
    
    check.Paint = function(self, w, h)
        local cvar = GetConVar(cvarName)
        local checked = cvar and cvar:GetBool() or false
        local col = checked and colors.checkOn or colors.checkOff
        
        draw.RoundedBox(2, 0, 0, w, h, colors.sliderBg)
        if checked then
            draw.RoundedBox(2, 3, 3, w - 6, h - 6, col)
        end
        surface.SetDrawColor(self:IsHovered() and colors.accent or colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    check.DoClick = function()
        local cvar = GetConVar(cvarName)
        if cvar then
            RunConsoleCommand(cvarName, cvar:GetBool() and "0" or "1")
        end
        surface.PlaySound("buttons/button15.wav")
    end
    
    local label = vgui.Create("DLabel", container)
    label:SetPos(28, 4)
    label:SetText(text)
    label:SetFont("GlitchLab_Main")
    label:SetTextColor(colors.text)
    label:SizeToContents()
    label:SetMouseInputEnabled(true)
    label.OnMousePressed = function() check:DoClick() end
    if tooltip then label:SetTooltip(tooltip) end
    
    return container
end

local function CreateSlider(parent, text, cvarName, min, max, decimals, tooltip)
    local container = vgui.Create("DPanel", parent)
    container:Dock(TOP)
    container:DockMargin(10, 4, 10, 0)
    container:SetTall(45)
    container.Paint = function() end
    
    local label = vgui.Create("DLabel", container)
    label:SetPos(0, 0)
    label:SetText(text)
    label:SetFont("GlitchLab_Main")
    label:SetTextColor(colors.text)
    label:SizeToContents()
    if tooltip then label:SetTooltip(tooltip) end
    
    local valueLabel = vgui.Create("DLabel", container)
    valueLabel:SetPos(340, 0)
    valueLabel:SetFont("GlitchLab_Main")
    valueLabel:SetTextColor(colors.accent)
    
    local slider = vgui.Create("DSlider", container)
    slider:SetPos(0, 22)
    slider:SetSize(500, 18)
    
    local cvar = GetConVar(cvarName)
    local initVal = cvar and cvar:GetFloat() or min
    slider:SetSlideX((initVal - min) / (max - min))
    
    slider.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, h/2 - 3, w, 6, colors.sliderBg)
        draw.RoundedBox(4, 0, h/2 - 3, self:GetSlideX() * w, 6, colors.sliderFill)
        surface.SetDrawColor(colors.border)
        surface.DrawOutlinedRect(0, h/2 - 3, w, 6, 1)
    end
    
    slider.Knob:SetSize(12, 16)
    slider.Knob.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, colors.accent)
    end
    
    local function UpdateValue()
        local val = min + slider:GetSlideX() * (max - min)
        if decimals == 0 then
            val = math.Round(val)
        else
            val = math.Round(val * (10 ^ decimals)) / (10 ^ decimals)
        end
        valueLabel:SetText(tostring(val))
        valueLabel:SizeToContents()
        RunConsoleCommand(cvarName, tostring(val))
    end
    
    slider.OnValueChanged = UpdateValue
    valueLabel:SetText(decimals == 0 and tostring(math.Round(initVal)) or tostring(initVal))
    valueLabel:SizeToContents()
    
    return container
end

local function CreateComboBox(parent, text, cvarName, options, tooltip)
    local container = vgui.Create("DPanel", parent)
    container:Dock(TOP)
    container:DockMargin(10, 4, 10, 0)
    container:SetTall(32)
    container.Paint = function() end
    
    local label = vgui.Create("DLabel", container)
    label:SetPos(0, 6)
    label:SetText(text)
    label:SetFont("GlitchLab_Main")
    label:SetTextColor(colors.text)
    label:SizeToContents()
    if tooltip then label:SetTooltip(tooltip) end
    
    local combo = vgui.Create("DComboBox", container)
    combo:SetPos(180, 2)
    combo:SetSize(320, 28)
    combo:SetFont("GlitchLab_Main")
    combo:SetTextColor(colors.text)
    
    combo.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, colors.sliderBg)
        surface.SetDrawColor(self:IsHovered() and colors.accent or colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    local cvar = GetConVar(cvarName)
    local currentVal = cvar and (cvar:GetString() or tostring(cvar:GetInt())) or ""
    
    for _, opt in ipairs(options) do
        local isSelected = tostring(opt.value) == currentVal
        combo:AddChoice(opt.name, opt.value, isSelected)
    end
    
    combo.OnSelect = function(self, index, value, data)
        RunConsoleCommand(cvarName, tostring(data))
        surface.PlaySound("buttons/button15.wav")
    end
    
    return combo, container
end

local function CreateColorPicker(parent, text, cvarR, cvarG, cvarB, tooltip)
    local container = vgui.Create("DPanel", parent)
    container:Dock(TOP)
    container:DockMargin(10, 4, 10, 0)
    container:SetTall(32)
    container.Paint = function() end
    
    local label = vgui.Create("DLabel", container)
    label:SetPos(0, 6)
    label:SetText(text)
    label:SetFont("GlitchLab_Main")
    label:SetTextColor(colors.text)
    label:SizeToContents()
    if tooltip then label:SetTooltip(tooltip) end
    
    local r = GetConVar(cvarR) and GetConVar(cvarR):GetInt() or 255
    local g = GetConVar(cvarG) and GetConVar(cvarG):GetInt() or 255
    local b = GetConVar(cvarB) and GetConVar(cvarB):GetInt() or 255
    
    local colorBtn = vgui.Create("DButton", container)
    colorBtn:SetPos(180, 2)
    colorBtn:SetSize(100, 28)
    colorBtn:SetText("")
    
    colorBtn.Paint = function(self, w, h)
        local cr = GetConVar(cvarR) and GetConVar(cvarR):GetInt() or 255
        local cg = GetConVar(cvarG) and GetConVar(cvarG):GetInt() or 255
        local cb = GetConVar(cvarB) and GetConVar(cvarB):GetInt() or 255
        
        draw.RoundedBox(4, 0, 0, w, h, Color(cr, cg, cb))
        surface.SetDrawColor(self:IsHovered() and colors.accent or colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    
    colorBtn.DoClick = function()
        local picker = vgui.Create("DFrame")
        picker:SetSize(300, 350)
        picker:Center()
        picker:SetTitle("Pick Color")
        picker:MakePopup()
        
        local mixer = vgui.Create("DColorMixer", picker)
        mixer:Dock(FILL)
        mixer:SetPalette(true)
        mixer:SetAlphaBar(false)
        mixer:SetWangs(true)
        mixer:SetColor(Color(r, g, b))
        
        mixer.ValueChanged = function(self, col)
            RunConsoleCommand(cvarR, tostring(col.r))
            RunConsoleCommand(cvarG, tostring(col.g))
            RunConsoleCommand(cvarB, tostring(col.b))
        end
    end
    
    return container
end

local function CreateButton(parent, text, onClick, width, bgColor)
    local btn = vgui.Create("DButton", parent)
    btn:Dock(TOP)
    btn:DockMargin(10, 5, 10, 0)
    btn:SetTall(32)
    btn:SetText("")
    
    btn.Paint = function(self, w, h)
        local col = self:IsHovered() and colors.buttonHover or (bgColor or colors.buttonBg)
        draw.RoundedBox(4, 0, 0, w, h, col)
        surface.SetDrawColor(colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        surface.SetFont("GlitchLab_Main")
        surface.SetTextColor(colors.text)
        local tw = surface.GetTextSize(text)
        surface.SetTextPos(w/2 - tw/2, 8)
        surface.DrawText(text)
    end
    
    btn.DoClick = function()
        surface.PlaySound("buttons/button15.wav")
        if onClick then onClick() end
    end
    
    return btn
end

local function CreateSpacer(parent, height)
    local spacer = vgui.Create("DPanel", parent)
    spacer:Dock(TOP)
    spacer:SetTall(height or 10)
    spacer.Paint = function() end
    return spacer
end

-- ============================================
-- TAB CONTENT BUILDERS
-- ============================================

local function BuildVoiceTab(parent)
    CreateSection(parent, "YOUR VOICE")
    
    -- Voice selector
    if GlitchLab.Voices and GlitchLab.Voices.List then
        local voiceOptions = {}
        for id, voice in pairs(GlitchLab.Voices.List) do
            table.insert(voiceOptions, {
                name = "[" .. voice.category .. "] " .. voice.name,
                value = id
            })
        end
        table.sort(voiceOptions, function(a, b) return a.name < b.name end)
        
        local voiceCombo, voiceContainer = CreateComboBox(parent, "Voice Type:", "uc_voice", voiceOptions,
            "Your unique voice that others will hear")
        
        -- Preview button
        local previewBtn = vgui.Create("DButton", voiceContainer)
        previewBtn:SetPos(420, 2)
        previewBtn:SetSize(80, 28)
        previewBtn:SetText("")
        previewBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(80, 180, 80) or Color(50, 130, 50)
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText("[>] Test", "GlitchLab_Small", w/2, h/2, colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        previewBtn.DoClick = function()
            local _, voiceId = voiceCombo:GetSelected()
            if voiceId and GlitchLab.PreviewVoicePhrase then
                local pitch = GetConVar("uc_voice_pitch") and GetConVar("uc_voice_pitch"):GetInt() or 0
                local vol = GetConVar("uc_voice_volume") and GetConVar("uc_voice_volume"):GetFloat() or 0
                GlitchLab.PreviewVoicePhrase(voiceId, pitch, vol, "Hello! This is my voice!")
            end
        end
        
        -- Description
        local descLabel = vgui.Create("DLabel", parent)
        descLabel:Dock(TOP)
        descLabel:DockMargin(10, 0, 10, 5)
        descLabel:SetFont("GlitchLab_Small")
        descLabel:SetTextColor(colors.textDim)
        descLabel:SetTall(20)
        
        local function UpdateDesc()
            local _, voiceId = voiceCombo:GetSelected()
            if voiceId and GlitchLab.Voices.List[voiceId] then
                descLabel:SetText("  " .. GlitchLab.Voices.List[voiceId].description)
            end
        end
        UpdateDesc()
        voiceCombo.OnSelect = function(self, idx, val, data)
            RunConsoleCommand("uc_voice", tostring(data))
            UpdateDesc()
            surface.PlaySound("buttons/button15.wav")
        end
    else
        local noVoice = vgui.Create("DLabel", parent)
        noVoice:Dock(TOP)
        noVoice:DockMargin(10, 10, 10, 10)
        noVoice:SetText("Voice system not loaded")
        noVoice:SetTextColor(colors.textDim)
    end
    
    CreateSlider(parent, "Pitch Offset", "uc_voice_pitch", -50, 50, 0,
        "Adjust voice pitch. Negative = deeper, Positive = higher")
    CreateSlider(parent, "Volume Offset", "uc_voice_volume", -30, 30, 0,
        "Adjust voice volume (in %)")
    
    CreateSection(parent, "VOICE SYNC")
    CreateCheckbox(parent, "Sync voice to other players", "uc_voice_sync",
        "Others will hear your custom voice")
    CreateCheckbox(parent, "Hear others' custom voices", "uc_voice_hear_others",
        "Hear other players' voice selections")
end

local function BuildSoundTab(parent)
    CreateSection(parent, "BLIP SOUNDS")
    CreateCheckbox(parent, "Enable Blip Sounds", "uc_blip_enabled",
        "Undertale-style character sounds")
    CreateSlider(parent, "Blip Volume", "uc_blip_volume", 0, 100, 0,
        "Master volume for blip sounds")
    CreateSlider(parent, "Max Simultaneous Blips", "uc_max_blips", 1, 5, 0,
        "How many messages can blip at once")
    CreateSlider(parent, "Blip Cooldown (ms)", "uc_blip_cooldown", 10, 100, 0,
        "Minimum time between blips")
    
    CreateSection(parent, "RADIO STYLE (/r)")
    CreateCheckbox(parent, "Enable Radio Static", "uc_radio_static",
        "Background static noise for radio messages")
    CreateSlider(parent, "Radio Static Volume", "uc_radio_volume", 0, 100, 0,
        "Volume of radio static effects")
    CreateCheckbox(parent, "Radio Crackles", "uc_radio_crackle",
        "Random crackle sounds during transmission")
    
    CreateSection(parent, "TELEGRAPH STYLE (/t)")
    CreateCheckbox(parent, "Enable Telegraph Sounds", "uc_telegraph_enabled",
        "Morse code beeps for telegraph messages")
    CreateSlider(parent, "Telegraph Volume", "uc_telegraph_volume", 0, 100, 0,
        "Volume of telegraph beeps")
    
    CreateSection(parent, "LETTER STYLE (/l)")
    CreateCheckbox(parent, "Enable Paper Sounds", "uc_paper_enabled",
        "Paper rustling sounds for letters")
    CreateSlider(parent, "Paper Volume", "uc_paper_volume", 0, 100, 0,
        "Volume of paper sounds")
    
    CreateSection(parent, "NOTIFICATIONS")
    CreateCheckbox(parent, "Mention Sound", "uc_mention_sound",
        "Play sound when your name is mentioned")
    CreateSlider(parent, "Mention Volume", "uc_mention_volume", 0, 100, 0,
        "Volume of mention notification")
    CreateCheckbox(parent, "New Message Sound", "uc_newmsg_sound",
        "Sound when new message arrives (chat closed)")
end

local function BuildVisualTab(parent)
    CreateSection(parent, "TYPEWRITER EFFECT")
    CreateSlider(parent, "Typing Speed", "uc_type_speed", 25, 300, 0,
        "Characters per second (higher = faster)")
    CreateCheckbox(parent, "Instant Messages", "uc_instant_messages",
        "Show messages immediately (no animation)")
    CreateCheckbox(parent, "Show Typing Cursor", "uc_show_cursor",
        "Blinking underscore while typing")
    CreateSlider(parent, "Cursor Blink Speed", "uc_cursor_speed", 1, 10, 0,
        "How fast the cursor blinks")
    
    CreateSection(parent, "EFFECTS")
    CreateCheckbox(parent, "Enable Glitch Effects", "uc_effects",
        "Visual glitches for radio messages")
    CreateSlider(parent, "Glitch Intensity", "uc_glitch_intensity", 0, 100, 0,
        "How intense the glitch effects are")
    CreateCheckbox(parent, "Enable Screen Shake", "uc_shake",
        "Screen shake during glitches")
    CreateSlider(parent, "Shake Intensity", "uc_shake_intensity", 0, 100, 0,
        "How strong the shake is")
    
    CreateSection(parent, "CRT EFFECTS")
    CreateCheckbox(parent, "Enable Scanlines", "uc_scanlines",
        "Retro CRT monitor lines")
    CreateSlider(parent, "Scanline Opacity", "uc_scanline_opacity", 0, 100, 0,
        "Visibility of scanlines")
    CreateCheckbox(parent, "Enable Glow", "uc_glow",
        "Subtle glow around chat box")
    CreateSlider(parent, "Glow Intensity", "uc_glow_intensity", 0, 100, 0,
        "Brightness of glow effect")
    
    CreateSection(parent, "TEXT")
    CreateCheckbox(parent, "Show Timestamps", "uc_timestamps",
        "Show [HH:MM] before messages")
    CreateComboBox(parent, "Timestamp Format:", "uc_timestamp_format", {
        {name = "[HH:MM]", value = "1"},
        {name = "[HH:MM:SS]", value = "2"},
        {name = "[MM:SS]", value = "3"},
    })
    CreateCheckbox(parent, "Text Shadows", "uc_text_shadows",
        "Drop shadow under text")
    CreateSlider(parent, "Shadow Opacity", "uc_shadow_opacity", 0, 100, 0,
        "Darkness of text shadows")
end

local function BuildPositionTab(parent)
    CreateSection(parent, "CHAT POSITION")
    CreateSlider(parent, "X Position (from left)", "uc_chat_x", 0, 800, 0)
    CreateSlider(parent, "Y Position (from bottom)", "uc_chat_y", 0, 600, 0)
    CreateSlider(parent, "Width", "uc_chat_width", 200, 1200, 0)
    CreateSlider(parent, "Height", "uc_chat_height", 100, 800, 0)
    
    CreateButton(parent, "[X] Reset Position to Default", function()
        RunConsoleCommand("uc_chat_x", "24")
        RunConsoleCommand("uc_chat_y", "140")
        RunConsoleCommand("uc_chat_width", "620")
        RunConsoleCommand("uc_chat_height", "300")
    end, nil, Color(100, 60, 60))
    
    CreateSection(parent, "SCALE")
    CreateSlider(parent, "UI Scale (overall)", "uc_ui_scale", 50, 200, 0,
        "Overall size multiplier (%)")
    CreateSlider(parent, "Text Scale", "uc_text_scale", 50, 200, 0,
        "Text size multiplier (%)")
    CreateSlider(parent, "Icon Scale", "uc_icon_scale", 50, 200, 0,
        "Icons and avatars multiplier (%)")
    
    CreateSection(parent, "SIZES (pixels)")
    CreateSlider(parent, "Avatar Size", "uc_avatar_size", 12, 64, 0)
    CreateSlider(parent, "Icon Size", "uc_icon_size", 8, 48, 0)
    CreateSlider(parent, "Line Height", "uc_line_height", 12, 50, 0)
    CreateSlider(parent, "Input Height", "uc_input_height", 20, 60, 0)
    CreateSlider(parent, "Border Thickness", "uc_border_thickness", 1, 6, 0)
    
    CreateButton(parent, "[X] Reset Scale to Default", function()
        RunConsoleCommand("uc_ui_scale", "100")
        RunConsoleCommand("uc_text_scale", "100")
        RunConsoleCommand("uc_icon_scale", "100")
        RunConsoleCommand("uc_avatar_size", "18")
        RunConsoleCommand("uc_icon_size", "16")
        RunConsoleCommand("uc_line_height", "20")
    end, nil, Color(100, 60, 60))
end

local function BuildThemeTab(parent)
    CreateSection(parent, "THEME SELECTION")
    
    local themeOptions = {}
    if GlitchLab.GetThemeList then
        for _, t in ipairs(GlitchLab.GetThemeList()) do
            table.insert(themeOptions, {name = t.name, value = t.id})
        end
    end
    
    CreateComboBox(parent, "Theme:", "uc_theme", themeOptions)
    
    local themeDesc = vgui.Create("DLabel", parent)
    themeDesc:Dock(TOP)
    themeDesc:DockMargin(10, 0, 10, 10)
    themeDesc:SetFont("GlitchLab_Small")
    themeDesc:SetTextColor(colors.textDim)
    themeDesc:SetText(GlitchLab.Theme and ("by " .. (GlitchLab.Theme.author or "Unknown")) or "")
    themeDesc:SizeToContents()
    
    CreateSection(parent, "AVATAR & ICONS")
    CreateComboBox(parent, "Avatar Mode:", "uc_avatar_mode", {
        {name = "None", value = "0"},
        {name = "Steam Avatar", value = "1"},
        {name = "Character Sprite", value = "2"},
    })
    
    -- Sprite selector
    local spriteOptions = {}
    if GlitchLab.Sprites and GlitchLab.Sprites.GetCharacterList then
        for _, c in ipairs(GlitchLab.Sprites.GetCharacterList()) do
            table.insert(spriteOptions, {name = "[" .. c.game .. "] " .. c.name, value = c.id})
        end
    end
    CreateComboBox(parent, "Character Sprite:", "uc_avatar_sprite", spriteOptions)
    
    CreateComboBox(parent, "Avatar Shape:", "uc_avatar_shape", {
        {name = "Square", value = "square"},
        {name = "Circle", value = "circle"},
        {name = "Rounded", value = "rounded"},
    })
    CreateCheckbox(parent, "Avatar Border", "uc_avatar_border")
    CreateCheckbox(parent, "Show Style Icons", "uc_show_style_icons")
    
    CreateSection(parent, "CUSTOM COLORS")
    CreateCheckbox(parent, "Use Custom Colors", "uc_custom_colors",
        "Override theme colors with your own")
    CreateColorPicker(parent, "Background:", "uc_color_bg_r", "uc_color_bg_g", "uc_color_bg_b")
    CreateColorPicker(parent, "Border:", "uc_color_border_r", "uc_color_border_g", "uc_color_border_b")
    CreateColorPicker(parent, "Accent:", "uc_color_accent_r", "uc_color_accent_g", "uc_color_accent_b")
    CreateColorPicker(parent, "Text:", "uc_color_text_r", "uc_color_text_g", "uc_color_text_b")
    CreateSlider(parent, "Background Opacity", "uc_bg_opacity", 0, 100, 0)
end

local function BuildMessagesTab(parent)
    CreateSection(parent, "MESSAGE DISPLAY")
    CreateSlider(parent, "Fade Time (seconds)", "uc_fade_time", 3, 120, 0,
        "How long messages stay visible")
    CreateSlider(parent, "Fade Duration", "uc_fade_duration", 0, 5, 1,
        "How long the fade animation takes")
    CreateSlider(parent, "Max Messages", "uc_max_messages", 20, 500, 0,
        "Maximum messages in history")
    
    CreateSection(parent, "MESSAGE TYPES")
    CreateCheckbox(parent, "Show System Messages", "uc_show_system",
        "Server notifications and announcements")
    CreateCheckbox(parent, "Show Join/Leave Messages", "uc_show_joinleave",
        "Player connected/disconnected messages")
    CreateCheckbox(parent, "Show Death Messages", "uc_show_death",
        "Player killed messages")
    CreateCheckbox(parent, "Show Admin Messages", "uc_show_admin",
        "ULX/Admin chat messages")
    
    CreateSection(parent, "HIGHLIGHTING")
    CreateCheckbox(parent, "Highlight Own Messages", "uc_highlight_own",
        "Make your messages stand out")
    CreateColorPicker(parent, "Own Message Color:", "uc_own_r", "uc_own_g", "uc_own_b")
    CreateCheckbox(parent, "Highlight Mentions", "uc_highlight_mentions",
        "Highlight when someone says your name")
    CreateColorPicker(parent, "Mention Color:", "uc_mention_r", "uc_mention_g", "uc_mention_b")
    
    CreateSection(parent, "LINKS")
    CreateCheckbox(parent, "Clickable Links", "uc_clickable_links",
        "Make URLs clickable")
    CreateColorPicker(parent, "Link Color:", "uc_link_r", "uc_link_g", "uc_link_b")
    CreateCheckbox(parent, "Underline Links", "uc_underline_links")
    CreateCheckbox(parent, "Show Link Previews", "uc_link_previews",
        "Show preview for images/videos")
end

local function BuildInputTab(parent)
    CreateSection(parent, "INPUT BEHAVIOR")
    CreateCheckbox(parent, "Save Draft on Close", "uc_save_draft",
        "Remember unfinished messages")
    CreateSlider(parent, "History Size", "uc_history_size", 10, 200, 0,
        "How many previous messages to remember")
    CreateCheckbox(parent, "Enable Autocomplete", "uc_autocomplete",
        "Tab to complete player names")
    CreateComboBox(parent, "Autocomplete Key:", "uc_autocomplete_key", {
        {name = "Tab", value = "tab"},
        {name = "Ctrl+Space", value = "ctrlspace"},
    })
    
    CreateSection(parent, "PLACEHOLDER")
    CreateCheckbox(parent, "Show Placeholder", "uc_show_placeholder",
        "Hint text in empty input")
    CreateCheckbox(parent, "Dynamic Placeholder", "uc_dynamic_placeholder",
        "Change hint based on command typed")
    
    CreateSection(parent, "CLOSE BEHAVIOR")
    CreateCheckbox(parent, "Close on Escape", "uc_close_escape",
        "ESC key closes chat")
    CreateCheckbox(parent, "Close on Click Outside", "uc_close_click",
        "Clicking outside closes chat")
    CreateCheckbox(parent, "Close After Send", "uc_close_send",
        "Automatically close after sending")
end

local function BuildAdvancedTab(parent)
    CreateSection(parent, "PERFORMANCE")
    CreateCheckbox(parent, "Performance Mode", "uc_performance_mode",
        "Reduce effects for better FPS")
    CreateCheckbox(parent, "Disable Animations", "uc_no_animations",
        "Skip all animations")
    CreateSlider(parent, "Max GIF Size (MB)", "uc_max_gif_size", 1, 10, 0,
        "Maximum size for GIF loading")
    CreateSlider(parent, "Render Distance", "uc_render_distance", 100, 2000, 0,
        "Distance for proximity chat")
    
    CreateSection(parent, "NETWORK")
    CreateCheckbox(parent, "Network Compression", "uc_net_compression",
        "Compress long messages")
    CreateCheckbox(parent, "Anti-Spam", "uc_antispam",
        "Limit message rate")
    CreateSlider(parent, "Spam Cooldown (ms)", "uc_spam_cooldown", 100, 2000, 0,
        "Minimum time between messages")
    
    CreateSection(parent, "LOGGING")
    CreateCheckbox(parent, "Log Messages to File", "uc_log_messages",
        "Save chat history to data/glitchlab/logs/")
    CreateCheckbox(parent, "Log Timestamps", "uc_log_timestamps",
        "Include time in log files")
    CreateButton(parent, "[FOLDER] Open Log Folder", function()
        chat.AddText(Color(177, 102, 199), "[UnderComms] ", 
            Color(255, 255, 255), "Logs: garrysmod/data/glitchlab/logs/")
    end)
    
    CreateSection(parent, "DEBUG")
    CreateCheckbox(parent, "Debug Mode", "uc_debug",
        "Show debug messages in console")
    CreateCheckbox(parent, "Show FPS Impact", "uc_show_fps",
        "Display performance stats")
    
    CreateSpacer(parent, 20)
    
    CreateButton(parent, "[!] RESET ALL SETTINGS TO DEFAULT", function()
        Derma_Query(
            "This will reset ALL settings to default values.\n\nAre you sure?",
            "Reset Settings",
            "Yes, Reset",
            function()
                if settings.ResetAll then settings.ResetAll() end
                surface.PlaySound("buttons/button9.wav")
                timer.Simple(0.2, function()
                    GlitchLab.Settings.OpenMenu()
                end)
            end,
            "Cancel",
            function() end
        )
    end, nil, Color(150, 50, 50))
    
    CreateSpacer(parent, 10)
    
    CreateButton(parent, "[SAVE] EXPORT SETTINGS", function()
        chat.AddText(Color(177, 102, 199), "[UnderComms] ", 
            Color(255, 255, 255), "Settings export coming soon!")
    end)
    
    CreateButton(parent, "[LOAD] IMPORT SETTINGS", function()
        chat.AddText(Color(177, 102, 199), "[UnderComms] ", 
            Color(255, 255, 255), "Settings import coming soon!")
    end)
end

-- ============================================
-- MAIN MENU
-- ============================================

function GlitchLab.Settings.OpenMenu()
    if IsValid(GlitchLab.Settings.MenuPanel) then
        GlitchLab.Settings.MenuPanel:Remove()
    end
    
    colors = GetMenuColors()
    
    local scrW, scrH = ScrW(), ScrH()
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    frame:SetPos(scrW/2 - PANEL_WIDTH/2, scrH/2 - PANEL_HEIGHT/2)
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colors.bg)
        
        -- Border
        surface.SetDrawColor(colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        -- Accent corners
        surface.SetDrawColor(colors.accent)
        local cs = 10
        surface.DrawRect(0, 0, cs, cs)
        surface.DrawRect(w - cs, 0, cs, cs)
        surface.DrawRect(0, h - cs, cs, cs)
        surface.DrawRect(w - cs, h - cs, cs, cs)
        
        -- Title
        draw.SimpleText("* SETTINGS", "GlitchLab_Large", w/2, 22, colors.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Version
        draw.SimpleText("v0.9.0", "GlitchLab_Small", w - 50, 15, colors.textDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    GlitchLab.Settings.MenuPanel = frame
    
    -- Close button
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(PANEL_WIDTH - 40, 8)
    closeBtn:SetSize(30, 30)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(255, 100, 100) or colors.textDim
        draw.SimpleText("X", "GlitchLab_Main", w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        surface.PlaySound("buttons/button15.wav")
        frame:Close()
    end
    
    -- ========== TAB BUTTONS WITH SPRITE ICONS ==========
    local tabPanel = vgui.Create("DPanel", frame)
    tabPanel:SetPos(10, 45)
    tabPanel:SetSize(PANEL_WIDTH - 20, 40)
    tabPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colors.sectionBg)
    end
    
    local tabWidth = (PANEL_WIDTH - 20) / #TABS
    local tabButtons = {}
    
    for i, tab in ipairs(TABS) do
        local btn = vgui.Create("DButton", tabPanel)
        btn:SetPos((i - 1) * tabWidth, 0)
        btn:SetSize(tabWidth, 40)
        btn:SetText("")
        
        btn.Paint = function(self, w, h)
            local isActive = currentTab == tab.id
            local isHovered = self:IsHovered()
            local col = isActive and colors.accent or (isHovered and colors.buttonHover or Color(0, 0, 0, 0))
            
            draw.RoundedBox(0, 0, 0, w, h, col)
            
            if isActive then
                surface.SetDrawColor(colors.accent)
                surface.DrawRect(0, h - 3, w, 3)
            end
            
            -- Draw icon using sprite system
            local iconColor = isActive and colors.text or (isHovered and colors.text or colors.textDim)
            local iconSize = 18
            local iconX = w/2 - iconSize/2
            local iconY = 4
            
            if GlitchLab.Sprites and GlitchLab.Sprites.DrawMenuIcon then
                GlitchLab.Sprites.DrawMenuIcon(tab.id, iconX, iconY, iconSize, iconColor)
            end
            
            -- Short name below icon
            draw.SimpleText(tab.shortName, "GlitchLab_Small", w/2, h - 8, iconColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        btn.DoClick = function()
            currentTab = tab.id
            surface.PlaySound("buttons/button15.wav")
            frame:Close()
            GlitchLab.Settings.OpenMenu()
        end
        
        btn:SetTooltip(tab.name)
        tabButtons[tab.id] = btn
    end
    
    -- ========== CONTENT SCROLL ==========
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(10, 90)
    scroll:SetSize(PANEL_WIDTH - 20, PANEL_HEIGHT - 150)
    
    local sbar = scroll:GetVBar()
    sbar:SetWide(6)
    sbar.Paint = function(s, w, h) draw.RoundedBox(0, 0, 0, w, h, colors.sliderBg) end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function(s, w, h) draw.RoundedBox(3, 0, 0, w, h, colors.accent) end
    
    local content = scroll:GetCanvas()
    
    -- Build current tab content
    if currentTab == "voice" then
        BuildVoiceTab(content)
    elseif currentTab == "sound" then
        BuildSoundTab(content)
    elseif currentTab == "visual" then
        BuildVisualTab(content)
    elseif currentTab == "position" then
        BuildPositionTab(content)
    elseif currentTab == "theme" then
        BuildThemeTab(content)
    elseif currentTab == "messages" then
        BuildMessagesTab(content)
    elseif currentTab == "input" then
        BuildInputTab(content)
    elseif currentTab == "advanced" then
        BuildAdvancedTab(content)
    end
    
    -- ========== BOTTOM BUTTONS ==========
    local btnPanel = vgui.Create("DPanel", frame)
    btnPanel:SetPos(10, PANEL_HEIGHT - 55)
    btnPanel:SetSize(PANEL_WIDTH - 20, 45)
    btnPanel.Paint = function() end
    
    local applyBtn = vgui.Create("DButton", btnPanel)
    applyBtn:SetPos(PANEL_WIDTH - 30 - 150, 5)
    applyBtn:SetSize(150, 35)
    applyBtn:SetText("")
    applyBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(100, 200, 100) or Color(60, 150, 60)
        draw.RoundedBox(4, 0, 0, w, h, col)
        draw.SimpleText("Apply & Close", "GlitchLab_Small", w/2, h/2, colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    applyBtn.DoClick = function()
        surface.PlaySound("buttons/button9.wav")
        if settings.Apply then settings.Apply() end
        if GlitchLab.SendMyVoice then GlitchLab.SendMyVoice() end
        frame:Close()
    end
end

-- Console command
concommand.Add("uc_settings", function()
    GlitchLab.Settings.OpenMenu()
end)

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), "Ultimate Settings Menu loaded (v0.9.0 - No Emoji Edition)\n")