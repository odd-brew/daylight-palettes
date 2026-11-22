# Changelog

## [Unreleased]

### Added
- Frame styles and glow styles from Looks now live in Palettes. The seven frames are Lintel, Sill, Stamp, Trestle, Flagon, Signboard and Trough. The three glows are Wick, Draught and Latch. The saved keys stay `Looks:lintel`, `Looks:wick` and so on.
- Ten Themes, separate from the colour palettes: Hearthnight, Harvestide, Tidemark, Old Road, Vigil, Snug, Bellows, Drawwell, Settle and After Hours. A Theme sets a palette, a frame style and a glow. Pick one on Plugins > Palettes > Themes, or with `/looks hearthnight`. `/palettes` still takes palette names only.
- Plugins > Palettes is one page with three tabs: Themes, Colours and Looks. Each tab's first row is its reset. Restore Daylight puts colours, the frame style and the glows back and clears the Theme. Restore colours puts colours back only. Restore looks puts the saved frame style and glows back only, and leaves a look set in Daylight's own menus alone when Palettes has no snapshot. On an older Daylight that cannot take frame and glow styles, only the Colours tab shows.
- Share codes are versioned. PAL2 carries the Theme name when one is on, plus the palette, frame and glow, for example `PAL2-hearthnight-ember-lintel-wick`. Copy and Apply sit on the Colours tab. PAL1 and `PAL2-C` still load Custom colours; a `PAL2-C` frame and glow apply when you Save. A bad code shows "That isn't a Palettes share code."

- On Daylight plugin API 1.7 or 1.8, colors still work and Themes, frames and glows stay hidden. The plugin still needs API 1.7.
- If the standalone Looks add-on is also loaded, Palettes keeps colors, does not register those styles again, and asks you to turn Looks off.

### Changed
- Changing one part of a Theme (a palette, a frame, a glow, or Custom colours) keeps the Theme name and shows it as "Hearthnight (changed)". Picking that Theme again, or applying a code that matches it exactly, clears the mark. If the current palette, frame and glow already match a Theme, that Theme shows as on.
- Restore Daylight, `/palettes off` and `/looks off` put Daylight's colors, frame style and glows back, and clear the Theme. With no saved look they leave the frame and glows alone. A pick made in combat waits until combat ends. Restore colours and Restore looks each put back only their own part, and mark a Theme changed when one was on. Restore looks with no snapshot changes nothing.
- The Theme, the frame, the glow and the Restore snapshot follow Save for this character only, and travel with a Daylight profile the same way a palette does. A profile with no Theme, frame or glow keys leaves those alone.
- The add-on notes and the in-game blurb now cover colors, frame styles and glow styles. Class and combat colors stay Daylight's.

## [0.3.1] - 2026-11-21

### Added
- Palettes follows a shared or switched Daylight profile. On import or switch, it uses that profile's palette, Accent follows class, and Custom colors. Save for this character only stays your own switch. A profile with no Palettes settings keeps your current look. Existing users keep their palette and Custom colors.
- If the profile used a palette this version doesn't have, Ember is used and chat shows: "Palettes: That profile's palette isn't in this version, so Ember is on instead. Your layout is unchanged."
- If the profile's Custom base is too light, it is darkened and chat shows: "Palettes: Custom base was darkened so text stays readable."

### Notes
- A v0.3.0 export with Palettes off does not turn Palettes off on import; you keep your current look. Exports from 0.3.1 do turn Palettes off when that's what was shared.

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
