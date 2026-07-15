runHook preInstall

install -Dm755 "$src" "$out/bin/agent-browser"

runHook postInstall
