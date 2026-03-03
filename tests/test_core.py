import subprocess
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]


def nvim_eval(commands):
    base = ["nvim", "--headless", "-u", "NONE", "-c", f"set rtp+={REPO_ROOT}"]
    for cmd in commands:
        base.extend(["-c", cmd])
    base.extend(["-c", "qa"])
    result = subprocess.run(base, capture_output=True, text=True, check=True)
    return result.stderr.strip().splitlines()


def hex_hl(name):
    return (
        "lua local h=vim.api.nvim_get_hl(0,{name='"
        + name
        + "',link=false}); print(h.fg and string.format('#%06X',h.fg) or 'nil', h.bg and string.format('#%06X',h.bg) or 'nil')"
    )


class TestBeardedCore(unittest.TestCase):
    def test_colorscheme_alias_sets_variant(self):
        out = nvim_eval([
            "colorscheme bearded-arc",
            "lua print(vim.g.bearded_variant, vim.g.colors_name, vim.o.background)",
        ])
        self.assertEqual(out[-1], "arc bearded dark")

    def test_light_variant_sets_background(self):
        out = nvim_eval([
            "colorscheme bearded-vivid-light",
            "lua print(vim.g.bearded_variant, vim.o.background)",
        ])
        self.assertEqual(out[-1], "vivid-light light")

    def test_bearded_theme_command_available_without_setup(self):
        out = nvim_eval([
            "colorscheme bearded",
            "BeardedTheme monokai-terra",
            "lua print(vim.g.bearded_variant)",
        ])
        self.assertEqual(out[-1], "monokai-terra")

    def test_core_syntax_mappings_for_arc(self):
        out = nvim_eval([
            "colorscheme bearded-arc",
            hex_hl("Function"),
            hex_hl("String"),
            hex_hl("Keyword"),
            hex_hl("Type"),
        ])

        self.assertEqual(out[-4], "#69C3FF nil")
        self.assertEqual(out[-3], "#3CEC85 nil")
        self.assertEqual(out[-2], "#EACD61 nil")
        self.assertEqual(out[-1], "#B78AFF nil")

    def test_transparent_mode_keeps_contrasting_cursor_foreground(self):
        out = nvim_eval([
            "lua require('bearded').setup({ transparent = true, variant = 'arc' })",
            "colorscheme bearded",
            hex_hl("Normal"),
            hex_hl("Cursor"),
        ])

        self.assertEqual(out[-2], "#D0D7E4 nil")
        self.assertEqual(out[-1], "#1C2433 #EACD61")


if __name__ == "__main__":
    unittest.main()
