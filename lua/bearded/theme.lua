local palettes = require('bearded.palettes').variants

local M = {}

local defaults = {
  transparent = false,
  terminal_colors = true,
  termguicolors = true,
  variant = 'arc',
}

local config = vim.deepcopy(defaults)

local function blend_alpha(hex, fallback)
  if type(hex) ~= 'string' then
    return fallback
  end

  if hex == 'NONE' then
    return hex
  end

  if #hex == 9 then
    return '#' .. hex:sub(2, 7)
  end

  if #hex == 7 then
    return hex
  end

  return fallback
end

local function normalize_color(hex)
  if type(hex) ~= 'string' then
    return hex
  end

  if hex == 'NONE' then
    return hex
  end

  if #hex == 9 then
    return '#' .. hex:sub(2, 7)
  end

  return hex
end

local function normalize_palette(value)
  if type(value) ~= 'table' then
    return normalize_color(value)
  end

  local out = {}
  for k, v in pairs(value) do
    out[k] = normalize_palette(v)
  end

  return out
end

local function set_hl(name, value)
  vim.api.nvim_set_hl(0, name, value)
end

local function apply_terminal_colors(c)
  vim.g.terminal_color_0 = c.bg
  vim.g.terminal_color_1 = c.syntax.red
  vim.g.terminal_color_2 = c.syntax.green
  vim.g.terminal_color_3 = c.syntax.yellow
  vim.g.terminal_color_4 = c.syntax.blue
  vim.g.terminal_color_5 = c.syntax.pink
  vim.g.terminal_color_6 = c.syntax.turquoise
  vim.g.terminal_color_7 = c.fg
  vim.g.terminal_color_8 = blend_alpha(c.line_nr_active, c.syntax.blue)
  vim.g.terminal_color_9 = c.error
  vim.g.terminal_color_10 = c.git_add
  vim.g.terminal_color_11 = c.warning
  vim.g.terminal_color_12 = c.semantic.namespace
  vim.g.terminal_color_13 = c.semantic.parameter
  vim.g.terminal_color_14 = c.semantic.default_lib
  vim.g.terminal_color_15 = c.bg_float
end

