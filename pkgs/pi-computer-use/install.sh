runHook preInstall

package_dir="$out/share/pi/packages/pi-computer-use"
install -d "$package_dir"
tar -xzf "$src" --strip-components=1 -C "$package_dir"

install -d "$package_dir/node_modules"
ln -s "$piPeerNodeModules/@earendil-works" "$package_dir/node_modules/@earendil-works"
ln -s "$piPeerNodeModules/typebox" "$package_dir/node_modules/typebox"

install -d "$helper/Applications"
cp -R "$package_dir/prebuilt/macos/universal/pi-computer-use.app" \
  "$helper/Applications/pi-computer-use.app"
install -d "$helper/bin"
ln -s "$helper/Applications/pi-computer-use.app/Contents/MacOS/bridge" \
  "$helper/bin/pi-computer-use-bridge"

runHook postInstall
