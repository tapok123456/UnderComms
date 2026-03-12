--[[
    GlitchLab | UnderComms — Input Handler
    
    v0.1.1 — Removed redundant input blocking
    The chatbox handles its own focus now like a big boy
]]

GlitchLab.Input = GlitchLab.Input or {}

local cfg = GlitchLab.Config
local chatbox = GlitchLab.Chatbox

local function dbg(...)
    if cfg.DebugMode then
        MsgC(Color(177, 102, 199), "[GlitchLab:Input] ")
        MsgC(Color(255, 255, 255), string.format(...) .. "\n")
    end
end

-- ============================================
-- CONSOLE COMMANDS
-- ============================================

concommand.Add("uc_open", function()
    if chatbox.Open then chatbox.Open(false) end
end, nil, "Open UnderComms chat")

concommand.Add("uc_open_team", function()
    if chatbox.Open then chatbox.Open(true) end
end, nil, "Open UnderComms team chat")

concommand.Add("uc_close", function()
    if chatbox.Close then chatbox.Close() end
end, nil, "Close UnderComms chat")

concommand.Add("uc_rebuild", function()
    if chatbox.Build then 
        chatbox.Build() 
        dbg("Chatbox rebuilt manually")
    end
end, nil, "Rebuild chatbox UI")

-- ============================================
-- DEBUG COMMANDS
-- ============================================

if cfg.DebugMode then
    concommand.Add("uc_test", function(ply, cmd, args)
        local text = table.concat(args, " ")
        if text == "" then text = "Test message #" .. math.random(1, 999) end
        
        local msg = chatbox.AddMessage(
            LocalPlayer():Nick(),
            cfg.Colors.PlayerName,
            text,
            cfg.Colors.Text,
            false
        )
        
        if IsValid(chatbox.MessagePanel) then
            chatbox.CreateMessagePanel(msg, #chatbox.Messages)
        end
    end, nil, "Add test message")
    
    concommand.Add("uc_test_sys", function(ply, cmd, args)
        local text = table.concat(args, " ")
        if text == "" then text = "* But nobody came." end
        
        local msg = chatbox.AddMessage(nil, nil, text, cfg.Colors.ServerMsg, true)
        
        if IsValid(chatbox.MessagePanel) then
            chatbox.CreateMessagePanel(msg, #chatbox.Messages)
        end
    end, nil, "Add test system message")
    
    concommand.Add("uc_status", function()
        print("=== UnderComms Status ===")
        print("IsOpen:", chatbox.IsOpen)
        print("IsTeamChat:", chatbox.IsTeamChat)
        print("Messages:", #chatbox.Messages)
        print("Frame valid:", IsValid(chatbox.Frame))
        print("Input valid:", IsValid(chatbox.InputPanel))
        print("MessagePanel valid:", IsValid(chatbox.MessagePanel))
    end, nil, "Print chatbox status")
end

-- ============================================
-- REMOVED: StartCommand hook
-- DFrame with MakePopup() handles input blocking automatically
-- We don't need to manually zero out movement anymore
-- That was the bug — we blocked movement but the input field
-- wasn't receiving keyboard focus properly
-- ============================================

dbg("cl_input.lua loaded. Input handler standing by.")