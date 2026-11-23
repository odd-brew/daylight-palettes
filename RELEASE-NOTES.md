## Palettes v0.5.0

New frame looks for your Player and Target frames. For Palettes, the DaylightUI plugin for World of Warcraft: Forever.

### Changed
- **Frame looks:** frame styles are now seven Player and Target looks: Flagon, Trestle, Beam, Stream, Ledger, Crest and Slate. Each one is built from DaylightUI's own unit frame settings and sets your Player and Target frame size, border, name, portrait and text. Focus, Party, Raid, Arena and your other frames are never touched.
- **Instant preview:** click a look on the Looks tab and it shows on Player and Target right away. Hit Apply to keep it. Leave the tab, the page or the window and yours comes back. In combat it waits until combat ends.
- **No reload for Looks:** applying a frame look or a glow, Reset Looks, and `/looks` followed by a look or glow name change your frames right away. Presets and Colours still ask you to reload.
- **Flagon extras:** Flagon also sets the bar textures, colours and Flow animation on Player and Target. Pick another look, Reset Looks or Undo to put yours back.
- **Presets** now use the new looks. Crest is on the Looks tab only.
- **Old names still work:** lintel, sill, stamp, signboard and trough still work in `/looks` and in share codes, and switch to the closest new look.
- **Clean restore:** Reset Looks, Restore Daylight and Undo put back the exact Player and Target settings you had before Palettes changed them.

### Fixed
- **Leftover frame style:** a frame style left over from earlier versions is set back to Daylight once, so it no longer sits in your DaylightUI settings.

### Good to know
- Beam's portrait has a slanted outer edge.
- Flagon's Flow bar animation needs DaylightUI's Motion effects turned on. Palettes doesn't turn them on for you.

### Install or update
1. You need DaylightUI installed first.
2. Download **Palettes-v0.5.0.zip** below.
3. Unzip it into `Interface/AddOns`, replacing your old `Palettes` folder.
4. In game, type `/reload`.

Found a bug? [Open an issue](https://github.com/odd-brew/daylight-palettes/issues/new/choose). Full details are in the [README](https://github.com/odd-brew/daylight-palettes#readme).
