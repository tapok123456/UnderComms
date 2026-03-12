--[[
    GlitchLab | UnderComms — Sprite System
    
    v0.7.0 — SPRITES EDITION (with real Steam avatars)
    
    Undertale-style avatars and icons because
    Steam avatars are too realistic for this shit
    (but we support them anyway)
    
    "* You equipped the Pixel Avatar. ATK +0 DEF +0 STYLE +999"
]]

GlitchLab.Sprites = GlitchLab.Sprites or {}

local sprites = GlitchLab.Sprites

-- ============================================
-- CONVARS (make sure they exist)
-- ============================================

if not ConVarExists("uc_avatar_mode") then
    CreateClientConVar("uc_avatar_mode", "1", true, false, "Avatar mode: 0=none, 1=steam, 2=sprite")
end

if not ConVarExists("uc_avatar_sprite") then
    CreateClientConVar("uc_avatar_sprite", "frisk", true, false, "Selected sprite ID")
end

if not ConVarExists("uc_show_style_icons") then
    CreateClientConVar("uc_show_style_icons", "1", true, false, "Show style icons in chat")
end

-- ============================================
-- SPRITE CONFIGURATION
-- ============================================

sprites.BasePath = "glitchlab/"

-- Avatar display modes
sprites.AvatarMode = {
    NONE = 0,       -- no avatar
    STEAM = 1,      -- steam avatar
    SPRITE = 2,     -- undertale/deltarune sprite
}

-- ============================================
-- STYLE ICONS (for /r, /t, etc.)
-- ============================================

sprites.StyleIcons = {
    radio = {
        icon = nil,
        material = "glitchlab/icons/radio.png",
        color = Color(80, 255, 80),
    },
    telegraph = {
        icon = nil,
        material = "glitchlab/icons/telegraph.png",
        color = Color(255, 220, 150),
    },
    letter = {
        icon = nil,
        material = "glitchlab/icons/letter.png",
        color = Color(180, 150, 100),
    },
    whisper = {
        icon = nil,
        material = "glitchlab/icons/whisper.png",
        color = Color(180, 180, 180),
    },
    yell = {
        icon = nil,
        material = "glitchlab/icons/yell.png",
        color = Color(255, 100, 100),
    },
    action = {
        icon = nil,
        material = "glitchlab/icons/action.png",
        color = Color(255, 180, 100),
    },
    ooc = {
        icon = nil,
        material = "glitchlab/icons/ooc.png",
        color = Color(150, 150, 150),
    },
    looc = {
        icon = nil,
        material = "glitchlab/icons/looc.png",
        color = Color(150, 150, 150),
    },
    direct = {
        icon = nil,
        material = "glitchlab/icons/direct.png",
        color = Color(255, 255, 255),
    },
}

-- ============================================
-- MENU ICONS (for settings tabs)
-- Simple geometric icons drawn with surface lib
-- No emojis here, we ain't casuals
-- ============================================

