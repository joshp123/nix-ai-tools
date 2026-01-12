{ python3, writeShellScriptBin }:

let
  python = python3.withPackages (ps: [ ps.google-genai ps.pillow ]);
  script = ./nanobanana.py;
  runScript = writeShellScriptBin "nanobanana" ''
    set -euo pipefail

    if [ -z "''${GEMINI_API_KEY:-}" ] && [ -f /run/agenix/gemini-api-key ]; then
      export GEMINI_API_KEY="$(cat /run/agenix/gemini-api-key)"
    fi

    exec ${python}/bin/python -u ${script} "$@"
  '';
in
runScript
