-- Palettes recolors Daylight UI's own windows.
--
-- It does not move frames, change your layout, or touch class, reaction,
-- power, quality, or money colors. Those stay Daylight's so combat stays
-- readable.
--
-- How a palette is applied:
--   1. Snapshot Daylight's colors the first time, so "off" can put them back.
--   2. Write new red/green/blue numbers into the tables Daylight already has.
--      The same tables, not copies, because Daylight holds onto them.
--   3. Ask Daylight to use the custom accent and the custom window tint.
--      Daylight only accepts plain settings there, not color tables.
--   4. Ask Daylight to repaint. That repaint waits until combat ends.
--
-- The palettes are dark. Ember is the signed-off look: outline, shadow,
-- tooltip, and chat stay as Daylight paints them. A saved palette that is
-- no longer in the list becomes Ember. Daylight (off) puts the player's
-- colors back.
--
-- Daylight mixes class colors with softness and brightness, so those two
-- settings stay exactly as the player left them.
--
-- v2 adds eight dark palettes on that same path. Class accent replaces the
-- chrome accent with a shade of the player's class color. The shade keeps
-- the hue. Lightness stays between 0.30 and 0.88, and chroma stays at least
-- 0.08. A color that already clears 3:1 is kept. One that does not is
-- lightened until it does. Names, chat, and unit frames stay the game's
-- class color.
--
-- v3 adds the class themes and the realm themes on that same path.
-- While a palette is on, three Daylight surfaces follow it and there is no
-- new setting for any of them:
--   Name tabs on unit, party, and raid frames take the band fill and a 1px
--   accent edge. The name text stays Daylight's name color. The tab frame is
--   private. A missing tab, or a Daylight change that drops it, is skipped.
--   Micro-menu plates take the background, border, and band only while
--   Daylight's own micro-menu style switch is on. Icons stay on the accent.
--   Dark health mode paints the remaining fill with the background and a 1px
--   accent edge. The missing health stays the class or reaction color.
--   Other health modes are left as Daylight painted them.

local _, ns = ...

local paintedId -- palette currently on screen, or nil when Daylight's own colors are showing
-- previous is the one palette Undo can restore. It is not saved, so a /reload starts with Undo off.
-- pending is a pick that is waiting for combat to end. It is not written until then.
local history = { current = "off" }
local heldPaint -- a same-palette repaint that is waiting for combat to end
local listRow
local undoButton
local syncUndo
local refreshList
local applying -- true while we are writing, so our own saves are not treated as the player's edits
local shutting -- true while the UI is logging out or reloading
local warned -- the one chat line about a Daylight version we only partly understand
local skipped -- names of pieces this pass could not update
local ready -- Daylight has enabled the module
local snap -- copies of Daylight's colors from before the first palette
local shownChrome, shownInk -- colors last painted, so the options window can be updated in place
local INK = { title = true, value = true, text = true, label = true, off = true }
local GRADIENT = { c1 = true, c2 = true, c3 = true, c4 = true, c5 = true }

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

local function known(id)
    return id == "off" or (type(id) == "string" and ns.byId[id] ~= nil)
end

-- A saved name that is not a palette any more becomes Ember. "off" stays off.
-- A missing save stays missing, so the first login is still Daylight.
local function fallbackId(id)
    if known(id) then return id end
    if type(id) == "string" and id ~= "" then return "ember" end
end

local function paletteName(id)
    if id == "off" then return "Daylight (off)" end
    local p = type(id) == "string" and ns.byId[id]
    return p and p.name or "off"
end

-- InCombatLockdown is on Forever. A missing function means we are not in combat.
local function inCombat()
    return type(InCombatLockdown) == "function" and InCombatLockdown() == true
end

-- Protected frames reject Show, Hide, and moves during combat. We never call
-- those. Color changes on a protected frame are still skipped in combat.
local function isProtected(frame)
    if not inCombat() or type(frame) ~= "table" or type(frame.IsProtected) ~= "function" then
        return false
    end
    local ok, protected = pcall(frame.IsProtected, frame)
    return ok and protected == true
end

local function dui()
    if type(DaylightUI) == "table" then return DaylightUI end
end

local function style()
    local d = dui()
    if type(d) == "table" and type(d.Style) == "table" then return d.Style end
end

local function optionsColors()
    local d = dui()
    local theme = type(d) == "table" and d.OptionsTheme
    if type(theme) == "table" and type(theme.COLORS) == "table" then return theme.COLORS end
end

local function buttonColors()
    local d = dui()
    local widgets = type(d) == "table" and d.Widgets
    if type(widgets) == "table" and type(widgets.BUTTON) == "table" then return widgets.BUTTON end
end

-- Skins is a second addon. Kit is a function, not a table, and it may be absent.
local function kitTable()
    local d = dui()
    local skins = type(d) == "table" and d.Skins
    if type(skins) ~= "table" or type(skins.Kit) ~= "function" then return nil end
    local ok, kit = pcall(skins.Kit)
    if ok and type(kit) == "table" then return kit end
end

local function setting(path)
    local d = dui()
    if type(d) ~= "table" or type(d.Get) ~= "function" then return nil end
    return d:Get("general", path)
end

local function copy3(color)
    if type(color) ~= "table" or type(color[1]) ~= "number" or type(color[2]) ~= "number" or type(color[3]) ~= "number" then
        return nil
    end
    return { color[1], color[2], color[3] }
end

local function write3(live, color)
    local nextColor = copy3(color)
    if not nextColor or type(live) ~= "table" then return false end
    if type(live[1]) ~= "number" or type(live[2]) ~= "number" or type(live[3]) ~= "number" then
        return false
    end
    live[1], live[2], live[3] = nextColor[1], nextColor[2], nextColor[3]
    return true
end

local function near(a, b)
    return type(a) == "number" and type(b) == "number" and math.abs(a - b) < 0.006
end

local function same3(a, b)
    return type(a) == "table" and type(b) == "table" and near(a[1], b[1]) and near(a[2], b[2]) and near(a[3], b[3])
end

-- The live table Daylight is using for one of our keys, or nil if this
-- version of Daylight does not have it.
local function liveSlot(key)
    local look = style()
    local colors = optionsColors()
    local buttons = buttonColors()
    local kit = kitTable()
    local ink = type(look) == "table" and look.INK
    local gradient = setting("accentGradient")
    if key == "border" then return type(look) == "table" and look.BORDER or nil end
    if key == "band" then return type(look) == "table" and look.BAND or nil end
    if key == "bandLit" then return type(look) == "table" and look.BAND_LIT or nil end
    if key == "background" then return type(look) == "table" and look.BACKGROUND or nil end
    if key == "title" then return type(ink) == "table" and ink.TITLE or nil end
    if key == "value" then return type(ink) == "table" and ink.VALUE or nil end
    if key == "text" then return type(ink) == "table" and ink.TEXT or nil end
    if key == "label" then return type(ink) == "table" and ink.LABEL or nil end
    if key == "off" then return type(ink) == "table" and ink.OFF or nil end
    if key == "window" then return type(colors) == "table" and colors.window or nil end
    if key == "sidebar" then return type(colors) == "table" and colors.sidebar or nil end
    if key == "list" then return type(colors) == "table" and colors.list or nil end
    if key == "stage" then return type(colors) == "table" and colors.stage or nil end
    if key == "card" then return type(colors) == "table" and colors.card or nil end
    if key == "cardEdge" then return type(colors) == "table" and colors.cardEdge or nil end
    if key == "cardLit" then return type(colors) == "table" and colors.cardLit or nil end
    if key == "control" then return type(colors) == "table" and colors.control or nil end
    if key == "controlHover" then return type(colors) == "table" and colors.controlHover or nil end
    if key == "track" then return type(colors) == "table" and colors.track or nil end
    if key == "fillTop" then return type(buttons) == "table" and buttons.fillTop or nil end
    if key == "fillBottom" then return type(buttons) == "table" and buttons.fillBottom or nil end
    if key == "buttonBand" then return type(buttons) == "table" and buttons.band or nil end
    if key == "buttonBandMain" then return type(buttons) == "table" and buttons.bandMain or nil end
    if key == "buttonBandOff" then return type(buttons) == "table" and buttons.bandOff or nil end
    if key == "controlBorder" then return type(kit) == "table" and kit.CONTROL_BORDER or nil end
    if key == "disabledBorder" then return type(kit) == "table" and kit.DISABLED_BORDER or nil end
    if key == "rowHover" then return type(kit) == "table" and kit.ROW_HOVER or nil end
    if key == "emptyBorder" then return type(kit) == "table" and kit.EMPTY_ITEM_BORDER or nil end
    if key == "c1" or key == "c2" or key == "c3" or key == "c4" or key == "c5" then
        return type(gradient) == "table" and gradient[key] or nil
    end
    if key == "tint" then return setting("windowTintColor") end
