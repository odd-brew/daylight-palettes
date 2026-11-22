-- Frame styles, glow styles and presets from Looks v0.2.0.
-- Palettes registers them. The saved keys stay Looks:lintel, Looks:wick and
-- so on, through a Looks-named API handle. The plugin name stays Palettes.
-- The snapshot lives in Palettes' saved data and profile settings, never LooksDB.
-- A pick waits out combat. API 1.7 and 1.8 keep colors and hide this page.

local _, ns = ...

local NEED_STYLES = "Palettes: Daylight UI is missing the settings frame and glow styles need, so only colors are available."
local BOTH = "Palettes: Looks is also loaded. Turn Looks off; frame and glow styles now live in Palettes."
local GLOW_HINT = "Glow colour follows your accent colour. Change it in Daylight's accent setting, or with Palettes for DaylightUI."

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
    { id = "stamp", name = "Stamp", spec = { label = "Stamp", desc = "A tight name row and a thin power line, ring kept small.", row = true, line = true, ring = 0.35 } },
    { id = "trestle", name = "Trestle", spec = { label = "Trestle", desc = "A full portrait on a named board, power hung as a rail.", row = true, line = true } },
    { id = "flagon", name = "Flagon", spec = { label = "Flagon", desc = "A small boss and a deep cup, the name cut into the lip.", row = true, ring = 0.35, sizes = unitSizes({ height = 32 }) } },
    { id = "signboard", name = "Signboard", spec = { label = "Signboard", desc = "A hanging boss on a tall board, with a hairline rail along the bottom.", row = true, ring = 1, sizes = unitSizes({ height = 10, tabHeight = 28 }) } },
    { id = "trough", name = "Trough", spec = { label = "Trough", desc = "A full boss, a thin health lip, and power carried in a deep trough underneath.", line = true, ring = 1, sizes = unitSizes({ height = 11, powerHeight = 14 }) } },
}

local GLOWS = {
    { id = "wick", name = "Wick", mood = "A quiet flame gathers at the corners.", spec = { label = "Wick", lap = 2, draw = drawWick } },
    { id = "draught", name = "Draught", mood = "A soft wash along the rim.", spec = { label = "Draught", lap = 2, draw = drawDraught } },
    { id = "latch", name = "Latch", mood = "A short catch of light, then still.", spec = { label = "Latch", lap = 2, draw = drawLatch } },
}

local PRESETS = {
    { id = "hearthnight", name = "Hearthnight", frame = "lintel", glow = "wick", mood = "A winter hearth: a named beam, a quiet corner flame. Sits well with Palettes for DaylightUI — Ember." },
    { id = "harvestide", name = "Harvestide", frame = "sill", glow = "draught", mood = "Harvest light along the sill of the bar. Sits well with Palettes for DaylightUI — Vanilla." },
    { id = "tidemark", name = "Tidemark", frame = "stamp", glow = "draught", mood = "A tight line at the waterline, a soft wash along the rim. Sits well with Palettes for DaylightUI — Tide." },
    { id = "oldroad", name = "Old Road", frame = "lintel", glow = "latch", mood = "A weathered beam and a short catch of lantern light. Sits well with Palettes for DaylightUI — Forever." },
    { id = "vigil", name = "Vigil", frame = "sill", glow = "wick", mood = "The name tab stays, and a flame is kept lit at the corners. Sits well with Palettes for DaylightUI — Paladin." },
}

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
for i = 1, #PRESETS do ORDER[#ORDER + 1] = PRESETS[i] end

local GLOW_READS = {
    { "general", "buttonGlow" },
    { "Nameplates", "targetLight" },
}

local view
local refreshers = {}
local looksPending

local CARD = "Presets & Styles"
local CARD_INTRO = "Presets pair a frame style and a glow style only. They never change colours."
local PAGE = "Add frame styles and glow styles to Daylight. Colors stay in Palettes for DaylightUI, or in Daylight if Palettes for DaylightUI is off."
local PAGE_NOTE = "Starts off on first login · /looks"
local RESTORE_LABEL = "Restore Daylight"
local PRESET_HEAD = "PRESETS"
local FRAME_HEAD = "FRAME STYLES"
local GLOW_HEAD = "GLOW STYLES"

