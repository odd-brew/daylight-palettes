## Palettes v0.9.0

A major content expansion adding **10 new dark colour palettes** (45 total), **12 new Looks across all 8 categories** (58 total), and **4 new 9-layer Core Presets** (10 total in a compact 5×2 grid).

### Added
- **+10 Colour Palettes (35 → 45 Total):**
  - **Dark (+5 → 20):** **Verdier** (`verdigris`), **Abyssal** (`abyssal`), **Cinderclay** (`cinderclay`), **Lichen** (`lichen`), and **Twilight** (`twilight`).
  - **Realm (+5 → 16):** **Dalaran** (`kirintor`), **Silvermoon** (`sunspire`), **Blackrock** (`blackrock`), **Stranglethorn** (`stranglethorn`), and **Winterspring** (`winterspring`).
  - All 10 palettes use dark base surfaces (`L* <= 28`), pass all WCAG contrast floors, preserve combat-color immunity, and include precomputed class chrome shades.
- **+12 Looks Across All 8 Categories (46 → 58 Total):**
  - **Player/Target (8 → 10, 5×2):** **Anvil** (`anvil`) and **Channel** (`channel`, with gentle tide health FX and clean snapshot restore).
  - **Focus (5 → 6, 3×2):** **Watch Plate** (`watch_plate`).
  - **ToT (5 → 6, 3×2):** **Angled Chip** (`angled_chip`).
  - **Party (4 → 6, 3×2):** **Squad Ribbon** (`squad_ribbon`) and **Ward Stack** (`ward_stack`).
  - **Raid (5 → 6, 3×2):** **Triage Cells** (`triage_cells`).
  - **Cast Bars (7 → 9, 3×3):** **Arcane Comet** (`arcane_comet`) and **Interrupt Flare** (`interrupt_flare`), with `partyCastbar` height safely clamped `<= 14px`.
  - **Action Bars (7 → 9, 3×3):** **Hex Cell** (`hex_cell`) and **Chamfered Octagon** (`chamfer_oct`) with live hexagonal/octagonal masks in the Preview Deck.
  - **Nameplates (5 → 6, 3×2):** **Angled Blade** (`angled_blade`).
- **+4 Core Presets & Compact 5×2 Grid (6 → 10 Total):** Added **Bastion Line** (`bastionline`), **Dalaran Arcanum** (`arcanum`), **Verdant Canopy** (`canopy`), and **Blackrock Ledger** (`blackrockledger`), arranged in a compact 5×2 grid so the **Preset Recipe** and **My Presets** cards remain cleanly in frame.
- **Expanded Slash Commands:** `/palettes` and `/looks` now resolve all new palette, look, and preset IDs and display names (including multi-word names) and respect combat lockdown queuing.

### Fixed
- **Staged preset overrides:** Selecting an already-applied palette, frame, or extra look (such as ToT **Slim Bar** or Cast Bars **Brushed Metal**) while a preset with a different recipe value is staged now highlights, previews, and applies your override instead of falling back to the preset's recipe.

### Install or update
1. You need DaylightUI installed first.
2. Download **Palettes-v0.9.0.zip** below.
3. Unzip it into `Interface/AddOns`, replacing your old `Palettes` folder.
4. In game, type `/reload`.

Found a bug? [Open an issue](https://github.com/odd-brew/daylight-palettes/issues/new/choose). Full details are in the [README](https://github.com/odd-brew/daylight-palettes#readme).