local function groups(c)
  return {
    Normal = { fg = c.fg, bg = c.bg },
    NormalNC = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg, bg = c.bg_float },
    FloatBorder = { fg = c.border, bg = c.bg_float },
    FloatTitle = { fg = c.semantic.namespace, bold = true },
    ColorColumn = { bg = c.line },
    Conceal = { fg = c.comment },
    Cursor = { fg = c.bg, bg = c.cursor },
    CursorColumn = { bg = c.line },
    CursorLine = { bg = c.line },
    CursorLineNr = { fg = c.line_nr_active, bold = true },
    LineNr = { fg = c.line_nr },
    Directory = { fg = c.semantic.namespace },
    EndOfBuffer = { fg = c.bg },
    ErrorMsg = { fg = c.error, bold = true },
    WarningMsg = { fg = c.warning, bold = true },
    ModeMsg = { fg = c.semantic.namespace, bold = true },
    MoreMsg = { fg = c.git_add, bold = true },
    Question = { fg = c.git_add, bold = true },
    Folded = { fg = c.comment, bg = c.bg_alt },
    FoldColumn = { fg = c.comment, bg = c.gutter },
    SignColumn = { fg = c.comment, bg = c.gutter },
    IncSearch = { fg = c.bg, bg = c.warning, bold = true },
    CurSearch = { fg = c.bg, bg = c.warning, bold = true },
    Search = { bg = c.search },
    MatchParen = { fg = c.warning, bg = c.selection, bold = true },
    NonText = { fg = c.comment },
    Whitespace = { fg = blend_alpha(c.comment, c.border) },
    SpecialKey = { fg = c.comment },
    Pmenu = { fg = c.fg, bg = c.pmenu_bg },
    PmenuSel = { fg = c.fg, bg = c.pmenu_sel, bold = true },
    PmenuSbar = { bg = c.bg_alt },
    PmenuThumb = { bg = c.comment },
    WildMenu = { fg = c.bg, bg = c.semantic.namespace, bold = true },
    StatusLine = { fg = c.fg, bg = c.status_bg },
    StatusLineNC = { fg = c.status_fg, bg = c.bg_alt },
    WinSeparator = { fg = c.border },
    VertSplit = { fg = c.border },
    TabLine = { fg = c.tab_inactive_fg, bg = c.tab_inactive },
    TabLineSel = { fg = c.tab_fg, bg = c.tab_active, bold = true },
    TabLineFill = { bg = c.bg_alt },
    Title = { fg = c.syntax.yellow, bold = true },
    Visual = { bg = c.selection },
    VisualNOS = { bg = c.selection },
    QuickFixLine = { bg = c.selection, bold = true },
    CursorLineFold = { fg = c.line_nr_active },
    CursorLineSign = { fg = c.line_nr_active, bg = c.gutter },

    Comment = { fg = c.comment, italic = true },
    Constant = { fg = c.syntax.red },
    String = { fg = c.syntax.green },
    Character = { fg = c.syntax.green_alt },
    Number = { fg = c.syntax.orange },
    Boolean = { fg = c.syntax.orange },
    Float = { fg = c.syntax.orange },
    Identifier = { fg = c.syntax.salmon },
    Function = { fg = c.syntax.blue },
    Statement = { fg = c.syntax.yellow },
    Conditional = { fg = c.syntax.yellow },
    Repeat = { fg = c.syntax.yellow },
    Label = { fg = c.syntax.orange },
    Operator = { fg = c.syntax.yellow },
    Keyword = { fg = c.syntax.yellow },
    Exception = { fg = c.error },
    PreProc = { fg = c.syntax.yellow },
    Include = { fg = c.syntax.yellow },
    Define = { fg = c.syntax.yellow },
    Macro = { fg = c.semantic.decorator },
    PreCondit = { fg = c.syntax.yellow },
    Type = { fg = c.syntax.purple },
    StorageClass = { fg = c.syntax.turquoise },
    Structure = { fg = c.syntax.purple },
    Typedef = { fg = c.syntax.purple },
    Special = { fg = c.semantic.property },
    SpecialChar = { fg = c.syntax.orange },
    Tag = { fg = c.syntax.blue },
    Delimiter = { fg = c.fg },
    SpecialComment = { fg = c.comment, italic = true },
    Debug = { fg = c.error },
    Underlined = { fg = c.semantic.namespace, underline = true },
    Bold = { bold = true },
    Italic = { italic = true },
    Ignore = { fg = c.comment },
    Error = { fg = c.error },
    Todo = { fg = c.bg, bg = c.syntax.yellow, bold = true },

    DiagnosticError = { fg = c.error },
    DiagnosticWarn = { fg = c.warning },
    DiagnosticInfo = { fg = c.info },
    DiagnosticHint = { fg = c.hint },
    DiagnosticOk = { fg = c.git_add },
    DiagnosticVirtualTextError = { fg = c.error, bg = c.diff_delete },
    DiagnosticVirtualTextWarn = { fg = c.warning, bg = c.diff_change },
    DiagnosticVirtualTextInfo = { fg = c.info, bg = c.diff_change },
    DiagnosticVirtualTextHint = { fg = c.hint, bg = c.diff_change },
    DiagnosticUnderlineError = { sp = c.error, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.warning, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.info, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.hint, undercurl = true },

    DiffAdd = { bg = c.diff_add },
    DiffChange = { bg = c.diff_change },
    DiffDelete = { bg = c.diff_delete },
    DiffText = { bg = c.selection },
    Added = { fg = c.git_add },
    Changed = { fg = c.git_change },
    Removed = { fg = c.git_delete },

    GitSignsAdd = { fg = c.git_add, bg = c.gutter },
    GitSignsChange = { fg = c.git_change, bg = c.gutter },
    GitSignsDelete = { fg = c.git_delete, bg = c.gutter },
    GitSignsCurrentLineBlame = { fg = c.comment, italic = true },

    ['@namespace'] = { fg = c.semantic.namespace },
    ['@type'] = { fg = c.syntax.purple },
    ['@type.builtin'] = { fg = c.syntax.turquoise },
    ['@type.definition'] = { fg = c.semantic.class },
    ['@attribute'] = { fg = c.semantic.decorator },
    ['@property'] = { fg = c.semantic.property },
    ['@function'] = { fg = c.syntax.blue },
    ['@function.builtin'] = { fg = c.syntax.blue },
    ['@function.call'] = { fg = c.syntax.blue },
    ['@constructor'] = { fg = c.syntax.blue },
    ['@parameter'] = { fg = c.semantic.parameter },
    ['@variable'] = { fg = c.semantic.variable },
    ['@variable.builtin'] = { fg = c.semantic.default_lib },
    ['@keyword'] = { fg = c.syntax.yellow },
    ['@keyword.return'] = { fg = c.syntax.yellow },
    ['@keyword.function'] = { fg = c.syntax.yellow },
    ['@string'] = { fg = c.syntax.green },
    ['@string.escape'] = { fg = c.syntax.orange },
    ['@character'] = { fg = c.syntax.green_alt },
    ['@number'] = { fg = c.syntax.orange },
    ['@boolean'] = { fg = c.syntax.orange },
    ['@constant'] = { fg = c.syntax.red },
    ['@constant.builtin'] = { fg = c.syntax.turquoise },
    ['@constant.macro'] = { fg = c.semantic.decorator },
    ['@operator'] = { fg = c.syntax.yellow },
    ['@punctuation.delimiter'] = { fg = c.fg },
    ['@punctuation.bracket'] = { fg = c.fg },
    ['@comment'] = { fg = c.comment, italic = true },
    ['@markup.heading'] = { fg = c.syntax.yellow, bold = true },
    ['@markup.strong'] = { fg = c.syntax.salmon, bold = true },
    ['@markup.italic'] = { fg = c.syntax.orange, italic = true },
    ['@markup.strikethrough'] = { fg = c.syntax.red, strikethrough = true },
    ['@markup.link'] = { fg = c.semantic.namespace, underline = true },
    ['@diff.plus'] = { fg = c.git_add },
    ['@diff.minus'] = { fg = c.git_delete },
    ['@diff.delta'] = { fg = c.git_change },

    NvimTreeNormal = { fg = c.fg, bg = c.bg_alt },
    NvimTreeRootFolder = { fg = c.syntax.yellow, bold = true },
    NvimTreeFolderName = { fg = c.semantic.namespace },
    NvimTreeOpenedFolderName = { fg = c.semantic.namespace, bold = true },
    NvimTreeGitDirty = { fg = c.git_change },
    NvimTreeGitNew = { fg = c.git_add },
    NvimTreeGitDeleted = { fg = c.git_delete },

    TelescopeNormal = { fg = c.fg, bg = c.bg_float },
    TelescopeBorder = { fg = c.border, bg = c.bg_float },
    TelescopeTitle = { fg = c.syntax.yellow, bold = true },
    TelescopePromptNormal = { fg = c.fg, bg = c.bg_alt },
    TelescopePromptBorder = { fg = c.border, bg = c.bg_alt },
    TelescopeSelection = { bg = c.selection, bold = true },
    TelescopeMatching = { fg = c.syntax.yellow, bold = true },

    WhichKey = { fg = c.syntax.yellow },
    WhichKeyDesc = { fg = c.semantic.namespace },
    WhichKeyGroup = { fg = c.syntax.pink },
    WhichKeySeparator = { fg = c.comment },
  }
