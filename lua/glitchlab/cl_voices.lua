--[[
    GlitchLab | UnderComms — Voice System (Client)
    
    v0.8.1 — VOICE SYNC EDITION
    
    Now actually fucking works with the settings system.
    Both ConVars and file storage are synced like a boss.
]]

GlitchLab = GlitchLab or {}
GlitchLab.ClientVoices = GlitchLab.ClientVoices or {}

-- ============================================
-- LOCAL STATE
-- ============================================

local myVoice = {
    voiceId = "default",
    pitchOffset = 0,
    volumeOffset = 0,
}

local voiceMenuOpen = false

-- ============================================
-- SYNC CONVARS <-> FILE
-- This is the magic that makes everything work
-- ============================================

local function LoadMyVoice()
    -- Try loading from file first
    local data = file.Read("glitchlab/my_voice.txt", "DATA")
    if data then
        local tbl = util.JSONToTable(data)
        if tbl then
            myVoice = tbl
            
            -- Sync to ConVars (file is source of truth)
            RunConsoleCommand("uc_voice", myVoice.voiceId)
            RunConsoleCommand("uc_voice_pitch", tostring(myVoice.pitchOffset))
            RunConsoleCommand("uc_voice_volume", tostring(myVoice.volumeOffset))
            
            return
        end
    end
    
    -- No file? Load from ConVars
    LoadFromConVars()
end

local function LoadFromConVars()
    -- Read from settings system
    myVoice.voiceId = GetConVar("uc_voice"):GetString()
    myVoice.pitchOffset = GetConVar("uc_voice_pitch"):GetInt()
    myVoice.volumeOffset = GetConVar("uc_voice_volume"):GetInt()
    
    -- Validate voice exists
    if not GlitchLab.Voices.List[myVoice.voiceId] then
        myVoice.voiceId = "default"
    end
end

local function SaveMyVoice(voiceData)
    if voiceData then
        myVoice = voiceData
    end
    
    -- Save to file
    if not file.IsDir("glitchlab", "DATA") then
        file.CreateDir("glitchlab")
    end
    file.Write("glitchlab/my_voice.txt", util.TableToJSON(myVoice, true))
    
    -- Sync to ConVars (file is always master)
    RunConsoleCommand("uc_voice", myVoice.voiceId)
    RunConsoleCommand("uc_voice_pitch", tostring(myVoice.pitchOffset))
    RunConsoleCommand("uc_voice_volume", tostring(myVoice.volumeOffset))
    
    MsgC(Color(177, 102, 199), "[GlitchLab] ")
    MsgC(Color(255, 255, 255), "Voice saved: " .. myVoice.voiceId .. "\n")
end

-- Make globally accessible
GlitchLab.SaveMyVoice = SaveMyVoice
GlitchLab.LoadMyVoiceFromConVars = LoadFromConVars

-- ============================================
-- CONVAR CHANGE HOOK
-- When settings menu changes ConVars, update our state
-- ============================================

cvars.AddChangeCallback("uc_voice", function(cvarName, oldValue, newValue)
    if myVoice.voiceId ~= newValue then
        myVoice.voiceId = newValue
        SaveMyVoice()
        GlitchLab.SendMyVoice()
    end
end, "GlitchLab_VoiceSync")

cvars.AddChangeCallback("uc_voice_pitch", function(cvarName, oldValue, newValue)
    local newPitch = tonumber(newValue) or 0
    if myVoice.pitchOffset ~= newPitch then
        myVoice.pitchOffset = newPitch
        SaveMyVoice()
        GlitchLab.SendMyVoice()
    end
end, "GlitchLab_VoicePitchSync")

cvars.AddChangeCallback("uc_voice_volume", function(cvarName, oldValue, newValue)
    local newVol = tonumber(newValue) or 0
    if myVoice.volumeOffset ~= newVol then
        myVoice.volumeOffset = newVol
        SaveMyVoice()
        GlitchLab.SendMyVoice()
    end
end, "GlitchLab_VoiceVolSync")

-- ============================================
-- NETWORK — Send/Receive voices
-- ============================================

function GlitchLab.SendMyVoice()
    if not myVoice.voiceId then return end
    
    net.Start("GlitchLab_VoiceUpdate")
        net.WriteString(myVoice.voiceId)
        net.WriteInt(myVoice.pitchOffset, 8)
        net.WriteFloat(myVoice.volumeOffset / 100)  -- Convert % to 0-1
    net.SendToServer()
    
    MsgC(Color(100, 200, 100), "[GlitchLab] Voice synced to server\n")