GlitchLab.Sprites.MenuIcons = {
    -- Draw functions for each tab icon
    
    voice = function(x, y, size, color)
        -- Musical note / sound wave
        surface.SetDrawColor(color)
        local s = size
        -- Sound waves
        surface.DrawRect(x + s*0.2, y + s*0.35, s*0.15, s*0.3)
        surface.DrawOutlinedRect(x + s*0.4, y + s*0.25, s*0.2, s*0.5, 2)
        surface.DrawOutlinedRect(x + s*0.65, y + s*0.15, s*0.2, s*0.7, 2)
    end,
    
    sound = function(x, y, size, color)
        -- Speaker icon
        surface.SetDrawColor(color)
        local s = size
        -- Speaker body
        surface.DrawRect(x + s*0.15, y + s*0.35, s*0.25, s*0.3)
        -- Speaker cone (triangle approximation)
        surface.DrawRect(x + s*0.4, y + s*0.25, s*0.05, s*0.5)
        surface.DrawRect(x + s*0.45, y + s*0.2, s*0.05, s*0.6)
        surface.DrawRect(x + s*0.5, y + s*0.15, s*0.05, s*0.7)
        -- Sound waves
        surface.DrawOutlinedRect(x + s*0.6, y + s*0.3, s*0.1, s*0.4, 1)
        surface.DrawOutlinedRect(x + s*0.75, y + s*0.2, s*0.1, s*0.6, 1)
    end,
    
    visual = function(x, y, size, color)
        -- Eye icon
        surface.SetDrawColor(color)
        local s = size
        local cx, cy = x + s*0.5, y + s*0.5
        -- Eye outline (diamond shape)
        draw.NoTexture()
        surface.DrawOutlinedRect(x + s*0.1, y + s*0.35, s*0.8, s*0.3, 2)
        -- Pupil
        surface.DrawRect(x + s*0.4, y + s*0.4, s*0.2, s*0.2)
    end,
    
    position = function(x, y, size, color)
        -- Crosshair / move icon
        surface.SetDrawColor(color)
        local s = size
        -- Cross
        surface.DrawRect(x + s*0.45, y + s*0.15, s*0.1, s*0.7)
        surface.DrawRect(x + s*0.15, y + s*0.45, s*0.7, s*0.1)
        -- Arrows
        surface.DrawRect(x + s*0.4, y + s*0.1, s*0.2, s*0.1)  -- top
        surface.DrawRect(x + s*0.4, y + s*0.8, s*0.2, s*0.1)  -- bottom
        surface.DrawRect(x + s*0.1, y + s*0.4, s*0.1, s*0.2)  -- left
        surface.DrawRect(x + s*0.8, y + s*0.4, s*0.1, s*0.2)  -- right
    end,
    
    theme = function(x, y, size, color)
        -- Paint brush / palette
        surface.SetDrawColor(color)
        local s = size
        -- Brush handle
        surface.DrawRect(x + s*0.6, y + s*0.1, s*0.15, s*0.5)
        -- Brush head
        surface.DrawRect(x + s*0.55, y + s*0.55, s*0.25, s*0.15)
        surface.DrawRect(x + s*0.5, y + s*0.7, s*0.35, s*0.15)
        -- Color dots
        surface.DrawRect(x + s*0.1, y + s*0.3, s*0.15, s*0.15)
        surface.DrawRect(x + s*0.3, y + s*0.2, s*0.15, s*0.15)
        surface.DrawRect(x + s*0.2, y + s*0.5, s*0.15, s*0.15)
    end,
    
    messages = function(x, y, size, color)
        -- Chat bubble
        surface.SetDrawColor(color)
        local s = size
        -- Main bubble
        surface.DrawOutlinedRect(x + s*0.1, y + s*0.15, s*0.7, s*0.5, 2)
        -- Tail
        surface.DrawRect(x + s*0.2, y + s*0.65, s*0.15, s*0.1)
        surface.DrawRect(x + s*0.15, y + s*0.75, s*0.1, s*0.1)
        -- Text lines
        surface.DrawRect(x + s*0.2, y + s*0.3, s*0.5, s*0.05)
        surface.DrawRect(x + s*0.2, y + s*0.45, s*0.35, s*0.05)
    end,
    
    input = function(x, y, size, color)
        -- Keyboard
        surface.SetDrawColor(color)
        local s = size
        -- Keyboard outline
        surface.DrawOutlinedRect(x + s*0.1, y + s*0.3, s*0.8, s*0.4, 2)
        -- Keys row 1
        for i = 0, 4 do
            surface.DrawRect(x + s*0.15 + i*s*0.13, y + s*0.38, s*0.08, s*0.08)
        end
        -- Keys row 2
        for i = 0, 3 do
            surface.DrawRect(x + s*0.2 + i*s*0.15, y + s*0.52, s*0.1, s*0.08)
        end
    end,
    
    advanced = function(x, y, size, color)
        -- Gear/cog icon
        surface.SetDrawColor(color)
        local s = size
        -- Center
        surface.DrawRect(x + s*0.35, y + s*0.35, s*0.3, s*0.3)
        -- Teeth
        surface.DrawRect(x + s*0.4, y + s*0.15, s*0.2, s*0.15)  -- top
        surface.DrawRect(x + s*0.4, y + s*0.7, s*0.2, s*0.15)   -- bottom
        surface.DrawRect(x + s*0.15, y + s*0.4, s*0.15, s*0.2)  -- left
        surface.DrawRect(x + s*0.7, y + s*0.4, s*0.15, s*0.2)   -- right
        -- Inner circle (hole)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(x + s*0.42, y + s*0.42, s*0.16, s*0.16)
    end,
}

