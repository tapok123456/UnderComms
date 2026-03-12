--[[
    GlitchLab | UnderComms — Input History
    
    v0.5.0 — QUALITY OF LIFE
    
    Arrow keys go brrrr through your message history
    "↑↑↓↓←→←→BA START" — wrong game but same energy
]]

GlitchLab.InputHistory = GlitchLab.InputHistory or {}

local history = GlitchLab.InputHistory

-- ============================================
-- CONFIG — how many messages we remember
-- ============================================

local MAX_HISTORY = 50
local HISTORY_FILE = "glitchlab/input_history.txt"

-- ============================================
-- STATE
-- ============================================

history.Messages = {}      -- {"newest msg", "older msg", ...}
history.CurrentIndex = 0   -- 0 = not browsing, 1+ = which message
history.TempDraft = ""     -- saves what you were typing before pressing ↑

-- ============================================
-- SAVE TO DISK — persistent across sessions
-- ============================================

function history.Save()
    if not file.IsDir("glitchlab", "DATA") then
        file.CreateDir("glitchlab")
    end
    
    local data = util.TableToJSON(history.Messages)
    file.Write(HISTORY_FILE, data)
end

-- ============================================
-- LOAD FROM DISK
-- ============================================

function history.Load()
    if not file.Exists(HISTORY_FILE, "DATA") then
        history.Messages = {}
        return
    end
    
    local data = file.Read(HISTORY_FILE, "DATA")
    if not data or data == "" then
        history.Messages = {}
        return
    end
    
    local decoded = util.JSONToTable(data)
    history.Messages = decoded or {}
    
    MsgC(Color(177, 102, 199), "[GlitchLab] ")
    MsgC(Color(255, 255, 255), string.format("Loaded %d history entries\n", #history.Messages))
end

-- ============================================
-- ADD MESSAGE — called when you send a message
-- ============================================

function history.Add(text)
    if not text or text == "" then return end
    text = string.Trim(text)
    if text == "" then return end
    
    -- dont add duplicates of the last message (spam protection)
    if history.Messages[1] == text then return end
    
    -- insert at beginning (most recent first)
    table.insert(history.Messages, 1, text)
    
    -- trim to max size
    while #history.Messages > MAX_HISTORY do
        table.remove(history.Messages)
    end
    
    -- reset browsing state
    history.CurrentIndex = 0
    history.TempDraft = ""
    
    -- save to disk
    history.Save()
end

-- ============================================
-- NAVIGATE UP — older messages
-- ============================================

function history.Up()
    if #history.Messages == 0 then return nil end
    
    -- first time pressing up? save current draft
    if history.CurrentIndex == 0 then
        local chatbox = GlitchLab.Chatbox
        if chatbox and IsValid(chatbox.InputPanel) then
            history.TempDraft = chatbox.InputPanel:GetText() or ""
        end
    end
    
    -- move up (older)
    history.CurrentIndex = math.min(history.CurrentIndex + 1, #history.Messages)
    
    return history.Messages[history.CurrentIndex]
end

-- ============================================
-- NAVIGATE DOWN — newer messages
-- ============================================

function history.Down()
    if history.CurrentIndex == 0 then return nil end
    
    -- move down (newer)
    history.CurrentIndex = history.CurrentIndex - 1
    
    if history.CurrentIndex == 0 then
        -- back to current draft
        return history.TempDraft
    else
        return history.Messages[history.CurrentIndex]
    end
end

-- ============================================
-- RESET — called when chat closes
-- ============================================

function history.Reset()
    history.CurrentIndex = 0
    history.TempDraft = ""
end

-- ============================================
-- CLEAR — console command
-- ============================================

function history.Clear()
    history.Messages = {}
    history.CurrentIndex = 0
    history.TempDraft = ""
    history.Save()
    
    MsgC(Color(177, 102, 199), "[GlitchLab] ")
    MsgC(Color(255, 255, 255), "History cleared, you paranoid fuck\n")
end

-- ============================================
-- CONSOLE COMMANDS
-- ============================================

concommand.Add("uc_history_clear", function()
    history.Clear()
end, nil, "Clear chat input history")

concommand.Add("uc_history_list", function()
    print("\n=== Input History (newest first) ===")
    for i, msg in ipairs(history.Messages) do
        local preview = #msg > 50 and string.sub(msg, 1, 47) .. "..." or msg
        print(string.format("  %d: %s", i, preview))
    end
    print(string.format("Total: %d entries\n", #history.Messages))
end, nil, "Show chat input history")

-- ============================================
-- INIT — load history on startup
-- ============================================

hook.Add("InitPostEntity", "GlitchLab_LoadInputHistory", function()
    timer.Simple(0.5, function()
        history.Load()
    end)
end)

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), "Input history system loaded\n")