end

function GlitchLab.RequestAllVoices()
    net.Start("GlitchLab_VoiceRequest")
    net.SendToServer()
end

-- Receive voice update for a player
net.Receive("GlitchLab_VoiceSync", function()
    local entIndex = net.ReadUInt(16)
    local voiceId = net.ReadString()
    local pitchOffset = net.ReadInt(8)
    local volumeOffset = net.ReadFloat()
    
    GlitchLab.ClientVoices[entIndex] = {
        voiceId = voiceId,
        pitchOffset = pitchOffset,
        volumeOffset = volumeOffset,
    }
    
    local ent = Entity(entIndex)
    local name = IsValid(ent) and ent:IsPlayer() and ent:Nick() or "Unknown"
    
    if GlitchLab.Settings.DebugMode() then
        MsgC(Color(177, 102, 199), "[GlitchLab] ")
        MsgC(Color(200, 200, 200), "Voice sync: " .. name .. " -> " .. voiceId .. "\n")
    end
end)

-- ============================================
-- GET PLAYER VOICE
-- ============================================

function GlitchLab.GetPlayerVoiceClient(ply)
    if not IsValid(ply) then
        return GlitchLab.Voices.Get("default"), 0, 0
    end
    
    local entIndex = ply:EntIndex()
    local voiceData = GlitchLab.ClientVoices[entIndex]
    
    if not voiceData then
        return GlitchLab.Voices.Get("default"), 0, 0
    end
    
    local voice = GlitchLab.Voices.Get(voiceData.voiceId)
    return voice, voiceData.pitchOffset or 0, voiceData.volumeOffset or 0
end

function GlitchLab.GetMyVoice()
    return myVoice
end

-- ============================================
-- VOICE PREVIEW
-- ============================================

local lastPreviewTime = 0

function GlitchLab.PreviewVoice(voiceId, pitchOffset, volumeOffset)
    if CurTime() - lastPreviewTime < 0.1 then return end
    lastPreviewTime = CurTime()
    
    local voice = GlitchLab.Voices.Get(voiceId)
    if not voice or not voice.sound then return end
    
    pitchOffset = pitchOffset or 0
    volumeOffset = volumeOffset or 0
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local pitch = math.random(voice.pitchMin, voice.pitchMax) + pitchOffset
    local vol = math.Clamp(voice.volume + (volumeOffset / 100), 0.05, 1.0)
    
    ply:EmitSound(voice.sound, 60, pitch, vol, CHAN_STATIC)
end

function GlitchLab.PreviewVoicePhrase(voiceId, pitchOffset, volumeOffset, text)
    local voice = GlitchLab.Voices.Get(voiceId)
    if not voice or not voice.sound then return end
    
    text = text or "Hello World!"
    pitchOffset = pitchOffset or 0
    volumeOffset = volumeOffset or 0
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local chars = {}
    for i = 1, #text do
        local c = string.sub(text, i, i)
        if c ~= " " then
            table.insert(chars, c)
        end
    end
    
    local delay = 0
    local baseDelay = 0.05 / (voice.speedMult or 1.0)
    
    for i, char in ipairs(chars) do
        timer.Simple(delay, function()
            if not IsValid(ply) then return end
            
            local pitch = math.random(voice.pitchMin, voice.pitchMax) + pitchOffset
            
            -- Glitchy voices have random pitch per char
            if voice.randomPitchPerChar then
                pitch = math.random(30, 170)
            end
            
            local vol = math.Clamp(voice.volume + (volumeOffset / 100), 0.05, 1.0)
            ply:EmitSound(voice.sound, 50, pitch, vol, CHAN_STATIC)
        end)
        
        delay = delay + baseDelay
    end
end

-- ============================================
-- VOICE SELECTION MENU
-- ============================================

