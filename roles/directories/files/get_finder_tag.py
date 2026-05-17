#!/usr/bin/env python3
"""Read the current macOS Finder color tag on a path, printing the name or 'clear'."""
from __future__ import annotations

import plistlib
import subprocess
import sys

XATTR = "com.apple.metadata:_kMDItemUserTags"


def get_tag(path: str) -> str:
    result = subprocess.run(
        ["xattr", "-px", XATTR, path],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return "clear"
    try:
        hex_data = result.stdout.replace("\n", "").replace(" ", "")
        tags = plistlib.loads(bytes.fromhex(hex_data))
        return tags[0].split("\n")[0] if tags else "clear"
    except Exception:
        return "clear"


def main() -> None:
    if len(sys.argv) != 2:
        print("usage: get_finder_tag.py <path>", file=sys.stderr)
        sys.exit(2)
    print(get_tag(sys.argv[1]))


if __name__ == "__main__":
    main()
