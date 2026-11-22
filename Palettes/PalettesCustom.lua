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
    -- A cap at L* 28 can round one step over 28. A hair past that is still
    -- the cap. Anything lighter is rebuilt from the sliders.
    if type(base) == "table" and labOf(base[1], base[2], base[3]) > 28.1 then base = nil end
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
        mood = "Your own background, band and accent, saved at this character.",
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

local function validHex(hex)
    return type(hex) == "string" and string.match(string.upper(hex), "^#?%x%x%x%x%x%x$") ~= nil
end

-- A Custom spec from a shared profile. Missing pieces are filled the way the
-- editor fills them. A base lighter than L* 28 is darkened. The second return
-- is true when that darkening happened.
function ns.profileCustom(raw)
    if type(raw) ~= "table" then return nil, false end
    local capped = type(raw.l) == "number" and raw.l > 28
    local spec = ns.customSpec(raw)
    if not validHex(spec.baseHex) then spec.baseHex = nil end
    if not validHex(spec.accentHex) then spec.accentHex = nil end
    spec = ns.customSpec(spec)
    local base = spec.baseHex and fromHex(spec.baseHex)
    if type(base) == "table" and labOf(base[1], base[2], base[3]) > 28 then
        local shown = shiftL(base, 28)
        local h, s = rgbHsl(shown[1], shown[2], shown[3])
        spec = ns.customSpec({
            h = h, s = s, l = 28,
            ah = spec.ah, as = spec.as, al = spec.al,
            baseHex = shown.hex, accentHex = spec.accentHex,
        })
        capped = true
    end
    local function readable(sample)
        if type(ns.ratio) ~= "function" or type(sample) ~= "table" then return true end
        if ns.ratio(sample.text, sample.background) < 6.6 then return false end
        if ns.ratio(sample.title, sample.background) < 4.5 then return false end
        if ns.ratio(sample.label, sample.background) < 4.5 then return false end
        return true
    end
    if not readable(ns.deriveCustom(spec)) then
        spec.baseHex = nil
        spec.l = 28
        spec = ns.customSpec(spec)
        capped = true
        if not readable(ns.deriveCustom(spec)) then
            spec = ns.customDefaults()
        end
    end
    return spec, capped
end

local function bareHex(hex)
    if type(hex) ~= "string" then return nil end
    return string.match(string.upper(hex), "^#?(%x%x%x%x%x%x)$")
end

-- PAL1-RRGGBB-RRGGBB from the draft the editor is showing. Base, then accent.
function ns.shareCode(spec)
    local palette = ns.deriveCustom(spec)
    local base = type(palette.background) == "table" and bareHex(palette.background.hex)
    local accent = type(palette.c2) == "table" and bareHex(palette.c2.hex)
    if not base or not accent then return nil end
    return "PAL1-" .. base .. "-" .. accent
end

local SHARE_FRAMES = {
    lintel = true, sill = true, stamp = true, trestle = true, flagon = true,
    signboard = true, trough = true, daylight = true, none = true,
}
local SHARE_GLOWS = { wick = true, draught = true, latch = true, daylight = true, none = true }

