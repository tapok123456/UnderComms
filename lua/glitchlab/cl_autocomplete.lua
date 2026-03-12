--[[
    GlitchLab | UnderComms — Tab Autocomplete
    
    v0.5.1 — FIXED EDITION
    
    Press Tab to complete player names
    "Tab Tab Tab Tab Tab Tab Ta- FUCK WRONG PERSON"
    
    Now doesn't crash on second Tab like a little bitch
]]

GlitchLab.Autocomplete = GlitchLab.Autocomplete or {}

local ac = GlitchLab.Autocomplete

-- ============================================
-- STATE
-- ============================================

ac.Candidates = {}      -- list of matching player names
ac.CurrentIndex = 0     -- which candidate we're on (cycles)
ac.LastWord = ""        -- the partial word we started with
ac.WordStart = 0        -- position where that word starts
ac.LastCompletion = ""  -- what we inserted last time (for cycling detection)

-- ============================================
-- GET WORD AT CURSOR POSITION
-- ============================================

local function GetWordAtCursor(text, cursorPos)
    if not text or text == "" then return "", 1, 0 end
    
    cursorPos = cursorPos or #text
    
    -- find where current word starts (go backwards until space)
    local wordStart = cursorPos
    while wordStart > 1 do
        local char = string.sub(text, wordStart - 1, wordStart - 1)
        if char == " " then break end
        wordStart = wordStart - 1
    end
    
    -- extract the word
    local word = string.sub(text, wordStart, cursorPos)
    
    return word, wordStart, cursorPos
end

-- ============================================
-- FIND MATCHING PLAYERS
-- ============================================

local function FindMatches(partial)
    local matches = {}
    local lowerPartial = string.lower(partial or "")
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local nick = ply:Nick()
            
            -- if no partial, add everyone
            -- otherwise, check if nick starts with partial
            if partial == "" or string.StartWith(string.lower(nick), lowerPartial) then
                table.insert(matches, nick)
            end
        end
    end
    
    -- sort alphabetically so cycling is consistent
    table.sort(matches, function(a, b)
        return string.lower(a) < string.lower(b)
    end)
    
    return matches
end

-- ============================================
-- CHECK IF WE'RE CYCLING THROUGH COMPLETIONS
-- ============================================

local function IsCycling(word, wordStart)
    -- We're cycling if:
    -- 1. We have candidates from previous Tab
    -- 2. Current word matches one of our previous completions
    -- 3. WordStart is the same position
    
    if #ac.Candidates == 0 then return false end
    if wordStart ~= ac.WordStart then return false end
    
    -- Check if current word is one of our completions (user pressed Tab before)
    local trimmedWord = string.Trim(word)
    for _, candidate in ipairs(ac.Candidates) do
        if trimmedWord == candidate or trimmedWord == candidate .. " " then
            return true
        end
    end
    
    -- Also check if it matches the original partial
    if word == ac.LastWord then
        return true
    end
    
    return false
end

-- ============================================
-- COMPLETE — main function
-- Returns: newText, newCursorPos
-- ============================================

function ac.Complete(currentText, cursorPos)
    if not currentText then currentText = "" end
    cursorPos = cursorPos or #currentText
    
    -- get the word we're trying to complete
    local word, wordStart, wordEnd = GetWordAtCursor(currentText, cursorPos)
    
    -- check if we're cycling through existing completions
    local isCycling = IsCycling(word, wordStart)
    
    if not isCycling then
        -- new word: reset and find matches
        ac.LastWord = word
        ac.WordStart = wordStart
        ac.CurrentIndex = 0
        ac.Candidates = FindMatches(word)
        
        if #ac.Candidates == 0 then
            -- no matches, play sad sound and bail
            surface.PlaySound("buttons/button10.wav")
            return currentText, cursorPos
        end
    end
    
    -- Safety check: make sure we have candidates
    if #ac.Candidates == 0 then
        surface.PlaySound("buttons/button10.wav")
        return currentText, cursorPos
    end
    
    -- cycle to next candidate
    ac.CurrentIndex = ac.CurrentIndex + 1
    if ac.CurrentIndex > #ac.Candidates then
        ac.CurrentIndex = 1
    end
    
    local completion = ac.Candidates[ac.CurrentIndex]
    
    -- Safety check: completion must exist
    if not completion or completion == "" then
        surface.PlaySound("buttons/button10.wav")
        return currentText, cursorPos
    end
    
    -- build new text: before + completion + after
    local before = string.sub(currentText, 1, ac.WordStart - 1)
    local after = string.sub(currentText, wordEnd + 1)
    
    -- Trim any trailing space from 'after' that we might have added
    after = string.gsub(after, "^%s+", "")
    
    -- add space after name
    local completionWithSpace = completion .. " "
    
    local newText = before .. completionWithSpace .. after
    local newCursor = #before + #completionWithSpace
    
    -- Store what we completed for cycle detection
    ac.LastCompletion = completion
    
    -- sound feedback
    surface.PlaySound("buttons/button15.wav")
    
    return newText, newCursor
end

-- ============================================
-- RESET — when text changes manually
-- ============================================

function ac.Reset()
    ac.Candidates = {}
    ac.CurrentIndex = 0
    ac.LastWord = ""
    ac.WordStart = 0
    ac.LastCompletion = ""
end

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), "Tab autocomplete loaded (v0.5.1 fixed)\n")