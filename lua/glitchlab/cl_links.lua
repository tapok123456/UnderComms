--[[
    GlitchLab | UnderComms — Clickable Links
    
    v0.8.0 — SECURITY EDITION
    
    Now with domain whitelist because apparently
    people click on totallynotavirus.ru links
    
    "I'm not suspicious, you're suspicious"
]]

GlitchLab.LinkParser = GlitchLab.LinkParser or {}

local parser = GlitchLab.LinkParser

-- ============================================
-- URL PATTERNS
-- ============================================

local URL_PATTERNS = {
    "(https?://[%w%-_%.%?%.:/%+=&%%#@!]+)",  -- http/https
    "(steam://[%w%-_%.%?%.:/%+=&%%]+)",       -- steam links
}

-- ============================================
-- DOMAIN EXTRACTION
-- ============================================

local function ExtractDomain(url)
    if not url then return nil end
    
    -- Remove protocol
    local domain = string.match(url, "https?://([^/]+)")
    if not domain then
        domain = string.match(url, "steam://([^/]+)")
    end
    
    if not domain then return nil end
    
    -- Remove port if present
    domain = string.gsub(domain, ":%d+$", "")
    
    -- Remove www prefix for matching
    domain = string.gsub(domain, "^www%.", "")
    
    return string.lower(domain)
end

-- ============================================
-- WHITELIST CHECK
-- ============================================

local function IsDomainAllowed(url)
    local cfg = GlitchLab.Config
    
    -- If whitelist disabled, allow everything (not recommended)
    if cfg.EnforceWhitelist == false then
        return true
    end
    
    local allowedDomains = cfg.AllowedDomains
    if not allowedDomains or #allowedDomains == 0 then
        return true  -- no whitelist configured, allow all
    end
    
    local domain = ExtractDomain(url)
    if not domain then return false end
    
    for _, allowed in ipairs(allowedDomains) do
        local allowedLower = string.lower(allowed)
        
        -- Exact match
        if domain == allowedLower then
            return true
        end
        
        -- Subdomain match (e.g. "cdn.discord.com" matches "discord.com")
        if string.EndsWith(domain, "." .. allowedLower) then
            return true
        end
    end
    
    return false
end

-- ============================================
-- PARSE TEXT FOR URLS
-- Returns: { {text="...", isLink=bool, url="..."}, ... }
-- ============================================

function parser.Parse(text)
    if not text or text == "" then
        return {{text = "", isLink = false}}
    end
    
    local parts = {}
    
    -- Find all URLs with their positions
    local urls = {}
    
    for _, pattern in ipairs(URL_PATTERNS) do
        local searchStart = 1
        while true do
            local matchStart, matchEnd, match = string.find(text, pattern, searchStart)
            if not matchStart then break end
            
            table.insert(urls, {
                startPos = matchStart,
                endPos = matchEnd,
                url = match
            })
            
            searchStart = matchEnd + 1
        end
    end
    
    -- Sort by position
    table.sort(urls, function(a, b) return a.startPos < b.startPos end)
    
    -- Remove overlapping URLs (keep first)
    local filtered = {}
    local lastUrlEnd = 0
    for _, u in ipairs(urls) do
        if u.startPos > lastUrlEnd then
            table.insert(filtered, u)
            lastUrlEnd = u.endPos
        end
    end
    urls = filtered
    
    -- Build parts array
    local currentPos = 1
    for _, urlData in ipairs(urls) do
        -- Text before URL
        if urlData.startPos > currentPos then
            local beforeText = string.sub(text, currentPos, urlData.startPos - 1)
            table.insert(parts, {
                text = beforeText,
                isLink = false
            })
        end
        
        -- Check if URL is allowed
        local isAllowed = IsDomainAllowed(urlData.url)
        
        -- The URL itself
        table.insert(parts, {
            text = urlData.url,
            isLink = isAllowed,  -- only clickable if allowed
            url = urlData.url,
            blocked = not isAllowed,
        })
        
        currentPos = urlData.endPos + 1
    end
    
    -- Remaining text after last URL
    if currentPos <= #text then
        table.insert(parts, {
            text = string.sub(text, currentPos),
            isLink = false
        })
    end
    
    -- If no parts, return original text
    if #parts == 0 then
        return {{text = text, isLink = false}}
    end
    
    return parts
end

-- ============================================
-- OPEN URL (with confirmation for unknown domains)
-- ============================================

function parser.OpenURL(url)
    if not url or url == "" then return end
    
    -- Final safety check
    if not IsDomainAllowed(url) then
        MsgC(Color(255, 100, 100), "[GlitchLab] ")
        MsgC(Color(255, 255, 255), "Blocked URL (not in whitelist): " .. url .. "\n")
        
        -- Show notification to user
        if GlitchLab.Event then
            GlitchLab.Event("BLOCKED", "URL not in whitelist", {type = "warning", duration = 2})
        end
        
        return
    end
    
    gui.OpenURL(url)
    
    surface.PlaySound("buttons/button14.wav")
    
    MsgC(Color(177, 102, 199), "[GlitchLab] ")
    MsgC(Color(100, 150, 255), "Opening: " .. url .. "\n")
end

-- ============================================
-- CONSOLE COMMANDS
-- ============================================

concommand.Add("uc_link_test", function(ply, cmd, args)
    local url = args[1] or "https://example.com"
    local allowed = IsDomainAllowed(url)
    local domain = ExtractDomain(url)
    
    print("\n=== Link Test ===")
    print("URL:", url)
    print("Domain:", domain or "N/A")
    print("Allowed:", allowed and "YES" or "NO")
    print("=================\n")
end, nil, "Test if a URL is allowed")

concommand.Add("uc_link_list", function()
    local cfg = GlitchLab.Config
    
    print("\n=== Allowed Domains ===")
    print("Whitelist enforced:", cfg.EnforceWhitelist and "YES" or "NO")
    print("")
    
    if cfg.AllowedDomains then
        for i, domain in ipairs(cfg.AllowedDomains) do
            print("  " .. i .. ". " .. domain)
        end
    else
        print("  (none configured)")
    end
    
    print("=======================\n")
end, nil, "List allowed URL domains")

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), "Link parser loaded (with domain whitelist)\n")