-- Frame styles, glow styles and Themes. Palettes registers the styles.
-- A Theme sets one palette, one frame and one glow. Palettes stay color-only.
-- Palettes registers them. The saved keys stay Looks:lintel, Looks:wick and
-- so on, through a Looks-named API handle. The plugin name stays Palettes.
-- The snapshot lives in Palettes' saved data and profile settings, never LooksDB.
-- A pick waits out combat. API 1.7 and 1.8 keep colors and hide this page.

local _, ns = ...

local NEED_STYLES = "Palettes: Daylight UI is missing the settings frame and glow styles need, so only colors are available."
local BOTH = "Palettes: Looks is also loaded. Turn Looks off; frame and glow styles now live in Palettes."
local GLOW_HINT = "Glow colour follows your accent colour. Change it on the Colours tab."

local function unitSizes(spec)
    local frames = { "player", "target", "focus" }
    local sizes = {}
    for i = 1, #frames do sizes[frames[i]] = spec end
    return sizes
end

local CORNER = { 0, 0.25, 0.5, 0.75 }

local function wave(at)
    return 0.5 - 0.5 * math.cos(at * math.pi * 2)
end

local function lightSize(size)
    if type(size) == "number" and size > 0 then return size end
    return 8
end

local function drawWick(g, at, lo, hi, size)
    local s = lightSize(size) * (0.55 + 0.5 * wave(at))
    local alpha = 0.35 + 0.65 * wave(at)
    for i = 1, 4 do
        local color = (i % 2 == 1) and lo or hi
        g:Light(CORNER[i], s, color, alpha)
        g:Trail(CORNER[i], 0.045, alpha * 0.45, lo, hi)
    end
end

local function drawDraught(g, at, lo, hi)
    local span = 0.62
    local from = (1 - span) * wave(at)
    g:Edge(1, 0, 1, 0.16, 0.16, lo, hi)
    g:Edge(1, from, from + span, 0.2, 0.9, lo, hi)
end

local function drawLatch(g, at, lo, hi, size)
    if at >= 0.42 then return end
    local alpha
    if at < 0.16 then
        alpha = 0.45 + 0.55 * (at / 0.16)
    else
        alpha = 1 - (at - 0.16) / (0.42 - 0.16)
    end
    g:Edge(1, 0, 1, alpha * 0.45, alpha, lo, hi)
    g:Edge(2, 0, 1, alpha, alpha * 0.3, hi, lo)
    g:Edge(3, 0, 1, alpha * 0.3, alpha * 0.55, lo, hi)
    g:Edge(4, 0, 1, alpha * 0.55, alpha * 0.4, hi, lo)
    g:Light(0, lightSize(size) * 0.7, hi, alpha)
    g:Trail(0.02, 0.08, alpha * 0.5, lo, hi)
end

local FRAMES = {
    { id = "lintel", name = "Lintel", spec = { label = "Lintel", desc = "A named beam over a solid bar.", row = true } },
    { id = "sill", name = "Sill", spec = { label = "Sill", desc = "The name tab stays; power sits as a thin sill under the bar.", line = true } },
    { id = "stamp", name = "Stamp", spec = { label = "Stamp", desc = "A tight name row and a thin power line.", row = true, line = true, ring = 0.35 } },
    { id = "trestle", name = "Trestle", spec = { label = "Trestle", desc = "A named board, with power hung as a rail.", row = true, line = true } },
    { id = "flagon", name = "Flagon", spec = { label = "Flagon", desc = "A small boss and a deep cup, the name cut into the lip.", row = true, ring = 0.35, sizes = unitSizes({ height = 32 }) } },
    { id = "signboard", name = "Signboard", spec = { label = "Signboard", desc = "A hanging boss on a tall board, with a hairline rail along the bottom.", row = true, ring = 1, sizes = unitSizes({ height = 10, tabHeight = 28 }) } },
    { id = "trough", name = "Trough", spec = { label = "Trough", desc = "A full boss, a thin health lip, power in a deep trough.", line = true, ring = 1, sizes = unitSizes({ height = 11, powerHeight = 14 }) } },
}

local GLOWS = {
    { id = "wick", name = "Wick", mood = "A quiet flame gathers at the corners.", spec = { label = "Wick", lap = 2, draw = drawWick } },
    { id = "draught", name = "Draught", mood = "A soft wash along the rim.", spec = { label = "Draught", lap = 2, draw = drawDraught } },
    { id = "latch", name = "Latch", mood = "A short catch of light, then still.", spec = { label = "Latch", lap = 2, draw = drawLatch } },
}

