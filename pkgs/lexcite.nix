{ buildGoModule
, lib
, stdenv
}:

let
  version = "unstable-2026-04-04";
  lawbotHubSrc = builtins.path {
    path = /Users/josh/code/lawbot-hub/services/lexcite;
    name = "lexcite-source";
  };
  piGolangSrc = builtins.path {
    path = /Users/josh/code/pi-golang;
    name = "pi-golang-source";
  };
in
buildGoModule {
  pname = "lexcite";
  inherit version;

  src = lawbotHubSrc;

  tags = [ "usearch" ];
  subPackages = [ "cmd/lexcite" ];
  vendorHash = "sha256-og2fjGdC07NyRDj7mE/WjKZO2x7sqwPJLzqcs86+UYw=";

  postPatch = ''
    cp -R ${piGolangSrc} ./third_party/pi-golang
    chmod -R u+w ./third_party/pi-golang
    substituteInPlace go.mod \
      --replace-fail '../../../pi-golang' './third_party/pi-golang'
  '';

  postInstall = ''
    mkdir -p "$out/lib"
    cp ./third_party/usearch/golang/libusearch_c.dylib "$out/lib/"
    chmod 555 "$out/lib/libusearch_c.dylib"
    install_name_tool -delete_rpath "$(otool -l "$out/bin/lexcite" | awk '/LC_RPATH/{getline; getline; print $2; exit}')" "$out/bin/lexcite"
    install_name_tool -add_rpath "$out/lib" "$out/bin/lexcite"
  '';

  env.CGO_ENABLED = 1;

  meta = with lib; {
    description = "LexCite research plane server for Lawbot";
    homepage = "https://github.com/joshp123/lawbot-hub";
    license = licenses.mit;
    platforms = platforms.darwin;
    mainProgram = "lexcite";
  };
}
