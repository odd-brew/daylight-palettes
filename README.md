# Palettes (DaylightUI Plugin)

Palettes recolors DaylightUI's windows, panels, borders, accent and text with one of 35 dark palettes, or a Custom palette you mix yourself. It also adds **Looks** across seven UI categories (unit frames, cast bars, and action bars) and **Presets** that configure an entire 8-layer setup in one click, with a live **Preview Deck** and multi-tab staging. Your layout doesn't move, and class and combat colors stay exactly as DaylightUI paints them, so fights stay readable.

Made for World of Warcraft: Forever.

## What you get

- **35 dark palettes** in three groups:
  - **Dark (15):** Ember, Tide, Dusk, Ash, Pine, Forgeglow, Nightglass, Vesper, Carmine Night, Gilded, Phosphor, Ink, Sightline, Vanilla, Forever
  - **Class themes (9):** Warrior, Mage, Paladin, Priest, Hunter, Rogue, Shaman, Warlock, Druid
  - **Realm themes (11):** Azeroth, Horde, Alliance, Stormwind, Ironforge, Darnassus, Gnomeregan, Orgrimmar, Undercity, Thunder Bluff, Darkspear
- **6 core Presets + My Presets (4 slots):** Hearthnight, Harvestide, Tidemark, Old Road, Vigil, and Snug each set an 8-layer UI recipe (a colour palette plus all 7 Looks categories). Save up to 4 of your own combinations in **My Presets**.
- **7 Looks categories:** Mix and match styles across **Player & Target** (7), **Focus** (4), **ToT** (4), **Party** (4), **Raid** (4), **Cast Bars** (6), and **Action Bars** (6). Other DaylightUI frames (such as Arena) and DaylightUI's own `UnitFrames` style selector are never overwritten.
- **Live Preview Deck & multi-tab staging:** Preview presets, palettes, and frame/bar looks live—including DaylightUI's real unit frames and an 8-icon Action Bars preview—without touching saved settings. Selections accumulate across **Presets**, **Colours**, and all **Looks** sub-tabs so you can tweak any layer before clicking **Apply Live** or **Apply (Reloads UI)**, or back out cleanly with **Cancel Preview**.
- **Custom palette:** Mix your own base and accent colors with Hue, Saturation, and Lightness sliders. The dark base is capped so text stays readable, and the accent is yours to choose.
- **Three-color swatches:** Each palette card shows background, band, and accent.
- **Undo:** One step back to the previous palette, look, or preset for this session (or cancels a pick waiting for combat to end). It greys out after you use it or when nothing has changed yet.
- **Accent follows class:** Tints the window accent to a shade of your class color, adjusted just enough to stay readable.
- **Account-wide by default:** One setup for all your characters, or save a different one for a single character.
- **Restore anytime:** `/palettes off` or `/looks off` puts DaylightUI's own colors and any look settings Palettes changed back, and clears a Preset. In the UI, **Restore Daylight**, **Reset Colours**, and **Reset Looks** stage a non-destructive preview before applying.
- **Daylight profiles:** Importing or switching a DaylightUI profile also brings its palette, Accent follows class, Custom colors, and looks. **Save for this character only** stays your own switch. A profile with no Palettes settings keeps your current look.

Vanilla is dark oak and pewter chrome. Forever is near-black soot with weathered bronze trim. Sightline uses slate blue and amber, chosen with color-blind players in mind.

While a palette is on and Daylight's micro-menu style is on, micro-menu icons follow the palette accent. There is no new Palettes setting for this.

## Requirements

