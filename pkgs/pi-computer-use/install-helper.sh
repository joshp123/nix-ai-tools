install -d "$helper/Applications"
cp -R "$out/share/pi/packages/pi-computer-use/prebuilt/macos/universal/pi-computer-use.app" \
  "$helper/Applications/pi-computer-use.app"
install -d "$helper/bin"
ln -s "$helper/Applications/pi-computer-use.app/Contents/MacOS/bridge" \
  "$helper/bin/pi-computer-use-bridge"
