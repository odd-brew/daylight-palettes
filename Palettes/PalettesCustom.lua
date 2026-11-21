-- Custom palette colors. No game calls, so the checker can load it.
--
-- The base is any hue and saturation, with CIE L* capped at 28.
-- Band, border, and ink are derived from that base. The accent is not capped.

local _, ns = ...

local function lin(c)
    if c <= 0.04045 then return c / 12.92 end
    return ((c + 0.055) / 1.055) ^ 2.4
end

local function comp(c)
    if c <= 0 then return 0 end
    if c >= 1 then return 1 end
    if c <= 0.0031308 then return 12.92 * c end
    return 1.055 * (c ^ (1 / 2.4)) - 0.055
end

local Xn, Yn, Zn = 0.95047, 1, 1.08883
local DELTA = 6 / 29
local DELTA3 = DELTA * DELTA * DELTA

local function fLab(t)
    if t > DELTA3 then return t ^ (1 / 3) end
    return t / (3 * DELTA * DELTA) + 4 / 29
end

local function fInv(t)
    local cubed = t * t * t
    if cubed > DELTA3 then return cubed end
    return 3 * DELTA * DELTA * (t - 4 / 29)
end

local function labOf(r, g, b)
    local R, G, B = lin(r), lin(g), lin(b)
    local x = 0.4124564 * R + 0.3575761 * G + 0.1804375 * B
    local y = 0.2126729 * R + 0.7151522 * G + 0.0721750 * B
    local z = 0.0193339 * R + 0.1191920 * G + 0.9503041 * B
    local fy = fLab(y / Yn)
    return 116 * fy - 16, 500 * (fLab(x / Xn) - fy), 200 * (fy - fLab(z / Zn))
end

local function labRgb(L, a, b)
    local fy = (L + 16) / 116
    local x = Xn * fInv(fy + a / 500)
    local y = Yn * fInv(fy)
    local z = Zn * fInv(fy - b / 200)
    return 3.2404542 * x - 1.5371385 * y - 0.4985314 * z,
        -0.9692660 * x + 1.8760108 * y + 0.0415560 * z,
        0.0556434 * x - 0.2040259 * y + 1.0572252 * z
end

local function inGamut(r, g, b)
    return r >= -0.002 and r <= 1.002 and g >= -0.002 and g <= 1.002 and b >= -0.002 and b <= 1.002
end

local function pack(r, g, b)
    r, g, b = comp(r), comp(g), comp(b)
    local function byte(c)
        return math.floor(math.max(0, math.min(1, c)) * 255 + 0.5)
    end
    local R, G, B = byte(r), byte(g), byte(b)
    return {
        hex = string.format("#%02X%02X%02X", R, G, B),
        R / 255, G / 255, B / 255,
    }
end

