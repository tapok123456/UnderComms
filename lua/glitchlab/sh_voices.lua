--[[
    GlitchLab | UnderComms — Voice System (Shared)
    
    v0.8.0 — VOICE EDITION
    
    Every player can have their own voice, just like
    every character in Undertale has unique blips.
    This shit is gonna be FIRE.
]]

GlitchLab = GlitchLab or {}
GlitchLab.Voices = GlitchLab.Voices or {}

-- ============================================
-- VOICE DEFINITIONS
-- Each voice has unique sound characteristics
-- Like Sans vs Papyrus, ya know?
-- ============================================

GlitchLab.Voices.List = {
    -- ========== CLASSIC VOICES ==========
    
    ["asriel"] = {
        name = "Asriel",
        description = "The voice of Asriel's Kid form",
        sound = "voices/voice_asriel.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.4,
        speedMult = 0.7,
        icon = "voice_asriel",
        category = "Classic",
    },
    
    ["asriel_hyperdeath"] = {
        name = "Asriel Hyperdeath",
        description = "The voice of Asriel's Hyperdeath form",
        sound = "voices/voice_asriel_hyperdeath.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.4,
        speedMult = 0.7,
        icon = "voice_asriel_hyperdeath",
        category = "Classic",
    },
    
    ["sans"] = {
        name = "Sans",
        description = "Deep, lazy, lowercase energy",
        sound = "voices/voice_sans.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.25,
        speedMult = 0.7,
        icon = "voice_sans",
        category = "Classic",
    },
    
    ["papyrus"] = {
        name = "Papyrus",
        description = "LOUD AND CONFIDENT! NYEH HEH HEH!",
        sound = "voices/voice_papyrus.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.35,
        speedMult = 0.7,
        icon = "voice_papyrus",
        category = "Classic",
    },
    
    ["toriel"] = {
        name = "Toriel",
        description = "Warm and motherly",
        sound = "voices/voice_toriel.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.28,
        speedMult = 0.7,
        icon = "voice_toriel",
        category = "Classic",
    },
    
    ["undyne"] = {
        name = "Undyne",
        description = "Aggressive and passionate!",
        sound = "voices/voice_undyne.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.35,
        speedMult = 0.7,
        icon = "voice_undyne",
        category = "Classic",
    },
    
    ["alphys"] = {
        name = "Alphys",
        description = "N-nervous and stuttery...",
        sound = "voices/voice_alphys.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.22,
        speedMult = 0.7,
        icon = "voice_alphys",
        category = "Classic",
    },
    
    ["mettaton"] = {
        name = "Mettaton",
        description = "OH YES! Fabulous and dramatic~",
        sound = "voices/voice_mettaton.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.32,
        speedMult = 0.7,
        icon = "voice_mettaton",
        category = "Classic",
    },
    
    --["napstablook"] = {
    --    name = "Napstablook",
    --    description = "oh............ really quiet and sad",
    --    sound = "voices/voice_napstablook.wav",
    --    pitchMin = 75,
    --    pitchMax = 90,
    --    volume = 0.15,  -- very quiet
    --    speedMult = 0.7,  -- slow and sad
    --    icon = "voice_napstablook",
    --    category = "Classic",
    --},
    
    ["flowey"] = {
        name = "Flowey",
        description = "Friendly at first... then CREEPY",
        sound = "voices/voice_flowey.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        speedMult = 0.7,
        icon = "voice_flowey",
        category = "Classic",
    },
    
    ["asgore"] = {
        name = "Asgore",
        description = "Deep and regal, with sadness",
        sound = "voices/voice_asgore.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        speedMult = 0.7,
        icon = "voice_asgore",
        category = "Classic",
    },
    
    -- ========== DELTARUNE VOICES ==========
    
    --["kris"] = {
    --    name = "Kris",
    --    description = "Silent protagonist... or are they?",
    --    sound = "voices/voice_kris.wav",
    --    pitchMin = 100,
    --    pitchMax = 100,
    --    volume = 0.25,
    --    speedMult = 1.0,
    --    icon = "voice_kris",
    --    category = "Deltarune",
    --},
    
    ["susie"] = {
        name = "Susie",
        description = "Rough and tough, dont mess with her",
        sound = "voices/voice_susie.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        speedMult = 1.0,
        icon = "voice_susie",
        category = "Deltarune",
    },
    
    ["ralsei"] = {
        name = "Ralsei",
        description = "Soft fluffy boy, very kind",
        sound = "voices/voice_ralsei.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        speedMult = 0.95,
        icon = "voice_ralsei",
        category = "Deltarune",
    },
    
    ["lancer"] = {
        name = "Lancer",
        description = "HO HO HO! Bad guy but actually good",
        sound = "voices/voice_lancer.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        speedMult = 1.1,
        icon = "voice_lancer",
        category = "Deltarune",
    },
    
    ["spamton"] = {
        name = "Spamton",
        description = "NOW'S YOUR CHANCE TO BE A [[BIG SHOT]]",
        sound = "voices/voice_spamton.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        speedMult = 1.3,  -- fast and chaotic
        icon = "voice_spamton",
        category = "Deltarune",
        glitchy = true,  -- special flag for glitch effects
    },
    
    ["jevil"] = {
        name = "Jevil",
        description = "CHAOS CHAOS! I CAN DO ANYTHING!",
        sound = "voices/voice_jevil.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        speedMult = 1.25,
        icon = "voice_jevil",
        category = "Deltarune",
        chaotic = true,
    },
    
    -- ========== SPECIAL VOICES ==========

--[[
    ["robot"] = {
        name = "Robot",
        description = "BEEP BOOP. MECHANICAL SPEECH DETECTED.",
        sound = "voices/voice_robot.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        speedMult = 1.0,
        icon = "voice_robot",
        category = "Special",
    },
    
    ["demon"] = {
        name = "Demon",
        description = "Ḑ̷̛A̸R̷K̵ ̸A̷N̸D̶ ̵D̴I̷S̸T̵O̶R̵T̷E̵D̷",
        sound = "voices/voice_demon.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.35,
        speedMult = 0.8,
        icon = "voice_demon",
        category = "Special",
        distorted = true,
    },
    
    ["glitch"] = {
        name = "Glitch",
        description = "E̵̢R̷̨R̵O̷R̴_̴V̷O̸I̷C̵E̶_̵N̸O̶T̸_̸F̵O̷U̷N̴D̵",
        sound = "voices/voice_glitch.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        speedMult = 1.0,
        icon = "voice_glitch",
        category = "Special",
        glitchy = true,
        randomPitchPerChar = true,
    },
    
    ["whisper"] = {
        name = "Whisper",
        description = "barely audible... shhhh...",
        sound = "voices/voice_whisper.wav",
        pitchMin = 100,
        pitchMax = 110,
        volume = 0.1,
        speedMult = 0.85,
        icon = "voice_whisper",
        category = "Special",
    },
    
    ["announcer"] = {
        name = "Announcer",
        description = "ATTENTION! IMPORTANT ANNOUNCEMENT!",
        sound = "voices/voice_announcer.wav",
        pitchMin = 80,
        pitchMax = 100,
        volume = 0.4,
        speedMult = 0.9,
        icon = "voice_announcer",
        category = "Special",
    },
    
    ["child"] = {
        name = "Child",
        description = "High-pitched and innocent",
        sound = "voices/voice_child.wav",
        pitchMin = 130,
        pitchMax = 160,
        volume = 0.28,
        speedMult = 1.1,
        icon = "voice_child",
        category = "Special",
    },
]]
    
    ["gaster"] = {
        name = "Gaster",
        description = "... ... ... (ENTRY SEVENTEEN)",
        sound = "voices/voice_gaster.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        speedMult = 0.4,
        icon = "voice_gaster",
        category = "Special",
        wingdings = true,  -- special flag
        distorted = true,
    },
    
    ["default"] = {
        name = "Default",
        description = "Standard addon voice",
        sound = "voices/voice_default.wav",
        pitchMin = 100,
        pitchMax = 100,
        volume = 0.3,
        speedMult = 0.7,
        icon = "voice_default",
        category = "Special",
    },
    
    -- ========== CUSTOM/MEME VOICES ==========

--[[
    ["mlg"] = {
        name = "MLG",
        description = "420 BLAZE IT NOSCOPE",
        sound = "voices/voice_mlg.wav",
        pitchMin = 70,
        pitchMax = 130,
        volume = 0.35,
        speedMult = 1.4,
        icon = "voice_mlg",
        category = "Meme",
    },
    
    ["uwu"] = {
        name = "UwU",
        description = "OwO what's this? *notices ur message*",
        sound = "voices/voice_uwu.wav",
        pitchMin = 120,
        pitchMax = 150,
        volume = 0.25,
        speedMult = 1.0,
        icon = "voice_uwu",
        category = "Meme",
    },
    
    ["none"] = {
        name = "Silent",
        description = "No voice at all (for the shy ones)",
        sound = nil,  -- no sound
        pitchMin = 100,
        pitchMax = 100,
        volume = 0,
        speedMult = 1.0,
        icon = "voice_none",
        category = "Special",
    },
]]
}

