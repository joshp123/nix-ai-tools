runHook preInstallCheck

# Never execute anything inside $out/Applications/CuaDriver.app here: running a
# Mach-O in a notarized bundle makes macOS App Management protect the bundle,
# and Nix then cannot canonicalise the output. Its CLI also cannot run outside
# the bundle (its entitlements need the embedded provisioning profile). So run
# the release's loose CLI, check the bundle's declared version, and verify the
# bundle's signature.
expected="cua-driver $version"
actual=$(./cua-driver --version)
if [[ "$actual" != "$expected" ]]; then
  echo "loose CLI: expected '$expected', got '$actual'" >&2
  exit 1
fi
app="$out/Applications/CuaDriver.app"
bundle_version=$(/usr/bin/plutil -extract CFBundleShortVersionString raw "$app/Contents/Info.plist")
if [[ "$bundle_version" != "$version" ]]; then
  echo "CuaDriver.app: expected version $version, got $bundle_version" >&2
  exit 1
fi
/usr/bin/codesign --verify --deep --strict "$app"
test -s "$out/share/cua-driver/skills/cua-driver/SKILL.md"

runHook postInstallCheck
