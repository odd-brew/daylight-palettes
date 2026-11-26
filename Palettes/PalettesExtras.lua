-- Curated Looks for Focus, Target of Target, Party, Raid, Cast Bars, and Action Bars,
-- plus Full-UI Preset recipes and User-Saved Presets.
-- Everything previews via DaylightUI's temporary Override handles and snapshots the
-- player's prior values before writing so Reset Looks / Restore Daylight restores cleanly.
local _, ns = ...

local FOCUS_LOOKS = {
    {
        id = "match", name = "Match Player & Target",
        desc = "Mirrors your active Player & Target frame look onto Focus without changing its width.",
        matchPT = true,
    },
    {
        id = "compact_beam", name = "Compact Beam",
        desc = "Sturdy dark name tab, crisp 2px border, and angled 2.0 portrait for a clear focus monitor.",
        style = "daylight", slant = true, border = 2, corner = 6, shadow = 8,
        tabWidth = "full", tabSlant = true, tabCorner = 4, tabShadow = 4,
        portrait = "2d", portraitLook = "2.0", portraitShape = "square", ring = "class", ringWidth = 2,
        nameOnBar = false, namePos = "outer", bigNumber = false,
    },
    {
        id = "slim_ribbon", name = "Slim Ribbon",
        desc = "Low-profile Ribbon bar with a floating name row, thin power underline, and rounded portrait.",
        style = "ribbon", slant = true, border = 1, corner = 4, shadow = 4,
        tabWidth = "fit", tabSlant = false, tabCorner = 4, tabShadow = 0,
        portrait = "2d", portraitLook = "2.0", portraitShape = "round", ring = "class", ringWidth = 2,
        nameOnBar = false, namePos = "outer", bigNumber = false,
    },
    {
        id = "minimal_slate", name = "Minimal Slate",
        desc = "Portrait-free sharp square Ribbon bar focused purely on health and cast readability.",
        style = "ribbon", slant = false, border = 1, corner = 0, shadow = 0,
        tabWidth = "fit", tabSlant = false, tabCorner = 0, tabShadow = 0,
        portrait = "none", portraitLook = "2.0", portraitShape = "square", ring = "none", ringWidth = 0,
        nameOnBar = true, namePos = "outer", bigNumber = false,
    },
}

local TOT_LOOKS = {
    {
        id = "match", name = "Match Player & Target",
        desc = "Shares border, corners, and bar style with your active Player & Target look.",
        matchPT = true,
    },
    {
        id = "compact_pill", name = "Compact Pill",
        desc = "Soft rounded miniature frame with centered target name and subtle shadow.",
        style = "daylight", slant = false, border = 2, corner = 8, shadow = 6,
    },
    {
        id = "slim_bar", name = "Slim Bar",
        desc = "Ultra-thin Ribbon bar with crisp 1px border and zero clutter.",
        style = "ribbon", slant = false, border = 1, corner = 2, shadow = 0,
    },
    {
        id = "crisp_square", name = "Crisp Square",
        desc = "Sharp-cornered utility tile built for tanks and healers watching target swaps.",
        style = "daylight", slant = false, border = 2, corner = 0, shadow = 2,
    },
}

local PARTY_LOOKS = {
    {
        id = "standard", name = "Daylight Standard",
        desc = "Angled 34px bars with round class portraits, top name tabs, and bold health.",
        slant = true, height = 34, showPower = true, powerHeight = 7,
        portrait = "class", portraitShape = "round", portraitLook = "socket",
        nameOnBar = false, bigNumber = true, showPercent = true, healthText = "percent",
        border = 2, corner = 6, shadow = 8, texture = "daylight",
    },
    {
        id = "compact", name = "Clean Compact",
        desc = "Slim 24px portrait-free silk bars with crisp 1px edges and inline names.",
        slant = false, height = 24, showPower = true, powerHeight = 4,
        portrait = "none", portraitShape = "square", portraitLook = "2.0",
        nameOnBar = true, bigNumber = false, showPercent = true, healthText = "percent",
        border = 1, corner = 2, shadow = 0, texture = "silk",
    },
    {
        id = "healer", name = "Healer Grid",
        desc = "Tall 42px portrait-free matte tiles built for instant health & debuff scanning.",
        slant = false, height = 42, showPower = true, powerHeight = 6,
        portrait = "none", portraitShape = "square", portraitLook = "2.0",
        nameOnBar = true, bigNumber = false, showPercent = true, healthText = "deficit",
        border = 2, corner = 4, shadow = 4, texture = "daylight",
    },
    {
        id = "framed", name = "Framed Classic",
        desc = "Sculpted 38px RPG plates with 2D character portraits, 3px brushed rim, and shadow.",
        slant = true, height = 38, showPower = true, powerHeight = 8,
        portrait = "2d", portraitShape = "square", portraitLook = "2.0",
        nameOnBar = false, bigNumber = true, showPercent = true, healthText = "percent",
        border = 3, corner = 6, shadow = 12, texture = "brushed",
    },
}

