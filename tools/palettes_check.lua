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
check(ns.order and #ns.order or 0, 35, "palette count")

local ids = {
    "ember", "tide", "dusk", "ash", "pine",
    "forgeglow", "nightglass", "vesper", "carmine-night", "gilded", "phosphor", "ink", "sightline",
    "vanilla", "forever",
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
    gilded = { group = "dark", window = "#070706", background = "#0B0B08", border = "#050403",
        band = "#18180F", bandLit = "#2C2C1C", c1 = "#B89020", c2 = "#D4AF37", c3 = "#F0D878",
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
    vanilla = { group = "dark", window = "#241208", background = "#32180A", border = "#100804",
        band = "#4A2814", bandLit = "#6E3E1C", c1 = "#C4C0B8", c2 = "#E8E4DC", c3 = "#F8F6F0",
        title = "#FFF8EE", text = "#F3E6D0", label = "#C8B080", off = "#9A8460" },
    forever = { group = "dark", window = "#080706", background = "#0C0908", border = "#050403",
        band = "#321C10", bandLit = "#523824", c1 = "#B07A50", c2 = "#DCA77F", c3 = "#F0D0B0",
        title = "#F7F6F2", text = "#EAE8E0", label = "#C8B49A", off = "#9A846C" },
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

for i = 1, 15 do
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
check(ns.groups and #ns.groups[1].ids, 15, "dark count")
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
        band = "#2A2823", bandLit = "#424038", c1 = "#A89060", c2 = "#D0B888", c3 = "#F0E4C8",
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
        band = "#28291C", bandLit = "#3E3F2A", c1 = "#B0B024", c2 = "#E0DC30", c3 = "#F2F08A",
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
    crownwall = { group = "realm", window = "#1A1810", background = "#2A281C", border = "#06070A",
        band = "#444230", bandLit = "#4A4732", c1 = "#2E6CB8", c2 = "#4A98EA", c3 = "#B8D6FA",
        title = "#F6F7F9", text = "#E3E7ED", label = "#B8B4A0", off = "#7E93AF" },
    deepforge = { group = "realm", window = "#111213", background = "#17181A", border = "#060607",
        band = "#28292C", bandLit = "#404247", c1 = "#C06820", c2 = "#E08A38", c3 = "#F0C090",
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
        band = "#212622", bandLit = "#363E38", c1 = "#98A880", c2 = "#D0D8B0", c3 = "#EEF0D8",
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

check(ns.byId.vanilla and ns.byId.vanilla.mood, "Dark oak and pewter chrome.", "vanilla mood")
check(ns.byId.forever and ns.byId.forever.mood, "Near-black soot, weathered bronze trim.", "forever mood")
check(ns.byId.crownwall and ns.byId.crownwall.mood, "Pale castle stone, banner blue.", "crownwall mood")
check(ns.byId.druid and ns.byId.druid.c2.hex, "#C26218", "druid accent stays")
check(ns.byId.ironbanner and ns.byId.ironbanner.c2.hex, "#C8583A", "ironbanner accent stays")
check(ns.byId.forgeglow and ns.byId.forgeglow.c2.hex, "#F26A1A", "forgeglow accent stays")

-- Body text stays at least 6.6:1 on the background. Title, text and label
-- stay at least 4.5:1 on the background and the band. Accent and dim text
-- stay at least 3:1 on both. These are the signed-off sheet numbers.
local function closeRatio(actual, expected, label)
    if type(actual) ~= "number" or math.abs(actual - expected) > 0.06 then
        fail(label .. "\n  expected: " .. tostring(expected) .. "\n  actual:   " .. tostring(actual))
    end
end
local sheetRatio = {
    vanilla = { textBg = 13.41, accentBg = 13.03, accentBand = 10.32 },
    forever = { textBg = 16.18, accentBg = 9.33, accentBand = 7.54 },
    crownwall = { textBg = 11.93, accentBg = 4.91, accentBand = 3.37, labelBg = 7.10, labelBand = 4.87 },
    rogue = { accentBg = 12.53, accentBand = 10.15 },
    gilded = { textBg = 15.82, accentBg = 9.37, accentBand = 8.49 },
    warrior = { accentBg = 9.38, accentBand = 7.64 },
    deepforge = { accentBg = 6.65, accentBand = 5.45 },
    gravelight = { accentBg = 12.26, accentBand = 10.35 },
}
for id, want in pairs(sheetRatio) do
    local p = ns.byId[id]
    if want.textBg then closeRatio(ns.ratio(p.text, p.background), want.textBg, id .. " text on background") end
    if want.labelBg then closeRatio(ns.ratio(p.label, p.background), want.labelBg, id .. " label on background") end
    if want.labelBand then closeRatio(ns.ratio(p.label, p.band), want.labelBand, id .. " label on band") end
    closeRatio(ns.ratio(p.c2, p.background), want.accentBg, id .. " accent on background")
    closeRatio(ns.ratio(p.c2, p.band), want.accentBand, id .. " accent on band")
    if ns.ratio(p.text, p.background) < 6.6 then fail(id .. " body text is under 6.6:1") end
    for _, ink in ipairs({ p.title, p.text, p.label }) do
        if ns.ratio(ink, p.background) < 4.5 or ns.ratio(ink, p.band) < 4.5 then
            fail(id .. " ink is under 4.5:1")
        end
    end
    for _, ink in ipairs({ p.c2, p.off }) do
        if ns.ratio(ink, p.background) < 3 or ns.ratio(ink, p.band) < 3 then
            fail(id .. " accent or dim text is under 3:1")
        end
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
if not main:find("Reload to finish applying your changes?", 1, true) then
    fail("missing reload note")
end
if not main:find("Previewing your pick.", 1, true) then
    fail("missing the preview note")
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
local shareAt = main:find('label = "Share code"', 1, true)
if not (choicesAt and accentAt and saveAt and shareAt
    and choicesAt < accentAt and accentAt < saveAt and saveAt < shareAt) then
    fail("settings are out of order")
end
if not main:find('Reset Colours', 1, true) then
    fail("missing the colours reset label")
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
local customPath = root .. "/Palettes/PalettesCustom.lua"
local customChunk, customErr = loadfile(customPath)
if not customChunk then
    fail("could not load PalettesCustom.lua: " .. tostring(customErr))
else
    setfenv(customChunk, {
        math = math, string = string, tonumber = tonumber, type = type,
        pairs = pairs, ipairs = ipairs,
    })
    local customOk, customRunErr = pcall(customChunk, "Palettes", ns)
    if not customOk then
        fail("PalettesCustom.lua failed: " .. tostring(customRunErr))
    end
end
check(ns.order and #ns.order or 0, 35, "custom does not add a thirty-sixth palette")
check(ns.byId.custom and ns.byId.custom.name, "Custom", "custom palette name")
check(ns.byId.custom and ns.byId.custom.mood, "Your own background, band and accent, saved at this character.", "custom palette description")

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

    local function look(palette, accent, custom)
        return {
            palette = palette, classAccent = accent == true, seeded = true,
            custom = custom,
        }
    end
    local mine = look("tide", false, { baseHex = "#0E1916", accentHex = "#3DB8A8" })
    local me = { only = false, ready = true }
    local empty = { palette = "off", classAccent = false, only = true }
    local kept, _, keptOnly, unknownEmpty, _, hadEmpty = ns.adoptProfile(mine, me, empty)
    check(kept, "tide", "a profile with no Palettes part keeps yours")
    check(hadEmpty, false, "defaults are not a shared Palettes part")
    check(unknownEmpty, false, "keeping yours is not an unknown palette")
    check(mine.palette, "tide", "keeping yours does not snap the account to off")
    check(mine.custom.baseHex, "#0E1916", "keeping yours keeps your custom colors")
    check(me.only, false, "a profile does not turn Save for this character only on")
    check(empty.only, false, "the switch in the profile is put back to yours")
    check(empty.palette, "tide", "your look is stamped into a profile that had none")
    check(empty.carried, true, "a stamped profile is marked as carrying Palettes")
    check(empty.custom and empty.custom.baseHex, "#0E1916", "your custom colors are stamped for the next share")

    local friend = look("tide", false, { baseHex = "#0E1916", accentHex = "#3DB8A8" })
    local friendChar = { only = false, ready = true }
    local emberProfile = { palette = "ember", classAccent = false, carried = true, only = true }
    local adopted, adoptedAccent, adoptedOnly, unknownEmber = ns.adoptProfile(friend, friendChar, emberProfile)
    check(adopted, "ember", "an imported Ember profile is adopted")
    check(adoptedAccent, false, "Accent follows class is adopted from the profile")
    check(adoptedOnly, false, "the importer's switch stays off")
    check(unknownEmber, false, "Ember is a known palette")
    check(friend.palette, "ember", "Ember is written into the account slot")
    check(friendChar.only, false, "import does not tick the switch")
    check(emberProfile.only, false, "the imported switch is not kept")
    check(friend.custom.baseHex, "#0E1916", "a profile with no custom leaves yours")

    local customFriend = look("tide", false, { baseHex = "#0E1916", accentHex = "#3DB8A8" })
    local customChar = { only = true, ready = true, palette = "tide", classAccent = false,
        custom = { baseHex = "#111111", accentHex = "#222222" } }
    local customProfile = {
        palette = "custom", classAccent = false, carried = true, only = false,
        custom = { baseHex = "#341529", accentHex = "#E2B14A" },
    }
    local customId = ns.adoptProfile(customFriend, customChar, customProfile)
    check(customId, "custom", "an imported Custom profile is adopted")
    check(customChar.palette, "custom", "Custom goes into this character's slot")
    check(customChar.custom.baseHex, "#341529", "this character gets the shared custom colors")
    check(customFriend.palette, "tide", "other characters keep the account palette")
    check(customFriend.custom.baseHex, "#0E1916", "other characters keep the account custom colors")
    check(customChar.only, true, "this character's switch stays on")

    local partOff = look("tide", false, { baseHex = "#0E1916", accentHex = "#3DB8A8" })
    local partChar = { only = false, ready = true }
    local stillMine = { palette = "tide", classAccent = false, carried = true, custom = { baseHex = "#0E1916", accentHex = "#3DB8A8" } }
    local stillId, _, _, _, _, stillHad, stillChanged = ns.adoptProfile(partOff, partChar, stillMine)
    check(stillId, "tide", "turning the Palettes part off keeps yours")
    check(stillHad, true, "your own stamped profile still carries Palettes")
    check(stillChanged, false, "keeping the same palette is not a change")
    check(partOff.custom.baseHex, "#0E1916", "turning the part off keeps your custom colors")

    local specAccount = look("ember", false, { baseHex = "#341529", accentHex = "#E2B14A" })
    local specChar = { only = false, ready = true }
    local tideProfile = {
        palette = "tide", classAccent = false, carried = true,
        custom = { baseHex = "#0E1916", accentHex = "#3DB8A8" },
    }
    local emberAgain = {
        palette = "ember", classAccent = false, carried = true,
        custom = { baseHex = "#341529", accentHex = "#E2B14A" },
    }
    check(select(1, ns.adoptProfile(specAccount, specChar, tideProfile)), "tide", "a talent switch adopts that profile")
    check(specAccount.custom.baseHex, "#0E1916", "a talent switch adopts that profile's custom colors")
    check(select(1, ns.adoptProfile(specAccount, specChar, emberAgain)), "ember", "switching back adopts the other profile")
    check(specAccount.custom.baseHex, "#341529", "switching back restores that profile's custom colors")

    local offAccount = look("tide", false, { baseHex = "#0E1916", accentHex = "#3DB8A8" })
    local offChar = { only = false, ready = true }
    local offProfile = { carried = true, classAccent = false }
    local offId, _, _, offUnknown, _, offHad, offChanged = ns.adoptProfile(offAccount, offChar, offProfile)
    check(offHad, true, "a carried profile is a Palettes part even when the palette is off")
    check(offId, "off", "a shared off is adopted")
    check(offChanged, true, "moving from Tide to off is a change")
    check(offUnknown, false, "off is not an unknown palette")
    check(offAccount.palette, "off", "off is written into the account slot")
    check(offAccount.custom.baseHex, "#0E1916", "off with no custom leaves your custom colors")

    local old = look("tide", false, nil)
    local oldChar = { only = false, ready = true }
    local retired = { palette = "not-a-palette", classAccent = true, carried = true }
    local retiredId, retiredAccent, _, retiredUnknown = ns.adoptProfile(old, oldChar, retired)
    check(retiredUnknown, true, "an unknown profile palette is reported")
    check(retiredId, "ember", "an unknown profile palette falls back to Ember")
    check(retiredAccent, true, "Accent follows class still comes from that profile")
    check(retired.palette, "ember", "the profile stores Ember after the fallback")
    check(old.palette, "ember", "the account stores Ember after the fallback")

    local lightAccount = look("custom", false, nil)
    local lightChar = { only = false, ready = true }
    local lightDb = { palette = "custom", carried = true, custom = { baseHex = "#F5E6D0", accentHex = "#E8A04A" } }
    local _, _, _, _, lightWas = ns.adoptProfile(lightAccount, lightChar, lightDb)
    check(lightWas, true, "adopting a light base reports the darkening")
    check(lightAccount.custom.baseHex, "#4B412F", "adopting a light base stores the cap")
    check(ns.deriveCustom(lightAccount.custom).c2.hex, "#E8A04A", "adopting a light base keeps the accent")

    local stored = look("ember", false, { baseHex = "#211812", accentHex = "#E8A04A" })
    local storedChar = { only = false, ready = true }
    local withCustom = { palette = "tide", classAccent = false, carried = true, custom = { h = 180 } }
    ns.adoptProfile(stored, storedChar, withCustom)
    check(stored.palette, "tide", "custom colors are stored even when the pick is not Custom")
    check(type(stored.custom) == "table" and type(stored.custom.h) == "number", true, "a partial profile custom is stored")
    check(stored.custom.baseHex == "#211812", false, "the partial profile custom replaces the old one")
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

    local again = { current = "ember" }
    local againAccount = { palette = "ember", classAccent = false, seeded = true }
    local againChar = { only = false, ready = true }
    ns.choosePalette(again, againAccount, againChar, "mage", true)
    ns.choosePalette(again, againAccount, againChar, "ember", true)
    check(again.pending, nil, "picking the current palette clears the wait")
    check(again.current, "ember", "picking the current palette stays on ember")
    check(againAccount.palette, "ember", "picking the current palette writes ember back")
    ns.finishCombat(again, againAccount, againChar)
    check(again.current, "ember", "combat end stays on ember")
    check(againAccount.palette, "ember", "combat end saves ember")

    local scopeWait = { current = "ember" }
    local scopeAccount = { palette = "ember", classAccent = false, seeded = true }
    local scopeChar = { only = false, ready = true }
    ns.choosePalette(scopeWait, scopeAccount, scopeChar, "mage", true)
    ns.clearPending(scopeWait, scopeAccount, scopeChar)
    local scopeId = ns.setOnly(scopeAccount, scopeChar, true)
    check(scopeWait.pending, nil, "a scope change clears the waiting pick")
    check(scopeAccount.palette, "ember", "a scope change puts the on-screen palette back")
    check(scopeId, "ember", "ticking the box copies the on-screen palette")
    check(scopeChar.palette, "ember", "the character does not copy the waiting palette")
    check(scopeChar.only, true, "the box is ticked")
end
if not main:find('"PENDING"', 1, true) then
    fail("a waiting row must be tagged PENDING")
end

-- Custom palette. Lightness of the base stops at CIE L* 28. Accent does not.
-- Slider edits stay in the preview until Save. Back throws them away.
if type(ns.customSpec) ~= "function" or type(ns.deriveCustom) ~= "function"
    or type(ns.saveCustom) ~= "function" or type(ns.backCustom) ~= "function"
    or type(ns.resetCustomToEmber) ~= "function" or type(ns.writeCustom) ~= "function" then
    fail("custom palette functions are missing")
else
    local function close(actual, expected, tol, label)
        if type(actual) ~= "number" or math.abs(actual - expected) > tol then
            fail(label .. "\n  expected: " .. tostring(expected) .. "\n  actual:   " .. tostring(actual))
        end
    end

    local hues = { 0, 60, 120, 180, 242, 300 }
    for i = 1, #hues do
        for _, sat in ipairs({ 0, 1 }) do
            local spec = ns.customSpec({ h = hues[i], s = sat, l = 40, ah = 30, as = 0.5, al = 70 })
            check(spec.l, 28, "base lightness stops at 28 for hue " .. hues[i])
            local measured = ns.customBaseL(spec)
            if type(measured) ~= "number" or measured > 28.05 then
                fail("base L* is over 28 at hue " .. hues[i] .. " sat " .. sat .. ": " .. tostring(measured))
            end
            local textOnBase = ns.customTextRatio(spec)
            if type(textOnBase) ~= "number" or textOnBase < 6.6 then
                fail("body text is under 6.6:1 on the base at hue " .. hues[i] .. " sat " .. sat)
            end
        end
    end
    local openAccent = ns.customSpec({ h = 0, s = 0, l = 10, ah = 40, as = 0.8, al = 95 })
    check(openAccent.al, 95, "accent lightness is not capped")

    local starter = ns.deriveCustom(ns.customDefaults())
    check(starter.background.hex, "#341529", "starter base")
    check(starter.band.hex, "#3D1D32", "starter band")
    check(starter.text.hex, "#EDE3E9", "starter text")
    check(starter.c2.hex, "#E2B14A", "starter accent")
    check(starter.c1.hex, "#A0751A", "starter accent gradient start")
    check(starter.c3.hex, "#E7D7B5", "starter accent gradient end")
    close(ns.customTextRatio(ns.customDefaults()), 13.04, 0.06, "starter text on the base")
    close(ns.customAccentRatio(ns.customDefaults()), 8.26, 0.06, "gold accent on the starter base")
    check(ns.accentHardToSee(ns.customDefaults()), false, "gold accent does not warn")

    check(ns.shareCode(ns.customDefaults()), "PAL1-341529-E2B14A", "starter share code")
    local function applied(code)
        local spec, status = ns.applyShareCode(code)
        if type(spec) ~= "table" then return nil, status end
        local palette = ns.deriveCustom(spec)
        return palette, status, spec
    end
    local round, roundStatus = applied("PAL1-341529-E2B14A")
    check(roundStatus, "applied", "starter code applies")
    check(round and round.background.hex, "#341529", "starter code keeps the base")
    check(round and round.c2.hex, "#E2B14A", "starter code keeps the accent")
    check(ns.shareCode(ns.applyShareCode("pal1-#341529-#e2b14a")), "PAL1-341529-E2B14A", "share codes ignore case and hashes")
    local jungle, jungleStatus = applied("PAL1-0E1916-E85A32")
    check(jungleStatus, "applied", "a dark code applies")
    check(jungle and jungle.background.hex, "#0E1916", "a dark code sets the base")
    check(jungle and jungle.c2.hex, "#E85A32", "a dark code sets the accent")
    local light, lightStatus, lightSpec = applied("PAL1-F5E6D0-E8A04A")
    check(lightStatus, "capped", "a light base is capped")
    check(light and light.background.hex, "#4B412F", "a light base darkens to the cap")
    check(light and light.c2.hex, "#E8A04A", "a light base keeps its accent")
    if type(lightSpec) == "table" and lightSpec.l ~= 28 then
        fail("a capped base slider sits at 28")
    end
    if type(light) == "table" and ns.customBaseL(lightSpec) > 28.1 then
        fail("a capped base is lighter than L* 28")
    end
    local untouched = ns.customDefaults()
    local badSpec, badStatus = ns.applyShareCode("hello")
    check(badSpec, nil, "hello is not a share code")
    check(badStatus, "bad", "a bad code says so")
    check(ns.shareCode(untouched), "PAL1-341529-E2B14A", "a bad code does not change the draft")
    check(select(1, ns.applyShareCode("")), nil, "an empty code is rejected")
    check(select(1, ns.applyShareCode("   ")), nil, "a blank code is rejected")
    check(select(1, ns.applyShareCode("PAL1-341529")), nil, "a short code is rejected")

    local carried, wasCapped = ns.profileCustom({ baseHex = "#341529", accentHex = "#E2B14A" })
    check(wasCapped, false, "a dark profile base is not darkened")
    check(ns.deriveCustom(carried).background.hex, "#341529", "a profile keeps a dark base")
    check(ns.deriveCustom(carried).c2.hex, "#E2B14A", "a profile keeps its accent")
    local lightProfile, lightCapped = ns.profileCustom({ baseHex = "#F5E6D0", accentHex = "#E8A04A" })
    check(lightCapped, true, "a light profile base is darkened")
    check(ns.deriveCustom(lightProfile).background.hex, "#4B412F", "a light profile base caps at the share-code color")
    check(ns.deriveCustom(lightProfile).c2.hex, "#E8A04A", "a light profile base keeps its accent")
    if ns.customBaseL(lightProfile) > 28.1 then fail("a profile base stayed lighter than L* 28") end
    local partial = ns.profileCustom({ h = 200 })
    check(type(partial) == "table" and type(partial.ah) == "number", true, "a partial custom fills the missing accent")
    check(ns.deriveCustom(partial).background and true or false, true, "a partial custom still derives")
    local broken = ns.profileCustom({ baseHex = "nope", l = "high", accentHex = "#E8A04A" })
    check(type(broken) == "table", true, "a damaged custom still returns colors")
    local textOn, _ = ns.customTextRatio(broken)
    if textOn < 6.6 then fail("a damaged custom leaves text unreadable") end
    check(ns.profileCustom("nope"), nil, "a custom that is not a table is ignored")

    local grey = ns.deriveCustom({ h = 0, s = 0, l = 28, ah = 0, as = 0, al = 50 })
    check(grey.background.hex, "#424242", "grey at the lightness cap")
    check(grey.band.hex, "#4B4B4B", "grey band at the lightness cap")

    local low = ns.customSpec({
        h = 321, s = 0.42, l = 12, ah = 330, as = 0.3, al = 40,
        baseHex = "#341529", accentHex = "#794B69",
    })
    close(ns.customAccentRatio(low), 2.35, 0.06, "low accent contrast")
    check(ns.accentHardToSee(low), true, "an accent under 3:1 warns")

    local previewAccount = { palette = "ember" }
    local previewChar = { only = false }
    local saved = ns.readCustom(previewAccount, previewChar)
    local draft = ns.customSpec({ h = 90, s = 1, l = 28, ah = 10, as = 1, al = 80 })
    if ns.deriveCustom(draft).background.hex == ns.deriveCustom(saved).background.hex then
        fail("moving a slider should change the preview")
    end
    local kept = ns.backCustom(saved)
    check(ns.deriveCustom(kept).background.hex, ns.deriveCustom(saved).background.hex, "back keeps the saved colors")
    check(previewAccount.custom, nil, "back does not write the account")
    check(previewChar.custom, nil, "back does not write the character")

    local resetAccount = { palette = "custom", custom = { h = 222, s = 0.58, l = 28, ah = 41, as = 0.72, al = 75 } }
    local resetChar = { only = false }
    local savedHex = ns.deriveCustom(ns.readCustom(resetAccount, resetChar)).background.hex
    local resetSpec = ns.resetCustomToEmber(resetAccount, resetChar)
    check(resetAccount.palette, "custom", "reset leaves Custom selected")
    check(ns.deriveCustom(resetSpec).background.hex, "#211812", "reset loads Ember's base into the draft")
    check(ns.deriveCustom(resetSpec).c2.hex, "#E8A04A", "reset loads Ember's accent into the draft")
    check(ns.deriveCustom(ns.readCustom(resetAccount, resetChar)).background.hex, savedHex, "reset does not write the saved custom")
    local afterBack = ns.backCustom(ns.readCustom(resetAccount, resetChar))
    check(ns.deriveCustom(afterBack).background.hex, savedHex, "back after reset keeps the saved custom")
    check(resetAccount.custom.h, 222, "back after reset leaves the saved hue")

    local resetSave = { current = "tide" }
    local resetSaveAccount = { palette = "tide", custom = { h = 222, s = 0.58, l = 28, ah = 41, as = 0.72, al = 75 } }
    local resetSaveChar = { only = false }
    ns.saveCustom(resetSave, resetSaveAccount, resetSaveChar, ns.resetCustomToEmber(resetSaveAccount, resetSaveChar), false)
    check(resetSave.current, "custom", "saving a reset selects custom")
    check(resetSave.previous, "tide", "saving a reset remembers the previous palette")
    check(ns.deriveCustom(ns.readCustom(resetSaveAccount, resetSaveChar)).background.hex, "#211812", "save writes the reset colors")
    check(ns.undoPalette(resetSave, resetSaveAccount, resetSaveChar), "tide", "undo after a saved reset returns the previous palette")
    check(resetSaveAccount.palette, "tide", "undo after a saved reset restores the palette id")

    local scoped = { palette = "ember", custom = ns.customDefaults() }
    local mine = { only = true }
    local navy = { h = 222, s = 0.58, l = 28, ah = 41, as = 0.72, al = 75 }
    ns.writeCustom(scoped, mine, navy)
    check(scoped.custom.h, 321, "a character custom does not replace the account colors")
    check(mine.custom.h, 222, "a character custom is stored on the character")
    check(mine.custom.l, 28, "a character custom keeps the capped lightness")
    mine.only = false
    ns.writeCustom(scoped, mine, navy)
    check(math.floor(scoped.custom.h + 0.5), 222, "an account custom is stored on the account")
    check(mine.custom, nil, "an account custom clears the character copy")

    local copied = { palette = "ember", custom = { h = 10, s = 1, l = 20, ah = 0, as = 0, al = 40 } }
    local copiedChar = { only = false }
    ns.setOnly(copied, copiedChar, true)
    check(copiedChar.custom and math.floor(copiedChar.custom.h + 0.5), 10, "ticking the box copies custom colors")
    check(copied.custom.h, 10, "ticking the box leaves the account custom")
    ns.writeCustom(copied, copiedChar, navy)
    check(copied.custom.h, 10, "a private edit leaves the account custom")
    ns.setOnly(copied, copiedChar, false)
    check(copiedChar.custom, nil, "unticking the box drops the private custom")
    check(math.floor(ns.readCustom(copied, copiedChar).h + 0.5), 10, "unticking the box follows the account custom")

    local undoState = { current = "ember" }
    local undoAccount = { palette = "ember" }
    local undoChar = { only = false }
    ns.saveCustom(undoState, undoAccount, undoChar, navy, false)
    check(undoState.current, "custom", "saving custom selects custom")
    check(undoState.previous, "ember", "saving custom remembers the previous palette")
    check(undoAccount.palette, "custom", "saving custom writes the palette id")
    check(math.floor(undoAccount.custom.h + 0.5), 222, "saving custom writes the colors")
    check(ns.undoReady(undoState), true, "undo is on after a custom save")
    check(ns.undoPalette(undoState, undoAccount, undoChar), "ember", "undo steps back from a custom save")
    check(undoAccount.palette, "ember", "undo restores the palette from before custom")
    check(undoState.current, "ember", "undo selects the previous palette")
    check(ns.undoReady(undoState), false, "undo is off after stepping back from custom")

    local customFight = { current = "ember" }
    local customFightAccount = { palette = "ember" }
    local customFightChar = { only = false }
    ns.saveCustom(customFight, customFightAccount, customFightChar, navy, true)
    check(customFight.current, "ember", "a custom save in combat stays on the current palette")
    check(customFight.pending, "custom", "a custom save in combat waits")
    check(customFightAccount.palette, "custom", "a custom save in combat is saved for after combat")
    ns.undoPalette(customFight, customFightAccount, customFightChar)
    check(customFight.pending, nil, "undo cancels a waiting custom save")
    check(customFightAccount.palette, "ember", "undo writes the on-screen palette back over custom")
    ns.finishCombat(customFight, customFightAccount, customFightChar)
    check(customFight.current, "ember", "combat end does not apply a cancelled custom save")
end
if not main:find("Your own background, band and accent, saved at this character.", 1, true) then
    fail("the custom row needs its description")
end
if not main:find("Base colors stay dark so text stays readable.", 1, true) then
    fail("the base cap note is missing")
end
if not main:find("Accent is hard to see on this base.", 1, true) then
    fail("the accent warning is missing")
end
if not main:find("Reset to Ember", 1, true) then
    fail("reset to ember is missing")
end
if not main:find("L*%d / 28", 1, true) then
    fail("the lightness readout is missing")
end
if not main:find("Reset Custom to Ember?", 1, true) then
    fail("reset needs a confirm")
end
if not main:find("SliderLook", 1, true) or not main:find("Widgets", 1, true) then
    fail("the editor should use Daylight's slider and button widgets")
end
if main:find("OptionsSliderTemplate", 1, true) or main:find("UIPanelButtonTemplate", 1, true) then
    fail("the editor should not use game slider or button templates")
end
if main:find("onlySwitch:SetOn", 1, true) then
    fail("the editor switch must be called as a function, not a method")
end
if not main:find('override("microIconColor", "accent", "ActionBars")', 1, true) then
    fail("micro icons should follow through ActionBars.microIconColor")
end
if main:find("PaintMicro", 1, true) then
    fail("micro icons must not be recolored by painting them")
end
if not main:find("Palettes: That profile's palette isn't in this version, so Ember is on instead. Your layout is unchanged.", 1, true) then
    fail("missing the unknown-palette line")
end
if not main:find("Palettes: Custom base was darkened so text stays readable.", 1, true) then
    fail("missing the darkened-base line")
end
if main:find("that profile used a palette this version doesn't have", 1, true) then
    fail("the old unknown-palette line remains")
end
if not main:find("carried = false", 1, true) then
    fail("a profile needs a marker for Palettes settings")
end
if not main:find("ns.adoptProfile", 1, true) then
    fail("login must adopt the profile")
end

-- The in-editor switch uses Daylight's plain SetOn(on). A colon call would
-- pass the frame as the flag, so the switch would always look on.
do
    local function piece()
        local w = {}
        w.scripts = {}
        function w:SetPoint() end
        function w:SetSize() end
        function w:SetWidth() end
        function w:SetHeight() end
        function w:SetAllPoints() end
        function w:ClearAllPoints() end
        function w:Hide() end
        function w:Show() end
        function w:SetShown() end
        function w:SetText(text) w.words = text end
        function w:GetText() return w.words or "" end
        function w:HighlightText() w.selected = true end
        function w:SetFocus() end
        function w:HasFocus() return false end
        function w:SetAutoFocus() end
        function w:SetTextColor() end
        function w:SetFont() end
        function w:SetJustifyH() end
        function w:SetWordWrap() end
        function w:SetColorTexture() end
        function w:SetTexture() end
        function w:SetVertexColor() end
        function w:SetAlpha() end
        function w:SetFrameLevel() end
        function w:GetFrameLevel() return 1 end
        function w:EnableMouse() end
        function w:SetOrientation() end
        function w:SetMinMaxValues() end
        function w:SetValueStep() end
        function w:SetObeyStepOnDrag() end
        function w:SetValue() end
        function w:GetValue() return 0 end
        function w:GetWidth() return 480 end
        function w:GetHeight() return 28 end
        function w:GetStringWidth() return 40 end
        function w:SetScript(name, fn) w.scripts[name] = fn end
        function w:CreateTexture() return piece() end
        function w:CreateFontString() return piece() end
        return w
    end
    local rowButtons = {}
    local named = {}
    local switches = {}
    local settings = { palette = "ember", only = false, classAccent = false }
    local module
    local ui = {
        API = { major = 1, minor = 7 },
        OptionsPanel = { Refresh = function() end },
        Style = {},
    }
    function ui:RegisterPlugin() return {} end
    function ui:RegisterModule(_, spec) module = spec end
    function ui:Get(_, key) return settings[key] end
    function ui:Set(_, key, value) settings[key] = value end
    ui.Widgets = {
        Button = function(_, text)
            local b = piece()
            function b.FitWidth() end
            named[text] = b
            return b
        end,
        SliderLook = function()
            return { track = piece(), fill = piece() }
        end,
        Switch = function()
            local b = piece()
            -- Same shape as Daylight: SetOn is a plain function, and the flag is its only argument.
            function b.SetOn(on) b.on = on end
            switches[#switches + 1] = b
            return b
        end,
        Close = function() return piece() end,
        Input = function()
            return piece()
        end,
    }
    local editorChunk, editorErr = loadfile(mainPath)
    if not editorChunk then
        fail("could not reload Palettes.lua: " .. tostring(editorErr))
    else
        setfenv(editorChunk, {
            math = math, string = string, table = table, type = type,
            pairs = pairs, ipairs = ipairs, pcall = pcall, tostring = tostring,
            tonumber = tonumber, select = select, unpack = unpack, next = next, error = error,
            _G = {},
            DaylightUI = ui,
            CreateFrame = function(kind)
                local w = piece()
                if kind == "Button" then rowButtons[#rowButtons + 1] = w end
                return w
            end,
        })
        local loaded, loadErr = pcall(editorChunk, "Palettes", ns)
        local function labeled(text)
            local pages = module and module.options and module.options.pages
            if type(pages) ~= "table" then return nil end
            for p = 1, #pages do
                local groups = pages[p].groups
                if type(groups) == "table" then
                    for g = 1, #groups do
                        local items = groups[g].items
                        if type(items) == "table" then
                            for i = 1, #items do
                                if items[i].label == text then return items[i] end
                            end
                        end
                    end
                end
            end
        end
        local build = labeled("Choices")
        build = build and build.build
        local row = piece()
        if not loaded or type(build) ~= "function" then
            fail("the editor harness did not register: " .. tostring(loadErr))
        else
            build(row)
            local accentRow = labeled("Accent follows class")
            local restoreRow = { hidden = ns.coloursResetHidden }
            local custom = rowButtons[1]
            local switch = switches[1]
            if type(row.palettesEditor) ~= "table" or type(custom) ~= "table"
                or type(custom.scripts.OnClick) ~= "function" or type(switch) ~= "table"
                or type(accentRow) ~= "table" or type(accentRow.hidden) ~= "function"
                or type(restoreRow) ~= "table" or type(restoreRow.hidden) ~= "function" then
                fail("the custom editor did not build")
            else
                check(accentRow.hidden(), false, "accent follows class shows while the list is open")
                check(restoreRow.hidden(), false, "restore shows while the list is open")
                local opened, openErr = pcall(custom.scripts.OnClick)
                if not opened then fail("opening the editor: " .. tostring(openErr)) end
                check(switch.on, false, "the editor switch shows off when Palettes.only is off")
                settings.only = true
                local painted, paintErr = pcall(row.palettesRefresh)
                if not painted then fail("painting the editor: " .. tostring(paintErr)) end
                check(switch.on, true, "the editor switch shows on when Palettes.only is on")
                settings.only = false
                local clicked, clickErr = pcall(switch.scripts.OnClick)
                if not clicked then fail("clicking the editor switch: " .. tostring(clickErr)) end
                check(settings.only, true, "clicking the editor switch turns Palettes.only on")
                check(switch.on, true, "clicking the editor switch shows on")
                pcall(switch.scripts.OnClick)
                check(switch.on, false, "clicking the editor switch shows off")
                check(accentRow.hidden(), true, "accent follows class hides while the editor is open")
                check(restoreRow.hidden(), true, "restore hides while the editor is open")
                local back = named["Back"]
                if type(back) ~= "table" or type(back.scripts.OnClick) ~= "function" then
                    fail("the editor has no Back button")
                else
                    local left, leftErr = pcall(back.scripts.OnClick)
                    if not left then fail("Back: " .. tostring(leftErr)) end
                    check(accentRow.hidden(), false, "accent follows class shows again after Back")
                    check(restoreRow.hidden(), false, "restore shows again after Back")
                end
                local again, againErr = pcall(custom.scripts.OnClick)
                if not again then fail("reopening the editor: " .. tostring(againErr)) end
                local field = row.palettesEditor.palettesShareField
                local note = row.palettesEditor.palettesShareNote
                local copy = named["Copy"]
                local applyCode = named["Apply"]
                if type(field) ~= "table" or type(note) ~= "table"
                    or type(copy) ~= "table" or type(copy.scripts.OnClick) ~= "function"
                    or type(applyCode) ~= "table" or type(applyCode.scripts.OnClick) ~= "function" then
                    fail("the editor has no share code row")
                else
                    check(field:GetText(), "PAL1-341529-E2B14A", "the share field tracks the starter draft")
                    local copied, copyErr = pcall(copy.scripts.OnClick)
                    if not copied then fail("Copy: " .. tostring(copyErr)) end
                    check(copy.words, "Copied.", "Copy reads Copied.")
                    check(field.selected, true, "Copy selects the code")
                    field:SetText("hello")
                    field.selected = nil
                    local rejected, rejectErr = pcall(applyCode.scripts.OnClick)
                    if not rejected then fail("Apply hello: " .. tostring(rejectErr)) end
                    check(note.words, "That isn't a Palettes share code.", "a bad code is named")
                    local still, stillErr = pcall(copy.scripts.OnClick)
                    if not still then fail("Copy after a bad code: " .. tostring(stillErr)) end
                    check(field:GetText(), "PAL1-341529-E2B14A", "a bad code leaves the draft")
                    field:SetText("PAL1-0E1916-E85A32")
                    local pasted, pasteErr = pcall(applyCode.scripts.OnClick)
                    if not pasted then fail("Apply a code: " .. tostring(pasteErr)) end
                    check(note.words, "Applied. Save to keep it.", "a good code says to save")
                    local keptCode, keptErr = pcall(copy.scripts.OnClick)
                    if not keptCode then fail("Copy after Apply: " .. tostring(keptErr)) end
                    check(field:GetText(), "PAL1-0E1916-E85A32", "Apply loads that base and accent")
                    field:SetText("PAL1-F5E6D0-E8A04A")
                    local capped, capErr = pcall(applyCode.scripts.OnClick)
                    if not capped then fail("Apply a light code: " .. tostring(capErr)) end
                    check(note.words, "Base was darkened so text stays readable.", "a light base says it was darkened")
                    pcall(copy.scripts.OnClick)
                    check(field:GetText(), "PAL1-4B412F-E8A04A", "a light base is the capped color")
                end
                local save = named["Save"]
                if type(save) ~= "table" or type(save.scripts.OnClick) ~= "function" then
                    fail("the editor has no Save button")
                else
                    local saved, saveErr = pcall(save.scripts.OnClick)
                    if not saved then fail("Save: " .. tostring(saveErr)) end
                    check(accentRow.hidden(), false, "accent follows class shows again after Save")
                    check(restoreRow.hidden(), false, "restore shows again after Save")
                end
            end
        end
    end
end

if not toc:find("## Version: 0.4.0", 1, true) then
    fail("version stays 0.4.0")
end
if not toc:find("frame styles", 1, true) or not toc:find("glow styles", 1, true) then
    fail("toc notes must cover frame styles and glow styles")
end
if not toc:find("PalettesLooks.lua", 1, true) then
    fail("toc must load PalettesLooks.lua")
end
local looksSource = readAll(root .. "/Palettes/PalettesLooks.lua")
if looksSource:find("LooksDB", 1, true) and looksSource:find("LooksDB%s*=", 1, false) then
    fail("looks must not write LooksDB")
end
if not looksSource:find("Each preset is a ready-made pairing of a Colours palette with a Looks frame and glow. Pick one, then change any part on the Colours or Looks tab.", 1, true) then
    fail("missing the presets intro")
end
if not looksSource:find("A preset on the Presets tab sets all three.", 1, true) then
    fail("missing the looks intro")
end
if not looksSource:find("A full boss, a thin health lip, power in a deep trough.", 1, true) then
    fail("trough description is cut off")
end
if not main:find("Presets set a palette, a frame style and a glow. ", 1, true) then
    fail("the page subtitle must end with a period")
end
if not looksSource:find("Palettes: Daylight UI is missing the settings frame and glow styles need, so only colors are available.", 1, true) then
    fail("missing the api guard line")
end
if not looksSource:find("Palettes: Looks is also loaded. Turn Looks off; frame and glow styles now live in Palettes.", 1, true) then
    fail("missing the both-addons line")
end
if not main:find("Palettes: off. Daylight's own colors, frame style and glows are restored.", 1, true) then
    fail("missing the full restore line")
end
if not main:find('blurb = "Colors, frame styles and glow styles for Daylight. Class and combat colors stay Daylight\'s."', 1, true) then
    fail("plugin blurb must cover colors, frames and glows")
end
local moods = {
    "A winter hearth of campfire gold: a named beam and a quiet corner flame.",
    "Harvest light on dark oak and pewter, washed along the sill of the bar.",
    "Cool sea-green at the waterline: a tight stamp and a soft wash along the rim.",
    "Near-black soot and weathered bronze: a weathered beam and a short catch of lantern light.",
    "Rose on warm plum-brown. The name tab stays, and a flame is kept lit at the corners.",
    "A deep gold cup in the quiet corner, and a short catch of lantern light.",
    "A named work board and a quiet corner flame, like a forge kept open late.",
    "Storm-grey water in a deep basin, and a soft wash along the rim.",
    "A walnut beam and a brief catch of brass-lantern light, like a high-backed bench by the fire.",
    "A hanging sign and a brief cut of carmine light, after the room has gone quiet.",
}
for i = 1, #moods do
    if not looksSource:find(moods[i], 1, true) then fail("missing preset mood: " .. moods[i]) end
end
if not looksSource:find("powerHeight = 14", 1, true) then
    fail("trough power height must ship as 14")
end

local OFF_LINE = "Looks: off. Type /looks lintel, sill, stamp, trestle, flagon, signboard, trough, wick, draught, latch, hearthnight, harvestide, tidemark, oldroad, vigil, snug, bellows, drawwell, settle, afterhours, or off."
local LINTEL_LINE = "Looks: Lintel is on. Type /looks sill, stamp, trestle, flagon, signboard, trough, wick, draught, latch, hearthnight, harvestide, tidemark, oldroad, vigil, snug, bellows, drawwell, settle, afterhours, or off."
local HEARTH_LINE = "Looks: Hearthnight is on. Type /looks sill, stamp, trestle, flagon, signboard, trough, draught, latch, harvestide, tidemark, oldroad, vigil, snug, bellows, drawwell, settle, afterhours, or off."
local CHANGED_LINE = "Looks: Hearthnight (changed) is on. Type /looks sill, stamp, trestle, flagon, signboard, trough, wick, latch, harvestide, tidemark, oldroad, vigil, snug, bellows, drawwell, settle, afterhours, or off."

local function piece()
    local w = {}
    w.scripts = {}
    function w:SetPoint() end
    function w:SetSize() end
    function w:SetWidth() end
    function w:SetHeight() end
    function w:SetAllPoints() end
    function w:ClearAllPoints() end
    w.shown = true
    function w:Hide() w.shown = false end
    function w:Show() w.shown = true end
    function w:SetShown() end
    function w:SetText(text) w.words = text end
    function w:SetTextColor() end
    function w:SetFont() end
    function w:SetJustifyH() end
    function w:SetWordWrap() end
    function w:SetColorTexture() end
    function w:SetFrameLevel() end
    function w:GetFrameLevel() return 1 end
    function w:EnableMouse() end
    function w:GetWidth() return 760 end
    function w:GetHeight() return 28 end
    function w:GetStringWidth() return 64 end
    function w:GetParent() return nil end
    function w:GetScript() return nil end
    function w:SetScript(name, fn) w.scripts[name] = fn end
    function w:CreateTexture() return piece() end
    function w:CreateFontString() return piece() end
    return w
end

local said = {}
local sets = {
    UnitFrames = { ["look.style"] = "daylight" },
    general = { buttonGlow = "circle" },
    Nameplates = { targetLight = "none" },
}
local palDb = { palette = "tide", classAccent = false, only = false, carried = true }
local views = {}
local styleCalls = { frame = 0, glow = 0 }
local function freshView(name)
    local v = { name = name }
    function v.AddFrameStyle(id, spec)
        styleCalls.frame = styleCalls.frame + 1
        v.frameKey = name .. ":" .. id
        if id == "lintel" then v.lintelKey = name .. ":" .. id end
        if id == "trough" then v.trough = spec end
    end
    function v.AddGlowStyle(id, spec)
        styleCalls.glow = styleCalls.glow + 1
        if id == "wick" then v.glowKey = name .. ":" .. id end
    end
    function v.On(event, fn)
        v.handlers = v.handlers or {}
        v.handlers[event] = fn
    end
    views[name] = v
    return v
end
local ui = {
    API = {
        major = 1,
        minor = 9,
        For = function(name)
            return views[name] or freshView(name)
        end,
        GetUnitFrame = function() return { unit = "player" } end,
        Parts = function()
            return { style = sets.UnitFrames["look.style"] }
        end,
        GetSetting = function(scope, path)
            local bag = sets[scope]
            if type(bag) == "table" then return bag[path] end
        end,
    },
    Widgets = {},
}
function ui:RegisterPlugin() return {} end
function ui:RegisterModule(_, spec) ui.module = spec end
function ui:Get(scope, path)
    if scope == "Palettes" then return palDb[path] end
    local bag = sets[scope]
    if type(bag) == "table" then return bag[path] end
end
function ui:Set(scope, path, value)
    if scope == "Palettes" then
        palDb[path] = value
    else
        sets[scope] = sets[scope] or {}
        sets[scope][path] = value
    end
    local pal = views.Palettes
    if not ns.writingLooks and pal and pal.handlers and pal.handlers.SettingChanged then
        pal.handlers.SettingChanged(scope, path, value)
    end
    return true
end
function ui:GetModule() return nil end

local looksEnv = {
    math = math, string = string, table = table, type = type,
    pairs = pairs, ipairs = ipairs, pcall = pcall, tostring = tostring,
    tonumber = tonumber, select = select, unpack = unpack, next = next, error = error,
    print = function(text) said[#said + 1] = text end,
    DaylightUI = ui,
    SlashCmdList = {},
    CreateFrame = function() return piece() end,
    InCombatLockdown = function() return false end,
}
local looksChunk, looksErr = loadfile(root .. "/Palettes/PalettesLooks.lua")
if not looksChunk then
    fail("could not load PalettesLooks.lua: " .. tostring(looksErr))
else
    setfenv(looksChunk, looksEnv)
    local loaded, loadErr = pcall(looksChunk, "Palettes", ns)
    if not loaded then fail("PalettesLooks.lua failed: " .. tostring(loadErr)) end
end
local mainChunk, mainErr = loadfile(mainPath)
if not mainChunk then
    fail("could not reload Palettes.lua for looks: " .. tostring(mainErr))
else
    setfenv(mainChunk, looksEnv)
    local loaded, loadErr = pcall(mainChunk, "Palettes", ns)
    if not loaded then fail("Palettes.lua with looks failed: " .. tostring(loadErr)) end
end

local function saidHas(text)
    for i = 1, #said do
        if said[i] == text then return true end
    end
    return false
end

check(styleCalls.frame, 7, "seven frame styles register")
check(styleCalls.glow, 3, "three glow styles register")
check(views.Looks and views.Looks.lintelKey, "Looks:lintel", "frame keys stay on Looks")
check(views.Looks and views.Looks.glowKey, "Looks:wick", "glow keys stay on Looks")
check(views.Looks and views.Looks.trough and views.Looks.trough.sizes.player.powerHeight, 14, "trough power height is not clamped here")
local pages = ui.module and ui.module.options and ui.module.options.pages
check(type(pages) == "table" and #pages or 0, 1, "palettes is one page")
check(pages[1] and pages[1].id, "main", "the page id is main")
check(pages[1] and pages[1].label, "Palettes", "the page is Palettes")
local function groupsOn(name)
    local list = {}
    local groups = pages[1] and pages[1].groups or {}
    for i = 1, #groups do
        if groups[i].tab == name then list[#list + 1] = groups[i] end
    end
    return list
end
local themeGroups = groupsOn("Presets")
local colourGroups = groupsOn("Colours")
local lookGroups = groupsOn("Looks")
check(#themeGroups, 1, "presets tab is one list")
check(#colourGroups, 1, "colours tab is one list")
check(#lookGroups, 1, "looks tab is one list")
check(pages[1].groups[1].tab, "Presets", "presets is the first tab")
check(colourGroups[1] and pages[1].groups[2].tab, "Colours", "colours is the second tab")
check(pages[1].groups[#pages[1].groups].tab, "Looks", "looks is the last tab")
check(themeGroups[1].items[1].hidden(), false, "presets tab shows on api 1.9")
check(lookGroups[1].items[1].hidden(), false, "looks tab shows on api 1.9")
local function resetNamed(tab)
    local rows = ns.tabReset
    if type(rows) ~= "table" then return nil end
    for i = 1, #rows do
        if rows[i].tab == tab then return rows[i] end
    end
end
check(resetNamed("Presets") and resetNamed("Presets").label, "Restore Daylight", "presets reset is Restore Daylight")
check(resetNamed("Colours") and resetNamed("Colours").label, "Reset Colours", "colours reset is Reset Colours")
check(resetNamed("Looks") and resetNamed("Looks").label, "Reset Looks", "looks reset is Reset Looks")

local account = ns.accountTable()
local char = ns.charTable()
account.looks = nil
char.only = false
char.looks = nil
said = {}
ns.looksSlash("")
check(said[#said], OFF_LINE, "fresh /looks lists every name")
ns.looksSlash("lintel")
check(sets.UnitFrames["look.style"], "Looks:lintel", "lintel writes the looks key")
check(type(account.looks) == "table" and account.looks.frame, "daylight", "the first write keeps the old frame")
check(account.looks.glow, "circle", "the first write keeps the old glow")
check(account.looks.light, "none", "the first write keeps the old outline")
check(palDb.looks and palDb.looks.frame, "daylight", "the snapshot is in the palettes profile")
check(palDb.palette, "tide", "a frame pick does not change the palette")
said = {}
ns.looksSlash("")
check(said[#said], LINTEL_LINE, "/looks names lintel and leaves it out of the list")
ns.looksSlash("nope")
check(said[#said], LINTEL_LINE, "an unknown name reprints the status")
ns.looksSlash("hearthnight")
check(palDb.palette, "ember", "hearthnight sets the ember palette")
check(sets.UnitFrames["look.style"], "Looks:lintel", "hearthnight sets lintel")
check(sets.general.buttonGlow, "Looks:wick", "hearthnight sets wick on the buttons")
check(sets.Nameplates.targetLight, "Looks:wick", "hearthnight sets wick on the nameplate")
check(account.theme, "hearthnight", "hearthnight remembers the theme")
check(account.looks.frame, "daylight", "a second look does not replace the snapshot")
check(saidHas("Palettes: Hearthnight is on. Your layout is unchanged."), true, "a theme says it is on")
said = {}
ns.looksSlash("")
check(said[#said], HEARTH_LINE, "/looks names the theme and leaves its parts out")
ns.looksSlash("draught")
check(palDb.palette, "ember", "a glow pick does not change the palette")
check(sets.general.buttonGlow, "Looks:draught", "draught replaces wick")
check(account.theme, "hearthnight", "a glow pick keeps the theme name")
check(account.themeChanged, true, "a glow pick marks the theme changed")
said = {}
ns.looksSlash("")
check(said[#said], CHANGED_LINE, "/looks reports the changed theme")
ns.looksSlash("hearthnight")
check(account.themeChanged, false, "picking the theme again clears changed")
check(sets.general.buttonGlow, "Looks:wick", "picking the theme again restores its glow")
local frameBefore = sets.UnitFrames["look.style"]
local glowBefore = sets.general.buttonGlow
looksEnv.SlashCmdList.PALETTES("hearthnight")
check(sets.UnitFrames["look.style"], frameBefore, "/palettes does not take a theme name")
check(sets.general.buttonGlow, glowBefore, "/palettes hearthnight does not change the glow")
said = {}
ns.looksSlash("off")
check(account.theme, false, "a full restore clears the theme")
check(sets.UnitFrames["look.style"], "daylight", "restore writes the saved frame back")
check(sets.general.buttonGlow, "circle", "restore writes the saved glow back")
check(sets.Nameplates.targetLight, "none", "restore writes the saved outline back")
check(account.looks, false, "a successful restore clears the snapshot")
check(saidHas("Palettes: off. Daylight's own colors, frame style and glows are restored."), true, "full restore chat")
sets.UnitFrames["look.style"] = "Looks:sill"
local left = ns.restoreLooks(true)
check(left, false, "restore with no snapshot does nothing")
check(sets.UnitFrames["look.style"], "Looks:sill", "no snapshot leaves the frame alone")

char.only = false
account.looks = nil
sets.UnitFrames["look.style"] = "daylight"
sets.general.buttonGlow = "circle"
sets.Nameplates.targetLight = "none"
ns.setOnly(account, char, true)
ns.looksSlash("sill")
check(char.looks and char.looks.frame, "daylight", "save for this character keeps the snapshot on the character")
check(type(account.looks) == "table", false, "a character snapshot stays off the account")
ns.setOnly(account, char, false)
check(char.looks, nil, "untick drops the character snapshot")

local imported = { palette = "ember", classAccent = false, seeded = true, looks = { frame = "daylight", glow = "circle", light = "none" } }
local importedChar = { only = false, ready = true }
local importedDb = { palette = "tide", classAccent = false, carried = true, looks = { frame = "Looks:lintel", glow = "Looks:wick", light = "Looks:wick" } }
ns.adoptProfile(imported, importedChar, importedDb)
check(imported.looks and imported.looks.frame, "Looks:lintel", "a profile switch adopts the snapshot")
check(imported.palette, "tide", "a profile switch still adopts the palette")
local keep = { palette = "tide", classAccent = false, seeded = true, looks = { frame = "daylight", glow = "circle", light = "none" } }
local keepChar = { only = false, ready = true }
local keepDb = { palette = "ember", classAccent = false, carried = true }
ns.adoptProfile(keep, keepChar, keepDb)
check(keep.looks and keep.looks.frame, "daylight", "a profile with no snapshot leaves yours")

looksEnv.InCombatLockdown = function() return true end
local during = sets.UnitFrames["look.style"]
ns.looksSlash("trough")
check(sets.UnitFrames["look.style"], during, "a combat pick does not write yet")
check(said[#said], "Looks: Trough queued until combat ends.", "a combat pick says it is waiting")
looksEnv.InCombatLockdown = function() return false end
ns.finishLooksCombat()
check(sets.UnitFrames["look.style"], "Looks:trough", "combat end applies the waiting frame")

styleCalls.frame = 0
styleCalls.glow = 0
ui.API.minor = 7
ns.looksReady = nil
ns.looksGuard = nil
ns.looksBothSaid = nil
said = {}
ns.bootLooks()
check(styleCalls.frame, 0, "api 1.7 does not register frames")
check(styleCalls.glow, 0, "api 1.7 does not register glows")
check(said[#said], "Palettes: Daylight UI is missing the settings frame and glow styles need, so only colors are available.", "api 1.7 says only colors")
check(themeGroups[1].items[1].hidden(), true, "api 1.7 hides the presets tab")
check(lookGroups[1].items[1].hidden(), true, "api 1.7 hides the looks tab")
check(type(colourGroups[1].items[1].hidden) ~= "function" or colourGroups[1].items[1].hidden() ~= true, true, "api 1.7 still shows colours")
local beforeGuard = sets.UnitFrames["look.style"]
local paletteGuard = palDb.palette
ns.looksSlash("lintel")
check(sets.UnitFrames["look.style"], beforeGuard, "api 1.7 /looks does not apply")
ns.looksSlash("hearthnight")
check(sets.UnitFrames["look.style"], beforeGuard, "api 1.7 /looks hearthnight does not apply a theme")
check(palDb.palette, paletteGuard, "api 1.7 /looks hearthnight does not change colours")
check(said[#said], "Palettes: Daylight UI is missing the settings frame and glow styles need, so only colors are available.", "/looks repeats the guard")

ui.API.minor = 9
ns.looksReady = nil
ns.looksGuard = nil
ns.looksBothSaid = nil
styleCalls.frame = 0
looksEnv.C_AddOns = { IsAddOnLoaded = function(name) return name == "Looks" end }
said = {}
ns.bootLooks()
check(styleCalls.frame, 0, "a loaded Looks add-on is not registered twice")
check(said[#said], "Palettes: Looks is also loaded. Turn Looks off; frame and glow styles now live in Palettes.", "both add-ons get one line")

check(resetNamed("Looks") and resetNamed("Looks").label, "Reset Looks", "looks reset is labelled Reset Looks")
local row = piece()
local body = lookGroups[1].items[1]
ui.API.minor = 9
ns.looksReady = true
ns.looksGuard = nil
if type(body) == "table" and type(body.build) == "function" then
    local built, buildErr = pcall(body.build, row)
    if not built then fail("looks tab did not build: " .. tostring(buildErr)) end
    check(type(row.lines) == "table" and #row.lines or 0, 10, "frames and glows are rows")
    if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
    local active = row.lines[1]
    active.SetOn(true, false)
    check(active.key.shown, false, "the picked row hides its key")
    check(active.onText.words, "✓", "the picked row shows a check")
    check(active.onText.shown, true, "the check is visible")
    active.SetOn(false, true)
    check(active.key.shown, false, "a waiting row hides its key")
    check(active.onText.words, "PENDING", "a waiting row shows PENDING")
    active.SetOn(false, false)
    check(active.key.shown, false, "style keys stay off the row")
    active.SetHover(true)
    check(active.hoverText.words, "HOVER", "a hovered row says HOVER")
    check(active.hoverText.shown, true, "the hover mark is visible")
    active.SetHover(false)
    local beforeStyle = sets.UnitFrames["look.style"]
    local lintel = row.lines[1]
    if type(lintel.button) ~= "table" or type(lintel.button.scripts.OnClick) ~= "function" then
        fail("a style row is not a button")
    else
        lintel.button.scripts.OnClick()
        check(sets.UnitFrames["look.style"], beforeStyle, "a row click previews and does not write")
        check(type(ns.staged) == "table" and ns.staged.kind, "frame", "a frame click is staged")
        looksEnv.StaticPopupDialogs = {}
        looksEnv.StaticPopup_Show = function(which) said[#said + 1] = "popup:" .. which end
        local committed = ns.commitStaged()
        check(committed, true, "apply commits the staged pick")
        check(sets.UnitFrames["look.style"], "Looks:lintel", "apply writes the frame")
        check(said[#said], "popup:PALETTES_RELOAD", "apply asks to reload")
        local entered = false
        local menuButton = piece()
        function menuButton:GetScript(name)
            if name == "OnEnter" then return function() entered = true end end
            if name == "OnLeave" then return function() end end
        end
        looksEnv.GameMenuFrame = {
            buttonPool = {
                EnumerateActive = function()
                    local done = false
                    return function()
                        if done then return nil end
                        done = true
                        return menuButton
                    end
                end,
            },
        }
        check(ns.refreshGameMenu(), true, "game menu refresh touches a pooled button")
        check(entered, true, "game menu refresh runs the button hover script")
    end
else
    fail("looks tab has no body")
end
local themeRow = piece()
local themeBody = themeGroups[1].items[1]
if type(themeBody) == "table" and type(themeBody.build) == "function" then
    local builtTheme, themeErr = pcall(themeBody.build, themeRow)
    if not builtTheme then fail("themes tab did not build: " .. tostring(themeErr)) end
    check(type(themeRow.lines) == "table" and #themeRow.lines or 0, 10, "ten theme rows")
    local hearth = themeRow.lines[1]
    local lastTheme = themeRow.lines[10]
    check(hearth.baseName, "Hearthnight", "theme order still starts with Hearthnight")
    check(lastTheme.baseName, "After Hours", "theme order still ends with After Hours")
    check(hearth.parts, "Ember · Lintel · Wick", "hearthnight names its palette, frame and glow")
    check(lastTheme.parts, "Carmine Night · Signboard · Latch", "after hours names its palette, frame and glow")
    check(hearth.mood, "A winter hearth of campfire gold: a named beam and a quiet corner flame.", "hearthnight keeps its mood")
    check(type(hearth.preview) == "table" and #hearth.preview or 0, 3, "a theme row shows three swatches")
    check(hearth.preview[1], ns.byId.ember.background, "the first swatch is the palette background")
    check(hearth.preview[2], ns.byId.ember.band, "the second swatch is the band")
    check(hearth.preview[3], ns.byId.ember.c2, "the third swatch is the accent")
    check(row.lines[1].parts, nil, "a frame row has no parts line")
    account.theme = "hearthnight"
    account.themeChanged = true
    palDb.palette = "tide"
    if type(themeRow.UpdateLooks) == "function" then themeRow.UpdateLooks() end
    check(hearth.name.words, "Hearthnight (changed)", "a changed theme still renames the row")
    check(hearth.parts, "Ember · Lintel · Wick", "changed leaves the parts line")
else
    fail("themes tab has no body")
end

sets.UnitFrames["look.style"] = "daylight"
sets.general.buttonGlow = "circle"
sets.Nameplates.targetLight = "none"
account.looks = nil
account.theme = false
account.themeChanged = false
palDb.palette = "tide"
palDb.looks = nil
ns.looksSlash("hearthnight")
check(account.theme, "hearthnight", "reset setup turns hearthnight on")
local coloursButton = resetNamed("Colours")
if type(coloursButton) == "table" and type(coloursButton.run) == "function" then
    coloursButton.run()
end
check(palDb.palette, "off", "Restore colours turns the palette off")
check(sets.UnitFrames["look.style"], "Looks:lintel", "Restore colours leaves the frame")
check(sets.general.buttonGlow, "Looks:wick", "Restore colours leaves the glow")
check(account.theme, "hearthnight", "Restore colours keeps the theme name")
check(account.themeChanged, true, "Restore colours marks the theme changed")

account.themeChanged = false
palDb.palette = "ember"
sets.UnitFrames["look.style"] = "Looks:lintel"
sets.general.buttonGlow = "Looks:wick"
sets.Nameplates.targetLight = "Looks:wick"
account.looks = { frame = "daylight", glow = "circle", light = "none" }
palDb.looks = account.looks
local looksButton = resetNamed("Looks")
if type(looksButton) ~= "table" or type(looksButton.run) ~= "function" then
    fail("looks reset did not build")
else
    looksButton.run()
end
check(palDb.palette, "ember", "Restore looks leaves the palette")
check(sets.UnitFrames["look.style"], "daylight", "Restore looks puts the saved frame back")
check(account.theme, "hearthnight", "Restore looks keeps the theme name")
check(account.themeChanged, true, "Restore looks marks the theme changed")

sets.UnitFrames["look.style"] = "Looks:sill"
sets.general.buttonGlow = "Looks:latch"
sets.Nameplates.targetLight = "Looks:latch"
account.looks = nil
palDb.looks = nil
account.theme = "hearthnight"
account.themeChanged = false
palDb.palette = "ember"
looksButton.run()
check(sets.UnitFrames["look.style"], "Looks:sill", "Restore looks with no snapshot leaves the frame")
check(sets.general.buttonGlow, "Looks:latch", "Restore looks with no snapshot leaves the glow")
check(palDb.palette, "ember", "Restore looks with no snapshot leaves the palette")
check(account.theme, "hearthnight", "Restore looks with no snapshot keeps the theme")
check(account.themeChanged, false, "Restore looks with no snapshot does not mark the theme changed")

palDb.palette = "ember"
sets.UnitFrames["look.style"] = "Looks:lintel"
sets.general.buttonGlow = "Looks:wick"
sets.Nameplates.targetLight = "Looks:wick"
account.looks = { frame = "daylight", glow = "circle", light = "none" }
palDb.looks = account.looks
account.theme = "hearthnight"
account.themeChanged = false
local themesButton = resetNamed("Presets")
if type(themesButton) ~= "table" or type(themesButton.run) ~= "function" then
    fail("presets reset did not build")
else
    themesButton.run()
end
check(palDb.palette, "off", "Restore Daylight turns colours off")
check(sets.UnitFrames["look.style"], "daylight", "Restore Daylight puts the frame back")
check(account.theme, false, "Restore Daylight clears the theme")

local round = ns.parseShare("PAL2-hearthnight-ember-lintel-wick")
check(round and round.theme, "hearthnight", "PAL2 keeps the theme")
check(round and round.palette, "ember", "PAL2 keeps the palette")
check(round and round.frame, "lintel", "PAL2 keeps the frame")
check(round and round.glow, "wick", "PAL2 keeps the glow")
check(ns.pal2Code(round), "PAL2-hearthnight-ember-lintel-wick", "PAL2 theme code round-trips")
local drifted = ns.parseShare("PAL2-HEARTHNIGHT-EMBER-LINTEL-DRAUGHT")
check(drifted and drifted.glow, "draught", "PAL2 ignores case")
check(ns.pal2Code({ theme = "hearthnight", palette = "ember", frame = "lintel", glow = "draught" }), "PAL2-hearthnight-ember-lintel-draught", "a changed theme keeps its name in the code")
local parts = ns.parseShare("PAL2-ember-lintel-wick")
check(parts and parts.theme, nil, "PAL2 without a theme has no theme name")
check(ns.pal2Code(parts), "PAL2-ember-lintel-wick", "PAL2 parts round-trip")
local onlyPalette = ns.parseShare("PAL2-ember-none-none")
check(onlyPalette and onlyPalette.frame, "none", "PAL2 none leaves the frame unset")
local customCode = ns.parseShare("PAL2-#C-#1A1410-#C4A574-sill-wick")
check(customCode and customCode.custom, true, "PAL2-C is custom colors")
check(customCode and customCode.frame, "sill", "PAL2-C keeps the frame")
check(ns.pal2Code({ custom = true, base = "1A1410", accent = "C4A574", frame = "sill", glow = "wick" }), "PAL2-C-1A1410-C4A574-sill-wick", "PAL2-C round-trips")
local customOnly = ns.applyShareCode("PAL2-C-1A1410-C4A574-none-none")
check(type(customOnly) == "table", true, "PAL2-C loads a custom draft")
check(ns.shareLook, nil, "PAL2-C with none does not queue a frame")
local queued = ns.applyShareCode("PAL2-C-341529-E2B14A-sill-wick")
check(type(queued) == "table", true, "PAL2-C with a look loads the draft")
check(ns.shareLook and ns.shareLook.frame, "sill", "PAL2-C holds the frame until Save")
check(ns.shareLook and ns.shareLook.glow, "wick", "PAL2-C holds the glow until Save")
ns.shareLook = nil
local pal1 = ns.applyShareCode("PAL1-341529-E2B14A")
check(ns.shareCode(pal1), "PAL1-341529-E2B14A", "PAL1 still imports colors only")
check(ns.shareLook, nil, "PAL1 does not queue a frame or glow")
check(ns.parseShare("PAL2-nope-ember-lintel-wick"), nil, "a bad PAL2 is rejected")
sets.UnitFrames["look.style"] = "daylight"
sets.general.buttonGlow = "circle"
sets.Nameplates.targetLight = "none"
palDb.palette = "tide"
account.theme = false
said = {}
check(ns.applyLiveShare(ns.parseShare("PAL2-hearthnight-ember-lintel-wick")), true, "a PAL2 theme applies")
check(palDb.palette, "ember", "PAL2 theme sets the palette")
check(sets.UnitFrames["look.style"], "Looks:lintel", "PAL2 theme sets the frame")
check(sets.general.buttonGlow, "Looks:wick", "PAL2 theme sets the glow")
check(account.theme, "hearthnight", "PAL2 theme marks the theme on")
check(account.themeChanged, false, "an exact PAL2 theme is not changed")
check(ns.applyLiveShare(ns.parseShare("PAL2-tide-none-none")), true, "a palette-only PAL2 applies")
check(palDb.palette, "tide", "a palette-only PAL2 changes colours")
check(sets.UnitFrames["look.style"], "Looks:lintel", "PAL2 none leaves the frame alone")
check(account.theme, false, "a PAL2 with no theme name drops a theme the parts do not match")

sets.UnitFrames["look.style"] = "Looks:lintel"
sets.general.buttonGlow = "Looks:wick"
sets.Nameplates.targetLight = "Looks:wick"
account.theme = "hearthnight"
account.themeChanged = false
palDb.palette = "ember"
ns.notePalette("ember")
check(account.themeChanged, false, "picking the theme's own palette does not mark it changed")
ns.notePalette("tide")
check(account.theme, "hearthnight", "another palette keeps the theme name")
check(account.themeChanged, true, "another palette marks the theme changed")
ns.notePalette("ember")
check(account.themeChanged, false, "parts that match the theme clear changed")

local shot = ns.captureUndo("theme")
sets.UnitFrames["look.style"] = "Looks:sill"
sets.general.buttonGlow = "Looks:draught"
sets.Nameplates.targetLight = "Looks:draught"
account.theme = "hearthnight"
account.themeChanged = true
ns.applyUndoShot(shot)
check(sets.UnitFrames["look.style"], "Looks:lintel", "undo of a theme puts the frame back")
check(sets.general.buttonGlow, "Looks:wick", "undo of a theme puts the glow back")
check(account.themeChanged, false, "undo of a theme clears changed when the parts match")

local bare = { palette = "tide", classAccent = false, seeded = true, theme = "vigil" }
local bareChar = { only = false, ready = true }
local bareDb = { palette = "ember", classAccent = false, carried = true }
ns.adoptProfile(bare, bareChar, bareDb)
check(bare.theme, "vigil", "a profile with no theme keys leaves the theme")
local brought = { palette = "tide", classAccent = false, seeded = true }
local broughtChar = { only = false, ready = true }
local broughtDb = {
    palette = "vanilla", classAccent = false, carried = true,
    theme = "harvestide", themeChanged = false, frame = "sill", glow = "draught",
}
ns.adoptProfile(brought, broughtChar, broughtDb)
check(brought.theme, "harvestide", "a profile theme is adopted")
check(sets.UnitFrames["look.style"], "Looks:sill", "a profile frame is adopted")
check(sets.general.buttonGlow, "Looks:draught", "a profile glow is adopted")
local unknownTheme = { palette = "ember", classAccent = false, seeded = true, theme = "snug", frame = "flagon", glow = "latch" }
local unknownChar = { only = false, ready = true }
local unknownDb = { palette = "not-a-palette", classAccent = false, carried = true, theme = "bellows", frame = "trestle", glow = "wick" }
ns.adoptProfile(unknownTheme, unknownChar, unknownDb)
check(unknownTheme.palette, "ember", "an unknown profile palette still falls back to ember")
check(unknownTheme.theme, "snug", "an unknown profile palette does not apply its theme")
check(unknownTheme.frame, "flagon", "an unknown profile palette does not apply its frame")

if failures > 0 then
    io.stderr:write(failures .. " Palettes check(s) failed\n")
    os.exit(1)
end

io.write("Palettes check passed\n")
