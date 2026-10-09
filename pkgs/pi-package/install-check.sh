runHook preInstallCheck

# Load the extension the way Pi does at startup. RPC mode loads extensions,
# needs no model or API key, and exits when stdin closes; a load failure
# exits non-zero. --offline skips startup network calls.
HOME="$TMPDIR" "$piBin" --offline --no-session \
  --no-extensions --no-skills --no-prompt-templates --no-themes --no-context-files \
  --extension "$out/share/pi/packages/$piPackageName" \
  --mode rpc </dev/null

runHook postInstallCheck