local THEMES = {
    { id = "hearthnight", name = "Hearthnight", palette = "ember", frame = "lintel", glow = "wick", mood = "A winter hearth of campfire gold: a named beam and a quiet corner flame." },
    { id = "harvestide", name = "Harvestide", palette = "vanilla", frame = "sill", glow = "draught", mood = "Harvest light on dark oak and pewter, washed along the sill of the bar." },
    { id = "tidemark", name = "Tidemark", palette = "tide", frame = "stamp", glow = "draught", mood = "Cool sea-green at the waterline: a tight stamp and a soft wash along the rim." },
    { id = "oldroad", name = "Old Road", palette = "forever", frame = "lintel", glow = "latch", mood = "Near-black soot and weathered bronze: a weathered beam and a short catch of lantern light." },
    { id = "vigil", name = "Vigil", palette = "paladin", frame = "sill", glow = "wick", mood = "Rose on warm plum-brown. The name tab stays, and a flame is kept lit at the corners." },
    { id = "snug", name = "Snug", palette = "gilded", frame = "flagon", glow = "latch", mood = "A deep gold cup in the quiet corner, and a short catch of lantern light." },
    { id = "bellows", name = "Bellows", palette = "forgeglow", frame = "trestle", glow = "wick", mood = "A named work board and a quiet corner flame, like a forge kept open late." },
    { id = "drawwell", name = "Drawwell", palette = "shaman", frame = "trough", glow = "draught", mood = "Storm-grey water in a deep basin, and a soft wash along the rim." },
    { id = "settle", name = "Settle", palette = "keepstone", frame = "lintel", glow = "latch", mood = "A walnut beam and a brief catch of brass-lantern light, like a high-backed bench by the fire." },
    { id = "afterhours", name = "After Hours", palette = "carmine-night", frame = "signboard", glow = "latch", mood = "A hanging sign and a brief cut of carmine light, after the room has gone quiet." },
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
    lintel = {}, sill = {}, stamp = {}, trestle = {}, flagon = {},
    signboard = {}, trough = {}, wick = {}, draught = {}, latch = {},
}

addBox(ICONS.lintel, 1, 5, 8, 8)
addEdge(ICONS.lintel, 12, 6, 14, 1)
addBox(ICONS.lintel, 11, 9, 23, 7)
addBox(ICONS.sill, 1, 3, 7, 7)
addEdge(ICONS.sill, 11, 4, 12, 1)
addBox(ICONS.sill, 11, 7, 23, 6)
addEdge(ICONS.sill, 11, 15, 23, 1)
addBox(ICONS.stamp, 1, 6, 6, 6)
addEdge(ICONS.stamp, 10, 3, 22, 1)
addBox(ICONS.stamp, 10, 6, 24, 5)
addEdge(ICONS.stamp, 10, 13, 24, 1)
addBox(ICONS.trestle, 1, 2, 11, 12)
addEdge(ICONS.trestle, 15, 4, 18, 1)
addBox(ICONS.trestle, 15, 7, 19, 5)
addEdge(ICONS.trestle, 15, 14, 19, 1)
addBox(ICONS.flagon, 1, 5, 6, 6)
addEdge(ICONS.flagon, 10, 3, 22, 1)
addBox(ICONS.flagon, 10, 6, 24, 10)
addBox(ICONS.signboard, 1, 2, 10, 10)
addBox(ICONS.signboard, 14, 2, 20, 10)
addEdge(ICONS.signboard, 14, 14, 20, 1)
addBox(ICONS.trough, 1, 2, 10, 12)
addBox(ICONS.trough, 14, 2, 20, 4)
addBox(ICONS.trough, 14, 8, 20, 8)
addBox(ICONS.wick, 1, 1, 34, 16)
addEdge(ICONS.wick, 3, 3, 3, 1)
addEdge(ICONS.wick, 30, 3, 3, 1)
addEdge(ICONS.wick, 3, 14, 3, 1)
addEdge(ICONS.wick, 30, 14, 3, 1)
addBox(ICONS.draught, 1, 1, 34, 16)
addEdge(ICONS.draught, 4, 3, 28, 1)
addEdge(ICONS.draught, 6, 5, 24, 1)
addBox(ICONS.latch, 1, 1, 34, 16)
addEdge(ICONS.latch, 4, 3, 1, 12)
addEdge(ICONS.latch, 4, 3, 8, 1)
addEdge(ICONS.latch, 4, 14, 8, 1)

local ORDER = {}
for i = 1, #FRAMES do ORDER[#ORDER + 1] = FRAMES[i] end
for i = 1, #GLOWS do ORDER[#ORDER + 1] = GLOWS[i] end
for i = 1, #THEMES do ORDER[#ORDER + 1] = THEMES[i] end

local GLOW_READS = {
    { "general", "buttonGlow" },
    { "Nameplates", "targetLight" },
}

local view
local refreshers = {}
local looksPending

local THEME_INTRO = "Each preset is a ready-made pairing of a Colours palette with a Looks frame and glow. Pick one, then change any part on the Colours or Looks tab."
local LOOKS_INTRO = "A preset on the Presets tab sets all three."
local PAGE_NOTE = "Starts off on first login · /looks"
local FRAME_HEAD = "FRAME STYLES"
local GLOW_HEAD = "GLOW STYLES"
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