local CREAM = { 0.95, 0.91, 0.86, 1 }
local DIM = { 0.62, 0.56, 0.48, 1 }
local ON_INK = { 0.93, 0.84, 0.68, 1 }
local RED = { 0.48, 0.17, 0.15, 1 }
local CHIP_EDGE = { 0.45, 0.38, 0.30, 1 }
local CHIP_FILL = { 0.16, 0.15, 0.14, 1 }
local BOX_EDGE = { 0.55, 0.50, 0.44, 1 }
local BOX_FILL = { 0.10, 0.10, 0.11, 1 }
local BOX_ON = { 0.62, 0.52, 0.36, 1 }
local ROW_ON = { 0.28, 0.24, 0.20, 0.95 }
local HINT_EDGE = { 0.35, 0.32, 0.28, 1 }
local CARD_EDGE = { 0.16, 0.16, 0.19, 1 }
local CARD_FILL = { 0.12, 0.12, 0.14, 1 }

local INTRO_H = 28
local PRESET_HEAD_H = 18
local PRESET_H = 88
local STYLE_H = 26
local HEAD_H = 18
local HINT_H = 58

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

local function presetById(id)
    for i = 1, #PRESETS do
        if PRESETS[i].id == id then return PRESETS[i] end
    end
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
    local id, name = wornFrame()
    local glows = wornGlows()
    local omit = {}
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
    say("Looks: " .. name .. " queued until combat ends.")
    refreshLooks()
end

local function applyFrame(id, quiet)
    if inCombat() then
        local found = frameById(id)
        queueLook("frame", id, found and found.name or id)
        return false
    end
    local set = frameSetter()
    local shot = (set or hasMenuStyle() or hasWrite()) and capture() or nil
    if set and pcall(set, id) then
        if shot then storeSnapshot(shot) end
        refreshPage()
        refreshLooks()
        return true
    end
    local key = frameKey(id)
    if menuSetStyle(key) or writeSetting("UnitFrames", "look.style", key) then
        if shot then storeSnapshot(shot) end
        refreshPage()
        refreshLooks()
        return true
    end
    if not quiet then pointAtFrame(id) end
    return false
end

local function applyGlow(id, quiet)
    if inCombat() then
        local found = glowById(id)
        queueLook("glow", id, found and found.name or id)
        return false
    end
    local set = glowSetter()
    local shot = (set or hasWrite()) and capture() or nil
    if set and pcall(set, id) then
        if shot then storeSnapshot(shot) end
        refreshPage()
        refreshLooks()
        return true
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
        return true
    end
    if buttons or light then refreshPage() end
    if not quiet then pointAtGlow(id) end
    refreshLooks()
    return false
end

local function applyPreset(preset)
    if inCombat() then
        queueLook("preset", preset.id, preset.name)
        return
    end
    local frameOk = applyFrame(preset.frame, true)
    local glowOk = applyGlow(preset.glow, true)
    if frameOk and glowOk then return end
    local frame = frameById(preset.frame)
    local glow = glowById(preset.glow)
    say("Looks: " .. preset.name .. " is " .. frame.name .. " and " .. glow.name .. ". It does not change Palettes or the accent.")
    if not frameOk then pointAtFrame(preset.frame) end
    if not glowOk then pointAtGlow(preset.glow) end
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
    elseif pending.kind == "preset" then
        local preset = presetById(pending.id)
        if preset then applyPreset(preset) end
    end
    refreshLooks()
end

local function guardLine()
    if ns.looksGuard then return ns.looksGuard end
    if not ns.looksApiOk() then return NEED_STYLES end
end

function ns.looksSlash(msg)
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
    local preset = presetById(arg)
    if preset then
        applyPreset(preset)
        return
    end
    say(statusLine())
end

