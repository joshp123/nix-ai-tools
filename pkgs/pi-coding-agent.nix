{ lib
, buildNpmPackage
, fetchFromGitHub
, fetchurl
, nodejs_22
, nodejs-slim_22
, diffutils
, makeSetupHook
, writeText
, jq
, prefetch-npm-deps
, pkg-config
, python3
, removeReferencesTo
, cacert
, cairo
, freetype
, fontconfig
, giflib
, libjpeg
, libpng
, pango
, pixman
, srcOnly
, stdenv
, path
, ... }:

let
  nodejs = nodejs_22;
  diffutilsNoCheck = diffutils.overrideAttrs (_: { doCheck = false; });
  piNpmConfigHook = makeSetupHook {
    name = "pi-npm-config-hook";
    substitutions = {
      nodeSrc = srcOnly nodejs;
      nodeGyp = "${nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js";
      npmArch = stdenv.targetPlatform.node.arch;
      npmPlatform = stdenv.targetPlatform.node.platform;

      diff = "${diffutilsNoCheck}/bin/diff";
      jq = "${jq}/bin/jq";
      prefetchNpmDeps = "${prefetch-npm-deps}/bin/prefetch-npm-deps";
    };
  } (writeText "pi-npm-config-hook.sh" (builtins.replaceStrings
    [ "npm_config_offline=\"true\"" ]
    [ "npm_config_offline=\"false\"" ]
    (builtins.readFile "${path}/pkgs/build-support/node/build-npm-package/hooks/npm-config-hook.sh")
  ));
  version = "1.1.0";
  piNpmDepsHash = "sha256-GOh5WG+rRgzoy/yVHY5PoEKJZGQcEGhISrDDJxkP8W4=";
  src = fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    rev = "v${version}";
    hash = "sha256-lwjspkMGrW+8Fl/yBEDEFsHZJA57OKOhmVQmi6zfej4=";
  };
  piAiRelease = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${version}.tgz";
    hash = "sha256-bKqzPOxXSA7QLFf+N0KKAwp3zCoGYoFLQ1pc+JMq2Ck=";
  };
in
buildNpmPackage {
  pname = "pi-coding-agent";
  inherit version src;
  inherit nodejs;

  patches = [ ./pi-coding-agent/retry-anthropic-extra-usage.patch ];

  npmDepsHash = piNpmDepsHash;
  makeCacheWritable = true;
  npmInstallFlags = [
    "--offline=false"
    "--legacy-peer-deps"
  ];
  npmConfigHook = piNpmConfigHook;

  postPatch = ''
    if [ ! -f packages/coding-agent/CHANGELOG.md ]; then
      touch packages/coding-agent/CHANGELOG.md
    fi
    mkdir -p packages/ai/src/providers/data
    tar -xzf ${piAiRelease} \
      -C packages/ai/src/providers/data \
      --strip-components=4 \
      package/dist/providers/data
  '';

  nativeBuildInputs = [ pkg-config python3 removeReferencesTo ];
  buildInputs = [ cairo freetype fontconfig giflib libjpeg libpng pango pixman ];

  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    packageOut="$out/lib/node_modules/@earendil-works/pi-coding-agent"
    mkdir -p "$packageOut"
    cp -R packages/coding-agent/. "$packageOut"

    pushd packages/coding-agent >/dev/null
    nodejsInstallExecutables package.json
    nodejsInstallManuals package.json
    popd >/dev/null
    substituteInPlace "$out/bin/pi" \
      --replace-fail "${nodejs}/bin/node" "${nodejs-slim_22}/bin/node"

    mkdir -p "$packageOut/node_modules"
    cp -R node_modules/. "$packageOut/node_modules/"

    bash ${./pi-coding-agent/install-workspaces.sh} "$packageOut"

    find "$packageOut/node_modules" -xtype l -delete

    # Keep only the native add-ons from node-gyp's build trees. Object files,
    # archives and make metadata retain the compiler, SDK and Node sources.
    find "$packageOut/node_modules" -type f \( \
      -name '*.o' -o \
      -name '*.a' -o \
      -name '*.mk' -o \
      -name 'Makefile' -o \
      -name 'config.gypi' \
    \) -delete
    find "$packageOut/node_modules" -type f -path '*/build/Release/*.node' -exec strip -S {} +

    # node-gyp leaves the Node source path in native-addon build metadata.
    # It is not needed at runtime and otherwise retains about 482 MiB.
    # Only touch files that contain the path: per-file re-signing on Darwin is
    # slow across the ~33k files in node_modules.
    { grep -rlFZ "${srcOnly nodejs}" "$out" || true; } | xargs -0r remove-references-to -t "${srcOnly nodejs}"

    runHook postInstall
  '';

  postFixup = ''
    while IFS= read -r file; do
      substituteInPlace "$file" \
        --replace-fail "${nodejs}/bin/node" "${nodejs-slim_22}/bin/node"
    done < <(grep -IlrF "${nodejs}/bin/node" "$out")
    { grep -rlFZ "${nodejs}" "$out" || true; } | xargs -0r remove-references-to -t "${nodejs}"
  '';

  # Upstream's root offline build compiles every workspace in order and uses
  # the model data unpacked from the pi-ai release in postPatch.
  npmBuildScript = "build:offline";

  passthru.runtimeNode = nodejs-slim_22;

  env = {
    CI = "1";
    HUSKY = "0";
    NODE_ENV = "development";
    npm_config_production = "false";
    NPM_CONFIG_CAFILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    NODE_EXTRA_CA_CERTS = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  meta = with lib; {
    description = "Terminal-based coding agent CLI";
    homepage = "https://github.com/earendil-works/pi";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "pi";
  };
}
