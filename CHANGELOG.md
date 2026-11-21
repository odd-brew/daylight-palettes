# Changelog

## [0.1.1] - 2026-11-20

### Changed
- Palettes are account-wide by default, with a per-character option. The "Use this palette on every character" setting is replaced by a "Save for this character only" checkbox, and Accent follows class is saved the same way.
- Unticking "Save for this character only" clears that character's own pick.
- Upgrading from 0.1.0 keeps your look: the first character to log in sets the account palette, and any character with a different palette gets "Save for this character only" ticked automatically.

### Removed
- Accent from setting.

## [0.1.0] - 2026-11-20

First public release.

### Added
- 33 dark palettes for DaylightUI's windows, panels, borders, accent and text, in three groups: Dark (13), Class themes (9) and Realm themes (11).
- Plugins > Palettes page with a swatch and short description for each palette.
- Palette dropdown on DaylightUI's Appearance page, synced with the Plugins page.
- `/palettes` slash command: pick a palette by name, see the current one, or `/palettes off` to restore DaylightUI's colors.
- Accent follows class: a readable shade of your class color as the window accent.
- Accent from: use another palette's accent, limited to accents with enough contrast.
- Use this palette on every character, or keep it per character.
- Restore Daylight colors button.
- While a palette is on, name tabs on unit, party and raid frames, the micro-menu plates (when DaylightUI's micro-menu style is on) and Dark health mode follow it.

### Notes
- Palette changes made in combat apply when combat ends.
- Class, reaction, power, item quality and money colors are never changed.
