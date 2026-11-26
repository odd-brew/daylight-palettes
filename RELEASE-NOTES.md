## Palettes v0.5.4

Removes glow styles from Palettes now that DaylightUI's Neon plugin covers them. For Palettes, the DaylightUI plugin for World of Warcraft: Forever.

### Removed
- **Glow styles:** Removed `Wick`, `Draught`, and `Latch` from the Looks tab, Presets, and `/looks`. The Looks tab now shows only **Frame looks** and **Reset Looks**.
- **No glow writes:** Palettes no longer writes button glow or `Nameplates.targetLight` settings, leaving your existing DaylightUI / Neon glow settings untouched. Old glow saved variables are dropped automatically on `/reload`.
- **Legacy restore preserved:** **Reset Looks** and **Restore Daylight** still restore pre-Palettes glow values if you applied a Palettes glow before updating.
- **Share codes:** `PAL2` codes now omit the glow suffix (older `PAL2` codes with a glow suffix still import cleanly).

### Install or update
1. You need DaylightUI installed first.
2. Download **Palettes-v0.5.4.zip** below.
3. Unzip it into `Interface/AddOns`, replacing your old `Palettes` folder.
4. In game, type `/reload`.

Found a bug? [Open an issue](https://github.com/odd-brew/daylight-palettes/issues/new/choose). Full details are in the [README](https://github.com/odd-brew/daylight-palettes#readme).
