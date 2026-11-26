-- Curated Bar Finishes, Action Bar Button Looks, and User-Saved Presets.
-- Everything previews via DaylightUI's temporary Override handles and snapshots
-- the player's prior values before writing so Reset Looks / Restore Daylight
-- always puts their own settings back untouched.
local _, ns = ...

local BAR_FINISHES = {
    {
        id = "matte", name = "Clean Matte",
        desc = "Smooth Daylight bars with zero fill animation.",
        texture = "daylight", fx = "none",
    },
    {
        id = "silk", name = "Silk Sheen",
        desc = "Soft woven silk texture for a refined, calm bar.",
        texture = "silk", fx = "none",
    },
    {
        id = "brushed", name = "Brushed Metal",
        desc = "Fine horizontal brushed grain with subtle depth.",
        texture = "brushed", fx = "none",
    },
    {
        id = "flow", name = "Living Flow",
        desc = "Gentle liquid motion across health and cast bars.",
        texture = "daylight", fx = "flow",
    },
    {
        id = "tide", name = "Tidal Glass",
        desc = "Polished glass bar with a slow rising tide shimmer.",
        texture = "glass", fx = "tide",
    },
    {
        id = "molten", name = "Molten Ember",
        desc = "Textured grain lit by a warm glowing ember pulse.",
        texture = "grain", fx = "molten",
    },
}

