runHook preInstall

install -Dm755 "$src" "$out/bin/herdr"
install -Dm644 "$piIntegration" \
  "$out/share/herdr/integrations/pi/herdr-agent-state.ts"

runHook postInstall