local RAID_LOOKS = {
    {
        id = "tiles", name = "Daylight Tiles",
        desc = "Balanced 76x32 rounded raid tiles with slim power strips and clean spacing.",
        width = 76, height = 32, spacing = 3, slant = false,
        showPower = true, powerHeight = 4, fillVertical = false, showPercent = false,
        border = 2, corner = 5, shadow = 6, texture = "daylight",
    },
    {
        id = "tight", name = "Tight Raid Grid",
        desc = "Dense 64x24 sharp-corner grid without power bars for 20- and 40-man clarity.",
        width = 64, height = 24, spacing = 1, slant = false,
        showPower = false, powerHeight = 2, fillVertical = false, showPercent = false,
        border = 1, corner = 0, shadow = 0, texture = "daylight",
    },
    {
        id = "matte", name = "Vertical Healer",
        desc = "Tall 72x42 upward-filling silk tiles with live health percentages.",
        width = 72, height = 42, spacing = 2, slant = false,
        showPower = true, powerHeight = 4, fillVertical = true, showPercent = true,
        border = 2, corner = 2, shadow = 2, texture = "silk",
    },
    {
        id = "framed", name = "Sculpted Plates",
        desc = "Wide 86x34 angled brushed plates with 3px rim, power bar, and health text.",
        width = 86, height = 34, spacing = 4, slant = true,
        showPower = true, powerHeight = 5, fillVertical = false, showPercent = true,
        border = 3, corner = 4, shadow = 8, texture = "brushed",
    },
}

local CAST_LOOKS = {
    {
        id = "matte", name = "Clean Matte",
        desc = "Crisp 18px flat bar with 1px edges and zero fill animation.",
        texture = "daylight", fx = "none", height = 18, border = 1, corner = 2, shadow = 0,
    },
    {
        id = "silk", name = "Silk Sheen",
        desc = "Sleek 16px woven silk bar with soft rounded corners and light shadow.",
        texture = "silk", fx = "none", height = 16, border = 2, corner = 6, shadow = 6,
    },
    {
        id = "brushed", name = "Brushed Metal",
        desc = "Sturdy 22px brushed steel bar with a bold 3px framed rim.",
        texture = "brushed", fx = "none", height = 22, border = 3, corner = 2, shadow = 10,
    },
    {
        id = "flow", name = "Living Flow",
        desc = "Rounded 20px bar with gentle liquid light flowing steadily across casts.",
        texture = "daylight", fx = "flow", height = 20, border = 2, corner = 6, shadow = 8,
    },
    {
        id = "tide", name = "Tidal Glass",
        desc = "Slim 16px polished glass bar with a slow rising tide shimmer.",
        texture = "glass", fx = "tide", height = 16, border = 2, corner = 4, shadow = 6,
    },
    {
        id = "molten", name = "Molten Ember",
        desc = "Bold 24px heavy-rimmed bar lit by a warm glowing ember pulse.",
        texture = "grain", fx = "molten", height = 24, border = 3, corner = 4, shadow = 12,
    },
}