end

local function normalize_variant(input)
  if not input or input == '' then
    return nil
  end

  return string.lower(input)
end

local function resolve_variant(requested)
  local requested_variant = normalize_variant(requested)
  local variant = normalize_variant(requested)
    or normalize_variant(vim.g.bearded_variant)
    or normalize_variant(config.variant)
    or defaults.variant

  if palettes[variant] then
    return variant, palettes[variant], nil
  end

  local current = normalize_variant(vim.g.bearded_variant)
  if current and palettes[current] then
    return current, palettes[current], requested_variant
  end

  return defaults.variant, palettes[defaults.variant], requested_variant
end

local transparent_groups = {
  Normal = true,
  NormalNC = true,
  NormalFloat = true,
  FloatBorder = true,
  SignColumn = true,
  FoldColumn = true,
  StatusLine = true,
  StatusLineNC = true,
  TabLine = true,
  TabLineSel = true,
  TabLineFill = true,
  Pmenu = true,
  PmenuSbar = true,
  PmenuThumb = true,
  NvimTreeNormal = true,
  TelescopeNormal = true,
  TelescopeBorder = true,
  TelescopePromptNormal = true,
  TelescopePromptBorder = true,
}

local function apply_transparency(hl)
  for name, spec in pairs(hl) do
    if transparent_groups[name] then
      spec.bg = 'NONE'
    end
  end
end

function M.get_variants()
  local out = {}

  for key, data in pairs(palettes) do
    out[#out + 1] = {
      key = key,
      name = data.name,
      background = data.background,
    }
  end

  table.sort(out, function(a, b)
    return a.key < b.key
  end)

  return out
end

function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
end

function M.load(variant)
  local key, palette, invalid = resolve_variant(variant)
  palette = normalize_palette(palette)

  if invalid then
    vim.notify(
      string.format("bearded.nvim: unknown variant '%s', using '%s'", invalid, key),
      vim.log.levels.WARN
    )
  end

  if config.termguicolors and not vim.o.termguicolors then
    vim.o.termguicolors = true
  end

  vim.o.background = palette.background
  vim.g.bearded_variant = key

  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') == 1 then
    vim.cmd('syntax reset')
  end

  vim.g.colors_name = 'bearded'

  local hl = groups(palette)

  if config.transparent then
    apply_transparency(hl)
  end

  for name, value in pairs(hl) do
    set_hl(name, value)
  end

  if config.terminal_colors then
    apply_terminal_colors(palette)
  end

  return key
end

return M
