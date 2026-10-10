runHook preInstall

mkdir -p "$out/Applications" "$out/bin" "$out/share/cua-driver/skills/cua-driver"
cp -R CuaDriver.app "$out/Applications/CuaDriver.app"
ln -s "$out/Applications/CuaDriver.app/Contents/MacOS/cua-driver" "$out/bin/cua-driver"
tar -xzf "$skills" --strip-components=1 -C "$out/share/cua-driver/skills/cua-driver"

runHook postInstall