local function hsl(h, s, l)
    h = h % 360
    local function hue(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1 / 6 then return p + (q - p) * 6 * t end
        if t < 0.5 then return q end
        if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
        return p
    end
    if s <= 0 then return l, l, l end
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    local hk = h / 360
    return hue(p, q, hk + 1 / 3), hue(p, q, hk), hue(p, q, hk - 1 / 3)
end

local function rgbHsl(r, g, b)
    local maxc, minc = math.max(r, g, b), math.min(r, g, b)
    local l = (maxc + minc) / 2
    if maxc == minc then return 0, 0, l end
    local d = maxc - minc
    local s = l > 0.5 and d / (2 - maxc - minc) or d / (maxc + minc)
    local h
    if maxc == r then
        h = (g - b) / d + (g < b and 6 or 0)
    elseif maxc == g then
        h = (b - r) / d + 2
    else
        h = (r - g) / d + 4
    end
    return h * 60, s, l
end

local function packedHsl(h, s, l)
    local r, g, b = hsl(h, s, l)
    return pack(lin(r), lin(g), lin(b))
end

-- sRGB color at this hue and HSL saturation whose CIE L* is as close as
-- possible to the target without going over it. 8-bit rounding is included,
-- so a saturated color does not sneak past the cap.
function ns.colorAtL(h, s, target)
    local lo, hi = 0, 1
    for _ = 1, 24 do
        local mid = (lo + hi) / 2
        local color = packedHsl(h, s, mid)
        if labOf(color[1], color[2], color[3]) <= target then lo = mid else hi = mid end
    end
    return packedHsl(h, s, lo)
end

local function clamp01(n)
    if n < 0 then return 0 end
    if n > 1 then return 1 end
    return n
end

-- Same hue, new CIE L*. Chroma drops until the color fits in sRGB.
local function shiftL(color, target)
    local L, a, b = labOf(color[1], color[2], color[3])
    if target < 0 then target = 0 end
    if target > 100 then target = 100 end
    local scale = 1
    local r, g, bl = labRgb(target, a, b)
    if not inGamut(r, g, bl) then
        local lo, hi = 0, 1
        for _ = 1, 16 do
            local mid = (lo + hi) / 2
            r, g, bl = labRgb(target, a * mid, b * mid)
            if inGamut(r, g, bl) then lo = mid else hi = mid end
        end
        scale = lo
        r, g, bl = labRgb(target, a * scale, b * scale)
    end
    return pack(clamp01(r), clamp01(g), clamp01(bl))
end

function ns.customDefaults()
    -- Dark plum and gold, distinct from Ember before the player edits.
    -- The hexes are the starter swatch. Sliders are the same color, rounded.
    return {
        h = 321, s = 0.42, l = 12, ah = 41, as = 0.72, al = 75,
        baseHex = "#341529", accentHex = "#E2B14A",
    }
end

function ns.customSpec(spec)
    local base = ns.customDefaults()
    if type(spec) ~= "table" then return base end
    local function num(value, fallback)
        if type(value) ~= "number" then return fallback end
        return value
    end
    local out = {
        h = num(spec.h, base.h) % 360,
        s = clamp01(num(spec.s, base.s)),
        l = num(spec.l, base.l),
        ah = num(spec.ah, base.ah) % 360,
        as = clamp01(num(spec.as, base.as)),
        al = num(spec.al, base.al),
    }
    if out.l < 0 then out.l = 0 end
    if out.l > 28 then out.l = 28 end
    if out.al < 0 then out.al = 0 end
    if out.al > 100 then out.al = 100 end
    if type(spec.baseHex) == "string" then out.baseHex = spec.baseHex end
    if type(spec.accentHex) == "string" then out.accentHex = spec.accentHex end
    return out
end

local function fromHex(hex)
    if type(ns.hexColor) == "function" then return ns.hexColor(hex) end
end

local function ink(h, s, mul, cap, l)
    local r, g, b = hsl(h, math.min(s * mul, cap), l)
    return pack(lin(r), lin(g), lin(b))
end

local function hslPack(h, s, l)
    local r, g, b = hsl(h, s, l)
    return pack(lin(r), lin(g), lin(b))
end

function ns.deriveCustom(spec)
    spec = ns.customSpec(spec)
    local base = spec.baseHex and fromHex(spec.baseHex)
    if type(base) == "table" and labOf(base[1], base[2], base[3]) > 28.05 then base = nil end
    if type(base) ~= "table" then base = ns.colorAtL(spec.h, spec.s, spec.l) end
    local accent = spec.accentHex and fromHex(spec.accentHex)
    if type(accent) ~= "table" then accent = ns.colorAtL(spec.ah, spec.as, spec.al) end
    local baseL = labOf(base[1], base[2], base[3])
    local hue, sat = rgbHsl(base[1], base[2], base[3])
    local accentH, accentS, accentL = rgbHsl(accent[1], accent[2], accent[3])
    local function at(delta, cap, floor)
        local target = baseL + delta
        if cap and target > cap then target = cap end
        if floor and target < floor then target = floor end
        return shiftL(base, target)
    end
    local text = ink(hue, sat, 0.50, 0.40, 0.91)
    return {
        id = "custom", name = "Custom", group = "custom",
        mood = "Your own colors.",
        background = base,
        band = at(4, 32, 0),
        bandLit = at(14, 42, 0),
        border = shiftL(base, math.max(2, baseL * 0.35)),
        window = at(-4, nil, 2),
        sidebar = at(-6, nil, 2),
        list = at(-6, nil, 2),
        stage = at(-7, nil, 2),
        card = at(3, nil, 0),
        cardEdge = at(16, 50, 0),
        cardLit = at(12, 48, 0),
        control = at(8, nil, 0),
        controlHover = at(10, nil, 0),
        track = at(10, nil, 0),
        fillTop = at(4, nil, 0),
        fillBottom = at(1, nil, 0),
        buttonBand = at(4, 32, 0),
        buttonBandMain = at(14, 42, 0),
        buttonBandOff = shiftL(base, math.max(2, baseL * 0.35)),
        controlBorder = at(16, 50, 0),
        disabledBorder = at(6, nil, 0),
        rowHover = at(20, 55, 0),
        emptyBorder = at(18, 50, 0),
        title = ink(hue, sat, 0.55, 0.35, 0.96),
        text = text,
        label = ink(hue, sat, 0.40, 0.35, 0.72),
        off = ink(hue, sat, 0.35, 0.30, 0.58),
        c1 = hslPack(accentH, accentS, math.max(0.18, accentL * 0.62)),
        c2 = accent,
        c3 = hslPack(accentH, accentS * 0.70, math.min(0.90, accentL + 0.22)),
    }
end

function ns.customBaseL(spec)
    local palette = ns.deriveCustom(spec)
    return labOf(palette.background[1], palette.background[2], palette.background[3])
end

function ns.customTextRatio(spec)
    local palette = ns.deriveCustom(spec)
    return ns.ratio(palette.text, palette.background), ns.ratio(palette.text, palette.band)
end

function ns.customAccentRatio(spec)
    local palette = ns.deriveCustom(spec)
    return ns.ratio(palette.c2, palette.background)
end

function ns.accentHardToSee(spec)
    return ns.customAccentRatio(spec) < 3
end

function ns.readCustom(account, char)
    local slot
    if type(char) == "table" and char.only == true and type(char.custom) == "table" then
        slot = char.custom
    elseif type(account) == "table" and type(account.custom) == "table" then
        slot = account.custom
    end
    return ns.customSpec(slot)
end

function ns.writeCustom(account, char, spec)
    if type(account) ~= "table" or type(char) ~= "table" then return end
    spec = ns.customSpec(spec)
    if char.only == true then
        char.custom = spec
        return spec
    end
    account.custom = spec
    char.custom = nil
    return spec
end

-- Back keeps the saved spec. The draft is thrown away.
function ns.backCustom(saved)
    return ns.customSpec(saved)
end

function ns.emberCustomSpec()
    local ember = ns.byId and ns.byId.ember
    local base = ember and ember.background
    local accent = ember and ember.c2
    if type(base) ~= "table" or type(accent) ~= "table" then
        return ns.customSpec({ baseHex = "#211812", accentHex = "#E8A04A" })
    end
    local h, s = rgbHsl(base[1], base[2], base[3])
    local ah, as = rgbHsl(accent[1], accent[2], accent[3])
    return ns.customSpec({
        h = h, s = s, l = labOf(base[1], base[2], base[3]),
        ah = ah, as = as, al = labOf(accent[1], accent[2], accent[3]),
        baseHex = base.hex, accentHex = accent.hex,
    })
end

-- Ember's colors for the editor draft. Save is what writes them.
function ns.resetCustomToEmber(account, char)
    return ns.emberCustomSpec()
end

-- Saving custom colors is a palette pick, so Undo can step back to the previous one.
function ns.saveCustom(state, account, char, spec, duringCombat)
    ns.writeCustom(account, char, spec)
    if type(ns.choosePalette) == "function" then
        return ns.choosePalette(state, account, char, "custom", duringCombat == true)
    end
end

if type(ns.byId) == "table" then
    ns.byId.custom = ns.deriveCustom(ns.customDefaults())
end
