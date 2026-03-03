#!/usr/bin/env python3
"""Regenerate lua/bearded/palettes.lua from VSCode Bearded theme JSON files.

Usage:
  python3 scripts/update-palettes.py --themes-dir /path/to/bearded-theme/dist/vscode/themes
"""

from __future__ import annotations

import argparse
import glob
import json
import os
from pathlib import Path
from typing import Dict


THEME_PREFIX = "bearded-theme-"


def hex_to_rgb(hex_color: str) -> tuple[float, float, float]:
    value = hex_color.lstrip("#")
    if len(value) == 8:
        value = value[:6]
    return (
        int(value[0:2], 16) / 255.0,
        int(value[2:4], 16) / 255.0,
        int(value[4:6], 16) / 255.0,
    )


def is_light(hex_color: str) -> bool:
    red, green, blue = hex_to_rgb(hex_color)
    luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
    return luminance > 0.58


def pick_color(colors: Dict[str, str], key: str, fallback: str | None = None) -> str | None:
    return colors.get(key, fallback)


def build_palette_entry(slug: str, payload: dict) -> list[str]:
    colors = payload["colors"]
    semantic = payload.get("semanticTokenColors", {})

    ui_keys = {
        "bg": "editor.background",
        "fg": "editor.foreground",
        "cursor": "editorCursor.foreground",
        "line": "editor.lineHighlightBackground",
        "selection": "editor.selectionBackground",
        "search": "editor.findMatchBackground",
        "border": "editorGroup.border",
        "bg_alt": "editorGroupHeader.tabsBackground",
        "bg_float": "editorWidget.background",
        "gutter": "editorGutter.background",
        "line_nr": "editorLineNumber.foreground",
        "line_nr_active": "editorLineNumber.activeForeground",
        "pmenu_bg": "editorSuggestWidget.background",
        "pmenu_sel": "editorSuggestWidget.selectedBackground",
        "status_bg": "statusBar.background",
        "status_fg": "statusBar.foreground",
        "tab_active": "tab.activeBackground",
        "tab_inactive": "tab.inactiveBackground",
        "tab_fg": "tab.activeForeground",
        "tab_inactive_fg": "tab.inactiveForeground",
        "diff_add": "diffEditor.insertedTextBackground",
        "diff_delete": "diffEditor.removedTextBackground",
        "diff_change": "diffEditor.move.border",
        "git_add": "gitDecoration.untrackedResourceForeground",
        "git_delete": "gitDecoration.deletedResourceForeground",
        "git_change": "gitDecoration.modifiedResourceForeground",
        "error": "editorError.foreground",
        "warning": "editorWarning.foreground",
        "info": "editorOverviewRuler.infoForeground",
        "hint": "editorInfo.foreground",
        "accent": "activityBar.activeBorder",
        "accent_alt": "activityBar.foreground",
        "comment": "editorLineNumber.foreground",
    }

    semantic_colors = {
        "namespace": semantic.get("namespace", {}).get("foreground", colors.get("charts.blue")),
        "property": semantic.get("property", {}).get("foreground", colors.get("charts.orange")),
        "parameter": semantic.get("parameter", {}).get("foreground", colors.get("charts.purple")),
        "variable": semantic.get("variable", {}).get("foreground", colors.get("editor.foreground")),
        "default_lib": semantic.get("variable.defaultLibrary", {}).get("foreground", colors.get("charts.green")),
        "class": semantic.get("class.declaration", {}).get("foreground", colors.get("charts.purple")),
        "decorator": semantic.get("class.decorator", {}).get("foreground", colors.get("charts.purple")),
    }

    syntax = {
        "blue": colors.get("charts.blue"),
        "green": colors.get("charts.green"),
        "green_alt": colors.get("scmGraph.foreground3", colors.get("charts.green")),
        "orange": colors.get("charts.orange"),
        "pink": colors.get("charts.purple"),
        "purple": semantic_colors["class"],
        "red": colors.get("charts.red"),
        "salmon": semantic_colors["variable"],
        "turquoise": semantic_colors["default_lib"],
        "yellow": colors.get("charts.yellow"),
    }

    bg = pick_color(colors, ui_keys["bg"], "#1e1e1e") or "#1e1e1e"
    background = "light" if is_light(bg) else "dark"

    lines = [f"  ['{slug.lower()}'] = {{", f"    name = '{slug}',", f"    background = '{background}',"]

    for key, json_key in ui_keys.items():
        value = pick_color(colors, json_key)
        if value is None:
            if key in ("hint", "info"):
                value = colors.get("charts.blue")
            elif key == "comment":
                value = colors.get("editorLineNumber.foreground", colors.get("editor.foreground"))
            else:
                value = colors.get("editor.foreground")
        lines.append(f"    {key} = '{value}',")

    lines.append("    syntax = {")
    for key in ("blue", "green", "green_alt", "orange", "pink", "purple", "red", "salmon", "turquoise", "yellow"):
        lines.append(f"      {key} = '{syntax[key]}',")
    lines.append("    },")

    lines.append("    semantic = {")
    for key in ("namespace", "property", "parameter", "variable", "default_lib", "class", "decorator"):
        lines.append(f"      {key} = '{semantic_colors[key]}',")
    lines.append("    },")
    lines.append("  },")

    return lines


def main() -> int:
    parser = argparse.ArgumentParser(description="Regenerate lua/bearded/palettes.lua from Bearded VSCode themes")
    parser.add_argument(
        "--themes-dir",
        default=os.environ.get("BEARDED_THEMES_DIR", "/private/tmp/bearded-theme/dist/vscode/themes"),
        help="Directory containing bearded-theme-*.json files",
    )
    parser.add_argument(
        "--output",
        default=str(Path(__file__).resolve().parents[1] / "lua/bearded/palettes.lua"),
        help="Output Lua file path",
    )
    args = parser.parse_args()

    pattern = os.path.join(args.themes_dir, f"{THEME_PREFIX}*.json")
    files = sorted(glob.glob(pattern))
    if not files:
        print(f"No theme files found at: {pattern}")
        print("Build upstream first: npm run build:vscode (in Bearded theme repo)")
        return 1

    output_lines = [
        "-- Auto-generated from BeardedBear/bearded-theme VSCode dist themes.",
        "-- Source: " + args.themes_dir,
        "local M = {}",
        "",
        "M.variants = {",
    ]

    for path in files:
        name = os.path.basename(path)
        slug = name[len(THEME_PREFIX) : -len(".json")]
        with open(path, "r", encoding="utf-8") as handle:
            payload = json.load(handle)
        output_lines.extend(build_palette_entry(slug, payload))

    output_lines.extend(["}", "", "return M", ""])

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(output_lines), encoding="ascii")

    print(f"Wrote {output_path} with {len(files)} variants")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