local BUTTON_LOOKS = {
    {
        id = "classic", name = "Daylight Classic",
        desc = "Warm 2px Daylight rim with soft rounded corners and shadow.",
        shape = "square", borderStyle = "daylight", border = 2, corners = "round", shadow = true, zoom = 0.06,
    },
    {
        id = "flat", name = "Crisp Flat",
        desc = "Razor-thin 1px square frame for a clean modern grid.",
        shape = "square", borderStyle = "flat", border = 1, corners = "square", shadow = false, zoom = 0.08,
    },
    {
        id = "borderless", name = "Borderless Zoom",
        desc = "Edge-to-edge zoomed spell art with soft drop shadow.",
        shape = "square", borderStyle = "none", border = 1, corners = "round", shadow = true, zoom = 0.14,
    },
    {
        id = "heavy", name = "Heavy Rim",
        desc = "Bold 4px framed square buttons with strong RPG presence.",
        shape = "square", borderStyle = "daylight", border = 4, corners = "square", shadow = true, zoom = 0.04,
    },
    {
        id = "circle", name = "Rounded Medallion",
        desc = "Circular spell medallions with a clean ringed border.",
        shape = "circle", borderStyle = "daylight", border = 2, corners = "round", shadow = true, zoom = 0.12,
    },
    {
        id = "shield", name = "Shield Crest",
        desc = "Classic RPG shield-cut buttons with subtle shadow.",
        shape = "shield", borderStyle = "daylight", border = 2, corners = "round", shadow = true, zoom = 0.10,
    },
}

local function indexById(list)
    local t = {}
    for i = 1, #list do t[list[i].id] = list[i] end
    return t
end

ns.FOCUS_LOOKS, ns.FOCUS_BY_ID = FOCUS_LOOKS, indexById(FOCUS_LOOKS)
ns.TOT_LOOKS, ns.TOT_BY_ID = TOT_LOOKS, indexById(TOT_LOOKS)
ns.PARTY_LOOKS, ns.PARTY_BY_ID = PARTY_LOOKS, indexById(PARTY_LOOKS)
ns.RAID_LOOKS, ns.RAID_BY_ID = RAID_LOOKS, indexById(RAID_LOOKS)
ns.CAST_LOOKS, ns.CAST_BY_ID = CAST_LOOKS, indexById(CAST_LOOKS)
ns.BAR_FINISHES, ns.BAR_BY_ID = CAST_LOOKS, ns.CAST_BY_ID
ns.BUTTON_LOOKS, ns.BUTTON_BY_ID = BUTTON_LOOKS, indexById(BUTTON_LOOKS)

-- Complete 8-layer recipes & design rationales for all 10 curated Presets.
ns.PRESET_EXTRAS = {
    hearthnight = {
        focus = "compact_beam", tot = "compact_pill", party = "framed", raid = "framed",
        castbars = "molten", actionbars = "classic",
        why = "Tavern hearth warmth: Ember gold pairs with Beam's dark name tab, Molten Ember cast bars, and soft rounded Daylight Classic buttons.",
    },
    harvestide = {
        focus = "slim_ribbon", tot = "compact_pill", party = "standard", raid = "tiles",
        castbars = "silk", actionbars = "classic",
        why = "Warm oak and pewter without heaviness: Stream's slim ribbon bars, Silk Sheen cast bars, and rounded Daylight buttons keep the UI airy.",
    },
    tidemark = {
        focus = "minimal_slate", tot = "slim_bar", party = "compact", raid = "tight",
        castbars = "tide", actionbars = "flat",
        why = "Precision minimal UI: portrait-free Slate bars paired with 1px Crisp Flat buttons, Tight Raid Grid, and cool Tidal Glass shimmer.",
    },
    oldroad = {
        focus = "compact_beam", tot = "crisp_square", party = "framed", raid = "framed",
        castbars = "brushed", actionbars = "heavy",
        why = "Weathered bronze and heavy iron for Forever nostalgia: Beam's solid bars meet Brushed Metal cast bars and bold 4px Heavy Rim buttons.",
    },
    vigil = {
        focus = "slim_ribbon", tot = "compact_pill", party = "healer", raid = "matte",
        castbars = "silk", actionbars = "circle",
        why = "Built for healers and paladins: Stream's rounded portrait echoes circular Medallion buttons, with Healer Grid + Bordered Matte raid tiles.",
    },
    snug = {
        focus = "match", tot = "compact_pill", party = "standard", raid = "tiles",
        castbars = "flow", actionbars = "circle",
        why = "Rich gilded curves throughout: Flagon's rounded portrait and Living Flow motion tie directly into circular Rounded Medallion buttons.",
    },
    bellows = {
        focus = "compact_beam", tot = "crisp_square", party = "framed", raid = "matte",
        castbars = "brushed", actionbars = "heavy",
        why = "Industrial forge aesthetic: Trestle's named work-board frame, Brushed Metal cast bars, and Heavy Rim buttons give Forgeglow tactile punch.",
    },
    drawwell = {
        focus = "minimal_slate", tot = "crisp_square", party = "compact", raid = "tight",
        castbars = "matte", actionbars = "flat",
        why = "Zero-distraction dungeon & raid workhorse: portrait-free Ledger bars, Clean Matte casts, Crisp Flat buttons, and Tight Raid Grid.",
    },
    settle = {
        focus = "compact_beam", tot = "compact_pill", party = "framed", raid = "framed",
        castbars = "matte", actionbars = "shield",
        why = "Classic Azeroth RPG storytelling: aged brass and walnut paired with Beam frames, calm Matte cast bars, and Shield Crest buttons.",
    },
    afterhours = {
        focus = "slim_ribbon", tot = "slim_bar", party = "compact", raid = "tight",
        castbars = "tide", actionbars = "borderless",
        why = "Sleek late-night minimalism: deep carmine chrome paired with Borderless Zoom icons so spell art floats cleanly over dark glass.",
    },
}

