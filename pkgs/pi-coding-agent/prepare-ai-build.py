#!/usr/bin/env python3
"""Prepare @earendil-works/pi-ai for deterministic Nix builds.

Why:
- Upstream build scripts run model generators, which fetch live provider catalogs.
- Nix builds should stay deterministic/cacheable.

This script:
1) Strips model generation from packages/ai/package.json build script
2) Uses the generated model files committed in the upstream release tarball
"""

from __future__ import annotations

import json
from pathlib import Path


def patch_ai_package_json(root: Path) -> None:
    package_json = root / "packages/ai/package.json"
    data = json.loads(package_json.read_text())
    scripts = data.get("scripts", {})
    build = scripts.get("build", "")
    if "generate-models" in build or "generate-image-models" in build:
        scripts["build"] = "tsgo -p tsconfig.build.json"
        data["scripts"] = scripts
        package_json.write_text(json.dumps(data, indent=2) + "\n")


def main() -> None:
    root = Path.cwd()
    patch_ai_package_json(root)


if __name__ == "__main__":
    main()