function GlitchLab.OpenVoiceMenu()
    if voiceMenuOpen then return end
    voiceMenuOpen = true
    
    local scrW, scrH = ScrW(), ScrH()
    local w, h = 600, 500
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(w, h)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    
    frame.OnClose = function()
        voiceMenuOpen = false
    end
    
    frame.Paint = function(self, pw, ph)
        -- Background
        draw.RoundedBox(0, 0, 0, pw, ph, Color(15, 15, 20, 250))
        
        -- Border
        surface.SetDrawColor(177, 102, 199, 255)
        surface.DrawOutlinedRect(0, 0, pw, ph, 2)
        
        -- Title bar
        draw.RoundedBox(0, 2, 2, pw - 4, 30, Color(177, 102, 199, 100))
        
        -- Title
        surface.SetFont("GlitchLab_Chat")
        surface.SetTextColor(255, 255, 255)
        surface.SetTextPos(10, 8)
        surface.DrawText("* SELECT YOUR VOICE")
    end
    
    -- Close button
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(w - 32, 5)
    closeBtn:SetSize(24, 24)
    closeBtn:SetText("X")
    closeBtn:SetTextColor(Color(255, 255, 255))
    closeBtn.Paint = function(self, pw, ph)
        local col = self:IsHovered() and Color(255, 100, 100) or Color(100, 100, 100)
        draw.RoundedBox(0, 0, 0, pw, ph, col)
    end
    closeBtn.DoClick = function()
        frame:Close()
    end
    
    -- ========== LEFT PANEL: Voice List ==========
    
    local listPanel = vgui.Create("DScrollPanel", frame)
    listPanel:SetPos(10, 40)
    listPanel:SetSize(250, h - 100)
    
    local sbar = listPanel:GetVBar()
    sbar:SetWide(6)
    sbar.Paint = function() end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function(s, pw, ph)
        draw.RoundedBox(3, 0, 0, pw, ph, Color(177, 102, 199))
    end
    
    local selectedVoiceId = myVoice.voiceId
    local voiceButtons = {}
    
    local function UpdateSelection(newId)
        selectedVoiceId = newId
        for id, btn in pairs(voiceButtons) do
            btn.Selected = (id == newId)
        end
    end
    
    -- Group by category
    for _, category in ipairs(GlitchLab.Voices.Categories) do
        -- Category header
        local header = vgui.Create("DPanel", listPanel)
        header:Dock(TOP)
        header:DockMargin(0, 5, 0, 2)
        header:SetTall(20)
        header.Paint = function(self, pw, ph)
            surface.SetFont("GlitchLab_ChatSmall")
            surface.SetTextColor(177, 102, 199)
            surface.SetTextPos(5, 2)
            surface.DrawText("— " .. category .. " —")
        end
        
        -- Voices in category
        for id, voice in pairs(GlitchLab.Voices.List) do
            if voice.category == category then
                local btn = vgui.Create("DButton", listPanel)
                btn:Dock(TOP)
                btn:DockMargin(0, 1, 0, 0)
                btn:SetTall(28)
                btn:SetText("")
                btn.VoiceId = id
                btn.Selected = (id == selectedVoiceId)
                
                btn.Paint = function(self, pw, ph)
                    local bgCol = Color(30, 30, 35)
                    if self.Selected then
                        bgCol = Color(177, 102, 199, 100)
                    elseif self:IsHovered() then
                        bgCol = Color(60, 60, 70)
                    end
                    
                    draw.RoundedBox(0, 0, 0, pw, ph, bgCol)
                    
                    surface.SetFont("GlitchLab_Chat")
                    surface.SetTextColor(255, 255, 255)
                    surface.SetTextPos(10, 6)
                    surface.DrawText(voice.name)
                end
                
                btn.DoClick = function()
                    UpdateSelection(id)
                    GlitchLab.PreviewVoice(id, myVoice.pitchOffset, myVoice.volumeOffset)
                end
                
                btn.DoDoubleClick = function()
                    UpdateSelection(id)
                    GlitchLab.PreviewVoicePhrase(id, myVoice.pitchOffset, myVoice.volumeOffset)
                end
                
                voiceButtons[id] = btn
            end
        end
    end
    
    -- ========== RIGHT PANEL: Settings & Preview ==========
    
    local rightPanel = vgui.Create("DPanel", frame)
    rightPanel:SetPos(270, 40)
    rightPanel:SetSize(320, h - 100)
    rightPanel.Paint = function(self, pw, ph)
        draw.RoundedBox(0, 0, 0, pw, ph, Color(25, 25, 30))
        surface.SetDrawColor(80, 80, 90)
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)
    end
    
    -- Voice description
    local descLabel = vgui.Create("DLabel", rightPanel)
    descLabel:SetPos(10, 10)
    descLabel:SetSize(300, 40)
    descLabel:SetWrap(true)
    descLabel:SetFont("GlitchLab_ChatSmall")
    descLabel:SetTextColor(Color(200, 200, 200))
    
    local function UpdateDescription()
        local voice = GlitchLab.Voices.Get(selectedVoiceId)
        descLabel:SetText(voice.description or "No description")
    end
    UpdateDescription()
    
    -- Pitch slider
    local pitchLabel = vgui.Create("DLabel", rightPanel)
    pitchLabel:SetPos(10, 60)
    pitchLabel:SetText("Pitch Offset:")
    pitchLabel:SetFont("GlitchLab_Chat")
    pitchLabel:SetTextColor(Color(255, 255, 255))
    pitchLabel:SizeToContents()
    
    local pitchSlider = vgui.Create("DNumSlider", rightPanel)
    pitchSlider:SetPos(10, 80)
    pitchSlider:SetSize(300, 30)
    pitchSlider:SetText("")
    pitchSlider:SetMin(-50)
    pitchSlider:SetMax(50)
    pitchSlider:SetDecimals(0)
    pitchSlider:SetValue(myVoice.pitchOffset)
    pitchSlider.OnValueChanged = function(self, val)
        myVoice.pitchOffset = math.floor(val)
    end
    
    -- Volume slider
    local volLabel = vgui.Create("DLabel", rightPanel)
    volLabel:SetPos(10, 120)
    volLabel:SetText("Volume Offset:")
    volLabel:SetFont("GlitchLab_Chat")
    volLabel:SetTextColor(Color(255, 255, 255))
    volLabel:SizeToContents()
    
    local volSlider = vgui.Create("DNumSlider", rightPanel)
    volSlider:SetPos(10, 140)
    volSlider:SetSize(300, 30)
    volSlider:SetText("")
    volSlider:SetMin(-30)
    volSlider:SetMax(30)
    volSlider:SetDecimals(0)
    volSlider:SetValue(myVoice.volumeOffset)
    volSlider.OnValueChanged = function(self, val)
        myVoice.volumeOffset = math.floor(val)
    end
    
    -- Preview button
    local previewBtn = vgui.Create("DButton", rightPanel)
    previewBtn:SetPos(10, 190)
    previewBtn:SetSize(145, 35)
    previewBtn:SetText("")
    previewBtn.Paint = function(self, pw, ph)
        local col = self:IsHovered() and Color(100, 200, 100) or Color(60, 150, 60)
        draw.RoundedBox(4, 0, 0, pw, ph, col)
        
        surface.SetFont("GlitchLab_Chat")
        surface.SetTextColor(255, 255, 255)
        local tw = surface.GetTextSize("[>] PREVIEW")
        surface.SetTextPos(pw/2 - tw/2, 10)
        surface.DrawText("[>] PREVIEW")
    end
    previewBtn.DoClick = function()
        UpdateDescription()
        GlitchLab.PreviewVoicePhrase(selectedVoiceId, myVoice.pitchOffset, myVoice.volumeOffset)
    end
    
    -- Test phrase button
    local testBtn = vgui.Create("DButton", rightPanel)
    testBtn:SetPos(165, 190)
    testBtn:SetSize(145, 35)
    testBtn:SetText("")
    testBtn.Paint = function(self, pw, ph)
        local col = self:IsHovered() and Color(100, 150, 200) or Color(60, 100, 150)
        draw.RoundedBox(4, 0, 0, pw, ph, col)
        
        surface.SetFont("GlitchLab_Chat")
        surface.SetTextColor(255, 255, 255)
        local tw = surface.GetTextSize("TEST MSG")
        surface.SetTextPos(pw/2 - tw/2, 10)
        surface.DrawText("TEST MSG")
    end
    testBtn.DoClick = function()
        GlitchLab.PreviewVoicePhrase(selectedVoiceId, myVoice.pitchOffset, myVoice.volumeOffset, 
            "Hello! This is my new voice!")
    end
    
    -- Current voice display
    local currentLabel = vgui.Create("DLabel", rightPanel)
    currentLabel:SetPos(10, 250)
    currentLabel:SetFont("GlitchLab_Chat")
    currentLabel:SetTextColor(Color(177, 102, 199))
    
    local function UpdateCurrentLabel()
        local voice = GlitchLab.Voices.Get(myVoice.voiceId)
        currentLabel:SetText("Current: " .. voice.name)
        currentLabel:SizeToContents()
    end
    UpdateCurrentLabel()
    
    -- ========== BOTTOM: Save/Cancel ==========
    
    local saveBtn = vgui.Create("DButton", frame)
    saveBtn:SetPos(w - 220, h - 50)
    saveBtn:SetSize(100, 35)
    saveBtn:SetText("")
    saveBtn.Paint = function(self, pw, ph)
        local col = self:IsHovered() and Color(100, 255, 100) or Color(60, 200, 60)
        draw.RoundedBox(4, 0, 0, pw, ph, col)
        
        surface.SetFont("GlitchLab_Chat")
        surface.SetTextColor(0, 0, 0)
        local tw = surface.GetTextSize("SAVE")
        surface.SetTextPos(pw/2 - tw/2, 10)
        surface.DrawText("SAVE")
    end
    saveBtn.DoClick = function()
        -- Update myVoice with current selections
        myVoice.voiceId = selectedVoiceId
        
        -- Save to file AND convars
        SaveMyVoice()
        
        -- Send to server
        GlitchLab.SendMyVoice()
        
        surface.PlaySound("buttons/button9.wav")
        
        chat.AddText(Color(177, 102, 199), "[UnderComms] ", Color(255, 255, 255), 
            "Voice set to: " .. GlitchLab.Voices.Get(selectedVoiceId).name)
        
        frame:Close()
    end
    
    local cancelBtn = vgui.Create("DButton", frame)
    cancelBtn:SetPos(w - 110, h - 50)
    cancelBtn:SetSize(100, 35)
    cancelBtn:SetText("")
    cancelBtn.Paint = function(self, pw, ph)
        local col = self:IsHovered() and Color(255, 100, 100) or Color(200, 60, 60)
        draw.RoundedBox(4, 0, 0, pw, ph, col)
        
        surface.SetFont("GlitchLab_Chat")
        surface.SetTextColor(255, 255, 255)
        local tw = surface.GetTextSize("CANCEL")
        surface.SetTextPos(pw/2 - tw/2, 10)
        surface.DrawText("CANCEL")
    end
    cancelBtn.DoClick = function()
        frame:Close()
    end
    
    -- Update description when selection changes
    listPanel.Think = function()
        UpdateDescription()
    end
