-- ODB-141. Checks Palettes' color data and the addon manifest.
-- From the repo root: lua5.1 tools/palettes_check.lua

local source = arg and arg[0] or ""
local scriptDir = source:match("^(.*)/")
local root = "."
if scriptDir and scriptDir ~= "" then
    root = scriptDir:match("^(.*)/") or "."
end

local failures = 0

local function fail(label)
    failures = failures + 1
    io.stderr:write(label .. "\n")
end

local function check(actual, expected, label)
    if actual ~= expected then
        fail(label .. "\n  expected: " .. tostring(expected) .. "\n  actual:   " .. tostring(actual))
    end
end

local colorsPath = root .. "/Palettes/PalettesColors.lua"
local mainPath = root .. "/Palettes/Palettes.lua"
local tocPath = root .. "/Palettes/Palettes.toc"

local chunk, loadErr = loadfile(colorsPath)
if not chunk then
    fail("could not load PalettesColors.lua: " .. tostring(loadErr))
    os.exit(1)
end

-- The color file is plain Lua. It must not need the game.
setfenv(chunk, {
    math = math,
    string = string,
    tonumber = tonumber,
    type = type,
    pairs = pairs,
    ipairs = ipairs,
})

local ns = {}
local ok, runErr = pcall(chunk, "Palettes", ns)
if not ok then
    fail("PalettesColors.lua failed: " .. tostring(runErr))
    os.exit(1)
end

local function hex(id, key)
    local p = ns.byId and ns.byId[id]
    local color = p and p[key]
    return color and color.hex
end

