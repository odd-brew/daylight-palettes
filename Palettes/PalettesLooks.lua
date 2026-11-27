-- Frame looks and Presets. A frame look is a bundle of DaylightUI
-- settings for the player and target frames. Palettes never registers a frame
-- style and never writes UnitFrames look.style, so every other frame stays put.
-- A Preset sets one palette and one frame look. Palettes stay color-only.
-- The snapshot lives in Palettes' saved data and profile settings, never LooksDB.
-- A pick waits out combat. API 1.7 and 1.8 keep colors and hide this page.

local _, ns = ...

local NEED_STYLES = "Palettes: Daylight UI is missing the settings frame looks need, so only colors are available."
local BOTH = "Palettes: Looks is also loaded. Turn Looks off; frame looks now live in Palettes."

-- One row per look. Every look carries the same keys, so switching never leaves
-- a value from the last one behind. Widths are settings: 187 draws 188 wide.
-- Trestle's 0.80 portrait scale draws a 55 px socket, so its name row is
-- 162.3 x 16 and the whole look is 225.3 x 55.
local LOOK_SPECS = {
    flagon = {
        style = "daylight", width = 187, height = 32, powerHeight = 11, ribbonGap = 2, tabHeight = 16, slant = true,
        border = 3, corner = 6, shadow = 4,
        portrait = "class", portraitLook = "socket", portraitShape = "round", ring = "class", ringWidth = "thin", scale = 0.80,
        dragon = false, nameOnBar = true, namePos = "bar",
        tabWidth = "fit", tabSlant = "frame", tabCorner = 6, tabShadow = 2,
        bigNumber = false, playerHealth = "both", targetHealth = "percentboth",
        showPowerText = false, powerFormat = "value", targetLevel = "foot",
        percent = 11, big = 18,
    },
    trestle = {
        style = "ribbon", width = 187, height = 24, powerHeight = 5, ribbonGap = 2, tabHeight = 16, slant = true,
        border = 3, corner = 4, shadow = 4,
        portrait = "class", portraitLook = "socket", portraitShape = "round", ring = "class", ringWidth = "normal", scale = 0.80,
        dragon = false, nameOnBar = false, namePos = "bar",
        tabWidth = "fit", tabSlant = "frame", tabCorner = 4, tabShadow = 2,
        bigNumber = false, playerHealth = "value", targetHealth = "percent",
        showPowerText = false, powerFormat = "value", targetLevel = "foot",
        percent = 12, big = 18,
    },
    beam = {
        style = "daylight", width = 200, height = 42, powerHeight = 10, ribbonGap = 2, tabHeight = 16, slant = true,
        border = 6, corner = 2, shadow = 4,
        portrait = "class", portraitLook = "socket", portraitShape = "angled", ring = "dark", ringWidth = "thin", scale = 1.0,
        dragon = false, nameOnBar = false, namePos = "bar",
        tabWidth = "full", tabSlant = "frame", tabCorner = 2, tabShadow = 2,
        bigNumber = true, playerHealth = "both", targetHealth = "percent",
        showPowerText = false, powerFormat = "value", targetLevel = "foot",
        percent = 11, big = 18,
    },
    stream = {
        style = "ribbon", width = 210, height = 24, powerHeight = 5, ribbonGap = 3, tabHeight = 16, slant = true,
        border = 4, corner = 2, shadow = 3,
        portrait = "class", portraitLook = "socket", portraitShape = "round", ring = "class", ringWidth = "thin", scale = 0.80,
        dragon = false, nameOnBar = false, namePos = "bar",
        tabWidth = "fit", tabSlant = "frame", tabCorner = 2, tabShadow = 2,
        bigNumber = false, playerHealth = "value", targetHealth = "percent",
        showPowerText = false, powerFormat = "value", targetLevel = "foot",
        percent = 12, big = 18,
    },
    ledger = {
        style = "daylight", width = 196, height = 36, powerHeight = 10, ribbonGap = 2, tabHeight = 16, slant = false,
        border = 4, corner = 0, shadow = 2,
        portrait = "none", portraitLook = "socket", portraitShape = "square", ring = "dark", ringWidth = "normal", scale = 1.0,
        dragon = false, nameOnBar = true, namePos = "above",
        tabWidth = "fit", tabSlant = "off", tabCorner = 0, tabShadow = 0,
        bigNumber = false, playerHealth = "both", targetHealth = "percentboth",
        showPowerText = true, powerFormat = "percent", targetLevel = "foot",
        percent = 11, big = 18,
    },
    crest = {
        style = "daylight", width = 192, height = 46, powerHeight = 11, ribbonGap = 2, tabHeight = 17, slant = true,
        border = 8, corner = 8, shadow = 6,
        portrait = "3d", portraitLook = "classic", portraitShape = "round", ring = "class", ringWidth = "thick", scale = 1.05,
        dragon = true, nameOnBar = false, namePos = "bar",
        tabWidth = "fit", tabSlant = "frame", tabCorner = 6, tabShadow = 4,
        bigNumber = true, playerHealth = "value", targetHealth = "percent",
        showPowerText = false, powerFormat = "value", targetLevel = "ring",
        percent = 11, big = 22,
    },
    slate = {
        style = "ribbon", width = 188, height = 22, powerHeight = 4, ribbonGap = 2, tabHeight = 15, slant = false,
        border = 4, corner = 0, shadow = 2,
        portrait = "none", portraitLook = "socket", portraitShape = "square", ring = "dark", ringWidth = "thin", scale = 1.0,
        dragon = false, nameOnBar = false, namePos = "bar",
        tabWidth = "fit", tabSlant = "off", tabCorner = 0, tabShadow = 0,
        bigNumber = false, playerHealth = "value", targetHealth = "percent",
        showPowerText = false, powerFormat = "value", targetLevel = "foot",
        percent = 11, big = 18,
    },
}

local FRAMES = {
    { id = "flagon", name = "Flagon", desc = "Slanted bar with round class socket and flowing health FX for smooth combat feedback.", bestFor = "All-Rounder, Solo Leveling" },
    { id = "trestle", name = "Trestle", desc = "Slim slanted bar with hung power rail and top name tab to save vertical screen space.", bestFor = "DPS, 5-Man Dungeons" },
    { id = "beam", name = "Beam", desc = "Tall slanted bar with angled portrait and big HP numbers for instant peripheral reads.", bestFor = "Tanking, Dungeons & Raids" },
    { id = "stream", name = "Stream", desc = "Slim slanted ribbon with floating name and class-ring portrait to cut mid-screen bulk.", bestFor = "Healing, Ranged DPS" },
    { id = "ledger", name = "Ledger", desc = "Square portrait-free bar with dual health and power readouts for clean resource tracking.", bestFor = "Mana Management, Raiding" },
    { id = "crest", name = "Crest", desc = "Tall hero bar with 3D portrait, thick class ring, and big numbers for classic presence.", bestFor = "Solo Questing, Tanking" },
    { id = "slate", name = "Slate", desc = "Flat 22px portrait-free strip with hairline power bar for the smallest combat footprint.", bestFor = "20/40-Man Raiding, Minimalists" },
}

-- Only these two frames are ever written. Everything else DaylightUI keeps is the player's.
local UNITS = { "player", "target" }
local STYLES = { "daylight", "ribbon" }
local SIZE_FIELDS = { "height", "powerHeight", "tabHeight" }