function GlitchLab.Sprites.DrawMenuIcon(iconName, x, y, size, color)
    local drawFunc = GlitchLab.Sprites.MenuIcons[iconName]
    if drawFunc then
        drawFunc(x, y, size, color or Color(255, 255, 255))
        return true
    end
    return false
end

-- ============================================
-- CHARACTER SPRITES (Undertale/Deltarune)
-- ============================================

sprites.Characters = {
    -- Undertale
    {
        id = "frisk",
        name = "Frisk",
        game = "Undertale",
        material = "glitchlab/sprites/frisk.png",
    },
    {
        id = "chara",
        name = "Chara",
        game = "Undertale",
        material = "glitchlab/sprites/chara.png",
    },
    {
        id = "sans",
        name = "Sans",
        game = "Undertale",
        material = "glitchlab/sprites/sans.png",
    },
    {
        id = "papyrus",
        name = "Papyrus",
        game = "Undertale",
        material = "glitchlab/sprites/papyrus.png",
    },
    {
        id = "undyne",
        name = "Undyne",
        game = "Undertale",
        material = "glitchlab/sprites/undyne.png",
    },
    {
        id = "alphys",
        name = "Alphys",
        game = "Undertale",
        material = "glitchlab/sprites/alphys.png",
    },
    {
        id = "toriel",
        name = "Toriel",
        game = "Undertale",
        material = "glitchlab/sprites/toriel.png",
    },
    {
        id = "asgore",
        name = "Asgore",
        game = "Undertale",
        material = "glitchlab/sprites/asgore.png",
    },
    {
        id = "flowey",
        name = "Flowey",
        game = "Undertale",
        material = "glitchlab/sprites/flowey.png",
    },
    --Deltarune
    {
        id = "asriel",
        name = "Asriel",
        game = "Deltarune",
        material = "glitchlab/sprites/asriel.png",
    },
    -- NOT TODAY SORRY
    --{
    --    id = "mettaton",
    --    name = "Mettaton",
    --    game = "Undertale",
    --    material = "glitchlab/sprites/mettaton.png",
    --},
    --{
    --    id = "napstablook",
    --    name = "Napstablook",
    --    game = "Undertale",
    --    material = "glitchlab/sprites/napstablook.png",
    --},
    
    -- Deltarune
    --{
    --    id = "kris",
    --    name = "Kris",
    --    game = "Deltarune",
    --    material = "glitchlab/sprites/kris.png",
    --},
    --{
    --    id = "susie",
    --    name = "Susie",
    --    game = "Deltarune",
    --    material = "glitchlab/sprites/susie.png",
    --},
    --{
    --    id = "ralsei",
    --    name = "Ralsei",
    --    game = "Deltarune",
    --    material = "glitchlab/sprites/ralsei.png",
    --},
    --{
    --    id = "noelle",
    --    name = "Noelle",
    --    game = "Deltarune",
    --    material = "glitchlab/sprites/noelle.png",
    --},
    --{
    --    id = "lancer",
    --    name = "Lancer",
    --    game = "Deltarune",
    --    material = "glitchlab/sprites/lancer.png",
    --},
    --{
    --    id = "spamton",
    --    name = "Spamton",
    --    game = "Deltarune",
    --    material = "glitchlab/sprites/spamton.png",
    --},
    --{
    --    id = "jevil",
    --    name = "Jevil",
    --    game = "Deltarune",
    --    material = "glitchlab/sprites/jevil.png",
    --},
    
    ---- Special
    --{
    --    id = "soul_red",
    --    name = "Red Soul",
    --    game = "Special",
    --    material = "glitchlab/sprites/soul_red.png",
    --},
    --{
    --    id = "soul_cyan",
    --    name = "Cyan Soul",
    --    game = "Special",
    --    material = "glitchlab/sprites/soul_cyan.png",
    --},
    --{
    --    id = "annoying_dog",
    --    name = "Annoying Dog",
    --    game = "Special",
    --    material = "glitchlab/sprites/annoying_dog.png",
    --},
}