- [DaylightUI](https://www.curseforge.com/wow/addons/daylightui) installed and enabled. Palettes is a plugin and does nothing on its own.

## Install

1. Install from CurseForge, or download the latest release zip (for example, `Palettes-v0.7.1.zip`) from the [latest GitHub release](https://github.com/odd-brew/daylight-palettes/releases/latest).
2. Unzip it into your game's `Interface/AddOns` folder, so you end up with `Interface/AddOns/Palettes`.
3. Start the game, or type `/reload` if it's already running.

## Picking a palette

Palettes starts switched off, so your first login looks exactly like DaylightUI. Pick a palette any of these ways:

- **Plugins page:** Open DaylightUI's options and go to **Plugins > Palettes**. All three tabs share a live **Preview Deck** at the top. On **Colours**, filter by **Dark (15)**, **Class themes (9)**, or **Realm themes (11)**, hover any swatch card to see its description, and click to preview it live across DaylightUI. Click **Custom Palette** to open the custom color editor.
- **Appearance page:** DaylightUI's **Appearance** page has a **Colours** dropdown that stays in sync with the Plugins page, including Custom.
- **Slash command:** Type `/palettes` followed by a palette name, like `/palettes ember`, `/palettes custom` or `/palettes carmine night`. Type `/palettes` on its own to see which palette is on and the full list of names. `/palettes` does not take a Preset name. `/palettes off` restores DaylightUI's colors and any look settings Palettes changed, and clears a Preset.

### Presets, colours, and looks

**Plugins > Palettes** is one page with a live **Preview Deck** and three tabs: **Presets**, **Colours**, and **Looks**.

- **Presets** shows 6 curated full-UI recipes in a 3×2 grid:
  - **Hearthnight** — Ember + Beam, Compact Beam, Compact Pill, Framed Classic, Sculpted Plates, Molten Ember, Daylight Classic
  - **Harvestide** — Vanilla + Stream, Slim Ribbon, Compact Pill, Daylight Standard, Daylight Tiles, Silk Sheen, Daylight Classic
  - **Tidemark** — Tide + Slate, Minimal Slate, Slim Bar, Clean Compact, Tight Raid Grid, Tidal Glass, Crisp Flat
  - **Old Road** — Forever + Crest, Compact Beam, Crisp Square, Framed Classic, Sculpted Plates, Brushed Metal, Heavy Rim
  - **Vigil** — Paladin + Stream, Slim Ribbon, Compact Pill, Healer Grid, Vertical Healer, Silk Sheen, Rounded Medallion
  - **Snug** — Gilded + Flagon, Match Player & Target, Compact Pill, Daylight Standard, Daylight Tiles, Living Flow, Rounded Medallion

  Below the grid sit the 8-layer **Preset Recipe** card (click any layer to jump straight to that tab and tweak it) and **My Presets** (4 custom slots in a 2×2 grid—click **Save to My Presets** to save your current setup, click a slot to preview/load it, or click `x` to delete it). You can also apply a core preset by slash command, such as `/looks hearthnight`. Chat says **Palettes: Hearthnight is on. Your layout is unchanged.**
- **Colours** shows the category filter pills (**Dark (15)**, **Class themes (9)**, **Realm themes (11)**, defaulting to Dark), the **Custom Palette** button, a 3-column swatch grid with hover descriptions, **Accent follows class**, and **Save for this character only**. Clicking a palette previews its colours live immediately; **Apply (Reloads UI)** saves it. Appearance > Colours, `/palettes ember`, and `/palettes off` still change colours immediately and then ask you to reload.
- **Looks** has 7 single-row sub-tabs bidirectionally synced with the **Preview Deck**:
  - **Player & Target (7):** Flagon, Trestle, Beam, Stream, Ledger, Crest, Slate
  - **Focus (4):** Match Player & Target, Compact Beam, Slim Ribbon, Minimal Slate
  - **ToT (4):** Match Player & Target, Compact Pill, Slim Bar, Crisp Square
  - **Party (4):** Daylight Standard, Clean Compact, Healer Grid, Framed Classic
  - **Raid (4):** Daylight Tiles, Tight Raid Grid, Vertical Healer, Sculpted Plates
  - **Cast Bars (6):** Clean Matte, Silk Sheen, Brushed Metal, Living Flow, Tidal Glass, Molten Ember
  - **Action Bars (6):** Daylight Classic, Crisp Flat, Borderless Zoom, Heavy Rim, Rounded Medallion, Shield Crest

  Focus and ToT include a **Match Player & Target** option with a dynamic `Currently: [Look]` label. You can also apply a Player & Target look by slash command, such as `/looks beam`. The legacy names `lintel`, `sill`, `stamp`, `signboard`, and `trough` still work in `/looks` and map to Beam, Stream, Slate, Beam, and Ledger. Flagon also sets bar textures, colours, and Flow animation on Player and Target (and choosing another look puts yours back). Animated bar FX (such as Flagon's Flow, Living Flow, Tidal Glass, and Molten Ember) require DaylightUI's **Motion effects**, which Palettes does not turn on for you.

If you change any part of an active preset, it shows as **Hearthnight (changed)** (and `/looks` reports the same). Picking that preset again clears the mark.

### Multi-tab staging & applying changes

Clicking a preset, palette, or look previews it immediately without overwriting your saved settings, and your picks accumulate across **Presets**, **Colours**, and all **Looks** sub-tabs. While a preview is active, the footer bar shows `Previewing: ... — Unsaved` alongside:

- **Cancel Preview** — discards the staged preview and reverts to your saved settings (pressing Escape or switching to another DaylightUI page does the same).
- **Apply Live** — shown when only Looks changed; applies your unit frame, cast bar, and action bar looks right away without needing a reload.
- **Apply (Reloads UI)** — shown when colours, a Preset, or a colour/full reset are included; saves your changes and asks **Reload to finish applying your changes?** (**Reload now** reloads the UI; **Later** leaves it). Game Menu buttons (Options, Log Out, Exit Game) keep their old colours until that reload, or until you hover them, if a direct refresh cannot reach them.

Each tab has one reset button in the tab row: **Restore Daylight** (Presets), **Reset Colours** (Colours), and **Reset Looks** (Looks). Clicking a reset stages a non-destructive preview first so you can inspect the result before clicking Apply. A colours or looks reset while a preset is active marks that preset **(changed)**. **Reset Looks** does nothing when Palettes has not saved a look, so frame and bar settings you configured in DaylightUI's own menus stay put.

On an older DaylightUI that can recolor but cannot take frame looks, only the Colours tab shows and `/looks` says only colors are available.

**Undo** sits in the **Plugins > Palettes** header. Use it to step back one change in the current session, or to cancel a pick that's still waiting for combat to end.

### Custom colors

Click **Custom Palette** on the **Colours** tab to open the editor. It has **Hue**, **Saturation**, and **Lightness** sliders for **BASE** and **ACCENT**. Base lightness stops at CIE L\* 28, shown as **L\*12 / 28**, with the note **Base colors stay dark so text stays readable.** Moving a slider updates only the preview until you **Save**. If the accent is hard to see, **Accent is hard to see on this base.** appears, though Save still works.

If you haven't saved your own colors yet, Custom starts with a dark plum base and gold accent.

- **Back** leaves the editor without saving.
- **Reset to Ember** asks first (**Reset Custom to Ember?**). Confirming copies Ember's colors into the editor; **Save** is what writes them. Custom stays selected.
- **Save** writes your colors and applies them, then asks you to reload. In combat, that apply and the reload prompt wait until combat ends.

Custom follows **Save for this character only**, like every other palette, and travels automatically when you share or switch DaylightUI profiles.

## Settings

On **Plugins > Palettes**:

| Setting | What it does |
| --- | --- |
| Accent follows class | Uses a shade of your class color as the window accent. Names, chat and unit frames keep the game's class colors. |
| Save for this character only | Off: this character uses your account setup. On: changes here apply only to this character, including Accent follows class, Custom colors, Looks, My Presets, and the Restore snapshot. Unticking it clears this character's own pick and goes back to the account setup. |
| Restore Daylight | On the Presets tab. Stages a full restore of DaylightUI's own colors and any look settings Palettes changed, and clears the preset. `/palettes off` and `/looks off` run the full restore directly. |
| Reset Colours | On the Colours tab. Stages resetting colors back to DaylightUI only. Your Looks stay. A preset that was on shows as changed. |
| Reset Looks | On the Looks tab. Stages resetting the saved frame and bar look settings back to DaylightUI only (applies live with no reload). Colors stay. A preset that was on shows as changed. With no saved look, it changes nothing. |

## Known limits

- **Combat waits.** If you change palettes or looks in combat, the card shows **PENDING** and a note reads **Applies when combat ends.** The change applies when combat ends. **Undo** cancels that waiting pick, so nothing applies.
- **A v0.3.0 export with Palettes off.** Importing that profile does not turn Palettes off; you keep your current look. Exports from 0.3.1+ do turn Palettes off when that's what was shared.
- **Some text changes color after a `/reload`.**
- **Editing DaylightUI's Accent or Window tint switches the palette off.** Palettes steps aside so your own colors win. Pick a palette again to bring it back.
- **Some things never change color:** class, reaction, power, item quality and money colors, plus tooltips and chat. That's on purpose.
- **Needs a recent DaylightUI.** If your DaylightUI is too old, Palettes prints a chat line and leaves your colors alone.
- **Partial support on some DaylightUI versions.** If a DaylightUI update changes a window Palettes doesn't know, Palettes skips that piece and says so in chat once.
- **It's an early version.** Expect rough edges.

## Found a bug?

[Open an issue](https://github.com/odd-brew/daylight-palettes/issues/new/choose) and include:

- what you did
- what you expected
- what happened instead (a screenshot or the error text helps a lot)
- your Palettes and DaylightUI versions, and the palette/preset you were using

## Development & Release

### Checks

Pull requests and pushes run `.github/workflows/checks.yml`:

- Lua 5.1 syntax check (`luac5.1 -p`) on all files in `Palettes/`
- Automated suite (`lua5.1 tools/palettes_check.lua`)
- Secret scan (`bash tools/secret_scan.sh`)

### Test builds

Pushing to any non-`main` branch (or triggering `.github/workflows/test-build.yml` manually) builds `PalettesTest.zip` and updates the rolling `palettes-test` GitHub pre-release. **Palettes (Test)** uses isolated SavedVariables (`PalettesTestAccount` / `PalettesTestChar`), an isolated DaylightUI page (`Pal Test`), and no CurseForge project ID so it can be installed side-by-side with live Palettes. On Windows, `tools/install-palettes-test.bat` downloads and installs the latest `PalettesTest.zip` into your WoW `Interface/AddOns` folder.

### Release

Pushing a `palettes-v*` tag runs `.github/workflows/release.yml`. The **Approved Release Issue** check runs first and requires an open GitHub issue in this repository labeled both `release` and `approved` whose title or body contains the exact tag (for example `palettes-v0.7.2`). The release job builds `Palettes-v<version>.zip` with the `Palettes` folder at the top of the zip, publishes the GitHub release from `RELEASE-NOTES.md`, uploads it to CurseForge, and closes the release issue.

That same zip is uploaded to the Palettes project on CurseForge. The project id is `## X-Curse-Project-ID` in `Palettes/Palettes.toc` (`1820278`). The upload refuses a missing or non-numeric id. The token is the `CF_API_KEY` repository secret. There is no Wago upload.

The CurseForge game version is WoW: Forever. `## Interface: 16001` is read as `1.60.1`, the same split the BigWigs packager uses for `-g forever`, and CurseForge's Forever list (version type 88568) must contain that name. A missing match stops the upload.

## License

See [LICENSE](LICENSE).
