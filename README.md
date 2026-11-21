# Palettes (DaylightUI Plugin)

Palettes recolors DaylightUI's windows, panels, borders, accent and text with one of 33 dark palettes. Your layout doesn't move, and class and combat colors stay exactly as DaylightUI paints them, so fights stay readable.

Made for World of Warcraft: Forever.

## What you get

- **33 dark palettes** in three groups:
  - **Dark (13):** Ember, Tide, Dusk, Ash, Pine, Forgeglow, Nightglass, Vesper, Carmine Night, Gilded, Phosphor, Ink, Sightline
  - **Class themes (9):** Warrior, Mage, Paladin, Priest, Hunter, Rogue, Shaman, Warlock, Druid
  - **Realm themes (11):** Keepstone, Ironbanner, Sapphire Crown, Crownwall, Deepforge, Starshade, Cogspark, Rustbrand, Gravelight, Plainsong, Junglefire
- **Accent follows class:** tints the window accent to a shade of your class color, adjusted just enough to stay readable.
- **Account-wide by default:** one palette for all your characters, or save a different one for a single character.
- **Restore anytime:** one button, or `/palettes off`, puts DaylightUI's own colors back.

Sightline uses slate blue and amber, chosen with color-blind players in mind.

## Requirements

- [DaylightUI](https://www.curseforge.com/wow/addons/daylightui) installed and enabled. Palettes is a plugin and does nothing on its own.

## Install

1. Download `Palettes-v0.1.1.zip` from the [latest release](https://github.com/odd-brew/daylight-palettes/releases/latest).
2. Unzip it into your game's `Interface/AddOns` folder, so you end up with `Interface/AddOns/Palettes`.
3. Start the game, or type `/reload` if it's already running.

## Picking a palette

Palettes starts switched off, so your first login looks exactly like DaylightUI. Pick a palette any of these ways:

- **Plugins page:** open DaylightUI's options and go to **Plugins > Palettes**. Each palette shows a swatch and a one-line description. Click one to use it.
- **Appearance page:** DaylightUI's **Appearance** page has a **Palette** dropdown that stays in sync with the Plugins page.
- **Slash command:** type `/palettes` followed by a palette name, like `/palettes ember` or `/palettes carmine night`. Type `/palettes` on its own to see which palette is on and the full list of names. `/palettes off` restores DaylightUI's colors.

## Settings

On **Plugins > Palettes**:

| Setting | What it does |
| --- | --- |
| Accent follows class | Uses a shade of your class color as the window accent. Names, chat and unit frames keep the game's class colors. |
| Save for this character only | Off: this character uses your account palette. On: changes here apply only to this character, including Accent follows class. Unticking it clears this character's own pick and goes back to the account palette. |
| Restore Daylight colors | Switches off whichever palette is active, account or character, and puts DaylightUI's own colors back. |

## Known limits

- **Combat waits.** If you change palettes in combat, the change is queued and applies when combat ends.
- **Editing DaylightUI's Accent or Window tint switches the palette off.** Palettes steps aside so your own colors win. Pick a palette again to bring it back.
- **Some things never change color:** class, reaction, power, item quality and money colors, plus game text. That's on purpose.
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
