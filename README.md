# Palettes (DaylightUI Plugin)

Palettes recolors DaylightUI's windows, panels, borders, accent and text with one of 35 dark palettes, or a Custom palette you mix yourself. It also adds frame looks, glow styles and Presets that set a palette, a frame look and a glow in one click. Your layout doesn't move, and class and combat colors stay exactly as DaylightUI paints them, so fights stay readable.

Made for World of Warcraft: Forever.

## What you get

- **35 dark palettes** in three groups:
  - **Dark (15):** Ember, Tide, Dusk, Ash, Pine, Forgeglow, Nightglass, Vesper, Carmine Night, Gilded, Phosphor, Ink, Sightline, Vanilla, Forever
  - **Class themes (9):** Warrior, Mage, Paladin, Priest, Hunter, Rogue, Shaman, Warlock, Druid
  - **Realm themes (11):** Keepstone, Ironbanner, Sapphire Crown, Crownwall, Deepforge, Starshade, Cogspark, Rustbrand, Gravelight, Plainsong, Junglefire
- **10 Presets:** each one sets a palette, a frame look and a glow together. Change any part and it shows as changed.
- **7 frame looks and 3 glow styles:** Flagon, Trestle, Beam, Stream, Ledger, Crest and Slate set up your Player and Target frames (size, border, name, portrait and text). Wick, Draught and Latch are the glows. A frame look changes only Player and Target; Focus, Party, Raid, Arena and the rest are never touched, and neither is DaylightUI's own frame style menu.
- **Custom:** mix your own colors, or paste a share code. The dark base is kept dark enough that text stays readable, and the accent is yours to choose.
- **Three-color swatches:** each palette row shows background, band and accent.
- **Undo:** one step back to the previous palette, for this session. It is not a return to Daylight's colors, and it greys out after you use it or when nothing has changed yet.
- **Accent follows class:** tints the window accent to a shade of your class color, adjusted just enough to stay readable.
- **Account-wide by default:** one palette for all your characters, or save a different one for a single character.
- **Restore anytime:** `/palettes off` or `/looks off` puts DaylightUI's own colors, Player and Target frame settings and glows back, and clears a Preset. **Restore Daylight** on the Presets tab does the same. **Reset Colours** puts colors back only. **Reset Looks** puts the saved frame settings and glows back only.
- **Daylight profiles:** importing or switching a Daylight profile also brings its palette, Accent follows class, and Custom colors. **Save for this character only** stays your own switch. A profile with no Palettes settings keeps your current look.

Vanilla is dark oak and pewter chrome. Forever is near-black soot with weathered bronze trim. Sightline uses slate blue and amber, chosen with color-blind players in mind.

While a palette is on and Daylight's micro-menu style is on, micro-menu icons follow the palette accent. There is no new Palettes setting for this.

## Requirements

