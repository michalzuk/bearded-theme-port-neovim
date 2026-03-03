# bearded.nvim

Port of [Bearded Theme](https://github.com/BeardedBear/bearded-theme) from VSCode to Neovim.

Unofficial Neovim port for Bearded Theme users. This project is not affiliated with, endorsed by, or a replacement for the original VSCode theme; it exists to bring the same visual style to Neovim while crediting the original authors.

This plugin ships all 64 Bearded variants generated from the upstream VSCode theme JSON files and maps them to core Vim, Tree-sitter, and common plugin highlight groups.

## Install

### lazy.nvim (GitHub)

```lua
{
  'michalzuk/bearded-theme-port-neovim',
  name = 'bearded.nvim',
  config = function()
    require('bearded').setup({
      variant = 'arc',
      transparent = false,
      terminal_colors = true,
      termguicolors = true,
    })
    vim.cmd.colorscheme('bearded')
  end,
}
```

### lazy.nvim (local dev)

```lua
{
  dir = '~/Projects/bearer.nvim',
  name = 'bearded.nvim',
}
```

### vim-plug

```vim
Plug 'michalzuk/bearded-theme-port-neovim'
```

## Usage

- `:colorscheme bearded` loads the theme.
- `:colorscheme bearded-arc` (or any variant key) loads a specific variant directly.
- `:BeardedTheme <variant>` switches to any variant.
- `:BeardedThemeList` prints all available variants.

Direct variant colorscheme in config:

```lua
vim.cmd.colorscheme('bearded-arc')
```

You can also set a global before loading:

```lua
vim.g.bearded_variant = 'monokai-terra'
vim.cmd.colorscheme('bearded')
```

## API

```lua
require('bearded').setup(opts)
require('bearded').load('arc')
require('bearded').variants()
```

### setup opts

- `variant` (string): default variant key (default: `arc`)
- `transparent` (boolean): remove background for main UI groups
- `terminal_colors` (boolean): set `g:terminal_color_0..15`
- `termguicolors` (boolean): enable `termguicolors` if disabled (default: `true`)

## Notes

- Palette data is generated from upstream theme artifacts in `dist/vscode/themes/*.json`.
- Variant keys are lower-case slugs, e.g. `arc`, `solarized-light`, `themanopia`, `milkshake-vanilla`.

## Refresh palettes from upstream

1. Build VSCode themes in the upstream repo:

```bash
cd /path/to/bearded-theme
npm ci
npm run build:vscode
```

2. Regenerate this plugin palette file:

```bash
python3 scripts/update-palettes.py --themes-dir /path/to/bearded-theme/dist/vscode/themes
```

By default, the script reads from `/private/tmp/bearded-theme/dist/vscode/themes` and writes to `lua/bearded/palettes.lua`.

## Tests

Run core behavior tests (variant loading, command availability, key highlight mappings, transparent mode):

```bash
python3 -m unittest tests/test_core.py
```

## Attribution

- This project is a Neovim port of [Bearded Theme](https://github.com/BeardedBear/bearded-theme) by [BeardedBear](https://github.com/BeardedBear).
- Upstream theme design and palette definitions come from the original project.
- This repository is distributed under `GPL-3.0`; see `LICENSE`.
