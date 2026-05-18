#!/usr/bin/env bash
# Export Brave profile customizations from this Mac into dotfiles/brave-profiles/.
# Quit Brave before running. Re-run after UI tweaks, then commit profiles.json (+ backgrounds/).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$REPO_ROOT/dotfiles/brave-profiles"
BACKGROUNDS="$OUT_DIR/backgrounds"
CONFIG="$OUT_DIR/profiles.json"
BRAVE_DATA="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"

if pgrep -xq "Brave Browser" 2>/dev/null; then
  echo "Quit Brave Browser first."
  exit 1
fi

mkdir -p "$BACKGROUNDS"

export BRAVE_DATA OUT_DIR BACKGROUNDS CONFIG
python3 <<'PY'
import json
import os
import shutil
from pathlib import Path

BRAVE_DATA = Path(os.environ["BRAVE_DATA"])
OUT_DIR = Path(os.environ["OUT_DIR"])
BACKGROUNDS = Path(os.environ["BACKGROUNDS"])
CONFIG = Path(os.environ["CONFIG"])

PROFILE_DIRS = [
    ("Default", "Personal"),
    ("Profile 1", "Adobe"),
    ("Profile 2", "UV Cyber"),
]

state = json.loads((BRAVE_DATA / "Local State").read_text(encoding="utf-8"))
info_cache = state.get("profile", {}).get("info_cache", {})

NTP_KEYS = {
    "background",
    "custom_background_image_list",
    "show_brave_vpn",
    "show_rewards",
    "show_together",
}
THEME_KEYS = {"color_scheme2", "color_variant2", "user_color2"}
LOCAL_STATE_KEYS = {
    "avatar_icon",
    "profile_color_seed",
    "profile_highlight_color",
    "default_avatar_fill_color",
    "default_avatar_stroke_color",
}

profiles_out = []

for dir_name, default_name in PROFILE_DIRS:
    prefs_path = BRAVE_DATA / dir_name / "Preferences"
    if not prefs_path.exists():
        continue
    prefs = json.loads(prefs_path.read_text(encoding="utf-8"))
    ls = info_cache.get(dir_name, {})

    entry = {
        "dir": dir_name,
        "name": prefs.get("profile", {}).get("name", default_name),
        "local_state": {k: ls[k] for k in LOCAL_STATE_KEYS if k in ls},
        "preferences": {},
    }

    profile_prefs = {}
    if "avatar_index" in prefs.get("profile", {}):
        profile_prefs["avatar_index"] = prefs["profile"]["avatar_index"]
    profile_prefs["name"] = entry["name"]
    if dir_name != "Default":
        profile_prefs["is_using_default_name"] = False
    entry["preferences"]["profile"] = profile_prefs

    browser_theme = prefs.get("browser", {}).get("theme", {})
    if browser_theme:
        entry["preferences"]["browser"] = {
            "theme": {k: browser_theme[k] for k in THEME_KEYS if k in browser_theme}
        }

    ext_theme = prefs.get("extensions", {}).get("theme", {})
    if ext_theme:
        entry["preferences"]["extensions"] = {"theme": ext_theme}

    ntp = prefs.get("brave", {}).get("new_tab_page", {})
    if ntp:
        ntp_out = {k: ntp[k] for k in NTP_KEYS if k in ntp}
        entry["preferences"]["brave"] = {"new_tab_page": ntp_out}
        bg = ntp.get("background", {})
        if bg.get("type") == "custom_image":
            image_name = bg.get("selected_value")
            if image_name:
                entry["background_image"] = image_name
                src = BRAVE_DATA / dir_name / "sanitized_background_images" / image_name
                if src.is_file():
                    shutil.copy2(src, BACKGROUNDS / image_name)
                    print(f"copied background: {image_name}")

    if prefs.get("bookmark_bar"):
        entry["preferences"]["bookmark_bar"] = prefs["bookmark_bar"]

    profiles_out.append(entry)
    print(f"exported: {entry['name']} ({dir_name})")

spec = {"version": 1, "profiles": profiles_out}
CONFIG.write_text(json.dumps(spec, indent=2) + "\n", encoding="utf-8")
print(f"wrote {CONFIG}")
PY

echo "Done. Review and commit dotfiles/brave-profiles/"
