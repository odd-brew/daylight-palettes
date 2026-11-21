# Changelog

## [0.3.0] - 2026-11-21

### Added
- Vanilla and Forever in the Dark group, after Sightline. Vanilla is "Dark oak and pewter chrome." Forever is "Near-black soot, weathered bronze trim."
- Share codes in the Custom editor, in the form PAL1-RRGGBB-RRGGBB (base, then accent). The Share code row has Copy and Apply. Copy puts the draft in the field, and on the clipboard when the game allows it; the button reads "Copied." for a moment. Apply loads the preview only; Save is what applies it in game. A bad or empty code leaves the draft alone and shows "That isn't a Palettes share code." A valid code shows "Applied. Save to keep it." If the base is too light, it is darkened and the note reads "Base was darkened so text stays readable."
- While a palette is on and Daylight's micro-menu style is on, micro-menu icons follow the palette accent. There is no new Palettes setting. Palette off, Restore Daylight colors, or the style switch off puts the player's own icon color back.

### Changed
- Crownwall, Rogue, Gilded, Warrior, Deepforge and Gravelight were retuned. Crownwall's description is now "Pale castle stone, banner blue."

## [0.2.0] - 2026-11-21

### Added
- Each palette row shows a three-color swatch: background, band and accent.
- Undo in the Plugins > Palettes header. One step back to the previous palette, for this session only. It greys out after you use it, and when nothing has changed yet. There is no Redo.
- A pick made in combat marks the row PENDING and shows "Applies when combat ends." under the list. Undo cancels that waiting pick.
- A Custom palette above Dark, described as "Your own colors." Click it to apply your last saved colors and open the editor. Hue, Saturation and Lightness sliders for the base and the accent; the base stays dark so text stays readable. Back leaves without saving. Reset to Ember asks first, then copies Ember's colors into the editor. Save writes the colors. Custom follows "Save for this character only."

### Notes
- Moving a Custom slider changes only the preview until you Save. If the accent is hard to see, "Accent is hard to see on this base." appears, but Save still works.
- Some text changes color after a /reload.

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