local function rowPending(kind, id)
    local pending = looksPending
    if type(pending) ~= "table" or pending.kind == "off" then return false end
    if pending.kind == kind and pending.id == id then return true end
    if pending.kind == "preset" then
        local preset = presetById(pending.id)
        if preset and ((kind == "frame" and preset.frame == id) or (kind == "glow" and preset.glow == id)) then
            return true
        end
    end
    return false
end

local function sheetHeight()
    local left = INTRO_H + PRESET_HEAD_H + #PRESETS * PRESET_H + 20
    local right = INTRO_H + HEAD_H + #FRAMES * STYLE_H + HEAD_H + #GLOWS * STYLE_H + HINT_H + 8
    if right > left then return right + 8 end
    return left + 8
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

local function redButton(parent, text, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(72, 22)
    flat(b, "BACKGROUND", RED)
    local fs = uiFont(b, 12, CREAM)
    fs:ClearAllPoints()
    fs:SetPoint("CENTER", b, "CENTER", 0, 0)
    if type(fs.SetJustifyH) == "function" then fs:SetJustifyH("CENTER") end
    fs:SetText(text)
    b:SetScript("OnClick", function() onClick() end)
    return b
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

local function sameRestore()
    if type(ns.armLooksRestore) == "function" then ns.armLooksRestore() end
    local d = DaylightUI
    if type(d) == "table" and type(d.Set) == "function" then
        d:Set("Palettes", "palette", "off")
    end
end

local function buildRestore(row)
    if row.made or type(CreateFrame) ~= "function" then return end
    row.made = true
    local caption = uiFont(row, 12, DIM)
    caption:SetText(RESTORE_LABEL)
    local button = redButton(row, "Restore", sameRestore)
    row.restoreButton = button
    hookSize(row, function()
        button:ClearAllPoints()
        caption:ClearAllPoints()
        button:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -4)
        caption:SetPoint("RIGHT", button, "LEFT", -8, 0)
    end)
end

local function restoreItem()
    return {
        type = "custom",
        label = RESTORE_LABEL,
        build = buildRestore,
        height = function() return 32 end,
    }
end

