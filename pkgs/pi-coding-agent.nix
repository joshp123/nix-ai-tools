{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs_22
, diffutils
, makeSetupHook
, writeText
, jq
, prefetch-npm-deps
, pkg-config
, python3
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
  version = "0.80.3";
  piNpmDepsHash = "sha256-geh8LH88OZybFXkR/jDeTdew6TNMdFM6jhCSYKn//dU=";
  src = fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    rev = "v${version}";
    hash = "sha256-wQTrWKsb2HCGwzSAFEk8NWSDpqxSY/lv1/R6ghcmbaA=";
  };
in
buildNpmPackage {
  pname = "pi-coding-agent";
  inherit version src;
  inherit nodejs;

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
  '';

  nativeBuildInputs = [ pkg-config python3 ];
  buildInputs = [ cairo freetype fontconfig giflib libjpeg libpng pango pixman ];

  preBuild = ''
    python3 ${./pi-coding-agent/prepare-ai-build.py}
    npm run build -w @earendil-works/pi-tui
    npm run build -w @earendil-works/pi-ai
    npm run build -w @earendil-works/pi-agent-core
  '';

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

    mkdir -p "$packageOut/node_modules"
    cp -R node_modules/. "$packageOut/node_modules/"

    rm -rf "$packageOut/node_modules/@earendil-works/pi-mom"
    rm -rf "$packageOut/node_modules/@earendil-works/pi-proxy"
    rm -rf "$packageOut/node_modules/@earendil-works/pi-web-ui"
    rm -rf "$packageOut/node_modules/@earendil-works/pi"

    rm -rf "$packageOut/node_modules/@earendil-works/pi-ai"
    rm -rf "$packageOut/node_modules/@earendil-works/pi-agent-core"
    rm -rf "$packageOut/node_modules/@earendil-works/pi-tui"
    rm -rf "$packageOut/node_modules/@earendil-works/pi-coding-agent"

    cp -R packages/ai "$packageOut/node_modules/@earendil-works/pi-ai"
    cp -R packages/agent "$packageOut/node_modules/@earendil-works/pi-agent-core"
    cp -R packages/tui "$packageOut/node_modules/@earendil-works/pi-tui"
    cp -R packages/coding-agent "$packageOut/node_modules/@earendil-works/pi-coding-agent"

    find "$packageOut/node_modules" -xtype l -delete

    runHook postInstall
  '';

  npmWorkspace = "packages/coding-agent";
  npmBuildScript = "build";

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
