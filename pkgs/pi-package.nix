{ lib
, stdenvNoCC
, fetchurl
, makeWrapper
, importNpmLock
, nodejs_22
, nodejs-slim_22
, pi-coding-agent
}:
{ pname
, version
, url
, hash
, packageName ? pname
, binEntries ? []
, meta
, ...
}@args:

let
  # Runtime npm dependencies are pinned in pkgs/<pname>/package-lock.json,
  # written by scripts/pi-package-lock.sh (auto-bump reruns it on every bump).
  npmLockFile = ./. + "/${pname}/package-lock.json";
  npmLock = lib.optionalAttrs (builtins.pathExists npmLockFile) (lib.importJSON npmLockFile);
  npmDependencies = npmLock.packages."".dependencies or { };
  hasNpmDependencies = npmDependencies != { };
in
stdenvNoCC.mkDerivation (removeAttrs args [ "url" "hash" "packageName" ] // {
  src = fetchurl { inherit url hash; };
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ] ++ lib.optional hasNpmDependencies nodejs_22;

  piPackageName = packageName;
  piPeerNodeModules = "${pi-coding-agent}/lib/node_modules/@earendil-works/pi-coding-agent/node_modules";
  piNpmDependencies = builtins.toJSON npmDependencies;
  piNpmDeps = lib.optionalString hasNpmDependencies (importNpmLock {
    package = { inherit (npmLock.packages."") name version; dependencies = npmDependencies; };
    packageLock = npmLock;
  });
  inherit binEntries;
  runtimeNode = nodejs-slim_22;

  installPhase = builtins.readFile ./pi-package/install.sh;

  # Publish only extensions Pi can load: building is not enough.
  doInstallCheck = true;
  piBin = "${pi-coding-agent}/bin/pi";
  installCheckPhase = builtins.readFile ./pi-package/install-check.sh;
})