local DAYLIGHT_FRAME = "daylight"
local DAYLIGHT_GLOW = "circle"
local DAYLIGHT_LIGHT = "none"

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

local function glowById(id)
    for i = 1, #GLOWS do
        if GLOWS[i].id == id then return GLOWS[i] end
    end
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
    else
        row = glowById(id)
    end
    if type(row) == "table" and type(row.name) == "string" and row.name ~= "" then return row.name end
    return "—"
end

local function themePills(theme)
    return partLabel("palette", theme.palette),
        partLabel("frame", theme.frame) .. " + " .. partLabel("glow", theme.glow)
end

function ns.frameById(id)
    return frameById(id)
end

function ns.glowById(id)
    return glowById(id)
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

local function copyShot(shot)
    if type(shot) ~= "table" then return nil end
    return {
        frame = type(shot.frame) == "string" and shot.frame or nil,
        glow = type(shot.glow) == "string" and shot.glow or nil,
        light = type(shot.light) == "string" and shot.light or nil,
    }
end

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

local function wornFrame()
    local api = apiOf()
    if not api or type(api.GetUnitFrame) ~= "function" or type(api.Parts) ~= "function" then
        return nil
    end
    local ok, frame = pcall(api.GetUnitFrame, "player")
    if not ok or type(frame) ~= "table" then return nil end
    local okParts, parts = pcall(api.Parts, frame)
    if not okParts or type(parts) ~= "table" then return nil end
    local found = frameById(looksId(parts.style))
    if found then return found.id, found.name end
end