-- ============================================
-- CACHED MATERIALS
-- ============================================

sprites.MaterialCache = {}

-- ============================================
-- GET MATERIAL (with caching)
-- ============================================

function sprites.GetMaterial(path)
    if not path then return nil end
    
    -- Check cache
    if sprites.MaterialCache[path] then
        return sprites.MaterialCache[path]
    end
    
    -- Try to load material
    local mat = Material(path, "smooth mips")
    
    if mat and not mat:IsError() then
        sprites.MaterialCache[path] = mat
        return mat
    end
    
    return nil
end

-- ============================================
-- GET STYLE ICON
-- ============================================

function sprites.GetStyleIcon(styleName)
    local iconData = sprites.StyleIcons[styleName]
    if not iconData then return nil end
    
    return {
        icon = iconData.icon,
        material = iconData.material and sprites.GetMaterial(iconData.material),
        color = iconData.color,
    }
end

-- ============================================
-- GET CHARACTER SPRITE BY ID
-- ============================================

function sprites.GetCharacter(spriteId)
    for _, char in ipairs(sprites.Characters) do
        if char.id == spriteId then
            return {
                id = char.id,
                name = char.name,
                game = char.game,
                material = sprites.GetMaterial(char.material),
            }
        end
    end
    return nil
end

-- ============================================
-- GET CHARACTER LIST (for menu)
-- ============================================

function sprites.GetCharacterList()
    local list = {}
    for _, char in ipairs(sprites.Characters) do
        table.insert(list, {
            id = char.id,
            name = char.name,
            game = char.game,
        })
    end
    return list
end

-- ============================================
-- DRAW STYLE ICON
-- ============================================

function sprites.DrawStyleIcon(styleName, x, y, size, alpha)
    size = size or 20
    alpha = alpha or 255
    
    local iconData = sprites.GetStyleIcon(styleName)
    if not iconData then return 0 end
    
    -- Check if icons enabled
    local cvar = GetConVar("uc_show_style_icons")
    if cvar and not cvar:GetBool() then
        return 0
    end
    
    local iconWidth = 0
    
    -- Try to draw material first
    if iconData.material then
        surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetMaterial(iconData.material)
        surface.DrawTexturedRect(x, y, size, size)
        iconWidth = size + 4
    elseif iconData.icon and iconData.icon ~= "" then
        -- Draw unicode/emoji fallback with background
        local col = iconData.color or Color(255, 255, 255)
        
        -- Icon background
        local theme = GlitchLab.Theme or {}
        local bgCol = theme.chatBg or Color(10, 10, 10)
        surface.SetDrawColor(bgCol.r + 20, bgCol.g + 20, bgCol.b + 20, alpha * 0.8)
        surface.DrawRect(x - 2, y - 1, size + 4, size + 2)
        
        -- Border
        surface.SetDrawColor(col.r, col.g, col.b, alpha * 0.5)
        surface.DrawOutlinedRect(x - 2, y - 1, size + 4, size + 2, 1)
        
        -- Icon text
        surface.SetFont("GlitchLab_Main")
        surface.SetTextColor(col.r, col.g, col.b, alpha)
        surface.SetTextPos(x, y)
        surface.DrawText(iconData.icon)
        
        iconWidth = surface.GetTextSize(iconData.icon) + 6
    end
    
    return iconWidth
end

-- ============================================
-- STEAM AVATAR SYSTEM
-- ============================================

sprites.AvatarPanels = {}      -- AvatarImage panels per SteamID64
sprites.AvatarReady = {}       -- Is avatar loaded?
sprites.PendingRenders = {}    -- Avatars waiting to be rendered

local AVATAR_SIZE = 64

-- ============================================
-- AVATAR RENDER QUEUE (for HUDPaint)
-- ============================================

