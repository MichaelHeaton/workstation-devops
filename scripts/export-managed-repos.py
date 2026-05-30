#!/usr/bin/env python3
"""Export managed_repos from Ansible group_vars as JSON for Notion sync.

Reads managed_repos_common (all.yml) and managed_repos (profile yml).
Output: repo slug, ansible dest, clone_scope (common | personal | work).

Usage:
  make repos-export
  make repos-sync-notion
  ./scripts/export-managed-repos.py --profile personal
  ./scripts/export-managed-repos.py --json > /tmp/managed-repos.json

Requires: yq (same as scripts/preflight.sh).
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
ALL_CONFIG = REPO_ROOT / "group_vars" / "all.yml"


def run_yq(expr: str, path: Path) -> list[str]:
    proc = subprocess.run(
        ["yq", expr, str(path)],
        check=False,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        return []
    lines = [ln.strip() for ln in proc.stdout.splitlines() if ln.strip()]
    return lines


def parse_repo_slug(repo_url: str) -> str | None:
    """Return owner/name from git@host:owner/repo.git or similar."""
    m = re.search(r"[:/]([^/]+)/([^/.]+?)(?:\.git)?$", repo_url)
    if not m:
        return None
    return f"{m.group(1)}/{m.group(2)}"


def load_managed(scope: str, config: Path) -> list[dict]:
    key = "managed_repos_common" if scope == "common" else "managed_repos"
    dests = run_yq(f".{key}[].dest", config)
    repos = run_yq(f".{key}[].repo", config)
    if len(dests) != len(repos):
        print(f"warning: {config} {key} dest/repo count mismatch", file=sys.stderr)
    entries = []
    for dest, repo in zip(dests, repos):
        slug = parse_repo_slug(repo)
        if not slug:
            print(f"warning: could not parse repo URL: {repo}", file=sys.stderr)
            continue
        entries.append(
            {
                "name": slug.split("/", 1)[-1],
                "slug": slug,
                "dest": dest,
                "clone_scope": scope,
                "repo_url": repo,
            }
        )
    return entries


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--profile",
        default="personal",
        help="Profile name for group_vars/<profile>.yml (default: personal)",
    )
    parser.add_argument("--json", action="store_true", help="Print JSON only")
    args = parser.parse_args()

    profile_config = REPO_ROOT / "group_vars" / f"{args.profile}.yml"
    if not profile_config.is_file():
        print(f"error: missing {profile_config}", file=sys.stderr)
        return 1

    merged: dict[str, dict] = {}
    for scope, path in (("common", ALL_CONFIG), (args.profile, profile_config)):
        for entry in load_managed(scope, path):
            # Profile overrides common for same slug (personal wins over common)
            merged[entry["slug"]] = entry

    rows = sorted(merged.values(), key=lambda r: (r["clone_scope"], r["dest"]))
    payload = {
        "profile": args.profile,
        "projects_root": "~/Projects",
        "repos": rows,
    }

    if args.json:
        print(json.dumps(payload, indent=2))
        return 0

    print(f"profile={args.profile} repos={len(rows)}")
    for row in rows:
        print(f"{row['clone_scope']:8} {row['dest']:45} {row['slug']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
