{ lib
, stdenv
, fetchFromGitHub
, nodejs_22
, pnpm_10 ? null
, pnpm
, bun
, cacert
, git
, python3
, makeWrapper
, pkgs
, ... }:

let
  nodejs = nodejs_22;
  pnpmPkg = if pnpm_10 != null then pnpm_10 else pnpm;
  pnpmFetchDepsPkg = pkgs.callPackage "${pkgs.path}/pkgs/build-support/node/fetch-pnpm-deps" {
    pnpm = pnpmPkg;
  };
  pnpmFetchDeps = pnpmFetchDepsPkg.fetchPnpmDeps;
  pnpmConfigHook = pnpmFetchDepsPkg.pnpmConfigHook;

  version = "17.2.0";
  pnpmHash = if stdenv.isLinux then "sha256-+k0w4ojGhGKNNIVrGovj6lT3WbGnN8i8AthFJQiEZyQ=" else "sha256-WY6LWQhLEKJVnI/028CPUqiH4DUyX0wTMmlY0tDfSS4=";
  src = fetchFromGitHub {
    owner = "ryoppippi";
    repo = "ccusage";
    rev = "v${version}";
    hash = "sha256-3EHiNPQlvLQgkFRSGWhLuo31PVaNBGhpc9pa3VcR5tw=";
  };

  mkCcusage = { pname, packageFilter, packageDir, binName, description }:
    stdenv.mkDerivation (finalAttrs: {
      inherit pname;
      inherit version;
      src = src;

      pnpmDeps = pnpmFetchDeps {
        inherit (finalAttrs) pname version src;
        hash = pnpmHash;
        fetcherVersion = 3;
      };

      nativeBuildInputs = [
        nodejs
        pnpmPkg
        pnpmConfigHook
        bun
        cacert
        git
        python3
        makeWrapper
      ];

      env = {
        PNPM_IGNORE_PACKAGE_MANAGER_CHECK = "1";
        CI = "1";
        CCUSA_SKIP_SCHEMA_COPY = "1";
        NPM_CONFIG_CAFILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
        NODE_EXTRA_CA_CERTS = "${cacert}/etc/ssl/certs/ca-bundle.crt";
        SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
      };

      postPatch = ''
        substituteInPlace packages/internal/src/pricing.ts \
          --replace "using fetcher =" "const fetcher ="
        substituteInPlace package.json \
          --replace "pnpm@10.24.0" "pnpm@${pnpmPkg.version}"
        python3 - <<'PY'
from pathlib import Path

path = Path("apps/ccusage/scripts/generate-json-schema.ts")
text = path.read_text()
old = (
    "\tconst gitRoot = await $`git rev-parse --show-toplevel`.text().then(text => text.trim());\n"
    "\tawait $`cp ''${SCHEMA_FILENAME} ''${gitRoot}/docs/public/''${SCHEMA_FILENAME}`;\n"
)
new = (
    "\tif (process.env.CCUSA_SKIP_SCHEMA_COPY == '1') return;\n"
    "\tlet gitRoot = \"\";\n"
    "\ttry {\n"
    "\t\tgitRoot = await $`git rev-parse --show-toplevel`.text().then(text => text.trim());\n"
    "\t} catch {\n"
    "\t\treturn;\n"
    "\t}\n"
    "\tawait $`cp ''${SCHEMA_FILENAME} ''${gitRoot}/docs/public/''${SCHEMA_FILENAME}`;\n"
)
if old not in text:
    raise SystemExit("Expected snippet not found in generate-json-schema.ts")
path.write_text(text.replace(old, new))
PY
      '';

      buildPhase = ''
        runHook preBuild
        export HOME="$TMPDIR"
        if [ -n "''${STORE_PATH:-}" ]; then
          export PNPM_STORE_PATH="''${STORE_PATH}"
          export NPM_CONFIG_STORE_DIR="''${STORE_PATH}"
          pnpm config set store-dir "''${STORE_PATH}"
        fi
        pnpm install --offline --frozen-lockfile --ignore-scripts
        pnpm --filter "${packageFilter}" build
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/libexec/$pname $out/bin
        if [ -d "apps/${packageDir}/dist" ]; then
          cp -r "apps/${packageDir}/dist" "$out/libexec/$pname/"
        fi
        if [ -f "apps/${packageDir}/config-schema.json" ]; then
          cp "apps/${packageDir}/config-schema.json" "$out/libexec/$pname/"
        fi
        cp -r node_modules "$out/libexec/$pname/node_modules"
        for path in apps/ccusage apps/codex apps/mcp; do
          if [ -d "$path" ]; then
            mkdir -p "$out/libexec/$pname/$(dirname "$path")"
            cp -r "$path" "$out/libexec/$pname/$path"
          fi
        done
        for path in packages/internal packages/terminal; do
          if [ -d "$path" ]; then
            mkdir -p "$out/libexec/$pname/$(dirname "$path")"
            cp -r "$path" "$out/libexec/$pname/$path"
          fi
        done
        if [ -d "docs" ]; then
          cp -r "docs" "$out/libexec/$pname/docs"
        fi
        rm -rf \
          "$out/libexec/$pname/apps/ccusage/node_modules" \
          "$out/libexec/$pname/apps/codex/node_modules" \
          "$out/libexec/$pname/apps/mcp/node_modules" \
          "$out/libexec/$pname/docs/node_modules"
        makeWrapper ${nodejs}/bin/node "$out/bin/${binName}" \
          --add-flags "$out/libexec/$pname/dist/index.js" \
          --set NODE_PATH "$out/libexec/$pname/node_modules"
        runHook postInstall
      '';

      meta = with lib; {
        inherit description;
        homepage = "https://github.com/ryoppippi/ccusage";
        license = licenses.mit;
        platforms = platforms.unix;
        mainProgram = binName;
      };
    });
in
{
  ccusage = mkCcusage {
    pname = "ccusage";
    packageFilter = "ccusage";
    packageDir = "ccusage";
    binName = "ccusage";
    description = "Usage analysis tool for Claude Code";
  };

  ccusage-codex = mkCcusage {
    pname = "ccusage-codex";
    packageFilter = "@ccusage/codex";
    packageDir = "codex";
    binName = "ccusage-codex";
    description = "Usage analysis tool for OpenAI Codex sessions";
  };
}