local function buildPage(row, sheet)
    if row.made or type(CreateFrame) ~= "function" then return end
    row.made = true
    row.lines = {}

    local intro = uiFont(row, 12, DIM)
    intro:SetText(CARD_INTRO)
    intro:SetWordWrap(true)
    local note = uiFont(row, 12, DIM)
    note:SetText(PAGE_NOTE)
    if type(note.SetJustifyH) == "function" then note:SetJustifyH("RIGHT") end
    if type(note.SetWordWrap) == "function" then note:SetWordWrap(false) end

    local function heading(text)
        local fs = uiFont(row, 11, DIM)
        fs:SetText(text)
        return fs
    end

    local presetHead = heading(PRESET_HEAD)
    local presetRows = {}
    for i = 1, #sheet.presets do
        local preset = sheet.presets[i]
        local hold = CreateFrame("Frame", nil, row)
        hold:SetHeight(PRESET_H - 8)
        flat(hold, "BACKGROUND", CARD_EDGE)
        local fill = hold:CreateTexture(nil, "BORDER")
        if type(fill.SetColorTexture) == "function" then
            fill:SetColorTexture(CARD_FILL[1], CARD_FILL[2], CARD_FILL[3], 1)
        end
        fill:SetPoint("TOPLEFT", hold, "TOPLEFT", 1, -1)
        fill:SetPoint("BOTTOMRIGHT", hold, "BOTTOMRIGHT", -1, 1)
        local name = uiFont(hold, 14, CREAM)
        name:SetText(preset.name)
        local chip = CreateFrame("Frame", nil, hold)
        flat(chip, "BACKGROUND", CHIP_EDGE)
        local chipFill = chip:CreateTexture(nil, "BORDER")
        if type(chipFill.SetColorTexture) == "function" then
            chipFill:SetColorTexture(CHIP_FILL[1], CHIP_FILL[2], CHIP_FILL[3], 1)
        end
        chipFill:SetPoint("TOPLEFT", chip, "TOPLEFT", 1, -1)
        chipFill:SetPoint("BOTTOMRIGHT", chip, "BOTTOMRIGHT", -1, 1)
        local chipText = uiFont(chip, 10, ON_INK)
        chipText:SetText(preset.chip)
        chipText:SetPoint("CENTER", chip, "CENTER", 0, 0)
        if type(chipText.SetJustifyH) == "function" then chipText:SetJustifyH("CENTER") end
        local chipW = chipText.GetStringWidth and chipText:GetStringWidth() or 72
        if type(chipW) ~= "number" or chipW < 8 then chipW = 72 end
        chip:SetSize(chipW + 12, 16)
        local mood = uiFont(hold, 11, DIM)
        mood:SetText(preset.mood)
        mood:SetWordWrap(true)
        local button = redButton(hold, "Apply", preset.apply)
        presetRows[#presetRows + 1] = { hold = hold, name = name, chip = chip, mood = mood, button = button }
    end

    local frameHead = heading(FRAME_HEAD)
    local glowHead = heading(GLOW_HEAD)

    local function styleLine(entry)
        local hold = CreateFrame("Button", nil, row)
        hold:SetHeight(STYLE_H)
        local hi = hold:CreateTexture(nil, "BACKGROUND")
        if type(hi.SetColorTexture) == "function" then
            hi:SetColorTexture(ROW_ON[1], ROW_ON[2], ROW_ON[3], ROW_ON[4])
        end
        hi:SetAllPoints()
        hi:Hide()
        local box = CreateFrame("Button", nil, hold)
        box:SetSize(14, 14)
        flat(box, "BACKGROUND", BOX_EDGE)
        local boxFill = box:CreateTexture(nil, "BORDER")
        if type(boxFill.SetColorTexture) == "function" then
            boxFill:SetColorTexture(BOX_FILL[1], BOX_FILL[2], BOX_FILL[3], 1)
        end
        boxFill:SetPoint("TOPLEFT", box, "TOPLEFT", 1, -1)
        boxFill:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -1, 1)
        local mark = box:CreateTexture(nil, "ARTWORK")
        if type(mark.SetColorTexture) == "function" then
            mark:SetColorTexture(BOX_ON[1], BOX_ON[2], BOX_ON[3], 1)
        end
        mark:SetSize(8, 8)
        mark:SetPoint("CENTER", box, "CENTER", 0, 0)
        mark:Hide()
        local icon = drawIcon(hold, entry.icon)
        local name = uiFont(hold, 13, CREAM)
        name:SetText(entry.name)
        local desc = uiFont(hold, 11, DIM)
        desc:SetText(entry.desc)
        if type(desc.SetWordWrap) == "function" then desc:SetWordWrap(false) end
        if type(name.SetWordWrap) == "function" then name:SetWordWrap(false) end
        local key = uiFont(hold, 11, DIM)
        key:SetText(entry.key)
        local onText = uiFont(hold, 12, ON_INK)
        onText:SetText("[On]")
        onText:Hide()
        local line = { id = entry.id, kind = entry.kind }
        line.key = key
        line.onText = onText
        function line.SetOn(on, pending)
            line.markOn = on and true or false
            line.markPending = pending and true or false
            local marked = line.markOn or line.markPending
            if marked then hi:Show() else hi:Hide() end
            if marked then mark:Show() else mark:Hide() end
            if on and not pending then onText:SetText("[On]") end
            if pending then onText:SetText("PENDING") end
            if marked then
                if key.Hide then key:Hide() end
                onText:ClearAllPoints()
                onText:SetPoint("RIGHT", hold, "RIGHT", -4, 0)
                onText:Show()
            else
                if key.Show then key:Show() end
                if onText.Hide then onText:Hide() end
            end
            if type(boxFill.SetColorTexture) == "function" then
                local c = marked and BOX_ON or BOX_FILL
                boxFill:SetColorTexture(c[1], c[2], c[3], 1)
            end
        end
        local function pick() entry.select() end
        hold:SetScript("OnClick", pick)
        box:SetScript("OnClick", pick)
        row.lines[#row.lines + 1] = line
        return { hold = hold, box = box, icon = icon, name = name, desc = desc, key = key, onText = onText, line = line }
    end

    local frameRows, glowRows = {}, {}
    for i = 1, #sheet.frames do frameRows[#frameRows + 1] = styleLine(sheet.frames[i]) end
    for i = 1, #sheet.glows do glowRows[#glowRows + 1] = styleLine(sheet.glows[i]) end

    local hint = CreateFrame("Frame", nil, row)
    hint:SetHeight(HINT_H)
    flat(hint, "BACKGROUND", HINT_EDGE)
    local hintFill = hint:CreateTexture(nil, "BORDER")
    if type(hintFill.SetColorTexture) == "function" then
        hintFill:SetColorTexture(0.12, 0.12, 0.13, 1)
    end
    hintFill:SetPoint("TOPLEFT", hint, "TOPLEFT", 1, -1)
    hintFill:SetPoint("BOTTOMRIGHT", hint, "BOTTOMRIGHT", -1, 1)
    local hintText = uiFont(hint, 11, DIM)
    hintText:SetText(GLOW_HINT)
    hintText:SetWordWrap(true)
    local combatNote = uiFont(row, 12, ON_INK)
    combatNote:SetText("Applies when combat ends.")
    if combatNote.Hide then combatNote:Hide() end

    local function place()
        local w = row:GetWidth()
        if type(w) ~= "number" or w < 120 then w = 760 end
        local gap = 22
        local leftW = math.floor((w - gap) * 0.50)
        local rightX = leftW + gap
        local rightW = w - rightX
        intro:ClearAllPoints()
        intro:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
        intro:SetWidth(leftW)
        local anchor, nx, ny = row, 0, 22
        if type(row.GetParent) == "function" then
            local parent = row:GetParent()
            if type(parent) == "table" then anchor, nx, ny = parent, -12, -12 end
        end
        note:ClearAllPoints()
        note:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", nx, ny)
        presetHead:ClearAllPoints()
        presetHead:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -INTRO_H)
        local y = INTRO_H + PRESET_HEAD_H
        for i = 1, #presetRows do
            local p = presetRows[i]
            p.hold:ClearAllPoints()
            p.hold:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -y)
            p.hold:SetWidth(leftW)
            p.name:ClearAllPoints()
            p.name:SetPoint("TOPLEFT", p.hold, "TOPLEFT", 10, -10)
            p.chip:ClearAllPoints()
            p.chip:SetPoint("LEFT", p.name, "RIGHT", 8, 0)
            p.button:ClearAllPoints()
            p.button:SetPoint("TOPRIGHT", p.hold, "TOPRIGHT", -10, -10)
            p.mood:ClearAllPoints()
            p.mood:SetPoint("TOPLEFT", p.hold, "TOPLEFT", 10, -34)
            p.mood:SetWidth(math.max(40, leftW - 108))
            y = y + PRESET_H
        end
        combatNote:ClearAllPoints()
        combatNote:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -y)
        local function placeHead(fs, at)
            fs:ClearAllPoints()
            fs:SetPoint("TOPLEFT", row, "TOPLEFT", rightX, -at)
        end
        local function placeStyle(list, at)
            for i = 1, #list do
                local s = list[i]
                s.hold:ClearAllPoints()
                s.hold:SetPoint("TOPLEFT", row, "TOPLEFT", rightX, -at)
                s.hold:SetWidth(rightW)
                s.box:ClearAllPoints()
                s.box:SetPoint("LEFT", s.hold, "LEFT", 0, 0)
                s.icon:ClearAllPoints()
                s.icon:SetPoint("LEFT", s.box, "RIGHT", 8, 0)
                s.name:ClearAllPoints()
                s.name:SetPoint("LEFT", s.icon, "RIGHT", 8, 0)
                s.name:SetWidth(88)
                s.desc:ClearAllPoints()
                s.desc:SetPoint("LEFT", s.name, "RIGHT", 8, 0)
                s.desc:SetWidth(math.max(40, rightW - 14 - 36 - 88 - 150))
                s.key:ClearAllPoints()
                s.onText:ClearAllPoints()
                if s.line.markOn or s.line.markPending then
                    if s.key.Hide then s.key:Hide() end
                    s.onText:SetPoint("RIGHT", s.hold, "RIGHT", -4, 0)
                else
                    if s.key.Show then s.key:Show() end
                    s.key:SetPoint("RIGHT", s.hold, "RIGHT", -4, 0)
                end
                at = at + STYLE_H
            end
            return at
        end
        local ry = INTRO_H
        placeHead(frameHead, ry)
        ry = placeStyle(frameRows, ry + HEAD_H)
        placeHead(glowHead, ry)
        ry = placeStyle(glowRows, ry + HEAD_H)
        hint:ClearAllPoints()
        hint:SetPoint("TOPLEFT", row, "TOPLEFT", rightX, -(ry + 6))
        hint:SetWidth(rightW)
        hintText:ClearAllPoints()
        hintText:SetPoint("TOPLEFT", hint, "TOPLEFT", 8, -8)
        hintText:SetWidth(math.max(40, rightW - 16))
    end

    function row.UpdateLooks()
        local waiting = type(looksPending) == "table"
        if combatNote.SetShown then combatNote:SetShown(waiting) end
        for i = 1, #row.lines do
            local line = row.lines[i]
            local pending = rowPending(line.kind, line.id)
            local on = line.kind == "frame" and sheet.frameOn(line.id) or sheet.glowOn(line.id)
            line.SetOn(on and true or false, pending)
        end
    end
    hookSize(row, place)
    row.UpdateLooks()
    refreshers[#refreshers + 1] = function()
        if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
    end
end

function ns.looksPage()
    local function frameOn(id)
        return wornFrame() == id
    end
    local function glowOn(id)
        local glows = wornGlows()
        for i = 1, #glows do
            if glows[i].id == id then return true end
        end
        return false
    end
    local presets, frames, glows = {}, {}, {}
    for i = 1, #PRESETS do
        local preset = PRESETS[i]
        local frame = frameById(preset.frame)
        local glow = glowById(preset.glow)
        presets[#presets + 1] = {
            id = preset.id,
            name = preset.name,
            chip = frame.name .. " + " .. glow.name,
            mood = preset.mood,
            apply = function() applyPreset(preset) end,
        }
    end
    for i = 1, #FRAMES do
        local frame = FRAMES[i]
        frames[#frames + 1] = {
            kind = "frame", id = frame.id, name = frame.name, desc = frame.spec.desc,
            key = "Looks:" .. frame.id, icon = ICONS[frame.id],
            select = function() applyFrame(frame.id) end,
        }
    end
    for i = 1, #GLOWS do
        local glow = GLOWS[i]
        glows[#glows + 1] = {
            kind = "glow", id = glow.id, name = glow.name, desc = glow.mood,
            key = "Looks:" .. glow.id, icon = ICONS[glow.id],
            select = function() applyGlow(glow.id) end,
        }
    end
    local sheet = { presets = presets, frames = frames, glows = glows, frameOn = frameOn, glowOn = glowOn }
    return {
        id = "looks",
        label = "Looks",
        desc = PAGE,
        hidden = function() return ns.looksApiOk() ~= true end,
        groups = {
            { label = "Restore", bare = true, wide = true, items = { restoreItem() } },
            {
                label = CARD,
                wide = true,
                items = {
                    {
                        type = "custom",
                        label = CARD,
                        build = function(row) buildPage(row, sheet) end,
                        update = function(row)
                            if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
                        end,
                        height = function() return sheetHeight() end,
                    },
                },
            },
            { label = "Restore", bare = true, wide = true, items = { restoreItem() } },
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