end

-- ============================================
-- CONSOLE COMMANDS
-- ============================================

concommand.Add("uc_voice", function(ply, cmd, args)
    GlitchLab.OpenVoiceMenu()
end, nil, "Open voice selection menu")

concommand.Add("uc_voice_set", function(ply, cmd, args)
    local voiceId = args[1]
    if not voiceId then
        print("Usage: uc_voice_set <voice_id>")
        print("Available voices:")
        for id, voice in pairs(GlitchLab.Voices.List) do
            print("  " .. id .. " — " .. voice.name)
        end
        return
    end
    
    if not GlitchLab.Voices.List[voiceId] then
        print("Unknown voice: " .. voiceId)
        return
    end
    
    myVoice.voiceId = voiceId
    SaveMyVoice()
    GlitchLab.SendMyVoice()
    
    print("[UnderComms] Voice set to: " .. GlitchLab.Voices.Get(voiceId).name)
end, nil, "Set your voice directly")

concommand.Add("uc_voice_list", function()
    print("\n=== Available Voices ===")
    for _, category in ipairs(GlitchLab.Voices.Categories) do
        print("\n[" .. category .. "]")
        for id, voice in pairs(GlitchLab.Voices.List) do
            if voice.category == category then
                print("  " .. id .. " — " .. voice.name .. ": " .. voice.description)
            end
        end
    end
    print("\n========================")
end, nil, "List all available voices")

concommand.Add("uc_voice_preview", function(ply, cmd, args)
    local voiceId = args[1] or myVoice.voiceId
    GlitchLab.PreviewVoicePhrase(voiceId, myVoice.pitchOffset, myVoice.volumeOffset)
end, nil, "Preview a voice")

-- ============================================
-- INITIALIZATION
-- ============================================

hook.Add("InitPostEntity", "GlitchLab_VoiceInit", function()
    LoadMyVoice()
    
    timer.Simple(3, function()
        GlitchLab.SendMyVoice()
        GlitchLab.RequestAllVoices()
    end)
    
    MsgC(Color(177, 102, 199), "[GlitchLab] ")
    MsgC(Color(255, 255, 255), "Voice client system initialized\n")
    MsgC(Color(100, 100, 100), "[GlitchLab] Type uc_voice to select your voice!\n")
end)