local function wornGlows()
    local api = apiOf()
    local out, seen = {}, {}
    if not api or type(api.GetSetting) ~= "function" then return out end
    for i = 1, #GLOW_READS do
        local ok, value = pcall(api.GetSetting, GLOW_READS[i][1], GLOW_READS[i][2])
        local found = ok and glowById(looksId(value))
        if found and not seen[found.id] then
            seen[found.id] = true
            out[#out + 1] = found
        end
    end
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
    local glows = wornGlows()
    local omit = {}
    if themeId then
        local theme = themeById(themeId)
        name = theme and theme.name or themeId
        if changed then name = name .. " (changed)" end
        omit[themeId] = true
    end
    if id then omit[id] = true end
    for i = 1, #glows do omit[glows[i].id] = true end
    if not name and glows[1] then name = glows[1].name end
    return hintLine(name, omit)
end

local function frameSetter()
    if type(view) == "table" and type(view.SetFrameStyle) == "function" then
        return function(key) view.SetFrameStyle(key) end
    end
    local api = apiOf()
    if api and type(api.SetFrameStyle) == "function" then
        return function(key)
            if key == "daylight" then api.SetFrameStyle("daylight") else api.SetFrameStyle("Looks:" .. key) end
        end
    end
end

local function glowSetter()
    if type(view) == "table" and type(view.SetGlowStyle) == "function" then
        return function(key) view.SetGlowStyle(key) end
    end
    local api = apiOf()
    if api and type(api.SetGlowStyle) == "function" then
        return function(key)
            if key == "none" then api.SetGlowStyle("none") else api.SetGlowStyle("Looks:" .. key) end
        end
    end
end

local function allowedWrite(scope, path)
    if scope == "UnitFrames" and path == "look.style" then return true end
    if scope == "general" and path == "buttonGlow" then return true end
    if scope == "Nameplates" and path == "targetLight" then return true end
    return false
end

local function readSetting(scope, path)
    local d = DaylightUI
    if type(d) ~= "table" or type(d.Get) ~= "function" then return nil, false end
    local ok, value = pcall(d.Get, d, scope, path)
    if not ok then return nil, false end
    return value, true
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

local function readFrameStyle()
    local value, ok = readKnown("UnitFrames", "look.style")
    if ok then return value, true end
    local api = apiOf()
    if not api or type(api.GetUnitFrame) ~= "function" or type(api.Parts) ~= "function" then
        return nil, false
    end
    local frameOk, frame = pcall(api.GetUnitFrame, "player")
    if not frameOk or type(frame) ~= "table" then return nil, false end
    local partsOk, parts = pcall(api.Parts, frame)
    if not partsOk or type(parts) ~= "table" or type(parts.style) ~= "string" then
        return nil, false
    end
    return parts.style, true
end

local function capture()
    if readSnapshot() then return nil end
    local frame, frameOk = readFrameStyle()
    local glow, glowOk = readKnown("general", "buttonGlow")
    local light, lightOk = readKnown("Nameplates", "targetLight")
    if not frameOk and not glowOk and not lightOk then return nil end
    return {
        frame = frameOk and frame or nil,
        glow = glowOk and glow or nil,
        light = lightOk and light or nil,
    }
end

local function hasWrite()
    local d = DaylightUI
    return type(d) == "table" and type(d.Set) == "function"
end

local function hasMenuStyle()
    local d = DaylightUI
    if type(d) ~= "table" or type(d.GetModule) ~= "function" then return false end
    local ok, mod = pcall(d.GetModule, d, "UnitFrames")
    return ok and type(mod) == "table" and type(mod.ns) == "table" and type(mod.ns.SetStyle) == "function"
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

local function menuSetStyle(value)
    local d = DaylightUI
    if type(d) ~= "table" or type(d.GetModule) ~= "function" then return false end
    local ok, mod = pcall(d.GetModule, d, "UnitFrames")
    if not ok or type(mod) ~= "table" or type(mod.ns) ~= "table" or type(mod.ns.SetStyle) ~= "function" then
        return false
    end
    if not pcall(mod.ns.SetStyle, "look.style", value) then return false end
    local got, readable = readSetting("UnitFrames", "look.style")
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

local function pointAtFrame(id)
    if id == "daylight" then
        say("Looks: pick Daylight in the Frame style menu.")
        return
    end
    local found = frameById(id)
    say("Looks: pick " .. (found and found.name or id) .. " in the Frame style menu.")
end

local function pointAtGlow(id)
    if id == "none" then
        say("Looks: pick none in the glow menu.")
        return
    end
    local found = glowById(id)
    say("Looks: pick " .. (found and found.name or id) .. " in the glow menu.")
end

local function pointAtGlowValue(value)
    if type(value) ~= "string" or value == "" or value == "none" then
        pointAtGlow("none")
        return
    end
    local id = looksId(value)
    if id then
        pointAtGlow(id)
        return
    end
    say("Looks: pick " .. value .. " in the glow menu.")
end

local function frameKey(id)
    if id == "daylight" then return "daylight" end
    return "Looks:" .. id
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

local function applyFrame(id, quiet)
    if inCombat() then
        local found = frameById(id)
        queueLook("frame", id, found and found.name or id)
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
    local set = frameSetter()
    local shot = (set or hasMenuStyle() or hasWrite()) and capture() or nil
    if set and pcall(set, id) then
        if shot then storeSnapshot(shot) end
        refreshPage()
        refreshLooks()
        return finish(true)
    end
    local key = frameKey(id)
    if menuSetStyle(key) or writeSetting("UnitFrames", "look.style", key) then
        if shot then storeSnapshot(shot) end
        refreshPage()
        refreshLooks()
        return finish(true)
    end
    if not quiet then pointAtFrame(id) end
    return finish(false)
end

local function applyGlow(id, quiet)
    if inCombat() then
        local found = glowById(id)
        queueLook("glow", id, found and found.name or id)
        return false
    end
    local undoShot = (not ns.applyingTheme and type(ns.captureUndo) == "function") and ns.captureUndo("glow") or nil
    local function finish(ok)
        if ok then
            if undoShot and type(ns.pushUndo) == "function" then ns.pushUndo(undoShot) end
            if type(ns.storeLookPart) == "function" then ns.storeLookPart("glow", id) end
            if not ns.applyingTheme and type(ns.notePalette) == "function" then ns.notePalette(ns.screenPalette()) end
        end
        return ok
    end
    local set = glowSetter()
    local shot = (set or hasWrite()) and capture() or nil
    if set and pcall(set, id) then
        if shot then storeSnapshot(shot) end
        refreshPage()
        refreshLooks()
        return finish(true)
    end
    local buttonKey, lightKey
    if id == "none" then
        buttonKey, lightKey = "circle", "none"
    else
        buttonKey, lightKey = "Looks:" .. id, "Looks:" .. id
    end
    local buttons = writeSetting("general", "buttonGlow", buttonKey)
    local light = writeSetting("Nameplates", "targetLight", lightKey)
    if buttons or light then
        if shot then storeSnapshot(shot) end
    end
    if buttons and light then
        refreshPage()
        refreshLooks()
        return finish(true)
    end
    if buttons or light then refreshPage() end
    if not quiet then pointAtGlow(id) end
    refreshLooks()
    return finish(false)
end

local function writeFrameValue(value)
    if menuSetStyle(value) or writeSetting("UnitFrames", "look.style", value) then
        return true
    end
    local set = frameSetter()
    if not set then return false end
    if value == DAYLIGHT_FRAME and pcall(set, "daylight") then return true end
    local id = looksId(value)
    if id and frameById(id) and pcall(set, id) then return true end
    return false
end

local function writeGlowValue(buttonValue, lightValue)
    local buttons = writeSetting("general", "buttonGlow", buttonValue)
    local light = writeSetting("Nameplates", "targetLight", lightValue)
    if buttons and light then return true end
    if not buttons and not light then
        local set = glowSetter()
        if set and buttonValue == lightValue then
            local id = buttonValue == "none" and "none" or looksId(buttonValue)
            if id and (id == "none" or glowById(id)) and pcall(set, id) then return true end
        end
    end
    return false
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

local function soleGlow()
    local button, buttonOk = readKnown("general", "buttonGlow")
    local light, lightOk = readKnown("Nameplates", "targetLight")
    if not buttonOk or not lightOk then return nil end
    local b = glowById(looksId(button))
    local l = glowById(looksId(light))
    if b and l and b.id == l.id then return b.id end
    if button == DAYLIGHT_GLOW and light == DAYLIGHT_LIGHT then return "daylight" end
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

function ns.exactTheme(palette, frameId, glowId)
    if type(palette) ~= "string" then return nil end
    for i = 1, #THEMES do
        local theme = THEMES[i]
        if theme.palette == palette and theme.frame == frameId and theme.glow == glowId then
            return theme
        end
    end
end

function ns.notePalette(id)
    if ns.applyingTheme or ns.clearingTheme then return end
    local exact = ns.exactTheme(id, wornFrame(), soleGlow())
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
    local exact = ns.exactTheme(ns.screenPalette(), wornFrame(), soleGlow())
    if exact then return exact.id, false, false end
    local id = ns.readTheme()
    if id then return id, true, false end
    return nil, false, false
end

function ns.captureUndo(kind)
    local themeId, changed = ns.readTheme()
    local frame = select(1, readFrameStyle())
    local glow = select(1, readKnown("general", "buttonGlow"))
    local light = select(1, readKnown("Nameplates", "targetLight"))
    return {
        kind = kind,
        frame = frame,
        glow = glow,
        light = light,
        theme = themeId or false,
        themeChanged = changed == true,
    }
end

function ns.applyUndoShot(shot)
    if type(shot) ~= "table" then return end
    if shot.kind == "theme" or shot.kind == "frame" or shot.kind == "looks" or shot.kind == "full" then
        if type(shot.frame) == "string" then writeFrameValue(shot.frame) end
    end
    if shot.kind == "theme" or shot.kind == "glow" or shot.kind == "looks" or shot.kind == "full" then
        if type(shot.glow) == "string" or type(shot.light) == "string" then
            writeGlowValue(shot.glow or DAYLIGHT_GLOW, shot.light or DAYLIGHT_LIGHT)
        end
    end
    if shot.theme == false or type(shot.theme) == "string" then
        writeThemeSlot(shot.theme, shot.themeChanged == true)
    end
    local exact = ns.exactTheme(ns.screenPalette(), wornFrame(), soleGlow())
    if exact then writeThemeSlot(exact.id, false) end
    refreshLooks()
end

function ns.applyShareLook(look)
    if type(look) ~= "table" then return end
    if type(look.frame) == "string" then
        if look.frame == "daylight" then writeFrameValue(DAYLIGHT_FRAME)
        elseif frameById(look.frame) then applyFrame(look.frame, true) end
    end
    if type(look.glow) == "string" then
        if look.glow == "daylight" then writeGlowValue(DAYLIGHT_GLOW, DAYLIGHT_LIGHT)
        elseif glowById(look.glow) then applyGlow(look.glow, true) end
    end
    if not ns.applyingTheme then ns.notePalette(ns.screenPalette()) end
end

function ns.currentPal2()
    local palette = ns.screenPalette()
    local themeId = select(1, ns.shownTheme())
    local frameId = wornFrame() or "daylight"
    local glowId = soleGlow() or "daylight"
    if palette == "custom" and type(ns.readCustom) == "function" and type(ns.shareCode) == "function" then
        local spec = ns.readCustom(type(ns.accountTable) == "function" and ns.accountTable() or {}, type(ns.charTable) == "function" and ns.charTable() or {})
        local code = ns.shareCode(spec)
        local base, accent = string.match(code or "", "^PAL1%-(%x%x%x%x%x%x)%-(%x%x%x%x%x%x)$")
        return ns.pal2Code({ theme = themeId, custom = true, base = base, accent = accent, frame = frameId, glow = glowId })
    end
    return ns.pal2Code({ theme = themeId, palette = palette, frame = frameId, glow = glowId })
end

local function themeKeys(db)
    return type(db) == "table" and (db.theme ~= nil or db.themeChanged ~= nil or db.frame ~= nil or db.glow ~= nil)
end

function ns.takeTheme(account, char, db, onlyOn)
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
    if db.frame ~= nil then write("frame", db.frame) end
    if db.glow ~= nil then write("glow", db.glow) end
    return true
end

function ns.applyProfileLook(db)
    if type(db) ~= "table" or not ns.looksApiOk() then return end
    if type(db.frame) == "string" then
        if db.frame == "daylight" then writeFrameValue(DAYLIGHT_FRAME)
        elseif frameById(db.frame) then writeFrameValue("Looks:" .. db.frame) end
    end
    if type(db.glow) == "string" then
        if db.glow == "daylight" then writeGlowValue(DAYLIGHT_GLOW, DAYLIGHT_LIGHT)
        elseif glowById(db.glow) then writeGlowValue("Looks:" .. db.glow, "Looks:" .. db.glow) end
    end
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
    local glowOk = applyGlow(theme.glow, true)
    writeThemeSlot(theme.id, false)
    ns.applyingTheme = false
    ns.quietPalette = false
    ns.undoHold = nil
    say("Palettes: " .. theme.name .. " is on. Your layout is unchanged.")
    if not frameOk then pointAtFrame(theme.frame) end
    if not glowOk then pointAtGlow(theme.glow) end
    refreshLooks()
end

function ns.restoreColoursOnly()
    ns.coloursOnlyRestore = true
    local d = DaylightUI
    if type(d) == "table" and type(d.Set) == "function" then
        d:Set("Palettes", "palette", "off")
    end
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
    local frame = DAYLIGHT_FRAME
    local glow = DAYLIGHT_GLOW
    local light = DAYLIGHT_LIGHT
    if saved.frame ~= nil then frame = saved.frame end
    if saved.glow ~= nil then glow = saved.glow end
    if saved.light ~= nil then light = saved.light end
    local frameOk = writeFrameValue(frame)
    local glowOk = writeGlowValue(glow, light)
    if frameOk or glowOk then refreshPage() end
    if frameOk and glowOk then storeSnapshot(false) end
    if undoShot and (frameOk or glowOk) and type(ns.pushUndo) == "function" then ns.pushUndo(undoShot) end
    local frameId = looksId(frame) or (frame == DAYLIGHT_FRAME and "daylight" or nil)
    if frameId then ns.storeLookPart("frame", frameId) end
    local glowId = looksId(saved.glow or glow)
    if glow == DAYLIGHT_GLOW and light == DAYLIGHT_LIGHT then glowId = "daylight" end
    if glowId then ns.storeLookPart("glow", glowId) end
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
        if parsed.frame == "daylight" then writeFrameValue(DAYLIGHT_FRAME)
        elseif frameById(parsed.frame) then applyFrame(parsed.frame, true) end
    end
    if parsed.glow and parsed.glow ~= "none" then
        if parsed.glow == "daylight" then writeGlowValue(DAYLIGHT_GLOW, DAYLIGHT_LIGHT)
        elseif glowById(parsed.glow) then applyGlow(parsed.glow, true) end
    end
    if theme then
        local exact = ns.exactTheme(ns.screenPalette(), wornFrame(), soleGlow())
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
    local frame = DAYLIGHT_FRAME
    local glow = DAYLIGHT_GLOW
    local light = DAYLIGHT_LIGHT
    if saved.frame ~= nil then frame = saved.frame end
    if saved.glow ~= nil then glow = saved.glow end
    if saved.light ~= nil then light = saved.light end
    local frameOk = writeFrameValue(frame)
    local glowOk = writeGlowValue(glow, light)
    if frameOk or glowOk then refreshPage() end
    if frameOk and glowOk then storeSnapshot(false) end
    if not frameOk and not quiet then pointAtFrame(looksId(frame) or "daylight") end
    if not glowOk and not quiet then pointAtGlowValue(saved.glow) end
    refreshLooks()
    return frameOk and glowOk
end

function ns.finishLooksCombat()
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
    elseif pending.kind == "glow" then
        applyGlow(pending.id, false)
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
    local glow = soleGlow() or "daylight"
    local pending = ""
    if type(looksPending) == "table" then
        pending = tostring(looksPending.kind) .. ":" .. tostring(looksPending.id)
    end
    return frame .. "/" .. glow .. "/" .. pending
end

local looksSlashRun

function ns.looksSlash(msg)
    local function run()
        looksSlashRun(msg)
    end
    if type(ns.withReloadAction) ~= "function" then
        run()
        return
    end
    local beforeLook = ns.lookMark()
    local beforePal = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
    ns.withReloadAction(function()
        run()
        local afterPal = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
        if ns.lookMark() ~= beforeLook or afterPal ~= beforePal then
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
    if frameById(arg) then
        applyFrame(arg)
        return
    end
    if glowById(arg) then
        applyGlow(arg)
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
        if theme and ((kind == "frame" and theme.frame == id) or (kind == "glow" and theme.glow == id) or (kind == "theme" and theme.id == id)) then
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
    local edge = hold:CreateTexture(nil, "BACKGROUND")
    if type(edge.SetColorTexture) == "function" then
        edge:SetColorTexture(0.55, 0.40, 0.22, 1)
    end
    if edge.SetAllPoints then edge:SetAllPoints() end
    local fill = hold:CreateTexture(nil, "BORDER")
    if type(fill.SetColorTexture) == "function" then
        fill:SetColorTexture(0.24, 0.17, 0.12, 1)
    end
    if fill.SetPoint then
        fill:SetPoint("TOPLEFT", hold, "TOPLEFT", 1, -1)
        fill:SetPoint("BOTTOMRIGHT", hold, "BOTTOMRIGHT", -1, 1)
    end
    local fs = uiFont(hold, 11, CREAM)
    fs:SetText(label)
    local width = 12 + string.len(label) * 6
    if type(fs.GetStringWidth) == "function" then
        local sw = fs:GetStringWidth()
        if type(sw) == "number" and sw > 8 then width = sw + 12 end
    end
    hold:SetWidth(width)
    fs:ClearAllPoints()
    fs:SetPoint("CENTER", hold, "CENTER", 0, 0)
    return hold, fs
end

local function styleRows(row, entries)
    row.lines = row.lines or {}
    local built = {}
    for i = 1, #entries do
        local entry = entries[i]
        local hold = CreateFrame("Button", nil, row)
        hold:SetHeight(entry.rowH or STYLE_H)
        local hi = hold:CreateTexture(nil, "BACKGROUND")
        if type(hi.SetColorTexture) == "function" then
            hi:SetColorTexture(ROW_REST[1], ROW_REST[2], ROW_REST[3], ROW_REST[4])
        end
        hi:SetAllPoints()
        hi:Hide()
        local icon = drawIcon(hold, entry.icon or {})
        local name = uiFont(hold, 13, CREAM)
        name:SetText(entry.name)
        if type(name.SetWordWrap) == "function" then name:SetWordWrap(false) end
        local desc = uiFont(hold, 11, DIM)
        desc:SetText(entry.desc)
        if type(desc.SetWordWrap) == "function" then desc:SetWordWrap(false) end
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
        local onText = uiFont(hold, 12, ON_INK)
        onText:SetText("")
        onText:Hide()
        local hoverText = uiFont(hold, 11, CREAM)
        hoverText:SetText("HOVER")
        hoverText:Hide()
        local line = {
            id = entry.id, kind = entry.kind, name = name, baseName = entry.name,
            mood = entry.desc, preview = preview, rowH = entry.rowH,
            button = hold, paletteId = entry.palette,
            palettePill = pillAText, lookPill = pillBText,
        }
        line.key = key
        line.desc = desc
        line.onText = onText
        line.hoverText = hoverText
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
            local rest = (surface and (surface.window or surface.background)) or ROW_REST
            local hover = (surface and (surface.control or surface.band)) or ROW_HOVER
            local color = rest
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
                edge = accent
            elseif line.hover then
                color = hover
            end
            line.washColor = color
            line.ink = light
            if type(hi.SetColorTexture) == "function" then
                hi:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
            end
            if hi.Show then hi:Show() end
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
                tint(name, CREAM)
                tint(desc, DIM)
            end
            if line.markPending then
                onText:SetText("PENDING")
                onText:Show()
                if hoverText.Hide then hoverText:Hide() end
            elseif line.markOn then
                if onText.Hide then onText:Hide() end
                if check.Show then check:Show() end
                if hoverText.Hide then hoverText:Hide() end
            elseif line.hover then
                if onText.Hide then onText:Hide() end
                hoverText:Show()
            else
                if onText.Hide then onText:Hide() end
                if hoverText.Hide then hoverText:Hide() end
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
            onText = onText, hoverText = hoverText, check = check, line = line,
        }
    end
    return built
end

local function placeStyles(row, intro, heads, rows, hintText, combatNote, introH)
    local w = row:GetWidth()
    if type(w) ~= "number" or w < 120 then w = 760 end
    intro:ClearAllPoints()
    intro:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    intro:SetWidth(w)
    local y = introH or INTRO_H
    local function placeHead(fs)
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -y)
        y = y + HEAD_H
    end
    local function placeList(list)
        for i = 1, #list do
            local s = list[i]
            s.hold:ClearAllPoints()
            s.hold:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -y)
            s.hold:SetWidth(w)
            s.icon:ClearAllPoints()
            s.icon:SetPoint("LEFT", s.hold, "LEFT", 0, 0)
            local textX = 44
            if s.swatch then
                s.swatch:ClearAllPoints()
                s.swatch:SetPoint("LEFT", s.icon, "RIGHT", 6, 0)
                textX = 94
            end
            s.name:ClearAllPoints()
            s.desc:ClearAllPoints()
            if s.pillA then
                s.name:SetPoint("TOPLEFT", s.hold, "TOPLEFT", textX, -6)
                local nameW = 96
                if type(s.name.GetStringWidth) == "function" then
                    local sw = s.name:GetStringWidth()
                    if type(sw) == "number" and sw > 24 then nameW = sw + 4 end
                end
                s.name:SetWidth(nameW)
                s.pillA:ClearAllPoints()
                s.pillA:SetPoint("LEFT", s.name, "RIGHT", 8, 0)
                s.pillB:ClearAllPoints()
                s.pillB:SetPoint("LEFT", s.pillA, "RIGHT", 6, 0)
                s.desc:SetPoint("TOPLEFT", s.name, "BOTTOMLEFT", 0, -4)
                s.desc:SetWidth(math.max(80, w - textX - 36))
            else
                s.name:SetPoint("LEFT", s.icon, "RIGHT", 8, 0)
                s.name:SetWidth(160)
                s.desc:SetPoint("LEFT", s.name, "RIGHT", 8, 0)
                s.desc:SetWidth(math.max(40, w - 160 - 36 - 72))
            end
            s.key:ClearAllPoints()
            s.onText:ClearAllPoints()
            if s.key.Hide then s.key:Hide() end
            s.onText:SetPoint("RIGHT", s.hold, "RIGHT", -10, 0)
            if s.check then
                s.check:ClearAllPoints()
                s.check:SetPoint("RIGHT", s.hold, "RIGHT", -10, 0)
            end
            if s.hoverText then
                s.hoverText:ClearAllPoints()
                s.hoverText:SetPoint("RIGHT", s.hold, "RIGHT", -10, 0)
            end
            y = y + (s.line.rowH or STYLE_H)
        end
    end
    for i = 1, #heads do
        placeHead(heads[i])
        placeList(rows[i])
    end
    if hintText then
        hintText.hold:ClearAllPoints()
        hintText.hold:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -(y + 6))
        hintText.hold:SetWidth(w)
    end
    if combatNote then
        combatNote:ClearAllPoints()
        combatNote:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -(y + (hintText and (HINT_H + 8) or 4)))
    end
