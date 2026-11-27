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
local editorOn -- the Custom editor is open
local customDraft -- slider colors, not saved until Save
local loadCustomEditor
local previewCustom
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
    local look = style()
    if snap then return type(look) == "table" end
    if type(look) ~= "table" then return false end
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

local holdingIcon

local function override(path, value, scope)
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
    local ok, handle = pcall(view.Override, scope or "general", path, value)
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

-- Icons follow the accent Palettes already applied, and only while Daylight's
-- micro-menu style is on. The player's own icon-color setting comes back
-- when this is released. Daylight drops it if they change that setting.
local function syncMicro()
    if not paintedId then
        release("microIconColor")
        return
    end
    local d = dui()
    local skin = type(d) == "table" and type(d.Get) == "function" and d:Get("ActionBars", "skinMenus")
    if skin ~= true then
        release("microIconColor")
        return
    end
    holdingIcon = true
    override("microIconColor", "accent", "ActionBars")
    holdingIcon = false
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
    snap = nil
    local looksBack = false
    local armed = ns.restoreLooksToo == true
    ns.restoreLooksToo = nil
    ns.coloursOnlyRestore = nil
    if armed and type(ns.restoreLooks) == "function" then
        looksBack = ns.restoreLooks(quiet) == true
    end
    if armed then
        ns.clearingTheme = true
        if type(ns.clearTheme) == "function" then ns.clearTheme() end
        ns.clearingTheme = false
    elseif type(ns.notePalette) == "function" and not ns.applyingTheme then
        ns.notePalette("off")
    end
    notify()
    pcall(dressExtras)
    if not quiet then
        if looksBack then
            say("Palettes: off. Daylight's own colors and frame look are restored.")
        else
            say("Palettes: off. Daylight's own colors are restored.")
        end
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
    snap = nil
    applying = false
    notify()
    pcall(dressExtras)
    say("Palettes: " .. name .. " lifted. Daylight is using your Appearance colors again.")
    if type(ns.notePalette) == "function" then ns.notePalette("off") end
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

-- Names used by the game menu on Forever (Interface 16001) and on later clients.
-- warcraft.wiki.gg documents GameMenuFrame; the button globals are the classic
-- menu. Newer clients build the same buttons from a pool instead.
local GAME_MENU_BUTTONS = {
    "GameMenuButtonContinue", "GameMenuButtonHelp", "GameMenuButtonStore",
    "GameMenuButtonWhatsNew", "GameMenuButtonOptions", "GameMenuButtonSettings",
    "GameMenuButtonUIOptions", "GameMenuButtonKeybindings", "GameMenuButtonMacros",
    "GameMenuButtonAddons", "GameMenuButtonLogout", "GameMenuButtonQuit",
    "GameMenuButtonExit", "GameMenuButtonEditMode",
}

local function restyleMenuButton(button)
    if type(button) ~= "table" then return false end
    local touched = false
    local Style = style()
    local shell = shellOf(Style, button)
    if type(shell) == "table" then
        paintShell(Style, shell, false)
        touched = true
    end
    -- Daylight repaints these buttons from its hover script, so the new colours
    -- show on mouse-over and stay stale until then. Run that script once and
    -- leave the button in its rest state. No new skin of our own.
    if type(button.GetScript) == "function" then
        local enter = button:GetScript("OnEnter")
        local leave = button:GetScript("OnLeave")
        if type(enter) == "function" then
            pcall(enter, button)
            touched = true
        end
        if type(leave) == "function" then pcall(leave, button) end
    end
    return touched
end

function ns.refreshGameMenu()
    local touched = false
    local global = type(_G) == "table" and _G or {}
    local menu = GameMenuFrame
    if type(menu) ~= "table" then menu = global.GameMenuFrame end
    if type(menu) == "table" and type(menu.buttonPool) == "table"
        and type(menu.buttonPool.EnumerateActive) == "function" then
        for button in menu.buttonPool:EnumerateActive() do
            if restyleMenuButton(button) then touched = true end
        end
    end
    for i = 1, #GAME_MENU_BUTTONS do
        if restyleMenuButton(global[GAME_MENU_BUTTONS[i]]) then touched = true end
    end
    return touched
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
-- (ActionBars skinMenus). Off returns before any button is touched. The icons
-- follow through the micro-icon color setting, which syncMicro points at the accent.
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

local function apply(id, fromQueue, quietLine)
    if not known(id) then return end
    if not fromQueue and inCombat() then
        if id == "off" and ns.restoreLooksToo and type(ns.queueLooksOff) == "function" then
            ns.queueLooksOff()
        end
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
        restore(quietLine == true)
        history.current = "off"
        applying = false
        if type(ns.refreshGameMenu) == "function" then pcall(ns.refreshGameMenu) end
        if refreshList then refreshList() end
        return
    end
    if id == "custom" and type(ns.deriveCustom) == "function" and type(ns.readCustom) == "function" then
        ns.byId.custom = ns.deriveCustom(ns.readCustom(ns.accountTable(), ns.charTable()))
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
    syncMicro()
    notify()
    pcall(dressExtras)
    warnMissing()
    if type(ns.notePalette) == "function" and not ns.applyingTheme then ns.notePalette(id) end
    if not quietLine and not ns.quietPalette then
        say("Palettes: " .. p.name .. " is on. Your layout is unchanged.")
    end
    if type(ns.refreshGameMenu) == "function" then pcall(ns.refreshGameMenu) end
    if refreshList then refreshList() end
    if type(ns.refreshLooks) == "function" then ns.refreshLooks() end
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
    account.glow = nil
    char.glow = nil
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
    char.custom = nil
end

-- Undo is one step, and only for this session. previous is nil at login.
-- A combat pick is saved early so a reload keeps it. Cancelling writes the
-- palette on screen back over that waiting id.
function ns.undoReady(state)
    if type(ns.looksWaiting) == "function" and ns.looksWaiting() then return true end
    return type(state) == "table" and (state.pending ~= nil or state.previous ~= nil or state.lookUndo ~= nil)
end

function ns.resetUndo(state, id)
    if type(state) ~= "table" then return end
    state.current = id or "off"
    state.previous = nil
    state.pending = nil
    state.lookUndo = nil
end

function ns.clearPending(state, account, char)
    if type(state) ~= "table" or state.pending == nil then return false end
    state.pending = nil
    if type(account) == "table" and type(char) == "table" then
        ns.setPalette(account, char, state.current or "off")
    end
    return true
end

function ns.pushUndo(shot)
    if type(shot) ~= "table" then return end
    history.lookUndo = shot
    if shot.kind == "frame" or shot.kind == "looks" then
        history.previous = nil
    end
end

function ns.rememberUndo(kind)
    if ns.applyingTheme then return end
    if type(ns.captureUndo) ~= "function" then return end
    history.lookUndo = ns.captureUndo(kind)
    if kind == "frame" or kind == "looks" then
        history.previous = nil
    end
end

function ns.choosePalette(state, account, char, id, duringCombat)
    if type(state) ~= "table" then return end
    id = fallbackId(id) or "off"
    if ns.undoHold then
        state.lookUndo = ns.undoHold
        ns.undoHold = nil
    elseif not duringCombat and state == history and type(ns.captureUndo) == "function" then
        state.lookUndo = ns.captureUndo("palette")
    end
    if duringCombat then
        if id ~= state.current then
            state.pending = id
            -- Saved now, so a reload keeps the pick. The screen waits for combat.
            if type(account) == "table" and type(char) == "table" then
                ns.setPalette(account, char, id)
            end
        else
            ns.clearPending(state, account, char)
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
    if ns.clearPending(state, account, char) then return state.current end
    local shot = state.lookUndo
    state.lookUndo = nil
    if state.previous == nil and shot == nil then return state.current end
    if state.previous ~= nil then
        state.current = state.previous
        state.previous = nil
        if type(account) == "table" and type(char) == "table" then
            ns.setPalette(account, char, state.current)
        end
    end
    if type(shot) == "table" and type(ns.applyUndoShot) == "function" then
        ns.applyUndoShot(shot)
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

local function copyLooks(shot)
    if type(ns.copyLooksShot) == "function" then return ns.copyLooksShot(shot) end
    return { glow = shot.glow, light = shot.light }
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
            if type(ns.customSpec) == "function" and type(account.custom) == "table" then
                char.custom = ns.customSpec(account.custom)
            else
                char.custom = nil
            end
            if account.looks == false then
                char.looks = false
            elseif type(account.looks) == "table" then
                char.looks = copyLooks(account.looks)
            else
                char.looks = nil
            end
            char.theme = account.theme
            char.themeChanged = account.themeChanged == true
            char.frame = account.frame
            char.glow = nil
            account.glow = nil
        end
        char.only = true
    else
        char.only = false
        char.palette = nil
        char.classAccent = nil
        char.custom = nil
        char.looks = nil
        char.theme = nil
        char.themeChanged = nil
        char.frame = nil
        char.glow = nil
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

-- The Daylight profile is the palette in force. carried marks a profile Palettes
-- has already written, including one whose palette is off. Without it, an
-- imported profile that never had Palettes would look the same as off.
local function profileCarries(db)
    if type(db) ~= "table" then return false end
    if db.carried == true then return true end
    if type(db.custom) == "table" then return true end
    if db.classAccent == true then return true end
    if type(db.palette) == "string" and db.palette ~= "" and db.palette ~= "off" then return true end
    return false
end

local function copyCustom(account, char)
    if type(ns.customSpec) ~= "function" then return nil end
    local slot
    if type(char) == "table" and char.only == true and type(char.custom) == "table" then
        slot = char.custom
    elseif type(account) == "table" and type(account.custom) == "table" then
        slot = account.custom
    end
    if type(slot) ~= "table" then return nil end
    return ns.customSpec(slot)
end

-- Reads the profile into the slot Save for this character only already uses.
-- A profile with no Palettes part keeps the saved look and is stamped so the
-- next share includes it. The switch itself is never taken from the profile.
function ns.adoptProfile(account, char, db)
    if type(account) ~= "table" or type(char) ~= "table" then
        return "off", false, false, false, false, false, false
    end
    local savedId, savedAccent, onlyOn = activeLook(account, char)
    if type(db) ~= "table" then
        return savedId, savedAccent, onlyOn, false, false, false, false
    end
    local hadLook = profileCarries(db)
    local unknown, capped = false, false
    local id, accent = savedId, savedAccent
    if hadLook then
        local raw = db.palette
        if type(raw) == "string" and raw ~= "" and not known(raw) then
            unknown = true
            id = "ember"
        else
            id = fallbackId(raw) or "off"
        end
        accent = db.classAccent == true
        if onlyOn then
            char.palette = id
            char.classAccent = accent
        else
            account.palette = id
            account.classAccent = accent
            char.palette = nil
            char.classAccent = nil
            char.custom = nil
        end
        if type(db.custom) == "table" and type(ns.profileCustom) == "function" then
            local spec, wasCapped = ns.profileCustom(db.custom)
            if type(spec) == "table" then
                capped = wasCapped == true
                if onlyOn then char.custom = spec else account.custom = spec end
                db.custom = spec
            end
        elseif not unknown and (fallbackId(raw) or "off") == savedId and type(ns.customSpec) == "function" then
            db.custom = copyCustom(account, char)
        end
    else
        db.palette = savedId
        db.classAccent = savedAccent == true
        db.custom = copyCustom(account, char)
    end
    db.palette = id
    db.classAccent = accent == true
    db.carried = true
    db.only = onlyOn
    db.own = nil
    db.everyCharacter = nil
    db.glow = nil
    account.glow = nil
    char.glow = nil
    if type(ns.takeLooks) == "function" then
        ns.takeLooks(account, char, db, hadLook, onlyOn)
    end
    if unknown then
        -- An unknown palette falls back to Ember colors only.
    elseif type(ns.takeTheme) == "function" then
        ns.takeTheme(account, char, db, onlyOn)
    end
    local changed = savedId ~= id or (savedAccent == true) ~= (accent == true)
    return id, accent == true, onlyOn, unknown, capped, hadLook, changed
end

-- SettingChanged is (scope, path, value). scope is "general" or a module name.
local function paletteMoved(beforeCur, beforePend)
    if history.current ~= beforeCur then return true end
    if history.pending ~= beforePend and history.pending ~= nil then return true end
    return false
end

local onSettingRun

local function onSetting(scope, path)
    if applying or shutting or ns.writingLooks then return end
    if type(ns.withReloadAction) ~= "function" then
        onSettingRun(scope, path)
        return
    end
    ns.withReloadAction(function()
        onSettingRun(scope, path)
    end)
end

function onSettingRun(scope, path)
    local d = dui()
    if type(d) ~= "table" or type(d.Get) ~= "function" then return end
    if scope == "Palettes" and path == "palette" then
        local beforeCur, beforePend = history.current, history.pending
        local id = fallbackId(d:Get("Palettes", "palette")) or "off"
        if d:Get("Palettes", "palette") ~= id and type(d.Set) == "function" then
            applying = true
            d:Set("Palettes", "palette", id)
            applying = false
        end
        if inCombat() then
            if id == "off" and ns.restoreLooksToo and type(ns.queueLooksOff) == "function" then
                ns.queueLooksOff()
            end
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
            if paletteMoved(beforeCur, beforePend) and type(ns.requestReload) == "function" then
                ns.requestReload()
            end
            return
        end
        ns.choosePalette(history, ns.accountTable(), ns.charTable(), id, false)
        apply(id, true)
        if paletteMoved(beforeCur, beforePend) and type(ns.requestReload) == "function" then
            ns.requestReload()
        end
        return
    end
    if scope == "Palettes" and path == "only" then
        local beforeId = d:Get("Palettes", "palette")
        local beforeAccent = d:Get("Palettes", "classAccent") == true
        local account, char = ns.accountTable(), ns.charTable()
        local cleared = ns.clearPending(history, account, char)
        local id, accent = ns.setOnly(account, char, d:Get("Palettes", "only") == true)
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
        local slot
        if char.only == true and type(char.custom) == "table" then
            slot = char.custom
        elseif type(account.custom) == "table" then
            slot = account.custom
        end
        local stored
        if slot and type(ns.customSpec) == "function" then stored = ns.customSpec(slot) end
        local looksStored
        if char.only == true then looksStored = char.looks else looksStored = account.looks end
        if type(looksStored) == "table" then
            looksStored = copyLooks(looksStored)
        elseif looksStored ~= false then
            looksStored = nil
        end
        local themeStored = char.only == true and char.theme or account.theme
        if themeStored == nil then themeStored = false end
        local themeChanged = char.only == true and char.themeChanged == true or char.only ~= true and account.themeChanged == true
        local frameStored = char.only == true and char.frame or account.frame
        if frameStored == nil then frameStored = false end
        account.glow = nil
        char.glow = nil
        applying = true
        d:Set("Palettes", "custom", stored)
        d:Set("Palettes", "looks", looksStored)
        d:Set("Palettes", "theme", themeStored)
        d:Set("Palettes", "themeChanged", themeChanged)
        d:Set("Palettes", "frame", frameStored)
        d:Set("Palettes", "glow", nil)
        d:Set("Palettes", "carried", true)
        applying = false
        if id ~= beforeId or (accent == true) ~= beforeAccent then
            apply(id)
            if type(ns.requestReload) == "function" then ns.requestReload() end
        elseif cleared and refreshList then refreshList() end
        return
    end
    if scope == "Palettes" and path == "looks" then
        if type(ns.adoptLooksSetting) == "function" then
            ns.adoptLooksSetting(d:Get("Palettes", "looks"))
        end
        return
    end
    if scope == "Palettes" and path == "classAccent" then
        local nextAccent = d:Get("Palettes", "classAccent") == true
        local account, char = ns.accountTable(), ns.charTable()
        local beforeAccent = type(account) == "table" and account.classAccent == true
        if type(char) == "table" and char.only == true then beforeAccent = char.classAccent == true end
        ns.setClassAccent(account, char, nextAccent)
        local id = d:Get("Palettes", "palette")
        if known(id) and id ~= "off" then apply(id) elseif refreshList then refreshList() end
        if beforeAccent ~= nextAccent and type(ns.requestReload) == "function" then ns.requestReload() end
        return
    end
    if scope == "ActionBars" and path == "microIconColor" then
        if paintedId and not holdingIcon then forget("microIconColor") end
        return
    end
    if scope == "ActionBars" and path == "skinMenus" then
        syncMicro()
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