sprites.AvatarRenderQueue = {}  -- {ply, x, y, size, alpha}

-- ============================================
-- QUEUE AVATAR FOR RENDERING
-- ============================================

function sprites.QueueAvatar(ply, x, y, size, alpha, clipBounds)
    if not IsValid(ply) then return end
    
    table.insert(sprites.AvatarRenderQueue, {
        ply = ply,
        x = x,
        y = y,
        size = size,
        alpha = alpha,
        clipBounds = clipBounds,  -- {minX, minY, maxX, maxY}
    })
end

-- ============================================
-- RENDER QUEUED AVATARS (called from HUDPaint)
-- ============================================

function sprites.RenderQueuedAvatars()
    for _, data in ipairs(sprites.AvatarRenderQueue) do
        if IsValid(data.ply) then
            -- Check if avatar is within visible bounds
            if data.clipBounds then
                local minX, minY, maxX, maxY = unpack(data.clipBounds)
                
                -- Skip if completely outside bounds
                if data.x + data.size < minX or data.x > maxX then
                    continue
                end
                if data.y + data.size < minY or data.y > maxY then
                    continue
                end
            end
            
            local steamId64 = data.ply:SteamID64()
            local panel = steamId64 and sprites.AvatarPanels[steamId64]
            
            if IsValid(panel) then
                panel:SetSize(data.size, data.size)
                panel:SetAlpha(data.alpha)
                panel:PaintAt(data.x, data.y)
            end
        end
    end
    
    -- Clear queue
    sprites.AvatarRenderQueue = {}
end

-- ============================================
-- HUDPAINT HOOK
-- ============================================

hook.Add("PostRenderVGUI", "GlitchLab_RenderAvatars", function()
    sprites.RenderQueuedAvatars()
end)

-- ============================================
-- PRELOAD AVATAR
-- ============================================

function sprites.PreloadAvatar(ply)
    if not IsValid(ply) then return end
    
    local steamId64 = ply:SteamID64()
    if not steamId64 then return end
    
    -- Already loaded or loading
    if sprites.AvatarPanels[steamId64] then return end
    
    -- Create avatar panel
    local avatar = vgui.Create("AvatarImage")
    avatar:SetSize(AVATAR_SIZE, AVATAR_SIZE)
    avatar:SetPlayer(ply, 64)
    avatar:SetPaintedManually(true)
    avatar:SetVisible(false)
    
    sprites.AvatarPanels[steamId64] = avatar
    
    -- Mark for rendering after delay (let Steam load the image)
    timer.Simple(0.5, function()
        if IsValid(avatar) then
            sprites.PendingRenders[steamId64] = true
        end
    end)
    
    -- Retry after longer delay
    timer.Simple(2, function()
        if IsValid(avatar) and not sprites.AvatarReady[steamId64] then
            sprites.PendingRenders[steamId64] = true
        end
    end)
end

-- ============================================
-- DRAW AVATAR
-- ============================================