-- ============================================
-- VOICE CATEGORIES FOR UI
-- ============================================

GlitchLab.Voices.Categories = {
    "Classic",
    "Deltarune", 
    "Special",
    "Meme",
}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

function GlitchLab.Voices.Get(voiceId)
    return GlitchLab.Voices.List[voiceId] or GlitchLab.Voices.List["default"]
end

function GlitchLab.Voices.GetByCategory(category)
    local result = {}
    for id, voice in pairs(GlitchLab.Voices.List) do
        if voice.category == category then
            result[id] = voice
        end
    end
    return result
end

function GlitchLab.Voices.GetAllSorted()
    local sorted = {}
    for id, voice in pairs(GlitchLab.Voices.List) do
        table.insert(sorted, {id = id, voice = voice})
    end
    table.sort(sorted, function(a, b)
        if a.voice.category ~= b.voice.category then
            return a.voice.category < b.voice.category
        end
        return a.voice.name < b.voice.name
    end)
    return sorted
end

-- ============================================
-- NETWORK STRINGS
-- ============================================

if SERVER then
    util.AddNetworkString("GlitchLab_VoiceUpdate")
    util.AddNetworkString("GlitchLab_VoiceSync")
    util.AddNetworkString("GlitchLab_VoiceRequest")
end

MsgC(Color(177, 102, 199), "[GlitchLab] ")
MsgC(Color(255, 255, 255), "Voice system loaded (" .. table.Count(GlitchLab.Voices.List) .. " voices)\n")