local function eatToken(body, id)
    if type(body) ~= "string" or type(id) ~= "string" or id == "" then return nil end
    if body == id then return "" end
    local prefix = id .. "-"
    if string.sub(body, 1, #prefix) == prefix then return string.sub(body, #prefix + 1) end
end

local function eatHex(body)
    if type(body) ~= "string" then return nil end
    local hex = string.match(body, "^(%x%x%x%x%x%x)")
    if not hex then return nil end
    local rest = string.sub(body, 7)
    if string.sub(rest, 1, 1) == "-" then rest = string.sub(rest, 2) end
    return string.upper(hex), rest
end

local function eatFrame(body)
    local best, rest
    for id in pairs(SHARE_FRAMES) do
        local left = eatToken(body, id)
        if left ~= nil and (not best or #id > #best) then best, rest = id, left end
    end
    return best, rest
end

local function eatGlow(body)
    local best, rest
    for id in pairs(SHARE_GLOWS) do
        local left = eatToken(body, id)
        if left ~= nil and (not best or #id > #best) then best, rest = id, left end
    end
    return best, rest
end

local function eatPalette(body)
    local best, rest
    local function consider(id)
        local left = eatToken(body, id)
        if left ~= nil and (not best or #id > #best) then best, rest = id, left end
    end
    if type(ns.byId) == "table" then
        for id in pairs(ns.byId) do consider(id) end
    end
    consider("off")
    return best, rest
end

local function parseCustomTail(body)
    local base, rest = eatHex(body)
    local accent, rest2 = eatHex(rest)
    local frame, rest3 = eatFrame(rest2)
    local glow, rest4 = eatGlow(rest3)
    if not base or not accent or not frame or not glow or rest4 ~= "" then return nil end
    return { custom = true, base = base, accent = accent, frame = frame, glow = glow }
end

local function parseLookTail(body)
    local palette, rest = eatPalette(body)
    local frame, rest2 = eatFrame(rest)
    local glow, rest3 = eatGlow(rest2)
    if not palette or not frame or not glow or rest3 ~= "" then return nil end
    return { palette = palette, frame = frame, glow = glow }
end

-- PAL2-theme-palette-frame-glow, PAL2-palette-frame-glow, or PAL2-C-base-accent-frame-glow.
-- A leading theme is included only when one is on. "none" leaves that part alone.
function ns.parseShare(text)
    if type(text) ~= "string" then return nil end
    local trimmed = string.match(text, "^%s*(.-)%s*$") or ""
    local upper = string.upper(trimmed)
    if string.sub(upper, 1, 5) == "PAL1-" then return { kind = "pal1" } end
    if string.sub(upper, 1, 5) ~= "PAL2-" then return nil end
    local body = string.lower(string.gsub(string.sub(trimmed, 6), "#", ""))
    if string.sub(body, 1, 2) == "c-" then
        local tail = parseCustomTail(string.sub(body, 3))
        if not tail then return nil end
        tail.kind = "pal2"
        return tail
    end
    if type(ns.themes) == "table" then
        for i = 1, #ns.themes do
            local id = ns.themes[i].id
            local rest = eatToken(body, id)
            if rest ~= nil then
                local with
                if string.sub(rest, 1, 2) == "c-" then
                    with = parseCustomTail(string.sub(rest, 3))
                else
                    with = parseLookTail(rest)
                end
                if with then
                    with.kind = "pal2"
                    with.theme = id
                    return with
                end
            end
        end
    end
    local plain = parseLookTail(body)
    if not plain then return nil end
    plain.kind = "pal2"
    return plain
end

function ns.pal2Code(part)
    if type(part) ~= "table" then return nil end
    local frame = type(part.frame) == "string" and part.frame or "none"
    local glow = type(part.glow) == "string" and part.glow or "none"
    local theme = type(part.theme) == "string" and part.theme ~= "" and part.theme or nil
    if part.custom == true then
        local base = bareHex(part.base)
        local accent = bareHex(part.accent)
        if not base or not accent then return nil end
        local tail = "C-" .. base .. "-" .. accent .. "-" .. frame .. "-" .. glow
        if theme then return "PAL2-" .. theme .. "-" .. tail end
        return "PAL2-" .. tail
    end
    local palette = type(part.palette) == "string" and part.palette or nil
    if not palette or palette == "" then return nil end
    if theme then return "PAL2-" .. theme .. "-" .. palette .. "-" .. frame .. "-" .. glow end
    return "PAL2-" .. palette .. "-" .. frame .. "-" .. glow
end

local function specFromHex(baseBody, accentBody)
    if type(ns.hexColor) ~= "function" then return nil, "bad" end
    local base = ns.hexColor("#" .. baseBody)
    local accent = ns.hexColor("#" .. accentBody)
    if type(base) ~= "table" or type(accent) ~= "table" then return nil, "bad" end
    local ah, as = rgbHsl(accent[1], accent[2], accent[3])
    local baseL = labOf(base[1], base[2], base[3])
    local accentL = labOf(accent[1], accent[2], accent[3])
    local capped = baseL > 28
    local shown = capped and shiftL(base, 28) or base
    local h, s = rgbHsl(shown[1], shown[2], shown[3])
    return ns.customSpec({
        h = h, s = s, l = capped and 28 or baseL,
        ah = ah, as = as, al = accentL,
        baseHex = shown.hex, accentHex = accent.hex,
    }), capped and "capped" or "applied"
end

-- A code loads a new draft. A bad code returns nothing, so the caller leaves
-- the current draft alone. A base lighter than L* 28 is dropped to 28 in Lab,
-- which is the cap color the editor shows. The accent is not capped.
-- PAL1 and PAL2-C load colors only. A named PAL2 is applied by the page row.
function ns.applyShareCode(text)
    if type(text) ~= "string" then return nil, "bad" end
    local parsed = ns.parseShare(text)
    if type(parsed) == "table" and parsed.kind == "pal2" and parsed.custom == true then
        local frame = parsed.frame ~= "none" and parsed.frame or nil
        local glow = parsed.glow ~= "none" and parsed.glow or nil
        if frame or glow then ns.shareLook = { frame = frame, glow = glow }
        else ns.shareLook = nil end
        return specFromHex(parsed.base, parsed.accent)
    end
    ns.shareLook = nil
    local trimmed = string.match(text, "^%s*(.-)%s*$")
    local raw = trimmed and string.upper(trimmed) or ""
    local baseBody, accentBody = string.match(raw, "^PAL1%-#?(%x%x%x%x%x%x)%-#?(%x%x%x%x%x%x)$")
    if not baseBody then return nil, "bad" end
    return specFromHex(baseBody, accentBody)
end

-- Saving custom colors is a palette pick, so Undo can step back to the previous one.
-- A PAL2-C frame and glow wait until this Save. PAL1 never writes them.
function ns.saveCustom(state, account, char, spec, duringCombat)
    local look = ns.shareLook
    ns.shareLook = nil
    if look and not duringCombat and type(ns.captureUndo) == "function" then
        ns.undoHold = ns.captureUndo("theme")
    end
    ns.writeCustom(account, char, spec)
    if type(ns.choosePalette) == "function" then
        ns.choosePalette(state, account, char, "custom", duringCombat == true)
    end
    if look and not duringCombat and type(ns.applyShareLook) == "function" then
        ns.applyingTheme = true
        ns.applyShareLook(look)
        ns.applyingTheme = false
        if type(ns.notePalette) == "function" then ns.notePalette("custom") end
    elseif look and duringCombat then
        ns.shareLook = look
    end
    return type(state) == "table" and state.current or nil
end

if type(ns.byId) == "table" then
    ns.byId.custom = ns.deriveCustom(ns.customDefaults())
end