function sprites.DrawAvatar(ply, screenX, screenY, size, alpha, localX, localY, clipBounds)
    size = size or 24
    alpha = alpha or 255
    
    local cvar = GetConVar("uc_avatar_mode")
    local mode = cvar and cvar:GetInt() or 1
    
    if mode == 0 then
        return 0
    end
    
    local theme = GlitchLab.Theme or {}
    local accentCol = theme.chatAccent or Color(177, 102, 199)
    local bgCol = theme.chatBg or Color(10, 10, 10)
    
    local drawX = localX or screenX
    local drawY = localY or screenY
    
    -- Mode 1: Steam avatar
    if mode == 1 then
        local initial = "?"
        local hasAvatar = false
        
        if IsValid(ply) then
            initial = string.upper(string.sub(ply:Nick() or "?", 1, 1))
            
            local steamId64 = ply:SteamID64()
            if steamId64 then
                if not sprites.AvatarPanels[steamId64] then
                    sprites.PreloadAvatar(ply)
                end
                
                if IsValid(sprites.AvatarPanels[steamId64]) then
                    hasAvatar = true
                    -- Queue with SCREEN coordinates AND clip bounds
                    sprites.QueueAvatar(ply, screenX, screenY, size, alpha, clipBounds)
                end
            end
        end
        
        -- Draw background/border at LOCAL coordinates
        if not hasAvatar then
            surface.SetDrawColor(bgCol.r + 40, bgCol.g + 40, bgCol.b + 40, alpha)
            surface.DrawRect(drawX, drawY, size, size)
        end
        
        surface.SetDrawColor(accentCol.r, accentCol.g, accentCol.b, alpha * 0.7)
        surface.DrawOutlinedRect(drawX, drawY, size, size, 1)
        
        if not hasAvatar then
            surface.SetFont("GlitchLab_Main")
            local tw, th = surface.GetTextSize(initial)
            local textX = drawX + (size - tw) / 2
            local textY = drawY + (size - th) / 2
            
            surface.SetTextColor(0, 0, 0, alpha * 0.5)
            surface.SetTextPos(textX + 1, textY + 1)
            surface.DrawText(initial)
            
            surface.SetTextColor(accentCol.r, accentCol.g, accentCol.b, alpha)
            surface.SetTextPos(textX, textY)
            surface.DrawText(initial)
        end
        
        return size + 4
    end
    
    -- Mode 2: Character sprite
    if mode == 2 then
        local spriteCvar = GetConVar("uc_avatar_sprite")
        local spriteId = spriteCvar and spriteCvar:GetString() or "frisk"
        local charData = sprites.GetCharacter(spriteId)
        
        if charData and charData.material then
            surface.SetDrawColor(255, 255, 255, alpha)
            surface.SetMaterial(charData.material)
            surface.DrawTexturedRect(drawX, drawY, size, size)
            
            surface.SetDrawColor(accentCol.r, accentCol.g, accentCol.b, alpha * 0.5)
            surface.DrawOutlinedRect(drawX, drawY, size, size, 1)
        else
            surface.SetDrawColor(accentCol.r * 0.3, accentCol.g * 0.3, accentCol.b * 0.3, alpha)
            surface.DrawRect(drawX, drawY, size, size)
            
            surface.SetDrawColor(accentCol.r, accentCol.g, accentCol.b, alpha)
            surface.DrawOutlinedRect(drawX, drawY, size, size, 1)
            
            local spriteInitial = string.upper(string.sub(spriteId, 1, 1))
            surface.SetFont("GlitchLab_Main")
            surface.SetTextColor(accentCol.r, accentCol.g, accentCol.b, alpha)
            local tw, th = surface.GetTextSize(spriteInitial)
            surface.SetTextPos(drawX + (size - tw) / 2, drawY + (size - th) / 2)
            surface.DrawText(spriteInitial)
        end
        
        return size + 4
    end
    
    return 0
end

-- ============================================
-- GET AVATAR MATERIAL (for compatibility)
-- ============================================

function sprites.GetAvatarMaterial(ply)
    -- Not used anymore, but kept for compatibility
    return nil
end

-- ============================================
-- REFRESH AVATAR
-- ============================================

function sprites.RefreshAvatar(ply)
    if not IsValid(ply) then return end
    
    local steamId64 = ply:SteamID64()
    if not steamId64 then return end
    
    -- Remove old panel
    if IsValid(sprites.AvatarPanels[steamId64]) then
        sprites.AvatarPanels[steamId64]:Remove()
    end
    
    sprites.AvatarPanels[steamId64] = nil
    sprites.AvatarReady[steamId64] = nil
    sprites.PendingRenders[steamId64] = nil
    
    -- Preload again
    sprites.PreloadAvatar(ply)
end

-- ============================================
-- GET CURRENT AVATAR SETTINGS
-- ============================================

function sprites.GetCurrentSettings()
    return {
        mode = GetConVar("uc_avatar_mode"):GetInt(),
        spriteId = GetConVar("uc_avatar_sprite"):GetString(),
    }
end

-- ============================================
-- SET AVATAR SETTINGS
-- ============================================

function sprites.SetAvatarMode(mode)
    RunConsoleCommand("uc_avatar_mode", tostring(mode))
end

