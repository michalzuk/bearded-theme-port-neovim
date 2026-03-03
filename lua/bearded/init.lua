local theme = require('bearded.theme')

local M = {}

local function command_variants(arglead)
  local variants = theme.get_variants()
  local names = {}
  local lead = string.lower(arglead or '')

  for _, variant in ipairs(variants) do
    if lead == '' or string.find(variant.key, lead, 1, true) == 1 then
      names[#names + 1] = variant.key
    end
  end

  return names
end

local function register_commands()
  if vim.g.bearded_commands_loaded then
    return
  end

  vim.api.nvim_create_user_command('BeardedTheme', function(args)
    theme.load(args.args)
  end, {
    nargs = '?',
    complete = function(arglead)
      return command_variants(arglead)
    end,
  })

  vim.api.nvim_create_user_command('BeardedThemeList', function()
    local variants = theme.get_variants()
    local lines = { 'Available Bearded variants:' }

    for _, variant in ipairs(variants) do
      lines[#lines + 1] = string.format('- %s (%s)', variant.key, variant.background)
    end

    vim.notify(table.concat(lines, '\n'))
  end, {})

  vim.g.bearded_commands_loaded = true
end

function M.setup(opts)
  theme.setup(opts)
  register_commands()

  if vim.g.colors_name == 'bearded' then
    theme.load(vim.g.bearded_variant)
  end
end

function M.load(variant)
  register_commands()
  return theme.load(variant)
end

function M.variants()
  return theme.get_variants()
end

return M
