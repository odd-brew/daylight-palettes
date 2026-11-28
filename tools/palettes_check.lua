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
check(ns.order and #ns.order or 0, 45, "palette count")

local ids = {
    "ember", "tide", "dusk", "ash", "pine",
    "forgeglow", "nightglass", "vesper", "carmine-night", "gilded", "phosphor", "ink", "sightline",
    "vanilla", "forever",
    "verdigris", "abyssal", "cinderclay", "lichen", "twilight",
    "warrior", "mage", "paladin", "priest",
    "hunter", "rogue", "shaman", "warlock", "druid",
    "keepstone", "ironbanner", "sapphire-crown", "crownwall", "deepforge",
    "starshade", "cogspark", "rustbrand", "gravelight", "plainsong", "junglefire",
    "kirintor", "sunspire", "blackrock", "stranglethorn", "winterspring",
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

for i = 1, 20 do
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
check(ns.groups and #ns.groups[1].ids, 20, "dark count")
check(ns.groups and ns.groups[2].label, "Class themes", "class group")
check(ns.groups and #ns.groups[2].ids, 9, "class theme count")
check(ns.groups and ns.groups[3].label, "Realm themes", "realm group")
check(ns.groups and #ns.groups[3].ids, 16, "realm theme count")
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
if not (choicesAt and accentAt and saveAt
    and choicesAt < accentAt and accentAt < saveAt) then
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
check(ns.order and #ns.order or 0, 45, "custom does not add a forty-sixth palette")
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
        function w:SetTexture(path) w.texture = path end
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
    local editorPopups = {}
    local editorCombat = false
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
            StaticPopupDialogs = {},
            StaticPopup_Show = function(which) editorPopups[#editorPopups + 1] = which end,
            InCombatLockdown = function() return editorCombat end,
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
                local save = named["Save"]
                if type(save) ~= "table" or type(save.scripts.OnClick) ~= "function" then
                    fail("the editor has no Save button")
                else
                    local saved, saveErr = pcall(save.scripts.OnClick)
                    if not saved then fail("Save: " .. tostring(saveErr)) end
                    check(accentRow.hidden(), false, "accent follows class shows again after Save")
                    check(restoreRow.hidden(), false, "restore shows again after Save")
                    check(#editorPopups, 1, "saving Custom asks to reload once")
                    local againOpen, againOpenErr = pcall(custom.scripts.OnClick)
                    if not againOpen then fail("reopening custom after save: " .. tostring(againOpenErr)) end
                    local savedAgain, savedAgainErr = pcall(save.scripts.OnClick)
                    if not savedAgain then fail("saving Custom again: " .. tostring(savedAgainErr)) end
                    check(#editorPopups, 1, "a no-op Custom Save out of combat does not ask to reload")
                    editorCombat = true
                    local combatOpen, combatOpenErr = pcall(custom.scripts.OnClick)
                    if not combatOpen then fail("reopening custom in combat: " .. tostring(combatOpenErr)) end
                    local combatSave, combatSaveErr = pcall(save.scripts.OnClick)
                    if not combatSave then fail("no-op Custom Save in combat: " .. tostring(combatSaveErr)) end
                    editorCombat = false
                    if type(ns.finishQueuedReload) == "function" then ns.finishQueuedReload(true) end
                    check(#editorPopups, 1, "a no-op Custom Save in combat does not ask to reload")
                end
            end
        end
    end
end

if not toc:find("## Version: 0.9.0", 1, true) then
    fail("version stays 0.9.0")
end
if not toc:find("frame looks", 1, true) or toc:find("glow styles", 1, true) then
    fail("toc notes must cover frame looks and not glow styles")
end
if not toc:find("PalettesLooks.lua", 1, true) then
    fail("toc must load PalettesLooks.lua")
end
local looksSource = readAll(root .. "/Palettes/PalettesLooks.lua")
if looksSource:find("LooksDB", 1, true) and looksSource:find("LooksDB%s*=", 1, false) then
    fail("looks must not write LooksDB")
end
if looksSource:find("AddGlowStyle", 1, true) or looksSource:find("SetGlowStyle", 1, true) then
    fail("looks must not register or set glow styles")
end
if not looksSource:find("Each preset is a ready-made pairing of a Colours palette with a frame look. Pick one, then change either part on the Colours or Looks tab.", 1, true) then
    fail("missing the presets intro")
end
if not looksSource:find("A Preset on the Presets tab sets both.", 1, true) then
    fail("missing the looks intro")
end
local frameLines = {
    "Slanted bar with round class socket and flowing health FX for smooth combat feedback.",
    "Slim slanted bar with hung power rail and top name tab to save vertical screen space.",
    "Tall slanted bar with angled portrait and big HP numbers for instant peripheral reads.",
    "Slim slanted ribbon with floating name and class-ring portrait to cut mid-screen bulk.",
    "Square portrait-free bar with dual health and power readouts for clean resource tracking.",
    "Tall hero bar with 3D portrait, thick class ring, and big numbers for classic presence.",
    "Flat 22px portrait-free strip with hairline power bar for the smallest combat footprint.",
}
for i = 1, #frameLines do
    if not looksSource:find(frameLines[i], 1, true) then fail("missing frame one-liner: " .. frameLines[i]) end
end
if looksSource:find("A named board with a round portrait", 1, true) then
    fail("Trestle ships the mock wording, not the spec summary")
end
if looksSource:find("AddFrameStyle", 1, true) or looksSource:find("SetFrameStyle", 1, true) then
    fail("frame looks must not use the frame style API")
end
if main:find("look.style", 1, true) or main:find("AddFrameStyle", 1, true) then
    fail("Palettes.lua must not touch look.style or frame styles")
end
do
    local from = looksSource:find("function ns.migrateFrames()", 1, true)
    local to = looksSource:find("function ns.noteLooksAddon()", 1, true)
    local uses = 0
    local at = 1
    while true do
        local found = looksSource:find('"look.style"', at, true)
        if not found then break end
        uses = uses + 1
        if not (from and to and found > from and found < to) then fail("look.style is used outside the one-time migration") end
        at = found + 1
    end
    check(uses, 2, "look.style is read and written once, in the migration")
end
if not main:find("Presets set a palette and a frame look. ", 1, true) then
    fail("the page subtitle must end with a period")
end
if not looksSource:find("Palettes: Daylight UI is missing the settings frame looks need, so only colors are available.", 1, true) then
    fail("missing the api guard line")
end
if not looksSource:find("Palettes: Looks is also loaded. Turn Looks off; frame looks now live in Palettes.", 1, true) then
    fail("missing the both-addons line")
end
if not main:find("Palettes: off. Daylight's own colors and frame look are restored.", 1, true) then
    fail("missing the full restore line")
end
if not main:find('blurb = "Colors and frame looks for Daylight. Class and combat colors stay Daylight\'s."', 1, true) then
    fail("plugin blurb must cover colors and frame looks")
end
local moods = {
    "Warm ember frames and fiery casts for high-focus combat.",
    "Warm classic ribbons and soft bars for relaxed sessions.",
    "Portrait-free, razor-thin frames for maximum screen view.",
    "Tall 3D hero portraits and heavy steel for classic weight.",
    "Triage-ready party grids, vertical raid bars, medallions.",
    "Gilded trim with animated flow bars and round buttons.",
}
for i = 1, #moods do
    if not looksSource:find(moods[i], 1, true) then fail("missing preset mood: " .. moods[i]) end
end
local OFF_LINE = "Looks: off. Type /looks flagon, trestle, beam, stream, ledger, crest, slate, anvil, channel, hearthnight, harvestide, tidemark, oldroad, vigil, snug, bastionline, arcanum, canopy, blackrockledger, or off."
local BEAM_LINE = "Looks: Beam is on. Type /looks flagon, trestle, stream, ledger, crest, slate, anvil, channel, hearthnight, harvestide, tidemark, oldroad, vigil, snug, bastionline, arcanum, canopy, blackrockledger, or off."
local HEARTH_LINE = "Looks: Hearthnight is on. Type /looks flagon, trestle, stream, ledger, crest, slate, anvil, channel, harvestide, tidemark, oldroad, vigil, snug, bastionline, arcanum, canopy, blackrockledger, or off."
local CHANGED_LINE = "Looks: Hearthnight (changed) is on. Type /looks flagon, trestle, stream, ledger, crest, slate, hearthnight, harvestide, tidemark, oldroad, vigil, snug, or off."

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
    function w:SetTextColor(r, g, b, a) w.ink = { r, g, b, a } end
    function w:SetFont() end
    function w:SetJustifyH() end
    function w:SetWordWrap() end
    function w:SetColorTexture(r, g, b, a) w.color = { r, g, b, a } end
    function w:SetTexture(path) w.texture = path end
    function w:SetVertexColor(r, g, b, a) w.vertex = { r, g, b, a } end
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
local unitWrites = {}
local unitOverrides = {}
local batches = { runs = 0, depth = 0, outside = 0 }
-- Daylight's Override: a temporary value that is never saved. savedValue is
-- what a logout would write, so the held value counts as its old one.
local held = {}
local function savedValue(scope, path)
    for i = 1, #held do
        if held[i].scope == scope and held[i].path == path then return held[i].was end
    end
    return sets[scope][path]
end
local function freshView(name)
    local v = { name = name }
    function v.Override(scope, path, value)
        for i = 1, #held do
            if held[i].scope == scope and held[i].path == path then return nil end
        end
        local o = { scope = scope, path = path, was = sets[scope][path], override = true }
        unitOverrides[#unitOverrides + 1] = { scope = scope, path = path, value = value, batch = batches.depth }
        held[#held + 1] = o
        sets[scope][path] = value
        return o
    end
    function v.AddFrameStyle()
        styleCalls.frame = styleCalls.frame + 1
    end
    function v.AddGlowStyle(id, spec)
        styleCalls.glow = styleCalls.glow + 1
        if id == "wick" then v.glowKey = name .. ":" .. id end
    end
    function v.AddOptionsGroup(id, spec)
        v.optionsGroups = v.optionsGroups or {}
        v.optionsGroups[id] = spec
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
        Off = function(handle)
            for i = 1, #held do
                if held[i] == handle then
                    table.remove(held, i)
                    sets[handle.scope][handle.path] = handle.was
                    unitOverrides[#unitOverrides + 1] = { off = true, scope = handle.scope, path = handle.path, batch = batches.depth }
                    return
                end
            end
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
function ui.Batch(fn)
    batches.runs = batches.runs + 1
    batches.depth = batches.depth + 1
    local ok, err = pcall(fn)
    batches.depth = batches.depth - 1
    if not ok then error(err, 0) end
end
function ui:Set(scope, path, value)
    if scope == "Palettes" then
        palDb[path] = value
    else
        sets[scope] = sets[scope] or {}
        sets[scope][path] = value
        if scope == "UnitFrames" then
            unitWrites[#unitWrites + 1] = { path = path, value = value, batch = batches.depth }
            if batches.depth == 0 then batches.outside = batches.outside + 1 end
        end
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

check(styleCalls.frame, 0, "frame looks do not register frame styles")
check(styleCalls.glow, 0, "glow styles do not register")

local FRAME_IDS = { "flagon", "trestle", "beam", "stream", "ledger", "crest", "slate" }
local frameKeys = ns.frameKeys()
local sizeKeys = ns.frameSizeKeys()
local extraValues = ns.frameExtras()
local extraKeys = {}
for key in pairs(extraValues) do extraKeys[#extraKeys + 1] = key end
table.sort(extraKeys)
local SENTINELS = {
    ["look.style"] = "daylight", ["look.slant"] = 0.21,
    ["focus.width"] = 250, ["focus.style"] = "ribbon", ["party.height"] = 30, ["raid.width"] = 120,
    ["arena.portrait"] = "2d", ["pet.width"] = 90, ["targettarget.width"] = 100,
    ["player.enabled"] = true, ["target.enabled"] = true, ["player.fade.mode"] = "ooc",
    ["playerAuras.buffs"] = true, ["playerCastbar.at"] = "below", ["targetCastbar.at"] = "power",
    ["player.predictHeals"] = true, ["player.colors"] = "mine", ["target.showMarker"] = true,
}
local allKeys = {}
for _, list in ipairs({ frameKeys, sizeKeys, extraKeys }) do
    for i = 1, #list do allKeys[#allKeys + 1] = list[i] end
end
local function userValue(key) return "user:" .. key end
local function seedFrames()
    local bag = {}
    for key, value in pairs(SENTINELS) do bag[key] = value end
    for i = 1, #allKeys do bag[allKeys[i]] = userValue(allKeys[i]) end
    sets.UnitFrames = bag
end
local function setBundle(id)
    for key, value in pairs(ns.frameValues(id)) do sets.UnitFrames[key] = value end
end
local function liveHas(id)
    for key, value in pairs(ns.frameValues(id)) do
        if sets.UnitFrames[key] ~= value then return false, key end
    end
    return true
end
local function liveLook()
    for i = 1, #FRAME_IDS do
        if liveHas(FRAME_IDS[i]) then return FRAME_IDS[i] end
    end
end
local function userRestored()
    for i = 1, #allKeys do
        if sets.UnitFrames[allKeys[i]] ~= userValue(allKeys[i]) then return false, allKeys[i] end
    end
    return true
end
local function sentinelsIntact()
    for key, value in pairs(SENTINELS) do
        if sets.UnitFrames[key] ~= value then return false, key end
    end
    return true
end
local function unitOf(path)
    return string.match(path, "^(%a+)%.")
end
local ALLOWED_UNIT = { player = true, playerText = true, target = true, targetText = true }
local function logsStayOnTwoFrames(log, label)
    local bad
    for i = 1, #log do
        local unit = unitOf(log[i].path)
        if not ALLOWED_UNIT[unit] or log[i].path == "look.style" then bad = log[i].path end
    end
    check(bad, nil, label)
end
local function resetLogs()
    for i = #unitWrites, 1, -1 do unitWrites[i] = nil end
    for i = #unitOverrides, 1, -1 do unitOverrides[i] = nil end
    batches.runs = 0
    batches.outside = 0
end
local function popupCount()
    local n = 0
    for i = 1, #said do
        if said[i] == "popup:PALETTES_RELOAD" then n = n + 1 end
    end
    return n
end

-- Every look carries the same keys and only touches the player and target frames.
for i = 1, #FRAME_IDS do
    local id = FRAME_IDS[i]
    local values = ns.frameValues(id)
    local missing
    for k = 1, #frameKeys do
        if values[frameKeys[k]] == nil then missing = frameKeys[k] end
    end
    check(missing, nil, id .. " fills every frame key")
    local stray
    for key in pairs(values) do
        if not ALLOWED_UNIT[unitOf(key)] or key == "look.style" or key == "look.slant" then stray = key end
        if string.find(key, "%.enabled$") or string.find(key, "%.powerAt$") and values[key] ~= "inside" then stray = key end
    end
    check(stray, nil, id .. " writes only player and target keys")
    check(values["player.powerAt"], "inside", id .. " keeps power inside")
    check(values["target.portraitAt"], "frame", id .. " keeps the portrait on the frame")
    check(values["player.showLevel"], false, id .. " leaves the player level off")
    check(values["target.showLevel"], true, id .. " keeps the target level on")
    check(values["player.shell.own"], true, id .. " owns its border")
    local style = values["player.style"]
    for _, unit in ipairs({ "player", "target" }) do
        for _, field in ipairs({ "height", "powerHeight", "tabHeight" }) do
            check(values[unit .. ".sizes." .. style .. "." .. field], values[unit .. "." .. field], id .. " " .. unit .. " sizes " .. field)
        end
    end
    check(values["player.portraitDragon"], id == "crest", id .. " dragon is Crest only")
    check(values["target.levelPos"], id == "crest" and "ring" or "foot", id .. " level badge position")
    check(values["target.portraitDragon"], nil, id .. " has no target dragon")
end
local borders = { flagon = 3, trestle = 3, beam = 6, stream = 4, ledger = 4, crest = 8, slate = 4 }
local widths = { flagon = 187, trestle = 187, beam = 200, stream = 210, ledger = 196, crest = 192, slate = 188 }
local styles = { flagon = "daylight", trestle = "ribbon", beam = "daylight", stream = "ribbon", ledger = "daylight", crest = "daylight", slate = "ribbon" }
for _, id in ipairs(FRAME_IDS) do
    local values = ns.frameValues(id)
    for _, unit in ipairs({ "player", "target" }) do
        check(values[unit .. ".shell.borderPx"], borders[id], id .. " " .. unit .. " border")
        check(values[unit .. ".width"], widths[id], id .. " " .. unit .. " width")
        check(values[unit .. ".style"], styles[id], id .. " " .. unit .. " style")
    end
end
local trestleValues = ns.frameValues("trestle")
check(trestleValues["player.portraitScale"], 0.80, "Trestle portrait scale is 0.80")
check(trestleValues["target.portraitScale"], 0.80, "Trestle target portrait scale is 0.80")
check(trestleValues["player.portraitRingWidth"], "normal", "Trestle keeps its normal ring")
local ledgerValues = ns.frameValues("ledger")
check(ledgerValues["player.showPowerText"], true, "Ledger shows power text")
check(ledgerValues["target.powerFormat"], "percent", "Ledger power text is a percent")
check(ledgerValues["player.powerFormat"], "percent", "Ledger player power text is a percent")
check(ledgerValues["playerText.power"], 0, "Ledger power text fits the bar")
check(ledgerValues["targetText.power"], 0, "Ledger target power text fits the bar")
check(ledgerValues["player.portrait"], "none", "Ledger has no portrait")
check(ledgerValues["player.namePos"], "above", "Ledger names float above")
check(ns.frameValues("crest")["player.portrait"], "3d", "Crest is a 3D portrait")
check(ns.frameValues("crest")["player.portraitLook"], "classic", "Crest is a classic portrait")
check(ns.frameValues("beam")["player.portraitShape"], "angled", "Beam keeps DaylightUI's angled portrait shape")
check(ns.frameValues("beam")["player.tab.width"], "full", "Beam has a full-width tab")
for _, id in ipairs({ "flagon", "beam", "stream", "ledger", "crest", "slate" }) do
    check(extraValues["player.media.health"] ~= nil and ns.frameValues(id)["player.media.health"], nil, id .. " carries no Flagon extras")
end
check(extraValues["player.barFx.health.style"], "flow", "Flagon extras set Flow")
check(extraValues["target.media.powerBack"], "daylight", "Flagon extras set the DaylightUI textures")
check(extraValues["player.colorHealth"], "global", "Flagon extras follow the Look page colours")
check(ns.resolveFrame("lintel"), "beam", "lintel is Beam")
check(ns.resolveFrame("sill"), "stream", "sill is Stream")
check(ns.resolveFrame("stamp"), "slate", "stamp is Slate")
check(ns.resolveFrame("signboard"), "beam", "signboard is Beam")
check(ns.resolveFrame("trough"), "ledger", "trough is Ledger")
check(ns.resolveFrame("crest"), "crest", "a look keeps its own id")
check(ns.resolveFrame("nope"), nil, "an unknown frame has no look")
do
    local icons = ns.frameIcons
    for _, id in ipairs(FRAME_IDS) do
        local parts = icons and icons[id]
        check(type(parts) == "table" and #parts > 0, true, id .. " has a silhouette")
        local inside = true
        for _, part in ipairs(parts or {}) do
            if part[1] < 0 or part[2] < 0 or part[1] + part[3] > 36 or part[2] + part[4] > 18 then inside = false end
        end
        check(inside, true, id .. " silhouette fits 36 x 18")
    end
    check(icons and icons.lintel, nil, "retired frames have no silhouette")
end

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
seedFrames()
ns.looksSlash("")
check(said[#said], OFF_LINE, "fresh /looks lists every name")
resetLogs()
ns.looksSlash("beam")
check(liveHas("beam"), true, "beam writes the beam bundle")
check(sets.UnitFrames["look.style"], "daylight", "a frame look never writes look.style")
check(sentinelsIntact(), true, "a frame look leaves other frames and settings alone")
logsStayOnTwoFrames(unitWrites, "a frame look writes only the player and target keys")
check(batches.outside, 0, "every frame write is inside DaylightUI.Batch")
check(batches.runs, 1, "a frame look is one batch")
check(sets.UnitFrames["player.barFx.health.style"], userValue("player.barFx.health.style"), "Beam does not write the bar animation")
check(sets.UnitFrames["target.media.health"], userValue("target.media.health"), "Beam does not write textures")
check(sets.UnitFrames["player.colorHealth"], userValue("player.colorHealth"), "Beam does not write colours")
check(type(account.looks) == "table" and type(account.looks.frameValues) == "table", true, "the first write saves the frame values")
check(account.looks.frameValues["player.width"], userValue("player.width"), "the snapshot keeps the old width")
check(account.looks.frameValues["target.sizes.ribbon.height"], userValue("target.sizes.ribbon.height"), "the snapshot keeps the sizes keys")
check(account.looks.frameValues["player.barFx.health.style"], userValue("player.barFx.health.style"), "the snapshot keeps the Flagon extras")
check(account.looks.frame, nil, "the snapshot does not save a frame style")
check(account.looks.glow, nil, "a frame look saves no glow")
check(palDb.looks and palDb.looks.frameValues and palDb.looks.frameValues["target.portrait"], userValue("target.portrait"), "the snapshot is in the palettes profile")
check(palDb.palette, "tide", "a frame pick does not change the palette")
said = {}
ns.looksSlash("")
check(said[#said], BEAM_LINE, "/looks names beam and leaves it out of the list")
ns.looksSlash("nope")
check(said[#said], BEAM_LINE, "an unknown name reprints the status")
sets.general.buttonGlow = "Neon:custom"
sets.Nameplates.targetLight = "Neon:target"
ns.looksSlash("hearthnight")
check(palDb.palette, "ember", "hearthnight sets the ember palette")
check(liveHas("beam"), true, "hearthnight sets beam")
check(sets.general.buttonGlow, "Neon:custom", "hearthnight leaves existing buttonGlow untouched")
check(sets.Nameplates.targetLight, "Neon:target", "hearthnight leaves existing targetLight untouched")
check(account.theme, "hearthnight", "hearthnight remembers the theme")
check(account.looks.frameValues["player.width"], userValue("player.width"), "a second look does not replace the snapshot")
check(account.looks.glow, nil, "a preset does not save a glow snapshot")
check(account.looks.light, nil, "a preset does not save a targetLight snapshot")
check(saidHas("Palettes: Hearthnight is on. Your layout is unchanged."), true, "a theme says it is on")
said = {}
ns.looksSlash("")
check(said[#said], HEARTH_LINE, "/looks names the theme and leaves its parts out")
ns.looksSlash("draught")
check(sets.general.buttonGlow, "Neon:custom", "legacy glow name does not change buttonGlow")
check(sets.Nameplates.targetLight, "Neon:target", "legacy glow name does not change targetLight")
check(said[#said], HEARTH_LINE, "a retired glow name reprints the status")
ns.looksSlash("tidemark")
check(palDb.palette, "tide", "tidemark sets the tide palette")
ns.looksSlash("hearthnight")
check(account.themeChanged, false, "picking the theme again clears changed")
looksEnv.SlashCmdList.PALETTES("hearthnight")
check(liveLook(), "beam", "/palettes does not take a theme name")
check(sets.general.buttonGlow, "Neon:custom", "/palettes hearthnight does not change buttonGlow")
said = {}
ns.looksSlash("off")
check(account.theme, false, "a full restore clears the theme")
check(userRestored(), true, "restore writes every saved frame value back")
check(sets.UnitFrames["look.style"], "daylight", "restore does not write look.style")
check(sets.general.buttonGlow, "Neon:custom", "restore without legacy glow snapshot leaves buttonGlow alone")
check(sets.Nameplates.targetLight, "Neon:target", "restore without legacy glow snapshot leaves targetLight alone")
check(account.looks, false, "a successful restore clears the snapshot")
check(saidHas("Palettes: off. Daylight's own colors and frame look are restored."), true, "full restore chat")
sets.general.buttonGlow = "circle"
sets.Nameplates.targetLight = "none"
setBundle("slate")
local left = ns.restoreLooks(true)
check(left, false, "restore with no snapshot does nothing")
check(liveHas("slate"), true, "no snapshot leaves the frame alone")

char.only = false
account.looks = nil
seedFrames()
sets.general.buttonGlow = "circle"
sets.Nameplates.targetLight = "none"
ns.setOnly(account, char, true)
ns.looksSlash("stream")
check(char.looks and char.looks.frameValues and char.looks.frameValues["player.width"], userValue("player.width"), "save for this character keeps the snapshot on the character")
check(type(account.looks) == "table", false, "a character snapshot stays off the account")
ns.setOnly(account, char, false)
check(char.looks, nil, "untick drops the character snapshot")

local imported = { palette = "ember", classAccent = false, seeded = true, looks = { frameValues = { ["player.width"] = 187 }, glow = "circle", light = "none" } }
local importedChar = { only = false, ready = true }
local importedDb = { palette = "tide", classAccent = false, carried = true, looks = { frameValues = { ["player.width"] = 220, ["target.portrait"] = "2d" }, glow = "Looks:wick", light = "Looks:wick" } }
ns.adoptProfile(imported, importedChar, importedDb)
check(imported.looks and imported.looks.frameValues and imported.looks.frameValues["player.width"], 220, "a profile switch adopts the frame snapshot")
check(imported.looks and imported.looks.frameValues and imported.looks.frameValues["target.portrait"], "2d", "a profile switch adopts every saved frame value")
check(imported.looks and imported.looks.glow, "Looks:wick", "a profile switch adopts the glow snapshot")
check(imported.palette, "tide", "a profile switch still adopts the palette")
local legacy = { palette = "ember", classAccent = false, seeded = true, looks = false }
local legacyChar = { only = false, ready = true }
local legacyDb = { palette = "tide", classAccent = false, carried = true, looks = { frame = "Looks:lintel", glow = "Looks:wick", light = "Looks:wick" } }
ns.adoptProfile(legacy, legacyChar, legacyDb)
check(legacy.looks and legacy.looks.frame, nil, "a 0.4.2 snapshot's frame style string is dropped")
check(legacy.looks and legacy.looks.glow, "Looks:wick", "a 0.4.2 snapshot keeps its glow")
local keep = { palette = "tide", classAccent = false, seeded = true, looks = { frameValues = { ["player.width"] = 187 }, glow = "circle", light = "none" } }
local keepChar = { only = false, ready = true }
local keepDb = { palette = "ember", classAccent = false, carried = true }
ns.adoptProfile(keep, keepChar, keepDb)
check(keep.looks and keep.looks.frameValues and keep.looks.frameValues["player.width"], 187, "a profile with no snapshot leaves yours")

seedFrames()
account.looks = nil
resetLogs()
looksEnv.InCombatLockdown = function() return true end
ns.looksSlash("ledger")
check(#unitWrites, 0, "a combat pick does not write yet")
check(said[#said], "Looks: Ledger queued until combat ends.", "a combat pick says it is waiting")
check(ns.looksWaiting(), true, "a combat pick is queued")
looksEnv.InCombatLockdown = function() return false end
ns.finishLooksCombat()
ns.finishQueuedReload(true)
check(liveHas("ledger"), true, "combat end applies the waiting frame")
check(ns.looksWaiting(), false, "combat end empties the queue")

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
check(said[#said], "Palettes: Daylight UI is missing the settings frame looks need, so only colors are available.", "api 1.7 says only colors")
check(themeGroups[1].items[1].hidden(), true, "api 1.7 hides the presets tab")
check(lookGroups[1].items[1].hidden(), true, "api 1.7 hides the looks tab")
check(type(colourGroups[1].items[1].hidden) ~= "function" or colourGroups[1].items[1].hidden() ~= true, true, "api 1.7 still shows colours")
seedFrames()
local paletteGuard = palDb.palette
resetLogs()
ns.looksSlash("lintel")
check(#unitWrites, 0, "api 1.7 /looks does not apply")
ns.looksSlash("hearthnight")
check(#unitWrites, 0, "api 1.7 /looks hearthnight does not apply a theme")
check(palDb.palette, paletteGuard, "api 1.7 /looks hearthnight does not change colours")
check(said[#said], "Palettes: Daylight UI is missing the settings frame looks need, so only colors are available.", "/looks repeats the guard")

ui.API.minor = 9
ns.looksReady = nil
ns.looksGuard = nil
ns.looksBothSaid = nil
styleCalls.frame = 0
looksEnv.C_AddOns = { IsAddOnLoaded = function(name) return name == "Looks" end }
said = {}
ns.bootLooks()
check(styleCalls.frame, 0, "a loaded Looks add-on is not registered twice")
check(said[#said], "Palettes: Looks is also loaded. Turn Looks off; frame looks now live in Palettes.", "both add-ons get one line")
looksEnv.C_AddOns = nil
ns.looksReady = nil
ns.looksGuard = nil
ns.looksBothSaid = nil
ns.bootLooks()
check(styleCalls.frame, 0, "booting again still registers no frame styles")
check(styleCalls.glow, 0, "booting again registers no glow styles")
check(ns.looksReady, true, "booting again leaves looks ready")

-- Leftover Looks: styles from 0.4.2 go back to daylight once, and retired frame names move.
do
    seedFrames()
    sets.UnitFrames["look.style"] = "Looks:lintel"
    account.framesMigrated = nil
    account.frame = "lintel"
    char.frame = "trough"
    account.looks = { frame = "Looks:sill", glow = "circle", light = "none" }
    palDb.frame = "signboard"
    resetLogs()
    ns.migrateFrames()
    check(sets.UnitFrames["look.style"], "daylight", "a leftover Looks: style goes back to daylight")
    check(account.frame, "beam", "a saved lintel becomes beam")
    check(char.frame, "ledger", "a saved trough becomes ledger")
    check(palDb.frame, "beam", "a profile's saved signboard becomes beam")
    check(account.looks.frame, nil, "the old snapshot style string is dropped")
    check(account.looks.glow, "circle", "the old snapshot glow stays")
    check(account.framesMigrated, true, "the migration is marked done")
    check(sentinelsIntact() or sets.UnitFrames["look.style"] == "daylight", true, "migration leaves other settings alone")
    check(#unitWrites, 1, "migration writes one key")
    sets.UnitFrames["look.style"] = "Looks:stamp"
    ns.migrateFrames()
    check(sets.UnitFrames["look.style"], "Looks:stamp", "the migration only runs once")
    account.framesMigrated = nil
    sets.UnitFrames["look.style"] = "ribbon"
    ns.migrateFrames()
    check(sets.UnitFrames["look.style"], "ribbon", "a style that is not Looks: stays")
    check(account.framesMigrated, true, "a clean profile is marked done")
    account.framesMigrated = nil
    sets.UnitFrames["look.style"] = "Looks:sill"
    looksEnv.C_AddOns = { IsAddOnLoaded = function(name) return name == "Looks" end }
    ns.migrateFrames()
    check(sets.UnitFrames["look.style"], "Looks:sill", "the standalone Looks add-on keeps its own styles")
    check(account.framesMigrated, nil, "no migration is marked while Looks is loaded")
    looksEnv.C_AddOns = nil
    sets.UnitFrames["look.style"] = nil
    ns.migrateFrames()
    check(account.framesMigrated, nil, "an unreadable style tries again next login")
    account.framesMigrated = true
    account.frame = false
    char.frame = nil
    palDb.frame = nil
    account.looks = nil
end

local row = piece()
local body = lookGroups[1].items[1]
ui.API.minor = 9
ns.looksReady = true
ns.looksGuard = nil
if type(body) == "table" and type(body.build) == "function" then
    local built, buildErr = pcall(body.build, row)
    if not built then fail("looks tab did not build: " .. tostring(buildErr)) end
    check(type(row.lines) == "table" and #row.lines or 0, 58, "all 8 Looks categories register 58 option cards")
    check(row.lines[1] and row.lines[1].id, "daylight_standard", "frame row 1 is daylight_standard")
    check(row.lines[1] and row.lines[1].kind, "frame", "frame row 1 is a frame")
    for i = 1, #FRAME_IDS do
        local ln = row.lines[i + 1]
        check(ln and ln.id, FRAME_IDS[i], "frame row " .. (i + 1) .. " is " .. FRAME_IDS[i])
        check(ln and ln.kind, "frame", "frame row " .. (i + 1) .. " is a frame")
        check(type(ln.button) == "table" and type(ln.button.scripts.OnClick), "function", "frame row " .. (i + 1) .. " is a button")
    end
    for i = 1, #row.lines do
        if row.lines[i].kind == "glow" then fail("looks tab must have no glow rows") end
    end
    if not looksSource:find('FRAME_HEAD = "Frame looks"', 1, true) then
        fail("looks tab section header must be Frame looks")
    end
    if looksSource:find("GLOW_HEAD", 1, true) or looksSource:find("GLOW_HINT", 1, true) then
        fail("looks tab must have no glow heading or glow hint")
    end
    for i = 1, #frameLines do
        check(row.lines[i + 1].desc.words, frameLines[i], "frame row " .. (i + 1) .. " reads the spec one-liner")
    end
    check(row.lines[3].desc.words, "Slim slanted bar with hung power rail and top name tab to save vertical screen space.", "Trestle ships the spec wording")
    if type(row.UpdateLooks) == "function" then row.UpdateLooks() end
    local active = row.lines[2]
    active.SetOn(true, false)
    check(active.key.shown, false, "the picked row hides its key")
    check(active.check.texture, "Interface\\Buttons\\UI-CheckBox-Check", "the check is the game texture")
    check(active.check.shown, true, "the check is visible")
    check(active.onText.shown, false, "the picked row does not use a font glyph")
    active.SetOn(false, true)
    check(active.key.shown, false, "a waiting row hides its key")
    check(active.onText.words, "PENDING", "a waiting row shows PENDING")
    active.SetOn(false, false)
    check(active.key.shown, false, "style keys stay off the row")
    active.SetHover(true)
    check(active.hover, true, "a hovered row still tracks hover")
    check(active.hoverText, nil, "a hovered row has no HOVER fontstring")
    check(active.onText.words == "HOVER", false, "a hovered row does not say HOVER")
    check(type(active.washColor) == "table", true, "hover still paints the row highlight")
    active.SetHover(false)

    local flagonRow, trestleRow, beamRow = row.lines[2], row.lines[3], row.lines[4]
    local function unitShows(id, unit)
        local n = 0
        for key, value in pairs(ns.frameValues(id)) do
            if string.sub(key, 1, #unit + 1) == unit .. "." or string.sub(key, 1, #unit + 5) == unit .. "Text." then
                n = n + 1
                if sets.UnitFrames[key] ~= value then return false end
            end
        end
        return n > 0
    end
    local function savedAreUser()
        for i = 1, #allKeys do
            if savedValue("UnitFrames", allKeys[i]) ~= userValue(allKeys[i]) then return false, allKeys[i] end
        end
        return true
    end
    local function heldExtras()
        local n = 0
        for i = 1, #held do
            if string.find(held[i].path, "barFx", 1, true) or string.find(held[i].path, "media", 1, true) then n = n + 1 end
        end
        return n
    end
    seedFrames()
    account.looks = nil
    palDb.looks = nil
    resetLogs()
    local looksBefore = account.looks
    flagonRow.button.scripts.OnClick()
    check(savedAreUser(), true, "a row click does not write the saved values")
    check(account.looks, looksBefore, "a row click does not write the snapshot")
    check(type(ns.staged) == "table" and ns.staged.kind, "frame", "a frame click is staged")
    check(unitShows("flagon", "player"), true, "a row click previews on the player frame")
    check(unitShows("flagon", "target"), true, "a row click previews on the target frame")
    check(sets.UnitFrames["player.barFx.health.style"], "flow", "the Flagon preview shows its extras on the player")
    check(sets.UnitFrames["target.media.health"], "daylight", "the Flagon preview shows its extras on the target")
    check(ns.previewShownId(), "flagon", "the preview knows what is showing")
    check(sets.UnitFrames["look.style"], "daylight", "a preview never touches look.style")
    check(sentinelsIntact(), true, "a preview never touches another frame")
    logsStayOnTwoFrames(unitOverrides, "a preview overrides only the player and target keys")
    local outsideBatch = 0
    for i = 1, #unitOverrides do
        if unitOverrides[i].batch == 0 then outsideBatch = outsideBatch + 1 end
    end
    check(outsideBatch, 0, "a preview overrides inside DaylightUI.Batch")
    check(#unitWrites, 0, "a preview writes nothing with Set")
    local previewed = {}
    for i = 1, #unitOverrides do previewed[unitOverrides[i].path] = true end
    local wantPaths = ns.frameValues("flagon")
    local extras = ns.frameExtras()
    local missingPath
    for key in pairs(wantPaths) do if not previewed[key] then missingPath = key end end
    for key in pairs(extras) do if not previewed[key] then missingPath = key end end
    check(missingPath, nil, "the Flagon preview covers every look key, sizes key and extra")
    local flagonMark = #unitOverrides
    beamRow.button.scripts.OnClick()
    check(unitShows("beam", "player"), true, "another row moves the preview on the player frame")
    check(unitShows("beam", "target"), true, "another row moves the preview on the target frame")
    check(heldExtras(), 0, "leaving Flagon in a preview lets go of its extras")
    check(sets.UnitFrames["player.barFx.health.style"], userValue("player.barFx.health.style"), "Beam's preview shows the player's own animation")
    local beamOverrides = 0
    for i = flagonMark + 1, #unitOverrides do
        local o = unitOverrides[i]
        if not o.off and extras[o.path] ~= nil then beamOverrides = beamOverrides + 1 end
    end
    check(beamOverrides, 0, "only the Flagon preview overrides the extras")
    check(savedAreUser(), true, "a second pick still writes nothing")
    beamRow.button.scripts.OnClick()
    check(userRestored(), true, "clicking the previewed row again reverts both frames")
    check(ns.staged, nil, "clicking the previewed row again drops the pick")
    check(#held, 0, "reverting releases every override")
    flagonRow.button.scripts.OnClick()
    ns.setLooksOpen(false)
    check(userRestored(), true, "leaving the Looks tab reverts the frames")
    check(ns.staged, nil, "leaving the Looks tab drops the pick")
    check(#held, 0, "leaving the Looks tab releases the preview")
    check(sentinelsIntact(), true, "reverting leaves other frames alone")
    looksEnv.InCombatLockdown = function() return true end
    flagonRow.button.scripts.OnClick()
    check(userRestored(), true, "a combat click waits to preview")
    looksEnv.InCombatLockdown = function() return false end
    ns.finishLooksCombat()
    check(unitShows("flagon", "player"), true, "combat end shows the waiting preview on the player frame")
    check(unitShows("flagon", "target"), true, "combat end shows the waiting preview on the target frame")
    looksEnv.InCombatLockdown = function() return true end
    ns.setLooksOpen(false)
    check(unitShows("flagon", "player"), true, "leaving in combat keeps the frames until combat ends")
    looksEnv.InCombatLockdown = function() return false end
    ns.finishLooksCombat()
    check(userRestored(), true, "combat end reverts the preview")
    check(#held, 0, "combat end releases the preview")
    local backendCalls = {}
    ns.SetPreviewBackend({
        apply = function(id, targets) backendCalls[#backendCalls + 1] = "apply:" .. id .. ":" .. table.concat(targets, ","); return {} end,
        revert = function() backendCalls[#backendCalls + 1] = "revert" end,
    }, { "player", "target" })
    flagonRow.button.scripts.OnClick()
    check(backendCalls[1], "apply:flagon:player,target", "a backend gets the look and the frames")
    ns.setLooksOpen(false)
    check(backendCalls[2], "revert", "a backend is told to revert")
    ns.SetPreviewBackend(nil)
    ns.SetPreviewBackend(nil, { "target" })
    resetLogs()
    flagonRow.button.scripts.OnClick()
    local sawPlayer = false
    for i = 1, #unitOverrides do
        local unit = unitOf(unitOverrides[i].path)
        if unit == "player" or unit == "playerText" then sawPlayer = true end
    end
    check(sawPlayer, false, "a preview limited to the target leaves the player frame alone")
    check(unitShows("flagon", "target"), true, "a preview limited to the target shows on it")
    ns.setLooksOpen(false)
    ns.SetPreviewBackend(nil, { "player", "target" })
    ns.setLooksOpen(true)

    looksEnv.StaticPopupDialogs = {}
    looksEnv.StaticPopup_Show = function(which) said[#said + 1] = "popup:" .. which end
    flagonRow.button.scripts.OnClick()
    local popupsBefore = popupCount()
    resetLogs()
    local committed = ns.commitStaged()
    check(committed, true, "apply commits the staged pick")
    check(liveHas("flagon"), true, "apply writes the Flagon bundle")
    check(sets.UnitFrames["player.barFx.health.style"], "flow", "apply writes the Flagon bar animation")
    check(sets.UnitFrames["target.media.power"], "daylight", "apply writes the Flagon textures")
    check(sets.UnitFrames["look.style"], "daylight", "apply never writes look.style")
    check(sentinelsIntact(), true, "apply leaves other frames alone")
    check(batches.outside, 0, "apply writes inside DaylightUI.Batch")
    check(popupCount(), popupsBefore, "applying a frame look does not ask to reload")
    check(#held, 0, "apply releases the preview")
    check(unitShows("flagon", "target"), true, "apply keeps the look on the target frame")
    check(account.looks.frameValues["player.width"], userValue("player.width"), "apply saves the player's values, not the preview")
    check(account.looks.frameValues["player.barFx.health.style"], userValue("player.barFx.health.style"), "apply saves the animation before Flagon changes it")
    check(liveLook(), "flagon", "Flagon shows as the worn look")
    -- Leaving Flagon puts back what Flagon wrote, and keeps what the player changed since.
    sets.UnitFrames["player.media.health"] = "mine"
    beamRow.button.scripts.OnClick()
    check(unitShows("beam", "player"), true, "Beam previews over Flagon")
    check(sets.UnitFrames["player.barFx.health.style"], "flow", "a Beam preview leaves the extras to Apply")
    check(#held > 0, true, "the Beam preview is held")
    for i = 1, #held do
        if extraValues[held[i].path] ~= nil then fail("a Beam preview must not override " .. held[i].path) end
    end
    ns.commitStaged()
    check(liveHas("beam"), true, "Beam replaces Flagon")
    for _, key in ipairs(extraKeys) do
        if key == "player.media.health" then
            check(sets.UnitFrames[key], "mine", "a texture the player changed on Flagon stays theirs")
        else
            check(sets.UnitFrames[key], userValue(key), "leaving Flagon puts back " .. key)
        end
    end
    check(popupCount(), popupsBefore, "leaving Flagon does not ask to reload")
    sets.UnitFrames["player.media.health"] = userValue("player.media.health")
    trestleRow.button.scripts.OnClick()
    looksEnv.InCombatLockdown = function() return true end
    ns.commitStaged()
    check(#held > 0, true, "a combat apply leaves the preview up until combat ends")
    check(ns.looksWaiting(), true, "a combat apply is queued")
    check(liveHas("beam") or savedValue("UnitFrames", "player.width") == widths.beam, true, "a combat apply does not write the saved values yet")
    looksEnv.InCombatLockdown = function() return false end
    ns.finishLooksCombat()
    check(#held, 0, "combat end releases the preview before the apply")
    check(liveHas("trestle"), true, "combat end writes the applied frame")
    check(popupCount(), popupsBefore, "a combat frame apply never asks to reload")
    ns.finishQueuedReload(true)
    check(popupCount(), popupsBefore, "a combat frame apply still does not ask once combat ends")
    ns.looksSlash("lintel")
    check(liveHas("beam"), true, "the slash command still writes, and lintel is Beam")
    ns.looksSlash("trough")
    check(liveHas("ledger"), true, "trough is Ledger")
    ns.looksSlash("sill")
    check(liveHas("stream"), true, "sill is Stream")
    ns.looksSlash("stamp")
    check(liveHas("slate"), true, "stamp is Slate")
    ns.looksSlash("signboard")
    check(liveHas("beam"), true, "signboard is Beam")
    ns.looksSlash("crest")
    check(liveHas("crest"), true, "/looks crest applies Crest")
    check(sets.UnitFrames["player.portraitDragon"], true, "Crest turns the player dragon on")
    ns.looksSlash("slate")
    check(sets.UnitFrames["player.portraitDragon"], false, "leaving Crest turns the dragon off")
    check(sets.UnitFrames["target.levelPos"], "foot", "leaving Crest puts the level badge back at the foot")

    -- Reset Looks puts back every saved value, including the Flagon extras.
    account.looks = nil
    palDb.looks = nil
    seedFrames()
    ns.looksSlash("flagon")
    check(sets.UnitFrames["player.barFx.health.style"], "flow", "Flagon turns Flow on")
    ns.looksSlash("ledger")
    ns.looksSlash("flagon")
    local resetPopups = popupCount()
    local resetBatches = batches.runs
    resetLogs()
    check(type(ns.runTabReset), "function", "the tab reset can be run")
    ns.runTabReset("Looks")
    check(userRestored(), true, "Reset Looks puts back every saved value")
    check(sets.UnitFrames["player.barFx.health.style"], userValue("player.barFx.health.style"), "Reset Looks does not leave Flow on")
    check(sets.UnitFrames["look.style"], "daylight", "Reset Looks never writes look.style")
    check(sentinelsIntact(), true, "Reset Looks leaves other frames alone")
    check(account.looks, false, "Reset Looks clears the snapshot")
    check(popupCount(), resetPopups, "Reset Looks does not ask to reload when only frames or glows changed")
    resetLogs()
    ns.runTabReset("Looks")
    check(#unitWrites, 0, "Reset Looks with no snapshot changes nothing")
    check(popupCount(), resetPopups, "Reset Looks with no snapshot does not ask to reload")

    -- 1-step undo of a frame look.
    seedFrames()
    account.looks = nil
    local before = ns.captureUndo("frame")
    ns.looksSlash("flagon")
    ns.applyUndoShot(before)
    check(userRestored(), true, "undo puts the previous frame values and extras back")
    check(sets.UnitFrames["look.style"], "daylight", "undo never writes look.style")
    account.looks = nil
    palDb.looks = nil
    seedFrames()
    sets.general.buttonGlow = "circle"
    sets.Nameplates.targetLight = "none"
    ns.looksSlash("beam")

    -- Apply asks to reload for a Preset, and a Preset applies its frame look.
    local themeRowForReload = piece()
    local themeBodyForReload = themeGroups[1].items[1]
    pcall(themeBodyForReload.build, themeRowForReload)
    seedFrames()
    account.looks = nil
    account.theme = false
    palDb.palette = "tide"
    local presetPopups = popupCount()
    themeRowForReload.lines[6].button.scripts.OnClick()
    check(type(ns.staged) == "table" and ns.staged.kind, "theme", "a preset click is staged")
    ns.commitStaged()
    check(liveHas("flagon"), true, "Snug applies the Flagon bundle")
    check(palDb.palette, "gilded", "Snug applies its palette")
    check(popupCount(), presetPopups + 1, "a Preset commit still asks to reload")
    palDb.palette = "tide"
    local colourPopups = popupCount()
    if type(ns.stagePick) == "function" then
        ns.stagePick("palette", "dusk", function() ui:Set("Palettes", "palette", "dusk") end, false)
        ns.commitStaged()
        check(popupCount(), colourPopups + 1, "a Colours commit still asks to reload")
    end
    local lookPopups = popupCount()
    ns.stagePick("frame", "slate", function() end, false)
    ns.commitStaged()
    check(popupCount(), lookPopups, "a Looks-only commit never asks to reload")
    row.lines[1].button.scripts.OnClick()
    ns.setLooksOpen(false)
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
else
    fail("looks tab has no body")
end
local themeRow = piece()
local themeBody = themeGroups[1].items[1]
if type(themeBody) == "table" and type(themeBody.build) == "function" then
    local builtTheme, themeErr = pcall(themeBody.build, themeRow)
    if not builtTheme then fail("themes tab did not build: " .. tostring(themeErr)) end
    check(type(themeRow.lines) == "table" and #themeRow.lines or 0, 10, "ten core theme rows")
    local hearth = themeRow.lines[1]
    local lastTheme = themeRow.lines[6]
    check(hearth.baseName, "Hearthnight", "theme order still starts with Hearthnight")
    check(lastTheme.baseName, "Snug", "theme order ends with Snug")
    check(hearth.palettePill and hearth.palettePill.words, "Ember", "hearthnight's palette pill")
    check(hearth.lookPill and hearth.lookPill.words, "Beam", "hearthnight's frame pill")
    check(lastTheme.palettePill and lastTheme.palettePill.words, "Gilded", "snug's palette pill")
    check(lastTheme.lookPill and lastTheme.lookPill.words, "Flagon", "snug's frame pill")
    local pills = {
        { "Hearthnight", "Ember", "Beam" }, { "Harvestide", "Vanilla", "Stream" },
        { "Tidemark", "Tide", "Slate" }, { "Old Road", "Forever", "Crest" },
        { "Vigil", "Paladin", "Stream" }, { "Snug", "Gilded", "Flagon" },
    }
    for i = 1, #pills do
        local line = themeRow.lines[i]
        check(line.baseName, pills[i][1], "preset " .. i .. " name")
        check(line.palettePill.words, pills[i][2], pills[i][1] .. " palette pill")
        check(line.lookPill.words, pills[i][3], pills[i][1] .. " frame pill")
    end
    local crestUsed = false
    for i = 1, #ns.themes do if ns.themes[i].frame == "crest" then crestUsed = true end end
    check(crestUsed, true, "Old Road showcases Crest on the Presets tab")
    for i = 1, #ns.themes do
        check(ns.frameById(ns.themes[i].frame) ~= nil, true, ns.themes[i].id .. " names one of the seven looks")
    end
    check(hearth.mood, "Warm ember frames and fiery casts for high-focus combat.", "hearthnight uses its new mood")
    check(type(hearth.preview) == "table" and #hearth.preview or 0, 3, "a theme row shows three swatches")
    check(hearth.preview[1], ns.byId.ember.background, "the first swatch is the palette background")
    check(hearth.preview[2], ns.byId.ember.band, "the second swatch is the band")
    check(hearth.preview[3], ns.byId.ember.c2, "the third swatch is the accent")
    check(row.lines[1].palettePill, nil, "a frame row has no pills")
    account.theme = "hearthnight"
    account.themeChanged = true
    palDb.palette = "tide"
    if type(themeRow.UpdateLooks) == "function" then themeRow.UpdateLooks() end
    check(themeRow.recipeTitle and themeRow.recipeTitle.words, "Custom (based on Hearthnight)", "a changed theme updates the recipe title")
    check(hearth.palettePill.words, "Ember", "changed leaves the palette pill")
    check(hearth.lookPill.words, "Beam", "changed leaves the frame pill")
    hearth.SetOn(true, false)
    local cream = { 0.95, 0.91, 0.86 }
    local dim = { 0.62, 0.56, 0.48 }
    local function near(a, b)
        return type(a) == "table" and type(b) == "table"
            and math.abs(a[1] - b[1]) < 0.002
            and math.abs(a[2] - b[2]) < 0.002
            and math.abs(a[3] - b[3]) < 0.002
    end
    local function washOf(id)
        local p = ns.byId[id]
        return ns.accentWash(p.c2, p.window, { p.title, p.text, cream })
    end
    local emberWash, emberInk, emberRatio = washOf("ember")
    local phosphorWash, phosphorInk, phosphorRatio = washOf("phosphor")
    local inkWash, inkInk, inkRatio = washOf("ink")
    check(ns.contrastRatio(cream, ns.byId.ember.c2) < 2, true, "raw Ember accent fails the name")
    check(ns.contrastRatio(dim, ns.byId.ember.c2) < 2, true, "raw Ember accent fails the description")
    check(emberRatio >= 4.5, true, "Ember wash clears 4.5")
    check(phosphorRatio >= 4.5, true, "Phosphor wash clears 4.5")
    check(inkRatio >= 4.5, true, "Ink wash clears 4.5")
    check(near(hearth.washColor, emberWash), true, "a picked preset uses the darkened accent wash")
    check(near(hearth.name.ink, emberInk), true, "the picked name uses the light ink")
    check(near(hearth.desc.ink, emberInk), true, "the picked mood uses the light ink")
    check(near(hearth.check.vertex, emberInk), true, "the check is tinted to the light ink")
    check(hearth.cue.shown, true, "a picked preset keeps an accent edge")
    check(near(hearth.cue.color, ns.byId.ember.c2), true, "the accent edge is raw c2")
    check(ns.contrastRatio(phosphorInk, phosphorWash) >= 4.5, true, "Phosphor ink clears its wash")
    check(ns.contrastRatio(inkInk, inkWash) >= 4.5, true, "Ink ink clears its wash")
    palDb.palette = "phosphor"
    row.lines[1].SetOn(true, false)
    check(near(row.lines[1].washColor, phosphorWash), true, "a picked look uses the screen palette wash")
    check(near(row.lines[1].name.ink, phosphorInk), true, "a picked look uses the light ink")
    palDb.palette = "ink"
    row.lines[1].SetOn(true, false)
    check(near(row.lines[1].washColor, inkWash), true, "Ink darkens a picked look")
    palDb.palette = "tide"
else
    fail("themes tab has no body")
end

seedFrames()
sets.general.buttonGlow = "Neon:custom"
sets.Nameplates.targetLight = "Neon:target"
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
check(liveHas("beam"), true, "Restore colours leaves the frame")
check(sets.general.buttonGlow, "Neon:custom", "Restore colours leaves existing buttonGlow alone")
check(sets.Nameplates.targetLight, "Neon:target", "Restore colours leaves existing targetLight alone")
check(account.theme, "hearthnight", "Restore colours keeps the theme name")
check(account.themeChanged, true, "Restore colours marks the theme changed")

local function userSnapshot()
    local values = {}
    for i = 1, #allKeys do values[allKeys[i]] = userValue(allKeys[i]) end
    return { frameValues = values, glow = "circle", light = "none" }
end
account.themeChanged = false
palDb.palette = "ember"
setBundle("beam")
sets.general.buttonGlow = "Looks:wick"
sets.Nameplates.targetLight = "Looks:wick"
account.looks = userSnapshot()
palDb.looks = account.looks
local looksButton = resetNamed("Looks")
if type(looksButton) ~= "table" or type(looksButton.run) ~= "function" then
    fail("looks reset did not build")
else
    looksButton.run()
end
check(palDb.palette, "ember", "Restore looks leaves the palette")
check(userRestored(), true, "Restore looks puts the saved frame values back")
check(sets.general.buttonGlow, "circle", "Restore looks puts the legacy saved glow back")
check(sets.Nameplates.targetLight, "none", "Restore looks puts the legacy saved targetLight back")
check(account.theme, "hearthnight", "Restore looks keeps the theme name")
check(account.themeChanged, true, "Restore looks marks the theme changed")

setBundle("stream")
sets.general.buttonGlow = "Neon:custom"
sets.Nameplates.targetLight = "Neon:target"
account.looks = nil
palDb.looks = nil
account.theme = "hearthnight"
account.themeChanged = false
palDb.palette = "ember"
looksButton.run()
check(liveHas("stream"), true, "Restore looks with no snapshot leaves the frame")
check(sets.general.buttonGlow, "Neon:custom", "Restore looks with no snapshot leaves buttonGlow")
check(sets.Nameplates.targetLight, "Neon:target", "Restore looks with no snapshot leaves targetLight")
check(palDb.palette, "ember", "Restore looks with no snapshot leaves the palette")
check(account.theme, "hearthnight", "Restore looks with no snapshot keeps the theme")
check(account.themeChanged, false, "Restore looks with no snapshot does not mark the theme changed")

-- A snapshot with only frame values leaves the glow alone, and a legacy glow snapshot restores it.
seedFrames()
setBundle("slate")
sets.general.buttonGlow = "Neon:custom"
sets.Nameplates.targetLight = "Neon:target"
account.looks = { frameValues = userSnapshot().frameValues }
palDb.looks = account.looks
looksButton.run()
check(userRestored(), true, "a frame-only snapshot restores the frame")
check(sets.general.buttonGlow, "Neon:custom", "a frame-only snapshot leaves buttonGlow")
check(sets.Nameplates.targetLight, "Neon:target", "a frame-only snapshot leaves targetLight")
setBundle("slate")
sets.general.buttonGlow = "Looks:wick"
sets.Nameplates.targetLight = "Looks:wick"
account.looks = { glow = "circle", light = "none" }
palDb.looks = account.looks
looksButton.run()
check(liveHas("slate"), true, "a legacy glow-only snapshot leaves the frame")
check(sets.general.buttonGlow, "circle", "a legacy glow-only snapshot restores buttonGlow")
check(sets.Nameplates.targetLight, "none", "a legacy glow-only snapshot restores targetLight")

palDb.palette = "ember"
setBundle("beam")
sets.general.buttonGlow = "Looks:wick"
sets.Nameplates.targetLight = "Looks:wick"
account.looks = userSnapshot()
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
check(userRestored(), true, "Restore Daylight puts the saved frame values back")
check(sets.general.buttonGlow, "circle", "Restore Daylight restores legacy saved buttonGlow")
check(sets.Nameplates.targetLight, "none", "Restore Daylight restores legacy saved targetLight")
check(account.theme, false, "Restore Daylight clears the theme")

local retired = { lintel = "beam", sill = "stream", stamp = "slate", signboard = "beam", trough = "ledger" }
for old, new in pairs(retired) do
    local plain = ns.parseShare("PAL2-ember-" .. old .. "-wick")
    check(plain and plain.frame, new, "PAL2 legacy code decodes " .. old .. " as " .. new)
    local modern = ns.parseShare("PAL2-ember-" .. old)
    check(modern and modern.frame, new, "PAL2 decodes " .. old .. " as " .. new)
    local themed = ns.parseShare("PAL2-hearthnight-ember-" .. old .. "-wick")
    check(themed and themed.frame, new, "a themed PAL2 decodes " .. old .. " as " .. new)
    local custom = ns.parseShare("PAL2-C-1A1410-C4A574-" .. old .. "-wick")
    check(custom and custom.frame, new, "PAL2-C decodes " .. old .. " as " .. new)
    check(ns.pal2Code({ palette = "ember", frame = old }), "PAL2-ember-" .. new, "PAL2 never emits " .. old)
end
for _, id in ipairs(FRAME_IDS) do
    local parsed = ns.parseShare("PAL2-tide-" .. id)
    check(parsed and parsed.frame, id, "PAL2 decodes " .. id)
    check(ns.pal2Code(parsed), "PAL2-tide-" .. id, "PAL2 emits " .. id)
end
check(ns.parseShare("PAL2-tide-CREST") and ns.parseShare("PAL2-tide-CREST").frame, "crest", "PAL2 ignores case on the new ids")
for _, id in ipairs(FRAME_IDS) do
    seedFrames()
    setBundle(id)
    palDb.palette = "ash"
    account.theme = false
    local code = ns.currentPal2()
    check(code, "PAL2-ash-" .. id, "Copy emits " .. id)
end
do
    seedFrames()
    setBundle("beam")
    palDb.palette = "ember"
    account.theme = false
    check(ns.currentPal2(), "PAL2-hearthnight-ember-beam", "Copy emits preset name when palette and frame match")
end
do
    seedFrames()
    palDb.palette = "ember"
    check(ns.currentPal2(), "PAL2-ember-daylight", "Copy emits daylight when no look is worn")
    for _, old in ipairs({ "lintel", "sill", "stamp", "signboard", "trough" }) do
        check(string.find(ns.currentPal2(), old, 1, true), nil, "Copy never emits " .. old)
    end
end
local round = ns.parseShare("PAL2-hearthnight-ember-lintel-wick")
check(round and round.theme, "hearthnight", "PAL2 keeps the theme")
check(round and round.palette, "ember", "PAL2 keeps the palette")
check(round and round.frame, "beam", "PAL2 turns lintel into beam")
check(ns.pal2Code(round), "PAL2-hearthnight-ember-beam", "PAL2 drops legacy glow on round-trip")
local drifted = ns.parseShare("PAL2-HEARTHNIGHT-EMBER-LINTEL")
check(drifted and drifted.frame, "beam", "PAL2 ignores case")
check(ns.pal2Code({ theme = "hearthnight", palette = "ember", frame = "beam" }), "PAL2-hearthnight-ember-beam", "a changed theme keeps its name in the code")
local parts = ns.parseShare("PAL2-ember-lintel")
check(parts and parts.theme, nil, "PAL2 without a theme has no theme name")
check(ns.pal2Code(parts), "PAL2-ember-beam", "PAL2 parts round-trip")
local onlyPalette = ns.parseShare("PAL2-ember-none")
check(onlyPalette and onlyPalette.frame, "none", "PAL2 none leaves the frame unset")
local customCode = ns.parseShare("PAL2-#C-#1A1410-#C4A574-sill-wick")
check(customCode and customCode.custom, true, "PAL2-C is custom colors")
check(customCode and customCode.frame, "stream", "PAL2-C turns sill into stream")
check(ns.pal2Code({ custom = true, base = "1A1410", accent = "C4A574", frame = "stream" }), "PAL2-C-1A1410-C4A574-stream", "PAL2-C round-trips")
local customOnly = ns.applyShareCode("PAL2-C-1A1410-C4A574-none")
check(type(customOnly) == "table", true, "PAL2-C loads a custom draft")
check(ns.shareLook, nil, "PAL2-C with none does not queue a frame")
local queued = ns.applyShareCode("PAL2-C-341529-E2B14A-sill-wick")
check(type(queued) == "table", true, "PAL2-C with a look loads the draft")
check(ns.shareLook and ns.shareLook.frame, "stream", "PAL2-C holds the frame until Save")
check(ns.shareLook and ns.shareLook.glow, nil, "PAL2-C ignores legacy glow")
ns.shareLook = nil
local pal1 = ns.applyShareCode("PAL1-341529-E2B14A")
check(ns.shareCode(pal1), "PAL1-341529-E2B14A", "PAL1 still imports colors only")
check(ns.shareLook, nil, "PAL1 does not queue a frame")
check(ns.parseShare("PAL2-nope-ember-lintel"), nil, "a bad PAL2 is rejected")
seedFrames()
sets.general.buttonGlow = "Neon:custom"
sets.Nameplates.targetLight = "Neon:target"
palDb.palette = "tide"
account.theme = false
account.looks = nil
said = {}
resetLogs()
check(ns.applyLiveShare(ns.parseShare("PAL2-hearthnight-ember-lintel-wick")), true, "a PAL2 theme applies")
check(palDb.palette, "ember", "PAL2 theme sets the palette")
check(liveHas("beam"), true, "PAL2 theme sets the frame")
logsStayOnTwoFrames(unitWrites, "a PAL2 look writes only the player and target keys")
check(sets.UnitFrames["look.style"], "daylight", "a PAL2 look never writes look.style")
check(sets.general.buttonGlow, "Neon:custom", "PAL2 theme leaves buttonGlow untouched")
check(sets.Nameplates.targetLight, "Neon:target", "PAL2 theme leaves targetLight untouched")
check(account.theme, "hearthnight", "PAL2 theme marks the theme on")
check(account.themeChanged, false, "an exact PAL2 theme is not changed")
check(ns.applyLiveShare(ns.parseShare("PAL2-tide-none")), true, "a palette-only PAL2 applies")
check(palDb.palette, "tide", "a palette-only PAL2 changes colours")
check(liveHas("beam"), true, "PAL2 none leaves the frame alone")
check(account.theme, false, "a PAL2 with no theme name drops a theme the parts do not match")
check(ns.applyLiveShare(ns.parseShare("PAL2-tide-crest")), true, "a PAL2 with Crest applies")
check(liveHas("crest"), true, "PAL2 applies Crest")
check(ns.applyLiveShare(ns.parseShare("PAL2-tide-daylight")), true, "a PAL2 with daylight applies")
check(userRestored(), true, "a PAL2 daylight frame puts the saved frame values back")

seedFrames()
setBundle("beam")
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
setBundle("stream")
account.theme = "hearthnight"
account.themeChanged = true
resetLogs()
ns.applyUndoShot(shot)
check(liveHas("beam"), true, "undo of a theme puts the frame back")
check(sets.UnitFrames["look.style"], "daylight", "undo does not write look.style")
logsStayOnTwoFrames(unitWrites, "undo writes only the player and target keys")
check(sets.general.buttonGlow, "Neon:custom", "undo of a theme leaves buttonGlow alone")
check(account.themeChanged, false, "undo of a theme clears changed when the parts match")

local bare = { palette = "tide", classAccent = false, seeded = true, theme = "vigil" }
local bareChar = { only = false, ready = true }
local bareDb = { palette = "ember", classAccent = false, carried = true }
ns.adoptProfile(bare, bareChar, bareDb)
check(bare.theme, "vigil", "a profile with no theme keys leaves the theme")
seedFrames()
local brought = { palette = "tide", classAccent = false, seeded = true, glow = "wick" }
local broughtChar = { only = false, ready = true, glow = "draught" }
local broughtDb = {
    palette = "vanilla", classAccent = false, carried = true,
    theme = "harvestide", themeChanged = false, frame = "sill", glow = "draught",
}
ns.adoptProfile(brought, broughtChar, broughtDb)
check(brought.theme, "harvestide", "a profile theme is adopted")
check(brought.frame, "stream", "a retired profile frame is carried as its replacement")
check(brought.glow, nil, "adopting drops account glow savedvar")
check(broughtChar.glow, nil, "adopting drops char glow savedvar")
check(broughtDb.glow, nil, "adopting drops profile glow savedvar")
check(liveHas("stream"), false, "adopting a profile does not write its frame")
check(sets.UnitFrames["look.style"], "daylight", "a profile frame never writes look.style")
seedFrames()
ns.looksSlash("stream")
check(liveHas("stream"), true, "picking a frame look applies its values at once")
sets.UnitFrames["player.width"] = 321
local keptDb = { palette = "vanilla", classAccent = false, carried = true, frame = "stream", glow = "draught" }
local keptAccount = { palette = "tide", classAccent = false, seeded = true, frame = "stream", glow = "draught" }
ns.adoptProfile(keptAccount, { only = false, ready = true }, keptDb)
check(sets.UnitFrames["player.width"], 321, "a later width edit survives adopting the same frame")
check(keptAccount.frame, "stream", "adopting keeps the frame id for the Looks tab")
check(keptAccount.glow, nil, "adopting clears legacy account glow")
check(keptDb.glow, nil, "adopting clears legacy profile glow")
check(sets.UnitFrames["look.style"], "daylight", "adopting never writes look.style")
local unknownTheme = { palette = "ember", classAccent = false, seeded = true, theme = "snug", frame = "flagon", glow = "latch" }
local unknownChar = { only = false, ready = true }
local unknownDb = { palette = "not-a-palette", classAccent = false, carried = true, theme = "bellows", frame = "trestle", glow = "wick" }
ns.adoptProfile(unknownTheme, unknownChar, unknownDb)
check(unknownTheme.palette, "ember", "an unknown profile palette still falls back to ember")
check(unknownTheme.theme, "snug", "an unknown profile palette does not apply its theme")
check(unknownTheme.frame, "flagon", "an unknown profile palette does not apply its frame")
check(unknownTheme.glow, nil, "an unknown profile palette still drops account glow")

looksEnv.StaticPopupDialogs = looksEnv.StaticPopupDialogs or {}
if type(looksEnv.StaticPopup_Show) ~= "function" then
    looksEnv.StaticPopup_Show = function(which) said[#said + 1] = "popup:" .. which end
end
if type(ui.module) == "table" and type(ui.module.OnEnable) == "function" then
    ui.module.OnEnable(nil, palDb)
    local frameBefore = palDb.frame
    seedFrames()
    palDb.frame, palDb.glow = "stream", "draught"
    account.glow = "wick"
    char.glow = "latch"
    sets.UnitFrames["player.width"] = 654
    sets.general.buttonGlow = "Neon:edited"
    sets.Nameplates.targetLight = "Neon:target"
    ui.module.OnEnable(nil, palDb)
    check(sets.UnitFrames["player.width"], 654, "a reload with the same saved frame keeps a later width edit")
    check(sets.general.buttonGlow, "Neon:edited", "a reload keeps existing buttonGlow untouched")
    check(sets.Nameplates.targetLight, "Neon:target", "a reload keeps existing targetLight untouched")
    check(account.glow, nil, "reload drops PalettesAccount.glow")
    check(char.glow, nil, "reload drops PalettesChar.glow")
    check(palDb.glow, nil, "reload drops profile glow")
    check(liveHas("stream"), false, "a reload does not write the saved frame")
    palDb.frame = frameBefore
end
seedFrames()
local quiet = popupCount()
ns.looksSlash("")
check(popupCount(), quiet, "a blank /looks does not ask to reload")
ns.looksSlash("nope")
check(popupCount(), quiet, "an unknown /looks does not ask to reload")
ns.looksSlash("lintel")
check(liveHas("beam"), true, "/looks lintel still applies Beam")
check(popupCount(), quiet, "/looks <frame> does not ask to reload")
ns.looksSlash("flagon")
check(liveHas("flagon"), true, "/looks flagon applies Flagon")
check(popupCount(), quiet, "/looks flagon does not ask to reload")
sets.general.buttonGlow = "Neon:edited"
sets.Nameplates.targetLight = "Neon:target"
ns.looksSlash("wick")
check(sets.general.buttonGlow, "Neon:edited", "/looks wick no longer touches buttonGlow")
check(sets.Nameplates.targetLight, "Neon:target", "/looks wick no longer touches targetLight")
check(popupCount(), quiet, "/looks <retired glow> does not ask to reload")
looksEnv.SlashCmdList.PALETTES("")
check(popupCount(), quiet, "a blank /palettes does not ask to reload")
looksEnv.SlashCmdList.PALETTES("dusk")
check(palDb.palette, "dusk", "/palettes dusk writes the palette")
check(popupCount(), quiet + 1, "/palettes dusk asks to reload once")
looksEnv.SlashCmdList.PALETTES("dusk")
check(popupCount(), quiet + 1, "repeating /palettes dusk does not ask again")
do
    local group = ui.API.For("Palettes").optionsGroups
    group = type(group) == "table" and group.appearance or nil
    check(type(group), "table", "the Appearance options group is added")
    group = type(group) == "table" and group or { items = {} }
    local dropdown, text
    for i = 1, #group.items do
        local item = group.items[i]
        if item.type == "dropdown" then dropdown = item end
        if item.type == "text" then text = item end
    end
    dropdown = dropdown or {}
    text = text or {}
    check(group.label, "Colours", "the Appearance group label says Colours")
    check(group.desc, "Synced with Plugins > Palettes > Colours. Changing Accent or Window tint below switches it off.", "the Appearance desc says switches it off")
    check(dropdown.label, "Colours", "the Appearance dropdown label says Colours")
    check(dropdown.key, "palette", "the Appearance dropdown keeps the palette key")
    check(text.label, "Editing Accent or Window tint switches Palettes colours off. Class and combat colors stay Daylight's.", "the Appearance text row says switches Palettes colours off")
end
ui:Set("Palettes", "palette", "ash")
check(palDb.palette, "ash", "an Appearance pick writes the palette")
check(popupCount(), quiet + 2, "an Appearance palette pick asks to reload once")
ui:Set("Palettes", "palette", "ash")
check(popupCount(), quiet + 2, "the same Appearance pick does not ask again")
ns.looksSlash("hearthnight")
check(popupCount(), quiet + 3, "/looks <preset> asks to reload once")
ns.looksSlash("hearthnight")
check(popupCount(), quiet + 3, "repeating /looks <preset> does not ask again")
ns.looksSlash("flagon")
ns.looksSlash("hearthnight")
check(palDb.palette, "ember", "the preset's palette is already on")
check(liveHas("beam"), true, "/looks <preset> puts the preset's frame back")
check(popupCount(), quiet + 4, "/looks <preset> asks even when only its frame changes")
looksEnv.InCombatLockdown = function() return true end
ns.looksSlash("sill")
check(popupCount(), quiet + 4, "a combat /looks <frame> waits")
looksEnv.InCombatLockdown = function() return false end
ns.finishLooksCombat()
ns.finishQueuedReload(true)
check(liveHas("stream"), true, "combat end paints the slash frame")
check(popupCount(), quiet + 4, "a combat /looks <frame> never asks to reload")

char.only = false
char.looks = nil
seedFrames()
setBundle("stream")
sets.general.buttonGlow = "Looks:wick"
sets.Nameplates.targetLight = "Looks:wick"
account.looks = userSnapshot()
if palDb.palette ~= "off" then ns.restoreColoursOnly() end
check(palDb.palette, "off", "colours are already off before /palettes off")
check(liveHas("stream"), true, "Reset Colours leaves the frame")
local offBase = popupCount()
looksEnv.SlashCmdList.PALETTES("off")
check(userRestored(), true, "/palettes off restores the saved frame values")
check(sets.general.buttonGlow, "circle", "/palettes off restores the legacy saved glow")
check(sets.Nameplates.targetLight, "none", "/palettes off restores the legacy saved targetLight")
check(popupCount(), offBase + 1, "/palettes off asks to reload when it restores Looks")
looksEnv.SlashCmdList.PALETTES("off")
check(popupCount(), offBase + 1, "a no-op /palettes off does not ask again")
setBundle("stream")
sets.general.buttonGlow = "Looks:wick"
sets.Nameplates.targetLight = "Looks:wick"
account.looks = userSnapshot()
local looksOff = popupCount()
ns.looksSlash("off")
check(popupCount(), looksOff + 1, "/looks off asks to reload when it restores Looks")
ns.looksSlash("off")
check(popupCount(), looksOff + 1, "a no-op /looks off does not ask again")

if main:find('"HOVER"', 1, true) or looksSource:find('"HOVER"', 1, true) then
    fail("HOVER is still written as text")
end
do
    local frame = { scripts = {} }
    function frame:SetScript(name, fn) self.scripts[name] = fn end
    function frame:GetScript(name) return self.scripts[name] end
    local scroll = { points = {}, level = 4, strata = "MEDIUM" }
    function scroll:GetNumPoints() return #self.points end
    function scroll:GetPoint(i)
        local p = self.points[i]
        return p[1], p[2], p[3], p[4], p[5]
    end
    function scroll:ClearAllPoints() self.points = {} end
    function scroll:SetPoint(point, rel, relPoint, x, y)
        self.points[#self.points + 1] = { point, rel, relPoint, x, y }
    end
    function scroll:GetFrameLevel() return self.level end
    function scroll:GetFrameStrata() return self.strata end
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 40, -90)
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 22)
    local page = {}
    function page:GetParent() return scroll end
    local panel = {
        Current = function() return "Palettes.main" end,
        Frame = function() return frame end,
        PageFrame = function(id) return id == "Palettes.main" and page or nil end,
    }
    frame:SetScript("OnSizeChanged", function()
        scroll:ClearAllPoints()
        scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 40, -90)
        scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 22)
    end)
    local reserve = ns.liftPageScroll(panel)
    check(reserve, ns.footerReserve(), "the scroll keeps a footer gap")
    local bottom
    for i = 1, #scroll.points do
        if scroll.points[i][1] == "BOTTOMRIGHT" then bottom = scroll.points[i] end
    end
    check(type(bottom) == "table" and bottom[2] == frame, true, "the scroll bottom stays on the window")
    check(type(bottom) == "table" and bottom[4], -28, "the scroll keeps its right inset")
    local above = type(bottom) == "table" and type(bottom[5]) == "number" and bottom[5] > 22
    check(above, true, "the content bottom sits above the footer")
    check(type(bottom) == "table" and bottom[5], reserve, "the gap is the footer height plus its inset")
    frame.scripts.OnSizeChanged(frame, 900, 600)
    bottom = nil
    for i = 1, #scroll.points do
        if scroll.points[i][1] == "BOTTOMRIGHT" then bottom = scroll.points[i] end
    end
    check(type(bottom) == "table" and bottom[5], reserve, "a resize keeps the content above the footer")
    panel.Current = function() return "home" end
    local before = #scroll.points
    check(ns.liftPageScroll(panel), nil, "other pages keep Daylight's scroll")
    check(#scroll.points, before, "leaving the page does not move the scroll")
end

-- Issues #34, #41-#44 regression checks
do
    -- #41, #34 & #53: 10 core presets exact 9-layer recipes
    check(#ns.themes, 10, "#41 ten core presets")
    local wantRecipes = {
        hearthnight = { "ember", "beam", "compact_beam", "compact_pill", "framed", "framed", "molten", "classic", "sculpted" },
        harvestide = { "vanilla", "stream", "slim_ribbon", "compact_pill", "standard", "tiles", "silk", "classic", "standard" },
        tidemark = { "tide", "slate", "minimal_slate", "slim_bar", "compact", "tight", "tide", "flat", "razor" },
        oldroad = { "forever", "crest", "compact_beam", "crisp_square", "framed", "framed", "brushed", "heavy", "sculpted" },
        vigil = { "paladin", "stream", "slim_ribbon", "compact_pill", "healer", "matte", "silk", "circle", "triage" },
        snug = { "gilded", "flagon", "match", "compact_pill", "standard", "tiles", "flow", "circle", "standard" },
        bastionline = { "sightline", "anvil", "watch_plate", "crisp_square", "ward_stack", "tight", "interrupt_flare", "chamfer_oct", "flat" },
        arcanum = { "kirintor", "channel", "slim_ribbon", "slim_bar", "squad_ribbon", "tiles", "arcane_comet", "hex_cell", "razor" },
        canopy = { "verdigris", "trestle", "compact_beam", "angled_chip", "squad_ribbon", "triage_cells", "silk", "shield", "angled_blade" },
        blackrockledger = { "blackrock", "ledger", "minimal_slate", "slim_bar", "compact", "triage_cells", "matte", "borderless", "razor" },
    }
    for i = 1, #ns.themes do
        local t = ns.themes[i]
        local w = wantRecipes[t.id]
        check(type(w) == "table", true, "#41 known preset " .. tostring(t.id))
        if w then
            check(t.palette, w[1], t.id .. " palette")
            check(t.frame, w[2], t.id .. " frame")
            check(t.focus, w[3], t.id .. " focus")
            check(t.tot, w[4], t.id .. " tot")
            check(t.party, w[5], t.id .. " party")
            check(t.raid, w[6], t.id .. " raid")
            check(t.castbars, w[7], t.id .. " castbars")
            check(t.actionbars, w[8], t.id .. " actionbars")
            check(t.nameplates, w[9], t.id .. " nameplates")
        end
    end

    -- #41 & #34: My Presets 4-slot save/read/delete preserves 9th (nameplates) layer
    check(ns.saveMyPreset(1, "Raid Tank"), true, "#41 save My Preset slot 1")
    local savedSlots = ns.readMyPresets()
    check(type(savedSlots[1]) == "table" and savedSlots[1].name, "Raid Tank", "#41 read My Preset slot 1")
    check(type(savedSlots[1].recipe) == "table" and type(savedSlots[1].recipe.nameplates), "string", "#34 My Preset saves 9th nameplates layer")
    check(ns.deleteMyPreset(1), true, "#41 delete My Preset slot 1")
    check(ns.readMyPresets()[1], nil, "#41 My Preset slot 1 cleared")

    -- #42 & #34: 8 Looks categories, Player/Target & Nameplates sub-tabs, ToT tooltip, bidirectional Preview Deck sync
    check(#ns.lookCategories, 8, "#34 eight Looks sub-tab categories")
    check(ns.lookCategories[1].short, "Player/Target", "#34 first Looks sub-tab shortened to Player/Target")
    check(ns.lookCategories[3].short, "ToT", "#42 third Looks sub-tab is ToT")
    check(ns.lookCategories[3].tooltip, "Target of Target", "#42 ToT has Target of Target tooltip")
    check(ns.lookCategories[8].key, "nameplates", "#34 eighth Looks sub-tab is nameplates")
    check(ns.lookCategories[8].short, "Nameplates", "#34 eighth Looks sub-tab label is Nameplates")
    ns.setLooksSubTab("nameplates", false)
    check(ns.getLooksSubTab(), "nameplates", "#34 setLooksSubTab switches to nameplates")
    check(ns.getPreviewDeckMode(), "nameplates", "#34 nameplates sub-tab syncs Preview Deck mode")
    ns.setLooksSubTab("focus", false)
    check(ns.getLooksSubTab(), "focus", "#42 setLooksSubTab switches to focus")
    check(ns.getPreviewDeckMode(), "focus", "#42 sub-tab syncs Preview Deck mode")
    ns.setLooksSubTab("player_target", false)

    -- Every Looks category includes a "Daylight Standard" option in the first position
    check(ns.frameById("daylight_standard") and ns.frameById("daylight_standard").name, "Daylight Standard", "player_target has Daylight Standard option")
    for i = 2, #ns.lookCategories do
        local ck = ns.lookCategories[i].key
        local list = ns.extraLooks and ns.extraLooks[ck] or {}
        check(list[1] and list[1].id, "standard", ck .. " first option is standard")
        check(list[1] and list[1].name, "Daylight Standard", ck .. " first option is Daylight Standard")
    end

    -- #34 & #53: 6 curated Nameplate looks & strict Combat-Color Immunity
    local npList = ns.extraLooks and ns.extraLooks.nameplates or {}
    check(#npList, 6, "#34 six curated Nameplate looks")
    local forbiddenCombatKeys = {
        healthColor = true, healthCustom = true, healthGradient = true,
        threat = true, threatFill = true, threatAggro = true, threatWarn = true, threatLost = true,
        threatBar = true, threatBorder = true, threatGlow = true,
        castColor = true, castFill = true, castGradient = true,
        nameColor = true, bossBar = true, rareBar = true, questBar = true, casterBar = true,
        ["friendly.healthColor"] = true, ["friendly.healthCustom"] = true, ["friendly.healthGradient"] = true,
    }
    local wantNpIds = { "standard", "razor", "sculpted", "flat", "triage", "angled_blade" }
    for i = 1, #wantNpIds do
        local opt = npList[i]
        check(opt and opt.id, wantNpIds[i], "#34 nameplate look " .. i .. " is " .. wantNpIds[i])
        if opt and type(opt.settings) == "table" then
            for k in pairs(opt.settings) do
                if forbiddenCombatKeys[k] then
                    fail("#34 nameplate look " .. opt.id .. " must not override combat color key: " .. k)
                end
            end
        end
    end

    -- #34: Nameplates snapshot, apply, Undo, Reset Looks, combat queue, /looks, and module-absent safety
    local npOrig = {
        width = 170, height = 16, slant = true, backAlpha = 0.80,
        ["media.health"] = "daylight", ["media.cast"] = "daylight",
        castHeight = 14, castIcon = false, castIconPos = "outleft",
        nameSize = 13, percent = true, healthFormat = "percent", percentSign = true,
        targetStyle = "outline", targetAccent = true, targetScale = true, ["target.scale"] = 1.15, targetArrows = "none",
        ["friendly.height"] = 4, ["friendly.percent"] = false,
    }
    for k, v in pairs(npOrig) do sets.Nameplates[k] = v end
    local npModEnabled = true
    ui.GetModule = function(_, name)
        if name == "Nameplates" and npModEnabled then return { name = "Nameplates", enabled = true } end
        return nil
    end

    account.looks = nil
    check(ns.nameplatesModuleLoaded(), true, "#34 nameplatesModuleLoaded is true when module enabled")
    check(ns.applyCategoryLook("nameplates", "sculpted", true), true, "#34 applyCategoryLook writes Sculpted Plate")
    check(sets.Nameplates.width, 204, "#34 Sculpted Plate sets width to 204")
    check(sets.Nameplates.height, 24, "#34 Sculpted Plate sets height to 24")
    check(sets.Nameplates["media.health"], "brushed", "#34 Sculpted Plate sets brushed texture")
    check(sets.Nameplates.castHeight, 20, "#34 Sculpted Plate sets castHeight to 20")
    check(sets.Nameplates.targetStyle, "glow", "#34 Sculpted Plate sets targetStyle to glow")
    check(type(account.looks) == "table" and type(account.looks.nameplateValues) == "table" and account.looks.nameplateValues.width, 170, "#34 pre-write nameplate snapshot saved")

    -- Reset Looks restores original Nameplates values cleanly
    ns.restoreLooksOnly()
    check(sets.Nameplates.width, 170, "#34 Reset Looks restores Nameplates width")
    check(sets.Nameplates.height, 16, "#34 Reset Looks restores Nameplates height")
    check(sets.Nameplates["media.health"], "daylight", "#34 Reset Looks restores Nameplates texture")
    check(sets.Nameplates.castIcon, false, "#34 Reset Looks restores Nameplates castIcon")

    -- /looks supports nameplate look names and Undo restores them
    ns.looksSlash("razor")
    check(sets.Nameplates.height, 8, "#34 /looks razor applies Razor Strip height")
    check(sets.Nameplates.castIcon, false, "#34 /looks razor sets compact cast bar")
    ns.looksSlash("triage")
    check(sets.Nameplates.height, 21, "#34 /looks triage applies noticeably taller Triage Bar height")
    check(sets.Nameplates["media.health"], "silk", "#34 /looks triage applies silk bar texture")
    check(sets.Nameplates["friendly.percent"], true, "#34 /looks triage enables friendly % health")
    local undoBefore = ns.captureUndo("look")
    ns.applyCategoryLook("nameplates", "flat", true)
    check(sets.Nameplates["media.health"], "glass", "#34 Crisp Flat applies glass texture")
    ns.applyUndoShot(undoBefore)
    check(sets.Nameplates["media.health"], "silk", "#34 Undo restores previous Nameplates look")

    -- Combat lockdown queues Nameplate look until combat ends
    looksEnv.InCombatLockdown = function() return true end
    check(ns.applyCategoryLook("nameplates", "razor", true), false, "#34 combat lockdown blocks immediate nameplate write")
    check(sets.Nameplates["media.health"], "silk", "#34 combat lockdown leaves Nameplates unchanged")
    looksEnv.InCombatLockdown = function() return false end
    ns.finishLooksCombat()
    check(sets.Nameplates.height, 8, "#34 finishLooksCombat applies queued Razor Strip nameplate look")

    -- Module-absent safety: skips writes cleanly without error
    npModEnabled = false
    check(ns.nameplatesModuleLoaded(), false, "#34 nameplatesModuleLoaded is false when module absent")
    check(ns.applyCategoryLook("nameplates", "sculpted", true), false, "#34 applyCategoryLook skips safely when Nameplates absent")
    check(sets.Nameplates.height, 8, "#34 absent Nameplates module prevents writes")
    npModEnabled = true
    ns.restoreLooksOnly()
    ui.GetModule = nil

    -- #43: Non-destructive Reset staging & Cancel Preview + Live vs Reload flag
    local beforePal = palDb.palette
    ns.stageTabReset("Colours")
    check(type(ns.staged) == "table" and ns.staged.kind, "reset", "#43 Reset Colours stages non-destructively")
    check(ns.staged.looksOnly, false, "#43 Reset Colours requires reload")
    check(palDb.palette, beforePal, "#43 Reset Colours does not overwrite SavedVariables until Apply")
    check(ns.cancelStaged(), true, "#43 Cancel Preview clears staged reset")
    check(ns.staged, nil, "#43 ns.staged is nil after cancel")

    ns.stageTabReset("Looks")
    check(type(ns.staged) == "table" and ns.staged.looksOnly, true, "#43 Reset Looks is live-apply")
    ns.cancelStaged()

    -- Real Preview Deck shown on Presets, Colours, and Looks tabs
    if not main:find('tab == "Presets" or tab == "Colours" or tab == "Looks"', 1, true) then
        fail("real Preview Deck must show on Presets, Colours, and Looks tabs")
    end

    -- Multi-tab accumulated staging: Preset -> Colour tweak -> Looks tweak -> single Apply commits all
    local ran = {}
    ns.stagePick("theme", "oldroad", function() ran[#ran + 1] = "theme:oldroad" end, false, "Old Road")
    ns.stagePick("palette", "tide", function() ran[#ran + 1] = "palette:tide" end, false, "Tide")
    ns.stagePick("frame", "beam", function() ran[#ran + 1] = "frame:beam" end, false, "Beam")
    ns.stagePick("look", "healer", function() ran[#ran + 1] = "party:healer" end, false, "Healer Grid", nil, "party")
    check(type(ns.staged) == "table" and ns.staged.count, 4, "multi-tab staging accumulates Preset + Colour + 2 Looks")
    check(ns.staged.baseId, "oldroad", "staged draft retains base preset")
    check(ns.staged.palette, "tide", "staged draft retains colour tweak")
    check(ns.staged.frame, "beam", "staged draft retains frame tweak")
    check(ns.staged.looks and ns.staged.looks.party, "healer", "staged draft retains extra look tweak")
    check(ns.staged.looksOnly, false, "multi-tab draft with preset/colour requires reload")
    check(ns.commitStaged(), true, "commitStaged applies all accumulated selections")
    check(#ran, 4, "all 4 staged commits executed on Apply")
    check(ns.staged, nil, "ns.staged cleared after commit")
end

-- Issue #53: v0.9.0 Content Expansion checks
do
    -- 1. All 10 new palettes pass WCAG floors and L* <= 28
    local v09Pals = {
        "verdigris", "abyssal", "cinderclay", "lichen", "twilight",
        "kirintor", "sunspire", "blackrock", "stranglethorn", "winterspring",
    }
    local function lin(c) return c <= 0.04045 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4 end
    local function lstar(col)
        local Y = 0.2126 * lin(col[1]) + 0.7152 * lin(col[2]) + 0.0722 * lin(col[3])
        return Y > 0.008856 and (116 * (Y ^ (1 / 3)) - 16) or (903.3 * Y)
    end
    for i = 1, #v09Pals do
        local id = v09Pals[i]
        local p = ns.byId[id]
        check(type(p), "table", "#53 palette exists: " .. id)
        if p then
            check(lstar(p.background) <= 28, true, "#53 " .. id .. " background L* <= 28")
            check(lstar(p.window) <= 28, true, "#53 " .. id .. " window L* <= 28")
            check(ns.ratio(p.text, p.background) >= 6.6, true, "#53 " .. id .. " text/bg >= 6.6")
            check(ns.ratio(p.title, p.background) >= 4.5, true, "#53 " .. id .. " title/bg >= 4.5")
            check(ns.ratio(p.title, p.band) >= 4.5, true, "#53 " .. id .. " title/band >= 4.5")
            check(ns.ratio(p.text, p.band) >= 4.5, true, "#53 " .. id .. " text/band >= 4.5")
            check(ns.ratio(p.label, p.background) >= 4.5, true, "#53 " .. id .. " label/bg >= 4.5")
            check(ns.ratio(p.label, p.band) >= 4.5, true, "#53 " .. id .. " label/band >= 4.5")
            check(ns.ratio(p.c2, p.background) >= 3.0, true, "#53 " .. id .. " c2/bg >= 3.0")
            check(ns.ratio(p.c2, p.band) >= 3.0, true, "#53 " .. id .. " c2/band >= 3.0")
            check(ns.ratio(p.off, p.background) >= 3.0, true, "#53 " .. id .. " off/bg >= 3.0")
            check(ns.ratio(p.off, p.band) >= 3.0, true, "#53 " .. id .. " off/band >= 3.0")
        end
    end

    -- 2. All 8 Looks categories have balanced counts (10, 6, 6, 6, 6, 9, 9, 6 = 58)
    check(#ns.extraLooks.focus, 6, "#53 focus has 6 looks (3x2)")
    check(#ns.extraLooks.tot, 6, "#53 tot has 6 looks (3x2)")
    check(#ns.extraLooks.party, 6, "#53 party has 6 looks (3x2)")
    check(#ns.extraLooks.raid, 6, "#53 raid has 6 looks (3x2)")
    check(#ns.extraLooks.castbars, 9, "#53 castbars has 9 looks (3x3)")
    check(#ns.extraLooks.actionbars, 9, "#53 actionbars has 9 looks (3x3)")
    check(#ns.extraLooks.nameplates, 6, "#53 nameplates has 6 looks (3x2)")

    -- 3. Channel writes tide barFx; switching to Anvil restores saved barFx; partyCastbar <= 14
    seedFrames()
    ns.looksSlash("channel")
    check(sets.UnitFrames["player.barFx.health.style"], "tide", "#53 channel writes tide barFx")
    check(sets.UnitFrames["player.showPowerText"], true, "#53 channel enables power text")
    check(sets.UnitFrames["player.powerFormat"], "percent", "#53 channel uses percent powerFormat")
    ns.looksSlash("anvil")
    check(sets.UnitFrames["player.barFx.health.style"], userValue("player.barFx.health.style"), "#53 anvil restores saved barFx")
    check(sets.UnitFrames["player.portrait"], "3d", "#53 anvil sets 3d portrait")
    check(sets.UnitFrames["player.portraitShape"], "square", "#53 anvil sets square portrait")
    check(sets.UnitFrames["player.shell.borderPx"], 5, "#53 anvil sets 5px border")

    ns.looksSlash("interrupt_flare")
    check(sets.UnitFrames["playerCastbar.height"], 24, "#53 interrupt_flare sets 24px playerCastbar")
    check(sets.UnitFrames["partyCastbar.height"], 14, "#53 interrupt_flare clamps partyCastbar <= 14")
    check(sets.UnitFrames["playerCastbar.barFx.style"], "pixelsparks", "#53 interrupt_flare sets pixelsparks FX")

    ns.looksSlash("arcane_comet")
    check(sets.UnitFrames["playerCastbar.height"], 20, "#53 arcane_comet sets 20px playerCastbar")
    check(sets.UnitFrames["partyCastbar.height"], 14, "#53 arcane_comet clamps partyCastbar <= 14")
    check(sets.UnitFrames["playerCastbar.barFx.style"], "comet", "#53 arcane_comet sets comet FX")

    ns.looksSlash("hex_cell")
    check(sets.ActionBars["look.shape"], "hexagon", "#53 hex_cell sets hexagon shape")
    ns.looksSlash("chamfer_oct")
    check(sets.ActionBars["look.shape"], "octagon", "#53 chamfer_oct sets octagon shape")

    ns.looksSlash("angled_blade")
    check(sets.Nameplates["width"], 152, "#53 angled_blade sets 152 width")
    check(sets.Nameplates["height"], 12, "#53 angled_blade sets 12 height")
    check(sets.Nameplates["slant"], true, "#53 angled_blade sets slant true")
    check(sets.Nameplates["castHeight"], 11, "#53 angled_blade sets 11 castHeight")

    -- 4. /palettes and /looks resolve both IDs and display names
    looksEnv.SlashCmdList.PALETTES("dalaran")
    check(palDb.palette, "kirintor", "#53 /palettes dalaran resolves kirintor")
    looksEnv.SlashCmdList.PALETTES("silvermoon")
    check(palDb.palette, "sunspire", "#53 /palettes silvermoon resolves sunspire")
    looksEnv.SlashCmdList.PALETTES("verdier")
    check(palDb.palette, "verdigris", "#53 /palettes verdier resolves verdigris")
    looksEnv.SlashCmdList.PALETTES("winterspring")
    check(palDb.palette, "winterspring", "#53 /palettes winterspring resolves winterspring")

    ns.looksSlash("bastion line")
    check(palDb.palette, "sightline", "#53 /looks 'bastion line' applies bastionline preset")
    check(sets.UnitFrames["player.portraitShape"], "square", "#53 bastionline applies anvil frame")
    ns.looksSlash("dalaran arcanum")
    check(palDb.palette, "kirintor", "#53 /looks 'dalaran arcanum' applies arcanum preset")
    ns.looksSlash("verdant canopy")
    check(palDb.palette, "verdigris", "#53 /looks 'verdant canopy' applies canopy preset")
    ns.looksSlash("blackrock ledger")
    check(palDb.palette, "blackrock", "#53 /looks 'blackrock ledger' applies blackrockledger preset")

    -- 5. Combat lockdown queuing for new presets/looks
    looksEnv.InCombatLockdown = function() return true end
    ns.looksSlash("canopy")
    check(palDb.palette, "blackrock", "#53 combat lockdown queues canopy instead of writing immediately")
    looksEnv.InCombatLockdown = function() return false end
    ns.finishLooksCombat()
    check(palDb.palette, "verdigris", "#53 finishLooksCombat applies queued canopy preset")

    -- 6. Regression: selecting an already-live ToT look (slim_bar) while a preset with a different ToT (match) is staged
    ns.stagePick("mypreset", "slot-1", function() end, false, "Snug 1", {
        palette = "gilded", frame = "anvil", focus = "match", tot = "match",
        party = "standard", raid = "tiles", castbars = "flow", actionbars = "circle", nameplates = "standard",
    })
    -- Clicking Slim Bar when Slim Bar is already live (live = true) must stage slim_bar as an override, not clear to match
    ns.stagePick("look", "slim_bar", function() end, true, "Slim Bar", nil, "tot")
    check(ns.staged and ns.staged.looks and ns.staged.looks.tot, "slim_bar", "#53 live look overrides staged preset recipe")
    -- Clicking Match Player & Target (same as base preset) clears the redundant override cleanly
    ns.stagePick("look", "match", function() end, false, "Match Player & Target", nil, "tot")
    check(ns.staged and ns.staged.looks and ns.staged.looks.tot, nil, "#53 clicking base preset look clears override cleanly")
    ns.cancelStaged()

    -- Issue #56 (v0.9.5): Named My Presets, Recipe Pane Sync, (customized) External DaylightUI Edit Detection & Override Capture
    -- 1. Build Presets & Looks pages on mock frames to verify live UI state end-to-end
    local presetsPage = ns.themesPage()
    local presetsRow = piece()
    presetsRow.GetWidth = function() return 760 end
    presetsPage.groups[1].items[1].build(presetsRow)

    local looksPageObj = ns.looksPage()
    local looksRow = piece()
    looksRow.GetWidth = function() return 760 end
    looksPageObj.groups[1].items[1].build(looksRow)

    -- 2. Owned-key guardrails: anchors/positions and combat/class/reaction colors are strictly excluded
    check(ns.isOwnedLookKey("player_target", "UnitFrames", "player.height"), true, "#56 player.height is Palettes-owned")
    check(ns.isOwnedLookKey("castbars", "UnitFrames", "playerCastbar.height"), true, "#56 playerCastbar.height is Palettes-owned")
    check(ns.isOwnedLookKey("actionbars", "ActionBars", "look.shape"), true, "#56 ActionBars look.shape is Palettes-owned")
    check(ns.isOwnedLookKey("nameplates", "Nameplates", "height"), true, "#56 Nameplates height is Palettes-owned")
    check(ns.isOwnedLookKey("player_target", "UnitFrames", "player.offsetX"), false, "#56 player.offsetX is excluded")
    check(ns.isOwnedLookKey("player_target", "UnitFrames", "player.point"), false, "#56 player.point is excluded")
    check(ns.isOwnedLookKey("player_target", "UnitFrames", "positions.player"), false, "#56 positions.player is excluded")
    check(ns.isOwnedLookKey("player_target", "UnitFrames", "colors.health"), false, "#56 colors.health is excluded")
    check(ns.isOwnedLookKey("nameplates", "Nameplates", "healthColor"), false, "#56 Nameplates healthColor is excluded")
    check(ns.isOwnedLookKey("nameplates", "Nameplates", "threatAggro"), false, "#56 Nameplates threatAggro is excluded")
    check(ns.isOwnedLookKey("player_target", "UnitFrames", "textOutline"), false, "#56 textOutline is excluded")
    check(ns.isOwnedLookKey("player_target", "UnitFrames", "textShadow"), false, "#56 textShadow is excluded")

    -- 3. Applying Hearthnight records applied fingerprint and starts clean (not customized)
    ns.looksSlash("hearthnight")
    local fp = ns.readAppliedFingerprint()
    check(type(fp) == "table" and type(fp.player_target) == "table" and type(fp.player_target.UnitFrames) == "table", true, "#56 Hearthnight records player_target fingerprint")
    check(type(fp.castbars) == "table" and type(fp.castbars.UnitFrames) == "table", true, "#56 Hearthnight records castbars fingerprint")
    local cust0, custList0 = ns.detectCustomizedLayers()
    check(#custList0, 0, "#56 freshly applied Hearthnight has 0 customized layers")
    check(presetsRow.recipeTitle.words, "Hearthnight Recipe", "#56 clean Hearthnight recipe header")
    check(presetsRow.recipeReapply.shown, false, "#56 Re-apply button hidden when clean")

    -- 4. External edit to a forbidden/unmanaged key (position/combat color) must NOT trigger (customized)
    ui:Set("UnitFrames", "player.offsetX", 42)
    ui:Set("UnitFrames", "colors.health", "class")
    local _, custListForbidden = ns.detectCustomizedLayers()
    check(#custListForbidden, 0, "#56 external edits to positions/combat colors do not trigger customized")
    check(presetsRow.recipeTitle.words, "Hearthnight Recipe", "#56 recipe header stays clean after non-owned edit")

    -- 5. External DaylightUI edits to Palettes-owned keys trigger (customized) on Presets, Recipe, Looks sub-tabs & show Re-apply
    ui:Set("UnitFrames", "player.height", 58)
    ui:Set("UnitFrames", "playerCastbar.height", 24)
    local cust1, custList1 = ns.detectCustomizedLayers()
    check(cust1.player_target, true, "#56 external player.height edit marks player_target customized")
    check(cust1.castbars, true, "#56 external playerCastbar.height edit marks castbars customized")
    check(#custList1, 2, "#56 two layers detected as externally customized")
    check(presetsRow.recipeTitle.words, "Hearthnight (customized)", "#56 Recipe header appends (customized)")
    check(string.find(presetsRow.recipeDesc.words or "", "Player/Target", 1, true) ~= nil, true, "#56 Recipe desc notes Player/Target modified")
    check(string.find(presetsRow.recipeDesc.words or "", "Cast Bars", 1, true) ~= nil, true, "#56 Recipe desc notes Cast Bars modified")
    check(presetsRow.recipeReapply.shown, true, "#56 Re-apply button shown when externally customized")
    check(presetsRow.recipeReapplyFs.words, "Re-apply Hearthnight", "#56 Re-apply button text matches active preset")

    -- Verify Looks sub-tab labels diverged base looks as [Look Name] (customized)
    local beamLine, moltenLine
    for i = 1, #looksRow.lines do
        local ln = looksRow.lines[i]
        if ln.catKey == "player_target" and ln.id == "beam" then beamLine = ln end
        if ln.catKey == "castbars" and ln.id == "molten" then moltenLine = ln end
    end
    check(beamLine and beamLine.name.words, "Beam (customized)", "#56 Looks Player/Target labels diverged base look")
    check(moltenLine and moltenLine.name.words, "Molten Ember (customized)", "#56 Looks Cast Bars labels diverged base look")

    -- 6. Capture live custom DaylightUI overrides in + Save Current via inline EditBox
    check(ns.smartMyPresetName(1), "Hearthnight 1", "#56 smart default name uses active preset + 1")
    local slot1 = presetsRow.mySlots[1]
    slot1.editBox.GetText = function(self) return self.words or "" end
    -- Clicking empty slot opens inline EditBox pre-filled with smart default name; Esc cancels without saving
    slot1.btn.scripts.OnClick()
    check(slot1.editBox.shown, true, "#56 clicking + Save Current shows inline EditBox")
    check(slot1.editBox.words, "Hearthnight 1", "#56 inline EditBox pre-filled with smart default name")
    slot1.editBox.scripts.OnEscapePressed()
    check(slot1.editBox.shown, false, "#56 Esc closes inline EditBox")
    check(ns.readMyPresets()[1], nil, "#56 Esc cancels save without creating slot")

    -- Re-open inline EditBox, type custom name, press Enter to save with live overrides
    slot1.btn.scripts.OnClick()
    slot1.editBox:SetText("Snug Raid")
    slot1.editBox.scripts.OnEnterPressed()
    check(slot1.editBox.shown, false, "#56 Enter closes inline EditBox")
    local saved1 = ns.readMyPresets()[1]
    check(type(saved1) == "table" and saved1.name, "Snug Raid", "#56 Enter saves named My Preset")
    check(type(saved1.overrides) == "table" and saved1.overrides.player_target.UnitFrames["player.height"], 58, "#56 save captures live player.height override")
    check(saved1.overrides.castbars.UnitFrames["playerCastbar.height"], 24, "#56 save captures live playerCastbar.height override")
    check(saved1.overrides.player_target.UnitFrames["player.offsetX"], nil, "#56 save never captures frame offsetX")
    check(saved1.overrides.player_target.UnitFrames["colors.health"], nil, "#56 save never captures colors.health")

    -- 7. Inline rename via rename button AND via double-click
    slot1.renBtn.scripts.OnClick()
    check(slot1.editBox.shown, true, "#56 rename icon opens inline EditBox")
    check(slot1.editBox.words, "Snug Raid", "#56 rename EditBox pre-filled with existing name")
    slot1.editBox:SetText("Dungeon Main")
    slot1.editBox.scripts.OnEnterPressed()
    check(ns.readMyPresets()[1].name, "Dungeon Main", "#56 rename icon Enter renames slot")

    slot1.btn.scripts.OnDoubleClick()
    check(slot1.editBox.shown, true, "#56 double-click opens inline rename EditBox")
    slot1.editBox:SetText("Raid Main")
    slot1.editBox.scripts.OnEnterPressed()
    check(ns.readMyPresets()[1].name, "Raid Main", "#56 double-click Enter renames slot")

    -- 8. Clicking Re-apply Hearthnight restores clean values and clears (customized)
    presetsRow.recipeReapply.scripts.OnClick()
    local _, custListAfterReapply = ns.detectCustomizedLayers()
    check(#custListAfterReapply, 0, "#56 Re-apply Hearthnight clears all customized layers")
    check(presetsRow.recipeTitle.words, "Hearthnight Recipe", "#56 Recipe header clean after Re-apply")
    check(beamLine.name.words, "Beam", "#56 Looks sub-tab label clean after Re-apply")
    check(moltenLine.name.words, "Molten Ember", "#56 Cast Bars sub-tab label clean after Re-apply")

    -- 9. Selecting My Preset syncs Recipe pane header, auto-summary, and all 9 cells (marking overridden layers)
    ns.looksSlash("snug")
    slot1.btn.scripts.OnClick()
    check(presetsRow.recipeTitle.words, "Raid Main Recipe", "#56 selecting My Preset updates Recipe header to [Slot Name] Recipe")
    check(string.find(presetsRow.recipeDesc.words or "", "Ember", 1, true) ~= nil, true, "#56 My Preset Recipe desc includes colour summary")
    check(presetsRow.layerButtons[1].valFs.words, "Ember", "#56 Recipe cell 1 shows saved Colour")
    check(presetsRow.layerButtons[2].valFs.words, "Beam (customized)", "#56 Recipe cell 2 marks overridden Player/Target as (customized)")
    check(presetsRow.layerButtons[7].valFs.words, "Molten Ember (customized)", "#56 Recipe cell 7 marks overridden Cast Bars as (customized)")
    check(presetsRow.layerButtons[8].valFs.words, "Daylight Classic", "#56 Recipe cell 8 shows clean Action Bars look")
    check(presetsRow.layerButtons[9].valFs.words, "Sculpted Plate", "#56 Recipe cell 9 shows clean Nameplates look")

    -- 10. Applying My Preset restores both base layers and saved custom overrides cleanly
    ns.commitStaged()
    check(palDb.palette, "ember", "#56 applying My Preset restores base palette")
    check(sets.UnitFrames["player.height"], 58, "#56 applying My Preset restores saved player.height override")
    check(sets.UnitFrames["playerCastbar.height"], 24, "#56 applying My Preset restores saved playerCastbar.height override")
    local _, custListAfterMyApply = ns.detectCustomizedLayers()
    check(#custListAfterMyApply, 0, "#56 freshly applied My Preset matches its own applied fingerprint")
    check(presetsRow.recipeTitle.words, "Raid Main Recipe", "#56 active My Preset shows [Slot Name] Recipe")

    -- External edit on top of active My Preset flags [Slot Name] (customized) and offers Re-apply [Slot Name]
    ui:Set("ActionBars", "look.shape", "hexagon")
    local custMy, custMyList = ns.detectCustomizedLayers()
    check(custMy.actionbars, true, "#56 external ActionBars edit on active My Preset detected")
    check(#custMyList, 1, "#56 1 customized layer on active My Preset")
    check(presetsRow.recipeTitle.words, "Raid Main (customized)", "#56 active My Preset header appends (customized)")
    check(presetsRow.recipeReapplyFs.words, "Re-apply Raid Main", "#56 Re-apply link offers Re-apply Raid Main")

    -- 11. Combat lockdown queuing for My Preset apply + finishLooksCombat
    ns.looksSlash("snug")
    looksEnv.InCombatLockdown = function() return true end
    ns.applyMyPreset(ns.readMyPresets()[1], 1)
    check(palDb.palette, "gilded", "#56 combat lockdown queues My Preset instead of writing immediately")
    looksEnv.InCombatLockdown = function() return false end
    ns.finishLooksCombat()
    check(palDb.palette, "ember", "#56 finishLooksCombat applies queued My Preset palette")
    check(sets.UnitFrames["player.height"], 58, "#56 finishLooksCombat restores queued My Preset custom override")

    -- Clean up slot 1 and restore
    ns.deleteMyPreset(1)
    ns.looksSlash("off")
    check(userRestored(), true, "#53 off restores original frame snapshot cleanly")
end

if failures > 0 then
    io.stderr:write(failures .. " Palettes check(s) failed\n")
    os.exit(1)
end

io.write("Palettes check passed\n")
