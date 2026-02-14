#!/usr/bin/env python3
"""Prepare @mariozechner/pi-ai for deterministic Nix builds.

Why:
- Upstream build script runs `generate-models`, which fetches live provider catalogs.
- Nix builds should stay deterministic/cacheable.
- In v0.52.10, changelog advertises gpt-5.3-codex-spark, but generated models can be stale.

This script:
1) Strips generate-models from packages/ai/package.json build script
2) Ensures gpt-5.3-codex-spark exists for openai and openai-codex in models.generated.ts
"""

from __future__ import annotations

import json
import re
from pathlib import Path


def patch_ai_package_json(root: Path) -> None:
    package_json = root / "packages/ai/package.json"
    data = json.loads(package_json.read_text())
    scripts = data.get("scripts", {})
    build = scripts.get("build", "")
    if "generate-models" in build:
        scripts["build"] = "tsgo -p tsconfig.build.json"
        data["scripts"] = scripts
        package_json.write_text(json.dumps(data, indent=2) + "\n")


def ensure_spark_models(root: Path) -> None:
    models_path = root / "packages/ai/src/models.generated.ts"
    text = models_path.read_text()

    if '"gpt-5.3-codex-spark"' in text:
        return

    openai_insert = '''\t\t"gpt-5.3-codex-spark": {
\t\t\tid: "gpt-5.3-codex-spark",
\t\t\tname: "GPT-5.3 Codex Spark",
\t\t\tapi: "openai-responses",
\t\t\tprovider: "openai",
\t\t\tbaseUrl: "https://api.openai.com/v1",
\t\t\treasoning: true,
\t\t\tinput: ["text"],
\t\t\tcost: {
\t\t\t\tinput: 0,
\t\t\t\toutput: 0,
\t\t\t\tcacheRead: 0,
\t\t\t\tcacheWrite: 0,
\t\t\t},
\t\t\tcontextWindow: 128000,
\t\t\tmaxTokens: 16384,
\t\t} satisfies Model<"openai-responses">,
'''

    codex_insert = '''\t\t"gpt-5.3-codex-spark": {
\t\t\tid: "gpt-5.3-codex-spark",
\t\t\tname: "GPT-5.3 Codex Spark",
\t\t\tapi: "openai-codex-responses",
\t\t\tprovider: "openai-codex",
\t\t\tbaseUrl: "https://chatgpt.com/backend-api",
\t\t\treasoning: true,
\t\t\tinput: ["text"],
\t\t\tcost: {
\t\t\t\tinput: 0,
\t\t\t\toutput: 0,
\t\t\t\tcacheRead: 0,
\t\t\t\tcacheWrite: 0,
\t\t\t},
\t\t\tcontextWindow: 128000,
\t\t\tmaxTokens: 128000,
\t\t} satisfies Model<"openai-codex-responses">,
'''

    openai_pattern = re.compile(
        r'(\t\t"gpt-5\.3-codex": \{\n(?:.*?\n)*?\t\t\} satisfies Model<"openai-responses">,\n)',
        re.DOTALL,
    )
    codex_pattern = re.compile(
        r'(\t\t"gpt-5\.3-codex": \{\n(?:.*?\n)*?\t\t\} satisfies Model<"openai-codex-responses">,\n)',
        re.DOTALL,
    )

    text, openai_count = openai_pattern.subn(r"\1" + openai_insert, text, count=1)
    text, codex_count = codex_pattern.subn(r"\1" + codex_insert, text, count=1)

    if openai_count != 1 or codex_count != 1:
        raise RuntimeError(
            "failed to patch gpt-5.3-codex-spark into models.generated.ts "
            f"(openai={openai_count}, openai-codex={codex_count})"
        )

    models_path.write_text(text)


def main() -> None:
    root = Path.cwd()
    patch_ai_package_json(root)
    ensure_spark_models(root)


if __name__ == "__main__":
    main()
