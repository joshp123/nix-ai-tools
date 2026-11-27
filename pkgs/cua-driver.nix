{ lib
, stdenvNoCC
, fetchurl
}:

# CuaDriver.app is Developer ID signed, notarized and stapled; any change to a
# Mach-O breaks the signature, so it is copied byte-for-byte with no fixup.
# The skill pack's tool schemas track the binary, so both assets share one
# version. Driver releases are GitHub pre-releases: auto-bump passes the newest
# cua-driver-rs-v* tag explicitly and refreshes the skills hash itself.
let
  version = "0.64.2";
  releaseUrl = "https://github.com/trycua/cua/releases/download/cua-driver-rs-v${version}";
  skills = fetchurl {
    url = "${releaseUrl}/cua-driver-rs-v${version}-skills.tar.gz";
    hash = "sha256-QFgSH1FklQg/+rLz2W2+lDg7mPsS8oNG/bmddXscIAA=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "cua-driver";
  inherit version skills;

  src = fetchurl {
    url = "${releaseUrl}/cua-driver-rs-${version}-darwin-arm64.tar.gz";
    hash = "sha256-84ceoqxiopHAz0st/6uW0T1CbRWygtnlPETPboMNh3U=";
  };

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;
  dontStrip = true;

  installPhase = builtins.readFile ./cua-driver/install.sh;

  doInstallCheck = true;
  installCheckPhase = builtins.readFile ./cua-driver/install-check.sh;

  meta = with lib; {
    description = "Background computer-use driver for native macOS apps, with its agent skill";
    homepage = "https://github.com/trycua/cua";
    license = licenses.mit;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "cua-driver";
  };
}