local function unitPairs(unit, spec)
    local isPlayer = unit == "player"
    local list = {}
    local function put(key, value) list[#list + 1] = { unit .. "." .. key, value } end
    put("style", spec.style)
    put("width", spec.width)
    put("height", spec.height)
    put("powerHeight", spec.powerHeight)
    put("ribbonGap", spec.ribbonGap)
    put("tabHeight", spec.tabHeight)
    put("slant", spec.slant)
    put("strata", "MEDIUM")
    put("showPower", true)
    put("powerAt", "inside")
    put("portraitAt", "frame")
    put("showName", true)
    put("showPercent", true)
    put("showLevel", not isPlayer)
    put("shell.own", true)
    put("shell.borderPx", spec.border)
    put("shell.cornerPx", spec.corner)
    put("shell.shadowPx", spec.shadow)
    put("tab.own", true)
    put("tab.width", spec.tabWidth)
    put("tab.at", "outer")
    put("tab.slant", spec.tabSlant)
    put("tab.align", "center")
    put("tab.color", "dark")
    put("tab.borderPx", 4)
    put("tab.cornerPx", spec.tabCorner)
    put("tab.shadowPx", spec.tabShadow)
    put("portrait", spec.portrait)
    put("portraitLook", spec.portraitLook)
    put("portraitShape", spec.portraitShape)
    put("portraitRing", spec.ring)
    put("portraitRingWidth", spec.ringWidth)
    put("portraitRingLine", true)
    put("portraitScale", spec.scale)
    if isPlayer then
        put("portraitDragon", spec.dragon)
        put("portraitDragonColor", "class")
    end
    put("nameOnBar", spec.nameOnBar)
    put("namePos", spec.namePos)
    put("nameX", 0)
    put("nameY", 0)
    put("bigNumber", spec.bigNumber)
    put("healthText", isPlayer and spec.playerHealth or spec.targetHealth)
    put("percentSign", true)
    put("healthTextPos", "inner")
    put("healthTextX", 0)
    put("healthTextY", 0)
    put("showPowerText", spec.showPowerText)
    put("powerFormat", spec.powerFormat)
    put("powerPercentSign", true)
    put("powerTextPos", "inner")
    if not isPlayer then put("levelPos", spec.targetLevel) end
    list[#list + 1] = { unit .. "Text.name", 12 }
    list[#list + 1] = { unit .. "Text.percent", spec.percent }
    list[#list + 1] = { unit .. "Text.big", spec.big }
    list[#list + 1] = { unit .. "Text.power", 0 }
    return list
end

-- FRAME_KEYS is the one key list every look fills. The sizes keys keep a style
-- swap from writing old heights back over a look. Flagon alone adds the extras.
local FRAME_KEYS = {}
local FRAME_VALUES = {}
local SIZE_KEYS = {}
local SIZE_BY_LOOK = {}
local EXTRA_KEYS = {}
local EXTRA_VALUES = {}

local function buildFrames()
    for u = 1, #UNITS do
        local unit = UNITS[u]
        local keys = unitPairs(unit, LOOK_SPECS.flagon)
        for i = 1, #keys do FRAME_KEYS[#FRAME_KEYS + 1] = keys[i][1] end
        for s = 1, #STYLES do
            for f = 1, #SIZE_FIELDS do
                SIZE_KEYS[#SIZE_KEYS + 1] = unit .. ".sizes." .. STYLES[s] .. "." .. SIZE_FIELDS[f]
            end
        end
    end
    for id, spec in pairs(LOOK_SPECS) do
        local values, sizes = {}, {}
        for u = 1, #UNITS do
            local unit = UNITS[u]
            local list = unitPairs(unit, spec)
            for i = 1, #list do values[list[i][1]] = list[i][2] end
            for f = 1, #SIZE_FIELDS do
                local key = unit .. ".sizes." .. spec.style .. "." .. SIZE_FIELDS[f]
                sizes[#sizes + 1] = key
                values[key] = spec[SIZE_FIELDS[f]]
            end
        end
        FRAME_VALUES[id] = values
        SIZE_BY_LOOK[id] = sizes
    end
    local extras = {
        { "media.health", "daylight" }, { "media.healthBack", "daylight" },
        { "media.power", "daylight" }, { "media.powerBack", "daylight" },
        { "colorHealth", "global" }, { "colorPower", "global" },
        { "backHealth", "global" }, { "backPower", "global" },
        { "barFx.health.style", "flow" }, { "barFx.health.speed", 1 }, { "barFx.health.strength", 1 },
        { "barFx.health.colors", "bar" }, { "barFx.health.react", true }, { "barFx.health.reactSize", 1 },
    }
    for u = 1, #UNITS do
        for i = 1, #extras do
            local key = UNITS[u] .. "." .. extras[i][1]
            EXTRA_KEYS[#EXTRA_KEYS + 1] = key
            EXTRA_VALUES[key] = extras[i][2]
        end
    end
end
buildFrames()

local THEMES = {
    {
        id = "hearthnight", name = "Hearthnight",
        palette = "ember", frame = "beam", focus = "compact_beam", tot = "compact_pill",
        party = "framed", raid = "framed", castbars = "molten", actionbars = "classic",
        tags = { "Beam", "Molten" },
        bestFor = "Dungeons, Raiding, DPS & Tanks",
        mood = "Warm ember frames and fiery casts for high-focus combat.",
        rationale = "Pairs Ember's dark contrast with Beam's bold portrait bars, framed group plates, and Molten casts so interrupts and threat spikes stand out in dim instances.",
    },
    {
        id = "harvestide", name = "Harvestide",
        palette = "vanilla", frame = "stream", focus = "slim_ribbon", tot = "compact_pill",
        party = "standard", raid = "tiles", castbars = "silk", actionbars = "classic",
        tags = { "Stream", "Silk" },
        bestFor = "All-Rounder, Solo Leveling, Group Questing",
        mood = "Warm classic ribbons and soft bars for relaxed sessions.",
        rationale = "Blends Vanilla tones with Stream's airy ribbons, standard party portraits, and Silk cast bars for a readable, low-fatigue UI across quests and dungeons.",
    },
    {
        id = "tidemark", name = "Tidemark",
        palette = "tide", frame = "slate", focus = "minimal_slate", tot = "slim_bar",
        party = "compact", raid = "tight", castbars = "tide", actionbars = "flat",
        tags = { "Slate", "Tight Grid" },
        bestFor = "20/40-Man Raiding, DPS, Minimalists",
        mood = "Portrait-free, razor-thin frames for maximum screen view.",
        rationale = "Strips portraits, shadows, and extra borders across every layer—pairing Tide with Slate, Tight Raid Grid, and Crisp Flat buttons so encounter mechanics own the screen.",
    },
    {
        id = "oldroad", name = "Old Road",
        palette = "forever", frame = "crest", focus = "compact_beam", tot = "crisp_square",
        party = "framed", raid = "framed", castbars = "brushed", actionbars = "heavy",
        tags = { "Crest", "Heavy Rim" },
        bestFor = "Tanking, Solo & Group Questing, Classic Feel",
        mood = "Tall 3D hero portraits and heavy steel for classic weight.",
        rationale = "Combines Forever's dark palette with Crest's 3D portraits, thick-bordered group frames, Brushed casts, and Heavy Rim buttons for unmistakable peripheral clarity.",
    },
    {
        id = "vigil", name = "Vigil",
        palette = "paladin", frame = "stream", focus = "slim_ribbon", tot = "compact_pill",
        party = "healer", raid = "matte", castbars = "silk", actionbars = "circle",
        tags = { "Healer Grid", "Medallion" },
        bestFor = "Healing & Triage, 5-Man Dungeons, Raiding",
        mood = "Triage-ready party grids, vertical raid bars, medallions.",
        rationale = "Built for healers: pairs Paladin accents and low-profile Stream player bars with tall Healer Grid party frames, Vertical Healer raid cells, and Silk cast tracking.",
    },
    {
        id = "snug", name = "Snug",
        palette = "gilded", frame = "flagon", focus = "match", tot = "compact_pill",
        party = "standard", raid = "tiles", castbars = "flow", actionbars = "circle",
        tags = { "Flagon", "Living Flow" },
        bestFor = "All-Rounder, Solo Leveling, 5-Man Dungeons",
        mood = "Gilded trim with animated flow bars and round buttons.",
        rationale = "Matches Gilded's warm metallic accents with Flagon's flowing health bars, Living Flow casts, and Rounded Medallion buttons for a cohesive, animated everyday setup.",
    },
}
ns.themes = THEMES

-- 7 single-row Looks sub-tab categories (Issue #42).
local LOOK_CATEGORIES = {
    { key = "player_target", short = "Player & Target", label = "Player & Target" },
    { key = "focus", short = "Focus", label = "Focus" },
    { key = "tot", short = "ToT", label = "Target of Target", tooltip = "Target of Target" },
    { key = "party", short = "Party", label = "Party" },
    { key = "raid", short = "Raid", label = "Raid" },
    { key = "castbars", short = "Cast Bars", label = "Cast Bars" },
    { key = "actionbars", short = "Action Bars", label = "Action Bars" },
}
ns.lookCategories = LOOK_CATEGORIES

local CASTBAR_UNITS = { "playerCastbar", "targetCastbar", "focusCastbar", "partyCastbar" }

local EXTRA_LOOKS = {
    focus = {
        { id = "match", name = "Match Player & Target", isMatch = true,
          desc = "Mirrors your active Player & Target style so focus stays visually unified with targets.",
          bestFor = "All-Rounder, Visual Consistency" },
        { id = "compact_beam", name = "Compact Beam",
          desc = "Slanted mini-frame with square class icon and full tab for clear interrupt tracking.",
          bestFor = "DPS Interrupts, PvP",
          settings = {
              style = "daylight", width = 186, height = 28, powerHeight = 5, slant = true,
              portrait = "class", portraitLook = "socket", portraitShape = "square",
              portraitRing = "class", portraitRingWidth = "normal", portraitScale = 0.9,
              nameOnBar = false, namePos = "above", tabHeight = 16, bigNumber = false,
              showPower = true, showPowerText = false, showLevel = false,
              ["tab.own"] = true, ["tab.width"] = "full", ["tab.slant"] = "frame", ["tab.cornerPx"] = 4, ["tab.shadowPx"] = 2,
              ["shell.own"] = true, ["shell.borderPx"] = 2, ["shell.cornerPx"] = 6, ["shell.shadowPx"] = 5,
          } },
        { id = "slim_ribbon", name = "Slim Ribbon",
          desc = "Light slanted ribbon with round class icon and fitted tab for low-clutter CC watches.",
          bestFor = "Healing, Crowd Control",
          settings = {
              style = "ribbon", width = 176, height = 20, powerHeight = 4, ribbonGap = 2, slant = true,
              portrait = "class", portraitLook = "socket", portraitShape = "round",
              portraitRing = "class", portraitRingWidth = "thin", portraitScale = 0.85,
              nameOnBar = false, namePos = "above", tabHeight = 14, bigNumber = false,
              showPower = true, showPowerText = false, showLevel = false,
              ["tab.own"] = true, ["tab.width"] = "fit", ["tab.slant"] = "frame", ["tab.cornerPx"] = 4, ["tab.shadowPx"] = 2,
              ["shell.own"] = true, ["shell.borderPx"] = 1, ["shell.cornerPx"] = 4, ["shell.shadowPx"] = 3,
          } },
        { id = "minimal_slate", name = "Minimal Slate",
          desc = "Flat, portrait-free bar with name on health and zero shadow for tight raid layouts.",
          bestFor = "Raiding, Minimalists",
          settings = {
              style = "ribbon", width = 164, height = 18, powerHeight = 3, ribbonGap = 1, slant = false,
              portrait = "none", nameOnBar = true, namePos = "bar", bigNumber = false,
              showPower = true, showPowerText = false, showLevel = false,
              ["shell.own"] = true, ["shell.borderPx"] = 1, ["shell.cornerPx"] = 0, ["shell.shadowPx"] = 0,
          } },
    },
    tot = {
        { id = "match", name = "Match Player & Target", isMatch = true,
          desc = "Copies your Player & Target border and slant for a seamless target cluster.",
          bestFor = "All-Rounder, Visual Consistency" },
        { id = "compact_pill", name = "Compact Pill",
          desc = "Rounded capsule with soft shadow and % HP to spot aggro swaps at a glance.",
          bestFor = "Dungeons, Tanking",
          settings = {
              width = 118, height = 22, slant = false, showPower = false, powerHeight = 4,
              portrait = "none", namePos = "bar", showPercent = true,
              ["shell.own"] = true, ["shell.borderPx"] = 2, ["shell.cornerPx"] = 8, ["shell.shadowPx"] = 4,
          } },
        { id = "slim_bar", name = "Slim Bar",
          desc = "Low-profile 16px strip with 1px border and no shadow to stay out of the way.",
          bestFor = "Raiding, DPS",
          settings = {
              width = 112, height = 16, slant = false, showPower = false, powerHeight = 4,
              portrait = "none", namePos = "bar", showPercent = false,
              ["shell.own"] = true, ["shell.borderPx"] = 1, ["shell.cornerPx"] = 2, ["shell.shadowPx"] = 0,
          } },
        { id = "crisp_square", name = "Crisp Square",
          desc = "Sharp 90° frame with class icon and 2px border for fast tank target-swap reads.",
          bestFor = "Tanking, PvP",
          settings = {
              width = 124, height = 22, slant = false, showPower = false, powerHeight = 4,
              portrait = "class", namePos = "bar", showPercent = true,
              ["shell.own"] = true, ["shell.borderPx"] = 2, ["shell.cornerPx"] = 0, ["shell.shadowPx"] = 2,
          } },
    },
    party = {
        { id = "standard", name = "Daylight Standard",
          desc = "Slanted 34px bars with round portraits, role icons, and heals for everyday 5-mans.",
          bestFor = "5-Man Dungeons, Group Questing",
          settings = {
              style = "daylight", width = 196, height = 34, powerHeight = 7, spacing = 10, slant = true,
              portrait = "class", portraitLook = "socket", portraitShape = "round",
              portraitRing = "class", portraitRingWidth = "normal", portraitScale = 0.95,
              nameOnBar = false, namePos = "above", tabHeight = 16, bigNumber = true,
              showPower = true, showPowerText = false, showLevel = false,
              showRole = true, predictHeals = true, predictAbsorbs = true, showThreat = true,
              ["tab.own"] = true, ["tab.width"] = "fit", ["tab.slant"] = "frame", ["tab.cornerPx"] = 4, ["tab.shadowPx"] = 2,
              ["shell.own"] = true, ["shell.borderPx"] = 2, ["shell.cornerPx"] = 5, ["shell.shadowPx"] = 4,
          } },
        { id = "compact", name = "Clean Compact",
          desc = "Portrait-free 24px square bars with zero shadow to free up left-side screen space.",
          bestFor = "DPS, Minimalists",
          settings = {
              style = "ribbon", width = 168, height = 24, powerHeight = 4, ribbonGap = 1, spacing = 5, slant = false,
              portrait = "none", nameOnBar = true, namePos = "bar", bigNumber = false,
              showPower = true, showPowerText = false, showLevel = false,
              showRole = true, predictHeals = true, predictAbsorbs = false, showThreat = true,
              ["shell.own"] = true, ["shell.borderPx"] = 1, ["shell.cornerPx"] = 0, ["shell.shadowPx"] = 0,
          } },
        { id = "healer", name = "Healer Grid",
          desc = "Tall 42px portrait-free bars with incoming heals, absorbs, and threat for fast triage.",
          bestFor = "Healing & Triage, 5-Man Dungeons",
          settings = {
              style = "daylight", width = 184, height = 42, powerHeight = 6, spacing = 6, slant = false,
              portrait = "none", nameOnBar = true, namePos = "bar", bigNumber = false,
              showPower = true, showPowerText = false, showLevel = false,
              showRole = true, predictHeals = true, predictAbsorbs = true, showThreat = true,
              ["shell.own"] = true, ["shell.borderPx"] = 2, ["shell.cornerPx"] = 3, ["shell.shadowPx"] = 2,
          } },
        { id = "framed", name = "Framed Classic",
          desc = "Thick-bordered slanted bars with square portraits and threat highlights for tanks.",
          bestFor = "Tanking, Classic Feel",
          settings = {
              style = "daylight", width = 204, height = 38, powerHeight = 8, spacing = 12, slant = true,
              portrait = "class", portraitLook = "classic", portraitShape = "square",
              portraitRing = "dark", portraitRingWidth = "thick", portraitScale = 1.0,
              nameOnBar = false, namePos = "above", tabHeight = 17, bigNumber = true,
              showPower = true, showPowerText = false, showLevel = true,
              showRole = true, predictHeals = true, predictAbsorbs = true, showThreat = true,
              ["tab.own"] = true, ["tab.width"] = "full", ["tab.slant"] = "frame", ["tab.cornerPx"] = 3, ["tab.shadowPx"] = 3,
              ["shell.own"] = true, ["shell.borderPx"] = 3, ["shell.cornerPx"] = 4, ["shell.shadowPx"] = 6,
          } },
    },
    raid = {
        { id = "tiles", name = "Daylight Tiles",
          desc = "Balanced rounded tiles with power strips, role icons, and dispels for 20-man raids.",
          bestFor = "20-Man Raiding, All-Rounder",
          settings = {
              width = 76, height = 32, spacing = 3, groupSpacing = 8, slant = false,
              showPower = true, powerHeight = 4, namePos = "bar", nameAlign = "center",
              showPercent = false, showRole = true, predictHeals = true, predictAbsorbs = true,
              showThreat = true, showDispel = true, ["media.health"] = "daylight",
              ["shell.own"] = true, ["shell.borderPx"] = 2, ["shell.cornerPx"] = 5, ["shell.shadowPx"] = 3,
          } },
        { id = "tight", name = "Tight Raid Grid",
          desc = "Dense 64x24 cells with 1px gaps and no power bars to fit 40-man rosters cleanly.",
          bestFor = "40-Man Raiding, DPS",
          settings = {
              width = 64, height = 24, spacing = 1, groupSpacing = 4, slant = false,
              showPower = false, powerHeight = 0, namePos = "bar", nameAlign = "center",
              showPercent = false, showRole = false, predictHeals = true, predictAbsorbs = false,
              showThreat = true, showDispel = true, ["media.health"] = "daylight",
              ["shell.own"] = true, ["shell.borderPx"] = 1, ["shell.cornerPx"] = 0, ["shell.shadowPx"] = 0,
          } },
        { id = "matte", name = "Vertical Healer",
          desc = "Tall 72x42 silk cells with % HP, absorbs, and dispel alerts built for raid triage.",
          bestFor = "Raid Healing, Dispel Triage",
          settings = {
              width = 72, height = 42, spacing = 2, groupSpacing = 6, slant = false,
              showPower = true, powerHeight = 4, namePos = "bar", nameAlign = "center",
              showPercent = true, showRole = true, predictHeals = true, predictAbsorbs = true,
              showThreat = true, showDispel = true, ["media.health"] = "silk",
              ["shell.own"] = true, ["shell.borderPx"] = 1, ["shell.cornerPx"] = 2, ["shell.shadowPx"] = 2,
          } },
        { id = "framed", name = "Sculpted Plates",
          desc = "Wide slanted plates with brushed texture and thick borders for high-contrast reads.",
          bestFor = "Tanking, Raid Leaders",
          settings = {
              width = 86, height = 34, spacing = 4, groupSpacing = 10, slant = true,
              showPower = true, powerHeight = 5, namePos = "bar", nameAlign = "left",
              showPercent = true, showRole = true, predictHeals = true, predictAbsorbs = true,
              showThreat = true, showDispel = true, ["media.health"] = "brushed",
              ["shell.own"] = true, ["shell.borderPx"] = 3, ["shell.cornerPx"] = 4, ["shell.shadowPx"] = 5,
          } },
    },
    castbars = {
        { id = "matte", name = "Clean Matte",
          desc = "Flat 16px iconless bar with zero FX for distraction-free spell timing.",
          bestFor = "Minimalists, Raiding",
          settings = {
              height = 16, slant = false, showIcon = false, ["media.bar"] = "matte",
              ["barFx.style"] = "none", ["barFx.speed"] = 1.0, ["barFx.strength"] = 0.5, ["barFx.colors"] = "bar",
              ["shell.own"] = true, ["shell.borderPx"] = 1, ["shell.cornerPx"] = 0, ["shell.shadowPx"] = 0,
          } },
        { id = "silk", name = "Silk Sheen",
          desc = "Smooth 18px slanted bar with spell icon and rounded ends for clear cast reads.",
          bestFor = "All-Rounder, Healing",
          settings = {
              height = 18, slant = true, showIcon = true, ["media.bar"] = "silk",
              ["barFx.style"] = "none", ["barFx.speed"] = 1.0, ["barFx.strength"] = 0.6, ["barFx.colors"] = "bar",
              ["shell.own"] = true, ["shell.borderPx"] = 2, ["shell.cornerPx"] = 8, ["shell.shadowPx"] = 3,
          } },
        { id = "brushed", name = "Brushed Metal",
          desc = "Tall 26px squared bar with heavy border and icon so enemy interrupts never blend in.",
          bestFor = "Tanking, Interrupt Tracking",
          settings = {
              height = 26, slant = false, showIcon = true, ["media.bar"] = "brushed",
              ["barFx.style"] = "none", ["barFx.speed"] = 1.0, ["barFx.strength"] = 0.6, ["barFx.colors"] = "bar",
              ["shell.own"] = true, ["shell.borderPx"] = 4, ["shell.cornerPx"] = 2, ["shell.shadowPx"] = 6,
          } },
        { id = "flow", name = "Living Flow",
          desc = "Slanted 22px tube bar with animated liquid flow to spotlight active channel/cast pace.",
          bestFor = "Casters, Solo & Dungeons",
          settings = {
              height = 22, slant = true, showIcon = true, ["media.bar"] = "tube",
              ["barFx.style"] = "flow", ["barFx.speed"] = 1.0, ["barFx.strength"] = 0.9, ["barFx.colors"] = "accent",
              ["shell.own"] = true, ["shell.borderPx"] = 2, ["shell.cornerPx"] = 6, ["shell.shadowPx"] = 4,
          } },
        { id = "tide", name = "Tidal Glass",
          desc = "Slim 15px iconless glass strip with gentle wave motion for compact cast tracking.",
          bestFor = "DPS, Minimalists",
          settings = {
              height = 15, slant = true, showIcon = false, ["media.bar"] = "glass",
              ["barFx.style"] = "tide", ["barFx.speed"] = 0.9, ["barFx.strength"] = 0.7, ["barFx.colors"] = "bar",
              ["shell.own"] = true, ["shell.borderPx"] = 1, ["shell.cornerPx"] = 4, ["shell.shadowPx"] = 2,
          } },
        { id = "molten", name = "Molten Ember",
          desc = "Bold 28px slanted bar with rising ember FX and thick rim for high-urgency casts.",
          bestFor = "Interrupt Tracking, PvP & Dungeons",
          settings = {
              height = 28, slant = true, showIcon = true, ["media.bar"] = "grain",
              ["barFx.style"] = "embers", ["barFx.speed"] = 1.15, ["barFx.strength"] = 1.1, ["barFx.colors"] = "accent",
              ["shell.own"] = true, ["shell.borderPx"] = 4, ["shell.cornerPx"] = 4, ["shell.shadowPx"] = 6,
          } },
    },
    actionbars = {
        { id = "classic", name = "Daylight Classic",
          desc = "Rounded square buttons with 2px border and soft shadow for clear keybind separation.",
          bestFor = "All-Rounder, Dungeons & Questing",
          settings = {
              ["look.shape"] = "square", ["look.borderStyle"] = "daylight", ["look.border"] = 2,
              ["look.corners"] = "round", ["look.shadow"] = true, ["look.zoom"] = 0.06,
          } },
        { id = "flat", name = "Crisp Flat",
          desc = "Sharp 90° buttons with 1px flat border and zero shadow for tight multi-bar grids.",
          bestFor = "Raiding, Minimalists",
          settings = {
              ["look.shape"] = "square", ["look.borderStyle"] = "flat", ["look.border"] = 1,
              ["look.corners"] = "square", ["look.shadow"] = false, ["look.zoom"] = 0.08,
          } },
        { id = "borderless", name = "Borderless Zoom",
          desc = "Border-free icons cropped tight with drop shadow so spell art reads at small scales.",
          bestFor = "DPS, High-Density Bars",
          settings = {
              ["look.shape"] = "square", ["look.borderStyle"] = "none", ["look.border"] = 1,
              ["look.corners"] = "round", ["look.shadow"] = true, ["look.zoom"] = 0.14,
          } },
        { id = "heavy", name = "Heavy Rim",
          desc = "Chunky 4px square borders with shadow to anchor key cooldowns in peripheral vision.",
          bestFor = "Tanking, Classic Feel",
          settings = {
              ["look.shape"] = "square", ["look.borderStyle"] = "daylight", ["look.border"] = 4,
              ["look.corners"] = "square", ["look.shadow"] = true, ["look.zoom"] = 0.04,
          } },
        { id = "circle", name = "Rounded Medallion",
          desc = "Circular masked buttons with 2px ring to soften bar edges and spotlight proc glows.",
          bestFor = "Healing, Casters",
          settings = {
              ["look.shape"] = "circle", ["look.borderStyle"] = "daylight", ["look.border"] = 2,
              ["look.corners"] = "round", ["look.shadow"] = true, ["look.zoom"] = 0.12,
          } },
        { id = "shield", name = "Shield Crest",
          desc = "Heraldic shield-shaped buttons with 2px rim for bold class-fantasy bar presence.",
          bestFor = "Tanking, Solo & Group Questing",
          settings = {
              ["look.shape"] = "shield", ["look.borderStyle"] = "daylight", ["look.border"] = 2,
              ["look.corners"] = "round", ["look.shadow"] = true, ["look.zoom"] = 0.10,
          } },
    },
}
ns.extraLooks = EXTRA_LOOKS

local GLYPH = { 0.78, 0.72, 0.62, 1 }

local function edge(x, y, w, h)
    return { x, y, w, h, GLYPH[1], GLYPH[2], GLYPH[3], GLYPH[4] }
end

local function addEdge(list, x, y, w, h)
    list[#list + 1] = edge(x, y, w, h)
end

local function addBox(list, x, y, w, h)
    addEdge(list, x, y, w, 1)
    addEdge(list, x, y + h - 1, w, 1)
    addEdge(list, x, y, 1, h)
    addEdge(list, x + w - 1, y, 1, h)
end

local ICONS = {
    flagon = {}, trestle = {}, beam = {}, stream = {}, ledger = {}, crest = {}, slate = {},
}

-- Flagon: a small boss at the cup, the name on the lip.
addBox(ICONS.flagon, 1, 6, 7, 7)
addBox(ICONS.flagon, 10, 3, 24, 12)
addEdge(ICONS.flagon, 13, 6, 10, 1)
-- Trestle: a full portrait, a name row, a bar and a hung rail.
addBox(ICONS.trestle, 1, 2, 13, 13)
addEdge(ICONS.trestle, 17, 3, 16, 1)
addBox(ICONS.trestle, 17, 6, 17, 6)
addEdge(ICONS.trestle, 17, 14, 17, 2)
-- Beam: an angled socket and a full-width tab over a sturdy bar.
addBox(ICONS.beam, 1, 4, 10, 10)
addEdge(ICONS.beam, 11, 6, 1, 6)
addBox(ICONS.beam, 13, 2, 21, 4)
addBox(ICONS.beam, 13, 6, 21, 9)
-- Stream: a round portrait, a floating row, a slim bar and an underline.
addBox(ICONS.stream, 1, 3, 11, 11)
addEdge(ICONS.stream, 15, 3, 14, 1)
addBox(ICONS.stream, 15, 6, 19, 6)
addEdge(ICONS.stream, 15, 14, 19, 1)
-- Ledger: no portrait, a name above and a square bar split for health and power.
addEdge(ICONS.ledger, 9, 2, 18, 1)
addBox(ICONS.ledger, 1, 5, 34, 10)
addEdge(ICONS.ledger, 2, 10, 32, 1)
-- Crest: a thick ringed portrait, a fitted tab and a tall bar.
addBox(ICONS.crest, 1, 1, 15, 15)
addBox(ICONS.crest, 3, 3, 11, 11)
addBox(ICONS.crest, 18, 2, 12, 4)
addBox(ICONS.crest, 18, 6, 16, 9)
-- Slate: no portrait, a floating row, a low bar and a thin strip.
addEdge(ICONS.slate, 1, 4, 20, 1)
addBox(ICONS.slate, 1, 6, 34, 5)
addEdge(ICONS.slate, 1, 13, 34, 2)

ns.frameIcons = ICONS

local ORDER = {}
for i = 1, #FRAMES do ORDER[#ORDER + 1] = FRAMES[i] end
for i = 1, #THEMES do ORDER[#ORDER + 1] = THEMES[i] end

local view
local refreshers = {}
local looksPending

local THEME_INTRO = "Each preset is a ready-made pairing of a Colours palette with a frame look. Pick one, then change either part on the Colours or Looks tab."
local LOOKS_INTRO = "A Preset on the Presets tab sets both."
local PAGE_NOTE = "Starts off on first login · /looks"
local FRAME_HEAD = "Frame looks"
local THEME_HEAD = "PRESETS"

local CREAM = { 0.95, 0.91, 0.86, 1 }
local DIM = { 0.62, 0.56, 0.48, 1 }
local ON_INK = { 0.93, 0.84, 0.68, 1 }
local CHIP_EDGE = { 0.45, 0.38, 0.30, 1 }
local CHIP_FILL = { 0.16, 0.15, 0.14, 1 }
local BOX_EDGE = { 0.55, 0.50, 0.44, 1 }
local BOX_FILL = { 0.10, 0.10, 0.11, 1 }
local BOX_ON = { 0.62, 0.52, 0.36, 1 }
local ROW_REST = { 0.208, 0.169, 0.141, 1 }
local ROW_HOVER = { 0.243, 0.184, 0.141, 1 }
local ROW_PICK = { 0.357, 0.255, 0.141, 1 }
local HINT_EDGE = { 0.35, 0.32, 0.28, 1 }
local CARD_EDGE = { 0.16, 0.16, 0.19, 1 }
local CARD_FILL = { 0.12, 0.12, 0.14, 1 }

local INTRO_H = 28
local THEME_H = 54
local PRESET_HEAD_H = 18
local PRESET_H = 88
local STYLE_H = 26
local HEAD_H = 18
local HINT_H = 26

local function say(text)
    local frame = DEFAULT_CHAT_FRAME
    if type(frame) == "table" and type(frame.AddMessage) == "function" then
        frame:AddMessage(text)
    elseif type(print) == "function" then
        print(text)
    end
end

local function trim(text)
    if type(text) ~= "string" then return "" end
    return (string.gsub(text, "^%s*(.-)%s*$", "%1"))
end

local function frameById(id)
    for i = 1, #FRAMES do
        if FRAMES[i].id == id then return FRAMES[i] end
    end
end

-- A retired frame id (lintel, sill, stamp, signboard, trough) names its replacement.
local function resolveFrame(id)
    if type(id) ~= "string" then return nil end
    if type(ns.canonicalFrame) == "function" then id = ns.canonicalFrame(id) end
    if frameById(id) then return id end
end

function ns.resolveFrame(id)
    return resolveFrame(id)
end

local function themeById(id)
    for i = 1, #THEMES do
        if THEMES[i].id == id then return THEMES[i] end
    end
end

local function partLabel(kind, id)
    if type(id) ~= "string" or id == "" or id == "none" then return "—" end
    local row
    if kind == "palette" then
        row = type(ns.byId) == "table" and ns.byId[id] or nil
    elseif kind == "frame" then
        row = frameById(id)
    end
    if type(row) == "table" and type(row.name) == "string" and row.name ~= "" then return row.name end
    return "—"
end

local function themePills(theme)
    return partLabel("palette", theme.palette), partLabel("frame", theme.frame)
end

function ns.frameById(id)
    return frameById(id)
end

function ns.themeById(id)
    return themeById(id)
end


local function joinOr(list)
    if #list == 0 then return "" end
    if #list == 1 then return list[1] end
    local head = {}
    for i = 1, #list - 1 do head[i] = list[i] end
    return table.concat(head, ", ") .. ", or " .. list[#list]
end

local function looksId(key)
    local prefix = "Looks:"
    if type(key) ~= "string" or string.sub(key, 1, #prefix) ~= prefix then return nil end
    return string.sub(key, #prefix + 1)
end

local function apiOf()
    local d = DaylightUI
    local api = type(d) == "table" and d.API
    if type(api) == "table" then return api end
end

function ns.looksApiOk()
    local api = apiOf()
    return type(api) == "table" and api.major == 1 and type(api.minor) == "number" and api.minor >= 9
end

local function inCombat()
    return type(InCombatLockdown) == "function" and InCombatLockdown() == true
end

local function looksAddonLoaded()
    if type(C_AddOns) == "table" and type(C_AddOns.IsAddOnLoaded) == "function" then
        local ok, loaded = pcall(C_AddOns.IsAddOnLoaded, "Looks")
        if ok and loaded then return true end
    end
    if type(IsAddOnLoaded) == "function" then
        local ok, loaded = pcall(IsAddOnLoaded, "Looks")
        if ok and loaded then return true end
    end
    return false
end

local function copyValues(values)
    if type(values) ~= "table" then return nil end
    local out, any = {}, false
    for key, value in pairs(values) do
        local kind = type(value)
        if type(key) == "string" and (kind == "number" or kind == "string" or kind == "boolean") then
            out[key] = value
            any = true
        end
    end
    if any then return out end
end

-- The restore snapshot: glow, outline, and every frame value Palettes may write.
-- 0.4.2 also saved the frame style string. Nothing writes look.style now, so it is dropped.
local function copyShot(shot)
    if type(shot) ~= "table" then return nil end
    return {
        glow = type(shot.glow) == "string" and shot.glow or nil,
        light = type(shot.light) == "string" and shot.light or nil,
        frameValues = copyValues(shot.frameValues),
        extraUnitValues = copyValues(shot.extraUnitValues),
        actionBarValues = copyValues(shot.actionBarValues),
    }
end
ns.copyLooksShot = copyShot

local function readSnapshot()
    local account = type(ns.accountTable) == "function" and ns.accountTable() or nil
    local char = type(ns.charTable) == "function" and ns.charTable() or nil
    if type(char) == "table" and char.only == true then
        if type(char.looks) == "table" then return char.looks end
        return nil
    end
    if type(account) == "table" and type(account.looks) == "table" then return account.looks end
    return nil
end

local function storeSnapshot(shot)
    local account = type(ns.accountTable) == "function" and ns.accountTable() or nil
    local char = type(ns.charTable) == "function" and ns.charTable() or nil
    local stored = shot == false and false or copyShot(shot)
    if stored == nil then stored = false end
    if type(char) == "table" and char.only == true then
        char.looks = stored
    elseif type(account) == "table" then
        account.looks = stored
        if type(char) == "table" then char.looks = nil end
    end
    local d = DaylightUI
    if type(d) == "table" and type(d.Set) == "function" then
        ns.writingLooks = true
        pcall(d.Set, d, "Palettes", "looks", stored)
        ns.writingLooks = false
    end
end

function ns.takeLooks(account, char, db, hadLook, onlyOn)
    if type(db) ~= "table" then return end
    local function slotShot()
        local src
        if onlyOn and type(char) == "table" then src = char.looks
        elseif type(account) == "table" then src = account.looks end
        if src == false then return false end
        if type(src) == "table" then return copyShot(src) end
        return nil
    end
    local function writeSlot(value)
        if onlyOn and type(char) == "table" then
            char.looks = value
        elseif type(account) == "table" then
            account.looks = value
            if type(char) == "table" then char.looks = nil end
        end
    end
    if not hadLook then
        db.looks = slotShot()
        return
    end
    if type(db.looks) == "table" then
        writeSlot(copyShot(db.looks))
    elseif db.looks == false then
        writeSlot(false)
    end
end

function ns.adoptLooksSetting(value)
    local account = type(ns.accountTable) == "function" and ns.accountTable() or nil
    local char = type(ns.charTable) == "function" and ns.charTable() or nil
    local stored
    if type(value) == "table" then stored = copyShot(value)
    elseif value == false then stored = false
    else return end
    if type(char) == "table" and char.only == true then
        char.looks = stored
    elseif type(account) == "table" then
        account.looks = stored
    end
end

local function readSetting(scope, path)
    local d = DaylightUI
    if type(d) ~= "table" or type(d.Get) ~= "function" then return nil, false end
    local ok, value = pcall(d.Get, d, scope, path)
    if not ok then return nil, false end
    return value, true
end

-- Every frame write goes through DaylightUI.Batch, so the frames repaint once,
-- and suppresses per-key OptionsPanel.Refresh storms fired by SettingChanged.
local function batch(fn)
    local function run()
        local d = DaylightUI
        if type(d) == "table" and type(d.Batch) == "function" then
            return pcall(d.Batch, fn)
        end
        return pcall(fn)
    end
    if type(ns.withSuppressedPanelRefresh) == "function" then
        local ok, res
        ns.withSuppressedPanelRefresh(function()
            ok, res = run()
        end)
        return ok, res
    end
    return run()
end

local function readValues(keys, into)
    for i = 1, #keys do
        local value, ok = readSetting("UnitFrames", keys[i])
        local kind = type(value)
        if ok and (kind == "number" or kind == "string" or kind == "boolean") then
            into[keys[i]] = value
        end
    end
    return into
end

-- The live value of every key Palettes may write: the look keys, both sizes
-- sets and the Flagon extras. Nothing else is read.
local function readFrameValues()
    local d = DaylightUI
    if type(d) ~= "table" or type(d.Get) ~= "function" then return nil end
    local values = readValues(FRAME_KEYS, {})
    readValues(SIZE_KEYS, values)
    readValues(EXTRA_KEYS, values)
    if next(values) == nil then return nil end
    return values
end

local function writePairs(list)
    local d = DaylightUI
    if type(d) ~= "table" or type(d.Set) ~= "function" then return false end
    local failed = false
    local ran = batch(function()
        for i = 1, #list do
            local ok, result = pcall(d.Set, d, "UnitFrames", list[i][1], list[i][2])
            if not ok or result == false then failed = true end
        end
    end)
    return ran and not failed
end

-- Sizes first, then the live keys. A style swap copies sizes.<style> over the
-- live heights, so both sets carry the same numbers.
local function lookPairs(id)
    local values = FRAME_VALUES[id]
    local list = {}
    local sizes = SIZE_BY_LOOK[id]
    for i = 1, #sizes do list[#list + 1] = { sizes[i], values[sizes[i]] } end
    for i = 1, #FRAME_KEYS do list[#list + 1] = { FRAME_KEYS[i], values[FRAME_KEYS[i]] } end
    return list
end

-- Flagon writes the extras. Any other look puts back the ones Flagon left on
-- the frames, from the saved values. A key the player changed since stays theirs.
local function extraPairs(id, saved)
    local list = {}
    if id == "flagon" then
        for i = 1, #EXTRA_KEYS do list[#list + 1] = { EXTRA_KEYS[i], EXTRA_VALUES[EXTRA_KEYS[i]] } end
        return list
    end
    if type(saved) ~= "table" then return list end
    for i = 1, #EXTRA_KEYS do
        local key = EXTRA_KEYS[i]
        local was = saved[key]
        if was ~= nil and was ~= EXTRA_VALUES[key] and readSetting("UnitFrames", key) == EXTRA_VALUES[key] then
            list[#list + 1] = { key, was }
        end
    end
    return list
end

local function writeFrameValues(values)
    if type(values) ~= "table" then return true end
    local list = {}
    local sets = { SIZE_KEYS, FRAME_KEYS, EXTRA_KEYS }
    for s = 1, #sets do
        for i = 1, #sets[s] do
            local key = sets[s][i]
            if values[key] ~= nil then list[#list + 1] = { key, values[key] } end
        end
    end
    return writePairs(list)
end

local function samePairs(values, keys)
    for i = 1, #keys do
        local value, ok = readSetting("UnitFrames", keys[i])
        if not ok or value ~= values[keys[i]] then return false end
    end
    return true
end

-- The look whose keys are all on the player and target frames, or nothing
-- when any one has been changed.
local function wornFrame()
    local d = DaylightUI
    if type(d) ~= "table" or type(d.Get) ~= "function" then return nil end
    for i = 1, #FRAMES do
        local id = FRAMES[i].id
        local values = FRAME_VALUES[id]
        if samePairs(values, FRAME_KEYS) and samePairs(values, SIZE_BY_LOOK[id]) then
            return id, FRAMES[i].name
        end
    end
end

function ns.frameKeys()
    local out = {}
    for i = 1, #FRAME_KEYS do out[i] = FRAME_KEYS[i] end
    return out
end

function ns.frameValues(id)
    id = resolveFrame(id)
    if not id then return nil end
    local out = {}
    for key, value in pairs(FRAME_VALUES[id]) do out[key] = value end
    return out
end

function ns.frameExtras()
    local out = {}
    for i = 1, #EXTRA_KEYS do out[EXTRA_KEYS[i]] = EXTRA_VALUES[EXTRA_KEYS[i]] end
    return out
end

function ns.frameSizeKeys()
    local out = {}
    for i = 1, #SIZE_KEYS do out[i] = SIZE_KEYS[i] end
    return out
end

local function hintLine(name, omit)
    local names = {}
    for i = 1, #ORDER do
        if not omit[ORDER[i].id] then names[#names + 1] = ORDER[i].id end
    end
    names[#names + 1] = "off"
    if name then
        return "Looks: " .. name .. " is on. Type /looks " .. joinOr(names) .. "."
    end
    return "Looks: off. Type /looks " .. joinOr(names) .. "."
end

local function statusLine()
    local themeId, changed, pending = nil, false, false
    if type(ns.shownTheme) == "function" then
        themeId, changed, pending = ns.shownTheme()
    end
    if pending and themeId then
        local theme = themeById(themeId)
        return "Looks: " .. (theme and theme.name or themeId) .. " queued until combat ends."
    end
    local id, name = wornFrame()
    local omit = {}
    if themeId then
        local theme = themeById(themeId)
        name = theme and theme.name or themeId
        if changed then name = name .. " (changed)" end
        omit[themeId] = true
    end
    if id then omit[id] = true end
    return hintLine(name, omit)
end

local function allowedWrite(scope, path)
    if scope == "general" and path == "buttonGlow" then return true end
    if scope == "Nameplates" and path == "targetLight" then return true end
    return false
end

local function readKnown(scope, path)
    local value, ok = readSetting(scope, path)
    if ok and value ~= nil then return value, true end
    local api = apiOf()
    if api and type(api.GetSetting) == "function" then
        local gotOk, got = pcall(api.GetSetting, scope, path)
        if gotOk and got ~= nil then return got, true end
    end
    return nil, false
end

-- Parts of the restore snapshot Palettes has not saved yet. Saved once, just
-- before the first frame change, so Reset Looks only puts back what Palettes changed.
local function captureMissing(frames)
    local have = readSnapshot()
    if type(have) ~= "table" then have = {} end
    if frames and have.frameValues == nil then
        local values = readFrameValues()
        if values then return { frameValues = values } end
    end
end

local function mergeSnapshot(add)
    local out = copyShot(readSnapshot()) or {}
    if type(add) == "table" then
        if add.glow ~= nil then out.glow = add.glow end
        if add.light ~= nil then out.light = add.light end
        if add.frameValues ~= nil then out.frameValues = add.frameValues end
        if type(add.extraUnitValues) == "table" then
            out.extraUnitValues = out.extraUnitValues or {}
            for k, v in pairs(add.extraUnitValues) do
                if out.extraUnitValues[k] == nil then out.extraUnitValues[k] = v end
            end
        end
        if type(add.actionBarValues) == "table" then
            out.actionBarValues = out.actionBarValues or {}
            for k, v in pairs(add.actionBarValues) do
                if out.actionBarValues[k] == nil then out.actionBarValues[k] = v end
            end
        end
    end
    storeSnapshot(out)
end

local function extraLookById(catKey, id)
    local list = EXTRA_LOOKS[catKey]
    if type(list) ~= "table" or type(id) ~= "string" then return nil end
    for i = 1, #list do
        if list[i].id == id then return list[i] end
    end
end

function ns.extraLookById(catKey, id)
    return extraLookById(catKey, id)
end

function ns.categoryLookName(catKey, id)
    if catKey == "player_target" then
        local f = frameById(id)
        return f and f.name or (type(id) == "string" and id or "Daylight")
    end
    local opt = extraLookById(catKey, id)
    return opt and opt.name or (type(id) == "string" and id or "Daylight")
end

local function matchFocusSettings(ptId)
    local spec = LOOK_SPECS[resolveFrame(ptId) or wornFrame() or "beam"] or LOOK_SPECS.beam
    return {
        style = spec.style,
        width = math.max(150, math.floor(spec.width * 0.85)),
        height = math.max(18, math.floor(spec.height * 0.72)),
        powerHeight = math.max(3, math.floor(spec.powerHeight * 0.65)),
        ribbonGap = spec.ribbonGap,
        tabHeight = math.max(13, spec.tabHeight - 2),
        slant = spec.slant,
        portrait = spec.portrait,
        portraitLook = spec.portraitLook,
        portraitShape = spec.portraitShape,
        portraitRing = spec.ring,
        portraitRingWidth = spec.ringWidth,
        portraitScale = math.max(0.75, spec.scale * 0.9),
        nameOnBar = spec.nameOnBar,
        namePos = spec.namePos,
        bigNumber = false,
        showPower = true,
        showPowerText = false,
        showLevel = false,
        ["tab.own"] = true,
        ["tab.width"] = spec.tabWidth,
        ["tab.slant"] = spec.tabSlant,
        ["tab.cornerPx"] = spec.tabCorner,
        ["tab.shadowPx"] = spec.tabShadow,
        ["shell.own"] = true,
        ["shell.borderPx"] = math.max(1, math.floor(spec.border * 0.65)),
        ["shell.cornerPx"] = spec.corner,
        ["shell.shadowPx"] = spec.shadow,
    }
end

local function matchTotSettings(ptId)
    local spec = LOOK_SPECS[resolveFrame(ptId) or wornFrame() or "beam"] or LOOK_SPECS.beam
    return {
        width = 116,
        height = 20,
        slant = spec.slant,
        showPower = false,
        powerHeight = 4,
        portrait = "none",
        namePos = "bar",
        showPercent = true,
        ["shell.own"] = true,
        ["shell.borderPx"] = math.max(1, math.floor(spec.border * 0.5)),
        ["shell.cornerPx"] = spec.corner,
        ["shell.shadowPx"] = math.max(0, math.floor(spec.shadow * 0.75)),
    }
end

local function categoryPairs(catKey, optId, activePT)
    local list = {}
    if catKey == "player_target" then
        local fid = resolveFrame(optId)
        if not fid then return list end
        local pairsList = lookPairs(fid)
        for i = 1, #pairsList do
            list[#list + 1] = { "UnitFrames", pairsList[i][1], pairsList[i][2] }
        end
        return list
    end
    local opt = extraLookById(catKey, optId)
    if not opt then return list end
    local settings = opt.settings
    if opt.isMatch then
        if catKey == "focus" then settings = matchFocusSettings(activePT)
        elseif catKey == "tot" then settings = matchTotSettings(activePT) end
    end
    if type(settings) ~= "table" then return list end
    if catKey == "actionbars" then
        for k, v in pairs(settings) do
            list[#list + 1] = { "ActionBars", k, v }
        end
    elseif catKey == "castbars" then
        for u = 1, #CASTBAR_UNITS do
            local unit = CASTBAR_UNITS[u]
            for k, v in pairs(settings) do
                local val = v
                if unit == "partyCastbar" and k == "height" and type(v) == "number" then
                    val = math.min(14, v)
                end
                list[#list + 1] = { "UnitFrames", unit .. "." .. k, val }
            end
        end
    else
        local prefix = catKey == "tot" and "targettarget" or catKey
        for k, v in pairs(settings) do
            list[#list + 1] = { "UnitFrames", prefix .. "." .. k, v }
        end
    end
    return list
end

local function writeScopedPairs(list)
    local d = DaylightUI
    if type(d) ~= "table" or type(d.Set) ~= "function" then return false end
    local failed = false
    local ran = batch(function()
        for i = 1, #list do
            local ok, res = pcall(d.Set, d, list[i][1], list[i][2], list[i][3])
            if not ok or res == false then failed = true end
        end
    end)
    return ran and not failed
end

local function captureExtraForPairs(list)
    local addUnit, addAB = {}, {}
    local anyU, anyA = false, false
    for i = 1, #list do
        local scope, path = list[i][1], list[i][2]
        local val, ok = readSetting(scope, path)
        local kind = type(val)
        if ok and (kind == "number" or kind == "string" or kind == "boolean") then
            if scope == "UnitFrames" then
                addUnit[path] = val
                anyU = true
            elseif scope == "ActionBars" then
                addAB[path] = val
                anyA = true
            end
        end
    end
    if anyU or anyA then
        mergeSnapshot({
            extraUnitValues = anyU and addUnit or nil,
            actionBarValues = anyA and addAB or nil,
        })
    end
end


local function hasWrite()
    local d = DaylightUI
    return type(d) == "table" and type(d.Set) == "function"
end

local function writeSetting(scope, path, value)
    if not allowedWrite(scope, path) then return false end
    local d = DaylightUI
    if type(d) ~= "table" or type(d.Set) ~= "function" then return false end
    local ok, result = pcall(d.Set, d, scope, path, value)
    if not ok or result == false then return false end
    local got, readable = readSetting(scope, path)
    if readable and got ~= value then return false end
    return true
end

local function refreshPage()
    local d = DaylightUI
    local panel = type(d) == "table" and d.OptionsPanel
    if type(panel) ~= "table" or type(panel.Refresh) ~= "function" then return end
    pcall(panel.Refresh, panel)
end

local function refreshLooks()
    for i = 1, #refreshers do pcall(refreshers[i]) end
end
ns.refreshLooks = refreshLooks

local function pointAtGlowValue(value)
    if type(value) ~= "string" or value == "" or value == "none" then
        say("Looks: pick none in the glow menu.")
        return
    end
    local id = looksId(value)
    if id then
        say("Looks: pick " .. id .. " in the glow menu.")
        return
    end
    say("Looks: pick " .. value .. " in the glow menu.")
end

-- Frame look preview. A pick on the Looks tab shows on the player and target
-- frames at once and writes nothing saved. BeginPreview(id) shows a look,
-- RevertPreview() puts the saved values back, and CommitPreview(write) reverts,
-- then runs the real write. Which frames wear it, and how, is the backend's
-- job: apply(id, targets) returns a token, revert(token) undoes it. A new unit
-- frame implementation plugs in through ns.SetPreviewBackend.
local previewTargets = { "player", "target" }
local previewBackend
local previewShown
local previewWant
local previewWarned
local looksOpen = false

-- Override holds a value for a while: never saved, and API.Off puts it back.
local function overrideHost()
    if type(view) == "table" and type(view.Override) == "function" then return view end
    local api = apiOf()
    if api and type(api.For) == "function" then
        local ok, host = pcall(api.For, "Palettes")
        if ok and type(host) == "table" and type(host.Override) == "function" then return host end
    end
end

-- Only the player and target frames, and only their look keys. look.style and
-- every other frame stay as they are.
local function previewPairs(id, targets)
    local want = {}
    for i = 1, #targets do
        if targets[i] == "player" or targets[i] == "target" then
            want[targets[i] .. "."] = true
            want[targets[i] .. "Text."] = true
        end
    end
    local all = lookPairs(id)
    if id == "flagon" then
        local extras = extraPairs(id)
        for i = 1, #extras do all[#all + 1] = extras[i] end
    end
    local list = {}
    for i = 1, #all do
        local prefix = string.match(all[i][1], "^(%a+%.)")
        if prefix and want[prefix] then list[#list + 1] = all[i] end
    end
    return list
end

local previewBackendDefault = {
    apply = function(id, targets)
        local host = overrideHost()
        if not host then return nil end
        local list = previewPairs(id, targets)
        local handles = {}
        batch(function()
            for i = 1, #list do
                local ok, handle = pcall(host.Override, "UnitFrames", list[i][1], list[i][2])
                if ok and type(handle) == "table" then handles[#handles + 1] = handle end
            end
        end)
        if #handles > 0 then return handles end
    end,
    revert = function(handles)
        local api = apiOf()
        if not api or type(api.Off) ~= "function" or type(handles) ~= "table" then return end
        batch(function()
            for i = #handles, 1, -1 do pcall(api.Off, handles[i]) end
        end)
    end,
}

-- Protected frames repaint after combat, so a change asked for in combat waits
-- here and runs from ns.finishLooksCombat.
local function previewSync()
    if inCombat() then return end
    local want = previewWant
    if previewShown and previewShown.id ~= want then
        pcall(previewShown.backend.revert, previewShown.token)
        previewShown = nil
    end
    if want and not previewShown then
        local backend = previewBackend or previewBackendDefault
        local ok, token = pcall(backend.apply, want, previewTargets)
        if ok and token then
            previewShown = { id = want, token = token, backend = backend }
        elseif not previewWarned then
            previewWarned = true
            say("Looks: can't preview on the unit frames right now. Apply still works.")
        end
    end
end

function ns.BeginPreview(id)
    if not frameById(id) then return false end
    previewWant = id
    previewSync()
    return true
end

local extraPreviewHandles = nil
local extraPreviewKey = nil

local function revertExtraPreview()
    extraPreviewKey = nil
    if type(extraPreviewHandles) ~= "table" then return end
    local api = apiOf()
    if api and type(api.Off) == "function" then
        batch(function()
            for i = #extraPreviewHandles, 1, -1 do
                pcall(api.Off, extraPreviewHandles[i])
            end
        end)
    end
    extraPreviewHandles = nil
end

local function beginExtraPairs(key, pairsList)
    if key ~= nil and extraPreviewKey == key then return end
    revertExtraPreview()
    if inCombat() or type(pairsList) ~= "table" or #pairsList == 0 then return end
    local host = overrideHost()
    if not host then return end
    local handles = {}
    batch(function()
        for i = 1, #pairsList do
            local scope, path, val = pairsList[i][1], pairsList[i][2], pairsList[i][3]
            local cur, okCur = readSetting(scope, path)
            if not okCur or cur ~= val then
                local ok, handle = pcall(host.Override, scope, path, val)
                if ok and type(handle) == "table" then handles[#handles + 1] = handle end
            end
        end
    end)
    extraPreviewKey = key
    if #handles > 0 then extraPreviewHandles = handles end
end

local function previewPairsForCategory(catKey, optId, activePT)
    if catKey == "castbars" then
        -- Preview playerCastbar only so switching cast bar looks stays instant.
        local opt = extraLookById("castbars", optId)
        local list = {}
        if opt and type(opt.settings) == "table" then
            for k, v in pairs(opt.settings) do
                list[#list + 1] = { "UnitFrames", "playerCastbar." .. k, v }
            end
        end
        return list
    end
    return categoryPairs(catKey, optId, activePT)
end

function ns.RevertPreview()
    previewWant = nil
    previewSync()
    revertExtraPreview()
end

function ns.CommitPreview(write)
    previewWant = nil
    previewSync()
    revertExtraPreview()
    if type(write) == "function" then return write() end
end

function ns.SetPreviewBackend(backend, targets)
    ns.RevertPreview()
    if type(backend) == "table" and type(backend.apply) == "function" and type(backend.revert) == "function" then
        previewBackend = backend
    else
        previewBackend = nil
    end
    if type(targets) == "table" then previewTargets = targets end
end

function ns.previewShownId()
    return previewShown and previewShown.id or nil
end

function ns.themePaletteId(id)
    local theme = themeById(id)
    return theme and theme.palette or nil
end

-- The staged frame, category look, or preset pick is what shows while Palettes is open.
-- Resolves multi-layer staged drafts (Preset + Colour/Look overrides) for the active Preview Deck mode.
function ns.syncFramePreview()
    local staged = ns.staged
    if looksOpen and type(staged) == "table" then
        local deckMode = type(ns.getPreviewDeckMode) == "function" and ns.getPreviewDeckMode() or "player_target"
        local baseTheme = (staged.baseKind == "theme" or staged.kind == "theme") and themeById(staged.baseId or staged.id) or nil
        local baseRec = (staged.baseKind == "mypreset" or staged.kind == "mypreset") and type(staged.recipe) == "table" and staged.recipe or nil

        local effFrame = staged.frame
            or (staged.kind == "frame" and staged.id)
            or (baseTheme and baseTheme.frame)
            or (baseRec and baseRec.frame)

        if deckMode == "player_target" then
            revertExtraPreview()
            if effFrame and frameById(effFrame) then
                ns.BeginPreview(effFrame)
                return
            end
            previewWant = nil
            previewSync()
            return
        end

        local effExtra = (type(staged.looks) == "table" and staged.looks[deckMode])
            or (staged.kind == "look" and staged.catKey == deckMode and staged.id)
            or (baseTheme and baseTheme[deckMode])
            or (baseRec and baseRec[deckMode])

        if type(effExtra) == "string" then
            previewWant = nil
            previewSync()
            local pKey = deckMode .. ":" .. effExtra .. ":" .. tostring(effFrame or wornFrame() or "")
            beginExtraPairs(pKey, previewPairsForCategory(deckMode, effExtra, effFrame))
            return
        end
    end
    ns.RevertPreview()
end

-- Drops an unapplied frame/look/preset pick and its preview. Anything that writes a look
-- from somewhere else calls this first, so it reads the saved style.
function ns.dropFramePreview()
    local staged = ns.staged
    if type(staged) == "table" and (staged.kind == "frame" or staged.kind == "theme" or staged.kind == "look" or staged.kind == "mypreset" or staged.kind == "multi") then
        ns.staged = nil
        refreshLooks()
    end
    ns.RevertPreview()
end

-- Leaving the tab, the page or the window drops the pick.
function ns.setLooksOpen(open)
    open = open == true
    if open == looksOpen then return end
    looksOpen = open
    if not open then ns.dropFramePreview() end
end

local function queueLook(kind, id, name)
    if type(looksPending) == "table" and looksPending.kind == kind and looksPending.id == id then
        looksPending = nil
        refreshLooks()
        return
    end
    looksPending = { kind = kind, id = id }
    if kind == "theme" then
        say("Palettes: " .. name .. " queued until combat ends.")
    else
        say("Looks: " .. name .. " queued until combat ends.")
    end
    refreshLooks()
end

local function failFrame(id)
    local found = frameById(id)
    say("Looks: couldn't change the player and target frames to " .. (found and found.name or id) .. ".")
end

local function applyFrame(id, quiet)
    id = resolveFrame(id)
    if not id then return false end
    if inCombat() then
        queueLook("frame", id, frameById(id).name)
        return false
    end
    local undoShot = (not ns.applyingTheme and type(ns.captureUndo) == "function") and ns.captureUndo("frame") or nil
    local function finish(ok)
        if ok then
            if undoShot and type(ns.pushUndo) == "function" then ns.pushUndo(undoShot) end
            if type(ns.storeLookPart) == "function" then ns.storeLookPart("frame", id) end
            if not ns.applyingTheme and type(ns.notePalette) == "function" then ns.notePalette(ns.screenPalette()) end
        end
        return ok
    end
    if not hasWrite() then
        if not quiet then failFrame(id) end
        return finish(false)
    end
    local snapshot = readSnapshot()
    local shot = captureMissing(true)
    local list = lookPairs(id)
    local extras = extraPairs(id, type(snapshot) == "table" and snapshot.frameValues or nil)
    for i = 1, #extras do list[#list + 1] = extras[i] end
    local ok = writePairs(list)
    if shot then mergeSnapshot(shot) end
    refreshPage()
    refreshLooks()
    if not ok and not quiet then failFrame(id) end
    return finish(ok)
end

-- Puts back the frame values saved before Palettes first changed them. With
-- nothing saved there is nothing to put back.
local function restoreSavedFrames()
    local saved = readSnapshot()
    if type(saved) ~= "table" or type(saved.frameValues) ~= "table" then return true end
    return writeFrameValues(saved.frameValues)
end

-- Restores pre-Palettes glow values from a legacy snapshot created before glow removal.
local function writeGlowValue(buttonValue, lightValue)
    local buttons = buttonValue == nil or writeSetting("general", "buttonGlow", buttonValue)
    local light = lightValue == nil or writeSetting("Nameplates", "targetLight", lightValue)
    return buttons and light
end


local function activeSlot()
    local account = type(ns.accountTable) == "function" and ns.accountTable() or nil
    local char = type(ns.charTable) == "function" and ns.charTable() or nil
    if type(char) == "table" and char.only == true then return char, account, true end
    return account, account, false
end

local function writeThemeSlot(id, changed)
    local slot, account, onlyOn = activeSlot()
    local storedId = false
    local storedChanged = false
    if type(id) == "string" and themeById(id) then
        storedId = id
        storedChanged = changed == true
    end
    if onlyOn and type(slot) == "table" then
        slot.theme = storedId
        slot.themeChanged = storedChanged
    elseif type(account) == "table" then
        account.theme = storedId
        account.themeChanged = storedChanged
        local char = type(ns.charTable) == "function" and ns.charTable() or nil
        if type(char) == "table" then
            char.theme = nil
            char.themeChanged = nil
        end
    end
    local d = DaylightUI
    if type(d) == "table" and type(d.Set) == "function" then
        ns.writingLooks = true
        pcall(d.Set, d, "Palettes", "theme", storedId)
        pcall(d.Set, d, "Palettes", "themeChanged", storedChanged)
        ns.writingLooks = false
    end
end

function ns.readTheme()
    local slot = activeSlot()
    if type(slot) ~= "table" or type(slot.theme) ~= "string" then return nil, false end
    if not themeById(slot.theme) then return nil, false end
    return slot.theme, slot.themeChanged == true
end

function ns.clearTheme()
    writeThemeSlot(nil, false)
    refreshLooks()
end

function ns.storeLookPart(key, value)
    local slot, account, onlyOn = activeSlot()
    local stored = type(value) == "string" and value or false
    if onlyOn and type(slot) == "table" then
        slot[key] = stored
    elseif type(account) == "table" then
        account[key] = stored
        local char = type(ns.charTable) == "function" and ns.charTable() or nil
        if type(char) == "table" then char[key] = nil end
    end
    local d = DaylightUI
    if type(d) == "table" and type(d.Set) == "function" then
        ns.writingLooks = true
        pcall(d.Set, d, "Palettes", key, stored)
        ns.writingLooks = false
    end
end

function ns.screenPalette()
    local d = DaylightUI
    if type(d) == "table" and type(d.Get) == "function" then
        local id = d:Get("Palettes", "palette")
        if type(id) == "string" and id ~= "" then return id end
    end
    local slot = activeSlot()
    if type(slot) == "table" and type(slot.palette) == "string" then return slot.palette end
    return "off"
end

local EXTRA_CAT_KEYS = { "focus", "tot", "party", "raid", "castbars", "actionbars" }

local function readLookPicks()
    local slot = activeSlot()
    if type(slot) == "table" and type(slot.lookPicks) == "table" then
        return slot.lookPicks
    end
    return {}
end

local function writeLookPick(catKey, optId)
    local slot, account, onlyOn = activeSlot()
    local target = (onlyOn and type(slot) == "table") and slot or account
    if type(target) ~= "table" then return end
    if type(target.lookPicks) ~= "table" then target.lookPicks = {} end
    target.lookPicks[catKey] = optId
end

function ns.readLookPick(catKey)
    if catKey == "player_target" then return wornFrame() end
    local picks = readLookPicks()
    return picks[catKey]
end

local function copyLookPicks()
    local src = readLookPicks()
    local out = {}
    for i = 1, #EXTRA_CAT_KEYS do
        local k = EXTRA_CAT_KEYS[i]
        if type(src[k]) == "string" then out[k] = src[k] end
    end
    return out
end

local function readCurrentExtraValues()
    local unitVals, abVals = {}, {}
    local anyU, anyA = false, false
    local saved = readSnapshot()
    if type(saved) == "table" then
        if type(saved.extraUnitValues) == "table" then
            for k in pairs(saved.extraUnitValues) do
                local v, ok = readSetting("UnitFrames", k)
                if ok and v ~= nil then unitVals[k] = v; anyU = true end
            end
        end
        if type(saved.actionBarValues) == "table" then
            for k in pairs(saved.actionBarValues) do
                local v, ok = readSetting("ActionBars", k)
                if ok and v ~= nil then abVals[k] = v; anyA = true end
            end
        end
    end
    return anyU and unitVals or nil, anyA and abVals or nil
end

local function restoreExtraValues(unitVals, abVals)
    local list = {}
    if type(unitVals) == "table" then
        for k, v in pairs(unitVals) do list[#list + 1] = { "UnitFrames", k, v } end
    end
    if type(abVals) == "table" then
        for k, v in pairs(abVals) do list[#list + 1] = { "ActionBars", k, v } end
    end
    if #list == 0 then return true end
    return writeScopedPairs(list)
end

function ns.applyCategoryLook(catKey, optId, quiet)
    if catKey == "player_target" then return applyFrame(optId, quiet) end
    local opt = extraLookById(catKey, optId)
    if not opt then return false end
    if inCombat() then
        queueLook("look", catKey .. ":" .. optId, opt.name)
        return false
    end
    local undoShot = (not ns.applyingTheme and type(ns.captureUndo) == "function") and ns.captureUndo("look") or nil
    if not hasWrite() then return false end
    local list = categoryPairs(catKey, optId)
    if #list == 0 then return false end
    captureExtraForPairs(list)
    local ok = writeScopedPairs(list)
    if ok then
        writeLookPick(catKey, optId)
        if undoShot and type(ns.pushUndo) == "function" then ns.pushUndo(undoShot) end
        if not ns.applyingTheme then
            local themeId = ns.readTheme()
            if themeId then
                local theme = themeById(themeId)
                if theme and theme[catKey] ~= optId then
                    writeThemeSlot(themeId, true)
                end
            end
        end
    end
    refreshPage()
    refreshLooks()
    return ok
end

-- My Presets (4 slots, Issue #41). Stored on the active account/character slot.
local MY_PRESET_SLOTS = 4

function ns.readMyPresets()
    local slot = activeSlot()
    if type(slot) == "table" and type(slot.myPresets) == "table" then
        return slot.myPresets
    end
    return {}
end

function ns.currentRecipe()
    local picks = readLookPicks()
    local themeId = ns.readTheme()
    local theme = themeId and themeById(themeId) or nil
    return {
        palette = ns.screenPalette() or "off",
        frame = wornFrame() or (theme and theme.frame) or "beam",
        focus = picks.focus or (theme and theme.focus) or "match",
        tot = picks.tot or (theme and theme.tot) or "match",
        party = picks.party or (theme and theme.party) or "standard",
        raid = picks.raid or (theme and theme.raid) or "tiles",
        castbars = picks.castbars or (theme and theme.castbars) or "silk",
        actionbars = picks.actionbars or (theme and theme.actionbars) or "classic",
    }
end

function ns.saveMyPreset(slotIdx, name)
    if type(slotIdx) ~= "number" or slotIdx < 1 or slotIdx > MY_PRESET_SLOTS then return false end
    local slot, account, onlyOn = activeSlot()
    local target = (onlyOn and type(slot) == "table") and slot or account
    if type(target) ~= "table" then return false end
    if type(target.myPresets) ~= "table" then target.myPresets = {} end
    local cleanName = trim(name or "")
    if cleanName == "" then cleanName = "My Preset " .. tostring(slotIdx) end
    target.myPresets[slotIdx] = {
        name = cleanName,
        recipe = ns.currentRecipe(),
    }
    refreshLooks()
    return true
end

function ns.deleteMyPreset(slotIdx)
    if type(slotIdx) ~= "number" or slotIdx < 1 or slotIdx > MY_PRESET_SLOTS then return false end
    local slot, account, onlyOn = activeSlot()
    local target = (onlyOn and type(slot) == "table") and slot or account
    if type(target) ~= "table" or type(target.myPresets) ~= "table" then return false end
    target.myPresets[slotIdx] = nil
    refreshLooks()
    return true
end

function ns.applyMyPreset(entry)
    if type(entry) ~= "table" or type(entry.recipe) ~= "table" then return false end
    local rec = entry.recipe
    if inCombat() then return false end
    if type(ns.captureUndo) == "function" then
        ns.undoHold = ns.captureUndo("theme")
    end
    ns.applyingTheme = true
    ns.quietPalette = true
    local d = DaylightUI
    if type(d) == "table" and type(d.Set) == "function" and type(rec.palette) == "string" then
        d:Set("Palettes", "palette", rec.palette)
    end
    batch(function()
        if type(rec.frame) == "string" and resolveFrame(rec.frame) then
            applyFrame(rec.frame, true)
        end
        for i = 1, #EXTRA_CAT_KEYS do
            local ck = EXTRA_CAT_KEYS[i]
            if type(rec[ck]) == "string" then
                pcall(ns.applyCategoryLook, ck, rec[ck], true)
            end
        end
    end)
    writeThemeSlot(nil, false)
    ns.applyingTheme = false
    ns.quietPalette = false
    ns.undoHold = nil
    say("Palettes: " .. (entry.name or "My Preset") .. " is on. Your layout is unchanged.")
    refreshLooks()
    return true
end

function ns.exactTheme(palette, frameId)
    if type(palette) ~= "string" then return nil end
    local picks = readLookPicks()
    for i = 1, #THEMES do
        local theme = THEMES[i]
        if theme.palette == palette and theme.frame == frameId then
            local extraMatch = true
            for c = 1, #EXTRA_CAT_KEYS do
                local ck = EXTRA_CAT_KEYS[c]
                if picks[ck] ~= nil and theme[ck] ~= nil and picks[ck] ~= theme[ck] then
                    extraMatch = false
                    break
                end
            end
            if extraMatch then return theme end
        end
    end
end

function ns.notePalette(id)
    if ns.applyingTheme or ns.clearingTheme then return end
    local exact = ns.exactTheme(id, wornFrame())
    if exact then
        writeThemeSlot(exact.id, false)
        refreshLooks()
        return
    end
    local themeId = ns.readTheme()
    if themeId then writeThemeSlot(themeId, true) end
    refreshLooks()
end

function ns.shownTheme()
    if type(looksPending) == "table" and looksPending.kind == "theme" then
        return looksPending.id, false, true
    end
    local exact = ns.exactTheme(ns.screenPalette(), wornFrame())
    if exact then return exact.id, false, false end
    local id = ns.readTheme()
    if id then return id, true, false end
    return nil, false, false
end

function ns.captureUndo(kind)
    local themeId, changed = ns.readTheme()
    local extraU, extraAB = readCurrentExtraValues()
    return {
        kind = kind,
        frameValues = readFrameValues(),
        extraUnitValues = extraU,
        actionBarValues = extraAB,
        lookPicks = copyLookPicks(),
        theme = themeId or false,
        themeChanged = changed == true,
    }
end

function ns.applyUndoShot(shot)
    if type(shot) ~= "table" then return end
    if shot.kind == "theme" or shot.kind == "frame" or shot.kind == "look" or shot.kind == "looks" or shot.kind == "full" then
        if type(shot.frameValues) == "table" then writeFrameValues(shot.frameValues) end
        restoreExtraValues(shot.extraUnitValues, shot.actionBarValues)
        if type(shot.lookPicks) == "table" then
            local slot, account, onlyOn = activeSlot()
            local target = (onlyOn and type(slot) == "table") and slot or account
            if type(target) == "table" then target.lookPicks = shot.lookPicks end
        end
    end
    if shot.theme == false or type(shot.theme) == "string" then
        writeThemeSlot(shot.theme, shot.themeChanged == true)
    end
    local exact = ns.exactTheme(ns.screenPalette(), wornFrame())
    if exact then writeThemeSlot(exact.id, false) end
    refreshLooks()
end

function ns.applyShareLook(look)
    if type(look) ~= "table" then return end
    if type(look.frame) == "string" then
        if look.frame == "daylight" then restoreSavedFrames()
        elseif resolveFrame(look.frame) then applyFrame(look.frame, true) end
    end
    if not ns.applyingTheme then ns.notePalette(ns.screenPalette()) end
end

function ns.currentPal2()
    local palette = ns.screenPalette()
    local themeId = select(1, ns.shownTheme())
    local frameId = wornFrame() or "daylight"
    if palette == "custom" and type(ns.readCustom) == "function" and type(ns.shareCode) == "function" then
        local spec = ns.readCustom(type(ns.accountTable) == "function" and ns.accountTable() or {}, type(ns.charTable) == "function" and ns.charTable() or {})
        local code = ns.shareCode(spec)
        local base, accent = string.match(code or "", "^PAL1%-(%x%x%x%x%x%x)%-(%x%x%x%x%x%x)$")
        return ns.pal2Code({ theme = themeId, custom = true, base = base, accent = accent, frame = frameId })
    end
    return ns.pal2Code({ theme = themeId, palette = palette, frame = frameId })
end

local function themeKeys(db)
    return type(db) == "table" and (db.theme ~= nil or db.themeChanged ~= nil or db.frame ~= nil)
end

function ns.takeTheme(account, char, db, onlyOn)
    if type(account) == "table" then account.glow = nil end
    if type(char) == "table" then char.glow = nil end
    if type(db) == "table" then db.glow = nil end
    if not themeKeys(db) then return false end
    local function write(key, value)
        if onlyOn and type(char) == "table" then
            char[key] = value
        elseif type(account) == "table" then
            account[key] = value
            if type(char) == "table" then char[key] = nil end
        end
    end
    if db.theme ~= nil then write("theme", db.theme) end
    if db.themeChanged ~= nil then write("themeChanged", db.themeChanged == true) end
    if db.frame ~= nil then write("frame", resolveFrame(db.frame) or db.frame) end
    return true
end

function ns.looksWaiting()
    return type(looksPending) == "table"
end

function ns.cancelStylePending()
    if type(looksPending) ~= "table" then return false end
    looksPending = nil
    refreshLooks()
    return true
end

local function applyTheme(theme)
    if inCombat() then
        queueLook("theme", theme.id, theme.name)
        return
    end
    if type(ns.captureUndo) == "function" then
        ns.undoHold = ns.captureUndo("theme")
    end
    ns.applyingTheme = true
    ns.quietPalette = true
    local d = DaylightUI
    if type(d) == "table" and type(d.Set) == "function" then
        d:Set("Palettes", "palette", theme.palette)
    end
    local frameOk = true
    batch(function()
        frameOk = applyFrame(theme.frame, true)
        for i = 1, #EXTRA_CAT_KEYS do
            local ck = EXTRA_CAT_KEYS[i]
            if type(theme[ck]) == "string" then
                pcall(ns.applyCategoryLook, ck, theme[ck], true)
            end
        end
    end)
    writeThemeSlot(theme.id, false)
    ns.applyingTheme = false
    ns.quietPalette = false
    ns.undoHold = nil
    say("Palettes: " .. theme.name .. " is on. Your layout is unchanged.")
    if not frameOk then failFrame(theme.frame) end
    refreshLooks()
end

function ns.restoreColoursOnly()
    ns.coloursOnlyRestore = true
    local d = DaylightUI
    if type(d) == "table" and type(d.Set) == "function" then
        d:Set("Palettes", "palette", "off")
    end
end

-- Puts back only what Palettes saved: frame values, extra category values, plus any pre-update glow snapshot.
local function restoreSaved(saved)
    local frameOk, glowOk = true, true
    local hadFrames = type(saved.frameValues) == "table"
    local hadGlow = saved.glow ~= nil or saved.light ~= nil
    if hadFrames then frameOk = writeFrameValues(saved.frameValues) end
    if type(saved.extraUnitValues) == "table" or type(saved.actionBarValues) == "table" then
        restoreExtraValues(saved.extraUnitValues, saved.actionBarValues)
    end
    if hadGlow then glowOk = writeGlowValue(saved.glow, saved.light) end
    local slot, account, onlyOn = activeSlot()
    local target = (onlyOn and type(slot) == "table") and slot or account
    if type(target) == "table" then target.lookPicks = nil end
    return frameOk, glowOk, hadFrames, hadGlow
end

function ns.restoreLooksOnly()
    if not ns.looksApiOk() then return false end
    local saved = readSnapshot()
    -- No snapshot means Palettes never changed the look, so Daylight's own
    -- frame and glow stay as they are. Same as a full restore with nothing saved.
    if type(saved) ~= "table" then
        refreshLooks()
        return false
    end
    local undoShot = type(ns.captureUndo) == "function" and ns.captureUndo("looks") or nil
    ns.RevertPreview()
    local frameOk, glowOk, hadFrames = restoreSaved(saved)
    if frameOk or glowOk then refreshPage() end
    if frameOk and glowOk then storeSnapshot(false) end
    if undoShot and (frameOk or glowOk) and type(ns.pushUndo) == "function" then ns.pushUndo(undoShot) end
    if hadFrames then ns.storeLookPart("frame", wornFrame() or "daylight") end
    ns.notePalette(ns.screenPalette())
    refreshLooks()
    return frameOk and glowOk
end

function ns.restoreDaylightFull()
    if type(ns.armLooksRestore) == "function" then ns.armLooksRestore() end
    local d = DaylightUI
    if type(d) == "table" and type(d.Set) == "function" then
        d:Set("Palettes", "palette", "off")
    end
end

-- One labelled reset per tab. The options page draws the button in the tab row.
ns.tabReset = {
    { tab = "Presets", label = "Restore Daylight", run = ns.restoreDaylightFull },
    { tab = "Colours", label = "Reset Colours", run = ns.restoreColoursOnly },
    { tab = "Looks", label = "Reset Looks", run = ns.restoreLooksOnly },
}

function ns.applyLiveShare(parsed)
    if type(parsed) ~= "table" or parsed.kind ~= "pal2" or parsed.custom == true then return false end
    local theme = parsed.theme and themeById(parsed.theme) or nil
    if parsed.theme and not theme then return false end
    if parsed.palette and parsed.palette ~= "none" and parsed.palette ~= "custom" then
        if parsed.palette ~= "off" and type(ns.byId) == "table" and ns.byId[parsed.palette] == nil then
            return false
        end
    end
    if type(ns.captureUndo) == "function" then
        local shot = ns.captureUndo("theme")
        ns.undoHold = shot
    end
    ns.applyingTheme = true
    ns.quietPalette = theme ~= nil
    local d = DaylightUI
    if parsed.palette and parsed.palette ~= "none" and type(d) == "table" and type(d.Set) == "function" then
        d:Set("Palettes", "palette", parsed.palette)
    end
    if parsed.frame and parsed.frame ~= "none" then
        if parsed.frame == "daylight" then restoreSavedFrames()
        elseif resolveFrame(parsed.frame) then applyFrame(parsed.frame, true) end
    end
    if theme then
        local exact = ns.exactTheme(ns.screenPalette(), wornFrame())
        if exact and exact.id == theme.id then
            writeThemeSlot(theme.id, false)
            say("Palettes: " .. theme.name .. " is on. Your layout is unchanged.")
        else
            writeThemeSlot(theme.id, true)
            say("Palettes: " .. theme.name .. " (changed) is on. Your layout is unchanged.")
        end
    else
        writeThemeSlot(nil, false)
        ns.notePalette(ns.screenPalette())
    end
    ns.applyingTheme = false
    ns.quietPalette = false
    ns.undoHold = nil
    refreshLooks()
    return true
end

function ns.armLooksRestore()
    ns.restoreLooksToo = true
end

function ns.cancelLooksOff()
    if type(looksPending) == "table" and looksPending.kind == "off" then
        looksPending = nil
        refreshLooks()
    end
    ns.restoreLooksToo = nil
end

function ns.queueLooksOff()
    if not readSnapshot() then return end
    looksPending = { kind = "off" }
    refreshLooks()
end

function ns.restoreLooks(quiet)
    looksPending = nil
    if not ns.looksApiOk() then
        refreshLooks()
        return false
    end
    local saved = readSnapshot()
    if type(saved) ~= "table" then
        refreshLooks()
        return false
    end
    if inCombat() then
        looksPending = { kind = "off", quiet = quiet == true }
        refreshLooks()
        return false
    end
    ns.RevertPreview()
    local frameOk, glowOk = restoreSaved(saved)
    if frameOk or glowOk then refreshPage() end
    if frameOk and glowOk then storeSnapshot(false) end
    if not frameOk and not quiet then say("Looks: couldn't put your player and target frames back.") end
    if not glowOk and not quiet then pointAtGlowValue(saved.glow) end
    refreshLooks()
    return frameOk and glowOk
end

function ns.finishLooksCombat()
    if not inCombat() then ns.syncFramePreview() end
    local pending = looksPending
    if type(pending) ~= "table" then return end
    if inCombat() then return end
    looksPending = nil
    if pending.kind == "off" then
        ns.restoreLooks(pending.quiet)
        return
    end
    if pending.kind == "frame" then
        applyFrame(pending.id, false)
    elseif pending.kind == "theme" then
        local theme = themeById(pending.id)
        if theme then applyTheme(theme) end
    end
    refreshLooks()
end

local function guardLine()
    if ns.looksGuard then return ns.looksGuard end
    if not ns.looksApiOk() then return NEED_STYLES end
end

function ns.lookMark()
    local frame = wornFrame() or "daylight"
    local pending = ""
    if type(looksPending) == "table" then
        pending = tostring(looksPending.kind) .. ":" .. tostring(looksPending.id)
    end
    return frame .. "/" .. pending
end

local looksSlashRun

function ns.looksSlash(msg)
    ns.dropFramePreview()
    local function run()
        looksSlashRun(msg)
    end
    if type(ns.withReloadAction) ~= "function" then
        run()
        return
    end
    local beforeLook = ns.lookMark()
    local beforePal = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
    -- A frame look repaints live. A Preset or off changes colours.
    local arg = string.lower(trim(msg or ""))
    local looksOnly = resolveFrame(arg) ~= nil
    ns.withReloadAction(function()
        run()
        local afterPal = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
        if not looksOnly and (ns.lookMark() ~= beforeLook or afterPal ~= beforePal) then
            if type(ns.requestReload) == "function" then ns.requestReload() end
        end
    end)
end

function looksSlashRun(msg)
    local blocked = guardLine()
    if blocked then
        say(blocked)
        return
    end
    if not ns.looksReady then
        say(NEED_STYLES)
        return
    end
    local arg = string.lower(trim(msg or ""))
    if arg == "" or string.find(arg, "%s") then
        say(statusLine())
        return
    end
    if arg == "off" then
        if type(ns.armLooksRestore) == "function" then ns.armLooksRestore() end
        local d = DaylightUI
        if type(d) == "table" and type(d.Set) == "function" then
            if d:Set("Palettes", "palette", "off") == false then
                if type(ns.cancelLooksOff) == "function" then ns.cancelLooksOff() end
                say("Palettes: Daylight UI isn't ready, so no palette was changed.")
            end
        else
            say("Palettes: Daylight UI isn't ready, so no palette was changed.")
        end
        return
    end
    local frameId = resolveFrame(arg)
    if frameId then
        applyFrame(frameId)
        return
    end
    local theme = themeById(arg)
    if theme then
        applyTheme(theme)
        return
    end
    say(statusLine())
end

local function rowPending(kind, id)
    local pending = looksPending
    if type(pending) ~= "table" or pending.kind == "off" then return false end
    if pending.kind == kind and pending.id == id then return true end
    if pending.kind == "theme" then
        local theme = themeById(pending.id)
        if theme and ((kind == "frame" and theme.frame == id) or (kind == "theme" and theme.id == id)) then
            return true
        end
    end
    return false
end

local function uiFont(parent, size, color)
    local d = DaylightUI
    local widgets = type(d) == "table" and d.Widgets
    if type(widgets) == "table" and type(widgets.Font) == "function" and type(widgets.BODY) == "string" then
        return widgets.Font(parent, widgets.BODY, size, color, "LEFT")
    end
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    if color and type(fs.SetTextColor) == "function" then
        fs:SetTextColor(color[1], color[2], color[3], color[4] or 1)
    end
    if type(fs.SetJustifyH) == "function" then fs:SetJustifyH("LEFT") end
    return fs
end

local function flat(parent, layer, color)
    local t = parent:CreateTexture(nil, layer or "BACKGROUND")
    if type(t.SetColorTexture) == "function" then
        t:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
    end
    t:SetAllPoints()
    return t
end

local function paintChip(tex, color)
    if type(tex) ~= "table" or type(color) ~= "table" or type(tex.SetColorTexture) ~= "function" then return end
    if type(color[1]) ~= "number" or type(color[2]) ~= "number" or type(color[3]) ~= "number" then return end
    tex:SetColorTexture(color[1], color[2], color[3], 1)
end

-- Same three blocks as a Colours row: background, band, accent, on the palette border.
local function paletteSwatches(parent, paletteId)
    local hold = CreateFrame("Frame", nil, parent)
    hold:SetSize(44, 16)
    local edge = hold:CreateTexture(nil, "BORDER")
    edge:SetAllPoints()
    local bg = hold:CreateTexture(nil, "ARTWORK")
    bg:SetSize(12, 14)
    bg:SetPoint("LEFT", hold, "LEFT", 1, 0)
    local band = hold:CreateTexture(nil, "ARTWORK")
    band:SetSize(12, 14)
    band:SetPoint("LEFT", bg, "RIGHT", 1, 0)
    local accent = hold:CreateTexture(nil, "ARTWORK")
    accent:SetSize(16, 14)
    accent:SetPoint("LEFT", band, "RIGHT", 1, 0)
    local palette = type(ns.byId) == "table" and ns.byId[paletteId] or nil
    local preview
    if type(palette) == "table" then
        paintChip(edge, palette.border or { 0.05, 0.05, 0.05 })
        paintChip(bg, palette.background)
        paintChip(band, palette.band)
        paintChip(accent, palette.c2)
        preview = { palette.background, palette.band, palette.c2 }
    end
    return hold, preview
end

local function drawIcon(parent, parts)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(36, 18)
    for i = 1, #parts do
        local part = parts[i]
        local t = f:CreateTexture(nil, "ARTWORK")
        if type(t.SetColorTexture) == "function" then
            t:SetColorTexture(part[5], part[6], part[7], part[8] or 1)
        end
        t:ClearAllPoints()
        t:SetPoint("TOPLEFT", f, "TOPLEFT", part[1], -part[2])
        t:SetSize(math.max(1, part[3]), math.max(1, part[4]))
    end
    return f
end

local function hookSize(row, place)
    if type(row.GetScript) ~= "function" or type(row.SetScript) ~= "function" then
        place()
        return
    end
    local prev = row:GetScript("OnSizeChanged")
    row:SetScript("OnSizeChanged", function(f)
        if type(prev) == "function" then prev(f) end
        place()
    end)
    place()
end

-- warcraft.wiki.gg: CheckButton:SetCheckedTexture, Forever and Vanilla.
-- The stock art is Interface\Buttons\UI-CheckBox-Check. A font glyph is not
-- in every game font, so the row uses this texture.
local CHECK_PATH = "Interface\\Buttons\\UI-CheckBox-Check"

local function drawCheck(parent)
    local tex = parent:CreateTexture(nil, "OVERLAY")
    tex:SetSize(16, 16)
    if type(tex.SetTexture) == "function" then
        tex:SetTexture(CHECK_PATH)
    end
    if tex.Hide then tex:Hide() end
    return tex
end

local function makePill(parent, label)
    local hold = CreateFrame("Frame", nil, parent)
    hold:SetHeight(16)
    local pillCard = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(hold) or nil
    if pillCard then
        pillCard.paint({ 0.14, 0.16, 0.14 }, 0.85, { 0.32, 0.38, 0.32 }, 0.70)
    else
        local edge = hold:CreateTexture(nil, "BACKGROUND")
        if type(edge.SetColorTexture) == "function" then edge:SetColorTexture(0.32, 0.38, 0.32, 0.8) end
        if edge.SetAllPoints then edge:SetAllPoints() end
        local fill = hold:CreateTexture(nil, "BORDER")
        if type(fill.SetColorTexture) == "function" then fill:SetColorTexture(0.14, 0.16, 0.14, 0.9) end
        if fill.SetPoint then
            fill:SetPoint("TOPLEFT", hold, "TOPLEFT", 1, -1)
            fill:SetPoint("BOTTOMRIGHT", hold, "BOTTOMRIGHT", -1, 1)
        end
    end
    local fs = uiFont(hold, 10, CREAM)
    fs:SetText(label)
    local width = 10 + string.len(label) * 5
    if type(fs.GetStringWidth) == "function" then
        local sw = fs:GetStringWidth()
        if type(sw) == "number" and sw > 8 then width = sw + 10 end
    end
    hold:SetWidth(width)
    fs:ClearAllPoints()
    fs:SetPoint("CENTER", hold, "CENTER", 0, 0)
    return hold, fs
end

local CARD_GAP_X = 8
local CARD_GAP_Y = 6
local PRESET_CARD_H = 50
local LOOK_CARD_H = 58

local function styleRows(row, entries)
    row.lines = row.lines or {}
    local built = {}
    for i = 1, #entries do
        local entry = entries[i]
        local isPreset = entry.paletteName ~= nil
        local cardH = isPreset and PRESET_CARD_H or LOOK_CARD_H
        local hold = CreateFrame("Button", nil, row)
        hold:SetHeight(cardH)
        local card = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(hold) or nil
        local hi = card and card.fill or hold:CreateTexture(nil, "BACKGROUND")
        if not card then
            if type(hi.SetColorTexture) == "function" then
                hi:SetColorTexture(ROW_REST[1], ROW_REST[2], ROW_REST[3], ROW_REST[4])
            end
            hi:SetAllPoints()
            hi:Hide()
        end
        local icon = drawIcon(hold, entry.icon or {})
        local name = uiFont(hold, 12, CREAM)
        name:SetText(entry.name)
        if type(name.SetWordWrap) == "function" then name:SetWordWrap(false) end
        local desc = uiFont(hold, 11, DIM)
        desc:SetText(entry.desc)
        if type(desc.SetWordWrap) == "function" then desc:SetWordWrap(not isPreset) end
        local pillA, pillAText, pillB, pillBText
        if entry.paletteName then
            pillA, pillAText = makePill(hold, entry.paletteName)
            pillB, pillBText = makePill(hold, entry.lookName)
        end
        local swatch, preview
        if entry.palette then
            swatch, preview = paletteSwatches(hold, entry.palette)
        end
        local key = uiFont(hold, 11, DIM)
        key:SetText(entry.key)
        if key.Hide then key:Hide() end
        local cue = hold:CreateTexture(nil, "OVERLAY")
        cue:SetWidth(3)
        cue:SetPoint("TOPLEFT", hold, "TOPLEFT", 0, 0)
        cue:SetPoint("BOTTOMLEFT", hold, "BOTTOMLEFT", 0, 0)
        if cue.Hide then cue:Hide() end
        local check = drawCheck(hold)
        local onText = uiFont(hold, 11, ON_INK)
        onText:SetText("")
        onText:Hide()
        local line = {
            id = entry.id, kind = entry.kind, name = name, baseName = entry.name,
            mood = entry.desc, preview = preview, rowH = cardH,
            button = hold, paletteId = entry.palette,
            palettePill = pillAText, lookPill = pillBText,
        }
        line.key = key
        line.desc = desc
        line.onText = onText
        line.check = check
        line.cue = cue
        local function tint(fs, color)
            if type(fs) == "table" and type(fs.SetTextColor) == "function" and type(color) == "table" then
                fs:SetTextColor(color[1], color[2], color[3], color[4] or 1)
            end
        end
        local function paletteOf(id)
            if type(id) ~= "string" or type(ns.byId) ~= "table" then return nil end
            local palette = ns.byId[id]
            if type(palette) ~= "table" then return nil end
            return palette
        end
        local function paintRow()
            local own = paletteOf(line.paletteId)
            local screenId = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
            local screen = paletteOf(screenId)
            local surface = screen or own
            local win = (surface and (surface.window or surface.background)) or { 0.08, 0.10, 0.08 }
            local bnd = (surface and surface.band) or { 0.14, 0.18, 0.14 }
            local brd = (surface and surface.border) or { 0.22, 0.28, 0.22 }
            local blend = type(ns.blendColor) == "function" and ns.blendColor or function(a) return a end
            local rest = blend(win, bnd, 0.26)
            local hover = blend(win, bnd, 0.55)
            local color = rest
            local lineColor = brd
            local fillAlpha = 0.86
            local lineAlpha = 0.55
            local light
            local edge
            if line.markOn or line.markPending then
                local source = own or screen
                local accent = (source and source.c2) or { 0.91, 0.63, 0.29 }
                local window = (source and (source.window or source.background)) or ROW_REST
                local inks = {}
                if source and source.title then inks[#inks + 1] = source.title end
                if source and source.text then inks[#inks + 1] = source.text end
                inks[#inks + 1] = CREAM
                if source then
                    color, light = ns.accentWash(accent, window, inks)
                else
                    color, light = ROW_PICK, CREAM
                end
                lineColor = accent
                fillAlpha = 1
                lineAlpha = 0.95
                edge = accent
            elseif line.hover then
                local source = own or screen
                local accent = (source and source.c2) or { 0.91, 0.63, 0.29 }
                color = hover
                lineColor = blend(brd, accent, 0.50)
                fillAlpha = 0.94
                lineAlpha = 0.85
            end
            line.washColor = color
            line.ink = light
            if card then
                card.paint(color, fillAlpha, lineColor, lineAlpha)
            elseif type(hi.SetColorTexture) == "function" then
                hi:SetColorTexture(color[1], color[2], color[3], fillAlpha)
                if hi.Show then hi:Show() end
            end
            if key.Hide then key:Hide() end
            if check.Hide then check:Hide() end
            if cue.Hide then cue:Hide() end
            if light then
                tint(name, light)
                tint(desc, light)
                tint(onText, light)
                if type(check.SetVertexColor) == "function" then
                    check:SetVertexColor(light[1], light[2], light[3], 1)
                end
                if type(cue.SetColorTexture) == "function" then
                    cue:SetColorTexture(edge[1], edge[2], edge[3], 1)
                end
                if cue.Show then cue:Show() end
            else
                tint(name, (surface and surface.text) or CREAM)
                tint(desc, (surface and surface.label) or DIM)
            end
            if line.markPending then
                onText:SetText("PENDING")
                onText:Show()
            elseif line.markOn then
                if onText.Hide then onText:Hide() end
                if check.Show then check:Show() end
            else
                if onText.Hide then onText:Hide() end
            end
        end
        function line.SetOn(on, pending)
            line.markOn = on and true or false
            line.markPending = pending and true or false
            paintRow()
        end
        function line.SetHover(on)
            line.hover = on and true or false
            paintRow()
        end
        local function pick() entry.select() end
        hold:SetScript("OnClick", pick)
        hold:SetScript("OnEnter", function() line.SetHover(true) end)
        hold:SetScript("OnLeave", function() line.SetHover(false) end)
        row.lines[#row.lines + 1] = line
        built[#built + 1] = {
            hold = hold, icon = icon, name = name, desc = desc,
            pillA = pillA, pillB = pillB, swatch = swatch, key = key,
            onText = onText, check = check, line = line,
        }
    end
    return built
end

local function placeStyles(row, intro, heads, rows, hintText, combatNote, introH)
    local w = row:GetWidth()
    if type(w) ~= "number" or w < 120 then w = 760 end
    intro:ClearAllPoints()
    intro:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -2)
    intro:SetWidth(w - 8)
    local y = (introH or 22) + 4
    local cols = w >= 520 and 2 or 1
    local cardW = math.floor((w - 8 - (cols - 1) * CARD_GAP_X) / cols)

    local function placeHead(fs)
        if fs.Hide then fs:Hide() end
    end
    local function placeList(list)
        if #list == 0 then return end
        local cardH = list[1].line.rowH or LOOK_CARD_H
        for i = 1, #list do
            local s = list[i]
            local idx = i - 1
            local r = math.floor(idx / cols)
            local c = idx - r * cols
            local x = 4 + c * (cardW + CARD_GAP_X)
            local cy = y + r * (cardH + CARD_GAP_Y)
            s.hold:ClearAllPoints()
            s.hold:SetPoint("TOPLEFT", row, "TOPLEFT", x, -cy)
            s.hold:SetWidth(cardW)
            s.icon:ClearAllPoints()
            s.name:ClearAllPoints()
            s.desc:ClearAllPoints()
            if s.pillA then
                s.icon:SetPoint("TOPLEFT", s.hold, "TOPLEFT", 8, -8)
                local textX = 48
                if s.swatch then
                    s.swatch:ClearAllPoints()
                    s.swatch:SetPoint("TOPRIGHT", s.hold, "TOPRIGHT", -26, -8)
                end
                s.name:SetPoint("TOPLEFT", s.hold, "TOPLEFT", textX, -7)
                local nameW = 80
                if type(s.name.GetStringWidth) == "function" then
                    local sw = s.name:GetStringWidth()
                    if type(sw) == "number" and sw > 20 then nameW = sw + 4 end
                end
                s.name:SetWidth(nameW)
                s.pillA:ClearAllPoints()
                s.pillA:SetPoint("LEFT", s.name, "RIGHT", 6, 0)
                s.pillB:ClearAllPoints()
                s.pillB:SetPoint("LEFT", s.pillA, "RIGHT", 4, 0)
                s.desc:SetPoint("TOPLEFT", s.hold, "TOPLEFT", textX, -27)
                s.desc:SetWidth(math.max(80, cardW - textX - 24))
            else
                s.icon:SetPoint("TOPLEFT", s.hold, "TOPLEFT", 10, -8)
                s.name:SetPoint("LEFT", s.icon, "RIGHT", 8, 0)
                s.name:SetWidth(math.max(80, cardW - 86))
                s.desc:SetPoint("TOPLEFT", s.hold, "TOPLEFT", 10, -28)
                s.desc:SetWidth(math.max(80, cardW - 28))
            end
            s.key:ClearAllPoints()
            s.onText:ClearAllPoints()
            if s.key.Hide then s.key:Hide() end
            s.onText:SetPoint("TOPRIGHT", s.hold, "TOPRIGHT", -8, -8)
            if s.check then
                s.check:ClearAllPoints()
                s.check:SetPoint("TOPRIGHT", s.hold, "TOPRIGHT", -6, -7)
            end
        end
        local rowCount = math.ceil(#list / cols)
        y = y + rowCount * (cardH + CARD_GAP_Y)
    end
    for i = 1, #heads do
        placeHead(heads[i])
        placeList(rows[i])
    end
    if hintText then
        hintText.hold:ClearAllPoints()
        hintText.hold:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -(y + 6))
        hintText.hold:SetWidth(w - 8)
    end
    if combatNote then
        combatNote:ClearAllPoints()
        combatNote:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -(y + (hintText and (HINT_H + 8) or 4)))
    end
end

local function buildListPage(row, spec)
    if row.made or type(CreateFrame) ~= "function" then return end
    row.made = true
    row.lines = {}
    local intro = uiFont(row, 11, DIM)
    intro:SetText(spec.intro)
    intro:SetWordWrap(true)
    local heads, groups = {}, {}
    for i = 1, #spec.sections do
        local section = spec.sections[i]
        local head = uiFont(row, 11, DIM)
        head:SetText(section.head)
        heads[#heads + 1] = head
        groups[#groups + 1] = styleRows(row, section.rows)
    end
    local hint
    if spec.hint then
        local hold = CreateFrame("Frame", nil, row)
        hold:SetHeight(HINT_H)
        flat(hold, "BACKGROUND", HINT_EDGE)
        local hintFill = hold:CreateTexture(nil, "BORDER")
        if type(hintFill.SetColorTexture) == "function" then
            hintFill:SetColorTexture(0.12, 0.12, 0.13, 1)
        end
        hintFill:SetPoint("TOPLEFT", hold, "TOPLEFT", 1, -1)
        hintFill:SetPoint("BOTTOMRIGHT", hold, "BOTTOMRIGHT", -1, 1)
        local text = uiFont(hold, 11, DIM)
        text:SetText(spec.hint)
        text:SetWordWrap(true)
        text:SetPoint("LEFT", hold, "LEFT", 8, 0)
        text:SetPoint("RIGHT", hold, "RIGHT", -8, 0)
        hint = { hold = hold, text = text }
    end
    local combatNote = uiFont(row, 12, ON_INK)
    combatNote:SetText("Applies when combat ends.")
    if combatNote.Hide then combatNote:Hide() end
    function row.UpdateLooks()
        local waiting = type(looksPending) == "table"
        if combatNote.SetShown then combatNote:SetShown(waiting) end
        local shownId, changed, pendingTheme = ns.shownTheme()
        local function stagedOn(kind, id, real)
            local staged = ns.staged
            if type(staged) == "table" and staged.kind == kind then
                return staged.id == id
            end
            return real and true or false
        end
        for i = 1, #row.lines do
            local line = row.lines[i]
            local pending = rowPending(line.kind, line.id)
            local on = false
            if line.kind == "theme" then
                on = stagedOn("theme", line.id, shownId == line.id and not pendingTheme)
                if line.name and line.name.SetText then
                    if shownId == line.id and changed then
                        line.name:SetText(line.baseName .. " (changed)")
                    else
                        line.name:SetText(line.baseName)
                    end
                end
            elseif line.kind == "frame" then
                on = stagedOn("frame", line.id, spec.frameOn(line.id))
            end
            line.SetOn(on and true or false, pending)
        end
        placeStyles(row, intro, heads, groups, hint, combatNote, spec.introH)
    end
    hookSize(row, function()
        if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
    end)
    row.UpdateLooks()
    refreshers[#refreshers + 1] = function()
        if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
    end
end

local function listHeight(sections, withHint, introH)
    local rowsH = 0
    for i = 1, #sections do
        local section = sections[i]
        local isPreset = section.rows[1] and section.rows[1].paletteName ~= nil
        local cardH = isPreset and PRESET_CARD_H or LOOK_CARD_H
        local gridRows = math.ceil(#section.rows / 2)
        rowsH = rowsH + gridRows * (cardH + CARD_GAP_Y)
    end
    return (introH or 22) + rowsH + (withHint and (HINT_H + 8) or 8) + 8
end

local function hiddenStyles()
    return ns.looksApiOk() ~= true
end

local AMBER_BG = { 0.85, 0.47, 0.02, 1 }
local AMBER_INK = { 0.07, 0.05, 0.02, 1 }

local function activeSurface()
    local screenId = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
    local p = type(screenId) == "string" and type(ns.byId) == "table" and ns.byId[screenId] or nil
    local win = (p and (p.window or p.background)) or { 0.08, 0.10, 0.08 }
    local bg = (p and p.background) or win
    local bnd = (p and p.band) or { 0.14, 0.18, 0.14 }
    local bndLit = (p and p.bandLit) or bnd
    local brd = (p and p.border) or { 0.22, 0.28, 0.22 }
    local acc = (p and p.c2) or { 0.91, 0.63, 0.29 }
    local txt = (p and p.text) or CREAM
    local lbl = (p and p.label) or DIM
    return win, bg, bnd, bndLit, brd, acc, txt, lbl
end

local function tintText(fs, color)
    if type(fs) == "table" and type(fs.SetTextColor) == "function" and type(color) == "table" then
        fs:SetTextColor(color[1], color[2], color[3], color[4] or 1)
    end
end

local function setShownSafe(frame, shown)
    if type(frame) ~= "table" then return end
    if shown then
        if type(frame.Show) == "function" then frame:Show()
        elseif type(frame.SetShown) == "function" then frame:SetShown(true) end
    else
        if type(frame.Hide) == "function" then frame:Hide()
        elseif type(frame.SetShown) == "function" then frame:SetShown(false) end
    end
end

local function showTooltip(owner, text)
    if type(GameTooltip) ~= "table" or type(GameTooltip.SetOwner) ~= "function" then return end
    pcall(function()
        GameTooltip:SetOwner(owner, "ANCHOR_TOP")
        GameTooltip:SetText(text, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
end

local function hideTooltip()
    if type(GameTooltip) == "table" and type(GameTooltip.Hide) == "function" then
        pcall(GameTooltip.Hide, GameTooltip)
    end
end

-- Active Looks sub-tab (Issue #42): bidirectionally synced with Preview Deck.
local activeLooksSubTab = "player_target"
local looksSubTabRefresh = nil

function ns.getLooksSubTab()
    return activeLooksSubTab
end

function ns.setLooksSubTab(catKey, fromDeck)
    local valid = false
    for i = 1, #LOOK_CATEGORIES do
        if LOOK_CATEGORIES[i].key == catKey then valid = true; break end
    end
    if not valid then return end
    activeLooksSubTab = catKey
    if not fromDeck and type(ns.setPreviewDeckMode) == "function" then
        pcall(ns.setPreviewDeckMode, catKey, true)
    end
    if type(looksSubTabRefresh) == "function" then pcall(looksSubTabRefresh) end
end

function ns.jumpToTab(tabName, subTabKey)
    if type(subTabKey) == "string" and subTabKey ~= "" then
        ns.setLooksSubTab(subTabKey, false)
    end
    local d = DaylightUI
    local panel = type(d) == "table" and d.OptionsPanel
    if type(panel) == "table" and type(panel.PageFrame) == "function" then
        local pf = panel.PageFrame("Palettes.main")
        if type(pf) == "table" then
            if type(pf.SetTab) == "function" then
                pcall(pf.SetTab, tabName)
            else
                pf.tab = tabName
            end
        end
        if type(panel.Refresh) == "function" then pcall(panel.Refresh) end
    end
    refreshLooks()
end

-- Issue #41: Presets Tab — 6 core themes in 3x2 grid + split Recipe / My Presets footer.
local PRESET_GRID_CARD_H = 86
local PRESET_FOOTER_H = 154

local function buildPresetsPage(row)
    if row.made or type(CreateFrame) ~= "function" then return end
    row.made = true
    row.lines = {}
    local blend = type(ns.blendColor) == "function" and ns.blendColor or function(a) return a end

    local cards = {}
    for i = 1, #THEMES do
        local theme = THEMES[i]
        local paletteName, lookName = themePills(theme)
        local hold = CreateFrame("Button", nil, row)
        hold:SetHeight(PRESET_GRID_CARD_H)
        local card = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(hold) or nil

        -- Top row: Preset Name + status badge (Applied / Preview)
        local nameFs = uiFont(hold, 12, CREAM)
        nameFs:SetText(theme.name)
        if type(nameFs.SetWordWrap) == "function" then nameFs:SetWordWrap(false) end

        local badge = CreateFrame("Frame", nil, hold)
        badge:SetHeight(16)
        local badgeCard = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(badge) or nil
        local badgeFs = uiFont(badge, 9, AMBER_INK)
        badgeFs:SetText("")
        badgeFs:SetPoint("CENTER", badge, "CENTER", 0, 0)
        setShownSafe(badge, false)

        local check = drawCheck(hold)
        local onText = uiFont(hold, 10, ON_INK)
        onText:SetText("")
        setShownSafe(onText, false)

        -- Middle row: 3-stop swatch bar + 2 hero layer tags
        local swatch, preview = paletteSwatches(hold, theme.palette)
        local tagText = (type(theme.tags) == "table" and table.concat(theme.tags, " · ")) or (paletteName .. " · " .. lookName)
        local tagsFs = uiFont(hold, 10, DIM)
        tagsFs:SetText(tagText)
        if type(tagsFs.SetWordWrap) == "function" then tagsFs:SetWordWrap(false) end

        -- Bottom row: 1-line mood phrase
        local moodFs = uiFont(hold, 10, DIM)
        moodFs:SetText(theme.mood)
        if type(moodFs.SetWordWrap) == "function" then moodFs:SetWordWrap(false) end

        local pillAFs = uiFont(hold, 9, DIM)
        pillAFs:SetText(paletteName)
        setShownSafe(pillAFs, false)
        local pillBFs = uiFont(hold, 9, DIM)
        pillBFs:SetText(lookName)
        setShownSafe(pillBFs, false)

        local cue = hold:CreateTexture(nil, "OVERLAY")
        cue:SetWidth(3)
        cue:SetPoint("TOPLEFT", hold, "TOPLEFT", 0, 0)
        cue:SetPoint("BOTTOMLEFT", hold, "BOTTOMLEFT", 0, 0)
        setShownSafe(cue, false)

        local line = {
            id = theme.id, kind = "theme", name = nameFs, baseName = theme.name,
            mood = theme.mood, preview = preview, rowH = PRESET_GRID_CARD_H,
            button = hold, paletteId = theme.palette,
            palettePill = pillAFs, lookPill = pillBFs, cue = cue,
            onText = onText, check = check, badge = badge, badgeCard = badgeCard, badgeFs = badgeFs,
            swatch = swatch, tagsFs = tagsFs, desc = moodFs, card = card,
        }

        local function paintCard()
            local win, _, bnd, _, brd, acc, txt, lbl = activeSurface()
            local own = type(ns.byId) == "table" and ns.byId[theme.palette] or nil
            local cueCol = (own and own.c2) or acc
            local rest = blend(win, bnd, 0.28)
            local hover = blend(win, bnd, 0.52)
            local fill, edge, fa, ea = rest, brd, 0.90, 0.55
            local light = nil
            if line.markStaged or line.markOn or line.markPending then
                local source = own
                local window = (source and (source.window or source.background)) or win
                local inks = {}
                if source and source.title then inks[#inks + 1] = source.title end
                if source and source.text then inks[#inks + 1] = source.text end
                inks[#inks + 1] = CREAM
                if source and type(ns.accentWash) == "function" then
                    fill, light = ns.accentWash(cueCol, window, inks)
                else
                    fill, light = ROW_PICK, CREAM
                end
                edge = cueCol
                fa, ea = 1, line.markStaged and 1.0 or 0.95
            elseif line.hover then
                fill = hover
                edge = blend(brd, cueCol, 0.55)
                fa, ea = 0.94, 0.85
            end
            line.washColor = fill
            line.ink = light
            if card then card.paint(fill, fa, edge, ea) end
            setShownSafe(cue, false)
            if light then
                tintText(nameFs, light)
                tintText(tagsFs, light)
                tintText(moodFs, light)
                if type(cue.SetColorTexture) == "function" then
                    cue:SetColorTexture(cueCol[1], cueCol[2], cueCol[3], 1)
                end
                setShownSafe(cue, true)
            else
                tintText(nameFs, txt)
                tintText(tagsFs, lbl)
                tintText(moodFs, lbl)
            end
            setShownSafe(check, false)
            setShownSafe(onText, false)
            setShownSafe(badge, false)
            if line.markPending then
                onText:SetText("PENDING")
                tintText(onText, light or cueCol)
                setShownSafe(onText, true)
            elseif line.markStaged then
                badgeFs:SetText("PREVIEW")
                badge:SetWidth(52)
                if badgeCard then badgeCard.paint(AMBER_BG, 1, AMBER_BG, 1) end
                tintText(badgeFs, AMBER_INK)
                setShownSafe(badge, true)
            elseif line.markOn then
                badgeFs:SetText("APPLIED")
                badge:SetWidth(50)
                if badgeCard then badgeCard.paint(cueCol, 1, cueCol, 1) end
                tintText(badgeFs, AMBER_INK)
                setShownSafe(badge, true)
                local ck = light or cueCol
                if type(check.SetVertexColor) == "function" then
                    check:SetVertexColor(ck[1], ck[2], ck[3], 1)
                end
                setShownSafe(check, true)
            end
        end

        function line.SetOn(on, pending, staged)
            line.markOn = on and true or false
            line.markPending = pending and true or false
            line.markStaged = staged and true or false
            paintCard()
        end
        function line.SetHover(on)
            line.hover = on and true or false
            paintCard()
        end

        hold:SetScript("OnClick", function()
            local id, changed, pending = ns.shownTheme()
            local live = id == theme.id and not changed and not pending
            ns.setLooksOpen(true)
            if type(ns.stagePick) == "function" then
                ns.stagePick("theme", theme.id, function() applyTheme(theme) end, live, theme.name)
            else
                applyTheme(theme)
            end
            refreshLooks()
        end)
        hold:SetScript("OnEnter", function() line.SetHover(true) end)
        hold:SetScript("OnLeave", function() line.SetHover(false) end)

        row.lines[#row.lines + 1] = line
        cards[#cards + 1] = line
    end

    -- Two-Column Footer Split: Left = Preset Recipe Card, Right = My Presets (2x2)
    local recipeBox = CreateFrame("Frame", nil, row)
    recipeBox:SetHeight(PRESET_FOOTER_H)
    local recipeCard = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(recipeBox) or nil
    local recipeTitle = uiFont(recipeBox, 12, CREAM)
    row.recipeTitle = recipeTitle
    local recipeQuickSave = CreateFrame("Button", nil, recipeBox)
    recipeQuickSave:SetSize(116, 18)
    local quickSaveCard = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(recipeQuickSave) or nil
    local quickSaveFs = uiFont(recipeQuickSave, 10, CREAM)
    quickSaveFs:SetPoint("CENTER", recipeQuickSave, "CENTER", 0, 0)
    quickSaveFs:SetText("Save to My Presets")
    recipeQuickSave:SetScript("OnClick", function()
        local existing = ns.readMyPresets()
        for s = 1, MY_PRESET_SLOTS do
            if existing[s] == nil then
                local themeId = ns.readTheme()
                local t = themeId and themeById(themeId) or nil
                ns.saveMyPreset(s, t and (t.name .. " Custom") or ("My Setup " .. s))
                return
            end
        end
        say("Palettes: all 4 My Presets slots are full. Delete a slot to save a new one.")
    end)

    local recipeDesc = uiFont(recipeBox, 10, DIM)
    if type(recipeDesc.SetWordWrap) == "function" then recipeDesc:SetWordWrap(true) end

    local LAYER_DEFS = {
        { key = "palette", label = "Colour", tab = "Colours" },
        { key = "frame", label = "Player/Tgt", tab = "Looks", sub = "player_target" },
        { key = "focus", label = "Focus", tab = "Looks", sub = "focus" },
        { key = "tot", label = "ToT", tab = "Looks", sub = "tot" },
        { key = "party", label = "Party", tab = "Looks", sub = "party" },
        { key = "raid", label = "Raid", tab = "Looks", sub = "raid" },
        { key = "castbars", label = "Cast Bars", tab = "Looks", sub = "castbars" },
        { key = "actionbars", label = "Action Bars", tab = "Looks", sub = "actionbars" },
    }
    local layerButtons = {}
    for i = 1, #LAYER_DEFS do
        local def = LAYER_DEFS[i]
        local b = CreateFrame("Button", nil, recipeBox)
        b:SetHeight(28)
        local c = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(b) or nil
        local topFs = uiFont(b, 9, DIM)
        topFs:SetPoint("TOPLEFT", b, "TOPLEFT", 6, -3)
        topFs:SetText(def.label)
        local valFs = uiFont(b, 10, CREAM)
        valFs:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 6, 3)
        valFs:SetPoint("RIGHT", b, "RIGHT", -4, 0)
        if type(valFs.SetWordWrap) == "function" then valFs:SetWordWrap(false) end
        b:SetScript("OnClick", function()
            ns.jumpToTab(def.tab, def.sub)
        end)
        b:SetScript("OnEnter", function()
            showTooltip(b, "Click to edit " .. def.label .. " on the " .. def.tab .. " tab")
        end)
        b:SetScript("OnLeave", hideTooltip)
        layerButtons[#layerButtons + 1] = { def = def, btn = b, card = c, topFs = topFs, valFs = valFs }
    end

    -- Right Column: My Presets (2x2 grid, 4 slots)
    local myBox = CreateFrame("Frame", nil, row)
    myBox:SetHeight(PRESET_FOOTER_H)
    local myCard = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(myBox) or nil
    local myTitle = uiFont(myBox, 12, CREAM)
    myTitle:SetText("My Presets")
    local myCount = uiFont(myBox, 10, DIM)

    local mySlots = {}
    for s = 1, MY_PRESET_SLOTS do
        local slotBtn = CreateFrame("Button", nil, myBox)
        slotBtn:SetHeight(52)
        local sCard = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(slotBtn) or nil
        local sName = uiFont(slotBtn, 11, CREAM)
        if type(sName.SetWordWrap) == "function" then sName:SetWordWrap(false) end
        local sSub = uiFont(slotBtn, 10, DIM)
        if type(sSub.SetWordWrap) == "function" then sSub:SetWordWrap(false) end

        local swEdge = slotBtn:CreateTexture(nil, "BORDER")
        swEdge:SetSize(38, 12)
        local swBg = slotBtn:CreateTexture(nil, "ARTWORK")
        swBg:SetSize(10, 10)
        swBg:SetPoint("LEFT", swEdge, "LEFT", 1, 0)
        local swBand = slotBtn:CreateTexture(nil, "ARTWORK")
        swBand:SetSize(10, 10)
        swBand:SetPoint("LEFT", swBg, "RIGHT", 1, 0)
        local swAcc = slotBtn:CreateTexture(nil, "ARTWORK")
        swAcc:SetSize(14, 10)
        swAcc:SetPoint("LEFT", swBand, "RIGHT", 1, 0)

        local delBtn = CreateFrame("Button", nil, slotBtn)
        delBtn:SetSize(18, 18)
        delBtn:SetPoint("TOPRIGHT", slotBtn, "TOPRIGHT", -3, -3)
        local delFs = uiFont(delBtn, 11, DIM)
        delFs:SetPoint("CENTER", delBtn, "CENTER", 0, 0)
        delFs:SetText("x")
        setShownSafe(delBtn, false)

        delBtn:SetScript("OnClick", function()
            ns.deleteMyPreset(s)
        end)
        delBtn:SetScript("OnEnter", function() showTooltip(delBtn, "Delete saved preset") end)
        delBtn:SetScript("OnLeave", hideTooltip)

        slotBtn:SetScript("OnClick", function()
            local saved = ns.readMyPresets()[s]
            if type(saved) ~= "table" then
                local themeId = ns.readTheme()
                local t = themeId and themeById(themeId) or nil
                ns.saveMyPreset(s, t and (t.name .. " " .. s) or ("My Preset " .. s))
                return
            end
            ns.RevertPreview()
            ns.setLooksOpen(true)
            if type(ns.stagePick) == "function" then
                ns.stagePick("mypreset", "slot-" .. s, function() ns.applyMyPreset(saved) end, false, saved.name, saved.recipe)
            else
                ns.applyMyPreset(saved)
            end
            refreshLooks()
        end)
        slotBtn:SetScript("OnEnter", function()
            local saved = ns.readMyPresets()[s]
            if type(saved) == "table" then setShownSafe(delBtn, true) end
        end)
        slotBtn:SetScript("OnLeave", function()
            setShownSafe(delBtn, false)
        end)

        mySlots[s] = {
            btn = slotBtn, card = sCard, name = sName, sub = sSub,
            swEdge = swEdge, swBg = swBg, swBand = swBand, swAcc = swAcc, delBtn = delBtn,
        }
    end

    local combatNote = uiFont(row, 11, ON_INK)
    combatNote:SetText("Applies when combat ends.")
    setShownSafe(combatNote, false)

    local function layout()
        local w = type(row.GetWidth) == "function" and row:GetWidth() or 0
        if type(w) ~= "number" or w < 240 then w = 760 end
        local cols = w >= 540 and 3 or 2
        local cardW = math.floor((w - 8 - (cols - 1) * CARD_GAP_X) / cols)
        for i = 1, #cards do
            local s = cards[i]
            local idx = i - 1
            local r = math.floor(idx / cols)
            local c = idx - r * cols
            local x = 4 + c * (cardW + CARD_GAP_X)
            local y = 4 + r * (PRESET_GRID_CARD_H + CARD_GAP_Y)
            s.button:ClearAllPoints()
            s.button:SetPoint("TOPLEFT", row, "TOPLEFT", x, -y)
            s.button:SetWidth(cardW)
            s.name:ClearAllPoints()
            s.name:SetPoint("TOPLEFT", s.button, "TOPLEFT", 10, -8)
            s.name:SetWidth(math.max(60, cardW - 76))
            s.badge:ClearAllPoints()
            s.badge:SetPoint("TOPRIGHT", s.button, "TOPRIGHT", -8, -7)
            s.check:ClearAllPoints()
            s.check:SetPoint("RIGHT", s.badge, "LEFT", -3, 0)
            s.onText:ClearAllPoints()
            s.onText:SetPoint("TOPRIGHT", s.button, "TOPRIGHT", -8, -8)
            s.swatch:ClearAllPoints()
            s.swatch:SetPoint("TOPLEFT", s.button, "TOPLEFT", 10, -32)
            s.tagsFs:ClearAllPoints()
            s.tagsFs:SetPoint("LEFT", s.swatch, "RIGHT", 8, 0)
            s.tagsFs:SetPoint("RIGHT", s.button, "RIGHT", -8, 0)
            s.desc:ClearAllPoints()
            s.desc:SetPoint("BOTTOMLEFT", s.button, "BOTTOMLEFT", 10, 8)
            s.desc:SetPoint("RIGHT", s.button, "RIGHT", -10, 0)
        end

        local gridRows = math.ceil(#cards / cols)
        local footerY = 4 + gridRows * (PRESET_GRID_CARD_H + CARD_GAP_Y) + 8
        local halfW = math.floor((w - 8 - CARD_GAP_X) / 2)

        recipeBox:ClearAllPoints()
        recipeBox:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -footerY)
        recipeBox:SetWidth(halfW)
        recipeTitle:ClearAllPoints()
        recipeTitle:SetPoint("TOPLEFT", recipeBox, "TOPLEFT", 10, -8)
        recipeQuickSave:ClearAllPoints()
        recipeQuickSave:SetPoint("TOPRIGHT", recipeBox, "TOPRIGHT", -8, -6)
        recipeDesc:ClearAllPoints()
        recipeDesc:SetPoint("TOPLEFT", recipeBox, "TOPLEFT", 10, -26)
        recipeDesc:SetWidth(math.max(120, halfW - 20))

        local pillW = math.floor((halfW - 20 - 3 * 5) / 4)
        for i = 1, #layerButtons do
            local lb = layerButtons[i]
            local idx = i - 1
            local lr = math.floor(idx / 4)
            local lc = idx - lr * 4
            local lx = 10 + lc * (pillW + 5)
            local ly = 84 + lr * 33
            lb.btn:ClearAllPoints()
            lb.btn:SetPoint("TOPLEFT", recipeBox, "TOPLEFT", lx, -ly)
            lb.btn:SetWidth(pillW)
        end

        myBox:ClearAllPoints()
        myBox:SetPoint("TOPLEFT", row, "TOPLEFT", 4 + halfW + CARD_GAP_X, -footerY)
        myBox:SetWidth(halfW)
        myTitle:ClearAllPoints()
        myTitle:SetPoint("TOPLEFT", myBox, "TOPLEFT", 10, -8)
        myCount:ClearAllPoints()
        myCount:SetPoint("TOPRIGHT", myBox, "TOPRIGHT", -10, -9)

        local slotW = math.floor((halfW - 20 - 6) / 2)
        for s = 1, MY_PRESET_SLOTS do
            local sl = mySlots[s]
            local idx = s - 1
            local sr = math.floor(idx / 2)
            local sc = idx - sr * 2
            local sx = 10 + sc * (slotW + 6)
            local sy = 32 + sr * 58
            sl.btn:ClearAllPoints()
            sl.btn:SetPoint("TOPLEFT", myBox, "TOPLEFT", sx, -sy)
            sl.btn:SetWidth(slotW)
        end

        combatNote:ClearAllPoints()
        combatNote:SetPoint("TOPLEFT", row, "TOPLEFT", 6, -(footerY + PRESET_FOOTER_H + 6))
    end

    function row.UpdateLooks()
        local win, bg, bnd, _, brd, acc, txt, lbl = activeSurface()
        local waiting = type(looksPending) == "table"
        setShownSafe(combatNote, waiting)

        local shownId, changed, pendingTheme = ns.shownTheme()
        local staged = ns.staged
        local stagedThemeId = (type(staged) == "table" and (staged.baseKind == "theme" or staged.kind == "theme"))
            and (staged.baseId or staged.id) or nil

        for i = 1, #cards do
            local line = cards[i]
            local pending = rowPending("theme", line.id)
            local on = (shownId == line.id and not changed and not pendingTheme)
            local isStaged = (stagedThemeId == line.id)
            line.SetOn(on, pending, isStaged)
        end

        -- Update Preset Recipe card
        if recipeCard then recipeCard.paint(bg, 0.92, brd, 0.70) end
        local focusTheme = (stagedThemeId and themeById(stagedThemeId))
            or (shownId and themeById(shownId))
            or THEMES[1]
        local hasStagedTweaks = type(staged) == "table" and (staged.palette ~= nil or staged.frame ~= nil or (type(staged.looks) == "table" and next(staged.looks) ~= nil))
        local isModified = (shownId ~= nil and changed == true and stagedThemeId == nil) or (stagedThemeId ~= nil and hasStagedTweaks)
        if isModified then
            recipeTitle:SetText("Custom (based on " .. (focusTheme and focusTheme.name or "Preset") .. ")")
            recipeDesc:SetText("Modified from " .. (focusTheme and focusTheme.name or "Preset") .. ". Click any layer below to tweak or save to My Presets.")
            setShownSafe(recipeQuickSave, true)
            if quickSaveCard then quickSaveCard.paint(bnd, 0.95, acc, 0.85) end
            tintText(quickSaveFs, acc)
        else
            recipeTitle:SetText((focusTheme and focusTheme.name or "Preset") .. " Recipe")
            recipeDesc:SetText(focusTheme and focusTheme.rationale or THEME_INTRO)
            setShownSafe(recipeQuickSave, false)
        end
        tintText(recipeTitle, txt)
        tintText(recipeDesc, lbl)

        local baseRec = (stagedThemeId and focusTheme) or (isModified and ns.currentRecipe()) or focusTheme or ns.currentRecipe()
        local rec = {
            palette = (type(staged) == "table" and staged.palette) or baseRec.palette,
            frame = (type(staged) == "table" and staged.frame) or baseRec.frame,
            focus = (type(staged) == "table" and type(staged.looks) == "table" and staged.looks.focus) or baseRec.focus,
            tot = (type(staged) == "table" and type(staged.looks) == "table" and staged.looks.tot) or baseRec.tot,
            party = (type(staged) == "table" and type(staged.looks) == "table" and staged.looks.party) or baseRec.party,
            raid = (type(staged) == "table" and type(staged.looks) == "table" and staged.looks.raid) or baseRec.raid,
            castbars = (type(staged) == "table" and type(staged.looks) == "table" and staged.looks.castbars) or baseRec.castbars,
            actionbars = (type(staged) == "table" and type(staged.looks) == "table" and staged.looks.actionbars) or baseRec.actionbars,
        }
        for i = 1, #layerButtons do
            local lb = layerButtons[i]
            if lb.card then lb.card.paint(blend(win, bnd, 0.45), 0.90, brd, 0.65) end
            tintText(lb.topFs, lbl)
            tintText(lb.valFs, txt)
            local key = lb.def.key
            local valText = "—"
            if key == "palette" then
                valText = partLabel("palette", rec.palette)
            elseif key == "frame" then
                valText = partLabel("frame", rec.frame)
            else
                valText = ns.categoryLookName(key, rec[key])
            end
            lb.valFs:SetText(valText)
        end

        -- Update My Presets 2x2 slots
        if myCard then myCard.paint(bg, 0.92, brd, 0.70) end
        tintText(myTitle, txt)
        tintText(myCount, lbl)
        local savedList = ns.readMyPresets()
        local used = 0
        for s = 1, MY_PRESET_SLOTS do
            local sl = mySlots[s]
            local entry = savedList[s]
            local isStagedSlot = (type(staged) == "table" and staged.kind == "mypreset" and staged.id == ("slot-" .. s))
            if type(entry) == "table" then
                used = used + 1
                if sl.card then
                    sl.card.paint(
                        isStagedSlot and blend(win, acc, 0.18) or blend(win, bnd, 0.35),
                        0.94,
                        isStagedSlot and acc or brd,
                        isStagedSlot and 0.95 or 0.65
                    )
                end
                sl.name:ClearAllPoints()
                sl.name:SetPoint("TOPLEFT", sl.btn, "TOPLEFT", 8, -7)
                sl.name:SetPoint("RIGHT", sl.btn, "RIGHT", -22, 0)
                sl.name:SetText(entry.name or ("Preset " .. s))
                tintText(sl.name, txt)

                sl.swEdge:ClearAllPoints()
                sl.swEdge:SetPoint("BOTTOMLEFT", sl.btn, "BOTTOMLEFT", 8, 8)
                local pal = type(entry.recipe) == "table" and type(ns.byId) == "table" and ns.byId[entry.recipe.palette] or nil
                paintChip(sl.swEdge, (pal and pal.border) or { 0.05, 0.05, 0.05 })
                paintChip(sl.swBg, (pal and pal.background) or bg)
                paintChip(sl.swBand, (pal and pal.band) or bnd)
                paintChip(sl.swAcc, (pal and pal.c2) or acc)
                setShownSafe(sl.swEdge, true)
                setShownSafe(sl.swBg, true)
                setShownSafe(sl.swBand, true)
                setShownSafe(sl.swAcc, true)

                sl.sub:ClearAllPoints()
                sl.sub:SetPoint("LEFT", sl.swEdge, "RIGHT", 6, 0)
                sl.sub:SetPoint("RIGHT", sl.btn, "RIGHT", -6, 0)
                sl.sub:SetText(partLabel("frame", type(entry.recipe) == "table" and entry.recipe.frame or nil))
                tintText(sl.sub, lbl)
                setShownSafe(sl.sub, true)
            else
                if sl.card then sl.card.paint(blend(win, bnd, 0.16), 0.72, brd, 0.50) end
                sl.name:ClearAllPoints()
                sl.name:SetPoint("CENTER", sl.btn, "CENTER", 0, 0)
                sl.name:SetText("+ Save Current")
                tintText(sl.name, lbl)
                setShownSafe(sl.sub, false)
                setShownSafe(sl.swEdge, false)
                setShownSafe(sl.swBg, false)
                setShownSafe(sl.swBand, false)
                setShownSafe(sl.swAcc, false)
                setShownSafe(sl.delBtn, false)
            end
        end
        myCount:SetText(tostring(used) .. " / " .. tostring(MY_PRESET_SLOTS) .. " slots")

        layout()
    end

    hookSize(row, function()
        if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
    end)
    row.UpdateLooks()
    refreshers[#refreshers + 1] = function()
        if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
    end
end

function ns.themesPage()
    return {
        id = "themes",
        label = "Presets",
        desc = THEME_INTRO,
        groups = {
            {
                tab = "Presets",
                label = "Presets",
                wide = true,
                items = {
                    {
                        type = "custom",
                        label = "Presets",
                        hidden = hiddenStyles,
                        build = buildPresetsPage,
                        update = function(row)
                            if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
                        end,
                        height = function()
                            return 4 + 2 * (PRESET_GRID_CARD_H + CARD_GAP_Y) + 8 + PRESET_FOOTER_H + 16
                        end,
                    },
                },
            },
        },
    }
end

-- Issue #42: Looks Tab — Single-row 7 sub-tabs + bidirectional Preview Deck sync + dynamic Match labels.
local SUBTAB_H = 24
local LOOK_OPTION_H = 62

local function buildLooksTabPage(row)
    if row.made or type(CreateFrame) ~= "function" then return end
    row.made = true
    row.lines = {}
    local blend = type(ns.blendColor) == "function" and ns.blendColor or function(a) return a end

    -- Single-row 7 sub-tabs
    local subButtons = {}
    for i = 1, #LOOK_CATEGORIES do
        local cat = LOOK_CATEGORIES[i]
        local b = CreateFrame("Button", nil, row)
        b:SetHeight(SUBTAB_H)
        local c = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(b) or nil
        local fs = uiFont(b, 11, CREAM)
        fs:SetPoint("CENTER", b, "CENTER", 0, 0)
        fs:SetText(cat.short)
        b:SetScript("OnClick", function()
            ns.setLooksSubTab(cat.key, false)
        end)
        if cat.tooltip then
            b:SetScript("OnEnter", function() showTooltip(b, cat.tooltip) end)
            b:SetScript("OnLeave", hideTooltip)
        end
        subButtons[#subButtons + 1] = { cat = cat, btn = b, card = c, fs = fs }
    end

    -- Build option cards for all 7 categories
    local catCards = {}
    local function addOptionCard(catKey, opt)
        local hold = CreateFrame("Button", nil, row)
        hold:SetHeight(LOOK_OPTION_H)
        local card = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(hold) or nil
        local icon = (catKey == "player_target" and ICONS[opt.id]) and drawIcon(hold, ICONS[opt.id]) or nil
        local nameFs = uiFont(hold, 12, CREAM)
        nameFs:SetText(opt.name)
        if type(nameFs.SetWordWrap) == "function" then nameFs:SetWordWrap(false) end

        local matchFs = uiFont(hold, 10, ON_INK)
        matchFs:SetText("")
        setShownSafe(matchFs, false)

        local descFs = uiFont(hold, 10, DIM)
        descFs:SetText(opt.desc or "")
        if type(descFs.SetWordWrap) == "function" then descFs:SetWordWrap(true) end

        local badge = CreateFrame("Frame", nil, hold)
        badge:SetHeight(16)
        local badgeCard = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(badge) or nil
        local badgeFs = uiFont(badge, 9, AMBER_INK)
        badgeFs:SetPoint("CENTER", badge, "CENTER", 0, 0)
        setShownSafe(badge, false)
        local check = drawCheck(hold)

        local onText = uiFont(hold, 10, ON_INK)
        onText:SetText("")
        setShownSafe(onText, false)
        local keyFs = uiFont(hold, 10, DIM)
        keyFs:SetText(opt.id)
        setShownSafe(keyFs, false)

        local line = {
            id = opt.id, kind = (catKey == "player_target") and "frame" or "look",
            catKey = catKey, isMatch = opt.isMatch == true,
            name = nameFs, baseName = opt.name, desc = descFs, matchFs = matchFs,
            button = hold, card = card, icon = icon, key = keyFs, onText = onText,
            badge = badge, badgeCard = badgeCard, badgeFs = badgeFs, check = check,
            rowH = LOOK_OPTION_H,
        }

        local function paint()
            local win, _, bnd, _, brd, acc, txt, lbl = activeSurface()
            local screenId = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
            local screen = type(screenId) == "string" and type(ns.byId) == "table" and ns.byId[screenId] or nil
            local rest = blend(win, bnd, 0.28)
            local hover = blend(win, bnd, 0.52)
            local fill, edge, fa, ea = rest, brd, 0.90, 0.55
            local light = nil
            if line.markStaged or line.markOn or line.markPending then
                local inks = {}
                if screen and screen.title then inks[#inks + 1] = screen.title end
                if screen and screen.text then inks[#inks + 1] = screen.text end
                inks[#inks + 1] = CREAM
                if screen and type(ns.accentWash) == "function" then
                    fill, light = ns.accentWash(acc, screen.window or screen.background or win, inks)
                else
                    fill, light = ROW_PICK, CREAM
                end
                edge = acc
                fa, ea = 1, line.markStaged and 1.0 or 0.95
            elseif line.hover then
                fill, edge, fa, ea = hover, blend(brd, acc, 0.55), 0.94, 0.85
            end
            line.washColor = fill
            line.ink = light
            if card then card.paint(fill, fa, edge, ea) end
            tintText(nameFs, light or txt)
            tintText(descFs, light or lbl)
            tintText(matchFs, light or acc)
            setShownSafe(badge, false)
            setShownSafe(check, false)
            setShownSafe(onText, false)
            if line.markPending then
                onText:SetText("PENDING")
                tintText(onText, light or acc)
                setShownSafe(onText, true)
            elseif line.markStaged then
                badgeFs:SetText("PREVIEW")
                badge:SetWidth(52)
                if badgeCard then badgeCard.paint(AMBER_BG, 1, AMBER_BG, 1) end
                tintText(badgeFs, AMBER_INK)
                setShownSafe(badge, true)
            elseif line.markOn then
                badgeFs:SetText("APPLIED")
                badge:SetWidth(50)
                if badgeCard then badgeCard.paint(acc, 1, acc, 1) end
                tintText(badgeFs, AMBER_INK)
                setShownSafe(badge, true)
                local ck = light or acc
                if type(check.SetVertexColor) == "function" then
                    check:SetVertexColor(ck[1], ck[2], ck[3], 1)
                end
                setShownSafe(check, true)
            end
        end

        function line.SetOn(on, pending, staged)
            line.markOn = on and true or false
            line.markPending = pending and true or false
            line.markStaged = staged and true or false
            paint()
        end
        function line.SetHover(on)
            line.hover = on and true or false
            paint()
        end

        hold:SetScript("OnClick", function()
            ns.setLooksOpen(true)
            if catKey == "player_target" then
                local live = wornFrame() == opt.id
                if type(ns.stagePick) == "function" then
                    ns.stagePick("frame", opt.id, function() applyFrame(opt.id) end, live, opt.name)
                else
                    applyFrame(opt.id)
                end
            else
                local live = ns.readLookPick(catKey) == opt.id
                if type(ns.stagePick) == "function" then
                    ns.stagePick("look", opt.id, function() ns.applyCategoryLook(catKey, opt.id) end, live, opt.name, nil, catKey)
                else
                    ns.applyCategoryLook(catKey, opt.id)
                end
            end
            refreshLooks()
        end)
        hold:SetScript("OnEnter", function() line.SetHover(true) end)
        hold:SetScript("OnLeave", function() line.SetHover(false) end)

        row.lines[#row.lines + 1] = line
        catCards[catKey] = catCards[catKey] or {}
        catCards[catKey][#catCards[catKey] + 1] = line
    end

    for i = 1, #FRAMES do addOptionCard("player_target", FRAMES[i]) end
    for i = 2, #LOOK_CATEGORIES do
        local ck = LOOK_CATEGORIES[i].key
        local opts = EXTRA_LOOKS[ck] or {}
        for j = 1, #opts do addOptionCard(ck, opts[j]) end
    end

    local combatNote = uiFont(row, 11, ON_INK)
    combatNote:SetText("Applies when combat ends.")
    setShownSafe(combatNote, false)

    local function layout()
        local w = type(row.GetWidth) == "function" and row:GetWidth() or 0
        if type(w) ~= "number" or w < 240 then w = 760 end
        -- Single-row 7 sub-tabs fit comfortably across ~760px
        local gap = 4
        local totalGap = gap * (#subButtons - 1)
        local avail = w - 8 - totalGap
        local weights = { 1.55, 0.85, 0.65, 0.85, 0.78, 1.12, 1.20 }
        local sumW = 0
        for i = 1, #weights do sumW = sumW + weights[i] end
        local sx = 4
        for i = 1, #subButtons do
            local sb = subButtons[i]
            local bw = math.floor(avail * (weights[i] / sumW))
            sb.btn:ClearAllPoints()
            sb.btn:SetPoint("TOPLEFT", row, "TOPLEFT", sx, -4)
            sb.btn:SetWidth(bw)
            sx = sx + bw + gap
        end

        local cols = w >= 520 and 2 or 1
        local cardW = math.floor((w - 8 - (cols - 1) * CARD_GAP_X) / cols)
        local topY = SUBTAB_H + 14
        local shownCount = 0
        for ck, list in pairs(catCards) do
            local vis = (ck == activeLooksSubTab)
            for i = 1, #list do
                local s = list[i]
                setShownSafe(s.button, vis)
                if vis then
                    local idx = i - 1
                    local r = math.floor(idx / cols)
                    local c = idx - r * cols
                    local x = 4 + c * (cardW + CARD_GAP_X)
                    local y = topY + r * (LOOK_OPTION_H + CARD_GAP_Y)
                    s.button:ClearAllPoints()
                    s.button:SetPoint("TOPLEFT", row, "TOPLEFT", x, -y)
                    s.button:SetWidth(cardW)
                    if s.icon then
                        s.icon:ClearAllPoints()
                        s.icon:SetPoint("TOPLEFT", s.button, "TOPLEFT", 10, -8)
                        s.name:ClearAllPoints()
                        s.name:SetPoint("LEFT", s.icon, "RIGHT", 8, 0)
                    else
                        s.name:ClearAllPoints()
                        s.name:SetPoint("TOPLEFT", s.button, "TOPLEFT", 10, -8)
                    end
                    s.matchFs:ClearAllPoints()
                    s.matchFs:SetPoint("LEFT", s.name, "RIGHT", 8, 0)
                    s.badge:ClearAllPoints()
                    s.badge:SetPoint("TOPRIGHT", s.button, "TOPRIGHT", -8, -7)
                    s.check:ClearAllPoints()
                    s.check:SetPoint("RIGHT", s.badge, "LEFT", -3, 0)
                    s.desc:ClearAllPoints()
                    s.desc:SetPoint("TOPLEFT", s.button, "TOPLEFT", 10, -28)
                    s.desc:SetWidth(math.max(100, cardW - 20))
                    shownCount = shownCount + 1
                end
            end
        end
        local rows = math.max(1, math.ceil(shownCount / cols))
        combatNote:ClearAllPoints()
        combatNote:SetPoint("TOPLEFT", row, "TOPLEFT", 6, -(topY + rows * (LOOK_OPTION_H + CARD_GAP_Y) + 4))
    end

    function row.UpdateLooks()
        local win, _, bnd, _, brd, acc, txt, lbl = activeSurface()
        setShownSafe(combatNote, type(looksPending) == "table")
        for i = 1, #subButtons do
            local sb = subButtons[i]
            local active = sb.cat.key == activeLooksSubTab
            if sb.card then
                sb.card.paint(
                    active and blend(win, acc, 0.18) or blend(win, bnd, 0.24),
                    0.92,
                    active and acc or brd,
                    active and 0.95 or 0.55
                )
            end
            tintText(sb.fs, active and acc or txt)
        end

        local staged = ns.staged
        local stagedTheme = (type(staged) == "table" and (staged.baseKind == "theme" or staged.kind == "theme"))
            and themeById(staged.baseId or staged.id) or nil
        local stagedRec = (type(staged) == "table" and (staged.baseKind == "mypreset" or staged.kind == "mypreset") and type(staged.recipe) == "table")
            and staged.recipe or nil
        local stagedPT = (type(staged) == "table" and staged.frame)
            or (type(staged) == "table" and staged.kind == "frame" and staged.id)
            or (stagedTheme and stagedTheme.frame)
            or (stagedRec and stagedRec.frame)
        local activePT = stagedPT or wornFrame() or "beam"
        local activePTName = partLabel("frame", activePT)

        for ck, list in pairs(catCards) do
            local activeId = (ck == "player_target") and wornFrame() or ns.readLookPick(ck)
            local stagedForCat = nil
            if ck == "player_target" then
                stagedForCat = stagedPT
            elseif type(staged) == "table" then
                stagedForCat = (type(staged.looks) == "table" and staged.looks[ck])
                    or (staged.kind == "look" and staged.catKey == ck and staged.id)
                    or (stagedTheme and stagedTheme[ck])
                    or (stagedRec and stagedRec[ck])
            end
            for i = 1, #list do
                local line = list[i]
                local isStaged = (stagedForCat ~= nil and stagedForCat == line.id)
                if line.isMatch then
                    line.matchFs:SetText("Currently: " .. activePTName)
                    setShownSafe(line.matchFs, true)
                else
                    setShownSafe(line.matchFs, false)
                end
                line.SetOn(activeId == line.id, rowPending(line.kind, line.id), isStaged)
            end
        end
        layout()
    end

    looksSubTabRefresh = function()
        if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
    end
    hookSize(row, looksSubTabRefresh)
    row.UpdateLooks()
    refreshers[#refreshers + 1] = looksSubTabRefresh
end

function ns.looksPage()
    return {
        id = "looks",
        label = "Looks",
        desc = LOOKS_INTRO,
        groups = {
            {
                tab = "Looks",
                label = "Looks",
                wide = true,
                items = {
                    {
                        type = "custom",
                        label = "Looks",
                        hidden = hiddenStyles,
                        build = buildLooksTabPage,
                        update = function(row)
                            if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
                        end,
                        height = function()
                            return SUBTAB_H + 14 + 4 * (LOOK_OPTION_H + CARD_GAP_Y) + 20
                        end,
                    },
                },
            },
        },
    }
end

-- 0.4.2 and earlier wrote look.style = "Looks:<frame>". Once, a leftover one
-- goes back to daylight, and a saved frame name that was retired takes the
-- look that replaced it. The standalone Looks add-on owns its own Looks:
-- styles, so with it loaded the style is left alone. When Daylight can't be
-- read yet, nothing is marked done and the next login tries again.
function ns.migrateFrames()
    local account = type(ns.accountTable) == "function" and ns.accountTable() or nil
    local char = type(ns.charTable) == "function" and ns.charTable() or nil
    local slots = { account, char }
    for i = 1, 2 do
        local slot = slots[i]
        if type(slot) == "table" then
            if type(slot.frame) == "string" then slot.frame = resolveFrame(slot.frame) or slot.frame end
            slot.glow = nil
            if type(slot.looks) == "table" then slot.looks.frame = nil end
        end
    end
    local d = DaylightUI
    if type(d) == "table" and type(d.Get) == "function" and type(d.Set) == "function" then
        local stored = select(1, readSetting("Palettes", "frame"))
        local fixed = type(stored) == "string" and resolveFrame(stored) or nil
        if fixed and fixed ~= stored then
            ns.writingLooks = true
            pcall(d.Set, d, "Palettes", "frame", fixed)
            ns.writingLooks = false
        end
    end
    if type(account) ~= "table" or account.framesMigrated == true then return end
    if looksAddonLoaded() then return end
    local style, readable = readSetting("UnitFrames", "look.style")
    if not readable or style == nil then return end
    local prefix = "Looks:"
    if type(style) == "string" and string.sub(style, 1, #prefix) == prefix then
        if not pcall(d.Set, d, "UnitFrames", "look.style", "daylight") then return end
    end
    account.framesMigrated = true
end

function ns.noteLooksAddon()
    if ns.looksBothSaid or not looksAddonLoaded() then return end
    ns.looksBothSaid = true
    ns.looksShared = true
    say(BOTH)
end

function ns.bootLooks()
    local api = apiOf()
    if type(api) ~= "table" or api.major ~= 1 or type(api.minor) ~= "number" or api.minor < 7 then
        return
    end
    if api.minor < 9 then
        ns.looksReady = false
        ns.looksGuard = NEED_STYLES
        say(NEED_STYLES)
        return
    end
    ns.looksGuard = nil
    view = type(api.For) == "function" and api.For("Looks") or nil
    if looksAddonLoaded() then
        ns.looksReady = true
        ns.noteLooksAddon()
        return
    end
    ns.looksReady = true
end

if type(SlashCmdList) == "table" then
    SLASH_LOOKS1 = "/looks"
    SlashCmdList.LOOKS = function(msg)
        if not pcall(ns.looksSlash, msg) then
            say("Looks: something went wrong, and no style was changed.")
        end
    end
end
