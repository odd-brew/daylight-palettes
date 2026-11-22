# Palettes (DaylightUI Plugin)

Palettes recolors DaylightUI's windows, panels, borders, accent and text with one of 35 dark palettes, or a Custom palette you mix yourself. It also adds frame styles, glow styles and Themes that set a palette, frame and glow in one click. Your layout doesn't move, and class and combat colors stay exactly as DaylightUI paints them, so fights stay readable.

Made for World of Warcraft: Forever.

## What you get

- **35 dark palettes** in three groups:
  - **Dark (15):** Ember, Tide, Dusk, Ash, Pine, Forgeglow, Nightglass, Vesper, Carmine Night, Gilded, Phosphor, Ink, Sightline, Vanilla, Forever
  - **Class themes (9):** Warrior, Mage, Paladin, Priest, Hunter, Rogue, Shaman, Warlock, Druid
  - **Realm themes (11):** Keepstone, Ironbanner, Sapphire Crown, Crownwall, Deepforge, Starshade, Cogspark, Rustbrand, Gravelight, Plainsong, Junglefire
- **10 Themes:** each one sets a palette, a frame style and a glow together. Change any part and it shows as changed.
- **7 frame styles and 3 glow styles:** these used to be the Looks add-on and now live in Palettes.
- **Custom:** mix your own colors, or paste a share code. The dark base is kept dark enough that text stays readable, and the accent is yours to choose.
- **Three-color swatches:** each palette row shows background, band and accent.
- **Undo:** one step back to the previous palette, for this session. It is not a return to Daylight's colors, and it greys out after you use it or when nothing has changed yet.
- **Accent follows class:** tints the window accent to a shade of your class color, adjusted just enough to stay readable.
- **Account-wide by default:** one palette for all your characters, or save a different one for a single character.
- **Restore anytime:** `/palettes off` or `/looks off` puts DaylightUI's own colors, frame style and glows back, and clears a Theme. The Themes tab reset does the same. The Colours tab reset puts colors back only. The Looks tab reset puts the saved frame style and glows back only.
- **Daylight profiles:** importing or switching a Daylight profile also brings its palette, Accent follows class, and Custom colors. **Save for this character only** stays your own switch. A profile with no Palettes settings keeps your current look.

Vanilla is dark oak and pewter chrome. Forever is near-black soot with weathered bronze trim. Sightline uses slate blue and amber, chosen with color-blind players in mind.

While a palette is on and Daylight's micro-menu style is on, micro-menu icons follow the palette accent. There is no new Palettes setting for this.

## Requirements

