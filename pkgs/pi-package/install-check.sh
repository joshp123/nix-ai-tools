runHook preInstallCheck

package_dir="$out/share/pi/packages/$piPackageName"

# Pi loads a package vacuously when a declared extension entry is missing, so
# when the manifest declares pi.extensions, every entry must exist. Packages
# that rely on Pi's conventional directories declare nothing and skip this.
"$runtimeNode/bin/node" -e '
  const fs = require("fs");
  const path = require("path");
  const dir = process.argv[1];
  const manifest = require(path.join(dir, "package.json"));
  const entries = (manifest.pi && manifest.pi.extensions) || [];
  for (const entry of entries) {
    if (!fs.existsSync(path.join(dir, entry))) {
      console.error(`error: ${process.env.pname} declares extension ${entry} but it is missing`);
      process.exit(1);
    }
  }
' "$package_dir"

# Load the extension the way Pi does at startup. RPC mode loads extensions,
# needs no model or API key, and exits when stdin closes; a load failure
# exits non-zero. --offline skips startup network calls.
HOME="$TMPDIR" "$piBin" --offline --no-session \
  --no-extensions --no-skills --no-prompt-templates --no-themes --no-context-files \
  --extension "$package_dir" \
  --mode rpc </dev/null

runHook postInstallCheck
