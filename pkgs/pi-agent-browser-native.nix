{ lib, callPackage, pi-coding-agent }:

((callPackage ./pi-package.nix {
  inherit pi-coding-agent;
}) rec {
  pname = "pi-agent-browser-native";
  version = "0.5.0";
  url = "https://registry.npmjs.org/pi-agent-browser-native/-/pi-agent-browser-native-${version}.tgz";
  hash = "sha256-HlpqO7S13slSnsfq8ziPwLmxq2vfWl05WT5/ZBqJdoc=";
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