end

local function buildListPage(row, spec)
    if row.made or type(CreateFrame) ~= "function" then return end
    row.made = true
    row.lines = {}
    local intro = uiFont(row, 12, DIM)
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
        -- One line of hint, then the list ends. The old 58px well left a blank band.
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
            else
                on = stagedOn("glow", line.id, spec.glowOn(line.id))
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
        rowsH = rowsH + #section.rows * (section.rowH or STYLE_H)
    end
    return (introH or INTRO_H) + #sections * HEAD_H + rowsH + (withHint and (HINT_H + 4) or 4) + 8
end

local function hiddenStyles()
    return ns.looksApiOk() ~= true
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
                local id, changed, pending = ns.shownTheme()
                local live = id == theme.id and not changed and not pending
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
        introH = 44,
        frameOn = function() return false end,
        glowOn = function() return false end,
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
                },
            },
        },
    }
end

function ns.looksPage()
    local function frameOn(id)
        return wornFrame() == id
    end
    local function glowOn(id)
        return soleGlow() == id
    end
    local frames, glows = {}, {}
    for i = 1, #FRAMES do
        local frame = FRAMES[i]
        frames[#frames + 1] = {
            kind = "frame", id = frame.id, name = frame.name, desc = frame.spec.desc,
            key = "Looks:" .. frame.id, icon = ICONS[frame.id],
            select = function()
                local live = wornFrame() == frame.id
                if type(ns.stagePick) == "function" then
                    ns.stagePick("frame", frame.id, function() applyFrame(frame.id) end, live)
                else
                    applyFrame(frame.id)
                end
                refreshLooks()
            end,
        }
    end
    for i = 1, #GLOWS do
        local glow = GLOWS[i]
        glows[#glows + 1] = {
            kind = "glow", id = glow.id, name = glow.name, desc = glow.mood,
            key = "Looks:" .. glow.id, icon = ICONS[glow.id],
            select = function()
                local live = soleGlow() == glow.id
                if type(ns.stagePick) == "function" then
                    ns.stagePick("glow", glow.id, function() applyGlow(glow.id) end, live)
                else
                    applyGlow(glow.id)
                end
                refreshLooks()
            end,
        }
    end
    local spec = {
        intro = LOOKS_INTRO,
        introH = 22,
        hint = GLOW_HINT,
        frameOn = frameOn,
        glowOn = glowOn,
        sections = {
            { head = FRAME_HEAD, rows = frames },
            { head = GLOW_HEAD, rows = glows },
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
                        build = function(row) buildListPage(row, spec) end,
                        update = function(row)
                            if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
                        end,
                        height = function() return listHeight(spec.sections, true, spec.introH) end,
                    },
                },
            },
        },
    }
end

local function registerStyles()
    if type(view) ~= "table" or type(view.AddFrameStyle) ~= "function" or type(view.AddGlowStyle) ~= "function" then
        return false
    end
    for i = 1, #FRAMES do
        view.AddFrameStyle(FRAMES[i].id, FRAMES[i].spec)
    end
    for i = 1, #GLOWS do
        view.AddGlowStyle(GLOWS[i].id, GLOWS[i].spec)
    end
    return true
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
    if not registerStyles() then
        ns.looksReady = false
        ns.looksGuard = NEED_STYLES
        say(NEED_STYLES)
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