check(type(ns.byId), "table", "byId")
check(ns.order and #ns.order or 0, 33, "palette count")

local ids = {
    "ember", "tide", "dusk", "ash", "pine",
    "forgeglow", "nightglass", "vesper", "carmine-night", "gilded", "phosphor", "ink", "sightline",
    "warrior", "mage", "paladin", "priest",
    "hunter", "rogue", "shaman", "warlock", "druid",
    "keepstone", "ironbanner", "sapphire-crown", "crownwall", "deepforge",
    "starshade", "cogspark", "rustbrand", "gravelight", "plainsong", "junglefire",
}
for i = 1, #ids do
    check(ns.order[i], ids[i], "order " .. i)
    if ns.byId[ids[i]] == nil then fail("missing palette " .. ids[i]) end
end

check(hex("ember", "window"), "#18120E", "ember window")
check(hex("ember", "text"), "#F4E8D8", "ember text")
check(hex("ember", "c2"), "#E8A04A", "ember highlight")
check(hex("ember", "off"), "#9E8971", "ember dim text")
check(hex("tide", "window"), "#0E1418", "tide window")
check(hex("tide", "c2"), "#3DB8A8", "tide highlight")
check(hex("dusk", "window"), "#14111A", "dusk window")
check(hex("dusk", "c2"), "#B07AC8", "dusk highlight")
check(hex("ash", "window"), "#121315", "ash window")
check(hex("ash", "title"), "#FFFFFF", "ash title")
check(hex("ash", "c2"), "#C8C4B8", "ash highlight")
check(hex("pine", "window"), "#0E140F", "pine window")
check(hex("pine", "c2"), "#7CB86A", "pine highlight")
check(hex("pine", "emptyBorder"), "#304232", "pine item well")

local v2 = {
    forgeglow = { group = "dark", window = "#0C0908", background = "#100C0A", border = "#050302",
        band = "#221714", bandLit = "#3A241C", c1 = "#C44810", c2 = "#F26A1A", c3 = "#F6B17A",
        title = "#FFF6EE", text = "#F3E6D8", label = "#D0B49A", off = "#A08068" },
    nightglass = { group = "dark", window = "#071114", background = "#0A1518", border = "#03080A",
        band = "#163033", bandLit = "#2A4A4E", c1 = "#8AA3A8", c2 = "#C5D5D8", c3 = "#E8F0F2",
        title = "#F4FBFC", text = "#E2EEF0", label = "#B7C9CC", off = "#7A9094" },
    vesper = { group = "dark", window = "#0D0A16", background = "#120E1C", border = "#07050E",
        band = "#241A38", bandLit = "#3A2A55", c1 = "#D63080", c2 = "#E94A96", c3 = "#F099C0",
        title = "#F8F2FC", text = "#E8DCF4", label = "#C4B0D8", off = "#8A789C" },
    ["carmine-night"] = { group = "dark", window = "#100A0C", background = "#140E10", border = "#080506",
        band = "#2A161A", bandLit = "#4A242C", c1 = "#D4283C", c2 = "#E03040", c3 = "#E07080",
        title = "#FFF2F2", text = "#F0DEDE", label = "#D0B0B0", off = "#9A7878" },
    gilded = { group = "dark", window = "#0A0907", background = "#0E0D0A", border = "#050403",
        band = "#242018", bandLit = "#3A3428", c1 = "#B89020", c2 = "#D4AF37", c3 = "#F0D878",
        title = "#FFF8E8", text = "#F0E6C8", label = "#D4C498", off = "#A09070" },
    phosphor = { group = "dark", window = "#070806", background = "#0A0C09", border = "#030403",
        band = "#162014", bandLit = "#2A3A26", c1 = "#7AC400", c2 = "#B8FF00", c3 = "#E8FF8A",
        title = "#F4FFE8", text = "#E0F0D0", label = "#B0C8A0", off = "#7A9270" },
    ink = { group = "dark", window = "#0A0A0A", background = "#0A0A0A", border = "#000000",
        band = "#1C1C1C", bandLit = "#2E2E2E", c1 = "#C8C8C8", c2 = "#FFFFFF", c3 = "#8A8A8A",
        title = "#FFFFFF", text = "#F2F2F2", label = "#D0D0D0", off = "#8C8C8C" },
    sightline = { group = "dark", window = "#0E141A", background = "#121820", border = "#06080C",
        band = "#1C2836", bandLit = "#2E3E50", c1 = "#C48410", c2 = "#E8A020", c3 = "#F3C86A",
        title = "#F4F7FB", text = "#E2E8F0", label = "#B8C4D2", off = "#7E8C9A" },
}

local v2Keys = { "window", "background", "border", "band", "bandLit", "c1", "c2", "c3", "title", "text", "label", "off" }
for id, want in pairs(v2) do
    local p = ns.byId[id]
    if type(p) ~= "table" then
        fail("missing v2 palette " .. id)
    else
        check(p.group, "dark", id .. " group")
        for i = 1, #v2Keys do
            local key = v2Keys[i]
            check(hex(id, key), want[key], id .. " " .. key)
        end
        if p.windowAlpha ~= nil then fail(id .. " should not force window opacity") end
        if p.tip ~= nil then fail(id .. " should not have a tooltip plate") end
        if p.chatPlate ~= nil then fail(id .. " should not have a chat plate") end
    end
end

for i = 1, 13 do
    local p = ns.byId[ids[i]]
    if p.group ~= "dark" then fail(ids[i] .. " should be a dark palette") end
    if p.windowAlpha ~= nil then fail(ids[i] .. " should not force window opacity") end
    if p.tip ~= nil then fail(ids[i] .. " should not have a separate tooltip shell") end
    if p.chatPlate ~= nil then fail(ids[i] .. " should not have a chat plate") end
end
if ns.byId.linen or ns.byId.frost or ns.byId.meadow or ns.byId.petal
    or ns.byId["bone-and-ash"] or ns.byId.tidepool then
    fail("light palettes should be gone")
end

local banned = { good = true, warn = true, bad = true, damage = true, money = true }
for id, p in pairs(ns.byId) do
    for key in pairs(p) do
        if banned[key] then fail(id .. " carries a game-meaning color key " .. key) end
    end
end

check(ns.groups and #ns.groups, 3, "palette groups")
check(ns.groups and ns.groups[1].label, "Dark", "dark group")
check(ns.groups and #ns.groups[1].ids, 13, "dark count")
check(ns.groups and ns.groups[2].label, "Class themes", "class group")
check(ns.groups and #ns.groups[2].ids, 9, "class theme count")
check(ns.groups and ns.groups[3].label, "Realm themes", "realm group")
check(ns.groups and #ns.groups[3].ids, 11, "realm theme count")
check(ns.off and ns.off.name, "Daylight (off)", "restore name")

-- v3 sheet. Priest and Rustbrand accent stops are the nudged values.
-- Every other token is the design sheet. Each accent has to clear 3:1
-- on its own panel and its own band.
local v3 = {
    warrior = { group = "class", window = "#121110", background = "#171614", border = "#070605",
        band = "#2A2823", bandLit = "#424038", c1 = "#A88858", c2 = "#D4B07A", c3 = "#EEDCC0",
        title = "#F9F8F6", text = "#EDE9E3", label = "#A28B6A", off = "#A08C6E" },
    mage = { group = "class", window = "#0B111A", background = "#0F1622", border = "#04070B",
        band = "#172437", bandLit = "#273D5A", c1 = "#2E8EC4", c2 = "#56BEEA", c3 = "#B4E2F6",
        title = "#F6F8F9", text = "#E3EAEE", label = "#6191A6", off = "#6490A2" },
    paladin = { group = "class", window = "#150F12", background = "#1C1418", border = "#090607",
        band = "#2E1F26", bandLit = "#4A313C", c1 = "#C45E8A", c2 = "#E892B8", c3 = "#F6CCDD",
        title = "#F9F6F7", text = "#EEE3E7", label = "#B47993", off = "#B07B92" },
    priest = { group = "class", window = "#0B0C0E", background = "#0F1013", border = "#040405",
        band = "#1C1E23", bandLit = "#30333B", c1 = "#6E8CAA", c2 = "#8EADC8", c3 = "#E4F0F8",
        title = "#F7F7F8", text = "#E7E8EA", label = "#80868E", off = "#81868D" },
    hunter = { group = "class", window = "#12100A", background = "#16140C", border = "#060503",
        band = "#2A2418", bandLit = "#403828", c1 = "#7A8830", c2 = "#A8B44A", c3 = "#D8E090",
        title = "#F8F8F6", text = "#EBECE4", label = "#8B9062", off = "#8A8F66" },
    rogue = { group = "class", window = "#10110B", background = "#15160F", border = "#060604",
        band = "#28291C", bandLit = "#3E3F2A", c1 = "#9A9A28", c2 = "#D0D040", c3 = "#ECEC90",
        title = "#F9F9F6", text = "#EDEDE3", label = "#929254", off = "#929259" },
    shaman = { group = "class", window = "#0F1116", background = "#14161C", border = "#05060A",
        band = "#222830", bandLit = "#384456", c1 = "#3E6ECF", c2 = "#4A82E0", c3 = "#A8C8F4",
        title = "#F6F7F9", text = "#E3E7EE", label = "#798FB4", off = "#7C90B1" },
    warlock = { group = "class", window = "#0E0C16", background = "#14101C", border = "#07050C",
        band = "#241C32", bandLit = "#382C4E", c1 = "#695BC7", c2 = "#7A6AE0", c3 = "#B8AEEF",
        title = "#F6F6F9", text = "#E4E3EE", label = "#8780B7", off = "#8881B4" },
    druid = { group = "class", window = "#0F0D08", background = "#14120A", border = "#060503",
        band = "#262016", bandLit = "#3E3224", c1 = "#AC5014", c2 = "#C26218", c3 = "#E8A878",
        title = "#F9F7F6", text = "#EEE7E3", label = "#A78062", off = "#A38166" },
    keepstone = { group = "realm", window = "#16120C", background = "#1E1912", border = "#090704",
        band = "#322C22", bandLit = "#4C4436", c1 = "#867446", c2 = "#9A8650", c3 = "#C4B484",
        title = "#F8F8F7", text = "#EBE9E5", label = "#9B937A", off = "#9B937E" },
    ironbanner = { group = "realm", window = "#110E0C", background = "#17120F", border = "#060403",
        band = "#2A201A", bandLit = "#45332A", c1 = "#B64B2E", c2 = "#C8583A", c3 = "#EBA488",
        title = "#F9F6F6", text = "#EDE5E3", label = "#AB7E72", off = "#A88075" },
    ["sapphire-crown"] = { group = "realm", window = "#0A0D1A", background = "#0D1222", border = "#04050B",
        band = "#18214A", bandLit = "#283770", c1 = "#B89A48", c2 = "#E0C676", c3 = "#F4E6B8",
        title = "#F9F8F6", text = "#EEEBE3", label = "#9B8A57", off = "#998A5C" },
    crownwall = { group = "realm", window = "#101216", background = "#15181D", border = "#06070A",
        band = "#252A33", bandLit = "#3A414E", c1 = "#5A82BE", c2 = "#7FA6DC", c3 = "#C8D8F0",
        title = "#F6F7F9", text = "#E3E7ED", label = "#7C92B1", off = "#7E93AF" },
    deepforge = { group = "realm", window = "#111213", background = "#17181A", border = "#060607",
        band = "#28292C", bandLit = "#404247", c1 = "#B65734", c2 = "#D07048", c3 = "#E8B090",
        title = "#F9F7F6", text = "#EDE6E3", label = "#AF8776", off = "#AD8879" },
    starshade = { group = "realm", window = "#0C0C18", background = "#101020", border = "#05050C",
        band = "#1C1C3A", bandLit = "#2D2D58", c1 = "#8A78D4", c2 = "#B8A8F0", c3 = "#E0D8FA",
        title = "#F6F6F9", text = "#E5E3EE", label = "#8B7EB6", off = "#8B7FB3" },
    cogspark = { group = "realm", window = "#0F1112", background = "#141618", border = "#050606",
        band = "#23272A", bandLit = "#383E43", c1 = "#C430A0", c2 = "#F24EC8", c3 = "#F9B0E4",
        title = "#F9F6F8", text = "#EEE3EB", label = "#B57BA6", off = "#B17CA3" },
    rustbrand = { group = "realm", window = "#111109", background = "#17170E", border = "#060603",
        band = "#28281A", bandLit = "#424129", c1 = "#A86818", c2 = "#C98420", c3 = "#F0C48A",
        title = "#F9F7F6", text = "#EEE6E3", label = "#AF8471", off = "#AC8574" },
    gravelight = { group = "realm", window = "#0E100F", background = "#131614", border = "#050605",
        band = "#212622", bandLit = "#363E38", c1 = "#82A06A", c2 = "#A9C38C", c3 = "#D8E6C8",
        title = "#F7F8F7", text = "#E8EBE5", label = "#80926D", off = "#829171" },
    plainsong = { group = "realm", window = "#14110D", background = "#1B1712", border = "#070605",
        band = "#2C251C", bandLit = "#463B2D", c1 = "#2A7EAA", c2 = "#3AA4D4", c3 = "#A8D8F0",
        title = "#F6F8F9", text = "#E3EAEE", label = "#6493A8", off = "#6993A5" },
    junglefire = { group = "realm", window = "#0A1311", background = "#0E1916", border = "#040806",
        band = "#172B26", bandLit = "#26443C", c1 = "#C9411D", c2 = "#E85A32", c3 = "#F4A888",
        title = "#F9F6F6", text = "#EEE5E3", label = "#B28376", off = "#AF8579" },
}
for id, want in pairs(v3) do
    local p = ns.byId[id]
    if type(p) ~= "table" then
        fail("missing v3 palette " .. id)
    else
        check(p.group, want.group, id .. " group")
        check(p.name ~= nil and p.name ~= "", true, id .. " has a ship name")
        for i = 1, #v2Keys do
            local key = v2Keys[i]
            check(hex(id, key), want[key], id .. " " .. key)
        end
        if not ns.accentPasses(p.c2, p) then fail(id .. " accent is under 3:1 on its own panel or band") end
        if p.windowAlpha ~= nil then fail(id .. " should not force window opacity") end
        if p.tip ~= nil or p.chatPlate ~= nil then fail(id .. " should not add a tooltip or chat plate") end
    end
end

local function readAll(path)
    local f = io.open(path, "r")
    if not f then
        fail("missing " .. path)
        return ""
    end
    local text = f:read("*a")
    f:close()
    return text or ""
end

local toc = readAll(tocPath)
if not toc:find("## Title: Palettes %(DaylightUI Plugin%)", 1, false) then
    fail("toc title must end with (DaylightUI Plugin)")
end
if not toc:find("## Dependencies: DaylightUI", 1, true) then
    fail("toc must depend on DaylightUI")
end
if not toc:find("## SavedVariables: PalettesAccount", 1, true) then
    fail("toc must save PalettesAccount")
end
if not toc:find("## SavedVariablesPerCharacter: PalettesChar", 1, true) then
    fail("toc must save PalettesChar for each character")
end
if not toc:find("## Interface: 16001", 1, true) then
    fail("toc interface should be 16001")
end

local main = readAll(mainPath)
if main:find('"softness"', 1, true) or main:find('"brightness"', 1, true) then
    fail("softness or brightness would retint class colors")
end
if main:find("hooksecurefunc", 1, true) then
    fail("hooksecurefunc is not used on Daylight or the game")
end
if main:find("INK.GOOD", 1, true) or main:find("INK.MONEY", 1, true) or main:find("INK.DAMAGE", 1, true) then
    fail("game-meaning ink would be overwritten")
end
if main:find("GameTooltipText", 1, true) or main:find("GameTooltipHeaderText", 1, true) then
    fail("tooltip text would be recolored")
end
if main:find("palettesPlate", 1, true) or main:find("palettesChatPlate", 1, true) then
    fail("light tooltip and chat plates should be gone")
end
if main:find('"OUTLINE"', 1, true) or main:find("'OUTLINE'", 1, true) or main:find('"THICKOUTLINE"', 1, true) then
    fail("a font would be given an outline flag")
end
if main:find("textOutline", 1, true) or main:find("textShadow", 1, true) then
    fail("outline and shadow stay the player's settings")
end
if main:find('group == "light"', 1, true) or main:find("windowAlpha", 1, true) then
    fail("light-palette path should be gone")
end
if not main:find('return "ember"', 1, true) then
    fail("a missing palette must fall back to Ember")
end
if not main:find("Some text changes color after a /reload.", 1, true) then
    fail("missing reload note")
end
if not main:find("Applies immediately out of combat.", 1, true) then
    fail("missing combat note")
end
if not main:find("Applies when combat ends.", 1, true) then
    fail("missing combat-end note")
end
if main:find("Live sample", 1, true) then
    fail("the live sample bar should be gone")
end
if not main:find("classAccent", 1, true) then
    fail("class accent control is missing")
end
local _, mixCount = main:gsub("mixAccent", "mixAccent")
if mixCount ~= 1 or not main:find("db.mixAccent = nil", 1, true) then
    fail("mixAccent remains")
end
if main:find("Accent from", 1, true) then
    fail("Accent from remains")
end
if main:find("Use this palette on every character", 1, true) then
    fail("the every-character option remains")
end
if not main:find('label = "Save for this character only"', 1, true) then
    fail("missing save-for-this-character option")
end
if not main:find("Off: this character uses your account palette. On: changes here apply only to this character.", 1, true) then
    fail("missing character override help")
end
local choicesAt = main:find('label = "Choices"', 1, true)
local accentAt = main:find('label = "Accent follows class"', 1, true)
local saveAt = main:find('label = "Save for this character only"', 1, true)
local restoreAt = main:find('label = "Restore Daylight colors"', 1, true)
if not (choicesAt and accentAt and saveAt and restoreAt
    and choicesAt < accentAt and accentAt < saveAt and saveAt < restoreAt) then
    fail("settings are out of order")
end
if not main:find("ns.classShade(color, frame, token)", 1, true) then
    fail("class accent must shade every palette, light and dark")
end
if main:find('name .. " skipped"', 1, true) or main:find("palette accent stays", 1, true) then
    fail("class accent must not fall back to the palette accent")
end
if not main:find("ns.accentPasses", 1, true) then
    fail("accent contrast check is missing")
end
if not main:find('d:Get("ActionBars", "skinMenus")', 1, true) then
    fail("micro menu plates must follow Daylight's style switch")
end
if not main:find('d:Get("UnitFrames", "colors.health")', 1, true) then
    fail("dark health mode must read Daylight's health setting")
end
if not main:find("Style.GetShell", 1, true) and not main:find("GetShell", 1, true) then
    fail("name tabs must use the shell Daylight already built")
end
if not main:find("frame.tab", 1, true) then
    fail("name tabs must look for the private tab and skip when it is missing")
end
if not main:find("SetStatusBarColor", 1, true) then
    fail("dark health must recolor the remaining fill")
end
if main:find('owns = { "healthFill" }', 1, true) or main:find("healthBack", 1, true) then
    fail("dark health must not take the fill away from other modes or recolor missing health")
end

local shown = readAll(root .. "/README.md") .. "\n" .. main .. "\n" .. readAll(colorsPath)
local bannedWord = {
    "horde", "alliance", "night elf", "dwarf", "gnome", "tauren", "undead",
}
for i = 1, #bannedWord do
    local word = bannedWord[i]
    if shown:lower():find(word, 1, true) then
        fail("a ship name or a player-facing line uses a faction or ancestry word: " .. word)
    end
end
if type(ns.accentPasses) ~= "function" or type(ns.shiftShade) ~= "function"
    or type(ns.classShade) ~= "function" or type(ns.shadeOf) ~= "table"
    or type(ns.classes) ~= "table" or type(ns.classById) ~= "table" then
    fail("class shade table is not in the color file")
end

-- The checker's own contrast math. It must agree with the addon's, so a
-- weakened accentPasses cannot hide a failing mix.
local function channel(v)
    if v <= 0.04045 then return v / 12.92 end
    return ((v + 0.055) / 1.055) ^ 2.4
end
local function ratio(a, b)
    local function lum(color)
        return 0.2126 * channel(color[1]) + 0.7152 * channel(color[2]) + 0.0722 * channel(color[3])
    end
    local x, y = lum(a), lum(b)
    if y > x then x, y = y, x end
    return (x + 0.05) / (y + 0.05)
end
local function expectPass(color, palette)
    return ratio(color, palette.background) >= 3 and ratio(color, palette.band) >= 3
end

for i = 1, #ns.order do
    local accent = ns.byId[ns.order[i]]
    for n = 1, #ns.order do
        local frame = ns.byId[ns.order[n]]
        if ns.accentPasses(accent.c2, frame) ~= expectPass(accent.c2, frame) then
            fail(ns.order[i] .. " accent on " .. ns.order[n] .. " does not match the contrast check")
        end
    end
end

if not ns.accentPasses(ns.byId.phosphor.c2, ns.byId.gilded) then fail("phosphor accent should pass on Gilded") end

-- Every class shade on every palette. The precomputed hex, the shift, and
-- the contrast check have to agree. One miss fails the build. There is no
-- palette-accent fallback.
check(ns.shadeLMin, 0.30, "shade lightness floor")
check(ns.shadeLMax, 0.88, "shade lightness ceiling")
check(ns.shadeChromaMin, 0.08, "shade chroma floor")
check(ns.shadeStep, 0.005, "shade step")
for i = 1, #ns.classes do
    local class = ns.classes[i]
    local row = ns.shadeOf[class.id]
    if type(row) ~= "table" then
        fail("missing shade row for " .. class.id)
    else
        for n = 1, #ns.order do
            local id = ns.order[n]
            local palette = ns.byId[id]
            local hex = row[id]
            local shifted = ns.shiftShade(class.color, palette, class.id)
            local shipped = ns.classShade(class.color, palette, class.id)
            if type(hex) ~= "string" then
                fail(class.id .. " on " .. id .. " has no precomputed shade")
            else
                check(shifted and shifted.hex, hex, class.id .. " shift on " .. id)
                check(shipped and shipped.hex, hex, class.id .. " shade on " .. id)
                if not expectPass(ns.hexColor(hex), palette) then
                    fail(class.id .. " on " .. id .. " is under 3:1")
                end
            end
        end
    end
end

-- A class-color addon that cannot clear 3:1 uses that class's precomputed
-- shade. Black cannot clear 3:1 on Ember, so the warrior shade is what ships.
local warriorFallback = ns.classShade({ 0, 0, 0 }, ns.byId.ember, "WARRIOR")
check(warriorFallback and warriorFallback.hex, ns.shadeOf.WARRIOR.ember, "runtime fallback uses the class shade")
check(ns.shadeOf.PRIEST.ember, "#FFFFFF", "priest on ember stays white")
if ns.priestSilver ~= nil then fail("priest silver was only for light palettes") end
check(ns.shadeOf.DEATHKNIGHT.ember, "#CD2A41", "death knight on ember is lightened")
check(ns.shadeOf.SHAMAN.nightglass, "#0873E0", "shaman on nightglass is lightened")

local required = {
    "Palettes: skipped ",
    "in this Daylight version.",
    "queued until combat ends.",
    "Your layout is unchanged.",
    "Daylight's own colors are restored.",
    "lifted. Daylight is using your Appearance colors again.",
}
for i = 1, #required do
    if not main:find(required[i], 1, true) then
        fail("missing chat line: " .. required[i])
    end
end

-- 0.1.0 saved two characters on different palettes. Log in A, then B.
-- A becomes the account palette. B keeps its own look, with the box on.
-- Logging in again, after the old keys are gone, must not change that.
local addonChunk, addonErr = loadfile(mainPath)
if not addonChunk then
    fail("could not load Palettes.lua: " .. tostring(addonErr))
else
    local env = {
        math = math, string = string, table = table, type = type,
        pairs = pairs, ipairs = ipairs, pcall = pcall, tostring = tostring,
        tonumber = tonumber, select = select, unpack = unpack, next = next, error = error,
        CreateFrame = function()
            return { RegisterEvent = function() end, SetScript = function() end }
        end,
    }
    setfenv(addonChunk, env)
    local loaded, loadErr = pcall(addonChunk, "Palettes", ns)
    if not loaded then
        fail("Palettes.lua failed: " .. tostring(loadErr))
    end
end

if type(ns.migrateLogin) ~= "function" or type(ns.setOnly) ~= "function" or type(ns.restoreActive) ~= "function" then
    fail("palette scope functions are missing")
else
    local function saved(palette, accent)
        return {
            palette = palette, own = palette, everyCharacter = false, classAccent = accent == true,
        }
    end

    local account = { every = false }
    local charA = {}
    local idA, accentA, onlyA = ns.migrateLogin(account, charA, saved("ember", false))
    local charB = {}
    local idB, accentB, onlyB = ns.migrateLogin(account, charB, saved("tide", true))
    check(idA, "ember", "first character keeps ember")
    check(accentA, false, "first character keeps its class accent")
    check(onlyA, false, "first character uses the account palette")
    check(account.palette, "ember", "first character becomes the account palette")
    check(account.classAccent, false, "first character's class accent becomes the account one")
    check(charA.only, false, "first character's box is off")
    check(charA.palette, nil, "first character does not keep a private palette")
    check(idB, "tide", "second character keeps tide")
    check(accentB, true, "second character keeps its class accent")
    check(onlyB, true, "second character gets the box ticked")
    check(charB.palette, "tide", "second character keeps its own palette")
    check(charB.classAccent, true, "class accent is saved with the character palette")
    check(account.palette, "ember", "second character does not replace the account palette")

    local againA, againAccentA, againOnlyA = ns.migrateLogin(account, charA, {
        palette = "off", classAccent = false, only = false,
    })
    local againB, againAccentB, againOnlyB = ns.migrateLogin(account, charB, {
        palette = "off", classAccent = false, only = false,
    })
    check(againA, "ember", "logging in again keeps the first character")
    check(againAccentA, false, "logging in again keeps the account accent")
    check(againOnlyA, false, "logging in again leaves the first box off")
    check(againB, "tide", "logging in again keeps the second character")
    check(againAccentB, true, "logging in again keeps the second accent")
    check(againOnlyB, true, "logging in again keeps the box ticked")
    check(account.palette, "ember", "logging in again keeps the account palette")

    local charC = {}
    local idC, _, onlyC = ns.migrateLogin(account, charC, {
        palette = "off", classAccent = false, only = false,
    })
    check(idC, "ember", "a new character uses the account palette")
    check(onlyC, false, "a new character does not get the box")
    check(charC.palette, nil, "a new character has no private palette")

    local backId, backAccent, backOnly = ns.setOnly(account, charB, false)
    check(backOnly, false, "untick clears the box")
    check(charB.palette, nil, "untick clears the character palette")
    check(charB.classAccent, nil, "untick clears the character accent")
    check(backId, "ember", "untick falls back to the account palette")
    check(backAccent, false, "untick falls back to the account accent")
    check(account.palette, "ember", "untick leaves the account palette")

    local scoped = { every = false }
    local scopeA, scopeB = {}, {}
    ns.migrateLogin(scoped, scopeA, saved("pine", false))
    ns.migrateLogin(scoped, scopeB, saved("phosphor", false))
    ns.restoreActive(scoped, scopeA)
    check(scoped.palette, "off", "restore switches off the account palette")
    check(scopeA.only, false, "restore does not tick the account character")
    check(scopeA.palette, nil, "restore does not write a private palette")
    check(scopeB.only, true, "account restore leaves the other box ticked")
    check(scopeB.palette, "phosphor", "account restore leaves the other character")

    local scopedOn = { every = false }
    local onA, onB = {}, {}
    ns.migrateLogin(scopedOn, onA, saved("pine", false))
    ns.migrateLogin(scopedOn, onB, saved("phosphor", true))
    ns.restoreActive(scopedOn, onB)
    check(onB.palette, "off", "restore switches off this character")
    check(onB.only, true, "restore leaves the box ticked")
    check(onB.classAccent, true, "restore leaves this character's class accent")
    check(scopedOn.palette, "pine", "character restore leaves the account palette")
    check(onA.only, false, "character restore leaves the account character")

    -- 0.1.0 "every character" showed one palette. A different private pick was hidden,
    -- so the upgrade keeps the shared look instead of revealing that old pick.
    local shared = { every = true, palette = "dusk" }
    local sharedA, sharedB, sharedC = {}, {}, {}
    local sharedIdA = ns.migrateLogin(shared, sharedA, {
        palette = "ember", own = "ember", everyCharacter = true, classAccent = false,
    })
    local sharedIdB, _, sharedOnlyB = ns.migrateLogin(shared, sharedB, {
        palette = "tide", own = "tide", everyCharacter = true, classAccent = false,
    })
    local sharedIdC, sharedAccentC, sharedOnlyC = ns.migrateLogin(shared, sharedC, {
        palette = "tide", own = "tide", everyCharacter = true, classAccent = true,
    })
    check(sharedIdA, "dusk", "the shared palette becomes the account palette")
    check(shared.palette, "dusk", "a hidden private pick does not replace the account")
    check(sharedA.only, false, "the first shared character leaves the box off")
    check(sharedIdB, "dusk", "another character keeps the shared palette")
    check(sharedOnlyB, false, "the same shared look does not tick the box")
    check(sharedB.palette, nil, "the same shared look has no private palette")
    check(sharedIdC, "dusk", "a different class accent keeps the shared palette")
    check(sharedAccentC, true, "a different class accent is kept")
    check(sharedOnlyC, true, "a different class accent ticks the box")
    check(sharedC.palette, "dusk", "the override stores the palette that was showing")
end

-- Undo is one step, for this session. A combat pick can be cancelled before it applies.
if type(ns.choosePalette) ~= "function" or type(ns.undoPalette) ~= "function"
    or type(ns.finishCombat) ~= "function" or type(ns.undoReady) ~= "function" then
    fail("undo functions are missing")
else
    local account = { palette = "ember", classAccent = false, seeded = true }
    local char = { only = false, ready = true }
    local state = { current = "ember" }
    check(ns.undoReady(state), false, "undo starts off")
    ns.choosePalette(state, account, char, "mage", false)
    check(state.current, "mage", "mage is selected")
    check(state.previous, "ember", "undo remembers ember")
    check(account.palette, "mage", "mage is saved on the account")
    check(char.palette, nil, "an account pick does not write a character palette")
    check(ns.undoReady(state), true, "undo is on after a pick")
    check(ns.undoPalette(state, account, char), "ember", "undo restores ember")
    check(state.current, "ember", "ember is selected again")
    check(account.palette, "ember", "undo saves ember on the account")
    check(char.palette, nil, "account undo does not write a character palette")
    check(ns.undoReady(state), false, "undo is off after one use")
    ns.undoPalette(state, account, char)
    check(state.current, "ember", "a second undo does nothing")
    check(account.palette, "ember", "a second undo does not change the account")

    local fight = { current = "ember" }
    local fightAccount = { palette = "ember", classAccent = false, seeded = true }
    local fightChar = { only = false, ready = true }
    ns.choosePalette(fight, fightAccount, fightChar, "mage", true)
    check(fight.current, "ember", "a combat pick stays on ember")
    check(fight.pending, "mage", "a combat pick is waiting")
    check(fightAccount.palette, "mage", "a combat pick is saved for after combat")
    check(fightChar.palette, nil, "a combat pick on the account does not write a character palette")
    check(ns.undoReady(fight), true, "undo can cancel a combat pick")
    ns.undoPalette(fight, fightAccount, fightChar)
    check(fight.pending, nil, "undo clears the combat pick")
    check(fight.current, "ember", "undo leaves ember selected")
    check(fightAccount.palette, "ember", "undo puts the saved palette back")
    check(fightChar.palette, nil, "cancelling a combat pick does not write a character palette")
    check(ns.undoReady(fight), false, "undo is off after cancelling a combat pick")
    ns.finishCombat(fight, fightAccount, fightChar)
    check(fight.current, "ember", "combat end applies nothing after undo")
    check(fight.pending, nil, "combat end has nothing waiting")
    check(fightAccount.palette, "ember", "combat end saves nothing after undo")
    check(fightChar.palette, nil, "combat end does not write a character palette")

    local landed = { current = "ember" }
    local landedAccount = { palette = "ember", classAccent = false, seeded = true }
    local landedChar = { only = false, ready = true }
    ns.choosePalette(landed, landedAccount, landedChar, "mage", true)
    ns.finishCombat(landed, landedAccount, landedChar)
    check(landed.current, "mage", "combat end applies the waiting pick")
    check(landedAccount.palette, "mage", "combat end saves the waiting pick")
    check(ns.undoReady(landed), true, "undo can step back after combat")

    local scoped = { palette = "tide", classAccent = false, seeded = true }
    local mine = { only = true, palette = "ember", classAccent = false, ready = true }
    local mineState = { current = "ember" }
    ns.choosePalette(mineState, scoped, mine, "mage", false)
    check(scoped.palette, "tide", "a character pick leaves the account palette")
    check(mine.palette, "mage", "a character pick writes PalettesChar")
    check(mine.only, true, "a character pick leaves the box ticked")
    ns.undoPalette(mineState, scoped, mine)
    check(scoped.palette, "tide", "character undo leaves the account palette")
    check(scoped.classAccent, false, "character undo leaves the account accent")
    check(mine.palette, "ember", "character undo restores PalettesChar")
    check(mine.only, true, "character undo leaves the box ticked")
    check(mine.classAccent, false, "character undo leaves the character accent")
    check(mineState.current, "ember", "character undo selects ember again")
    check(ns.undoReady(mineState), false, "character undo is one step")

    local fightMine = { current = "ember" }
    local fightScoped = { palette = "tide", classAccent = false, seeded = true }
    local fightCharOnly = { only = true, palette = "ember", classAccent = true, ready = true }
    ns.choosePalette(fightMine, fightScoped, fightCharOnly, "mage", true)
    check(fightScoped.palette, "tide", "a character combat pick leaves the account palette")
    check(fightCharOnly.palette, "mage", "a character combat pick writes PalettesChar")
    ns.undoPalette(fightMine, fightScoped, fightCharOnly)
    ns.finishCombat(fightMine, fightScoped, fightCharOnly)
    check(fightScoped.palette, "tide", "character combat undo leaves the account palette")
    check(fightScoped.classAccent, false, "character combat undo leaves the account accent")
    check(fightCharOnly.palette, "ember", "character combat undo restores PalettesChar")
    check(fightCharOnly.only, true, "character combat undo leaves the box ticked")
    check(fightCharOnly.classAccent, true, "character combat undo leaves the character accent")
    check(fightMine.current, "ember", "character combat undo applies nothing when combat ends")
end

if failures > 0 then
    io.stderr:write(failures .. " Palettes check(s) failed\n")
    os.exit(1)
end

io.write("Palettes check passed\n")