local BUTTON_LOOKS = {
    {
        id = "classic", name = "Daylight Classic",
        desc = "Warm Daylight rim with soft rounded corners and shadow.",
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
        desc = "Bold 4px framed square buttons with strong presence.",
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

local BAR_BY_ID, BUTTON_BY_ID = {}, {}
for i = 1, #BAR_FINISHES do BAR_BY_ID[BAR_FINISHES[i].id] = BAR_FINISHES[i] end
for i = 1, #BUTTON_LOOKS do BUTTON_BY_ID[BUTTON_LOOKS[i].id] = BUTTON_LOOKS[i] end

ns.BAR_FINISHES = BAR_FINISHES
ns.BAR_BY_ID = BAR_BY_ID
ns.BUTTON_LOOKS = BUTTON_LOOKS
ns.BUTTON_BY_ID = BUTTON_BY_ID

-- Preset pairings: gives each curated Preset a matching Bar Finish + Button Look.
ns.PRESET_EXTRAS = {
    hearthnight = { bar = "molten",  button = "classic" },
    harvestide  = { bar = "silk",    button = "classic" },
    tidemark    = { bar = "tide",    button = "flat" },
    oldroad     = { bar = "brushed", button = "heavy" },
    vigil       = { bar = "silk",    button = "circle" },
    snug        = { bar = "flow",    button = "circle" },
    bellows     = { bar = "brushed", button = "heavy" },
    drawwell    = { bar = "matte",   button = "flat" },
    settle      = { bar = "matte",   button = "shield" },
    afterhours  = { bar = "tide",    button = "borderless" },
}

local function dui()
    return type(DaylightUI) == "table" and DaylightUI or nil
end

local function inCombat()
    return type(InCombatLockdown) == "function" and InCombatLockdown() == true
end

local function batch(fn)
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

-- Bar Finish pairs (UnitFrames scope).
local function barPairs(id)
    local spec = BAR_BY_ID[id]
    if not spec then return {} end
    local units = { "player", "target" }
    if select(1, readSetting("Palettes", "scopeFocus")) == true then
        units[#units + 1] = "focus"
        units[#units + 1] = "targettarget"
    end
    local includeGroup = select(1, readSetting("Palettes", "scopeGroup")) == true
    if includeGroup then
        units[#units + 1] = "party"
        units[#units + 1] = "raid"
    end
    local list = {}
    for i = 1, #units do
        local u = units[i]
        list[#list + 1] = { u .. ".media.health", spec.texture }
        list[#list + 1] = { u .. ".media.healthBack", spec.texture }
        list[#list + 1] = { u .. ".media.power", spec.texture }
        list[#list + 1] = { u .. ".media.powerBack", spec.texture }
        list[#list + 1] = { u .. ".barFx.health.style", spec.fx }
        if spec.fx ~= "none" then
            list[#list + 1] = { u .. ".barFx.health.speed", 1 }
            list[#list + 1] = { u .. ".barFx.health.strength", 1 }
            list[#list + 1] = { u .. ".barFx.health.colors", "bar" }
        end
    end
    -- Cast bars follow the same BarFx motion.
    local castUnits = { "playerCastbar", "targetCastbar" }
    if includeGroup then castUnits[#castUnits + 1] = "partyCastbar" end
    for i = 1, #castUnits do
        local cu = castUnits[i]
        list[#list + 1] = { cu .. ".barFx.cast.style", spec.fx }
    end
    return list
end

-- Button Look pairs (ActionBars scope).
local function buttonPairs(id)
    local spec = BUTTON_BY_ID[id]
    if not spec then return {} end
    return {
        { "look.shape", spec.shape },
        { "look.borderStyle", spec.borderStyle },
        { "look.border", spec.border },
        { "look.corners", spec.corners },
        { "look.shadow", spec.shadow },
        { "look.zoom", spec.zoom },
    }
end

-- Live Preview handles (never saved until Apply).
local barPreviewHandles, barPreviewId = nil, nil
local btnPreviewHandles, btnPreviewId = nil, nil

function ns.RevertBarPreview()
    if barPreviewHandles then
        releaseHandles(barPreviewHandles)
        barPreviewHandles = nil
    end
    barPreviewId = nil
end

function ns.BeginBarPreview(id)
    if inCombat() or not BAR_BY_ID[id] then return end
    if barPreviewId == id and barPreviewHandles then return end
    ns.RevertBarPreview()
    local host = overrideHost()
    if not host then return end
    local list = barPairs(id)
    local handles = {}
    batch(function()
        for i = 1, #list do
            local ok, h = pcall(host.Override, "UnitFrames", list[i][1], list[i][2])
            if ok and type(h) == "table" then handles[#handles + 1] = h end
        end
    end)
    if #handles > 0 then
        barPreviewHandles = handles
        barPreviewId = id
    end
end

function ns.RevertButtonPreview()
    if btnPreviewHandles then
        releaseHandles(btnPreviewHandles)
        btnPreviewHandles = nil
    end
    btnPreviewId = nil
end

function ns.BeginButtonPreview(id)
    if inCombat() or not BUTTON_BY_ID[id] then return end
    if btnPreviewId == id and btnPreviewHandles then return end
    ns.RevertButtonPreview()
    local host = overrideHost()
    if not host then return end
    local list = buttonPairs(id)
    local handles = {}
    batch(function()
        for i = 1, #list do
            local ok, h = pcall(host.Override, "ActionBars", list[i][1], list[i][2])
            if ok and type(h) == "table" then handles[#handles + 1] = h end
        end
    end)
    if #handles > 0 then
        btnPreviewHandles = handles
        btnPreviewId = id
    end
end

function ns.RevertAllExtrasPreview()
    ns.RevertBarPreview()
    ns.RevertButtonPreview()
end

-- Snapshot + Apply + Restore for Bar Finishes.
function ns.activeBarFinish()
    local st = extrasStore()
    return type(st.bar) == "string" and BAR_BY_ID[st.bar] and st.bar or nil
end

function ns.applyBarFinish(id)
    if inCombat() or not BAR_BY_ID[id] then return false end
    ns.RevertBarPreview()
    local st = extrasStore()
    local list = barPairs(id)
    if type(st.barSnap) ~= "table" then
        local snap = {}
        for i = 1, #list do
            local v, ok = readSetting("UnitFrames", list[i][1])
            if ok and v ~= nil then snap[list[i][1]] = v end
        end
        st.barSnap = snap
    end
    if writeSettingList("UnitFrames", list) then
        st.bar = id
        return true
    end
    return false
end

function ns.restoreBarFinish()
    ns.RevertBarPreview()
    local st = extrasStore()
    if type(st.barSnap) == "table" then
        local list = {}
        for k, v in pairs(st.barSnap) do list[#list + 1] = { k, v } end
        if #list > 0 then writeSettingList("UnitFrames", list) end
    end
    st.barSnap = nil
    st.bar = nil
end

-- Snapshot + Apply + Restore for Button Looks.
function ns.activeButtonLook()
    local st = extrasStore()
    return type(st.button) == "string" and BUTTON_BY_ID[st.button] and st.button or nil
end

function ns.applyButtonLook(id)
    if inCombat() or not BUTTON_BY_ID[id] then return false end
    ns.RevertButtonPreview()
    local st = extrasStore()
    local list = buttonPairs(id)
    if type(st.buttonSnap) ~= "table" then
        local snap = {}
        for i = 1, #list do
            local v, ok = readSetting("ActionBars", list[i][1])
            if ok and v ~= nil then snap[list[i][1]] = v end
        end
        st.buttonSnap = snap
    end
    if writeSettingList("ActionBars", list) then
        st.button = id
        return true
    end
    return false
end

function ns.restoreButtonLook()
    ns.RevertButtonPreview()
    local st = extrasStore()
    if type(st.buttonSnap) == "table" then
        local list = {}
        for k, v in pairs(st.buttonSnap) do list[#list + 1] = { k, v } end
        if #list > 0 then writeSettingList("ActionBars", list) end
    end
    st.buttonSnap = nil
    st.button = nil
end

-- User-Saved Presets (up to 4 custom slots saved in PalettesAccount).
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
        bar = combo.bar,
        button = combo.button,
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