local function hintNames(skipId)
    local names = {}
    if skipId ~= "custom" and type(ns.byId.custom) == "table" then
        names[#names + 1] = "custom"
    end
    for g = 1, #ns.groups do
        local group = ns.groups[g]
        for i = 1, #group.ids do
            if group.ids[i] ~= skipId then names[#names + 1] = group.ids[i] end
        end
    end
    return names
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
    local names = hintNames(id)
    if id ~= "off" then
        names[#names + 1] = "off"
        return "Palettes: " .. paletteName(id) .. " is on. Type /palettes " .. joinOr(names) .. "."
    end
    -- off is already the current state, so the hint lists the palette names instead.
    names = hintNames(nil)
    names[#names + 1] = "off"
    return "Palettes: off. Type /palettes " .. joinOr(names) .. "."
end

local slashRun

local function slash(msg)
    local function run()
        slashRun(msg)
    end
    if type(ns.withReloadAction) ~= "function" then
        run()
        return
    end
    -- A palette that is already off can still restore Looks. Count that too.
    local beforeLook = type(ns.lookMark) == "function" and ns.lookMark() or ""
    local beforePal = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
    ns.withReloadAction(function()
        run()
        local afterPal = type(ns.screenPalette) == "function" and ns.screenPalette() or nil
        local lookChanged = type(ns.lookMark) == "function" and ns.lookMark() ~= beforeLook
        if lookChanged or afterPal ~= beforePal then
            if type(ns.requestReload) == "function" then ns.requestReload() end
        end
    end)
end

function slashRun(msg)
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
        local normArg = string.gsub(arg, "%-", " ")
        for i = 1, #(ns.order or {}) do
            local pid = ns.order[i]
            local p = ns.byId[pid]
            if type(p) == "table" and type(p.name) == "string" then
                local normName = string.gsub(string.lower(trim(p.name)), "[%s%-]+", " ")
                if normName == normArg then
                    arg = pid
                    break
                end
            end
        end
    end
    if arg == "off" and type(ns.armLooksRestore) == "function" then ns.armLooksRestore() end
    if not known(arg) then
        say(statusLine())
        return
    end
    if d:Set("Palettes", "palette", arg) == false then
        if arg == "off" and type(ns.cancelLooksOff) == "function" then ns.cancelLooksOff() end
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

-- A dashed edge is the closest native look: short solid textures, no custom art.
local function paintDashes(entry, on, color)
    local dashes = entry.dashes
    if not on then
        if dashes then
            for i = 1, #dashes do
                if dashes[i].Hide then dashes[i]:Hide() end
            end
        end
        return
    end
    local button = entry.button
    if type(button) ~= "table" then return end
    if not dashes then
        dashes = {}
        for i = 1, 48 do
            local tex = button:CreateTexture(nil, "OVERLAY")
            tex:Hide()
            dashes[i] = tex
        end
        entry.dashes = dashes
    end
    local width = type(button.GetWidth) == "function" and button:GetWidth() or 0
    local height = type(button.GetHeight) == "function" and button:GetHeight() or 28
    if type(width) ~= "number" or width < 40 then width = 480 end
    if type(height) ~= "number" or height < 8 then height = 28 end
    local stride, used = 10, 0
    local across = math.floor(width / stride)
    if across > 20 then across = 20 end
    local function place(x, y, w, h)
        used = used + 1
        local tex = dashes[used]
        if not tex then return end
        tex:ClearAllPoints()
        tex:SetSize(w, h)
        tex:SetPoint("TOPLEFT", button, "TOPLEFT", x, y)
        paintSwatch(tex, color)
        if tex.Show then tex:Show() end
    end
    for i = 0, across - 1 do
        place(4 + i * stride, -1, 6, 1)
        place(4 + i * stride, 2 - height, 6, 1)
    end
    local down = math.floor((height - 4) / stride)
    for i = 0, down - 1 do
        place(1, -4 - i * stride, 1, 6)
        place(width - 2, -4 - i * stride, 1, 6)
    end
    for i = used + 1, #dashes do
        if dashes[i].Hide then dashes[i]:Hide() end
    end
end

local function currentId()
    local d = dui()
    if type(d) == "table" and type(d.Get) == "function" then
        local id = fallbackId(d:Get("Palettes", "palette"))
        if id then return id end
    end
    return paintedId or "off"
end

local EDITOR_H = 510

local function buildCustomEditor(row)
    if type(row) ~= "table" or type(row.palettesEditor) == "table" then return end
    if type(CreateFrame) ~= "function" or type(ns.deriveCustom) ~= "function" then return end
    local d0 = dui()
    local W = type(d0) == "table" and d0.Widgets
    if type(W) ~= "table" or type(W.Button) ~= "function" or type(W.SliderLook) ~= "function" then return end
    local editor = CreateFrame("Frame", nil, row)
    if type(editor) ~= "table" or type(editor.CreateTexture) ~= "function" or type(editor.SetPoint) ~= "function" then
        return
    end
    editor:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -4)
    editor:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -4)
    editor:SetHeight(EDITOR_H - 8)
    row.palettesEditorHeight = EDITOR_H
    if editor.EnableMouse then editor:EnableMouse(true) end
    if editor.SetFrameLevel and row.GetFrameLevel then
        editor:SetFrameLevel((row:GetFrameLevel() or 0) + 20)
    end
    if editor.Hide then editor:Hide() end

    local painting = false
    local function line(parent, text, point, relative, relPoint, x, y)
        local fs = blankText(parent)
        if type(fs) ~= "table" then return nil end
        fs:SetPoint(point, relative or parent, relPoint or point, x or 0, y or 0)
        if fs.SetText then fs:SetText(text or "") end
        return fs
    end

    local function slider(y, minValue, maxValue, ramp)
        local widget = CreateFrame("Slider", nil, editor)
        if type(widget) ~= "table" or type(widget.SetPoint) ~= "function" then return nil, nil end
        widget:SetPoint("TOPLEFT", editor, "TOPLEFT", 16, y)
        if widget.SetWidth then widget:SetWidth(220) end
        if widget.SetHeight then widget:SetHeight(18) end
        if widget.SetOrientation then widget:SetOrientation("HORIZONTAL") end
        if widget.SetMinMaxValues then widget:SetMinMaxValues(minValue, maxValue) end
        if widget.SetValueStep then widget:SetValueStep(1) end
        if widget.SetObeyStepOnDrag then pcall(widget.SetObeyStepOnDrag, widget, true) end
        local look = W.SliderLook(widget, {})
        local strips
        if ramp and type(look) == "table" then
            if type(look.track) == "table" and look.track.Hide then look.track:Hide() end
            if type(look.fill) == "table" and look.fill.Hide then look.fill:Hide() end
            strips = {}
            for i = 1, 12 do
                local tex = widget:CreateTexture(nil, "BACKGROUND")
                if type(tex) == "table" and tex.SetPoint then
                    tex:SetSize(20, 6)
                    tex:SetPoint("LEFT", widget, "LEFT", (i - 1) * 18, 0)
                    strips[i] = tex
                end
            end
        end
        local value = line(editor, "", "LEFT", widget, "RIGHT", 8, 0)
        return widget, value, strips
    end

    local function labelSlider(widget, text)
        if type(widget) ~= "table" then return end
        line(editor, text, "BOTTOMLEFT", widget, "TOPLEFT", 0, 2)
    end

    line(editor, "Custom", "TOPLEFT", editor, "TOPLEFT", 16, -2)
    local blurb = line(editor, "Mix a dark base and any accent, or paste a share code. Applies when you Save, out of combat.", "TOPLEFT", editor, "TOPLEFT", 16, -20)
    if type(blurb) == "table" and blurb.SetWidth then blurb:SetWidth(420) end
    local function chipAt(x, y)
        local swatch = editor:CreateTexture(nil, "ARTWORK")
        if type(swatch) ~= "table" then return nil, nil end
        swatch:SetSize(22, 14)
        swatch:SetPoint("TOPLEFT", editor, "TOPLEFT", x, y)
        local hex = line(editor, "", "LEFT", swatch, "RIGHT", 8, 0)
        return swatch, hex
    end
    line(editor, "BASE", "TOPLEFT", editor, "TOPLEFT", 16, -46)
    local baseChip, baseHex = chipAt(64, -44)
    local baseH, baseHValue, baseHueRamp = slider(-90, 0, 360, true)
    local baseS, baseSValue, baseSatRamp = slider(-118, 0, 100, true)
    local baseL, baseLValue = slider(-146, 0, 28, false)
    labelSlider(baseH, "Hue")
    labelSlider(baseS, "Saturation")
    labelSlider(baseL, "Lightness")
    local capNote = line(editor, "Base colors stay dark so text stays readable.", "TOPLEFT", editor, "TOPLEFT", 16, -168)
    if type(capNote) == "table" then
        if capNote.SetWidth then capNote:SetWidth(250) end
        if capNote.SetWordWrap then capNote:SetWordWrap(true) end
        if capNote.SetJustifyH then capNote:SetJustifyH("LEFT") end
    end

    line(editor, "ACCENT", "TOPLEFT", editor, "TOPLEFT", 16, -196)
    local accentChip, accentHex = chipAt(78, -194)
    local accentH, accentHValue, accentHueRamp = slider(-240, 0, 360, true)
    local accentS, accentSValue, accentSatRamp = slider(-268, 0, 100, true)
    local accentL, accentLValue = slider(-296, 0, 100, false)
    labelSlider(accentH, "Hue")
    labelSlider(accentS, "Saturation")
    labelSlider(accentL, "Lightness")

    local preview = CreateFrame("Frame", nil, editor)
    if type(preview) ~= "table" or type(preview.CreateTexture) ~= "function" then return end
    preview:SetSize(220, 132)
    preview:SetPoint("TOPRIGHT", editor, "TOPRIGHT", -12, -48)
    local border = preview:CreateTexture(nil, "BACKGROUND")
    border:SetAllPoints(preview)
    local bg = preview:CreateTexture(nil, "BORDER")
    bg:SetPoint("TOPLEFT", preview, "TOPLEFT", 2, -2)
    bg:SetPoint("BOTTOMRIGHT", preview, "BOTTOMRIGHT", -2, 2)
    local band = preview:CreateTexture(nil, "ARTWORK")
    band:SetPoint("TOPLEFT", preview, "TOPLEFT", 2, -2)
    band:SetPoint("TOPRIGHT", preview, "TOPRIGHT", -2, -2)
    band:SetHeight(18)
    local title = line(preview, "Custom", "TOPLEFT", preview, "TOPLEFT", 10, -26)
    local body = line(preview, "Body text", "TOPLEFT", preview, "TOPLEFT", 10, -46)
    if type(body) == "table" then
        if body.SetWidth then body:SetWidth(180) end
        if body.SetWordWrap then body:SetWordWrap(true) end
    end
    local previewAccent = preview:CreateTexture(nil, "OVERLAY")
    previewAccent:SetSize(36, 10)
    previewAccent:SetPoint("BOTTOMLEFT", preview, "BOTTOMLEFT", 10, 10)
    local accentLabel = line(preview, "Accent", "LEFT", previewAccent, "RIGHT", 6, 0)

    local warn = line(editor, "Accent is hard to see on this base.", "TOPLEFT", preview, "BOTTOMLEFT", 0, -8)
    if type(warn) == "table" then
        if warn.SetWidth then warn:SetWidth(210) end
        if warn.SetWordWrap then warn:SetWordWrap(true) end
        if warn.SetJustifyH then warn:SetJustifyH("LEFT") end
        if warn.Hide then warn:Hide() end
    end

    local function setText(fs, text)
        if type(fs) == "table" and fs.SetText then fs:SetText(text) end
    end

    local shareField, shareNote
    local shareQuiet

    local function showDraft()
        if type(customDraft) ~= "table" then return end
        local palette = ns.deriveCustom(customDraft)
        paintSwatch(border, palette.border)
        paintSwatch(bg, palette.background)
        paintSwatch(band, palette.band)
        paintSwatch(previewAccent, palette.c2)
        paintSwatch(baseChip, palette.background)
        paintSwatch(accentChip, palette.c2)
        if title then uiFont(title, nil, 13, palette.title) end
        if body then uiFont(body, nil, 12, palette.text) end
        if accentLabel then uiFont(accentLabel, nil, 11, palette.c2) end
        setText(baseHex, palette.background.hex)
        setText(accentHex, palette.c2.hex)
        setText(baseHValue, string.format("%d", math.floor(customDraft.h + 0.5)))
        setText(baseSValue, string.format("%d%%", math.floor(customDraft.s * 100 + 0.5)))
        setText(baseLValue, string.format("L*%d / 28", math.floor(customDraft.l + 0.5)))
        setText(accentHValue, string.format("%d", math.floor(customDraft.ah + 0.5)))
        setText(accentSValue, string.format("%d%%", math.floor(customDraft.as * 100 + 0.5)))
        setText(accentLValue, string.format("L*%d", math.floor(customDraft.al + 0.5)))
        local function paintRamp(strips, colorAt)
            if type(strips) ~= "table" or type(ns.colorAtL) ~= "function" then return end
            for i = 1, #strips do
                paintSwatch(strips[i], colorAt(i, #strips))
            end
        end
        paintRamp(baseHueRamp, function(i, n)
            return ns.colorAtL((i - 0.5) / n * 359, 1, 48)
        end)
        paintRamp(baseSatRamp, function(i, n)
            return ns.colorAtL(customDraft.h, (i - 0.5) / n, 42)
        end)
        paintRamp(accentHueRamp, function(i, n)
            return ns.colorAtL((i - 0.5) / n * 359, 1, 48)
        end)
        paintRamp(accentSatRamp, function(i, n)
            return ns.colorAtL(customDraft.ah, (i - 0.5) / n, 48)
        end)
        if type(warn) == "table" and warn.SetShown and type(ns.accentHardToSee) == "function" then
            local hard = ns.accentHardToSee(customDraft) == true
            warn:SetShown(hard)
            if hard then uiFont(warn, nil, 12, palette.text) end
        end
        if not shareQuiet and type(shareField) == "table" and type(ns.shareCode) == "function" then
            local focused = type(shareField.HasFocus) == "function" and shareField:HasFocus()
            if not focused and shareField.SetText then
                local code = ns.shareCode(customDraft)
                if code then shareField:SetText(code) end
            end
        end
    end

    local function setShareNote(text)
        if type(shareNote) ~= "table" then return end
        local on = type(text) == "string" and text ~= ""
        if shareNote.SetText then shareNote:SetText(on and text or "") end
        if shareNote.SetShown then shareNote:SetShown(on) end
        if on and type(customDraft) == "table" then
            uiFont(shareNote, nil, 12, ns.deriveCustom(customDraft).text)
        end
    end

    local function bind(widget, write)
        if type(widget) ~= "table" or type(widget.SetScript) ~= "function" then return end
        widget:SetScript("OnValueChanged", function(self, value)
            if painting or type(customDraft) ~= "table" then return end
            if type(value) ~= "number" and type(self) == "table" and type(self.GetValue) == "function" then
                value = self:GetValue()
            end
            if type(value) ~= "number" then return end
            write(customDraft, value)
            setShareNote("")
            showDraft()
        end)
    end
    bind(baseH, function(spec, value)
        spec.h = value
        spec.baseHex = nil
    end)
    bind(baseS, function(spec, value)
        spec.s = value / 100
        spec.baseHex = nil
    end)
    bind(baseL, function(spec, value)
        if value < 0 then value = 0 end
        if value > 28 then value = 28 end
        spec.l = value
        spec.baseHex = nil
    end)
    bind(accentH, function(spec, value)
        spec.ah = value
        spec.accentHex = nil
    end)
    bind(accentS, function(spec, value)
        spec.as = value / 100
        spec.accentHex = nil
    end)
    bind(accentL, function(spec, value)
        if value < 0 then value = 0 end
        if value > 100 then value = 100 end
        spec.al = value
        spec.accentHex = nil
    end)

    local function pushSliders()
        if type(customDraft) ~= "table" then return end
        painting = true
        local function put(widget, value)
            if type(widget) == "table" and widget.SetValue then widget:SetValue(value) end
        end
        put(baseH, customDraft.h)
        put(baseS, customDraft.s * 100)
        put(baseL, customDraft.l)
        put(accentH, customDraft.ah)
        put(accentS, customDraft.as * 100)
        put(accentL, customDraft.al)
        painting = false
        showDraft()
    end

    local function dayButton(parent, text, minWidth)
        local button = W.Button(parent, text, 22)
        if type(button) ~= "table" or type(button.SetPoint) ~= "function" then return nil end
        if button.FitWidth then button.FitWidth(minWidth) end
        return button
    end

    local function scopeOn()
        local d = dui()
        return type(d) == "table" and type(d.Get) == "function" and d:Get("Palettes", "only") == true
    end
    local onlySwitch
    if type(W.Switch) == "function" then
        onlySwitch = W.Switch(editor)
        if type(onlySwitch) == "table" and onlySwitch.SetPoint then
            onlySwitch:SetPoint("TOPLEFT", editor, "TOPLEFT", 16, -332)
            onlySwitch:SetScript("OnClick", function()
                local d = dui()
                if type(d) ~= "table" or type(d.Set) ~= "function" then return end
                d:Set("Palettes", "only", not scopeOn())
                if onlySwitch.SetOn then onlySwitch.SetOn(scopeOn()) end
            end)
        end
    end
    local onlyLabel = line(editor, "Save for this character only", "LEFT", onlySwitch or editor, onlySwitch and "RIGHT" or "TOPLEFT", onlySwitch and 8 or 16, onlySwitch and 0 or -386)
    local onlyNote = line(editor, "Custom uses the same character-only save as every other palette, and Undo steps back to the previous one.", "TOPLEFT", editor, "TOPLEFT", 16, -410)
    if type(onlyNote) == "table" and onlyNote.SetWidth then onlyNote:SetWidth(420) end

    local ask = CreateFrame("Frame", nil, editor)
    if type(ask) == "table" and ask.SetPoint then
        ask:SetSize(340, 128)
        ask:SetPoint("CENTER", editor, "CENTER", 40, 10)
        if ask.SetFrameLevel and editor.GetFrameLevel then
            ask:SetFrameLevel((editor:GetFrameLevel() or 1) + 30)
        end
        local askBg = ask:CreateTexture(nil, "BACKGROUND")
        if type(askBg) == "table" and askBg.SetAllPoints then
            askBg:SetAllPoints(ask)
            if askBg.SetColorTexture then askBg:SetColorTexture(0.09, 0.06, 0.05, 0.97) end
        end
        line(ask, "Reset Custom to Ember?", "TOPLEFT", ask, "TOPLEFT", 14, -12)
        local askBody = line(ask, "This replaces your current custom colors with Ember's base and accent. Custom stays selected.", "TOPLEFT", ask, "TOPLEFT", 14, -32)
        if type(askBody) == "table" then
            if askBody.SetWidth then askBody:SetWidth(300) end
            if askBody.SetWordWrap then askBody:SetWordWrap(true) end
        end
        if type(W.Close) == "function" then
            local close = W.Close(ask, function() if ask.Hide then ask:Hide() end end, 18)
            if type(close) == "table" and close.SetPoint then
                close:SetPoint("TOPRIGHT", ask, "TOPRIGHT", -4, -4)
            end
        end
        if ask.Hide then ask:Hide() end
        if ask.EnableMouse then ask:EnableMouse(true) end
        row.palettesAsk = ask
    end

    local function syncSetting(id)
        local d = dui()
        applying = true
        if type(d) == "table" and type(d.Set) == "function" and type(d.Get) == "function"
            and d:Get("Palettes", "palette") ~= id then
            d:Set("Palettes", "palette", id)
        end
        applying = false
    end

    local back = dayButton(editor, "Back", 72)
    local save = dayButton(editor, "Save", 72)
    local reset = dayButton(editor, "Reset to Ember", 130)
    local askCancel = type(ask) == "table" and dayButton(ask, "Cancel", 72) or nil
    local askYes = type(ask) == "table" and dayButton(ask, "Reset to Ember", 120) or nil
    if type(back) ~= "table" or type(save) ~= "table" or type(reset) ~= "table" then return end
    back:SetPoint("BOTTOMLEFT", editor, "BOTTOMLEFT", 8, 8)
    save:SetPoint("BOTTOMRIGHT", editor, "BOTTOMRIGHT", -8, 8)
    reset:SetPoint("RIGHT", save, "LEFT", -8, 0)
    if type(askCancel) == "table" then
        askCancel:SetPoint("BOTTOMRIGHT", ask, "BOTTOMRIGHT", -136, 10)
        askCancel:SetScript("OnClick", function() if ask.Hide then ask:Hide() end end)
    end
    if type(askYes) == "table" then
        askYes:SetPoint("BOTTOMRIGHT", ask, "BOTTOMRIGHT", -10, 10)
    end

    back:SetScript("OnClick", function()
        editorOn = false
        setShareNote("")
        if type(ask) == "table" and ask.Hide then ask:Hide() end
        if type(ns.readCustom) == "function" and type(ns.backCustom) == "function" then
            customDraft = ns.backCustom(ns.readCustom(ns.accountTable(), ns.charTable()))
        end
        if refreshList then refreshList() end
    end)
    save:SetScript("OnClick", function()
        if type(customDraft) ~= "table" or type(ns.saveCustom) ~= "function" then return end
        local function commit()
            local account, char = ns.accountTable(), ns.charTable()
            local before = type(ns.readCustom) == "function" and ns.readCustom(account, char) or nil
            local beforeId = history.current
            local hadLook = type(ns.shareLook) == "table"
            local during = inCombat()
            ns.saveCustom(history, account, char, customDraft, during)
            editorOn = false
            local changed = hadLook or beforeId ~= "custom" or history.pending == "custom"
            if type(ns.readCustom) == "function" and type(ns.shareCode) == "function" then
                local after = ns.readCustom(account, char)
                if ns.shareCode(before) ~= ns.shareCode(after) then changed = true end
            end
            if during then
                syncSetting(history.current or "off")
                if history.pending then
                    heldPaint = false
                    queueLine(history.pending)
                elseif history.current == "custom" then
                    heldPaint = true
                end
                if refreshList then refreshList() end
            else
                syncSetting("custom")
                apply("custom", true)
                local d = dui()
                if type(d) == "table" and type(d.Set) == "function" then
                    local slot
                    if char.only == true and type(char.custom) == "table" then
                        slot = char.custom
                    elseif type(account.custom) == "table" then
                        slot = account.custom
                    end
                    local stored = slot and type(ns.customSpec) == "function" and ns.customSpec(slot) or nil
                    applying = true
                    d:Set("Palettes", "custom", stored)
                    d:Set("Palettes", "carried", true)
                    applying = false
                end
            end
            if changed then ns.requestReload() end
        end
        if type(ns.withReloadAction) == "function" then
            ns.withReloadAction(commit)
        else
            commit()
        end
    end)
    local function applyReset()
        if type(ns.resetCustomToEmber) ~= "function" then return end
        customDraft = ns.customSpec(ns.resetCustomToEmber(ns.accountTable(), ns.charTable()))
        setShareNote("")
        if type(ask) == "table" and ask.Hide then ask:Hide() end
        pushSliders()
    end
    reset:SetScript("OnClick", function()
        if type(ask) == "table" and ask.Show then ask:Show() else applyReset() end
    end)
    if type(askYes) == "table" then askYes:SetScript("OnClick", applyReset) end
    if type(onlySwitch) == "table" and type(onlySwitch.SetOn) == "function" then
        local paint = showDraft
        showDraft = function()
            onlySwitch.SetOn(scopeOn())
            paint()
        end
    end

    loadCustomEditor = pushSliders
    previewCustom = showDraft
    row.palettesEditor = editor
end

local function blendColor(a, b, t)
    local ar, ag, ab = (a and a[1]) or 0.08, (a and a[2]) or 0.10, (a and a[3]) or 0.08
    local br, bg, bb = (b and b[1]) or 0.20, (b and b[2]) or 0.24, (b and b[3]) or 0.20
    return { ar + (br - ar) * t, ag + (bg - ag) * t, ab + (bb - ab) * t }
end

local function paintLayer(tex, isRound, color, alpha)
    if type(tex) ~= "table" then return end
    local r = type(color) == "table" and color[1] or 0.1
    local g = type(color) == "table" and color[2] or 0.12
    local b = type(color) == "table" and color[3] or 0.1
    local a = alpha ~= nil and alpha or (type(color) == "table" and color[4]) or 1
    if isRound and type(tex.SetVertexColor) == "function" then
        tex:SetVertexColor(r, g, b, a)
    elseif type(tex.SetColorTexture) == "function" then
        tex:SetColorTexture(r, g, b, a)
    end
end

-- Creates DaylightUI-native nine-slice rounded fill + 1px outline textures when W.Round is available.
function ns.makeRoundCard(parent)
    local d = dui()
    local W = type(d) == "table" and d.Widgets
    local fill, line, isRound
    if type(W) == "table" and type(W.Round) == "function" then
        local okF, f = pcall(W.Round, parent, "BACKGROUND", 0, false)
        local okL, l = pcall(W.Round, parent, "BORDER", 1, true)
        if okF and okL and type(f) == "table" and type(l) == "table" then
            fill, line, isRound = f, l, true
        end
    end
    if not fill then
        line = parent:CreateTexture(nil, "BACKGROUND")
        fill = parent:CreateTexture(nil, "BORDER")
        isRound = false
    end
    if isRound then
        if fill.SetAllPoints then fill:SetAllPoints() end
        if line.SetAllPoints then line:SetAllPoints() end
    else
        if line.SetAllPoints then line:SetAllPoints() end
        fill:SetPoint("TOPLEFT", parent, "TOPLEFT", 1, -1)
        fill:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -1, 1)
    end
    return {
        fill = fill,
        line = line,
        isRound = isRound,
        paint = function(fillColor, fillAlpha, lineColor, lineAlpha)
            paintLayer(fill, isRound, fillColor, fillAlpha)
            paintLayer(line, isRound, lineColor, lineAlpha)
        end,
    }
end

ns.blendColor = blendColor

local DECK_MODES = {
    { key = "player_target", label = "Player & Target", page = "UnitFrames.player" },
    { key = "focus", label = "Focus", page = "UnitFrames.focus" },
    { key = "tot", label = "Target of Target", page = "UnitFrames.targettarget" },
    { key = "party", label = "Party", page = "UnitFrames.party" },
    { key = "raid", label = "Raid", page = "UnitFrames.raid" },
    { key = "castbars", label = "Cast Bars", page = "UnitFrames.castbars" },
    { key = "actionbars", label = "Action Bars", page = nil },
    { key = "nameplates", label = "Nameplates", page = "Nameplates.plates" },
}

local previewDeckMode = "player_target"
local previewDeckRefresh = nil

function ns.getPreviewDeckMode()
    return previewDeckMode
end

function ns.setPreviewDeckMode(modeKey, fromSubTab)
    local found = false
    for i = 1, #DECK_MODES do
        if DECK_MODES[i].key == modeKey then found = true; break end
    end
    if not found then return end
    previewDeckMode = modeKey
    if not fromSubTab then
        local d = dui()
        local panel = type(d) == "table" and d.OptionsPanel
        local pf = type(panel) == "table" and type(panel.PageFrame) == "function" and panel.PageFrame("Palettes.main")
        local tab = type(pf) == "table" and type(pf.tab) == "string" and pf.tab or "Presets"
        if tab == "Looks" and type(ns.setLooksSubTab) == "function" then
            pcall(ns.setLooksSubTab, modeKey, true)
        end
    end
    if type(ns.syncFramePreview) == "function" then pcall(ns.syncFramePreview) end
    if type(previewDeckRefresh) == "function" then pcall(previewDeckRefresh) end
    local d = dui()
    local panel = type(d) == "table" and d.OptionsPanel
    if type(panel) == "table" and type(panel.Refresh) == "function" then pcall(panel.Refresh) end
end

local function makePlayerSample(parent)
    local d = dui()
    local opts = type(d) == "table" and d.Options
    if type(opts) ~= "table" or type(opts.GetPage) ~= "function" then return nil end
    local okP, ufPlayer = pcall(opts.GetPage, "UnitFrames.player")
    if not okP or type(ufPlayer) ~= "table" or type(ufPlayer.sample) ~= "function" then return nil end

    local container = CreateFrame("Frame", nil, parent)
    local okSP, playerS = pcall(ufPlayer.sample, container)
    if not okSP or type(playerS) ~= "table" or type(playerS.frame) ~= "table" then return nil end

    local function trySample(pageId)
        if not pageId then return nil end
        local okPg, pg = pcall(opts.GetPage, pageId)
        if okPg and type(pg) == "table" and type(pg.sample) == "function" then
            local okS, s = pcall(pg.sample, container)
            if okS and type(s) == "table" and type(s.frame) == "table" then return s end
        end
        return nil
    end

    local targetS = trySample("UnitFrames.target")
    local extraSamples = {}
    local function getExtraSample(modeKey, pageId)
        if extraSamples[modeKey] == nil then
            extraSamples[modeKey] = trySample(pageId) or false
        end
        return extraSamples[modeKey] or nil
    end

    -- Preview Deck header bar: mode selector button + amber PREVIEWING pill
    local HEADER_H = 24
    local header = CreateFrame("Frame", nil, container)
    header:SetHeight(HEADER_H)
    local headerCard = ns.makeRoundCard(header)

    local modeBtn = CreateFrame("Button", nil, header)
    modeBtn:SetSize(156, 20)
    modeBtn:SetPoint("LEFT", header, "LEFT", 6, 0)
    local modeCard = ns.makeRoundCard(modeBtn)
    local modeText = blankText(modeBtn)
    modeText:SetPoint("CENTER", modeBtn, "CENTER", 0, 0)
    modeBtn:SetScript("OnClick", function()
        local idx = 1
        for i = 1, #DECK_MODES do
            if DECK_MODES[i].key == previewDeckMode then idx = i; break end
        end
        local nextMode = DECK_MODES[(idx % #DECK_MODES) + 1]
        ns.setPreviewDeckMode(nextMode.key, false)
    end)

    local statusPill = CreateFrame("Frame", nil, header)
    statusPill:SetHeight(18)
    statusPill:SetPoint("RIGHT", header, "RIGHT", -6, 0)
    local statusCard = ns.makeRoundCard(statusPill)
    local statusText = blankText(statusPill)
    statusText:SetPoint("CENTER", statusPill, "CENTER", 0, 0)

    -- Live Action Bars preview strip reflecting the active/staged ActionBars look settings
    local abPreview = CreateFrame("Frame", nil, container)
    abPreview:SetHeight(56)
    local abSlots = {}
    local abKeys = { "1", "2", "3", "4", "5", "Q", "E", "R" }
    local abIcons = {
        "Interface\\Icons\\Spell_Holy_FlashHeal",
        "Interface\\Icons\\Spell_Fire_FireBolt",
        "Interface\\Icons\\Ability_Warrior_ShieldWall",
        "Interface\\Icons\\Spell_Frost_FrostBolt02",
        "Interface\\Icons\\Ability_Rogue_Sprint",
        "Interface\\Icons\\Spell_Nature_Lightning",
        "Interface\\Icons\\Ability_Hunter_AimedShot",
        "Interface\\Icons\\Spell_Shadow_ShadowBolt",
    }
    for i = 1, #abKeys do
        local slot = CreateFrame("Frame", nil, abPreview)
        slot:SetSize(38, 38)
        local shadow = slot:CreateTexture(nil, "BACKGROUND", nil, -6)
        local outer = slot:CreateTexture(nil, "BORDER", nil, 0)
        local roundCard = ns.makeRoundCard(slot)
        local icon = slot:CreateTexture(nil, "ARTWORK", nil, 0)
        if type(icon.SetTexture) == "function" then icon:SetTexture(abIcons[i]) end
        local mask = type(slot.CreateMaskTexture) == "function" and slot:CreateMaskTexture() or nil
        local kf = blankText(slot)
        kf:SetPoint("TOPRIGHT", slot, "TOPRIGHT", -3, -3)
        kf:SetText(abKeys[i])
        abSlots[i] = {
            frame = slot, shadow = shadow, outer = outer, roundCard = roundCard,
            icon = icon, mask = mask, masked = false, text = kf,
        }
    end
    if abPreview.Hide then abPreview:Hide() end

    -- Live Nameplates preview strip: Target casting interruptible spell + Secondary Enemy + Friendly plate.
    -- Semantic reaction/cast colors remain fixed (combat-color immune); frame chrome updates live with ns.staged.
    local NP_PREVIEW_H = 88
    local npPreview = CreateFrame("Frame", nil, container)
    npPreview:SetHeight(NP_PREVIEW_H)

    local function makeMockPlate(nameStr, lvlStr, pctVal, fillCol, isTarget, isFriendly)
        local wrap = CreateFrame("Frame", nil, npPreview)
        wrap:SetSize(180, 66)

        local nameFs = blankText(wrap)
        nameFs:SetText(nameStr)

        local barHost = CreateFrame("Frame", nil, wrap)
        barHost:SetSize(148, 16)

        local shadow = barHost:CreateTexture(nil, "BACKGROUND", nil, -7)
        local rim = barHost:CreateTexture(nil, "BACKGROUND", nil, -5)
        local roundCard = ns.makeRoundCard(barHost)
        local borderTex = barHost:CreateTexture(nil, "BORDER", nil, 0)
        local bgTex = barHost:CreateTexture(nil, "ARTWORK", nil, 0)
        local fillTex = barHost:CreateTexture(nil, "ARTWORK", nil, 2)
        local lvlFs = blankText(barHost)
        lvlFs:SetPoint("LEFT", barHost, "LEFT", 4, 0)
        lvlFs:SetText(lvlStr or "")
        local pctFs = blankText(barHost)
        pctFs:SetPoint("RIGHT", barHost, "RIGHT", -4, 0)

        local arrowL, arrowR
        if isTarget then
            arrowL = blankText(wrap)
            arrowL:SetText(">")
            arrowR = blankText(wrap)
            arrowR:SetText("<")
        end

        local castHost, castBg, castFill, castIconBox, castIconTex, castText, castTime
        if isTarget then
            castHost = CreateFrame("Frame", nil, wrap)
            castHost:SetSize(148, 14)
            castBg = castHost:CreateTexture(nil, "BORDER", nil, 0)
            castFill = castHost:CreateTexture(nil, "ARTWORK", nil, 2)
            castIconBox = CreateFrame("Frame", nil, wrap)
            castIconBox:SetSize(14, 14)
            castIconTex = castIconBox:CreateTexture(nil, "ARTWORK", nil, 1)
            if type(castIconTex.SetTexture) == "function" then
                castIconTex:SetTexture("Interface\\Icons\\Spell_Shadow_ShadowBolt")
            end
            if type(castIconTex.SetTexCoord) == "function" then
                castIconTex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
            castIconTex:SetAllPoints(castIconBox)
            castText = blankText(castHost)
            castText:SetPoint("LEFT", castHost, "LEFT", 4, 0)
            castText:SetText("Shadow Bolt")
            castTime = blankText(castHost)
            castTime:SetPoint("RIGHT", castHost, "RIGHT", -4, 0)
            castTime:SetText("1.4s")
        end

        return {
            wrap = wrap, nameFs = nameFs, barHost = barHost,
            shadow = shadow, rim = rim, roundCard = roundCard, borderTex = borderTex,
            bgTex = bgTex, fillTex = fillTex, lvlFs = lvlFs, pctFs = pctFs,
            arrowL = arrowL, arrowR = arrowR,
            castHost = castHost, castBg = castBg, castFill = castFill,
            castIconBox = castIconBox, castIconTex = castIconTex, castText = castText, castTime = castTime,
            lvlStr = lvlStr, pctVal = pctVal, fillCol = fillCol, isTarget = isTarget, isFriendly = isFriendly,
        }
    end

    local npPlates = {
        makeMockPlate("Shadowweaver", "25", 0.72, { 0.78, 0.22, 0.20 }, true, false),
        makeMockPlate("Boneguard", "24", 0.48, { 0.78, 0.24, 0.20 }, false, false),
        makeMockPlate("Aelindra", nil, 0.94, { 0.26, 0.72, 0.34 }, false, true),
    }
    if npPreview.Hide then npPreview:Hide() end

    local function modeLabel(key)
        for i = 1, #DECK_MODES do
            if DECK_MODES[i].key == key then return DECK_MODES[i].label end
        end
        return "Player & Target"
    end

    local function showDeckOnTab()
        local panel = type(d) == "table" and d.OptionsPanel
        if type(panel) ~= "table" or type(panel.PageFrame) ~= "function" then return true end
        local pf = panel.PageFrame("Palettes.main")
        local tab = type(pf) == "table" and type(pf.tab) == "string" and pf.tab or "Presets"
        return tab == "Presets" or tab == "Colours" or tab == "Looks"
    end

    local function hideAllSamples()
        if playerS.frame.Hide then playerS.frame:Hide() end
        if targetS and targetS.frame.Hide then targetS.frame:Hide() end
        if abPreview.Hide then abPreview:Hide() end
        if npPreview.Hide then npPreview:Hide() end
        for _, s in pairs(extraSamples) do
            if type(s) == "table" and s.frame and s.frame.Hide then s.frame:Hide() end
        end
    end

    local function resolveNameplateLook()
        local staged = ns.staged
        local npId = nil
        if type(staged) == "table" then
            if type(staged.looks) == "table" and type(staged.looks.nameplates) == "string" then
                npId = staged.looks.nameplates
            elseif staged.kind == "look" and staged.catKey == "nameplates" and type(staged.id) == "string" then
                npId = staged.id
            else
                local baseTheme = (staged.baseKind == "theme" or staged.kind == "theme")
                    and type(ns.themeById) == "function" and ns.themeById(staged.baseId or staged.id) or nil
                local baseRec = (staged.baseKind == "mypreset" or staged.kind == "mypreset")
                    and type(staged.recipe) == "table" and staged.recipe or nil
                npId = (baseTheme and baseTheme.nameplates) or (baseRec and baseRec.nameplates)
            end
        end
        if not npId and type(ns.readLookPick) == "function" then
            npId = ns.readLookPick("nameplates")
        end
        local opt = type(ns.extraLookById) == "function" and ns.extraLookById("nameplates", npId or "standard") or nil
        if not opt and type(ns.extraLookById) == "function" then
            opt = ns.extraLookById("nameplates", "standard")
        end
        return (opt and opt.settings) or {}, (opt and opt.preview) or { borderPx = 2, corner = "round", shadow = true }
    end

    local function readActionBarLook()
        local shape = (type(d.Get) == "function" and select(2, pcall(d.Get, d, "ActionBars", "look.shape"))) or "square"
        local borderStyle = (type(d.Get) == "function" and select(2, pcall(d.Get, d, "ActionBars", "look.borderStyle"))) or "daylight"
        local border = tonumber(type(d.Get) == "function" and select(2, pcall(d.Get, d, "ActionBars", "look.border"))) or 2
        local corners = (type(d.Get) == "function" and select(2, pcall(d.Get, d, "ActionBars", "look.corners"))) or "round"
        local shadowOn = (type(d.Get) == "function" and select(2, pcall(d.Get, d, "ActionBars", "look.shadow"))) ~= false
        local zoom = tonumber(type(d.Get) == "function" and select(2, pcall(d.Get, d, "ActionBars", "look.zoom"))) or 0.06
        return shape, borderStyle, border, corners, shadowOn, zoom
    end

    local function paintHeader()
        local staged = ns.staged
        local pid = (type(staged) == "table" and type(staged.palette) == "string" and staged.palette)
            or (type(staged) == "table" and staged.kind == "palette" and staged.id)
            or (type(staged) == "table" and staged.kind == "theme" and type(ns.themePaletteId) == "function" and ns.themePaletteId(staged.id))
            or currentId()
        local p = ns.byId[pid]
        local win = (p and p.window) or { 0.08, 0.10, 0.08 }
        local bnd = (p and p.band) or { 0.14, 0.18, 0.14 }
        local brd = (p and p.border) or { 0.22, 0.28, 0.22 }
        local acc = (p and p.c2) or { 0.91, 0.63, 0.29 }
        local txt = (p and p.text) or { 0.92, 0.90, 0.86 }
        headerCard.paint(bnd, 0.92, brd, 0.75)
        modeCard.paint(win, 0.95, acc, 0.70)
        modeText:SetText("Preview: " .. modeLabel(previewDeckMode) .. " v")
        if type(modeText.SetTextColor) == "function" then modeText:SetTextColor(txt[1], txt[2], txt[3], 1) end

        if type(staged) == "table" then
            local name = staged.label or staged.id or "Change"
            statusText:SetText("PREVIEWING: " .. tostring(name) .. " — Unsaved")
            local sw = 180
            if type(statusText.GetStringWidth) == "function" then
                local g = statusText:GetStringWidth()
                if type(g) == "number" and g > 40 then sw = g + 16 end
            end
            statusPill:SetWidth(sw)
            statusCard.paint({ 0.85, 0.47, 0.02 }, 1, { 0.95, 0.62, 0.10 }, 1)
            if type(statusText.SetTextColor) == "function" then statusText:SetTextColor(0.07, 0.05, 0.02, 1) end
        else
            statusText:SetText("Live · Saved")
            statusPill:SetWidth(92)
            statusCard.paint(win, 0.80, brd, 0.65)
            if type(statusText.SetTextColor) == "function" then statusText:SetTextColor(acc[1], acc[2], acc[3], 1) end
        end

        -- Paint Action Bars preview slots using live look.shape / borderStyle / border / corners / shadow / zoom
        local shape, borderStyle, borderPx, corners, shadowOn, zoom = readActionBarLook()
        local isShaped = (shape ~= "square")
        local inset = (borderStyle == "none") and 0 or math.max(1, math.min(6, borderPx))
        local media = type(d.MEDIA) == "string" and d.MEDIA or "Interface\\AddOns\\DaylightUI\\Media\\"
        local shapeTex = isShaped and (media .. "shape-" .. shape .. ".png") or nil
        local shadowTex = isShaped and (media .. "shape-" .. shape .. "-shadow.png") or nil
        local z = math.max(0, math.min(0.4, zoom)) / 2

        for i = 1, #abSlots do
            local sl = abSlots[i]
            local rimCol = (i == 2) and acc or ((borderStyle == "daylight") and bnd or brd)
            -- Shadow
            if sl.shadow.ClearAllPoints then sl.shadow:ClearAllPoints() end
            sl.shadow:SetPoint("TOPLEFT", sl.frame, "TOPLEFT", -3, 3)
            sl.shadow:SetPoint("BOTTOMRIGHT", sl.frame, "BOTTOMRIGHT", 3, -3)
            if shadowOn then
                if shadowTex and type(sl.shadow.SetTexture) == "function" then
                    sl.shadow:SetTexture(shadowTex)
                    if type(sl.shadow.SetVertexColor) == "function" then sl.shadow:SetVertexColor(0, 0, 0, 0.65) end
                elseif type(sl.shadow.SetColorTexture) == "function" then
                    sl.shadow:SetColorTexture(0, 0, 0, 0.55)
                end
                if sl.shadow.Show then sl.shadow:Show() end
            else
                if sl.shadow.Hide then sl.shadow:Hide() end
            end

            -- Shape mask vs rounded/square border
            if isShaped and sl.mask and shapeTex then
                if sl.roundCard.fill.Hide then sl.roundCard.fill:Hide() end
                if sl.roundCard.line.Hide then sl.roundCard.line:Hide() end
                if type(sl.outer.SetTexture) == "function" then
                    sl.outer:SetTexture(shapeTex)
                    if type(sl.outer.SetVertexColor) == "function" then sl.outer:SetVertexColor(rimCol[1], rimCol[2], rimCol[3], 1) end
                end
                sl.outer:ClearAllPoints()
                sl.outer:SetAllPoints(sl.frame)
                if borderStyle == "none" then
                    if sl.outer.Hide then sl.outer:Hide() end
                elseif sl.outer.Show then
                    sl.outer:Show()
                end
                if type(sl.mask.SetTexture) == "function" then
                    pcall(sl.mask.SetTexture, sl.mask, shapeTex, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                end
                sl.mask:ClearAllPoints()
                sl.mask:SetAllPoints(sl.icon)
                if not sl.masked and type(sl.icon.AddMaskTexture) == "function" then
                    if pcall(sl.icon.AddMaskTexture, sl.icon, sl.mask) then sl.masked = true end
                end
            else
                if sl.masked and sl.mask and type(sl.icon.RemoveMaskTexture) == "function" then
                    pcall(sl.icon.RemoveMaskTexture, sl.icon, sl.mask)
                    sl.masked = false
                end
                if corners == "round" and borderStyle ~= "none" then
                    if sl.outer.Hide then sl.outer:Hide() end
                    if sl.roundCard.fill.Show then sl.roundCard.fill:Show() end
                    if sl.roundCard.line.Show then sl.roundCard.line:Show() end
                    sl.roundCard.paint(rimCol, 0.96, (i == 2) and acc or brd, 0.95)
                else
                    if sl.roundCard.fill.Hide then sl.roundCard.fill:Hide() end
                    if sl.roundCard.line.Hide then sl.roundCard.line:Hide() end
                    sl.outer:ClearAllPoints()
                    sl.outer:SetAllPoints(sl.frame)
                    if borderStyle == "none" then
                        if sl.outer.Hide then sl.outer:Hide() end
                    else
                        if type(sl.outer.SetColorTexture) == "function" then
                            sl.outer:SetColorTexture(rimCol[1], rimCol[2], rimCol[3], 1)
                        end
                        if sl.outer.Show then sl.outer:Show() end
                    end
                end
            end

            sl.icon:ClearAllPoints()
            sl.icon:SetPoint("TOPLEFT", sl.frame, "TOPLEFT", inset, -inset)
            sl.icon:SetPoint("BOTTOMRIGHT", sl.frame, "BOTTOMRIGHT", -inset, inset)
            if type(sl.icon.SetTexCoord) == "function" then
                sl.icon:SetTexCoord(z, 1 - z, z, 1 - z)
            end
            if type(sl.text.SetTextColor) == "function" then
                sl.text:SetTextColor(txt[1], txt[2], txt[3], 1)
            end
        end

        -- Paint mock overhead Nameplates reflecting active/staged Nameplates look (fallback when module absent)
        local npSet, npPrev = resolveNameplateLook()
        local npBorderPx = math.max(1, math.min(4, tonumber(npPrev.borderPx) or 2))
        local npRound = (npPrev.corner == "round")
        local npShadow = (npPrev.shadow ~= false)
        local npBarW = math.max(106, math.min(186, math.floor((tonumber(npSet.width) or 170) * 0.88)))
        local npBarH = math.max(8, math.min(24, tonumber(npSet.height) or 16))
        local npCastH = math.max(9, math.min(20, tonumber(npSet.castHeight) or 14))
        local npCastIcon = (npSet.castIcon ~= false)
        local npShowPct = (npSet.percent ~= false)
        local npShowLvl = (npSet.level ~= false)
        local npPctSign = (npSet.percentSign ~= false)
        local npTargetStyle = npSet.targetStyle or "outline"
        local npTargetArrows = npSet.targetArrows or "none"
        local npBackAlpha = tonumber(npSet.backAlpha) or 0.80
        local npBarTexKey = npSet["media.health"]
        local npBarTexPath = (type(d.Media) == "table" and type(d.Media.Fetch) == "function" and npBarTexKey and npBarTexKey ~= "daylight")
            and select(2, pcall(d.Media.Fetch, "statusbar", npBarTexKey)) or nil

        for i = 1, #npPlates do
            local pl = npPlates[i]
            local bw = pl.isTarget and math.floor(npBarW * 1.08) or (pl.isFriendly and math.floor(npBarW * 0.86) or npBarW)
            local bh = pl.isFriendly and math.max(8, math.min(18, tonumber(npSet["friendly.height"]) or math.max(8, npBarH - 4))) or npBarH
            pl.barHost:SetSize(bw, bh)
            local nameGap = (pl.isTarget and npTargetStyle == "glow") and (npBorderPx + 6) or (npBorderPx + 4)
            pl.nameFs:ClearAllPoints()
            pl.nameFs:SetPoint("BOTTOM", pl.barHost, "TOP", 0, nameGap)
            if type(pl.nameFs.SetTextColor) == "function" then
                if pl.isFriendly then
                    pl.nameFs:SetTextColor(0.45, 0.88, 0.55, 1)
                else
                    pl.nameFs:SetTextColor(txt[1], txt[2], txt[3], 1)
                end
            end

            -- Shadow
            if pl.shadow.ClearAllPoints then pl.shadow:ClearAllPoints() end
            pl.shadow:SetPoint("TOPLEFT", pl.barHost, "TOPLEFT", -3, 3)
            pl.shadow:SetPoint("BOTTOMRIGHT", pl.barHost, "BOTTOMRIGHT", 3, -3)
            if npShadow then
                if type(pl.shadow.SetColorTexture) == "function" then pl.shadow:SetColorTexture(0, 0, 0, 0.50) end
                if pl.shadow.Show then pl.shadow:Show() end
            else
                if pl.shadow.Hide then pl.shadow:Hide() end
            end

            -- Target highlight rim / glow
            if pl.rim.ClearAllPoints then pl.rim:ClearAllPoints() end
            if pl.isTarget and npTargetStyle ~= "none" then
                local pad = (npTargetStyle == "glow") and (npBorderPx + 3) or (npBorderPx + 1)
                pl.rim:SetPoint("TOPLEFT", pl.barHost, "TOPLEFT", -pad, pad)
                pl.rim:SetPoint("BOTTOMRIGHT", pl.barHost, "BOTTOMRIGHT", pad, -pad)
                if type(pl.rim.SetColorTexture) == "function" then
                    pl.rim:SetColorTexture(acc[1], acc[2], acc[3], (npTargetStyle == "glow") and 0.65 or 0.95)
                end
                if pl.rim.Show then pl.rim:Show() end
            else
                if pl.rim.Hide then pl.rim:Hide() end
            end

            -- Border / corner chrome
            local rimCol = pl.isTarget and acc or brd
            if npRound then
                if pl.borderTex.Hide then pl.borderTex:Hide() end
                if pl.roundCard.fill.Show then pl.roundCard.fill:Show() end
                if pl.roundCard.line.Show then pl.roundCard.line:Show() end
                pl.roundCard.paint(bnd, 0.92, rimCol, 0.95)
            else
                if pl.roundCard.fill.Hide then pl.roundCard.fill:Hide() end
                if pl.roundCard.line.Hide then pl.roundCard.line:Hide() end
                pl.borderTex:ClearAllPoints()
                pl.borderTex:SetAllPoints(pl.barHost)
                if type(pl.borderTex.SetColorTexture) == "function" then
                    pl.borderTex:SetColorTexture(rimCol[1], rimCol[2], rimCol[3], 1)
                end
                if pl.borderTex.Show then pl.borderTex:Show() end
            end

            -- Bar backdrop & semantic combat fill (combat-color immune)
            pl.bgTex:ClearAllPoints()
            pl.bgTex:SetPoint("TOPLEFT", pl.barHost, "TOPLEFT", npBorderPx, -npBorderPx)
            pl.bgTex:SetPoint("BOTTOMRIGHT", pl.barHost, "BOTTOMRIGHT", -npBorderPx, npBorderPx)
            if type(pl.bgTex.SetColorTexture) == "function" then
                pl.bgTex:SetColorTexture(win[1], win[2], win[3], npBackAlpha)
            end

            local innerW = math.max(10, bw - npBorderPx * 2)
            local innerH = math.max(4, bh - npBorderPx * 2)
            pl.fillTex:ClearAllPoints()
            pl.fillTex:SetPoint("TOPLEFT", pl.barHost, "TOPLEFT", npBorderPx, -npBorderPx)
            pl.fillTex:SetSize(math.max(4, math.floor(innerW * pl.pctVal)), innerH)
            if npBarTexPath and type(pl.fillTex.SetTexture) == "function" then
                pl.fillTex:SetTexture(npBarTexPath)
                if type(pl.fillTex.SetVertexColor) == "function" then
                    pl.fillTex:SetVertexColor(pl.fillCol[1], pl.fillCol[2], pl.fillCol[3], 1)
                end
            elseif type(pl.fillTex.SetColorTexture) == "function" then
                pl.fillTex:SetColorTexture(pl.fillCol[1], pl.fillCol[2], pl.fillCol[3], 1)
            end

            -- Level badge (enemy plates when level is enabled)
            if pl.lvlFs then
                if not pl.isFriendly and pl.lvlStr and npShowLvl and bh >= 12 then
                    pl.lvlFs:SetText(pl.lvlStr)
                    if type(pl.lvlFs.SetTextColor) == "function" then pl.lvlFs:SetTextColor(1, 0.85, 0.25, 0.95) end
                    if pl.lvlFs.Show then pl.lvlFs:Show() end
                else
                    if pl.lvlFs.Hide then pl.lvlFs:Hide() end
                end
            end

            -- Health percent text
            local showThisPct = pl.isFriendly and (npSet["friendly.percent"] == true) or (not pl.isFriendly and npShowPct)
            if showThisPct then
                local numStr = tostring(math.floor(pl.pctVal * 100))
                pl.pctFs:SetText(npPctSign and (numStr .. "%") or numStr)
                if type(pl.pctFs.SetTextColor) == "function" then pl.pctFs:SetTextColor(1, 1, 1, 0.95) end
                if pl.pctFs.Show then pl.pctFs:Show() end
            else
                if pl.pctFs.Hide then pl.pctFs:Hide() end
            end

            -- Target side arrows
            if pl.arrowL and pl.arrowR then
                local showArrows = (npTargetArrows == "sides")
                pl.arrowL:ClearAllPoints()
                pl.arrowL:SetPoint("RIGHT", pl.barHost, "LEFT", -4, 0)
                pl.arrowR:ClearAllPoints()
                pl.arrowR:SetPoint("LEFT", pl.barHost, "RIGHT", 4, 0)
                if type(pl.arrowL.SetTextColor) == "function" then pl.arrowL:SetTextColor(acc[1], acc[2], acc[3], 1) end
                if type(pl.arrowR.SetTextColor) == "function" then pl.arrowR:SetTextColor(acc[1], acc[2], acc[3], 1) end
                if showArrows then
                    if pl.arrowL.Show then pl.arrowL:Show() end
                    if pl.arrowR.Show then pl.arrowR:Show() end
                else
                    if pl.arrowL.Hide then pl.arrowL:Hide() end
                    if pl.arrowR.Hide then pl.arrowR:Hide() end
                end
            end

            -- Attached interruptible cast bar on Target plate
            if pl.castHost then
                pl.castHost:ClearAllPoints()
                pl.castHost:SetPoint("TOPLEFT", pl.barHost, "BOTTOMLEFT", 0, -3)
                pl.castHost:SetSize(bw, npCastH)
                pl.castBg:ClearAllPoints()
                pl.castBg:SetAllPoints(pl.castHost)
                if type(pl.castBg.SetColorTexture) == "function" then
                    pl.castBg:SetColorTexture(win[1], win[2], win[3], 0.92)
                end
                pl.castFill:ClearAllPoints()
                pl.castFill:SetPoint("TOPLEFT", pl.castHost, "TOPLEFT", 1, -1)
                pl.castFill:SetSize(math.max(8, math.floor((bw - 2) * 0.68)), math.max(4, npCastH - 2))
                if type(pl.castFill.SetColorTexture) == "function" then
                    pl.castFill:SetColorTexture(0.82, 0.64, 0.24, 1)
                end
                if type(pl.castText.SetTextColor) == "function" then pl.castText:SetTextColor(1, 1, 1, 0.95) end
                if type(pl.castTime.SetTextColor) == "function" then pl.castTime:SetTextColor(1, 1, 1, 0.90) end
                if pl.castIconBox then
                    pl.castIconBox:ClearAllPoints()
                    pl.castIconBox:SetPoint("RIGHT", pl.castHost, "LEFT", -3, 0)
                    pl.castIconBox:SetSize(npCastH, npCastH)
                    if npCastIcon then
                        if pl.castIconBox.Show then pl.castIconBox:Show() end
                    else
                        if pl.castIconBox.Hide then pl.castIconBox:Hide() end
                    end
                end
            end
        end
    end

    previewDeckRefresh = paintHeader

    return {
        frame = container,
        hint = "Click the Preview selector to switch frames, pick a look below, then click Apply.",
        zoomRange = playerS.zoomRange,
        Zoom = playerS.Zoom,
        SetZoom = function(v)
            if type(playerS.SetZoom) == "function" then pcall(playerS.SetZoom, v) end
            if targetS and type(targetS.SetZoom) == "function" then pcall(targetS.SetZoom, v) end
            for _, s in pairs(extraSamples) do
                if type(s) == "table" and type(s.SetZoom) == "function" then pcall(s.SetZoom, v) end
            end
        end,
        Refresh = function(w, room)
            if not showDeckOnTab() then
                hideAllSamples()
                if header.Hide then header:Hide() end
                return 0
            end
            if header.Show then header:Show() end
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
            header:SetWidth(w)
            paintHeader()
            hideAllSamples()
            local topOffset = HEADER_H + 6
            local subRoom = type(room) == "number" and math.max(40, room - topOffset) or room

            if previewDeckMode == "actionbars" then
                if abPreview.Show then abPreview:Show() end
                abPreview:ClearAllPoints()
                abPreview:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -topOffset)
                abPreview:SetWidth(w)
                local totalW = #abSlots * 38 + (#abSlots - 1) * 8
                local startX = math.max(8, math.floor((w - totalW) / 2))
                for i = 1, #abSlots do
                    abSlots[i].frame:ClearAllPoints()
                    abSlots[i].frame:SetPoint("TOPLEFT", abPreview, "TOPLEFT", startX + (i - 1) * 46, -9)
                end
                local h = topOffset + 56
                container:SetSize(w, h)
                return h
            end

            if previewDeckMode == "nameplates" then
                local npEnemyS = getExtraSample("nameplates", "Nameplates.plates")
                if npEnemyS then
                    local npFriendS = getExtraSample("nameplates_friendly", "Nameplates.friendly")
                    if npEnemyS.frame.Show then npEnemyS.frame:Show() end
                    if npFriendS then
                        if npFriendS.frame.Show then npFriendS.frame:Show() end
                        local gap = 16
                        local half = math.max(160, math.floor((w - gap) / 2))
                        local okE, he = pcall(npEnemyS.Refresh, half, subRoom)
                        local okF, hf = pcall(npFriendS.Refresh, half, subRoom)
                        he = (okE and type(he) == "number" and he > 0) and he or 80
                        hf = (okF and type(hf) == "number" and hf > 0) and hf or 50
                        local maxH = math.max(he, hf)
                        local eTop = topOffset + math.floor((maxH - he) / 2)
                        local fTop = topOffset + math.floor((maxH - hf) / 2)
                        local h = topOffset + maxH
                        container:SetSize(w, h)
                        npEnemyS.frame:ClearAllPoints()
                        npEnemyS.frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -eTop)
                        npFriendS.frame:ClearAllPoints()
                        npFriendS.frame:SetPoint("TOPLEFT", container, "TOPLEFT", half + gap, -fTop)
                        return h
                    end
                    local okE, he = pcall(npEnemyS.Refresh, w, subRoom)
                    he = (okE and type(he) == "number" and he > 0) and he or 80
                    npEnemyS.frame:ClearAllPoints()
                    npEnemyS.frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -topOffset)
                    local h = topOffset + he
                    container:SetSize(w, h)
                    return h
                end

                -- Fallback mock strip when DaylightUI_Nameplates is not loaded/enabled
                if npPreview.Show then npPreview:Show() end
                npPreview:ClearAllPoints()
                npPreview:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -topOffset)
                npPreview:SetWidth(w)
                local colW = math.max(150, math.floor((w - 24) / 3))
                for i = 1, #npPlates do
                    local pl = npPlates[i]
                    local cx = 12 + (i - 1) * colW + math.floor(colW / 2)
                    local yOff = pl.isTarget and -22 or -28
                    pl.wrap:ClearAllPoints()
                    pl.wrap:SetPoint("TOP", npPreview, "TOPLEFT", cx, 0)
                    pl.barHost:ClearAllPoints()
                    pl.barHost:SetPoint("TOP", pl.wrap, "TOP", 0, yOff)
                end
                local h = topOffset + NP_PREVIEW_H
                container:SetSize(w, h)
                return h
            end

            if previewDeckMode ~= "player_target" then
                local pageId = nil
                for i = 1, #DECK_MODES do
                    if DECK_MODES[i].key == previewDeckMode then pageId = DECK_MODES[i].page; break end
                end
                local sampleObj = getExtraSample(previewDeckMode, pageId)
                if sampleObj then
                    if sampleObj.frame.Show then sampleObj.frame:Show() end
                    if type(sampleObj.f) == "table" and sampleObj.f.Show then sampleObj.f:Show() end
                    local okR, sh = pcall(sampleObj.Refresh, w, subRoom)
                    sh = (okR and type(sh) == "number" and sh > 0) and sh or 60
                    sampleObj.frame:ClearAllPoints()
                    sampleObj.frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -topOffset)
                    local h = topOffset + sh
                    container:SetSize(w, h)
                    return h
                end
            end

            if playerS.frame.Show then playerS.frame:Show() end
            if targetS then
                if targetS.frame.Show then targetS.frame:Show() end
                local gap = 16
                local half = math.max(120, math.floor((w - gap) / 2))
                local hp = playerS.Refresh(half, subRoom) or 0
                local ht = targetS.Refresh(half, subRoom) or 0
                local function centerOffsetFromTop(sampleObj, boxH)
                    local f = sampleObj.f
                    if type(f) == "table" and type(f.GetPoint) == "function" then
                        local _, _, _, _, cy = f:GetPoint(1)
                        local sc = type(f.GetScale) == "function" and f:GetScale() or 1
                        return (boxH / 2) - ((tonumber(cy) or 0) * (tonumber(sc) or 1))
                    end
                    return boxH / 2
                end
                local pCenter = centerOffsetFromTop(playerS, hp)
                local tCenter = centerOffsetFromTop(targetS, ht)
                local alignY = math.max(pCenter, tCenter)
                local pTop = topOffset + math.floor(alignY - pCenter + 0.5)
                local tTop = topOffset + math.floor(alignY - tCenter + 0.5)
                local h = math.max(pTop + hp, tTop + ht)
                container:SetSize(w, h)
                playerS.frame:ClearAllPoints()
                playerS.frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -pTop)
                targetS.frame:ClearAllPoints()
                targetS.frame:SetPoint("TOPLEFT", container, "TOPLEFT", half + gap, -tTop)
                return h
            end
            local h = topOffset + (playerS.Refresh(w, subRoom) or 0)
            container:SetSize(w, h)
            playerS.frame:ClearAllPoints()
            playerS.frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -topOffset)
            return h
        end,
        Parts = function() return {} end,
    }
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
    local activeCat = (ns.groups[1] and ns.groups[1].key) or "_dark"
    local hoverId = nil

    -- Pick the category that owns the currently active palette on initial open.
    local initId = currentId()
    for g = 1, #ns.groups do
        local grp = ns.groups[g]
        for i = 1, #grp.ids do
            if grp.ids[i] == initId then activeCat = grp.key end
        end
    end

    -- Create the Custom button first so test harnesses targeting rowButtons[1] open the Custom editor.
    local customBtn = CreateFrame("Button", nil, row)
    customBtn:SetHeight(24)
    local customCard = ns.makeRoundCard(customBtn)
    local customLabel = blankText(customBtn)
    customLabel:SetPoint("CENTER", customBtn, "CENTER", 0, 0)
    customLabel:SetText("Custom Palette")
    local CUSTOM_DESC = "Your own background, band and accent, saved at this character."
    customBtn:SetWidth(114)
    customBtn:SetScript("OnEnter", function()
        hoverId = "custom"
        if type(row.palettesRefresh) == "function" then row.palettesRefresh() end
    end)
    customBtn:SetScript("OnLeave", function()
        if hoverId == "custom" then hoverId = nil end
        if type(row.palettesRefresh) == "function" then row.palettesRefresh() end
    end)
    customBtn:SetScript("OnClick", function()
        if type(row.palettesEditor) == "table" then
            editorOn = true
            if type(ns.readCustom) == "function" then
                customDraft = ns.readCustom(ns.accountTable(), ns.charTable())
            end
            if loadCustomEditor then loadCustomEditor() end
            local d = dui()
            if type(d) == "table" and type(d.Set) == "function" then d:Set("Palettes", "palette", "custom") end
        end
        if refreshList then refreshList() end
    end)

    -- Category filter pills: Dark (15), Class (9), Realm (11).
    local catButtons = {}
    for g = 1, #ns.groups do
        local grp = ns.groups[g]
        local b = CreateFrame("Button", nil, row)
        b:SetHeight(24)
        local card = ns.makeRoundCard(b)
        local label = blankText(b)
        label:SetPoint("CENTER", b, "CENTER", 0, 0)
        local title = string.gsub(grp.label, " Themes$", "") .. " (" .. tostring(#grp.ids) .. ")"
        label:SetText(title)
        b:SetWidth(math.max(76, 22 + string.len(title) * 6))
        b:SetScript("OnClick", function()
            activeCat = grp.key
            editorOn = false
            if type(row.palettesRefresh) == "function" then row.palettesRefresh() end
        end)
        catButtons[#catButtons + 1] = { key = grp.key, button = b, card = card, label = label }
    end

    local function rowWidth()
        local w = type(row.GetWidth) == "function" and row:GetWidth() or 0
        if type(w) ~= "number" or w < 240 then return 760 end
        return w
    end

    local CARD_H = 44
    local CARD_GAP_X = 8
    local CARD_GAP_Y = 6
    local CAT_TOP = -4
    local GRID_TOP = -36

    for g = 1, #ns.groups do
        local group = ns.groups[g]
        for i = 1, #group.ids do
            local p = ns.byId[group.ids[i]]
            local id, name, mood = p.id, p.name, p.mood
            local button = CreateFrame("Button", nil, row)
            button:SetHeight(CARD_H)
            local card = ns.makeRoundCard(button)

            local nameText = blankText(button)
            nameText:SetPoint("TOPLEFT", button, "TOPLEFT", 10, -6)
            nameText:SetJustifyH("LEFT")
            nameText:SetWordWrap(false)

            local edge = button:CreateTexture(nil, "ARTWORK")
            edge:SetSize(38, 12)
            edge:SetPoint("TOPRIGHT", button, "TOPRIGHT", -10, -7)
            local bgSwatch = button:CreateTexture(nil, "OVERLAY")
            bgSwatch:SetSize(10, 10)
            bgSwatch:SetPoint("LEFT", edge, "LEFT", 1, 0)
            local bandSwatch = button:CreateTexture(nil, "OVERLAY")
            bandSwatch:SetSize(10, 10)
            bandSwatch:SetPoint("LEFT", bgSwatch, "RIGHT", 1, 0)
            local accentSwatch = button:CreateTexture(nil, "OVERLAY")
            accentSwatch:SetSize(14, 10)
            accentSwatch:SetPoint("LEFT", bandSwatch, "RIGHT", 1, 0)

            local moodText = blankText(button)
            moodText:SetPoint("TOPLEFT", button, "TOPLEFT", 10, -23)
            moodText:SetPoint("RIGHT", button, "RIGHT", -24, 0)
            moodText:SetJustifyH("LEFT")
            moodText:SetWordWrap(false)

            local onText = blankText(button)
            onText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -8, 5)
            local check = button:CreateTexture(nil, "OVERLAY")
            check:SetSize(14, 14)
            check:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -8, 5)
            if type(check.SetTexture) == "function" then
                check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            end
            if check.Hide then check:Hide() end

            button:SetScript("OnClick", function()
                editorOn = false
                local live = id == currentId() and history.pending == nil
                if type(ns.stagePick) == "function" then
                    ns.stagePick("palette", id, function()
                        local d = dui()
                        if type(d) == "table" and type(d.Set) == "function" then
                            d:Set("Palettes", "palette", id)
                        end
                    end, live, name)
                else
                    local d = dui()
                    if type(d) == "table" and type(d.Set) == "function" then d:Set("Palettes", "palette", id) end
                end
                if refreshList then refreshList() end
            end)
            button:SetScript("OnEnter", function()
                hoverId = id
                for j = 1, #entries do entries[j].hot = entries[j].id == id end
                if type(row.palettesRefresh) == "function" then row.palettesRefresh() end
            end)
            button:SetScript("OnLeave", function()
                if hoverId == id then hoverId = nil end
                for j = 1, #entries do
                    if entries[j].id == id then entries[j].hot = false end
                end
                if type(row.palettesRefresh) == "function" then row.palettesRefresh() end
            end)
            entries[#entries + 1] = {
                id = id, cat = group.key, name = name, mood = mood,
                card = card, wash = card.fill, button = button,
                edge = edge, bgSwatch = bgSwatch, bandSwatch = bandSwatch, accentSwatch = accentSwatch,
                nameText = nameText, moodText = moodText, onText = onText, check = check,
            }
        end
    end

    -- Full description strip below the grid so long moods are never cut off.
    local descStrip = blankText(row)
    descStrip:SetJustifyH("LEFT")
    descStrip:SetWordWrap(false)

    local combatNote = blankText(row)
    combatNote:SetJustifyH("LEFT")
    combatNote:SetText("Applies when combat ends.")
    if combatNote.SetShown then combatNote:SetShown(false) end

    local function layoutGrid()
        local w = rowWidth() - 8
        local cols = w >= 600 and 3 or 2
        local cardW = math.floor((w - (cols - 1) * CARD_GAP_X) / cols)

        local cx = 4
        local cy = CAT_TOP
        for i = 1, #catButtons do
            local cb = catButtons[i].button
            cb:ClearAllPoints()
            cb:SetPoint("TOPLEFT", row, "TOPLEFT", cx, cy)
            cx = cx + (cb:GetWidth() or 84) + 6
        end
        customBtn:ClearAllPoints()
        customBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, cy)

        local shownIdx = 0
        for i = 1, #entries do
            local e = entries[i]
            local vis = (editorOn ~= true) and (e.cat == activeCat)
            if e.button.SetShown then e.button:SetShown(vis) end
            if vis then
                local r = math.floor(shownIdx / cols)
                local c = shownIdx - r * cols
                local x = 4 + c * (cardW + CARD_GAP_X)
                local y = GRID_TOP - r * (CARD_H + CARD_GAP_Y)
                e.button:ClearAllPoints()
                e.button:SetPoint("TOPLEFT", row, "TOPLEFT", x, y)
                e.button:SetWidth(cardW)
                e.nameText:SetWidth(math.max(60, cardW - 62))
                shownIdx = shownIdx + 1
            end
        end
        local rows = math.max(1, math.ceil(shownIdx / cols))
        local bottomY = GRID_TOP - rows * (CARD_H + CARD_GAP_Y) - 4
        descStrip:ClearAllPoints()
        descStrip:SetPoint("TOPLEFT", row, "TOPLEFT", 6, bottomY)
        descStrip:SetPoint("TOPRIGHT", row, "TOPRIGHT", -6, bottomY)
        combatNote:ClearAllPoints()
        combatNote:SetPoint("TOPLEFT", row, "TOPLEFT", 6, bottomY - 18)
        combatNote:SetPoint("TOPRIGHT", row, "TOPRIGHT", -6, bottomY - 18)
        row.palettesListHeight = math.abs(bottomY) + 22
    end

    layoutGrid()
    row.palettesHeight = row.palettesListHeight
    listRow = row

    if type(row.GetScript) == "function" and type(row.SetScript) == "function" then
        local prevSize = row:GetScript("OnSizeChanged")
        row:SetScript("OnSizeChanged", function(f)
            if type(prevSize) == "function" then prevSize(f) end
            if type(row.palettesRefresh) == "function" then row.palettesRefresh() end
        end)
    end

    function row.palettesRefresh()
        local id = currentId()
        local staged = ns.staged
        local stagedPalId = nil
        if type(staged) == "table" then
            if type(staged.palette) == "string" then
                stagedPalId = staged.palette
            elseif staged.kind == "palette" and type(staged.id) == "string" then
                stagedPalId = staged.id
            elseif staged.kind == "reset" and (staged.id == "Colours" or staged.id == "Presets") then
                stagedPalId = "off"
            end
        end
        local previewId = stagedPalId or id
        local p = ns.byId[previewId] or ns.byId[id]
        if editorOn == true and type(customDraft) == "table" and type(ns.deriveCustom) == "function" then
            local okD, derived = pcall(ns.deriveCustom, customDraft)
            if okD and type(derived) == "table" then p = derived end
        end
        local textColor = p and p.text or offColor("text") or { 0.9, 0.9, 0.9 }
        local labelColor = p and p.label or textColor
        local accent = p and p.c2 or offColor("c2") or textColor
        local window = p and p.window or offColor("window") or { 0.08, 0.10, 0.08 }
        local border = p and p.border or { 0.22, 0.28, 0.22 }
        local band = p and p.band or { 0.14, 0.18, 0.14 }
        local choiceColor = nil
        if p then choiceColor = accentChoice(p) end
        if choiceColor then accent = choiceColor end
        local pending = history.pending
        local waitingPick = pending ~= nil and pending ~= id
        local editorOpen = editorOn == true and type(row.palettesEditor) == "table"

        local cardSurface = blendColor(window, band, 0.26)
        local cardHover = blendColor(window, band, 0.55)
        for i = 1, #catButtons do
            local cb = catButtons[i]
            local on = (not editorOpen) and cb.key == activeCat
            cb.card.paint(
                on and blendColor(window, accent, 0.18) or cardSurface,
                0.92,
                on and accent or border,
                on and 0.95 or 0.65
            )
            uiFont(cb.label, ink, 11, on and accent or labelColor)
            if cb.button.SetShown then cb.button:SetShown(not editorOpen) end
        end
        customCard.paint(
            (id == "custom" or editorOpen) and blendColor(window, accent, 0.18) or cardSurface,
            0.92,
            (id == "custom" or editorOpen) and accent or border,
            0.85
        )
        uiFont(customLabel, ink, 11, (id == "custom" or editorOpen) and accent or textColor)
        if customBtn.SetShown then customBtn:SetShown(not editorOpen) end

        for i = 1, #entries do
            local entry = entries[i]
            local isApplied = entry.id == id
            local isStaged = (stagedPalId ~= nil and stagedPalId == entry.id)
            local waiting = waitingPick and entry.id == pending
            local hot = entry.hot and not isApplied and not isStaged and not waiting
            local rowPalette = ns.byId[entry.id]
            local cueColor = (rowPalette and rowPalette.c2) or accent
            local nameColor = textColor
            local moodColor = labelColor
            local markColor = waiting and labelColor or (isStaged and { 0.95, 0.62, 0.10 } or cueColor)

            if isStaged then
                entry.card.paint(blendColor(window, cueColor, 0.20), 0.98, cueColor, 1.0)
                nameColor = textColor
            elseif isApplied or waiting then
                entry.card.paint(blendColor(window, cueColor, 0.16), 0.96, cueColor, 0.95)
                nameColor, markColor = textColor, cueColor
            elseif hot then
                entry.card.paint(cardHover, 0.94, blendColor(border, cueColor, 0.55), 0.85)
            else
                entry.card.paint(cardSurface, 0.86, border, 0.55)
            end

            if isApplied and entry.check and type(entry.check.SetVertexColor) == "function" then
                entry.check:SetVertexColor(markColor[1], markColor[2], markColor[3], 1)
            end
            uiFont(entry.nameText, ink, 12, nameColor)
            uiFont(entry.moodText, ink, 11, moodColor)
            uiFont(entry.onText, ink, 10, markColor)
            entry.nameText:SetText(entry.name)
            entry.moodText:SetText(entry.mood)
            if entry.check and entry.check.Hide then entry.check:Hide() end
            if waiting then
                entry.onText:SetText("PENDING")
            elseif isStaged then
                entry.onText:SetText("PREVIEW")
            elseif isApplied then
                entry.onText:SetText("")
                if entry.check and entry.check.Show then entry.check:Show() end
            else
                entry.onText:SetText("")
            end
            paintDashes(entry, waiting, accent)
            if entry.bgSwatch then
                local palette = ns.byId[entry.id]
                paintSwatch(entry.edge, (palette and palette.border) or { 0.05, 0.05, 0.05 })
                paintSwatch(entry.bgSwatch, palette and palette.background)
                paintSwatch(entry.bandSwatch, palette and palette.band)
                paintSwatch(entry.accentSwatch, palette and accentBlock(palette))
            end
        end

        local focusPal = (hoverId and hoverId ~= "custom" and ns.byId[hoverId]) or p
        uiFont(descStrip, ink, 11, labelColor)
        if hoverId == "custom" then
            descStrip:SetText("Custom:  " .. CUSTOM_DESC)
        elseif focusPal then
            descStrip:SetText(focusPal.name .. ":  " .. (focusPal.mood or ""))
        else
            descStrip:SetText("Pick a palette to preview it on DaylightUI.")
        end
        if descStrip.SetShown then descStrip:SetShown(not editorOpen) end

        layoutGrid()
        uiFont(combatNote, ink, 12, labelColor)
        if combatNote.SetShown then
            combatNote:SetShown((waitingPick or heldPaint == true) and not editorOpen)
        end
        if type(row.palettesEditor) == "table" and row.palettesEditor.SetShown then
            row.palettesEditor:SetShown(editorOpen)
        end
        if not editorOpen and type(row.palettesAsk) == "table" and row.palettesAsk.Hide then
            row.palettesAsk:Hide()
        end
        if editorOpen and previewCustom then previewCustom() end
        local want = editorOpen and (row.palettesEditorHeight or EDITOR_H) or row.palettesListHeight
        if type(want) == "number" and want ~= row.palettesHeight and not row.palettesLaying then
            row.palettesHeight = want
            row.palettesLaying = true
            local panel = dui()
            panel = type(panel) == "table" and panel.OptionsPanel
            if type(panel) == "table" and type(panel.Refresh) == "function" then pcall(panel.Refresh) end
            row.palettesLaying = false
        elseif type(want) == "number" then
            row.palettesHeight = want
        end
        if syncUndo then syncUndo() end
    end
    row.palettesRefresh()
    pcall(buildCustomEditor, row)
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
    if type(ns.byId.custom) == "table" then
        values.customGroup = "Custom"
        order[#order + 1] = "customGroup"
        titles.customGroup = true
        values.custom = "Custom"
        order[#order + 1] = "custom"
    end
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
    -- Drop saved choices from removed settings on enable/reload.
    if type(db) == "table" then
        db.mixAccent = nil
        db.glow = nil
    end
    account.glow = nil
    char.glow = nil
    -- 0.1.0 still moves into the account once. After that the profile wins.
    ns.migrateLogin(account, char, db)
    if type(ns.migrateFrames) == "function" then pcall(ns.migrateFrames) end
    local id, accent, onlyOn, unknown, capped, hadLook, changed = ns.adoptProfile(account, char, db)
    ns.resetUndo(history, id)
    heldPaint = false
    local d = dui()
    if type(d) == "table" and type(d.Set) == "function" and type(d.Get) == "function" then
        applying = true
        if d:Get("Palettes", "palette") ~= id then d:Set("Palettes", "palette", id) end
        if (d:Get("Palettes", "classAccent") == true) ~= (accent == true) then
            d:Set("Palettes", "classAccent", accent == true)
        end
        if (d:Get("Palettes", "only") == true) ~= (onlyOn == true) then
            d:Set("Palettes", "only", onlyOn == true)
        end
        if type(db) == "table" then d:Set("Palettes", "custom", db.custom) end
        if type(db) == "table" and db.looks ~= nil then d:Set("Palettes", "looks", db.looks) end
        if type(db) == "table" and db.theme ~= nil then d:Set("Palettes", "theme", db.theme) end
        if type(db) == "table" and db.themeChanged ~= nil then d:Set("Palettes", "themeChanged", db.themeChanged == true) end
        if type(db) == "table" and db.frame ~= nil then d:Set("Palettes", "frame", db.frame) end
        if d:Get("Palettes", "glow") ~= nil then d:Set("Palettes", "glow", nil) end
        if d:Get("Palettes", "carried") ~= true then d:Set("Palettes", "carried", true) end
        applying = false
    end
    ready = true
    if unknown then
        say("Palettes: That profile's palette isn't in this version, so Ember is on instead. Your layout is unchanged.")
        apply("ember", true, true)
    elseif id ~= "off" then
        apply(id)
    elseif hadLook and changed then
        apply("off")
    end
    if capped then say("Palettes: Custom base was darkened so text stays readable.") end
end

local function buttonWords(button, text)
    if type(button) ~= "table" then return end
    if type(button.text) == "table" and type(button.text.SetText) == "function" then
        button.text:SetText(text)
    elseif type(button.SetText) == "function" then
        button:SetText(text)
    end
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
        blurb = "Colors and frame looks for Daylight. Class and combat colors stay Daylight's.",
    })
    if type(plugin) ~= "table" or plugin.off then return end

    local coloursPage = {
        id = "colours",
        label = "Colours",
        desc = "Recolor Daylight's windows, panels, borders, accent and text. Class and combat colors stay Daylight's. Picking a palette never changes the frame look.",
        groups = {
            {
                tab = "Colours",
                label = "Palettes",
                items = {
                    { type = "custom", label = "Choices", noSearch = true, build = buildList, update = function(row)
                        if type(row.palettesRefresh) == "function" then pcall(row.palettesRefresh) end
                    end, height = function(row) return row.palettesHeight or 430 end },
                    { type = "toggle", key = "classAccent", label = "Accent follows class",
                        desc = "Uses your class color as the chrome accent. The shade keeps the class hue and moves only as far as it needs to clear 3:1 on this frame. Names, chat, and unit frames stay the game's colors.",
                        hidden = function() return editorOn == true end },
                    { type = "toggle", key = "only", label = "Save for this character only",
                        desc = "Off: this character uses your account palette. On: changes here apply only to this character.",
                        hidden = function() return editorOn == true end },
                },
            },
        },
    }
    -- One page. Daylight's options page draws a tab strip from group.tab
    -- (Options/Widgets.lua W.Page). Tabs show only when a group on them has a visible row.
    local groups = {}
    local function take(page)
        if type(page) ~= "table" or type(page.groups) ~= "table" then return end
        for i = 1, #page.groups do groups[#groups + 1] = page.groups[i] end
    end
    if type(ns.themesPage) == "function" then
        local okThemes, themesPage = pcall(ns.themesPage)
        if okThemes then take(themesPage) end
    end
    take(coloursPage)
    if type(ns.looksPage) == "function" then
        local okPage, looksPage = pcall(ns.looksPage)
        if okPage then take(looksPage) end
    end
    d:RegisterModule("Palettes", {
        label = "Palettes",
        plugin = "Palettes",
        defaults = {
            palette = "off", classAccent = false, only = false, carried = false,
            theme = false, themeChanged = false, frame = false, looks = false,
        },
        OnEnable = onEnable,
        options = { pages = {
            {
                id = "main",
                label = "Palettes",
                -- Daylight draws this as one non-wrapping line and clips the last
                -- glyph when the string is wider than the header. The short line
                -- fits. The trailing space is the glyph that gets clipped, so the
                -- period stays on every load.
                desc = "Presets set a palette and a frame look. ",
                sample = makePlayerSample,
                groups = groups,
            },
        } },
    })
    if type(ns.bootLooks) == "function" then pcall(ns.bootLooks) end

    local view = type(api.For) == "function" and api.For("Palettes") or nil
    if type(view) == "table" then
        if type(view.On) == "function" then
            view.On("SettingChanged", onSetting)
        end
        if type(view.AddOptionsGroup) == "function" then
            view.AddOptionsGroup("appearance", {
                label = "Colours",
                desc = "Synced with Plugins > Palettes > Colours. Changing Accent or Window tint below switches it off.",
                items = {
                    { type = "dropdown", key = "palette", label = "Colours", choices = menuChoices },
                    { type = "text", label = "Editing Accent or Window tint switches Palettes colours off. Class and combat colors stay Daylight's." },
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
    if type(ns.dropFramePreview) == "function" then ns.dropFramePreview() end
    if history.pending ~= nil then
        ns.undoPalette(history, ns.accountTable(), ns.charTable())
        if type(ns.cancelLooksOff) == "function" then ns.cancelLooksOff() end
        if refreshList then refreshList() end
        return
    end
    if type(ns.looksWaiting) == "function" and ns.looksWaiting() and type(ns.cancelStylePending) == "function" then
        ns.cancelStylePending()
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

local function rebuildStagedSummary(draft)
    local count = 0
    local singleKind, singleId, singleLabel, singleCat = nil, nil, nil, nil
    if draft.baseKind then
        count = count + 1
        singleKind, singleId, singleLabel = draft.baseKind, draft.baseId, draft.baseLabel
    end
    if draft.palette ~= nil then
        count = count + 1
        singleKind, singleId, singleLabel = "palette", draft.palette, draft.paletteLabel or draft.palette
    end
    if draft.frame ~= nil then
        count = count + 1
        singleKind, singleId, singleLabel = "frame", draft.frame, draft.frameLabel or draft.frame
    end
    if type(draft.looks) == "table" then
        for ck, optId in pairs(draft.looks) do
            count = count + 1
            singleKind, singleId, singleCat = "look", optId, ck
            singleLabel = (type(draft.lookLabels) == "table" and draft.lookLabels[ck]) or optId
        end
    end
    if count == 0 then return nil end
    draft.count = count
    if count == 1 then
        draft.kind = singleKind
        draft.id = singleId
        draft.catKey = singleCat
        draft.label = singleLabel or singleId
    else
        draft.kind = draft.baseKind or "multi"
        draft.id = draft.baseId or "multi"
        draft.catKey = nil
        if draft.baseKind and draft.baseLabel then
            draft.label = draft.baseLabel .. " + " .. tostring(count - 1) .. " tweak" .. ((count - 1) == 1 and "" or "s")
        else
            draft.label = tostring(count) .. " changes"
        end
    end
    local needsReload = (draft.palette ~= nil)
        or (draft.baseKind == "theme")
        or (draft.baseKind == "mypreset")
        or (draft.baseKind == "reset" and draft.baseId ~= "Looks")
    draft.looksOnly = not needsReload
    draft.commit = function()
        if type(draft.baseCommit) == "function" then draft.baseCommit() end
        if type(draft.paletteCommit) == "function" then draft.paletteCommit() end
        if type(draft.frameCommit) == "function" then draft.frameCommit() end
        if type(draft.lookCommits) == "table" then
            for _, fn in pairs(draft.lookCommits) do
                if type(fn) == "function" then fn() end
            end
        end
    end
    return draft
end

-- A row click previews and accumulates into ns.staged across tabs & sub-menus.
-- Apply commits every staged selection at once.
function ns.stagePick(kind, id, commit, live, label, recipe, catKey)
    local draft = type(ns.staged) == "table" and ns.staged or nil

    -- Presets, My Presets, and Resets replace the staged draft base.
    if kind == "theme" or kind == "mypreset" or kind == "reset" then
        if live or (draft and draft.baseKind == kind and draft.baseId == id and draft.count == 1) then
            ns.staged = nil
        else
            ns.staged = rebuildStagedSummary({
                baseKind = kind, baseId = id, baseLabel = label or id,
                baseCommit = commit, recipe = recipe,
                looks = {}, lookLabels = {}, lookCommits = {},
            })
        end
        if type(ns.notePreview) == "function" then ns.notePreview() end
        return
    end

    -- Individual Colour or Look picks layer onto the existing draft (unless base was a Reset).
    if not draft or draft.baseKind == "reset" then
        draft = { looks = {}, lookLabels = {}, lookCommits = {} }
    else
        draft.looks = draft.looks or {}
        draft.lookLabels = draft.lookLabels or {}
        draft.lookCommits = draft.lookCommits or {}
    end

    if kind == "palette" then
        if live or draft.palette == id then
            draft.palette = nil
            draft.paletteLabel = nil
            draft.paletteCommit = nil
        else
            draft.palette = id
            draft.paletteLabel = label or id
            draft.paletteCommit = commit
        end
    elseif kind == "frame" then
        if live or draft.frame == id then
            draft.frame = nil
            draft.frameLabel = nil
            draft.frameCommit = nil
        else
            draft.frame = id
            draft.frameLabel = label or id
            draft.frameCommit = commit
        end
    elseif kind == "look" and type(catKey) == "string" then
        if live or draft.looks[catKey] == id then
            draft.looks[catKey] = nil
            draft.lookLabels[catKey] = nil
            draft.lookCommits[catKey] = nil
        else
            draft.looks[catKey] = id
            draft.lookLabels[catKey] = label or id
            draft.lookCommits[catKey] = commit
        end
    end

    ns.staged = rebuildStagedSummary(draft)
    if type(ns.notePreview) == "function" then ns.notePreview() end
end

function ns.cancelStaged()
    if type(ns.staged) ~= "table" then return false end
    ns.staged = nil
    if type(ns.RevertPreview) == "function" then pcall(ns.RevertPreview) end
    if type(ns.notePreview) == "function" then ns.notePreview() end
    if refreshList then refreshList() end
    if type(ns.refreshLooks) == "function" then ns.refreshLooks() end
    return true
end

local RELOAD_WHICH = "PALETTES_RELOAD"
local reloadArmed = false

local function queuedWrite()
    if not inCombat() then return false end
    if history.pending ~= nil or heldPaint == true then return true end
    if type(ns.looksWaiting) == "function" and ns.looksWaiting() then return true end
    return false
end

local function showReload()
    if type(ns.refreshGameMenu) == "function" then pcall(ns.refreshGameMenu) end
    if type(ns.askReload) == "function" then pcall(ns.askReload) end
end

-- Apply and the tab resets arm this. A slash command does not. The popup
-- waits until combat ends when the write itself waited.
function ns.finishQueuedReload(painted)
    if not reloadArmed or inCombat() then return false end
    reloadArmed = false
    if painted == false then return false end
    showReload()
    return true
end

local actionDepth = 0
local reloadWanted = false

-- One user action can write from several places. The popup waits until the
-- action finishes, and a second call in that same action does not open another.
function ns.requestReload()
    if actionDepth > 0 then
        reloadWanted = true
        return
    end
    if queuedWrite() then
        reloadArmed = true
        return
    end
    showReload()
end

function ns.withReloadAction(fn)
    actionDepth = actionDepth + 1
    local ok, err = pcall(fn)
    actionDepth = actionDepth - 1
    if actionDepth < 0 then actionDepth = 0 end
    if actionDepth == 0 and reloadWanted then
        reloadWanted = false
        if queuedWrite() then
            reloadArmed = true
        else
            showReload()
        end
    elseif actionDepth == 0 then
        reloadWanted = false
    end
    if not ok then error(err, 0) end
end

function ns.askReload()
    local dialogs = StaticPopupDialogs
    local show = StaticPopup_Show
    if type(dialogs) ~= "table" or type(show) ~= "function" then
        say("Palettes: reload to finish applying your changes.")
        return false
    end
    if type(dialogs[RELOAD_WHICH]) ~= "table" then
        -- StaticPopup_Show / StaticPopupDialogs, verified on warcraft.wiki.gg.
        -- Reload is C_UI.Reload on Forever 1.60.1; ReloadUI remains the alias.
        -- Both need a hardware event, which the popup button click is.
        dialogs[RELOAD_WHICH] = {
            text = "Reload to finish applying your changes?",
            button1 = "Reload now",
            button2 = "Later",
            OnAccept = function()
                if type(C_UI) == "table" and type(C_UI.Reload) == "function" then
                    C_UI.Reload()
                elseif type(ReloadUI) == "function" then
                    ReloadUI()
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end
    local ok = pcall(show, RELOAD_WHICH)
    return ok
end

function ns.commitStaged()
    local staged = ns.staged
    if type(staged) ~= "table" or type(staged.commit) ~= "function" then return false end
    ns.staged = nil
    -- Frame and extra looks repaint live. Only colours/presets/full-reset need a reload.
    local looksOnly = staged.looksOnly == true
    local isReset = staged.kind == "reset" or staged.baseKind == "reset"
    local hasLookPreview = (staged.frame ~= nil)
        or (type(staged.looks) == "table" and next(staged.looks) ~= nil)
        or staged.kind == "frame" or staged.kind == "look"
        or staged.baseKind == "theme" or staged.baseKind == "mypreset"
        or staged.kind == "theme" or staged.kind == "mypreset"
    ns.withReloadAction(function()
        if hasLookPreview and type(ns.CommitPreview) == "function" then
            ns.CommitPreview(staged.commit)
        else
            staged.commit()
        end
        if not looksOnly and not isReset then ns.requestReload() end
    end)
    if type(ns.notePreview) == "function" then ns.notePreview() end
    if refreshList then refreshList() end
    if type(ns.refreshLooks) == "function" then ns.refreshLooks() end
    return true
end

function ns.coloursResetHidden()
    return editorOn == true
end

local TAB_ORDER = { "Presets", "Colours", "Looks" }

local function resetLabel(tab)
    local rows = ns.tabReset
    if type(rows) == "table" then
        for i = 1, #rows do
            if rows[i].tab == tab then return rows[i].label end
        end
    end
    if tab == "Colours" then return "Reset Colours" end
    if tab == "Looks" then return "Reset Looks" end
    return "Restore Daylight"
end

local function runTabReset(tab)
    ns.withReloadAction(function()
        ns.staged = nil
        if type(ns.RevertPreview) == "function" then ns.RevertPreview() end
        local beforeLook = type(ns.lookMark) == "function" and ns.lookMark() or ""
        local beforeCur, beforePend = history.current, history.pending
        local rows = ns.tabReset
        if type(rows) == "table" then
            for i = 1, #rows do
                if rows[i].tab == tab and type(rows[i].run) == "function" then
                    rows[i].run()
                end
            end
        elseif tab == "Colours" and type(DaylightUI) == "table" and type(DaylightUI.Set) == "function" then
            DaylightUI:Set("Palettes", "palette", "off")
        end
        local afterLook = type(ns.lookMark) == "function" and ns.lookMark() or ""
        -- Reset Looks only moves frames, which repaint live.
        local looksMoved = tab ~= "Looks" and beforeLook ~= afterLook
        if looksMoved or paletteMoved(beforeCur, beforePend) then
            ns.requestReload()
        end
    end)
    if refreshList then refreshList() end
    if type(ns.refreshLooks) == "function" then ns.refreshLooks() end
end

-- Issue #43: Per-tab Reset buttons stage their reset non-destructively into the Preview Deck first.
function ns.stageTabReset(tab)
    local lbl = resetLabel(tab)
    ns.stagePick("reset", tab, function()
        runTabReset(tab)
    end, false, lbl)
    if refreshList then refreshList() end
    if type(ns.refreshLooks) == "function" then ns.refreshLooks() end
end

ns.runTabReset = runTabReset

local function currentTab(panel)
    if type(panel) ~= "table" or type(panel.PageFrame) ~= "function" then return "Presets" end
    local pf = panel.PageFrame("Palettes.main")
    if type(pf) == "table" and type(pf.tab) == "string" and pf.tab ~= "" then return pf.tab end
    return "Presets"
end

local resetButtons
local applyButton
local cancelButton
local previewNote

-- Apply sits on the window. Daylight's scroll (and its backdrop) otherwise
-- runs to the same bottom edge and paints over the button. Leave a gap of
-- the button height plus its inset, and keep the button above that scroll.
local FOOTER_BUTTON_H = 24
local FOOTER_BOTTOM = 14
local FOOTER_GAP = 8
local footerResizeHooked

function ns.footerReserve()
    return FOOTER_BOTTOM + FOOTER_BUTTON_H + FOOTER_GAP
end

function ns.liftPageScroll(panel)
    if type(panel) ~= "table" then return nil end
    if type(panel.Current) == "function" and panel.Current() ~= "Palettes.main" then return nil end
    local frame = type(panel.Frame) == "function" and panel.Frame()
    local page = type(panel.PageFrame) == "function" and panel.PageFrame("Palettes.main")
    if type(frame) ~= "table" or type(page) ~= "table" or type(page.GetParent) ~= "function" then
        return nil
    end
    local scroll = page:GetParent()
    if type(scroll) ~= "table" or scroll == frame or type(scroll.SetPoint) ~= "function" then
        return nil
    end
    local topRel, topPoint, topX, topY, rightX
    if type(scroll.GetNumPoints) == "function" and type(scroll.GetPoint) == "function" then
        local n = scroll:GetNumPoints() or 0
        for i = 1, n do
            local point, rel, relPoint, x, y = scroll:GetPoint(i)
            if point == "TOPLEFT" then
                topRel, topPoint, topX, topY = rel, relPoint, x, y
            elseif point == "BOTTOMRIGHT" and type(x) == "number" then
                rightX = x
            end
        end
    end
    local reserve = ns.footerReserve()
    if type(scroll.ClearAllPoints) == "function" then scroll:ClearAllPoints() end
    if topRel ~= nil then
        scroll:SetPoint("TOPLEFT", topRel, topPoint, topX, topY)
    end
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", rightX or -16, reserve)
    local level = 8
    if type(scroll.GetFrameLevel) == "function" then
        local n = scroll:GetFrameLevel()
        if type(n) == "number" then level = n + 5 end
    end
    local function raiseBtn(btn)
        if type(btn) ~= "table" then return end
        if type(btn.SetFrameLevel) == "function" then btn:SetFrameLevel(level) end
        if type(btn.SetFrameStrata) == "function" and type(scroll.GetFrameStrata) == "function" then
            local strata = scroll:GetFrameStrata()
            if type(strata) == "string" and strata ~= "" then btn:SetFrameStrata(strata) end
        end
    end
    raiseBtn(applyButton)
    raiseBtn(cancelButton)
    if type(previewNote) == "table" and type(applyButton) == "table"
        and type(previewNote.SetParent) == "function" then
        local parent
        if type(previewNote.GetParent) == "function" then parent = previewNote:GetParent() end
        if parent ~= applyButton then previewNote:SetParent(applyButton) end
    end
    if not footerResizeHooked and type(frame.SetScript) == "function" then
        footerResizeHooked = true
        local old
        if type(frame.GetScript) == "function" then old = frame:GetScript("OnSizeChanged") end
        frame:SetScript("OnSizeChanged", function(self, ...)
            if type(old) == "function" then old(self, ...) end
            ns.liftPageScroll(panel)
        end)
    end
    return reserve
end

local function placeChrome(panel)
    local page = type(panel.Current) == "function" and panel.Current()
    local onPage = page == "Palettes.main"
    local tab = currentTab(panel)
    if not onPage and type(ns.staged) == "table" then
        ns.staged = nil
        if type(ns.notePreview) == "function" then pcall(ns.notePreview) end
    end
    if type(ns.setLooksOpen) == "function" then pcall(ns.setLooksOpen, onPage) end
    local editor = ns.coloursResetHidden()
    if type(resetButtons) == "table" then
        for i = 1, #TAB_ORDER do
            local name = TAB_ORDER[i]
            local button = resetButtons[name]
            if type(button) == "table" then
                local show = onPage and name == tab and not (editor and name == "Colours")
                if button.SetShown then button:SetShown(show)
                elseif show and button.Show then button:Show()
                elseif button.Hide then button:Hide() end
            end
        end
    end
    local staged = ns.staged
    local preview = onPage and type(staged) == "table"
    if type(applyButton) == "table" then
        if preview then
            local looksOnly = staged.looksOnly == true or staged.kind == "frame" or staged.kind == "look"
            local label = looksOnly and "Apply Live" or "Apply (Reloads UI)"
            buttonWords(applyButton, label)
            if applyButton.FitWidth then applyButton.FitWidth(looksOnly and 96 or 144) end
        end
        if applyButton.SetShown then applyButton:SetShown(preview)
        elseif preview and applyButton.Show then applyButton:Show()
        elseif applyButton.Hide then applyButton:Hide() end
    end
    if type(cancelButton) == "table" then
        if cancelButton.SetShown then cancelButton:SetShown(preview)
        elseif preview and cancelButton.Show then cancelButton:Show()
        elseif cancelButton.Hide then cancelButton:Hide() end
    end
    if type(previewNote) == "table" then
        if preview and previewNote.SetText then
            local nm = staged.label or staged.id or "your pick"
            previewNote:SetText("Previewing: " .. tostring(nm) .. " — Unsaved")
        end
        if previewNote.SetShown then previewNote:SetShown(preview)
        elseif preview and previewNote.Show then previewNote:Show()
        elseif previewNote.Hide then previewNote:Hide() end
    end
    ns.liftPageScroll(panel)
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

local previewRefreshing = false
ns.panelRefreshDepth = 0
ns.panelRefreshDirty = false

function ns.withSuppressedPanelRefresh(fn)
    ns.panelRefreshDepth = (ns.panelRefreshDepth or 0) + 1
    local ok, err = pcall(fn)
    ns.panelRefreshDepth = math.max(0, (ns.panelRefreshDepth or 1) - 1)
    if ns.panelRefreshDepth == 0 and ns.panelRefreshDirty then
        ns.panelRefreshDirty = false
        local d = dui()
        local panel = type(d) == "table" and d.OptionsPanel
        if type(panel) == "table" and type(panel.Refresh) == "function" and not previewRefreshing then
            previewRefreshing = true
            pcall(panel.Refresh)
            previewRefreshing = false
        end
    end
    if not ok then error(err, 0) end
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
                if (ns.panelRefreshDepth or 0) > 0 then
                    ns.panelRefreshDirty = true
                    return
                end
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
        local host = header
        local tabs = type(panel.Tabs) == "function" and panel.Tabs()
        if type(tabs) == "table" then host = tabs end
        resetButtons = {}
        for i = 1, #TAB_ORDER do
            local name = TAB_ORDER[i]
            local button = widgets.Button(host, resetLabel(name), 24)
            if type(button) == "table" then
                if button.FitWidth then button.FitWidth(150) end
                button:SetScript("OnClick", function()
                    if not pcall(ns.stageTabReset, name) then
                        say("Palettes: something went wrong, and nothing was staged.")
                    end
                end)
                resetButtons[name] = button
            end
        end
        local frame = type(panel.Frame) == "function" and panel.Frame() or header
        if type(frame) == "table" and type(frame.GetScript) == "function" and type(frame.SetScript) == "function" then
            local oldHide = frame:GetScript("OnHide")
            frame:SetScript("OnHide", function(self, ...)
                if type(oldHide) == "function" then oldHide(self, ...) end
                if type(ns.setLooksOpen) == "function" then pcall(ns.setLooksOpen, false) end
                if type(ns.staged) == "table" then
                    ns.staged = nil
                    if type(ns.notePreview) == "function" then pcall(ns.notePreview) end
                end
            end)
        end
        applyButton = widgets.Button(frame, "Apply", 24)
        if type(applyButton) == "table" then
            if applyButton.FitWidth then applyButton.FitWidth(144) end
            applyButton:SetScript("OnClick", function()
                if not pcall(ns.commitStaged) then
                    say("Palettes: something went wrong, and the pick was not applied.")
                end
            end)
            if applyButton.ClearAllPoints then applyButton:ClearAllPoints() end
            applyButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 14)

            cancelButton = widgets.Button(frame, "Cancel Preview", 24)
            if type(cancelButton) == "table" then
                if cancelButton.FitWidth then cancelButton.FitWidth(112) end
                cancelButton:SetScript("OnClick", function()
                    pcall(ns.cancelStaged)
                end)
                if cancelButton.ClearAllPoints then cancelButton:ClearAllPoints() end
                cancelButton:SetPoint("RIGHT", applyButton, "LEFT", -8, 0)
            end

            if type(frame.CreateFontString) == "function" then
                previewNote = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            end
            if type(previewNote) == "table" and previewNote.SetText then
                previewNote:SetText("Previewing your pick.")
                if type(previewNote.SetParent) == "function" then
                    previewNote:SetParent(applyButton)
                end
                if previewNote.ClearAllPoints then previewNote:ClearAllPoints() end
                previewNote:SetPoint("RIGHT", cancelButton or applyButton, "LEFT", -10, 0)
            end
        end
    end
    if type(resetButtons) == "table" then
        local host = type(panel.Header) == "function" and panel.Header()
        local tabs = type(panel.Tabs) == "function" and panel.Tabs()
        if type(tabs) == "table" then host = tabs end
        if type(host) == "table" then
            for i = 1, #TAB_ORDER do
                local button = resetButtons[TAB_ORDER[i]]
                if type(button) == "table" then
                    if type(button.GetParent) == "function" and button:GetParent() ~= host
                        and type(button.SetParent) == "function" then
                        button:SetParent(host)
                    end
                    if button.ClearAllPoints then button:ClearAllPoints() end
                    button:SetPoint("RIGHT", host, "RIGHT", -8, 0)
                end
            end
        end
    end
    placeUndo(panel)
    placeChrome(panel)
end

local previewPalId = nil
local function syncColorPreview()
    local staged = ns.staged
    local wantId = nil
    if type(staged) == "table" then
        if type(staged.palette) == "string" then
            wantId = staged.palette
        elseif staged.kind == "palette" then
            wantId = staged.id
        elseif (staged.baseKind == "theme" or staged.kind == "theme") and type(ns.themePaletteId) == "function" then
            wantId = ns.themePaletteId(staged.baseId or staged.id)
        elseif (staged.baseKind == "mypreset" or staged.kind == "mypreset") and type(staged.recipe) == "table" then
            wantId = staged.recipe.palette
        elseif (staged.baseKind == "reset" or staged.kind == "reset")
            and ((staged.baseId or staged.id) == "Colours" or (staged.baseId or staged.id) == "Presets") then
            wantId = "off"
        end
    end
    if wantId == previewPalId then return end
    previewPalId = wantId
    if inCombat() then return end
    local prevApplying = ns.applyingTheme
    local savedHistory = history.current
    ns.applyingTheme = true
    if wantId and (wantId == "off" or known(wantId)) then
        pcall(apply, wantId, false, true)
    else
        local liveId = currentId()
        if liveId ~= paintedId then
            pcall(apply, liveId, false, true)
        end
    end
    history.current = savedHistory
    ns.applyingTheme = prevApplying
end

ns.notePreview = function()
    ns.withSuppressedPanelRefresh(function()
        if syncUndo then syncUndo() end
        pcall(syncColorPreview)
        if type(ns.syncFramePreview) == "function" then pcall(ns.syncFramePreview) end
        ns.panelRefreshDirty = true
    end)
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
            local looksQueued = type(ns.looksWaiting) == "function" and ns.looksWaiting()
            local painted = waiting ~= nil or repaint == true or looksQueued == true
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
                if ns.shareLook and type(ns.applyShareLook) == "function" then
                    local look = ns.shareLook
                    ns.shareLook = nil
                    ns.applyingTheme = true
                    ns.applyShareLook(look)
                    ns.applyingTheme = false
                end
                if refreshList then refreshList() end
            elseif repaint then
                heldPaint = false
                local id = history.current
                if known(id) then apply(id, true) end
                if refreshList then refreshList() end
            end
            if type(ns.finishLooksCombat) == "function" then pcall(ns.finishLooksCombat) end
            if reloadArmed then ns.finishQueuedReload(painted) end
            return
        end
        if event == "ADDON_LOADED" and name == "Looks" and type(ns.noteLooksAddon) == "function" then
            ns.noteLooksAddon()
        end
        if event == "ADDON_LOADED" and name == "DaylightUI_UnitFrames" and type(ns.migrateFrames) == "function" then
            pcall(ns.migrateFrames)
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
