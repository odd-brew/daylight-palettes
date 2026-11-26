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
    { id = "flagon", name = "Flagon", desc = "A small boss and a deep cup, the name cut into the lip." },
    { id = "trestle", name = "Trestle", desc = "A full portrait on a named board, with power hung as a rail." },
    { id = "beam", name = "Beam", desc = "Sturdy Daylight bars with a full-width dark name tab and an angled 2.0 portrait socket." },
    { id = "stream", name = "Stream", desc = "Slim Ribbon bar with a floating name row, thin power underline, and a rounded 2.0 portrait sized to the bar stack." },
    { id = "ledger", name = "Ledger", desc = "Portrait-free square bars with a floating name above, crisp corners, and dual health and power numbers." },
    { id = "crest", name = "Crest", desc = "Tall hero bars with a 3D classic portrait, thick class ring, fitted tab, and bold health number." },
    { id = "slate", name = "Slate", desc = "Low-profile, portrait-free Ribbon bar with sharp corners and a thin power strip." },
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

-- Extra frames styled only when the user opts into "Also style Focus & Target of Target".
-- Widths are intentionally never touched so custom Focus/ToT layouts stay intact.
local FOCUS_UNITS = { "focus", "targettarget" }
local FOCUS_KEYS = {}

local function focusStylePairs(unit, spec)
    local list = {}
    local function put(key, value) list[#list + 1] = { unit .. "." .. key, value } end
    put("style", spec.style)
    put("slant", spec.slant)
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
    if unit == "focus" then
        put("portrait", spec.portrait)
        put("portraitLook", spec.portraitLook)
        put("portraitShape", spec.portraitShape)
        put("portraitRing", spec.ring)
        put("portraitRingWidth", spec.ringWidth)
        put("portraitRingLine", true)
    end
    put("nameOnBar", spec.nameOnBar)
    put("namePos", spec.namePos)
    put("bigNumber", spec.bigNumber)
    return list
end

for fu = 1, #FOCUS_UNITS do
    local pairsForUnit = focusStylePairs(FOCUS_UNITS[fu], LOOK_SPECS.flagon)
    for fi = 1, #pairsForUnit do FOCUS_KEYS[#FOCUS_KEYS + 1] = pairsForUnit[fi][1] end
end

-- Party & Raid frames styled only when the user opts into "Also style Party & Raid frames".
-- Only shell border/corner/shadow are written so group widths, heights, and grid layout stay intact.
local GROUP_UNITS = { "party", "raid" }
local GROUP_KEYS = {}

local function groupStylePairs(unit, spec)
    local list = {}
    local function put(key, value) list[#list + 1] = { unit .. "." .. key, value } end
    put("shell.own", true)
    put("shell.borderPx", spec.border)
    put("shell.cornerPx", spec.corner)
    put("shell.shadowPx", spec.shadow)
    return list
end

for gu = 1, #GROUP_UNITS do
    local pairsForGroup = groupStylePairs(GROUP_UNITS[gu], LOOK_SPECS.flagon)
    for gi = 1, #pairsForGroup do GROUP_KEYS[#GROUP_KEYS + 1] = pairsForGroup[gi][1] end
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
    { id = "hearthnight", name = "Hearthnight", palette = "ember", frame = "beam", mood = "A winter hearth of campfire gold on a dark, named beam." },
    { id = "harvestide", name = "Harvestide", palette = "vanilla", frame = "stream", mood = "Harvest light on dark oak and pewter, along a slim ribbon bar." },
    { id = "tidemark", name = "Tidemark", palette = "tide", frame = "slate", mood = "Cool sea-green at the waterline on a low-profile slate bar." },
    { id = "oldroad", name = "Old Road", palette = "forever", frame = "beam", mood = "Near-black soot and weathered bronze on a sturdy beam." },
    { id = "vigil", name = "Vigil", palette = "paladin", frame = "stream", mood = "Rose on warm plum-brown, with a slim ribbon bar and round portrait." },
    { id = "snug", name = "Snug", palette = "gilded", frame = "flagon", mood = "A deep gold cup with a rounded portrait in the quiet corner." },
    { id = "bellows", name = "Bellows", palette = "forgeglow", frame = "trestle", mood = "A named work board with a full portrait and hung power rail." },
    { id = "drawwell", name = "Drawwell", palette = "shaman", frame = "ledger", mood = "Storm-grey water in a deep, portrait-free square basin." },
    { id = "settle", name = "Settle", palette = "keepstone", frame = "beam", mood = "A walnut beam with a full-width tab, like a high-backed bench by the fire." },
    { id = "afterhours", name = "After Hours", palette = "carmine-night", frame = "beam", mood = "Deep carmine night on a sturdy beam, after the room has gone quiet." },
}
ns.themes = THEMES

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

-- Every frame write goes through DaylightUI.Batch, so the frames repaint once.
local function batch(fn)
    local d = DaylightUI
    if type(d) == "table" and type(d.Batch) == "function" then
        return pcall(d.Batch, fn)
    end
    return pcall(fn)
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

local function scopeFocusOn()
    return select(1, readSetting("Palettes", "scopeFocus")) == true
end

local function scopeGroupOn()
    return select(1, readSetting("Palettes", "scopeGroup")) == true
end

-- The live value of every key Palettes may write: the look keys, both sizes
-- sets, the Flagon extras, and Focus/ToT/Party/Raid keys when opted in.
local function readFrameValues()
    local d = DaylightUI
    if type(d) ~= "table" or type(d.Get) ~= "function" then return nil end
    local values = readValues(FRAME_KEYS, {})
    readValues(SIZE_KEYS, values)
    readValues(EXTRA_KEYS, values)
    if scopeFocusOn() then readValues(FOCUS_KEYS, values) end
    if scopeGroupOn() then readValues(GROUP_KEYS, values) end
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
    if scopeFocusOn() and LOOK_SPECS[id] then
        for u = 1, #FOCUS_UNITS do
            local fp = focusStylePairs(FOCUS_UNITS[u], LOOK_SPECS[id])
            for i = 1, #fp do list[#list + 1] = fp[i] end
        end
    end
    if scopeGroupOn() and LOOK_SPECS[id] then
        for u = 1, #GROUP_UNITS do
            local gp = groupStylePairs(GROUP_UNITS[u], LOOK_SPECS[id])
            for i = 1, #gp do list[#list + 1] = gp[i] end
        end
    end
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
    local sets = { SIZE_KEYS, FRAME_KEYS, EXTRA_KEYS, FOCUS_KEYS, GROUP_KEYS }
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
    end
    storeSnapshot(out)
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
    if scopeFocusOn() then
        want["focus."] = true
        want["targettarget."] = true
    end
    if scopeGroupOn() then
        want["party."] = true
        want["raid."] = true
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

function ns.RevertPreview()
    previewWant = nil
    previewSync()
end

function ns.CommitPreview(write)
    previewWant = nil
    previewSync()
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

-- The staged frame, bar, button, or preset pick is what shows while Presets or Looks is open.
function ns.syncFramePreview()
    local staged = ns.staged
    if looksOpen and type(staged) == "table" then
        if staged.kind == "frame" and frameById(staged.id) then
            if type(ns.RevertAllExtrasPreview) == "function" then ns.RevertAllExtrasPreview() end
            ns.BeginPreview(staged.id)
            return
        elseif staged.kind == "bar" then
            ns.RevertPreview()
            if type(ns.RevertButtonPreview) == "function" then ns.RevertButtonPreview() end
            if type(ns.BeginBarPreview) == "function" then ns.BeginBarPreview(staged.id) end
            return
        elseif staged.kind == "button" then
            ns.RevertPreview()
            if type(ns.RevertBarPreview) == "function" then ns.RevertBarPreview() end
            if type(ns.BeginButtonPreview) == "function" then ns.BeginButtonPreview(staged.id) end
            return
        elseif staged.kind == "theme" then
            local theme = themeById(staged.id)
            if theme and frameById(theme.frame) then
                ns.BeginPreview(theme.frame)
            else
                ns.RevertPreview()
            end
            local ex = type(ns.PRESET_EXTRAS) == "table" and ns.PRESET_EXTRAS[staged.id] or nil
            if ex and ex.bar and type(ns.BeginBarPreview) == "function" then
                ns.BeginBarPreview(ex.bar)
            elseif type(ns.RevertBarPreview) == "function" then
                ns.RevertBarPreview()
            end
            if ex and ex.button and type(ns.BeginButtonPreview) == "function" then
                ns.BeginButtonPreview(ex.button)
            elseif type(ns.RevertButtonPreview) == "function" then
                ns.RevertButtonPreview()
            end
            return
        elseif staged.kind == "user_preset" then
            if staged.frame and frameById(staged.frame) then
                ns.BeginPreview(staged.frame)
            else
                ns.RevertPreview()
            end
            if staged.bar and type(ns.BeginBarPreview) == "function" then
                ns.BeginBarPreview(staged.bar)
            elseif type(ns.RevertBarPreview) == "function" then
                ns.RevertBarPreview()
            end
            if staged.button and type(ns.BeginButtonPreview) == "function" then
                ns.BeginButtonPreview(staged.button)
            elseif type(ns.RevertButtonPreview) == "function" then
                ns.RevertButtonPreview()
            end
            return
        end
    end
    ns.RevertPreview()
    if type(ns.RevertAllExtrasPreview) == "function" then ns.RevertAllExtrasPreview() end
end

-- Drops an unapplied frame/bar/button/preset pick and its preview.
function ns.dropFramePreview()
    local staged = ns.staged
    if type(staged) == "table" and (staged.kind == "frame" or staged.kind == "bar" or staged.kind == "button" or staged.kind == "theme" or staged.kind == "user_preset") then
        ns.staged = nil
        refreshLooks()
    end
    ns.RevertPreview()
    if type(ns.RevertAllExtrasPreview) == "function" then ns.RevertAllExtrasPreview() end
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

function ns.exactTheme(palette, frameId)
    if type(palette) ~= "string" then return nil end
    for i = 1, #THEMES do
        local theme = THEMES[i]
        if theme.palette == palette and theme.frame == frameId then
            return theme
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
    return {
        kind = kind,
        frameValues = readFrameValues(),
        theme = themeId or false,
        themeChanged = changed == true,
    }
end

function ns.applyUndoShot(shot)
    if type(shot) ~= "table" then return end
    if shot.kind == "theme" or shot.kind == "frame" or shot.kind == "looks" or shot.kind == "full" then
        if type(shot.frameValues) == "table" then writeFrameValues(shot.frameValues) end
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
    local frameOk = applyFrame(theme.frame, true)
    local ex = type(ns.PRESET_EXTRAS) == "table" and ns.PRESET_EXTRAS[theme.id] or nil
    if ex then
        if ex.bar and type(ns.applyBarFinish) == "function" then pcall(ns.applyBarFinish, ex.bar) end
        if ex.button and type(ns.applyButtonLook) == "function" then pcall(ns.applyButtonLook, ex.button) end
    end
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

-- Puts back only what Palettes saved: frame values, bar/button extras, plus any pre-update glow snapshot.
local function restoreSaved(saved)
    local frameOk, glowOk = true, true
    local hadFrames = type(saved.frameValues) == "table"
    local hadGlow = saved.glow ~= nil or saved.light ~= nil
    if hadFrames then frameOk = writeFrameValues(saved.frameValues) end
    if hadGlow then glowOk = writeGlowValue(saved.glow, saved.light) end
    if type(ns.restoreBarFinish) == "function" then pcall(ns.restoreBarFinish) end
    if type(ns.restoreButtonLook) == "function" then pcall(ns.restoreButtonLook) end
    return frameOk, glowOk, hadFrames, hadGlow
end

function ns.restoreLooksOnly()
    if not ns.looksApiOk() then return false end
    local saved = readSnapshot()
    local hadExtras = (type(ns.activeBarFinish) == "function" and ns.activeBarFinish() ~= nil)
        or (type(ns.activeButtonLook) == "function" and ns.activeButtonLook() ~= nil)
    if type(ns.RevertAllExtrasPreview) == "function" then pcall(ns.RevertAllExtrasPreview) end
    -- No snapshot means Palettes never changed the look, so Daylight's own
    -- frame and glow stay as they are. Same as a full restore with nothing saved.
    if type(saved) ~= "table" then
        if hadExtras then
            if type(ns.restoreBarFinish) == "function" then pcall(ns.restoreBarFinish) end
            if type(ns.restoreButtonLook) == "function" then pcall(ns.restoreButtonLook) end
            refreshPage()
            refreshLooks()
            return true
        end
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

local function applyUserPreset(preset)
    if type(preset) ~= "table" or inCombat() then return end
    ns.applyingTheme = true
    ns.quietPalette = true
    local d = DaylightUI
    if preset.palette and preset.palette ~= "" and type(d) == "table" and type(d.Set) == "function" then
        d:Set("Palettes", "palette", preset.palette)
    end
    if preset.frame and frameById(preset.frame) then
        applyFrame(preset.frame, true)
    end
    if preset.bar and type(ns.applyBarFinish) == "function" then
        pcall(ns.applyBarFinish, preset.bar)
    end
    if preset.button and type(ns.applyButtonLook) == "function" then
        pcall(ns.applyButtonLook, preset.button)
    end
    ns.applyingTheme = false
    ns.quietPalette = false
    say("Palettes: " .. (preset.name or "Custom Preset") .. " is on. Your layout is unchanged.")
    refreshLooks()
end

local function buildUserPresets(row)
    if row.userMade or type(CreateFrame) ~= "function" then return end
    row.userMade = true
    local heading = uiFont(row, 11, DIM)
    heading:SetText("MY PRESETS (SAVE YOUR CURRENT MIX)")
    heading:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -4)

    local saveBtn = CreateFrame("Button", nil, row)
    saveBtn:SetHeight(22)
    saveBtn:SetWidth(116)
    saveBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -2)
    local saveCard = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(saveBtn) or nil
    local saveLabel = uiFont(saveBtn, 11, CREAM)
    saveLabel:SetPoint("CENTER", saveBtn, "CENTER", 0, 0)
    saveLabel:SetText("+ Save Current")

    local emptyNote = uiFont(row, 11, DIM)
    emptyNote:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -34)
    emptyNote:SetText("Mix any Palette, Frame Look, Bar Finish, or Button Look, then click + Save Current to keep it here.")

    local slots = {}
    local maxSlots = ns.MAX_USER_PRESETS or 4
    for i = 1, maxSlots do
        local b = CreateFrame("Button", nil, row)
        b:SetHeight(42)
        local card = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(b) or nil
        local title = uiFont(b, 12, CREAM)
        title:SetPoint("TOPLEFT", b, "TOPLEFT", 10, -6)
        local sub = uiFont(b, 10, DIM)
        sub:SetPoint("TOPLEFT", b, "TOPLEFT", 10, -23)
        sub:SetPoint("RIGHT", b, "RIGHT", -28, 0)
        if type(sub.SetWordWrap) == "function" then sub:SetWordWrap(false) end

        local del = CreateFrame("Button", nil, b)
        del:SetSize(18, 18)
        del:SetPoint("TOPRIGHT", b, "TOPRIGHT", -5, -5)
        local delText = uiFont(del, 11, DIM)
        delText:SetPoint("CENTER", del, "CENTER", 0, 0)
        delText:SetText("×")

        slots[i] = { button = b, card = card, title = title, sub = sub, del = del, delText = delText, idx = i }
    end

    local function update()
        local list = type(ns.getUserPresets) == "function" and ns.getUserPresets() or {}
        local screenId = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
        local surface = screenId and type(ns.byId) == "table" and ns.byId[screenId] or nil
        local win = (surface and (surface.window or surface.background)) or { 0.08, 0.10, 0.08 }
        local bnd = (surface and surface.band) or { 0.14, 0.18, 0.14 }
        local brd = (surface and surface.border) or { 0.22, 0.28, 0.22 }
        local acc = (surface and surface.c2) or { 0.91, 0.63, 0.29 }
        local blend = type(ns.blendColor) == "function" and ns.blendColor or function(a) return a end
        local rest = blend(win, bnd, 0.26)

        local full = #list >= maxSlots
        saveLabel:SetText(full and ("Saved (" .. tostring(#list) .. "/" .. tostring(maxSlots) .. ")") or "+ Save Current")
        if saveCard then
            saveCard.paint(full and rest or blend(win, acc, 0.16), 0.92, full and brd or acc, full and 0.55 or 0.90)
        end
        if emptyNote.SetShown then emptyNote:SetShown(#list == 0) end

        local w = row:GetWidth()
        if type(w) ~= "number" or w < 240 then w = 760 end
        local cols = w >= 520 and 2 or 1
        local cardW = math.floor((w - 8 - (cols - 1) * CARD_GAP_X) / cols)
        local staged = ns.staged

        for i = 1, maxSlots do
            local slot = slots[i]
            local item = list[i]
            if slot.button.SetShown then slot.button:SetShown(item ~= nil) end
            if item then
                local idx0 = i - 1
                local r = math.floor(idx0 / cols)
                local c = idx0 - r * cols
                slot.button:ClearAllPoints()
                slot.button:SetPoint("TOPLEFT", row, "TOPLEFT", 4 + c * (cardW + CARD_GAP_X), -(30 + r * 48))
                slot.button:SetWidth(cardW)
                slot.title:SetText(item.name or ("My Preset " .. tostring(i)))
                local parts = {}
                if item.palette and type(ns.byId) == "table" and ns.byId[item.palette] then
                    parts[#parts + 1] = ns.byId[item.palette].name
                end
                if item.frame and frameById(item.frame) then parts[#parts + 1] = frameById(item.frame).name end
                if item.bar and type(ns.BAR_BY_ID) == "table" and ns.BAR_BY_ID[item.bar] then
                    parts[#parts + 1] = ns.BAR_BY_ID[item.bar].name
                end
                if item.button and type(ns.BUTTON_BY_ID) == "table" and ns.BUTTON_BY_ID[item.button] then
                    parts[#parts + 1] = ns.BUTTON_BY_ID[item.button].name
                end
                slot.sub:SetText(#parts > 0 and table.concat(parts, " · ") or "Saved mix")

                local on = type(staged) == "table" and staged.kind == "user_preset" and staged.id == item.id
                if slot.card then
                    slot.card.paint(
                        on and blend(win, acc, 0.18) or rest,
                        on and 0.96 or 0.86,
                        on and acc or brd,
                        on and 0.95 or 0.55
                    )
                end
                slot.button:SetScript("OnClick", function()
                    ns.RevertPreview()
                    ns.setLooksOpen(true)
                    if type(ns.stagePick) == "function" then
                        ns.stagePick("user_preset", item.id, function() applyUserPreset(item) end, false)
                        if type(ns.staged) == "table" then
                            ns.staged.palette = item.palette
                            ns.staged.frame = item.frame
                            ns.staged.bar = item.bar
                            ns.staged.button = item.button
                            if type(ns.notePreview) == "function" then ns.notePreview() end
                        end
                    else
                        applyUserPreset(item)
                    end
                    update()
                end)
                slot.del:SetScript("OnClick", function()
                    if type(ns.deleteUserPreset) == "function" then
                        ns.deleteUserPreset(i)
                        update()
                    end
                end)
            end
        end
        local rows = #list == 0 and 1 or math.ceil(#list / cols)
        row.userPresetsHeight = 32 + rows * 48
    end

    saveBtn:SetScript("OnClick", function()
        if type(ns.saveUserPreset) ~= "function" then return end
        local list = type(ns.getUserPresets) == "function" and ns.getUserPresets() or {}
        if #list >= maxSlots then return end
        local pal = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
        local frm = wornFrame()
        local bar = type(ns.activeBarFinish) == "function" and ns.activeBarFinish() or nil
        local btn = type(ns.activeButtonLook) == "function" and ns.activeButtonLook() or nil
        ns.saveUserPreset({
            name = "My Preset " .. tostring(#list + 1),
            palette = pal,
            frame = frm,
            bar = bar,
            button = btn,
        })
        update()
    end)

    row.UpdateUserPresets = update
    hookSize(row, update)
    update()
    refreshers[#refreshers + 1] = update
end

function ns.themesPage()
    local rows = {}
    for i = 1, #THEMES do
        local theme = THEMES[i]
        local paletteName, lookName = themePills(theme)
        rows[#rows + 1] = {
            kind = "theme", id = theme.id, name = theme.name, desc = theme.mood,
            paletteName = paletteName, lookName = lookName,
            palette = theme.palette,
            rowH = THEME_H,
            key = "Looks:" .. theme.id, icon = ICONS[theme.frame],
            select = function()
                ns.RevertPreview()
                local id, changed, pending = ns.shownTheme()
                local live = id == theme.id and not changed and not pending
                ns.setLooksOpen(true)
                if type(ns.stagePick) == "function" then
                    ns.stagePick("theme", theme.id, function() applyTheme(theme) end, live)
                else
                    applyTheme(theme)
                end
                refreshLooks()
            end,
        }
    end
    local spec = {
        intro = THEME_INTRO,
        introH = 30,
        frameOn = function() return false end,
        sections = { { head = THEME_HEAD, rows = rows, rowH = THEME_H } },
    }
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
                        build = function(row) buildListPage(row, spec) end,
                        update = function(row)
                            if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
                        end,
                        height = function() return listHeight(spec.sections, false, spec.introH) end,
                    },
                    {
                        type = "custom",
                        label = "My Presets",
                        hidden = hiddenStyles,
                        build = buildUserPresets,
                        update = function(row)
                            if type(row.UpdateUserPresets) == "function" then row.UpdateUserPresets() end
                        end,
                        height = function(row) return (type(row) == "table" and row.userPresetsHeight) or 82 end,
                    },
                },
            },
        },
    }
end

local function buildLooksWithCategories(row, frameSpec)
    buildListPage(row, frameSpec)
    local barsList = type(ns.BAR_FINISHES) == "table" and ns.BAR_FINISHES or nil
    local btnsList = type(ns.BUTTON_LOOKS) == "table" and ns.BUTTON_LOOKS or nil
    if not barsList or not btnsList then return end

    local activeSub = "frames"
    local pillDefs = {
        { key = "frames", label = "Frames (" .. tostring(#FRAMES) .. ")" },
        { key = "bars",   label = "Bars (" .. tostring(#barsList) .. ")" },
        { key = "buttons", label = "Buttons (" .. tostring(#btnsList) .. ")" },
    }
    local pills = {}
    for i = 1, #pillDefs do
        local def = pillDefs[i]
        local b = CreateFrame("Button", nil, row)
        b:SetHeight(24)
        b:SetWidth(math.max(78, 22 + string.len(def.label) * 6))
        local card = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(b) or nil
        local fs = uiFont(b, 11, CREAM)
        fs:SetPoint("CENTER", b, "CENTER", 0, 0)
        fs:SetText(def.label)
        b:SetScript("OnClick", function()
            activeSub = def.key
            if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
        end)
        pills[i] = { key = def.key, button = b, card = card, label = fs }
    end

    local function makeExtraCards(items, kind, activeFn, applyFn)
        local out = {}
        for i = 1, #items do
            local item = items[i]
            local b = CreateFrame("Button", nil, row)
            b:SetHeight(LOOK_CARD_H)
            local card = type(ns.makeRoundCard) == "function" and ns.makeRoundCard(b) or nil
            local title = uiFont(b, 12, CREAM)
            title:SetPoint("TOPLEFT", b, "TOPLEFT", 12, -8)
            title:SetText(item.name)
            local desc = uiFont(b, 11, DIM)
            desc:SetPoint("TOPLEFT", b, "TOPLEFT", 12, -26)
            desc:SetPoint("RIGHT", b, "RIGHT", -24, 0)
            if type(desc.SetWordWrap) == "function" then desc:SetWordWrap(true) end
            desc:SetText(item.desc)
            local check = drawCheck(b)
            check:SetPoint("TOPRIGHT", b, "TOPRIGHT", -6, -7)
            b:SetScript("OnClick", function()
                ns.setLooksOpen(true)
                local live = activeFn() == item.id
                if type(ns.stagePick) == "function" then
                    ns.stagePick(kind, item.id, function() applyFn(item.id) end, live)
                else
                    applyFn(item.id)
                end
                refreshLooks()
            end)
            out[i] = { id = item.id, kind = kind, button = b, card = card, title = title, desc = desc, check = check }
        end
        return out
    end

    local barCards = makeExtraCards(barsList, "bar", ns.activeBarFinish, ns.applyBarFinish)
    local btnCards = makeExtraCards(btnsList, "button", ns.activeButtonLook, ns.applyButtonLook)

    local origUpdate = row.UpdateLooks
    function row.UpdateLooks()
        origUpdate()
        local w = row:GetWidth()
        if type(w) ~= "number" or w < 120 then w = 760 end
        local screenId = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
        local surface = screenId and type(ns.byId) == "table" and ns.byId[screenId] or nil
        local win = (surface and (surface.window or surface.background)) or { 0.08, 0.10, 0.08 }
        local bnd = (surface and surface.band) or { 0.14, 0.18, 0.14 }
        local brd = (surface and surface.border) or { 0.22, 0.28, 0.22 }
        local acc = (surface and surface.c2) or { 0.91, 0.63, 0.29 }
        local blend = type(ns.blendColor) == "function" and ns.blendColor or function(a) return a end
        local rest = blend(win, bnd, 0.26)

        local px = 4
        for i = 1, #pills do
            local p = pills[i]
            local on = p.key == activeSub
            p.button:ClearAllPoints()
            p.button:SetPoint("TOPLEFT", row, "TOPLEFT", px, -24)
            px = px + (p.button:GetWidth() or 84) + 6
            if p.card then
                p.card.paint(on and blend(win, acc, 0.18) or rest, 0.92, on and acc or brd, on and 0.95 or 0.65)
            end
            if type(p.label.SetTextColor) == "function" then
                local c = on and acc or ((surface and surface.label) or DIM)
                p.label:SetTextColor(c[1], c[2], c[3], 1)
            end
        end

        -- Show/hide the 7 Frame Look cards depending on activeSub.
        for i = 1, #row.lines do
            local line = row.lines[i]
            if line.button and line.button.SetShown then
                line.button:SetShown(activeSub == "frames")
            end
        end

        local cols = w >= 520 and 2 or 1
        local cardW = math.floor((w - 8 - (cols - 1) * CARD_GAP_X) / cols)
        local gridTop = 58
        local staged = ns.staged

        local function placeExtra(cards, vis, activeFn)
            for i = 1, #cards do
                local c = cards[i]
                if c.button.SetShown then c.button:SetShown(vis) end
                if vis then
                    local idx0 = i - 1
                    local r = math.floor(idx0 / cols)
                    local col = idx0 - r * cols
                    c.button:ClearAllPoints()
                    c.button:SetPoint("TOPLEFT", row, "TOPLEFT", 4 + col * (cardW + CARD_GAP_X), -(gridTop + r * (LOOK_CARD_H + CARD_GAP_Y)))
                    c.button:SetWidth(cardW)
                    local on = (type(staged) == "table" and staged.kind == c.kind and staged.id == c.id)
                        or (not (type(staged) == "table" and staged.kind == c.kind) and activeFn() == c.id)
                    if c.card then
                        c.card.paint(
                            on and blend(win, acc, 0.18) or rest,
                            on and 0.96 or 0.86,
                            on and acc or brd,
                            on and 0.95 or 0.55
                        )
                    end
                    if c.check then
                        if on and c.check.Show then
                            if type(c.check.SetVertexColor) == "function" then c.check:SetVertexColor(acc[1], acc[2], acc[3], 1) end
                            c.check:Show()
                        elseif c.check.Hide then
                            c.check:Hide()
                        end
                    end
                end
            end
        end

        placeExtra(barCards, activeSub == "bars", ns.activeBarFinish)
        placeExtra(btnCards, activeSub == "buttons", ns.activeButtonLook)
    end
    row.UpdateLooks()
end

function ns.looksPage()
    local function frameOn(id)
        return wornFrame() == id
    end
    local frames = {}
    for i = 1, #FRAMES do
        local frame = FRAMES[i]
        frames[#frames + 1] = {
            kind = "frame", id = frame.id, name = frame.name, desc = frame.desc,
            key = frame.id, icon = ICONS[frame.id],
            select = function()
                ns.RevertPreview()
                local live = wornFrame() == frame.id
                ns.setLooksOpen(true)
                if type(ns.stagePick) == "function" then
                    ns.stagePick("frame", frame.id, function() applyFrame(frame.id) end, live)
                else
                    applyFrame(frame.id)
                end
                refreshLooks()
            end,
        }
    end
    local spec = {
        intro = LOOKS_INTRO,
        introH = 54,
        frameOn = frameOn,
        sections = {
            { head = FRAME_HEAD, rows = frames },
        },
    }
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
                        build = function(row) buildLooksWithCategories(row, spec) end,
                        update = function(row)
                            if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
                        end,
                        height = function() return listHeight(spec.sections, false, spec.introH) end,
                    },
                    {
                        type = "toggle",
                        key = "scopeFocus",
                        label = "Also style Focus & Target of Target",
                        desc = "Applies the picked look's frame style, border, tab, and portrait to Focus and Target of Target without changing their widths.",
                        hidden = hiddenStyles,
                    },
                    {
                        type = "toggle",
                        key = "scopeGroup",
                        label = "Also style Party & Raid frames",
                        desc = "Applies the picked look's border, corners, shadow, and bar finish to Party and Raid frames without changing their layout or sizes.",
                        hidden = hiddenStyles,
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