local function dui()
    return type(DaylightUI) == "table" and DaylightUI or nil
end

local function inCombat()
    return type(InCombatLockdown) == "function" and InCombatLockdown() == true
end

local function batch(fn)
    if type(ns.withBulkWrite) == "function" then
        return pcall(ns.withBulkWrite, fn)
    end
    local d = dui()
    if type(d) == "table" and type(d.Batch) == "function" then
        return pcall(d.Batch, fn)
    end
    return pcall(fn)
end

local function readSetting(scope, key)
    local d = dui()
    if type(d) ~= "table" or type(d.Get) ~= "function" then return nil, false end
    local ok, val = pcall(d.Get, d, scope, key)
    if not ok then return nil, false end
    return val, true
end

local function writeSettingList(scope, list)
    local d = dui()
    if type(d) ~= "table" or type(d.Set) ~= "function" then return false end
    local failed = false
    local ran = batch(function()
        for i = 1, #list do
            local ok, res = pcall(d.Set, d, scope, list[i][1], list[i][2])
            if not ok or res == false then failed = true end
        end
    end)
    return ran and not failed
end

local function overrideHost()
    local d = dui()
    local api = type(d) == "table" and d.API
    if type(api) ~= "table" or type(api.For) ~= "function" then return nil end
    local ok, host = pcall(api.For, "Palettes")
    if ok and type(host) == "table" and type(host.Override) == "function" then return host end
    return nil
end

local function releaseHandles(handles)
    if type(handles) ~= "table" or #handles == 0 then return end
    local d = dui()
    local api = type(d) == "table" and d.API
    if type(api) ~= "table" or type(api.Off) ~= "function" then return end
    batch(function()
        for i = #handles, 1, -1 do pcall(api.Off, handles[i]) end
    end)
end

local function extrasStore()
    local acc = type(ns.accountTable) == "function" and ns.accountTable() or nil
    if type(acc) ~= "table" then return {} end
    if type(acc.extras) ~= "table" then acc.extras = {} end
    return acc.extras
end

local function resolvePTSpec()
    local ptId = type(ns.wornFrameId) == "function" and ns.wornFrameId() or nil
    if type(ns.staged) == "table" then
        if ns.staged.kind == "frame" then ptId = ns.staged.id
        elseif ns.staged.kind == "theme" and type(ns.themeFrameId) == "function" then ptId = ns.themeFrameId(ns.staged.id)
        elseif ns.staged.kind == "user_preset" and ns.staged.frame then ptId = ns.staged.frame end
    end
    return (ptId and type(ns.LOOK_SPECS) == "table" and ns.LOOK_SPECS[ptId]) or (type(ns.LOOK_SPECS) == "table" and ns.LOOK_SPECS.beam) or FOCUS_LOOKS[2]
end