function sprites.SetSprite(spriteId)
    RunConsoleCommand("uc_avatar_sprite", spriteId)
end

-- ============================================
-- PRELOAD ALL PLAYERS ON SPAWN
-- ============================================

hook.Add("InitPostEntity", "GlitchLab_PreloadAvatars", function()
    timer.Simple(2, function()
        for _, ply in ipairs(player.GetAll()) do
            sprites.PreloadAvatar(ply)
        end
    end)
end)

hook.Add("PlayerInitialSpawn", "GlitchLab_PreloadNewAvatar", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            sprites.PreloadAvatar(ply)
        end
    end)
end)

-- ============================================
-- CLEANUP
-- ============================================

hook.Add("ShutDown", "GlitchLab_SpritesCleanup", function()
    for steamId64, panel in pairs(sprites.AvatarPanels) do
        if IsValid(panel) then
            panel:Remove()
        end
    end
    sprites.AvatarPanels = {}
    sprites.AvatarRTs = {}
    sprites.AvatarMaterials = {}
    sprites.AvatarReady = {}
end)

-- ============================================
-- CONSOLE COMMANDS
-- ============================================

concommand.Add("uc_sprite_list", function()
    print("\n=== Available Sprites ===")
    
    local lastGame = ""
    for _, char in ipairs(sprites.Characters) do
        if char.game ~= lastGame then
            print("\n[" .. char.game .. "]")
            lastGame = char.game
        end
        print("  " .. char.id .. " — " .. char.name)
    end
    
    print("\nCurrent sprite: " .. GetConVar("uc_avatar_sprite"):GetString())
    print("=========================\n")
end, nil, "List available sprites")

concommand.Add("uc_sprite_set", function(ply, cmd, args)
    local spriteId = args[1]
    if not spriteId then
        print("Usage: uc_sprite_set <sprite_id>")
        print("Use uc_sprite_list to see available sprites")
        return
    end
    
    -- Validate sprite exists
    local found = false
    for _, char in ipairs(sprites.Characters) do
        if char.id == spriteId then
            found = true
            break
        end
    end
    
    if not found then
        print("[UnderComms] Sprite not found: " .. spriteId)
        return
    end
    
    sprites.SetSprite(spriteId)
    sprites.SetAvatarMode(2)  -- Switch to sprite mode
    
    print("[UnderComms] Sprite set to: " .. spriteId)
end, nil, "Set your chat sprite")

concommand.Add("uc_avatar_steam", function()
    sprites.SetAvatarMode(1)
    print("[UnderComms] Avatar mode: Steam")
end, nil, "Use Steam avatar")

concommand.Add("uc_avatar_none", function()
    sprites.SetAvatarMode(0)
    print("[UnderComms] Avatar mode: None")
end, nil, "Disable avatar")

concommand.Add("uc_icons_toggle", function()
    local cvar = GetConVar("uc_show_style_icons")
    local newVal = not cvar:GetBool()
    RunConsoleCommand("uc_show_style_icons", newVal and "1" or "0")
    print("[UnderComms] Style icons: " .. (newVal and "ON" or "OFF"))
end, nil, "Toggle style icons")

concommand.Add("uc_avatar_refresh", function()
    for _, ply in ipairs(player.GetAll()) do
        sprites.RefreshAvatar(ply)
    end
    print("[UnderComms] Avatars refreshed")
end, nil, "Refresh all player avatars")

concommand.Add("uc_avatar_status", function()
    print("\n=== Avatar Status ===")
    print("Mode: " .. GetConVar("uc_avatar_mode"):GetInt())
    print("Sprite: " .. GetConVar("uc_avatar_sprite"):GetString())
    print("")
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local steamId64 = ply:SteamID64()
            local ready = sprites.AvatarReady[steamId64] and "READY" or "LOADING"
            local hasPanel = sprites.AvatarPanels[steamId64] and "YES" or "NO"
            print(string.format("  %s: %s (panel: %s)", ply:Nick(), ready, hasPanel))
        end
    end
    print("=====================\n")
end, nil, "Show avatar loading status")

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), "Sprite system loaded (with Steam avatars)\n")