- [DaylightUI](https://www.curseforge.com/wow/addons/daylightui) installed and enabled. Palettes is a plugin and does nothing on its own.

## Install

1. Download `Palettes-v0.5.0.zip` from the [latest release](https://github.com/odd-brew/daylight-palettes/releases/latest).
2. Unzip it into your game's `Interface/AddOns` folder, so you end up with `Interface/AddOns/Palettes`.
3. Start the game, or type `/reload` if it's already running.

## Picking a palette

Palettes starts switched off, so your first login looks exactly like DaylightUI. Pick a palette any of these ways:

- **Plugins page:** open DaylightUI's options and go to **Plugins > Palettes**. Each palette shows a three-color swatch and a one-line description. Click one to use it. **Custom** sits above Dark: click it to apply your last saved colors and open the editor.
- **Appearance page:** DaylightUI's **Appearance** page has a **Palette** dropdown that stays in sync with the Plugins page, including Custom.
- **Slash command:** type `/palettes` followed by a palette name, like `/palettes ember`, `/palettes custom` or `/palettes carmine night`. Type `/palettes` on its own to see which palette is on and the full list of names. `/palettes` does not take a Theme name. `/palettes off` restores DaylightUI's colors, and, when Palettes has changed them, the Player and Target frame settings and glows, and clears a Preset.

### Themes, colours and looks

Plugins > Palettes is one page with three tabs: **Presets**, **Colours** and **Looks**.

- **Presets** lists ten presets. Each one sets a palette, a frame style and a glow. A row shows the frame glyph, the palette's background, band and accent, the name, two pills such as **Ember** and **Beam + Wick**, and the mood. Hearthnight is Ember, Beam and Wick. The others are Harvestide, Tidemark, Old Road, Vigil, Snug, Bellows, Drawwell, Settle and After Hours. Click a row to preview it, then **Apply**, or type `/looks hearthnight`. Chat says **Palettes: Hearthnight is on. Your layout is unchanged.**
- **Colours** is the palette list, with swatches, Accent follows class, Save for this character only, and a Share code row. A row click previews. **Apply** saves it. **Reset Colours** is how you turn colours off from this tab. Appearance > Palette, `/palettes ember`, and `/palettes off` still change colours immediately, then ask you to reload.
- **Looks** lists the seven frame looks (Flagon, Trestle, Beam, Stream, Ledger, Crest and Slate) and three glow styles. Click one to preview it on your Player and Target frames, then **Apply**, or type `/looks beam` or `/looks wick`. The old names `lintel`, `sill`, `stamp`, `signboard` and `trough` still work in `/looks` and in share codes, and mean Beam, Stream, Slate, Beam and Ledger. Crest is on this tab only; no Preset uses it. Flagon also sets the bar textures, colours and Flow animation on Player and Target, and the next look puts yours back. Flow still needs Motion effects, which Palettes does not turn on.

If you change any one part of a preset, its row reads **Hearthnight (changed)**. Picking that preset again clears the mark. `/looks` reports the same mark.

**Apply** on a Preset or on Colours saves the preview and asks **Reload to finish applying your changes?** A frame look or a glow changes your Player and Target frames right away and does not ask for a reload. Game Menu buttons (Options, Log Out, Exit Game) keep their old colours until that reload, or until you hover them, if a direct refresh cannot reach them. **Reload now** reloads the UI. **Later** leaves it.

Each tab has one reset in the tab row: **Restore Daylight** (colours, frame, glows, and the preset), **Reset Colours** (colours only) and **Reset Looks** (the saved frame settings and glows only, with no reload). A colours or looks reset while a preset is on marks that preset **(changed)**. Reset Looks does nothing when Palettes has not saved a look, so frame settings or a glow you set in Daylight's own menus stay put.

On an older DaylightUI that can recolor but cannot take frame and glow styles, only the Colours tab shows and `/looks` says only colors are available.

**Undo** sits in the Plugins > Palettes header. Use it to step back one palette, or to cancel a pick that's still waiting for combat to end.

### Custom colors

The editor has **Hue**, **Saturation** and **Lightness** sliders for **BASE** and **ACCENT**. Base lightness stops at 28, shown as **L\*12 / 28**. Under the base sliders: **Base colors stay dark so text stays readable.** Moving a slider changes only the preview until you **Save**. If the accent is hard to see, **Accent is hard to see on this base.** appears, but Save still works.

If you haven't saved your own colors yet, Custom starts with a dark plum base and gold accent.

A **Share code** row sits in the editor and on the Colours tab. Custom colour codes look like **PAL1-RRGGBB-RRGGBB** (base, then accent). A full code looks like **PAL2-hearthnight-ember-beam-wick**. Codes that name an old frame (lintel, sill, stamp, signboard, trough) still work; Copy only writes the seven current names. Case and a leading # don't matter. **Copy** on the Colours tab writes the current Theme, palette, frame and glow as PAL2, and on the clipboard when the game allows it; the button reads **Copied.** for a moment. **Apply** of a PAL2 code with a Theme name applies it in game. **Apply** of PAL1, or of **PAL2-C-RRGGBB-RRGGBB-frame-glow**, loads the Custom preview only; **Save** is what applies those colours, and a PAL2-C frame and glow, in game. A bad or empty code leaves your draft alone and shows **That isn't a Palettes share code.** A valid colour code shows **Applied. Save to keep it.** If the base is too light, it is darkened and the note reads **Base was darkened so text stays readable.**

- **Back** leaves the editor without saving.
- **Reset to Ember** asks first (**Reset Custom to Ember?**). Confirming copies Ember's colors into the editor; **Save** is what writes them. Custom stays selected.
- **Save** writes your colors and applies them, then asks you to reload. In combat, that apply and the reload prompt wait until combat ends.

Custom follows **Save for this character only**, like every other palette.

## Settings

On **Plugins > Palettes**:

| Setting | What it does |
| --- | --- |
| Accent follows class | Uses a shade of your class color as the window accent. Names, chat and unit frames keep the game's class colors. |
| Save for this character only | Off: this character uses your account palette. On: changes here apply only to this character, including Accent follows class, Custom colors, the frame look, the glow and the Restore snapshot. Unticking it clears this character's own pick and goes back to the account palette. |
| Restore Daylight | On the Presets tab. Puts DaylightUI's own colors, Player and Target frame settings and glows back, and clears the preset. `/palettes off` and `/looks off` do the same. |
| Reset Colours | On the Colours tab. Puts colors back only. The frame look and glows stay. A preset that was on shows as changed. |
| Reset Looks | On the Looks tab. Puts the saved frame settings and glows back only. Colors stay. A preset that was on shows as changed. With no saved look, it changes nothing. |

## Known limits

- **Combat waits.** If you change palettes in combat, the row shows **PENDING** and a note under the list reads **Applies when combat ends.** The change applies when combat ends. **Undo** cancels that waiting pick, so nothing applies.
- **A v0.3.0 export with Palettes off.** Importing that profile does not turn Palettes off; you keep your current look. Exports from 0.3.1 do turn Palettes off when that's what was shared.
- **Some text changes color after a /reload.**
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
- your Palettes and DaylightUI versions, and the palette you were using

## Release

Pushing a `palettes-v*` tag runs `.github/workflows/release.yml`. The Approved OPS Change check runs first. The release job builds `Palettes-v<version>.zip`, with the `Palettes` folder at the top of the zip, and publishes the GitHub release from `RELEASE-NOTES.md`.

That same zip is uploaded to the Palettes project on CurseForge. The project id is `## X-Curse-Project-ID` in `Palettes/Palettes.toc` (`1820278`). The upload refuses a missing or non-numeric id. The token is the `CF_API_KEY` repository secret. There is no Wago upload.

The CurseForge game version is WoW: Forever. `## Interface: 16001` is read as `1.60.1`, the same split the BigWigs packager uses for `-g forever`, and CurseForge's Forever list (version type 88568) must contain that name. A missing match stops the upload.

## License

See [LICENSE](LICENSE).