local CATEGORY_CFG = {
    focus = {
        scope = "UnitFrames", byId = ns.FOCUS_BY_ID, storeKey = "focus", snapKey = "focusSnap",
        pairs = function(id)
            local spec = ns.FOCUS_BY_ID[id]
            if not spec then return {} end
            if spec.matchPT then spec = resolvePTSpec() end
            return {
                { "focus.style", spec.style or "daylight" },
                { "focus.slant", spec.slant == true },
                { "focus.shell.own", true },
                { "focus.shell.borderPx", spec.border or 2 },
                { "focus.shell.cornerPx", spec.corner or 4 },
                { "focus.shell.shadowPx", spec.shadow or 6 },
                { "focus.tab.own", true },
                { "focus.tab.width", spec.tabWidth or "full" },
                { "focus.tab.at", "outer" },
                { "focus.tab.slant", spec.tabSlant == true },
                { "focus.tab.align", "center" },
                { "focus.tab.color", "dark" },
                { "focus.tab.borderPx", 4 },
                { "focus.tab.cornerPx", spec.tabCorner or 4 },
                { "focus.tab.shadowPx", spec.tabShadow or 4 },
                { "focus.portrait", spec.portrait or "2d" },
                { "focus.portraitLook", spec.portraitLook or "2.0" },
                { "focus.portraitShape", spec.portraitShape or "square" },
                { "focus.portraitRing", spec.ring or "class" },
                { "focus.portraitRingWidth", spec.ringWidth or 2 },
                { "focus.portraitRingLine", true },
                { "focus.nameOnBar", spec.nameOnBar == true },
                { "focus.namePos", spec.namePos or "outer" },
                { "focus.bigNumber", spec.bigNumber == true },
            }
        end,
    },
    tot = {
        scope = "UnitFrames", byId = ns.TOT_BY_ID, storeKey = "tot", snapKey = "totSnap",
        pairs = function(id)
            local spec = ns.TOT_BY_ID[id]
            if not spec then return {} end
            if spec.matchPT then spec = resolvePTSpec() end
            return {
                { "targettarget.style", spec.style or "daylight" },
                { "targettarget.slant", spec.slant == true },
                { "targettarget.shell.own", true },
                { "targettarget.shell.borderPx", spec.border or 2 },
                { "targettarget.shell.cornerPx", spec.corner or 4 },
                { "targettarget.shell.shadowPx", spec.shadow or 4 },
            }
        end,
    },
    party = {
        scope = "UnitFrames", byId = ns.PARTY_BY_ID, storeKey = "party", snapKey = "partySnap",
        pairs = function(id)
            local spec = ns.PARTY_BY_ID[id]
            if not spec then return {} end
            return {
                { "party.slant", spec.slant == true },
                { "party.height", spec.height or 34 },
                { "party.showPower", spec.showPower ~= false },
                { "party.powerHeight", spec.powerHeight or 7 },
                { "party.portrait", spec.portrait or "class" },
                { "party.portraitShape", spec.portraitShape or "round" },
                { "party.portraitLook", spec.portraitLook or "socket" },
                { "party.nameOnBar", spec.nameOnBar == true },
                { "party.bigNumber", spec.bigNumber == true },
                { "party.showPercent", spec.showPercent ~= false },
                { "party.healthText", spec.healthText or "percent" },
                { "party.shell.own", true },
                { "party.shell.borderPx", spec.border },
                { "party.shell.cornerPx", spec.corner },
                { "party.shell.shadowPx", spec.shadow },
                { "party.media.health", spec.texture },
                { "party.media.healthBack", spec.texture },
                { "party.media.power", spec.texture },
                { "party.media.powerBack", spec.texture },
            }
        end,
    },
    raid = {
        scope = "UnitFrames", byId = ns.RAID_BY_ID, storeKey = "raid", snapKey = "raidSnap",
        pairs = function(id)
            local spec = ns.RAID_BY_ID[id]
            if not spec then return {} end
            return {
                { "raid.width", spec.width or 72 },
                { "raid.height", spec.height or 28 },
                { "raid.spacing", spec.spacing or 2 },
                { "raid.slant", spec.slant == true },
                { "raid.showPower", spec.showPower == true },
                { "raid.powerHeight", spec.powerHeight or 3 },
                { "raid.fillVertical", spec.fillVertical == true },
                { "raid.showPercent", spec.showPercent == true },
                { "raid.shell.own", true },
                { "raid.shell.borderPx", spec.border },
                { "raid.shell.cornerPx", spec.corner },
                { "raid.shell.shadowPx", spec.shadow },
                { "raid.media.health", spec.texture },
                { "raid.media.healthBack", spec.texture },
                { "raid.media.power", spec.texture },
                { "raid.media.powerBack", spec.texture },
            }
        end,
    },
    castbars = {
        scope = "UnitFrames", byId = ns.CAST_BY_ID, storeKey = "castbars", snapKey = "castSnap",
        pairs = function(id)
            local spec = ns.CAST_BY_ID[id]
            if not spec then return {} end
            local list = {}
            local casts = { "playerCastbar", "targetCastbar", "focusCastbar", "partyCastbar" }
            for i = 1, #casts do
                local cu = casts[i]
                if cu ~= "partyCastbar" then
                    list[#list + 1] = { cu .. ".height", spec.height or 18 }
                end
                list[#list + 1] = { cu .. ".shell.own", true }
                list[#list + 1] = { cu .. ".shell.borderPx", spec.border or 2 }
                list[#list + 1] = { cu .. ".shell.cornerPx", spec.corner or 4 }
                list[#list + 1] = { cu .. ".shell.shadowPx", spec.shadow or 6 }
                list[#list + 1] = { cu .. ".media.bar", spec.texture }
                list[#list + 1] = { cu .. ".media.barBack", spec.texture }
                list[#list + 1] = { cu .. ".barFx.cast.style", spec.fx }
                if spec.fx ~= "none" then
                    list[#list + 1] = { cu .. ".barFx.cast.speed", 1 }
                    list[#list + 1] = { cu .. ".barFx.cast.strength", 1 }
                    list[#list + 1] = { cu .. ".barFx.cast.colors", "bar" }
                end
            end
            return list
        end,
    },
    actionbars = {
        scope = "ActionBars", byId = ns.BUTTON_BY_ID, storeKey = "actionbars", snapKey = "buttonSnap",
        pairs = function(id)
            local spec = ns.BUTTON_BY_ID[id]
            if not spec then return {} end
            return {
                { "look.shape", spec.shape },
                { "look.borderStyle", spec.borderStyle },
                { "look.border", spec.border },
                { "look.corners", spec.corners },
                { "look.shadow", spec.shadow },
                { "look.zoom", spec.zoom },
            }
        end,
    },
}

local EXTRA_ORDER = { "focus", "tot", "party", "raid", "castbars", "actionbars" }
ns.EXTRA_ORDER = EXTRA_ORDER

-- Generic Live Preview / Apply / Restore for all 6 extra categories.
local previewHandles = {}
local previewIds = {}

local function releaseNoBatch(handles)
    if type(handles) ~= "table" or #handles == 0 then return end
    local d = dui()
    local api = type(d) == "table" and d.API
    if type(api) ~= "table" or type(api.Off) ~= "function" then return end
    for i = #handles, 1, -1 do pcall(api.Off, handles[i]) end
end

local function applyCatNoBatch(host, cat, id)
    local cfg = CATEGORY_CFG[cat]
    if not cfg or not cfg.byId[id] then return end
    local list = cfg.pairs(id)
    local handles = {}
    for i = 1, #list do
        local ok, h = pcall(host.Override, cfg.scope, list[i][1], list[i][2])
        if ok and type(h) == "table" then handles[#handles + 1] = h end
    end
    if #handles > 0 then
        previewHandles[cat] = handles
        previewIds[cat] = id
    end
end

-- Syncs all 6 extra preview categories inside ONE single DaylightUI.Batch call.
function ns.SyncExtrasPreview(wantMap)
    if inCombat() then return end
    wantMap = type(wantMap) == "table" and wantMap or {}
    local needsWork = false
    for i = 1, #EXTRA_ORDER do
        local cat = EXTRA_ORDER[i]
        if previewIds[cat] ~= wantMap[cat] then
            needsWork = true
            break
        end
    end
    if not needsWork then return end
    local host = overrideHost()
    batch(function()
        for i = 1, #EXTRA_ORDER do
            local cat = EXTRA_ORDER[i]
            local want = wantMap[cat]
            if previewIds[cat] ~= want then
                if previewHandles[cat] then
                    releaseNoBatch(previewHandles[cat])
                    previewHandles[cat] = nil
                end
                previewIds[cat] = nil
                if want and host then
                    applyCatNoBatch(host, cat, want)
                end
            end
        end
    end)
end

function ns.RevertExtraPreview(cat)
    if previewHandles[cat] then
        releaseHandles(previewHandles[cat])
        previewHandles[cat] = nil
    end
    previewIds[cat] = nil
end

function ns.BeginExtraPreview(cat, id)
    local cfg = CATEGORY_CFG[cat]
    if inCombat() or not cfg or not cfg.byId[id] then return end
    if previewIds[cat] == id and previewHandles[cat] then return end
    local host = overrideHost()
    if not host then return end
    batch(function()
        if previewHandles[cat] then
            releaseNoBatch(previewHandles[cat])
            previewHandles[cat] = nil
        end
        previewIds[cat] = nil
        applyCatNoBatch(host, cat, id)
    end)
end

function ns.RevertAllExtrasPreview()
    ns.SyncExtrasPreview({})
end

function ns.activeExtra(cat)
    local cfg = CATEGORY_CFG[cat]
    if not cfg then return nil end
    local st = extrasStore()
    local val = st[cfg.storeKey]
    return type(val) == "string" and cfg.byId[val] and val or nil
end

function ns.hasAnyActiveExtra()
    for i = 1, #EXTRA_ORDER do
        if ns.activeExtra(EXTRA_ORDER[i]) ~= nil then return true end
    end
    return false
end

function ns.applyExtra(cat, id)
    local cfg = CATEGORY_CFG[cat]
    if inCombat() or not cfg or not cfg.byId[id] then return false end
    ns.RevertExtraPreview(cat)
    local st = extrasStore()
    local list = cfg.pairs(id)
    if type(st[cfg.snapKey]) ~= "table" then
        local snap = {}
        for i = 1, #list do
            local v, ok = readSetting(cfg.scope, list[i][1])
            if ok and v ~= nil then snap[list[i][1]] = v end
        end
        st[cfg.snapKey] = snap
    end
    if writeSettingList(cfg.scope, list) then
        st[cfg.storeKey] = id
        return true
    end
    return false
end

function ns.restoreExtra(cat)
    local cfg = CATEGORY_CFG[cat]
    if not cfg then return end
    ns.RevertExtraPreview(cat)
    local st = extrasStore()
    if type(st[cfg.snapKey]) == "table" then
        local list = {}
        for k, v in pairs(st[cfg.snapKey]) do list[#list + 1] = { k, v } end
        if #list > 0 then writeSettingList(cfg.scope, list) end
    end
    st[cfg.snapKey] = nil
    st[cfg.storeKey] = nil
end

function ns.restoreAllExtras()
    for i = 1, #EXTRA_ORDER do ns.restoreExtra(EXTRA_ORDER[i]) end
end

-- Backwards-friendly aliases for castbars & actionbars.
ns.BeginBarPreview = function(id) ns.BeginExtraPreview("castbars", id) end
ns.RevertBarPreview = function() ns.RevertExtraPreview("castbars") end
ns.BeginButtonPreview = function(id) ns.BeginExtraPreview("actionbars", id) end
ns.RevertButtonPreview = function() ns.RevertExtraPreview("actionbars") end
ns.activeBarFinish = function() return ns.activeExtra("castbars") end
ns.applyBarFinish = function(id) return ns.applyExtra("castbars", id) end
ns.restoreBarFinish = function() ns.restoreExtra("castbars") end
ns.activeButtonLook = function() return ns.activeExtra("actionbars") end
ns.applyButtonLook = function(id) return ns.applyExtra("actionbars", id) end
ns.restoreButtonLook = function() ns.restoreExtra("actionbars") end

-- User-Saved Presets (up to 4 custom slots storing all 8 UI layers in PalettesAccount).
ns.MAX_USER_PRESETS = 4

function ns.getUserPresets()
    local acc = type(ns.accountTable) == "function" and ns.accountTable() or nil
    if type(acc) ~= "table" then return {} end
    if type(acc.userPresets) ~= "table" then acc.userPresets = {} end
    return acc.userPresets
end

function ns.saveUserPreset(combo)
    if type(combo) ~= "table" then return nil end
    local list = ns.getUserPresets()
    if #list >= ns.MAX_USER_PRESETS then return nil end
    local idx = #list + 1
    local name = (type(combo.name) == "string" and combo.name ~= "") and combo.name or ("My Preset " .. tostring(idx))
    local item = {
        id = "user_" .. tostring(idx) .. "_" .. tostring(math.floor((type(GetTime) == "function" and GetTime() or idx) * 100)),
        name = name,
        palette = combo.palette,
        frame = combo.frame,
        focus = combo.focus,
        tot = combo.tot,
        party = combo.party,
        raid = combo.raid,
        castbars = combo.castbars,
        actionbars = combo.actionbars,
    }
    list[idx] = item
    return item
end

function ns.deleteUserPreset(index)
    local list = ns.getUserPresets()
    if type(index) ~= "number" or index < 1 or index > #list then return false end
    table.remove(list, index)
    return true
end
