-- Color numbers for the dark palettes.
--
-- This file does not call the game, so a checker can load it with plain
-- Lua 5.1. The hex strings are the approved dark palettes: the five from
-- v1, the eight dark palettes from the v2 sheet, and the v3 class and
-- realm themes. Class themes are palettes. They do not change class colors.
--
-- c1 and c3 are the ends of a decorative gradient. They are not text colors
-- and not hairline borders. The highlight a player sees is c2, the middle.

local _, ns = ...

-- "#RRGGBB" -> { hex = "#RRGGBB", 1 = red, 2 = green, 3 = blue } in 0..1.
local function C(hex)
    local n = tonumber(string.sub(hex, 2), 16) or 0
    return {
        hex = string.upper(hex),
        math.floor(n / 65536) % 256 / 255,
        math.floor(n / 256) % 256 / 255,
        n % 256 / 255,
    }
end

local function add(p)
    ns.byId[p.id] = p
    ns.order[#ns.order + 1] = p.id
end

ns.byId = {}
ns.order = {}

-- Dark. One scheme each, not a brightness slider.
add({
    id = "ember", name = "Ember", group = "dark",
    mood = "Warm campfire gold on deep charcoal.",
    window = C("#18120E"), background = C("#211812"), border = C("#0A0705"),
    band = C("#2A1F16"), bandLit = C("#4A3524"),
    c1 = C("#C45C2A"), c2 = C("#E8A04A"), c3 = C("#F3D59A"),
    title = C("#FFF6EC"), text = C("#F4E8D8"), label = C("#D0BA9F"), off = C("#9E8971"),
    sidebar = C("#120D0A"), list = C("#120D0A"), stage = C("#100B08"),
    card = C("#281E17"), cardEdge = C("#3D2E22"), cardLit = C("#523E2E"),
    control = C("#31251D"), controlHover = C("#3E2F24"), track = C("#3A2C22"),
    fillTop = C("#2B2019"), fillBottom = C("#1D1510"),
    buttonBand = C("#2A1F16"), buttonBandMain = C("#4A3524"), buttonBandOff = C("#1E1711"),
    controlBorder = C("#3D2E22"), disabledBorder = C("#261C15"),
    rowHover = C("#6E5644"), emptyBorder = C("#45362A"),
})

add({
    id = "tide", name = "Tide", group = "dark",
    mood = "Cool sea-green and slate.",
    window = C("#0E1418"), background = C("#141C22"), border = C("#05080A"),
    band = C("#16222B"), bandLit = C("#263B48"),
    c1 = C("#1A6B72"), c2 = C("#3DB8A8"), c3 = C("#A8E6DC"),
    title = C("#F0FAFA"), text = C("#DCECEB"), label = C("#A9C7C6"), off = C("#789697"),
    sidebar = C("#0A0F12"), list = C("#0A0F12"), stage = C("#080C0F"),
    card = C("#1A242C"), cardEdge = C("#283743"), cardLit = C("#364A5A"),
    control = C("#212E38"), controlHover = C("#2A3B47"), track = C("#273642"),
    fillTop = C("#1D2831"), fillBottom = C("#131B22"),
    buttonBand = C("#16222B"), buttonBandMain = C("#263B48"), buttonBandOff = C("#111A21"),
    controlBorder = C("#283743"), disabledBorder = C("#19232B"),
    rowHover = C("#4A6578"), emptyBorder = C("#30424F"),
})

add({
    id = "dusk", name = "Dusk", group = "dark",
    mood = "Muted plum and rose, late evening.",
    window = C("#14111A"), background = C("#1B1724"), border = C("#08060B"),
    band = C("#241D30"), bandLit = C("#3D3052"),
    c1 = C("#6A3A78"), c2 = C("#B07AC8"), c3 = C("#E8C4DC"),
    title = C("#F8F2FC"), text = C("#ECE4F4"), label = C("#C4B5D4"), off = C("#9384A5"),
    sidebar = C("#0F0C14"), list = C("#0F0C14"), stage = C("#0C0A11"),
    card = C("#221D2E"), cardEdge = C("#352D46"), cardLit = C("#473C5E"),
    control = C("#2B2539"), controlHover = C("#362F48"), track = C("#332C44"),
    fillTop = C("#262033"), fillBottom = C("#1A1524"),
    buttonBand = C("#241D30"), buttonBandMain = C("#3D3052"), buttonBandOff = C("#1A1523"),
    controlBorder = C("#352D46"), disabledBorder = C("#221D2D"),
    rowHover = C("#62537D"), emptyBorder = C("#3E3552"),
})

add({
    id = "ash", name = "Ash", group = "dark",
    mood = "Cool and quiet, color only where it counts.",
    window = C("#121315"), background = C("#18191C"), border = C("#060607"),
    band = C("#1D1E22"), bandLit = C("#31333A"),
    c1 = C("#8A8680"), c2 = C("#C8C4B8"), c3 = C("#E8E4D8"),
    title = C("#FFFFFF"), text = C("#EAEAE8"), label = C("#BAB9B4"), off = C("#8B8A86"),
    sidebar = C("#0E0F11"), list = C("#0E0F11"), stage = C("#0B0C0E"),
    card = C("#1F2024"), cardEdge = C("#2F3138"), cardLit = C("#3E414A"),
    control = C("#27292E"), controlHover = C("#32343B"), track = C("#2E3037"),
    fillTop = C("#222429"), fillBottom = C("#18191D"),
    buttonBand = C("#1D1E22"), buttonBandMain = C("#31333A"), buttonBandOff = C("#15161A"),
    controlBorder = C("#2F3138"), disabledBorder = C("#1E2025"),
    rowHover = C("#5A5D66"), emptyBorder = C("#3A3D45"),
})

add({
    id = "pine", name = "Pine", group = "dark",
    mood = "Deep forest green, night in the woods.",
    window = C("#0E140F"), background = C("#141C15"), border = C("#050805"),
    band = C("#172419"), bandLit = C("#28402C"),
    c1 = C("#3A6A38"), c2 = C("#7CB86A"), c3 = C("#C8E8B0"),
    title = C("#F2FAF0"), text = C("#E2EEDC"), label = C("#B1CAA9"), off = C("#7E9778"),
    sidebar = C("#0A0F0B"), list = C("#0A0F0B"), stage = C("#080D09"),
    card = C("#1A241B"), cardEdge = C("#28372A"), cardLit = C("#364A39"),
    control = C("#222E23"), controlHover = C("#2B3B2D"), track = C("#28372A"),
    fillTop = C("#1D281E"), fillBottom = C("#131B14"),
    buttonBand = C("#172419"), buttonBandMain = C("#28402C"), buttonBandOff = C("#121C14"),
    controlBorder = C("#28372A"), disabledBorder = C("#19231B"),
    rowHover = C("#4A664E"), emptyBorder = C("#304232"),
})

-- The v2 sheet lists the window, panel, border, band, ink, and accent.
-- It does not list the options-window slots. Those reuse the sheet's own
-- colors, so the options page still recolors and no extra hue is invented.
local function sheet(p)
    p.sidebar, p.list = p.window, p.window
    p.stage = p.background
    p.card, p.control, p.track = p.band, p.band, p.band
    p.cardEdge, p.cardLit, p.controlHover = p.bandLit, p.bandLit, p.bandLit
    p.fillTop, p.fillBottom = p.band, p.background
    p.buttonBand, p.buttonBandMain, p.buttonBandOff = p.band, p.bandLit, p.border
    p.controlBorder, p.disabledBorder = p.bandLit, p.border
    p.rowHover, p.emptyBorder = p.bandLit, p.border
    add(p)
end

-- v2 dark. Same path as Ember: no forced opacity, no tooltip plate.
sheet({
    id = "forgeglow", name = "Forgeglow", group = "dark",
    mood = "Soot-black iron, with a molten orange edge.",
    window = C("#0C0908"), background = C("#100C0A"), border = C("#050302"),
    band = C("#221714"), bandLit = C("#3A241C"),
    c1 = C("#C44810"), c2 = C("#F26A1A"), c3 = C("#F6B17A"),
    title = C("#FFF6EE"), text = C("#F3E6D8"), label = C("#D0B49A"), off = C("#A08068"),
})
sheet({
    id = "nightglass", name = "Nightglass", group = "dark",
    mood = "Midnight teal, finished in silver.",
    window = C("#071114"), background = C("#0A1518"), border = C("#03080A"),
    band = C("#163033"), bandLit = C("#2A4A4E"),
    c1 = C("#8AA3A8"), c2 = C("#C5D5D8"), c3 = C("#E8F0F2"),
    title = C("#F4FBFC"), text = C("#E2EEF0"), label = C("#B7C9CC"), off = C("#7A9094"),
})
sheet({
    id = "vesper", name = "Vesper", group = "dark",
    mood = "Deep indigo, struck with magenta.",
    window = C("#0D0A16"), background = C("#120E1C"), border = C("#07050E"),
    band = C("#241A38"), bandLit = C("#3A2A55"),
    c1 = C("#D63080"), c2 = C("#E94A96"), c3 = C("#F099C0"),
    title = C("#F8F2FC"), text = C("#E8DCF4"), label = C("#C4B0D8"), off = C("#8A789C"),
})
sheet({
    id = "carmine-night", name = "Carmine Night", group = "dark",
    mood = "Charcoal cloth, cut with carmine.",
    window = C("#100A0C"), background = C("#140E10"), border = C("#080506"),
    band = C("#2A161A"), bandLit = C("#4A242C"),
    c1 = C("#D4283C"), c2 = C("#E03040"), c3 = C("#E07080"),
    title = C("#FFF2F2"), text = C("#F0DEDE"), label = C("#D0B0B0"), off = C("#9A7878"),
})
sheet({
    id = "gilded", name = "Gilded", group = "dark",
    mood = "Near-black, trimmed in real gold.",
    window = C("#0A0907"), background = C("#0E0D0A"), border = C("#050403"),
    band = C("#242018"), bandLit = C("#3A3428"),
    c1 = C("#B89020"), c2 = C("#D4AF37"), c3 = C("#F0D878"),
    title = C("#FFF8E8"), text = C("#F0E6C8"), label = C("#D4C498"), off = C("#A09070"),
})
sheet({
    id = "phosphor", name = "Phosphor", group = "dark",
    mood = "Near-black, edged in acid green.",
    window = C("#070806"), background = C("#0A0C09"), border = C("#030403"),
    band = C("#162014"), bandLit = C("#2A3A26"),
    c1 = C("#7AC400"), c2 = C("#B8FF00"), c3 = C("#E8FF8A"),
    title = C("#F4FFE8"), text = C("#E0F0D0"), label = C("#B0C8A0"), off = C("#7A9270"),
})
sheet({
    id = "ink", name = "Ink", group = "dark",
    mood = "Pure black and white. No chroma.",
    window = C("#0A0A0A"), background = C("#0A0A0A"), border = C("#000000"),
    band = C("#1C1C1C"), bandLit = C("#2E2E2E"),
    c1 = C("#C8C8C8"), c2 = C("#FFFFFF"), c3 = C("#8A8A8A"),
    title = C("#FFFFFF"), text = C("#F2F2F2"), label = C("#D0D0D0"), off = C("#8C8C8C"),
})
sheet({
    id = "sightline", name = "Sightline", group = "dark",
    mood = "Slate-blue and amber, for colour-blind vision.",
    window = C("#0E141A"), background = C("#121820"), border = C("#06080C"),
    band = C("#1C2836"), bandLit = C("#2E3E50"),
    c1 = C("#C48410"), c2 = C("#E8A020"), c3 = C("#F3C86A"),
    title = C("#F4F7FB"), text = C("#E2E8F0"), label = C("#B8C4D2"), off = C("#7E8C9A"),
})

-- v3. Same dark path. Two accent gradients are nudged so near pairs stay apart.
-- Priest's stops are bluer than the sheet, so the silver is not Nightglass or Ash.
-- Rustbrand's stops are more amber than the sheet, so the orange is not
-- Ironbanner's rust or Junglefire's tangerine. Every other token is the sheet.
sheet({
    id = "warrior", name = "Warrior", group = "class",
    mood = "Oiled leather and iron, tan trim.",
    window = C("#121110"), background = C("#171614"), border = C("#070605"),
    band = C("#2A2823"), bandLit = C("#424038"),
    c1 = C("#A88858"), c2 = C("#D4B07A"), c3 = C("#EEDCC0"),
    title = C("#F9F8F6"), text = C("#EDE9E3"), label = C("#A28B6A"), off = C("#A08C6E"),
})
sheet({
    id = "mage", name = "Mage", group = "class",
    mood = "Frost-blue glass on deep navy.",
    window = C("#0B111A"), background = C("#0F1622"), border = C("#04070B"),
    band = C("#172437"), bandLit = C("#273D5A"),
    c1 = C("#2E8EC4"), c2 = C("#56BEEA"), c3 = C("#B4E2F6"),
    title = C("#F6F8F9"), text = C("#E3EAEE"), label = C("#6191A6"), off = C("#6490A2"),
})
sheet({
    id = "paladin", name = "Paladin", group = "class",
    mood = "Rose trim on warm plum-brown.",
    window = C("#150F12"), background = C("#1C1418"), border = C("#090607"),
    band = C("#2E1F26"), bandLit = C("#4A313C"),
    c1 = C("#C45E8A"), c2 = C("#E892B8"), c3 = C("#F6CCDD"),
    title = C("#F9F6F7"), text = C("#EEE3E7"), label = C("#B47993"), off = C("#B07B92"),
})
sheet({
    id = "priest", name = "Priest", group = "class",
    mood = "Cool silver on near-black.",
    window = C("#0B0C0E"), background = C("#0F1013"), border = C("#040405"),
    band = C("#1C1E23"), bandLit = C("#30333B"),
    c1 = C("#6E8CAA"), c2 = C("#8EADC8"), c3 = C("#E4F0F8"),
    title = C("#F7F7F8"), text = C("#E7E8EA"), label = C("#80868E"), off = C("#81868D"),
})
sheet({
    id = "keepstone", name = "Keepstone", group = "realm",
    mood = "Walnut and grey stone, aged brass.",
    window = C("#16120C"), background = C("#1E1912"), border = C("#090704"),
    band = C("#322C22"), bandLit = C("#4C4436"),
    c1 = C("#867446"), c2 = C("#9A8650"), c3 = C("#C4B484"),
    title = C("#F8F8F7"), text = C("#EBE9E5"), label = C("#9B937A"), off = C("#9B937E"),
})
sheet({
    id = "ironbanner", name = "Ironbanner", group = "realm",
    mood = "Blackened iron, rust-red trim.",
    window = C("#110E0C"), background = C("#17120F"), border = C("#060403"),
    band = C("#2A201A"), bandLit = C("#45332A"),
    c1 = C("#B64B2E"), c2 = C("#C8583A"), c3 = C("#EBA488"),
    title = C("#F9F6F6"), text = C("#EDE5E3"), label = C("#AB7E72"), off = C("#A88075"),
})
sheet({
    id = "sapphire-crown", name = "Sapphire Crown", group = "realm",
    mood = "Royal navy, pale crown gold.",
    window = C("#0A0D1A"), background = C("#0D1222"), border = C("#04050B"),
    band = C("#18214A"), bandLit = C("#283770"),
    c1 = C("#B89A48"), c2 = C("#E0C676"), c3 = C("#F4E6B8"),
    title = C("#F9F8F6"), text = C("#EEEBE3"), label = C("#9B8A57"), off = C("#998A5C"),
})
sheet({
    id = "crownwall", name = "Crownwall", group = "realm",
    mood = "Castle stone, banner blue.",
    window = C("#101216"), background = C("#15181D"), border = C("#06070A"),
    band = C("#252A33"), bandLit = C("#3A414E"),
    c1 = C("#5A82BE"), c2 = C("#7FA6DC"), c3 = C("#C8D8F0"),
    title = C("#F6F7F9"), text = C("#E3E7ED"), label = C("#7C92B1"), off = C("#7E93AF"),
})
sheet({
    id = "deepforge", name = "Deepforge", group = "realm",
    mood = "Granite and hot copper.",
    window = C("#111213"), background = C("#17181A"), border = C("#060607"),
    band = C("#28292C"), bandLit = C("#404247"),
    c1 = C("#B65734"), c2 = C("#D07048"), c3 = C("#E8B090"),
    title = C("#F9F7F6"), text = C("#EDE6E3"), label = C("#AF8776"), off = C("#AD8879"),
})
sheet({
    id = "starshade", name = "Starshade", group = "realm",
    mood = "Night-violet sky, pale moon blue.",
    window = C("#0C0C18"), background = C("#101020"), border = C("#05050C"),
    band = C("#1C1C3A"), bandLit = C("#2D2D58"),
    c1 = C("#8A78D4"), c2 = C("#B8A8F0"), c3 = C("#E0D8FA"),
    title = C("#F6F6F9"), text = C("#E5E3EE"), label = C("#8B7EB6"), off = C("#8B7FB3"),
})
sheet({
    id = "cogspark", name = "Cogspark", group = "realm",
    mood = "Gunmetal and a bright spark pink.",
    window = C("#0F1112"), background = C("#141618"), border = C("#050606"),
    band = C("#23272A"), bandLit = C("#383E43"),
    c1 = C("#C430A0"), c2 = C("#F24EC8"), c3 = C("#F9B0E4"),
    title = C("#F9F6F8"), text = C("#EEE3EB"), label = C("#B57BA6"), off = C("#B17CA3"),
})
sheet({
    id = "rustbrand", name = "Rustbrand", group = "realm",
    mood = "Olive war-hide and burnt orange.",
    window = C("#111109"), background = C("#17170E"), border = C("#060603"),
    band = C("#28281A"), bandLit = C("#424129"),
    c1 = C("#A86818"), c2 = C("#C98420"), c3 = C("#F0C48A"),
    title = C("#F9F7F6"), text = C("#EEE6E3"), label = C("#AF8471"), off = C("#AC8574"),
})
sheet({
    id = "gravelight", name = "Gravelight", group = "realm",
    mood = "Cold crypt stone, pale sickly green.",
    window = C("#0E100F"), background = C("#131614"), border = C("#050605"),
    band = C("#212622"), bandLit = C("#363E38"),
    c1 = C("#82A06A"), c2 = C("#A9C38C"), c3 = C("#D8E6C8"),
    title = C("#F7F8F7"), text = C("#E8EBE5"), label = C("#80926D"), off = C("#829171"),
})
sheet({
    id = "plainsong", name = "Plainsong", group = "realm",
    mood = "Warm hide-bronze, open-sky turquoise.",
    window = C("#14110D"), background = C("#1B1712"), border = C("#070605"),
    band = C("#2C251C"), bandLit = C("#463B2D"),
    c1 = C("#2A7EAA"), c2 = C("#3AA4D4"), c3 = C("#A8D8F0"),
    title = C("#F6F8F9"), text = C("#E3EAEE"), label = C("#6493A8"), off = C("#6993A5"),
})
sheet({
    id = "junglefire", name = "Junglefire", group = "realm",
    mood = "Deep jungle teal, tangerine trim.",
    window = C("#0A1311"), background = C("#0E1916"), border = C("#040806"),
    band = C("#172B26"), bandLit = C("#26443C"),
    c1 = C("#C9411D"), c2 = C("#E85A32"), c3 = C("#F4A888"),
    title = C("#F9F6F6"), text = C("#EEE5E3"), label = C("#B28376"), off = C("#AF8579"),
})

-- Headings in the Appearance menu, and the restore row under them.
ns.groups = {
    { key = "_dark", label = "Dark", ids = {
        "ember", "tide", "dusk", "ash", "pine",
        "forgeglow", "nightglass", "vesper", "carmine-night", "gilded", "phosphor", "ink", "sightline",
    } },
    { key = "_class", label = "Class themes", ids = {
        "warrior", "mage", "paladin", "priest",
    } },
    { key = "_realm", label = "Realm themes", ids = {
        "keepstone", "ironbanner", "sapphire-crown", "crownwall", "deepforge",
        "starshade", "cogspark", "rustbrand", "gravelight", "plainsong", "junglefire",
    } },
}
ns.off = { id = "off", name = "Daylight (off)", mood = "Restore Daylight's own colors." }

-- Swatch order on each row: window, panel, band, highlight, text.
ns.swatchKeys = { "window", "background", "band", "c2", "text" }

-- The game's class colors (RAID_CLASS_COLORS colorStr). Chrome accent only.
-- Names, chat, and unit frames keep these exact colors.
ns.classes = {
    { id = "WARRIOR", name = "Warrior", color = C("#C69B6D") },
    { id = "PALADIN", name = "Paladin", color = C("#F58CBA") },
    { id = "HUNTER", name = "Hunter", color = C("#ABD473") },
    { id = "ROGUE", name = "Rogue", color = C("#FFF468") },
    { id = "PRIEST", name = "Priest", color = C("#FFFFFF") },
    { id = "DEATHKNIGHT", name = "Death Knight", color = C("#C41E3A") },
    { id = "SHAMAN", name = "Shaman", color = C("#0070DD") },
    { id = "MAGE", name = "Mage", color = C("#3FC7EB") },
    { id = "WARLOCK", name = "Warlock", color = C("#8788EE") },
    { id = "MONK", name = "Monk", color = C("#00FF96") },
    { id = "DRUID", name = "Druid", color = C("#FF7C0A") },
    { id = "DEMONHUNTER", name = "Demon Hunter", color = C("#A330C9") },
    { id = "EVOKER", name = "Evoker", color = C("#33937F") },
}
ns.classById = {}
for i = 1, #ns.classes do
    ns.classById[ns.classes[i].id] = ns.classes[i]
end

function ns.hexColor(hex)
    if type(hex) ~= "string" then return nil end
    if string.sub(hex, 1, 1) ~= "#" then hex = "#" .. hex end
    return C(string.upper(hex))
end

-- WCAG contrast. A channel is the 0..1 red, green, or blue.
local function channel(v)
    if v <= 0.04045 then return v / 12.92 end
    return ((v + 0.055) / 1.055) ^ 2.4
end

local function luminance(color)
    return 0.2126 * channel(color[1]) + 0.7152 * channel(color[2]) + 0.0722 * channel(color[3])
end

function ns.ratio(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return 0 end
    local x, y = luminance(a), luminance(b)
    if y > x then x, y = y, x end
    return (x + 0.05) / (y + 0.05)
end

-- True when this accent stays readable on the palette's panel and on its band.
function ns.accentPasses(color, palette)
    if type(color) ~= "table" or type(color[1]) ~= "number" then return false end
    if type(palette) ~= "table" or type(palette.background) ~= "table" or type(palette.band) ~= "table" then
        return false
    end
    return ns.ratio(color, palette.background) >= 3 and ns.ratio(color, palette.band) >= 3
end

-- A shifted class shade keeps its hue. Lightness stays between these two
-- so the color does not turn near-black or near-white. Chroma stays at
-- least shadeChromaMin, and never higher than the class color's own
-- chroma, so it does not turn grey. Every palette is dark, so a color that
-- misses 3:1 is lightened. A color that already clears 3:1 is kept.
ns.shadeLMin = 0.30
ns.shadeLMax = 0.88
ns.shadeChromaMin = 0.08
ns.shadeStep = 0.005

local M1 = {
    { 0.4122214708, 0.5363325363, 0.0514459929 },
    { 0.2119034982, 0.6806995451, 0.1073969566 },
    { 0.0883024619, 0.2817188376, 0.6299787005 },
}
local M2 = {
    { 0.2104542553, 0.7936177850, -0.0040720468 },
    { 1.9779984951, -2.4285922050, 0.4505937099 },
    { 0.0259040371, 0.7827717662, -0.8086757660 },
}
local INV2 = {
    { 1, 0.3963377774, 0.2158037573 },
    { 1, -0.1055613458, -0.0638541728 },
    { 1, -0.0894841775, -1.2914855480 },
}
local INV1 = {
    { 4.0767416621, -3.3077115913, 0.2309699292 },
    { -1.2684380046, 2.6097574011, -0.3413193965 },
    { -0.0041960863, -0.7034186147, 1.7076147010 },
}

local function lin(c)
    if c <= 0.04045 then return c / 12.92 end
    return ((c + 0.055) / 1.055) ^ 2.4
end

local function unlin(c)
    if c <= 0 then return 0 end
    if c <= 0.0031308 then return 12.92 * c end
    return 1.055 * (c ^ (1 / 2.4)) - 0.055
end

local function cbrt(x)
    if x < 0 then return -((-x) ^ (1 / 3)) end
    return x ^ (1 / 3)
end

local function dot3(m, v)
    return {
        m[1][1] * v[1] + m[1][2] * v[2] + m[1][3] * v[3],
        m[2][1] * v[1] + m[2][2] * v[2] + m[2][3] * v[3],
        m[3][1] * v[1] + m[3][2] * v[2] + m[3][3] * v[3],
    }
end

local function quantize(r, g, b)
    local function byte(v)
        if v < 0 then v = 0 elseif v > 1 then v = 1 end
        return math.floor(v * 255 + 0.5)
    end
    local red, green, blue = byte(r), byte(g), byte(b)
    return {
        hex = string.format("#%02X%02X%02X", red, green, blue),
        red / 255, green / 255, blue / 255,
    }
end

local function rgbOklch(rgb)
    local lms = dot3(M1, { lin(rgb[1]), lin(rgb[2]), lin(rgb[3]) })
    lms[1], lms[2], lms[3] = cbrt(lms[1]), cbrt(lms[2]), cbrt(lms[3])
    local lab = dot3(M2, lms)
    local chroma = math.sqrt(lab[2] * lab[2] + lab[3] * lab[3])
    local hue = math.atan2(lab[3], lab[2]) * 180 / math.pi
    if hue < 0 then hue = hue + 360 end
    return lab[1], chroma, hue
end

local function oklchRgb(L, chroma, hue)
    local h = hue * math.pi / 180
    local a, b = chroma * math.cos(h), chroma * math.sin(h)
    local lms = dot3(INV2, { L, a, b })
    lms[1], lms[2], lms[3] = lms[1] ^ 3, lms[2] ^ 3, lms[3] ^ 3
    local rgb = dot3(INV1, lms)
    return { unlin(rgb[1]), unlin(rgb[2]), unlin(rgb[3]) }
end

local function inGamut(rgb)
    for i = 1, 3 do
        if rgb[i] < -0.0002 or rgb[i] > 1.0002 then return false end
    end
    return true
end

local function maxChroma(L, hue, cap)
    local lo, hi, best = 0, cap, 0
    for _ = 1, 30 do
        local mid = (lo + hi) / 2
        if inGamut(oklchRgb(L, mid, hue)) then
            best = mid
            lo = mid
        else
            hi = mid
        end
    end
    return best
end

-- The chrome shade for a class color on one palette. Nil when no shade
-- inside the floor clears 3:1. The caller then uses the precomputed shade
-- for that class. It does not use the palette accent.
function ns.shiftShade(color, palette, classId)
    if type(color) ~= "table" or type(color[1]) ~= "number" or type(palette) ~= "table" then
        return nil
    end
    local src = quantize(color[1], color[2], color[3])
    if ns.accentPasses(src, palette) then return src end
    local L, chroma, hue = rgbOklch(src)
    if chroma < 0.01 then return nil end
    local n = 1
    while n < 500 do
        local Lt = L + n * ns.shadeStep
        if Lt > ns.shadeLMax + 1e-9 then break end
        n = n + 1
        if Lt >= ns.shadeLMin - 1e-9 and Lt <= ns.shadeLMax + 1e-9 then
            local cap = chroma
            if cap < 0.40 then cap = 0.40 end
            local use = maxChroma(Lt, hue, cap)
            if use > chroma then use = chroma end
            if use + 1e-6 >= ns.shadeChromaMin then
                local raw = oklchRgb(Lt, use, hue)
                local shade = quantize(raw[1], raw[2], raw[3])
                local _, got = rgbOklch(shade)
                if got + 1e-6 >= ns.shadeChromaMin and ns.accentPasses(shade, palette) then
                    return shade
                end
            end
        end
    end
end

-- Precomputed chrome shade for each class on each palette. The shift
-- function reproduces these hexes. A class-color addon that cannot
-- clear 3:1 inside the floor uses this shade for that class.
ns.shadeOf = {
    WARRIOR = {
        ["ember"] = "#C69B6D",
        ["tide"] = "#C69B6D",
        ["dusk"] = "#C69B6D",
        ["ash"] = "#C69B6D",
        ["pine"] = "#C69B6D",
        ["forgeglow"] = "#C69B6D",
        ["nightglass"] = "#C69B6D",
        ["vesper"] = "#C69B6D",
        ["carmine-night"] = "#C69B6D",
        ["gilded"] = "#C69B6D",
        ["phosphor"] = "#C69B6D",
        ["ink"] = "#C69B6D",
        ["sightline"] = "#C69B6D",
        ["warrior"] = "#C69B6D",
        ["mage"] = "#C69B6D",
        ["paladin"] = "#C69B6D",
        ["priest"] = "#C69B6D",
        ["keepstone"] = "#C69B6D",
        ["ironbanner"] = "#C69B6D",
        ["sapphire-crown"] = "#C69B6D",
        ["crownwall"] = "#C69B6D",
        ["deepforge"] = "#C69B6D",
        ["starshade"] = "#C69B6D",
        ["cogspark"] = "#C69B6D",
        ["rustbrand"] = "#C69B6D",
        ["gravelight"] = "#C69B6D",
        ["plainsong"] = "#C69B6D",
        ["junglefire"] = "#C69B6D",
    },
    PALADIN = {
        ["ember"] = "#F58CBA",
        ["tide"] = "#F58CBA",
        ["dusk"] = "#F58CBA",
        ["ash"] = "#F58CBA",
        ["pine"] = "#F58CBA",
        ["forgeglow"] = "#F58CBA",
        ["nightglass"] = "#F58CBA",
        ["vesper"] = "#F58CBA",
        ["carmine-night"] = "#F58CBA",
        ["gilded"] = "#F58CBA",
        ["phosphor"] = "#F58CBA",
        ["ink"] = "#F58CBA",
        ["sightline"] = "#F58CBA",
        ["warrior"] = "#F58CBA",
        ["mage"] = "#F58CBA",
        ["paladin"] = "#F58CBA",
        ["priest"] = "#F58CBA",
        ["keepstone"] = "#F58CBA",
        ["ironbanner"] = "#F58CBA",
        ["sapphire-crown"] = "#F58CBA",
        ["crownwall"] = "#F58CBA",
        ["deepforge"] = "#F58CBA",
        ["starshade"] = "#F58CBA",
        ["cogspark"] = "#F58CBA",
        ["rustbrand"] = "#F58CBA",
        ["gravelight"] = "#F58CBA",
        ["plainsong"] = "#F58CBA",
        ["junglefire"] = "#F58CBA",
    },
    HUNTER = {
        ["ember"] = "#ABD473",
        ["tide"] = "#ABD473",
        ["dusk"] = "#ABD473",
        ["ash"] = "#ABD473",
        ["pine"] = "#ABD473",
        ["forgeglow"] = "#ABD473",
        ["nightglass"] = "#ABD473",
        ["vesper"] = "#ABD473",
        ["carmine-night"] = "#ABD473",
        ["gilded"] = "#ABD473",
        ["phosphor"] = "#ABD473",
        ["ink"] = "#ABD473",
        ["sightline"] = "#ABD473",
        ["warrior"] = "#ABD473",
        ["mage"] = "#ABD473",
        ["paladin"] = "#ABD473",
        ["priest"] = "#ABD473",
        ["keepstone"] = "#ABD473",
        ["ironbanner"] = "#ABD473",
        ["sapphire-crown"] = "#ABD473",
        ["crownwall"] = "#ABD473",
        ["deepforge"] = "#ABD473",
        ["starshade"] = "#ABD473",
        ["cogspark"] = "#ABD473",
        ["rustbrand"] = "#ABD473",
        ["gravelight"] = "#ABD473",
        ["plainsong"] = "#ABD473",
        ["junglefire"] = "#ABD473",
    },
    ROGUE = {
        ["ember"] = "#FFF468",
        ["tide"] = "#FFF468",
        ["dusk"] = "#FFF468",
        ["ash"] = "#FFF468",
        ["pine"] = "#FFF468",
        ["forgeglow"] = "#FFF468",
        ["nightglass"] = "#FFF468",
        ["vesper"] = "#FFF468",
        ["carmine-night"] = "#FFF468",
        ["gilded"] = "#FFF468",
        ["phosphor"] = "#FFF468",
        ["ink"] = "#FFF468",
        ["sightline"] = "#FFF468",
        ["warrior"] = "#FFF468",
        ["mage"] = "#FFF468",
        ["paladin"] = "#FFF468",
        ["priest"] = "#FFF468",
        ["keepstone"] = "#FFF468",
        ["ironbanner"] = "#FFF468",
        ["sapphire-crown"] = "#FFF468",
        ["crownwall"] = "#FFF468",
        ["deepforge"] = "#FFF468",
        ["starshade"] = "#FFF468",
        ["cogspark"] = "#FFF468",
        ["rustbrand"] = "#FFF468",
        ["gravelight"] = "#FFF468",
        ["plainsong"] = "#FFF468",
        ["junglefire"] = "#FFF468",
    },
    PRIEST = {
        ["ember"] = "#FFFFFF",
        ["tide"] = "#FFFFFF",
        ["dusk"] = "#FFFFFF",
        ["ash"] = "#FFFFFF",
        ["pine"] = "#FFFFFF",
        ["forgeglow"] = "#FFFFFF",
        ["nightglass"] = "#FFFFFF",
        ["vesper"] = "#FFFFFF",
        ["carmine-night"] = "#FFFFFF",
        ["gilded"] = "#FFFFFF",
        ["phosphor"] = "#FFFFFF",
        ["ink"] = "#FFFFFF",
        ["sightline"] = "#FFFFFF",
        ["warrior"] = "#FFFFFF",
        ["mage"] = "#FFFFFF",
        ["paladin"] = "#FFFFFF",
        ["priest"] = "#FFFFFF",
        ["keepstone"] = "#FFFFFF",
        ["ironbanner"] = "#FFFFFF",
        ["sapphire-crown"] = "#FFFFFF",
        ["crownwall"] = "#FFFFFF",
        ["deepforge"] = "#FFFFFF",
        ["starshade"] = "#FFFFFF",
        ["cogspark"] = "#FFFFFF",
        ["rustbrand"] = "#FFFFFF",
        ["gravelight"] = "#FFFFFF",
        ["plainsong"] = "#FFFFFF",
        ["junglefire"] = "#FFFFFF",
    },
    DEATHKNIGHT = {
        ["ember"] = "#CD2A41",
        ["tide"] = "#CB2840",
        ["dusk"] = "#CB2840",
        ["ash"] = "#C9253E",
        ["pine"] = "#CB2840",
        ["forgeglow"] = "#C6213B",
        ["nightglass"] = "#D8364A",
        ["vesper"] = "#CB2840",
        ["carmine-night"] = "#C8233D",
        ["gilded"] = "#CB2840",
        ["phosphor"] = "#C8233D",
        ["ink"] = "#C8233D",
        ["sightline"] = "#D23045",
        ["warrior"] = "#D43247",
        ["mage"] = "#CF2C42",
        ["paladin"] = "#CF2C42",
        ["priest"] = "#C9253E",
        ["keepstone"] = "#DA384B",
        ["ironbanner"] = "#CD2A41",
        ["sapphire-crown"] = "#CF2C42",
        ["crownwall"] = "#D63448",
        ["deepforge"] = "#D43247",
        ["starshade"] = "#CB2840",
        ["cogspark"] = "#D12E44",
        ["rustbrand"] = "#D23045",
        ["gravelight"] = "#D12E44",
        ["plainsong"] = "#D12E44",
        ["junglefire"] = "#D23045",
    },
    SHAMAN = {
        ["ember"] = "#0070DD",
        ["tide"] = "#0070DD",
        ["dusk"] = "#0070DD",
        ["ash"] = "#0070DD",
        ["pine"] = "#0070DD",
        ["forgeglow"] = "#0070DD",
        ["nightglass"] = "#0873E0",
        ["vesper"] = "#0070DD",
        ["carmine-night"] = "#0070DD",
        ["gilded"] = "#0070DD",
        ["phosphor"] = "#0070DD",
        ["ink"] = "#0070DD",
        ["sightline"] = "#0070DD",
        ["warrior"] = "#0070DD",
        ["mage"] = "#0070DD",
        ["paladin"] = "#0070DD",
        ["priest"] = "#0070DD",
        ["keepstone"] = "#0C75E2",
        ["ironbanner"] = "#0070DD",
        ["sapphire-crown"] = "#0070DD",
        ["crownwall"] = "#0472DF",
        ["deepforge"] = "#0070DD",
        ["starshade"] = "#0070DD",
        ["cogspark"] = "#0070DD",
        ["rustbrand"] = "#0070DD",
        ["gravelight"] = "#0070DD",
        ["plainsong"] = "#0070DD",
        ["junglefire"] = "#0070DD",
    },
    MAGE = {
        ["ember"] = "#3FC7EB",
        ["tide"] = "#3FC7EB",
        ["dusk"] = "#3FC7EB",
        ["ash"] = "#3FC7EB",
        ["pine"] = "#3FC7EB",
        ["forgeglow"] = "#3FC7EB",
        ["nightglass"] = "#3FC7EB",
        ["vesper"] = "#3FC7EB",
        ["carmine-night"] = "#3FC7EB",
        ["gilded"] = "#3FC7EB",
        ["phosphor"] = "#3FC7EB",
        ["ink"] = "#3FC7EB",
        ["sightline"] = "#3FC7EB",
        ["warrior"] = "#3FC7EB",
        ["mage"] = "#3FC7EB",
        ["paladin"] = "#3FC7EB",
        ["priest"] = "#3FC7EB",
        ["keepstone"] = "#3FC7EB",
        ["ironbanner"] = "#3FC7EB",
        ["sapphire-crown"] = "#3FC7EB",
        ["crownwall"] = "#3FC7EB",
        ["deepforge"] = "#3FC7EB",
        ["starshade"] = "#3FC7EB",
        ["cogspark"] = "#3FC7EB",
        ["rustbrand"] = "#3FC7EB",
        ["gravelight"] = "#3FC7EB",
        ["plainsong"] = "#3FC7EB",
        ["junglefire"] = "#3FC7EB",
    },
    WARLOCK = {
        ["ember"] = "#8788EE",
        ["tide"] = "#8788EE",
        ["dusk"] = "#8788EE",
        ["ash"] = "#8788EE",
        ["pine"] = "#8788EE",
        ["forgeglow"] = "#8788EE",
        ["nightglass"] = "#8788EE",
        ["vesper"] = "#8788EE",
        ["carmine-night"] = "#8788EE",
        ["gilded"] = "#8788EE",
        ["phosphor"] = "#8788EE",
        ["ink"] = "#8788EE",
        ["sightline"] = "#8788EE",
        ["warrior"] = "#8788EE",
        ["mage"] = "#8788EE",
        ["paladin"] = "#8788EE",
        ["priest"] = "#8788EE",
        ["keepstone"] = "#8788EE",
        ["ironbanner"] = "#8788EE",
        ["sapphire-crown"] = "#8788EE",
        ["crownwall"] = "#8788EE",
        ["deepforge"] = "#8788EE",
        ["starshade"] = "#8788EE",
        ["cogspark"] = "#8788EE",
        ["rustbrand"] = "#8788EE",
        ["gravelight"] = "#8788EE",
        ["plainsong"] = "#8788EE",
        ["junglefire"] = "#8788EE",
    },
    MONK = {
        ["ember"] = "#00FF96",
        ["tide"] = "#00FF96",
        ["dusk"] = "#00FF96",
        ["ash"] = "#00FF96",
        ["pine"] = "#00FF96",
        ["forgeglow"] = "#00FF96",
        ["nightglass"] = "#00FF96",
        ["vesper"] = "#00FF96",
        ["carmine-night"] = "#00FF96",
        ["gilded"] = "#00FF96",
        ["phosphor"] = "#00FF96",
        ["ink"] = "#00FF96",
        ["sightline"] = "#00FF96",
        ["warrior"] = "#00FF96",
        ["mage"] = "#00FF96",
        ["paladin"] = "#00FF96",
        ["priest"] = "#00FF96",
        ["keepstone"] = "#00FF96",
        ["ironbanner"] = "#00FF96",
        ["sapphire-crown"] = "#00FF96",
        ["crownwall"] = "#00FF96",
        ["deepforge"] = "#00FF96",
        ["starshade"] = "#00FF96",
        ["cogspark"] = "#00FF96",
        ["rustbrand"] = "#00FF96",
        ["gravelight"] = "#00FF96",
        ["plainsong"] = "#00FF96",
        ["junglefire"] = "#00FF96",
    },
    DRUID = {
        ["ember"] = "#FF7C0A",
        ["tide"] = "#FF7C0A",
        ["dusk"] = "#FF7C0A",
        ["ash"] = "#FF7C0A",
        ["pine"] = "#FF7C0A",
        ["forgeglow"] = "#FF7C0A",
        ["nightglass"] = "#FF7C0A",
        ["vesper"] = "#FF7C0A",
        ["carmine-night"] = "#FF7C0A",
        ["gilded"] = "#FF7C0A",
        ["phosphor"] = "#FF7C0A",
        ["ink"] = "#FF7C0A",
        ["sightline"] = "#FF7C0A",
        ["warrior"] = "#FF7C0A",
        ["mage"] = "#FF7C0A",
        ["paladin"] = "#FF7C0A",
        ["priest"] = "#FF7C0A",
        ["keepstone"] = "#FF7C0A",
        ["ironbanner"] = "#FF7C0A",
        ["sapphire-crown"] = "#FF7C0A",
        ["crownwall"] = "#FF7C0A",
        ["deepforge"] = "#FF7C0A",
        ["starshade"] = "#FF7C0A",
        ["cogspark"] = "#FF7C0A",
        ["rustbrand"] = "#FF7C0A",
        ["gravelight"] = "#FF7C0A",
        ["plainsong"] = "#FF7C0A",
        ["junglefire"] = "#FF7C0A",
    },
    DEMONHUNTER = {
        ["ember"] = "#A532CB",
        ["tide"] = "#A532CB",
        ["dusk"] = "#A532CB",
        ["ash"] = "#A330C9",
        ["pine"] = "#A532CB",
        ["forgeglow"] = "#A330C9",
        ["nightglass"] = "#B03FD7",
        ["vesper"] = "#A532CB",
        ["carmine-night"] = "#A330C9",
        ["gilded"] = "#A532CB",
        ["phosphor"] = "#A330C9",
        ["ink"] = "#A330C9",
        ["sightline"] = "#AB3AD1",
        ["warrior"] = "#AD3CD3",
        ["mage"] = "#A836CE",
        ["paladin"] = "#A836CE",
        ["priest"] = "#A330C9",
        ["keepstone"] = "#B241D8",
        ["ironbanner"] = "#A634CC",
        ["sapphire-crown"] = "#A836CE",
        ["crownwall"] = "#AE3DD5",
        ["deepforge"] = "#AD3CD3",
        ["starshade"] = "#A532CB",
        ["cogspark"] = "#AB3AD1",
        ["rustbrand"] = "#AB3AD1",
        ["gravelight"] = "#A938D0",
        ["plainsong"] = "#AB3AD1",
        ["junglefire"] = "#AB3AD1",
    },
    EVOKER = {
        ["ember"] = "#33937F",
        ["tide"] = "#33937F",
        ["dusk"] = "#33937F",
        ["ash"] = "#33937F",
        ["pine"] = "#33937F",
        ["forgeglow"] = "#33937F",
        ["nightglass"] = "#33937F",
        ["vesper"] = "#33937F",
        ["carmine-night"] = "#33937F",
        ["gilded"] = "#33937F",
        ["phosphor"] = "#33937F",
        ["ink"] = "#33937F",
        ["sightline"] = "#33937F",
        ["warrior"] = "#33937F",
        ["mage"] = "#33937F",
        ["paladin"] = "#33937F",
        ["priest"] = "#33937F",
        ["keepstone"] = "#33937F",
        ["ironbanner"] = "#33937F",
        ["sapphire-crown"] = "#33937F",
        ["crownwall"] = "#33937F",
        ["deepforge"] = "#33937F",
        ["starshade"] = "#33937F",
        ["cogspark"] = "#33937F",
        ["rustbrand"] = "#33937F",
        ["gravelight"] = "#33937F",
        ["plainsong"] = "#33937F",
        ["junglefire"] = "#33937F",
    },
}

local function nativeHex(color)
    if type(color) ~= "table" or type(color[1]) ~= "number" then return nil end
    if type(color.hex) == "string" then return color.hex end
    local function byte(v)
        if v < 0 then v = 0 elseif v > 1 then v = 1 end
        return math.floor(v * 255 + 0.5)
    end
    return string.format("#%02X%02X%02X", byte(color[1]), byte(color[2]), byte(color[3]))
end

-- Chrome accent for this class on this frame. The standard class color uses
-- the precomputed shade. A different color from a class-color addon is
-- shifted the same way. If that shift cannot clear 3:1, the precomputed
-- shade for the class is used. The palette accent is never returned.
function ns.classShade(color, palette, classId)
    if type(palette) ~= "table" or type(palette.id) ~= "string" then return nil end
    local listed = type(classId) == "string" and ns.shadeOf[classId] and ns.shadeOf[classId][palette.id]
    local row = type(classId) == "string" and ns.classById[classId] or nil
    if row and nativeHex(color) == row.color.hex and listed then
        return ns.hexColor(listed)
    end
    local shifted = ns.shiftShade(color, palette, classId)
    if shifted then return shifted end
    if listed then return ns.hexColor(listed) end
end