end

local function paletteMap(p)
    -- Title and value are the same hex in every approved palette.
    return {
        border = p.border, band = p.band, bandLit = p.bandLit, background = p.background,
        title = p.title, value = p.title, text = p.text, label = p.label, off = p.off,
        window = p.window, sidebar = p.sidebar, list = p.list, stage = p.stage,
        card = p.card, cardEdge = p.cardEdge, cardLit = p.cardLit,
        control = p.control, controlHover = p.controlHover, track = p.track,
        fillTop = p.fillTop, fillBottom = p.fillBottom,
        buttonBand = p.buttonBand, buttonBandMain = p.buttonBandMain, buttonBandOff = p.buttonBandOff,
        controlBorder = p.controlBorder, disabledBorder = p.disabledBorder,
        rowHover = p.rowHover, emptyBorder = p.emptyBorder,
        c1 = p.c1, c2 = p.c2, c3 = p.c3,
        tint = p.window,
    }
end

-- One chat line, once per session, naming each piece this Daylight version did not have.
local function skip(what)
    if type(what) ~= "string" or what == "" then return end
    if not skipped then skipped = {} end
    for i = 1, #skipped do
        if skipped[i] == what then return end
    end
    skipped[#skipped + 1] = what
end

local function warnMissing()
    if warned or type(skipped) ~= "table" or #skipped == 0 then return end
    warned = true
    say("Palettes: skipped " .. table.concat(skipped, ", ") .. " in this Daylight version.")
end

local function capture()
    if snap then return type(style()) == "table" end
    if type(style()) ~= "table" then return false end
    snap = {}
    shownChrome, shownInk = {}, {}
    local keys = {
        "border", "band", "bandLit", "background",
        "title", "value", "text", "label", "off",
        "window", "sidebar", "list", "stage", "card", "cardEdge", "cardLit",
        "control", "controlHover", "track",
        "fillTop", "fillBottom", "buttonBand", "buttonBandMain", "buttonBandOff",
        "controlBorder", "disabledBorder", "rowHover", "emptyBorder",
        "c1", "c2", "c3", "c4", "c5", "tint",
    }
    for i = 1, #keys do
        local key = keys[i]
        local copy = copy3(liveSlot(key))
        if copy then
            snap[key] = copy
            local again = { copy[1], copy[2], copy[3] }
            if INK[key] then shownInk[key] = again else shownChrome[key] = again end
        else
            -- c4 and c5 are optional extra gradient stops. Missing kit is reported later.
            if key ~= "c4" and key ~= "c5" and key ~= "controlBorder" and key ~= "disabledBorder"
                and key ~= "rowHover" and key ~= "emptyBorder" then
                skip("style." .. key)
            end
        end
    end
    snap.accent = setting("accent")
    snap.windowTint = setting("windowTint")
    local gradient = setting("accentGradient")
    if type(gradient) == "table" then snap.count = gradient.count end
    return true
end

local function writeMap(map, count)
    local gradient = setting("accentGradient")
    if type(gradient) == "table" then
        if type(count) == "number" and type(gradient.count) == "number" then gradient.count = count end
    else
        skip("accent gradient")
    end
    for key, color in pairs(map) do
        if type(color) == "table" and type(color[1]) == "number" then
            if not write3(liveSlot(key), color) then
                -- Kit colors are one skip below. Extra gradient stops are optional.
                local kitKey = key == "controlBorder" or key == "disabledBorder"
                    or key == "rowHover" or key == "emptyBorder"
                if key ~= "c4" and key ~= "c5" and not kitKey then skip("style." .. key) end
            end
        end
    end
    if kitTable() == nil then skip("skin kit") end
end

local function rememberShown(map)
    shownChrome, shownInk = {}, {}
    for key, color in pairs(map) do
        local copy = copy3(color)
        if copy then
            if INK[key] then shownInk[key] = copy else shownChrome[key] = copy end
        end
    end
end

local function pairsBetween(fromMap, toMap, wantInk)
    local list = {}
    if type(fromMap) ~= "table" or type(toMap) ~= "table" then return list end
    for key, from in pairs(fromMap) do
        local ink = INK[key] == true
        if ink == wantInk and not GRADIENT[key] then
            local to = toMap[key]
            if type(from) == "table" and type(to) == "table" then
                list[#list + 1] = { from[1], from[2], from[3], to[1], to[2], to[3] }
            end
        end
    end
    return list
end

local function matched(list, r, g, b)
    for i = 1, #list do
        local row = list[i]
        if near(r, row[1]) and near(g, row[2]) and near(b, row[3]) then
            return row[4], row[5], row[6]
        end
    end
end

local function semantic(r, g, b)
    local look = style()
    local ink = type(look) == "table" and look.INK
    if type(ink) ~= "table" then return false end
    local keys = { "GOOD", "WARN", "BAD", "DAMAGE", "MONEY" }
    for i = 1, #keys do
        local color = ink[keys[i]]
        if same3(color, { r, g, b }) then return true end
    end
    return false
end

local function paintTex(tex, r, g, b)
    if type(tex) ~= "table" or type(tex.GetVertexColor) ~= "function" or type(tex.SetVertexColor) ~= "function" then
        return
    end
    local _, _, _, alpha = tex:GetVertexColor()
    if type(alpha) == "number" and alpha < 0.2 then return end
    tex:SetVertexColor(r, g, b, type(alpha) == "number" and alpha or 1)
end

local function paintFont(fs, list)
    if type(fs) ~= "table" or type(fs.GetTextColor) ~= "function" or type(fs.SetTextColor) ~= "function" then
        return
    end
    local r, g, b, alpha = fs:GetTextColor()
    if semantic(r, g, b) then return end
    local nr, ng, nb = matched(list, r, g, b)
    if nr then pcall(fs.SetTextColor, fs, nr, ng, nb, type(alpha) == "number" and alpha or 1) end
end

-- The options window paints its colors once, when it is built. Writing the
-- shared tables does not recolor those existing pieces, so we walk only that
-- window and only recolor something that still has a color we previously painted.
local function recolorOptions(texPairs, inkPairs, target)
    local root = _G.DaylightUIOptions
    if type(root) ~= "table" then return end
    local stack, seen, n = { root }, {}, 0
    while #stack > 0 and n < 2500 do
        local frame = stack[#stack]
        stack[#stack] = nil
        if type(frame) == "table" and not seen[frame] and not frame.palettesOwn and not isProtected(frame) then
            seen[frame] = true
            n = n + 1
            -- Cards, the rail, and the page list are built once. Match them by
            -- shape. A missing table in this Daylight version is just skipped.
            local card, edge, lit = target and target.card, target and target.cardEdge, target and target.cardLit
            if frame.bg and frame.edge and frame.lit and frame.title and card and edge and lit then
                paintTex(frame.bg, card[1], card[2], card[3])
                paintTex(frame.edge, edge[1], edge[2], edge[3])
                paintTex(frame.lit, lit[1], lit[2], lit[3])
            elseif target and type(frame.GetWidth) == "function" and frame.bg and not frame.title and not frame.Paint then
                local width = frame:GetWidth()
                local side, list = target.sidebar, target.list
                if type(width) == "number" and side and math.abs(width - 66) < 2 then
                    paintTex(frame.bg, side[1], side[2], side[3])
                elseif type(width) == "number" and list and math.abs(width - 160) < 2 then
                    paintTex(frame.bg, list[1], list[2], list[3])
                end
            end
            if type(frame.GetTextColor) == "function" and type(frame.GetChildren) ~= "function" then
                paintFont(frame, inkPairs)
            elseif type(frame.GetVertexColor) == "function" and type(frame.GetText) ~= "function" then
                local r, g, b, alpha = frame:GetVertexColor()
                if not (type(alpha) == "number" and alpha < 0.2) then
                    local nr, ng, nb = matched(texPairs, r, g, b)
                    if nr then frame:SetVertexColor(nr, ng, nb, type(alpha) == "number" and alpha or 1) end
                end
            end
            if type(frame.Paint) == "function" and frame.band and frame.fill then pcall(frame.Paint) end
            if type(frame.GetRegions) == "function" then
                local regions = { frame:GetRegions() }
                for i = 1, #regions do stack[#stack + 1] = regions[i] end
            end
            if type(frame.GetChildren) == "function" then
                local kids = { frame:GetChildren() }
                for i = 1, #kids do stack[#stack + 1] = kids[i] end
            end
        end
    end
    if target and target.window and type(root.bg) == "table" then
        paintTex(root.bg, target.window[1], target.window[2], target.window[3])
    end
end

local function refreshLook(target)
    if type(target) ~= "table" then return end
    recolorOptions(pairsBetween(shownChrome, target, false), pairsBetween(shownInk, target, true), target)
    rememberShown(target)
end

-- Overrides. Daylight puts the player's old value back when we release one,
-- when they edit that setting, and at logout. Color tables cannot be overridden.
local handles = {}

local function override(path, value)
    for i = 1, #handles do
        if handles[i].path == path then return end
    end
    local d = dui()
    local api = type(d) == "table" and d.API
    if type(api) ~= "table" or type(api.For) ~= "function" then
        skip("setting overrides")
        return
    end
    local view = api.For("Palettes")
    if type(view) ~= "table" or type(view.Override) ~= "function" then
        skip("setting overrides")
        return
    end
    local ok, handle = pcall(view.Override, "general", path, value)
    if ok and type(handle) == "table" then
        handles[#handles + 1] = { ref = handle, path = path }
    else
        skip("setting overrides")
    end
end

local function release(path)
    local d = dui()
    local api = type(d) == "table" and d.API
    local off = type(api) == "table" and api.Off
    for i = #handles, 1, -1 do
        if path == nil or handles[i].path == path then
            local ref = handles[i].ref
            table.remove(handles, i)
            if type(off) == "function" then pcall(off, ref) end
        end
    end
end

local function forget(path)
    for i = #handles, 1, -1 do
        if handles[i].path == path then table.remove(handles, i) end
    end
end

local function notify()
    local d = dui()
    if type(d) == "table" and type(d.NotifyStyleChanged) == "function" then
        pcall(d.NotifyStyleChanged)
    end
end

local function savedColors()
    if not snap then return end
    writeMap(snap, snap.count)
end

local function restore(quiet)
    if snap and paintedId then
        writeMap(snap, snap.count)
        pcall(refreshLook, snap)
        release(nil)
    end
    paintedId = nil
    if not quiet then
        notify()
        pcall(dressExtras)
        say("Palettes: off. Daylight's own colors are restored.")
    end
end

local function lift(path)
    if not paintedId or not snap then return end
    local name = paletteName(paintedId)
    local d = dui()
    applying = true
    local keepAccent, keepTint
    if path == "accent" or path == "accentColor" or path == "accentGradient" then
        keepAccent = path == "accentColor" and "custom" or setting("accent")
    end
    if path == "windowTint" or path == "windowTintColor" then
        keepTint = path == "windowTintColor" and "custom" or setting("windowTint")
    end
    local restored = {}
    for key, color in pairs(snap) do
        if type(color) == "table" then
            local skip = (path == "accentGradient" and GRADIENT[key]) or (path == "windowTintColor" and key == "tint")
            if not skip then restored[key] = color end
        end
    end
    writeMap(restored, path == "accentGradient" and 3 or snap.count)
    pcall(refreshLook, snap)
    release(nil)
    if type(d) == "table" and type(d.Set) == "function" then
        if type(keepAccent) == "string" then d:Set("general", "accent", keepAccent) end
        if type(keepTint) == "string" then d:Set("general", "windowTint", keepTint) end
        d:Set("Palettes", "palette", "off")
    end
    -- The checkbox stays as it is. Only the palette in force is switched off.
    ns.restoreActive(ns.accountTable(), ns.charTable())
    paintedId = nil
    applying = false
    notify()
    pcall(dressExtras)
    say("Palettes: " .. name .. " lifted. Daylight is using your Appearance colors again.")
    ns.resetUndo(history, "off")
    heldPaint = false
end

-- The player's class color. A class-color addon wins, then the game's color.
-- The hex form is the one the contrast check measured. Plain red/green/blue
-- is the fallback when that hex is missing.
local function playerClassColor()
    if type(UnitClass) ~= "function" then return nil, nil end
    local _, token = UnitClass("player")
    if type(token) ~= "string" then return nil, nil end
    local row = type(ns.classById) == "table" and ns.classById[token] or nil
    local live
    if type(CUSTOM_CLASS_COLORS) == "table" then live = CUSTOM_CLASS_COLORS[token] end
    if type(live) ~= "table" and type(RAID_CLASS_COLORS) == "table" then
        live = RAID_CLASS_COLORS[token]
    end
    if type(live) == "table" and type(live.colorStr) == "string" and type(ns.hexColor) == "function" then
        local hex = string.match(live.colorStr, "(%x%x%x%x%x%x)$")
        if hex then
            local color = ns.hexColor("#" .. hex)
            if color then return color, row end
        end
    end
    if type(live) == "table" and type(live.r) == "number" and type(live.g) == "number" and type(live.b) == "number" then
        return { live.r, live.g, live.b }, row
    end
    if row then return row.color, row end
    return nil, nil
end

-- Class accent wins while it is on. The shade is always a class color: the
-- shifted one, or the precomputed shade for that class. Game text is not recolored.
local function accentChoice(frame)
    if type(frame) ~= "table" or type(ns.accentPasses) ~= "function" then return nil, nil, nil end
    local d = dui()
    if type(d) ~= "table" or type(d.Get) ~= "function" then return nil, nil, nil end
    if d:Get("Palettes", "classAccent") ~= true then return nil, nil, nil end
    local color, row = playerClassColor()
    local name = row and row.name or "Class"
    local token = row and row.id
    local shade
    if type(ns.classShade) == "function" then
        shade = ns.classShade(color, frame, token)
    end
    if shade then return shade, name, nil end
    return nil, nil, nil
end

local function resolvedMap(frame)
    local map = paletteMap(frame)
    local color, _, accent = accentChoice(frame)
    if accent then
        map.c1, map.c2, map.c3 = accent.c1, accent.c2, accent.c3
    elseif color then
        -- One flat stop. Daylight's accent is the middle of the gradient,
        -- so all three stops are the class shade and nothing lighter is invented.
        map.c1, map.c2, map.c3 = color, color, color
    end
    return map
end

-- The accent block on a row. Same color apply would write: the class shade
-- while Accent follows class is on, otherwise the palette's own highlight.
local function accentBlock(frame)
    local color, _, accent = accentChoice(frame)
    if type(accent) == "table" then return accent.c2 or color end
    if color then return color end
    if type(frame) == "table" then return frame.c2 end
end

-- The name tab is private. Style.GetShell is public, and so is the Paint
-- callback that tells us a unit, party, raid, or party-pet frame was painted.
-- Anything missing is skipped. The name text is never recolored.
local MICRO_BUTTONS = {
    "CharacterMicroButton", "ProfessionMicroButton", "PlayerSpellsMicroButton", "SpellbookMicroButton",
    "TalentMicroButton", "AchievementMicroButton", "LegacyMicroButton", "QuestLogMicroButton",
    "HousingMicroButton", "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton",
    "EJMicroButton", "HelpMicroButton", "StoreMicroButton", "MainMenuMicroButton",
}
local DARK_FILL = { 0.14, 0.14, 0.14 }
local watching

local function colorOk(color)
    return type(color) == "table" and type(color[1]) == "number"
        and type(color[2]) == "number" and type(color[3]) == "number"
end

local function nearColor(r, g, b, color)
    if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" or not colorOk(color) then
        return false
    end
    return math.abs(r - color[1]) < 0.03 and math.abs(g - color[2]) < 0.03 and math.abs(b - color[3]) < 0.03
end

local function paintShell(Style, shell, full)
    if type(Style) ~= "table" or type(shell) ~= "table" then return end
    if full and type(Style.LayoutShell) == "function" then
        pcall(Style.LayoutShell, shell)
        return
    end
    if type(Style.PaintBack) == "function" then pcall(Style.PaintBack, shell) end
    if type(Style.PaintShellColors) == "function" then pcall(Style.PaintShellColors, shell) end
end

local function dressShell(shell, bg, border, band, thin)
    if type(shell) ~= "table" or type(shell.opts) ~= "table" then return false end
    if shell.palettesSaved == nil then
        local opts = shell.opts
        shell.palettesSaved = {
            bgColor = opts.bgColor, borderColor = opts.borderColor, bandColor = opts.bandColor,
            borderPx = opts.borderPx, flat = opts.flat,
        }
    end
    local opts = shell.opts
    -- A copy, so a later shell write cannot change the palette table.
    local function copy(color)
        return { color[1], color[2], color[3] }
    end
    if colorOk(bg) then opts.bgColor = copy(bg) end
    if colorOk(border) then opts.borderColor = copy(border) end
    if colorOk(band) then opts.bandColor = copy(band) end
    if thin then
        opts.borderPx = 1
        opts.flat = true
    end
    return true
end

local function restoreShell(shell)
    local saved = type(shell) == "table" and shell.palettesSaved
    if type(saved) ~= "table" or type(shell.opts) ~= "table" then return false end
    shell.opts.bgColor = saved.bgColor
    shell.opts.borderColor = saved.borderColor
    shell.opts.bandColor = saved.bandColor
    shell.opts.borderPx = saved.borderPx
    shell.opts.flat = saved.flat
    shell.palettesSaved = nil
    return true
end

local function shellOf(Style, frame)
    if type(Style) ~= "table" or type(Style.GetShell) ~= "function" or type(frame) ~= "table" then
        return nil
    end
    local ok, shell = pcall(Style.GetShell, frame)
    if ok and type(shell) == "table" then return shell end
end

local function dressOneTab(host, band, accent, Style)
    if type(host) ~= "table" then return end
    local shell = shellOf(Style, host)
    if type(shell) ~= "table" then return end
    if not colorOk(band) or not colorOk(accent) then
        if restoreShell(shell) then paintShell(Style, shell, true) end
        return
    end
    local relayout = type(shell.opts) ~= "table" or shell.opts.borderPx ~= 1 or shell.opts.flat ~= true
    if dressShell(shell, band, accent, band, true) then paintShell(Style, shell, relayout) end
end

-- frame.tab is the name tab on a unit frame. frame.nameTag is the tab a party
-- or raid tile uses when the name sits outside the tile. parts.row is the
-- same tab when Daylight exposes it. A missing one is skipped.
local function dressTab(frame, parts, band, accent, Style)
    local seen = false
    if type(frame) == "table" and type(frame.tab) == "table" then
        seen = true
        dressOneTab(frame.tab, band, accent, Style)
    end
    if type(frame) == "table" and type(frame.nameTag) == "table" then
        seen = true
        dressOneTab(frame.nameTag, band, accent, Style)
    end
    if not seen and type(parts) == "table" then dressOneTab(parts.row, band, accent, Style) end
end

local function buttonChildren(btn)
    local list = {}
    if type(btn) ~= "table" or type(btn.GetChildren) ~= "function" then return list end
    if not pcall(function()
        local packed = { btn:GetChildren() }
        for i = 1, #packed do list[i] = packed[i] end
    end) then
        return {}
    end
    return list
end

-- Plates follow the palette only while Daylight's micro-menu style switch is on
-- (ActionBars skinMenus). Off returns before any button is touched. Icons are
-- not recolored here. Daylight keeps painting them with the accent.
local function dressMicro(bg, border, band)
    local d = dui()
    if type(d) ~= "table" or type(d.Get) ~= "function" then return end
    if d:Get("ActionBars", "skinMenus") ~= true then return end
    local Style = style()
    if type(Style) ~= "table" then return end
    local on = colorOk(bg) and colorOk(border) and colorOk(band)
    for i = 1, #MICRO_BUTTONS do
        local btn = _G[MICRO_BUTTONS[i]]
        local kids = buttonChildren(btn)
        for n = 1, #kids do
            local shell = shellOf(Style, kids[n])
            if type(shell) == "table" and (on or shell.palettesSaved) then
                local first = shell.palettesSaved == nil
                local changed = on and dressShell(shell, bg, border, band, false) or restoreShell(shell)
                if changed then paintShell(Style, shell, first) end
            end
        end
    end
end

local function healthMode(frame)
    local own = type(frame) == "table" and frame.healthMode
    if type(own) == "string" and own ~= "" and own ~= "global" then return own end
    local d = dui()
    if type(d) ~= "table" or type(d.Get) ~= "function" then return nil end
    local mode = d:Get("UnitFrames", "colors.health")
    if type(mode) == "string" then return mode end
end

local function edgePx(bar)
    local d = dui()
    local pixel = type(d) == "table" and d.Pixel
    if type(pixel) == "table" and type(pixel.Px) == "function" then
        local ok, n = pcall(pixel.Px, bar, 1)
        if ok and type(n) == "number" and n > 0 then return n end
    end
    return 1
end

local function healthEdge(bar)
    if type(bar) ~= "table" then return nil end
    if type(bar.palettesEdge) == "table" then return bar.palettesEdge end
    if type(CreateFrame) ~= "function" then return nil end
    local frame
    if not pcall(function()
        frame = CreateFrame("Frame", nil, bar)
        frame:SetAllPoints(bar)
        if frame.EnableMouse then frame:EnableMouse(false) end
        if frame.SetFrameLevel and bar.GetFrameLevel then
            frame:SetFrameLevel((bar:GetFrameLevel() or 0) + 2)
        end
        local lines = {}
        for i = 1, 4 do
            local tex = frame:CreateTexture(nil, "OVERLAY")
            if type(tex) == "table" and tex.SetColorTexture then tex:SetColorTexture(1, 1, 1, 1) end
            lines[i] = tex
        end
        frame.lines = lines
    end) or type(frame) ~= "table" then
        return nil
    end
    bar.palettesEdge = frame
    return frame
end

local function placeEdge(frame, bar, color)
    local lines = type(frame) == "table" and frame.lines
    if type(lines) ~= "table" or not colorOk(color) then return end
    local px = edgePx(bar)
    local anchors = {
        { "TOPLEFT", "TOPRIGHT", 0, 0, 0, -px },
        { "BOTTOMLEFT", "BOTTOMRIGHT", 0, px, 0, 0 },
        { "TOPLEFT", "BOTTOMLEFT", 0, 0, px, 0 },
        { "TOPRIGHT", "BOTTOMRIGHT", -px, 0, 0, 0 },
    }
    for i = 1, 4 do
        local tex = lines[i]
        local spot = anchors[i]
        if type(tex) == "table" and tex.ClearAllPoints and tex.SetPoint then
            tex:ClearAllPoints()
            tex:SetPoint(spot[1], frame, spot[1], spot[3], spot[4])
            tex:SetPoint(spot[2], frame, spot[2], spot[5], spot[6])
            if tex.SetColorTexture then tex:SetColorTexture(color[1], color[2], color[3], 1) end
            if tex.Show then tex:Show() end
        end
    end
    if frame.Show then frame:Show() end
end

-- Dark health only. The remaining fill is the palette background, with a 1px
-- accent edge. The missing part is the bar background Daylight already painted
-- in the class or reaction color, and this does not write that texture.
-- Any other mode hides the edge and leaves the fill alone.
local function dressHealth(frame, parts, bg, accent)
    local bar = type(parts) == "table" and type(parts.health) == "table" and parts.health
        or type(frame) == "table" and frame.health
    if type(bar) ~= "table" or type(bar.SetStatusBarColor) ~= "function" or type(bar.GetStatusBarColor) ~= "function" then
        return
    end
    local edge = bar.palettesEdge
    local function hide()
        if type(edge) == "table" and edge.Hide then edge:Hide() end
    end
    if healthMode(frame) ~= "dark" or not colorOk(bg) or not colorOk(accent) then
        hide()
        return
    end
    local r, g, b = bar:GetStatusBarColor()
    if not (nearColor(r, g, b, DARK_FILL) or nearColor(r, g, b, bg)) then
        hide()
        return
    end
    pcall(bar.SetStatusBarColor, bar, bg[1], bg[2], bg[3], 1)
    local made = healthEdge(bar)
    if type(made) == "table" then pcall(placeEdge, made, bar, accent) end
end

local function chromeMap()
    if not paintedId or paintedId == "off" then return nil end
    local frame = ns.byId[paintedId]
    if type(frame) ~= "table" then return nil end
    return resolvedMap(frame)
end

local function dressExtras()
    local map = chromeMap()
    if map then dressMicro(map.background, map.border, map.band) else dressMicro(nil, nil, nil) end
end

local function onPaintedFrame(frame, parts)
    if type(frame) ~= "table" then return end
    local map = chromeMap()
    local Style = style()
    if not map then
        dressTab(frame, parts, nil, nil, Style)
        dressHealth(frame, parts, nil, nil)
        return
    end
    dressTab(frame, parts, map.band, map.c2, Style)
    dressHealth(frame, parts, map.background, map.c2)
end

local function watchFrames()
    if watching then return end
    local d = dui()
    local api = type(d) == "table" and d.API
    if type(api) ~= "table" or type(api.For) ~= "function" then return end
    local view = api.For("Palettes")
    if type(view) ~= "table" or type(view.Paint) ~= "function" then return end
    watching = true
    local kinds = { "unit", "party", "raid", "partypet" }
    for i = 1, #kinds do
        local kind = kinds[i]
        pcall(function()
            view:Paint(kind, function(frame, parts)
                pcall(onPaintedFrame, frame, parts)
            end)
        end)
    end
end

local function queueLine(id)
    say("Palettes: " .. paletteName(id) .. " queued until combat ends.")
end

local function apply(id, fromQueue)
    if not known(id) then return end
    if not fromQueue and inCombat() then
        if id ~= history.current then
            history.pending = id
            heldPaint = false
            queueLine(id)
        else
            heldPaint = true
        end
        if refreshList then refreshList() end
        return
    end
    history.pending = nil
    heldPaint = false
    applying = true
    skipped = nil
    if id == "off" then
        restore(false)
        history.current = "off"
        applying = false
        if refreshList then refreshList() end
        return
    end
    local p = ns.byId[id]
    if not capture() then
        applying = false
        skip("style colors")
        warnMissing()
        return
    end
    local map = resolvedMap(p)
    writeMap(map, 3)
    override("accent", "customGradient")
    override("windowTint", "custom")
    pcall(refreshLook, map)
    paintedId = id
    history.current = id
    applying = false
    notify()
    pcall(dressExtras)
    warnMissing()
    say("Palettes: " .. p.name .. " is on. Your layout is unchanged.")
    if refreshList then refreshList() end
end

-- PalettesAccount is the palette every character uses until they opt out.
-- PalettesChar is this character only. only means "Save for this character only":
-- palette and classAccent on that table then replace the account ones.
-- seeded means a character has already filled in the account palette.
-- ready means this character's upgrade from 0.1.0 has already run.

function ns.accountTable()
    if type(PalettesAccount) ~= "table" then PalettesAccount = {} end
    return PalettesAccount
end

function ns.charTable()
    if type(PalettesChar) ~= "table" then PalettesChar = {} end
    return PalettesChar
end

local function hasLegacy(db)
    return type(db) == "table" and (type(db.own) == "string" or type(db.everyCharacter) == "boolean")
end

-- What 0.1.0 was showing. "Every character" used the account palette.
-- Otherwise this character's own pick won, then the palette setting.
local function legacyLook(account, db)
    local accent = type(db) == "table" and db.classAccent == true
    if type(account) == "table" and account.every == true then
        return fallbackId(account.palette) or "off", accent
    end
    if type(db) ~= "table" then return "off", false end
    return fallbackId(db.own) or fallbackId(db.palette) or "off", accent
end

local function activeLook(account, char)
    if type(account) ~= "table" then account = {} end
    if type(char) ~= "table" then char = {} end
    if char.only == true then
        local accent = char.classAccent
        if type(accent) ~= "boolean" then accent = account.classAccent == true end
        return fallbackId(char.palette) or fallbackId(account.palette) or "off", accent == true, true
    end
    return fallbackId(account.palette) or "off", account.classAccent == true, false
end

function ns.activeLook(account, char)
    return activeLook(account, char)
end

-- A name that is not a palette any more becomes Ember, same as a fresh login.
local function normalizeSaved(account, char)
    if type(account.palette) == "string" and not known(account.palette) then
        account.palette = fallbackId(account.palette) or "off"
    end
    if type(char.palette) == "string" and not known(char.palette) then
        char.palette = fallbackId(char.palette) or "off"
    end
end

function ns.setPalette(account, char, id)
    if type(account) ~= "table" or type(char) ~= "table" then return end
    id = fallbackId(id) or "off"
    if char.only == true then
        char.palette = id
        return
    end
    account.palette = id
    char.palette = nil
    char.classAccent = nil
end

-- Undo is one step, and only for this session. previous is nil at login.
-- A combat pick stays in pending until combat ends, so cancelling it writes nothing.
function ns.undoReady(state)
    return type(state) == "table" and (state.pending ~= nil or state.previous ~= nil)
end

function ns.resetUndo(state, id)
    if type(state) ~= "table" then return end
    state.current = id or "off"
    state.previous = nil
    state.pending = nil
end

function ns.choosePalette(state, account, char, id, duringCombat)
    if type(state) ~= "table" then return end
    id = fallbackId(id) or "off"
    if duringCombat then
        if id ~= state.current then
            state.pending = id
            -- Saved now, so a reload keeps the pick. The screen waits for combat.
            if type(account) == "table" and type(char) == "table" then
                ns.setPalette(account, char, id)
            end
        else
            state.pending = nil
        end
        return state.current
    end
    state.pending = nil
    if id ~= state.current then
        state.previous = state.current
        state.current = id
        if type(account) == "table" and type(char) == "table" then
            ns.setPalette(account, char, id)
        end
    end
    return state.current
end

function ns.undoPalette(state, account, char)
    if type(state) ~= "table" then return end
    if state.pending ~= nil then
        state.pending = nil
        -- The waiting pick was saved early. Put the palette on screen back.
        if type(account) == "table" and type(char) == "table" then
            ns.setPalette(account, char, state.current)
        end
        return state.current
    end
    if state.previous == nil then return state.current end
    state.current = state.previous
    state.previous = nil
    if type(account) == "table" and type(char) == "table" then
        ns.setPalette(account, char, state.current)
    end
    return state.current
end

function ns.finishCombat(state, account, char)
    if type(state) ~= "table" then return end
    local id = state.pending
    state.pending = nil
    if id == nil or id == state.current then return state.current end
    state.previous = state.current
    state.current = id
    if type(account) == "table" and type(char) == "table" then
        ns.setPalette(account, char, id)
    end
    return state.current
end

function ns.setClassAccent(account, char, on)
    if type(account) ~= "table" or type(char) ~= "table" then return end
    on = on == true
    if char.only == true then
        char.classAccent = on
        return
    end
    account.classAccent = on
    char.palette = nil
    char.classAccent = nil
end

-- Ticking copies the account look onto this character, so the screen does not jump.
-- Unticking throws that copy away and this character follows the account again.
function ns.setOnly(account, char, on)
    if type(account) ~= "table" or type(char) ~= "table" then
        return activeLook(account, char)
    end
    if on == true then
        if char.only ~= true then
            char.palette = fallbackId(account.palette) or "off"
            char.classAccent = account.classAccent == true
        end
        char.only = true
    else
        char.only = false
        char.palette = nil
        char.classAccent = nil
    end
    char.ready = true
    return activeLook(account, char)
end

function ns.restoreActive(account, char)
    ns.setPalette(account, char, "off")
    return activeLook(account, char)
end

-- Runs once per character. The first character logged in after 0.1.0 becomes
-- the account palette. A later character keeps a different look, with the box on.
-- A character who already ran this is left alone, including on the next login.
function ns.migrateLogin(account, char, db)
    if type(account) ~= "table" or type(char) ~= "table" then
        return "off", false, false
    end
    if char.ready == true then
        normalizeSaved(account, char)
        return activeLook(account, char)
    end
    if account.seeded ~= true then
        local id, accent = legacyLook(account, db)
        account.legacyEvery = account.every == true
        account.palette = id
        account.classAccent = accent == true
        account.seeded = true
        account.every = nil
        char.only = false
        char.palette = nil
        char.classAccent = nil
        char.ready = true
        return id, accent == true, false
    end
    if not hasLegacy(db) then
        char.only = false
        char.palette = nil
        char.classAccent = nil
        char.ready = true
        return activeLook(account, char)
    end
    local id, accent = legacyLook(account, db)
    if account.legacyEvery == true then
        id = fallbackId(account.palette) or "off"
    end
    local samePalette = id == (fallbackId(account.palette) or "off")
    local sameAccent = (accent == true) == (account.classAccent == true)
    if samePalette and sameAccent then
        char.only = false
        char.palette = nil
        char.classAccent = nil
    else
        char.only = true
        char.palette = id
        char.classAccent = accent == true
    end
    char.ready = true
    return activeLook(account, char)
end

-- SettingChanged is (scope, path, value). scope is "general" or a module name.
local function onSetting(scope, path)
    if applying or shutting then return end
    local d = dui()
    if type(d) ~= "table" or type(d.Get) ~= "function" then return end
    if scope == "Palettes" and path == "palette" then
        local id = fallbackId(d:Get("Palettes", "palette")) or "off"
        if d:Get("Palettes", "palette") ~= id and type(d.Set) == "function" then
            applying = true
            d:Set("Palettes", "palette", id)
            applying = false
        end
        if inCombat() then
            ns.choosePalette(history, ns.accountTable(), ns.charTable(), id, true)
            if history.pending then
                heldPaint = false
                queueLine(history.pending)
            end
            applying = true
            if type(d.Set) == "function" and d:Get("Palettes", "palette") ~= history.current then
                d:Set("Palettes", "palette", history.current)
            end
            applying = false
            if refreshList then refreshList() end
            return
        end
        ns.choosePalette(history, ns.accountTable(), ns.charTable(), id, false)
        apply(id, true)
        return
    end
    if scope == "Palettes" and path == "only" then
        local beforeId = d:Get("Palettes", "palette")
        local beforeAccent = d:Get("Palettes", "classAccent") == true
        local id, accent = ns.setOnly(ns.accountTable(), ns.charTable(), d:Get("Palettes", "only") == true)
        applying = true
        if beforeId ~= id then d:Set("Palettes", "palette", id) end
        if beforeAccent ~= (accent == true) then d:Set("Palettes", "classAccent", accent == true) end
        applying = false
        if id ~= beforeId then
            history.current = id
            history.previous = nil
            history.pending = nil
            heldPaint = false
        end
        if id ~= beforeId or (accent == true) ~= beforeAccent then apply(id) end
        return
    end
    if scope == "Palettes" and path == "classAccent" then
        ns.setClassAccent(ns.accountTable(), ns.charTable(), d:Get("Palettes", "classAccent") == true)
        local id = d:Get("Palettes", "palette")
        if known(id) and id ~= "off" then apply(id) elseif refreshList then refreshList() end
        return
    end
    if scope ~= "general" or not paintedId then return end
    if path == "accent" and snap and d:Get("general", "accent") == snap.accent then return end
    if path == "windowTint" and snap and d:Get("general", "windowTint") == snap.windowTint then return end
    if path == "accent" or path == "accentColor" or path == "accentGradient"
        or path == "windowTint" or path == "windowTintColor" then
        lift(path)
    end
end

local function joinOr(list)
    if #list == 0 then return "" end
    if #list == 1 then return list[1] end
    local head = {}
    for i = 1, #list - 1 do head[i] = list[i] end
    return table.concat(head, ", ") .. ", or " .. list[#list]
end

local function statusLine()
    local d = dui()
    local id = "off"
    if history.pending and history.pending ~= history.current then
        return "Palettes: " .. paletteName(history.pending) .. " queued until combat ends."
    end
    if type(d) == "table" and type(d.Get) == "function" then
        local saved = d:Get("Palettes", "palette")
        if known(saved) then id = saved end
    end
    local names = {}
    for g = 1, #ns.groups do
        local group = ns.groups[g]
        for i = 1, #group.ids do
            if group.ids[i] ~= id then names[#names + 1] = group.ids[i] end
        end
    end
    if id ~= "off" then
        names[#names + 1] = "off"
        return "Palettes: " .. paletteName(id) .. " is on. Type /palettes " .. joinOr(names) .. "."
    end
    -- off is already the current state, so the hint lists the palette names instead.
    names = {}
    for g = 1, #ns.groups do
        local group = ns.groups[g]
        for i = 1, #group.ids do names[#names + 1] = group.ids[i] end
    end
    names[#names + 1] = "off"
    return "Palettes: off. Type /palettes " .. joinOr(names) .. "."
end

local function slash(msg)
    if not ready then
        say("Palettes: Daylight UI isn't ready, so no palette was changed.")
        return
    end
    local d = dui()
    if type(d) ~= "table" or type(d.Set) ~= "function" then
        say("Palettes: Daylight UI isn't ready, so no palette was changed.")
        return
    end
    local arg = string.lower(trim(msg or ""))
    -- "carmine night" and "bone and ash" are the same ids as the hyphenated slash names.
    arg = string.gsub(arg, "%s+", "-")
    if arg == "" then
        say(statusLine())
        return
    end
    if arg == "daylight" then arg = "off" end
    if not known(arg) then
        say(statusLine())
        return
    end
    if d:Set("Palettes", "palette", arg) == false then
        say("Palettes: Daylight UI isn't ready, so no palette was changed.")
    end
end

-- The Plugins page draws its own list. Daylight's dropdown can preview a font
-- or a bar texture file. It has no per-row color, so each theme row draws its
-- background, band, and accent here.
local function uiFont(fs, from, size, color)
    local file, current
    if type(from) == "table" and type(from.GetFont) == "function" then file, current = from:GetFont() end
    if type(file) ~= "string" then
        local fallback = GameFontHighlight
        if type(fallback) == "table" and type(fallback.GetFont) == "function" then file, current = fallback:GetFont() end
    end
    if type(file) == "string" and type(fs.SetFont) == "function" then
        local height = size or current or 12
        if not pcall(fs.SetFont, fs, file, height, "") and not pcall(fs.SetFont, fs, "Fonts\\FRIZQT__.TTF", height, "") then
            return
        end
    elseif type(fs.SetFont) == "function" then
        pcall(fs.SetFont, fs, "Fonts\\FRIZQT__.TTF", size or 12, "")
    end
    if type(color) == "table" and type(color[1]) == "number" and type(fs.SetTextColor) == "function" then
        pcall(fs.SetTextColor, fs, color[1], color[2], color[3], 1)
    end
end

-- SetText before SetFont errors on this client, and that error used to collapse the whole list.
local function blankText(parent)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    if type(fs) ~= "table" then return nil end
    uiFont(fs, nil, 12, nil)
    return fs
end

local function paintSwatch(tex, color)
    if type(tex) ~= "table" or type(color) ~= "table" or type(tex.SetColorTexture) ~= "function" then return end
    tex:SetColorTexture(color[1], color[2], color[3], 1)
end

local function offColor(key)
    if snap and type(snap[key]) == "table" then return snap[key] end
    local look = style()
    if type(look) ~= "table" then return nil end
    if key == "window" or key == "background" then return copy3(look.BACKGROUND) end
    if key == "band" then return copy3(look.BAND) end
    if key == "text" then return type(look.INK) == "table" and copy3(look.INK.TEXT) or nil end
    if key == "c2" then return copy3(look.ACCENT) end
    if key == "border" then return copy3(look.BORDER) end
end

local function currentId()
    local d = dui()
    if type(d) == "table" and type(d.Get) == "function" then
        local id = fallbackId(d:Get("Palettes", "palette"))
        if id then return id end
    end
    return paintedId or "off"
end

local function buildList(row)
    -- Drawn once. A second call would stack another copy of the list on the same row.
    if row.palettesTried then return end
    row.palettesTried = true
    if type(row) ~= "table" or type(row.CreateFontString) ~= "function" then
        row.palettesHeight = 36
        skip("palette list: the options row cannot draw text")
        return
    end
    local function draw()
    row.palettesOwn = true
    local ink = type(row.label) == "table" and row.label or nil
    local entries = {}
    local y = -8

    local note = blankText(row)
    note:SetPoint("TOPLEFT", row, "TOPLEFT", 12, y)
    note:SetPoint("TOPRIGHT", row, "TOPRIGHT", -12, y)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText("Applies immediately out of combat. Some text changes color after a /reload.")
    y = y - 32

    local function addHeader(text)
        local fs = blankText(row)
        fs:SetPoint("TOPLEFT", row, "TOPLEFT", 12, y)
        fs.palettesText = text
        y = y - 20
        return fs
    end

    local function addChoice(id, name, mood, withSwatch)
        local button = CreateFrame("Button", nil, row)
        button:SetPoint("TOPLEFT", row, "TOPLEFT", 4, y)
        button:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, y)
        button:SetHeight(28)
        local wash = button:CreateTexture(nil, "BACKGROUND")
        wash:SetAllPoints(button)
        local edge, bgSwatch, bandSwatch, accentSwatch
        local nameText = blankText(button)
        if withSwatch then
            -- One pixel of the border color keeps a dark band from disappearing.
            -- The accent block is a little wider than the background and the band.
            edge = button:CreateTexture(nil, "BORDER")
            edge:SetSize(44, 16)
            edge:SetPoint("LEFT", button, "LEFT", 8, 0)
            bgSwatch = button:CreateTexture(nil, "ARTWORK")
            bgSwatch:SetSize(12, 14)
            bgSwatch:SetPoint("LEFT", edge, "LEFT", 1, 0)
            bandSwatch = button:CreateTexture(nil, "ARTWORK")
            bandSwatch:SetSize(12, 14)
            bandSwatch:SetPoint("LEFT", bgSwatch, "RIGHT", 1, 0)
            accentSwatch = button:CreateTexture(nil, "ARTWORK")
            accentSwatch:SetSize(16, 14)
            accentSwatch:SetPoint("LEFT", bandSwatch, "RIGHT", 1, 0)
            nameText:SetPoint("LEFT", edge, "RIGHT", 8, 0)
        else
            nameText:SetPoint("LEFT", button, "LEFT", 8, 0)
        end
        nameText:SetWidth(120)
        nameText:SetJustifyH("LEFT")
        nameText:SetWordWrap(false)
        local moodText = blankText(button)
        moodText:SetPoint("LEFT", nameText, "RIGHT", 6, 0)
        moodText:SetPoint("RIGHT", button, "RIGHT", -88, 0)
        moodText:SetJustifyH("LEFT")
        moodText:SetWordWrap(false)
        local onText = blankText(button)
        onText:SetPoint("RIGHT", button, "RIGHT", -8, 0)
        button:SetScript("OnClick", function()
            local d = dui()
            if type(d) == "table" and type(d.Set) == "function" then d:Set("Palettes", "palette", id) end
        end)
        entries[#entries + 1] = {
            id = id, name = name, mood = mood, wash = wash,
            edge = edge, bgSwatch = bgSwatch, bandSwatch = bandSwatch, accentSwatch = accentSwatch,
            nameText = nameText, moodText = moodText, onText = onText,
        }
        y = y - 28
    end

    local headers = {}
    for g = 1, #ns.groups do
        local group = ns.groups[g]
        headers[#headers + 1] = addHeader(group.label)
        for i = 1, #group.ids do
            local p = ns.byId[group.ids[i]]
            addChoice(p.id, p.name, p.mood, true)
        end
    end
    headers[#headers + 1] = addHeader("Restore")
    addChoice(ns.off.id, ns.off.name, ns.off.mood, false)
    local combatNote = blankText(row)
    combatNote:SetPoint("TOPLEFT", row, "TOPLEFT", 12, y)
    combatNote:SetPoint("TOPRIGHT", row, "TOPRIGHT", -12, y)
    combatNote:SetJustifyH("LEFT")
    combatNote:SetText("Applies when combat ends.")
    if combatNote.SetShown then combatNote:SetShown(false) end
    y = y - 18
    row.palettesHeight = -y + 8
    listRow = row

    function row.palettesRefresh()
        local id = currentId()
        local p = ns.byId[id]
        local textColor = p and p.text or offColor("text") or { 0.9, 0.9, 0.9 }
        local labelColor = p and p.label or textColor
        local accent = p and p.c2 or offColor("c2") or textColor
        local window = p and p.window or offColor("window") or { 0.1, 0.1, 0.1 }
        local choiceColor = nil
        if p then choiceColor = accentChoice(p) end
        if choiceColor then accent = choiceColor end
        local pending = history.pending
        local waitingPick = pending ~= nil and pending ~= id
        uiFont(note, ink, 11, (p and p.off) or { 0.55, 0.51, 0.45 })
        for i = 1, #headers do
            uiFont(headers[i], ink, 11, accent)
            headers[i]:SetText(string.upper(headers[i].palettesText or ""))
        end
        for i = 1, #entries do
            local entry = entries[i]
            local on = entry.id == id
            local waiting = waitingPick and entry.id == pending
            if type(entry.wash.SetColorTexture) == "function" then
                local fill = (on or waiting) and (p and p.control or window) or window
                entry.wash:SetColorTexture(fill[1], fill[2], fill[3], on and 0.55 or (waiting and 0.35 or 0))
            end
            uiFont(entry.nameText, ink, 13, textColor)
            uiFont(entry.moodText, ink, 12, labelColor)
            uiFont(entry.onText, ink, 12, waiting and labelColor or accent)
            entry.nameText:SetText(entry.name)
            entry.moodText:SetText(entry.mood)
            entry.onText:SetText(waiting and "Pending" or (on and "[On]" or ""))
            if entry.bgSwatch then
                local palette = ns.byId[entry.id]
                paintSwatch(entry.edge, (palette and palette.border) or { 0.05, 0.05, 0.05 })
                paintSwatch(entry.bgSwatch, palette and palette.background)
                paintSwatch(entry.bandSwatch, palette and palette.band)
                paintSwatch(entry.accentSwatch, palette and accentBlock(palette))
            end
        end
        uiFont(combatNote, ink, 12, labelColor)
        if combatNote.SetShown then
            combatNote:SetShown(waitingPick or heldPaint == true)
        end
        if syncUndo then syncUndo() end
    end
    row.palettesRefresh()
    end
    -- A drawing error leaves the slash command working and does not hide a list that was already built.
    local drew, err = pcall(draw)
    if not drew then
        row.palettesOwn = true
        if type(row.palettesHeight) ~= "number" or row.palettesHeight < 24 then
            row.palettesHeight = 36
        end
        local why = tostring(err or "unknown error")
        why = string.gsub(why, ".*Palettes%.lua:", "")
        if string.len(why) > 80 then why = string.sub(why, 1, 77) .. "..." end
        skip("palette list: " .. why)
    end
end

local function menuChoices()
    local values, order, titles = {}, {}, {}
    for g = 1, #ns.groups do
        local group = ns.groups[g]
        values[group.key] = group.label
        order[#order + 1] = group.key
        titles[group.key] = true
        for i = 1, #group.ids do
            local id = group.ids[i]
            values[id] = ns.byId[id].name
            order[#order + 1] = id
        end
    end
    values._restore = "Restore"
    order[#order + 1] = "_restore"
    titles._restore = true
    values.off = ns.off.name
    order[#order + 1] = "off"
    return values, order, titles
end

local function onEnable(_, db)
    watchFrames()
    local account = ns.accountTable()
    local char = ns.charTable()
    -- A saved choice from the removed setting is dropped, so the palette accent is its own.
    if type(db) == "table" then db.mixAccent = nil end
    local id, accent, onlyOn = ns.migrateLogin(account, char, db)
    ns.resetUndo(history, id)
    heldPaint = false
    if type(db) == "table" then
        db.own = nil
        db.everyCharacter = nil
    end
    local d = dui()
    if type(d) ~= "table" or type(d.Set) ~= "function" or type(d.Get) ~= "function" then return end
    applying = true
    if d:Get("Palettes", "palette") ~= id then d:Set("Palettes", "palette", id) end
    if (d:Get("Palettes", "classAccent") == true) ~= (accent == true) then
        d:Set("Palettes", "classAccent", accent == true)
    end
    if (d:Get("Palettes", "only") == true) ~= (onlyOn == true) then
        d:Set("Palettes", "only", onlyOn == true)
    end
    applying = false
    ready = true
    if id ~= "off" then apply(id) end
end

local function boot()
    local d = dui()
    if type(d) ~= "table" or type(d.RegisterPlugin) ~= "function" or type(d.RegisterModule) ~= "function" then
        return
    end
    local api = d.API
    if type(api) ~= "table" or api.major ~= 1 or type(api.minor) ~= "number" or api.minor < 7 then
        say("Palettes: Daylight UI is missing the settings Palettes needs, so no colors were changed.")
        return
    end
    local plugin = d.RegisterPlugin("Palettes", {
        needs = { 1, 7 },
        -- No icon file of our own. Daylight tints its fallback with this color.
        color = { 0.91, 0.63, 0.29 },
        short = "Palettes",
        blurb = "Recolor Daylight's windows. Class and combat colors stay.",
    })
    if type(plugin) ~= "table" or plugin.off then return end

    d:RegisterModule("Palettes", {
        label = "Palettes",
        plugin = "Palettes",
        defaults = { palette = "off", classAccent = false, only = false },
        OnEnable = onEnable,
        options = {
            pages = {
                {
                    id = "main",
                    label = "Palettes",
                    desc = "Recolor Daylight's windows, panels, borders, accent and text. Class and combat colors stay Daylight's.",
                    groups = {
                        {
                            label = "Palettes",
                            items = {
                                { type = "custom", label = "Choices", noSearch = true, build = buildList, update = function(row)
                                    if type(row.palettesRefresh) == "function" then pcall(row.palettesRefresh) end
                                end, height = function(row) return row.palettesHeight or 430 end },
                                { type = "toggle", key = "classAccent", label = "Accent follows class",
                                    desc = "Uses your class color as the chrome accent. The shade keeps the class hue and moves only as far as it needs to clear 3:1 on this frame. Names, chat, and unit frames stay the game's colors." },
                                { type = "toggle", key = "only", label = "Save for this character only",
                                    desc = "Off: this character uses your account palette. On: changes here apply only to this character." },
                                { type = "button", label = "Restore Daylight colors", text = "Restore", func = function()
                                    if type(DaylightUI) == "table" and type(DaylightUI.Set) == "function" then
                                        DaylightUI:Set("Palettes", "palette", "off")
                                    end
                                end },
                            },
                        },
                    },
                },
            },
        },
    })

    local view = type(api.For) == "function" and api.For("Palettes") or nil
    if type(view) == "table" then
        if type(view.On) == "function" then
            view.On("SettingChanged", onSetting)
        end
        if type(view.AddOptionsGroup) == "function" then
            view.AddOptionsGroup("appearance", {
                label = "Palette",
                desc = "Synced with Plugins > Palettes. Changing Accent or Window tint below lifts it.",
                items = {
                    { type = "dropdown", key = "palette", label = "Palette", choices = menuChoices },
                    { type = "text", label = "Editing Accent or Window tint lifts the palette. Class and combat colors stay Daylight's." },
                },
            })
        end
    end
    if syncUndo then syncUndo() end
end

-- Undo sits beside Reset page. It is one step back, not a return to Daylight's colors.
local undoHooked

local function undoClick()
    if not ns.undoReady(history) then return end
    if history.pending ~= nil then
        ns.undoPalette(history, ns.accountTable(), ns.charTable())
        if refreshList then refreshList() end
        return
    end
    local id = ns.undoPalette(history, ns.accountTable(), ns.charTable())
    local d = dui()
    applying = true
    if type(d) == "table" and type(d.Set) == "function" then
        d:Set("Palettes", "palette", id)
    end
    applying = false
    if inCombat() then
        heldPaint = true
        if refreshList then refreshList() end
    else
        apply(id, true)
    end
end

local function placeUndo(panel)
    local page = type(panel.Current) == "function" and panel.Current()
    local onPage = page == "Palettes.main"
    if undoButton.SetShown then
        undoButton:SetShown(onPage)
    elseif onPage and undoButton.Show then
        undoButton:Show()
    elseif undoButton.Hide then
        undoButton:Hide()
    end
    if not onPage then return end
    local reset = type(panel.ResetButton) == "function" and panel.ResetButton()
    local header = type(panel.Header) == "function" and panel.Header()
    local anchor = reset
    local test = type(panel.TestSwitch) == "function" and panel.TestSwitch()
    local design = type(panel.DesignSwitch) == "function" and panel.DesignSwitch()
    if type(design) == "table" and design.IsShown and design:IsShown() then
        anchor = design
    elseif type(test) == "table" and test.IsShown and test:IsShown() then
        anchor = test
    end
    if undoButton.ClearAllPoints then undoButton:ClearAllPoints() end
    if type(anchor) == "table" and anchor.IsShown and anchor:IsShown() then
        undoButton:SetPoint("RIGHT", anchor, "LEFT", -8, 0)
    elseif type(header) == "table" then
        undoButton:SetPoint("TOPRIGHT", header, "TOPRIGHT", -16, 0)
    end
    local off = not ns.undoReady(history)
    if undoButton.SetOff then
        undoButton.SetOff(off)
    elseif undoButton.SetEnabled then
        undoButton:SetEnabled(not off)
    end
end

syncUndo = function()
    local panel = type(DaylightUI) == "table" and DaylightUI.OptionsPanel
    if type(panel) ~= "table" then return end
    if not undoHooked and type(panel.Show) == "function" then
        undoHooked = true
        local show = panel.Show
        panel.Show = function(...)
            local a, b, c, d = show(...)
            syncUndo()
            return a, b, c, d
        end
        local refresh = panel.Refresh
        if type(refresh) == "function" then
            panel.Refresh = function(...)
                local a, b, c, d = refresh(...)
                syncUndo()
                return a, b, c, d
            end
        end
    end
    if not undoButton then
        local header = type(panel.Header) == "function" and panel.Header()
        local widgets = type(DaylightUI.Widgets) == "table" and DaylightUI.Widgets
        if type(header) ~= "table" or type(widgets) ~= "table" or type(widgets.Button) ~= "function" then
            return
        end
        undoButton = widgets.Button(header, "Undo", 24)
        if type(undoButton) ~= "table" then
            undoButton = nil
            return
        end
        if undoButton.FitWidth then undoButton.FitWidth(72) end
        undoButton:SetScript("OnClick", function()
            if not pcall(undoClick) then
                say("Palettes: something went wrong, and no palette was changed.")
            end
        end)
    end
    placeUndo(panel)
end

refreshList = function()
    if type(listRow) == "table" and type(listRow.palettesRefresh) == "function" then
        pcall(listRow.palettesRefresh)
    else
        syncUndo()
    end
end

-- A failure while listening must not stop the UI from loading.
local function listen()
    local events = CreateFrame("Frame")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")
    events:RegisterEvent("PLAYER_LOGOUT")
    events:RegisterEvent("ADDON_LOADED")
    events:SetScript("OnEvent", function(_, event, name)
        if event == "PLAYER_LOGOUT" then
            -- Reload and logout save Daylight's settings. Put the player's colors
            -- back first so a palette is not written into their accent.
            shutting = true
            if paintedId and snap then pcall(savedColors) end
            return
        end
        if event == "PLAYER_REGEN_ENABLED" then
            local waiting = history.pending
            local repaint = heldPaint
            if waiting ~= nil then
                local id = ns.finishCombat(history, ns.accountTable(), ns.charTable())
                local d = dui()
                applying = true
                if type(d) == "table" and type(d.Set) == "function" and type(d.Get) == "function"
                    and d:Get("Palettes", "palette") ~= id then
                    d:Set("Palettes", "palette", id)
                end
                applying = false
                apply(id, true)
                if refreshList then refreshList() end
            elseif repaint then
                heldPaint = false
                local id = history.current
                if known(id) then apply(id, true) end
                if refreshList then refreshList() end
            end
            return
        end
        if event == "ADDON_LOADED" and name == "DaylightUI_Skins" and paintedId then
            local p = ns.byId[paintedId]
            if p then
                -- Kit was still Daylight's colors if Skins loaded after the first paint.
                -- Put those originals back in the "last painted" map so the walk can find them.
                if snap and shownChrome then
                    local keys = { "controlBorder", "disabledBorder", "rowHover", "emptyBorder" }
                    for i = 1, #keys do
                        local color = snap[keys[i]]
                        if type(color) == "table" then
                            shownChrome[keys[i]] = { color[1], color[2], color[3] }
                        end
                    end
                end
                skipped = nil
                local map = resolvedMap(p)
                writeMap(map, 3)
                pcall(refreshLook, map)
                warnMissing()
            end
        end
    end)
end

if type(SlashCmdList) == "table" then
    SLASH_PALETTES1 = "/palettes"
    SlashCmdList.PALETTES = function(msg)
        if not pcall(slash, msg) then say("Palettes: something went wrong, and no palette was changed.") end
    end
end

if not pcall(listen) then
    say("Palettes: couldn't listen for combat or logout, so palettes wait for a safe /reload.")
end
if not pcall(boot) then
    say("Palettes: couldn't start, so Daylight's colors are unchanged.")
end
