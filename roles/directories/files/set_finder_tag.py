#!/usr/bin/env python3
"""Set or clear a macOS Finder color tag on a path (file or directory)."""
from __future__ import annotations

import plistlib
import subprocess
import sys

# Newline + suffix digit matches Finder's bplist encoding for named color tags.
FINDER_COLOR_SUFFIX: dict[str, str] = {
    "Gray": "0",
    "Green": "2",
    "Purple": "3",
    "Blue": "3",
    "Yellow": "4",
    "Red": "6",
    "Orange": "7",
}

XATTR = "com.apple.metadata:_kMDItemUserTags"
CLEAR = "clear"


def clear_tag(path: str) -> None:
    result = subprocess.run(
        ["xattr", "-d", XATTR, path],
        capture_output=True,
        text=True,
    )
    if result.returncode == 0:
        return
    if "No such xattr" in (result.stderr or ""):
        return
    result.check_returncode()


def set_tag(path: str, tag: str) -> None:
    suffix = FINDER_COLOR_SUFFIX.get(tag)
    if suffix is None:
        print(f"unknown Finder color tag: {tag!r}", file=sys.stderr)
        sys.exit(1)

    plist = plistlib.dumps([f"{tag}\n{suffix}"], fmt=plistlib.FMT_BINARY)
    subprocess.run(
        ["xattr", "-wx", XATTR, plist.hex(), path],
        check=True,
    )


def main() -> None:
    if len(sys.argv) != 3:
        print("usage: set_finder_tag.py <path> <ColorName|clear>", file=sys.stderr)
        sys.exit(2)

    path, action = sys.argv[1], sys.argv[2]
    if action == CLEAR:
        clear_tag(path)
    else:
        set_tag(path, action)


if __name__ == "__main__":
    main()
