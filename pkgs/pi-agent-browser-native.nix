{ lib, callPackage, pi-coding-agent }:

((callPackage ./pi-package.nix {
  inherit pi-coding-agent;
}) rec {
  pname = "pi-agent-browser-native";
  version = "0.6.9";
  url = "https://registry.npmjs.org/pi-agent-browser-native/-/pi-agent-browser-native-${version}.tgz";
  hash = "sha256-ycH7pA/Kp5eSvXidc1utLRC3SuBt2U2Z+x4R/fDY4Qk=";
  binEntries = [
    "pi-agent-browser-config:scripts/config.mjs"
    "pi-agent-browser-doctor:scripts/doctor.mjs"
  ];

  meta = with lib; {
    description = "Native Pi extension for agent-browser automation";
    homepage = "https://github.com/fitchmultz/pi-agent-browser-native";
    license = licenses.mit;
    platforms = platforms.unix;
  };
})