- [DaylightUI](https://www.curseforge.com/wow/addons/daylightui) installed and enabled. Palettes is a plugin and does nothing on its own.

## Install

1. Download `Palettes-v0.4.0.zip` from the [latest release](https://github.com/odd-brew/daylight-palettes/releases/latest).
2. Unzip it into your game's `Interface/AddOns` folder, so you end up with `Interface/AddOns/Palettes`.
3. Start the game, or type `/reload` if it's already running.

## Picking a palette

Palettes starts switched off, so your first login looks exactly like DaylightUI. Pick a palette any of these ways:

- **Plugins page:** open DaylightUI's options and go to **Plugins > Palettes**. Each palette shows a three-color swatch and a one-line description. Click one to use it. **Custom** sits above Dark: click it to apply your last saved colors and open the editor.
- **Appearance page:** DaylightUI's **Appearance** page has a **Palette** dropdown that stays in sync with the Plugins page, including Custom.
- **Slash command:** type `/palettes` followed by a palette name, like `/palettes ember`, `/palettes custom` or `/palettes carmine night`. Type `/palettes` on its own to see which palette is on and the full list of names. `/palettes` does not take a Theme name. `/palettes off` restores DaylightUI's colors, and, when Palettes has changed them, the frame style and glows, and clears a Theme.

### Themes, colours and looks

Plugins > Palettes is one page with three tabs:

- **Themes** lists ten Themes. Each one sets a palette, a frame style and a glow. A row shows the frame glyph, the palette's background, band and accent, the name, a parts line such as **Ember · Lintel · Wick**, and the mood. Hearthnight is Ember, Lintel and Wick. The others are Harvestide, Tidemark, Old Road, Vigil, Snug, Bellows, Drawwell, Settle and After Hours. Click a row, or type `/looks hearthnight`. Chat says **Palettes: Hearthnight is on. Your layout is unchanged.**
- **Colours** is the palette list, with swatches, Accent follows class, Save for this character only, and a Share code row. Picking a palette, including from Appearance > Palette or `/palettes ember`, changes colours only.
- **Looks** lists the seven frame styles and three glow styles. Click one, or type `/looks lintel` or `/looks wick`.

If you change any one part of a Theme, its row reads **Hearthnight (changed)**. Picking that Theme again clears the mark. `/looks` reports the same mark.

Each tab has its own reset at the top: **Restore Daylight** (colours, frame, glows, and the Theme), **Restore colours** (colours only) and **Restore looks** (the saved frame and glows only). A colours or looks reset while a Theme is on marks that Theme **(changed)**. Restore looks does nothing when Palettes has not saved a look, so a frame or glow set in Daylight's own menus stays put.

On an older DaylightUI that can recolor but cannot take frame and glow styles, only the Colours tab shows and `/looks` says only colors are available. If the standalone Looks add-on is also enabled, turn it off. These styles now live in Palettes.

**Undo** sits in the Plugins > Palettes header. Use it to step back one palette, or to cancel a pick that's still waiting for combat to end.

### Custom colors

The editor has **Hue**, **Saturation** and **Lightness** sliders for **BASE** and **ACCENT**. Base lightness stops at 28, shown as **L\*12 / 28**. Under the base sliders: **Base colors stay dark so text stays readable.** Moving a slider changes only the preview until you **Save**. If the accent is hard to see, **Accent is hard to see on this base.** appears, but Save still works.

If you haven't saved your own colors yet, Custom starts with a dark plum base and gold accent.

A **Share code** row sits in the editor and on the Colours tab. Custom colour codes look like **PAL1-RRGGBB-RRGGBB** (base, then accent). A full code looks like **PAL2-hearthnight-ember-lintel-wick**. Case and a leading # don't matter. **Copy** on the Colours tab writes the current Theme, palette, frame and glow as PAL2, and on the clipboard when the game allows it; the button reads **Copied.** for a moment. **Apply** of a PAL2 code with a Theme name applies it in game. **Apply** of PAL1, or of **PAL2-C-RRGGBB-RRGGBB-frame-glow**, loads the Custom preview only; **Save** is what applies those colours, and a PAL2-C frame and glow, in game. A bad or empty code leaves your draft alone and shows **That isn't a Palettes share code.** A valid colour code shows **Applied. Save to keep it.** If the base is too light, it is darkened and the note reads **Base was darkened so text stays readable.**

- **Back** leaves the editor without saving.
- **Reset to Ember** asks first (**Reset Custom to Ember?**). Confirming copies Ember's colors into the editor; **Save** is what writes them. Custom stays selected.
- **Save** writes your colors and applies them. In combat, that apply waits until combat ends.

Custom follows **Save for this character only**, like every other palette.

## Settings

On **Plugins > Palettes**:

| Setting | What it does |
| --- | --- |
| Accent follows class | Uses a shade of your class color as the window accent. Names, chat and unit frames keep the game's class colors. |
| Save for this character only | Off: this character uses your account palette. On: changes here apply only to this character, including Accent follows class, Custom colors, the frame style, the glow and the Restore snapshot. Unticking it clears this character's own pick and goes back to the account palette. |
| Restore Daylight | On the Themes tab. Puts DaylightUI's own colors, frame style and glows back, and clears the Theme. `/palettes off` and `/looks off` do the same. |
| Restore colours | On the Colours tab. Puts colors back only. The frame style and glows stay. A Theme that was on shows as changed. |
| Restore looks | On the Looks tab. Puts the saved frame style and glows back only. Colors stay. A Theme that was on shows as changed. With no saved look, it changes nothing. |

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

## License

See [LICENSE](LICENSE).
