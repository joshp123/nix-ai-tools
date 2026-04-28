{ lib
, stdenvNoCC
, fetchFromGitHub
, makeWrapper
, ast-grep
, coreutils
, curl
, findutils
, gawk
, gnused
, git
, jq
, ripgrep
}:

let
  rev = "9a48773847ea37c29c2802dd826f8226181dcd42";
  shortRev = builtins.substring 0 7 rev;
  version = "unstable-${shortRev}";
  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "ultimate_bug_scanner";
    rev = rev;
    hash = "sha256-MWQnmK1weeQN5H0wI1lU8WE9KU9Z6DaPVqfttVD9p3c=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "ubs";
  inherit version src;

  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 ubs $out/libexec/ubs/ubs
    install -d $out/libexec/ubs/modules
    install -m755 modules/ubs-*.sh $out/libexec/ubs/modules/

    makeWrapper $out/libexec/ubs/ubs $out/bin/ubs \
      --set UBS_NO_AUTO_UPDATE 1 \
      --prefix PATH : ${lib.makeBinPath [
        ast-grep
        coreutils
        curl
        findutils
        gawk
        gnused
        git
        jq
        ripgrep
      ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Ultimate Bug Scanner: fast bug-finding assistant for coding agents";
    homepage = "https://github.com/Dicklesworthstone/ultimate_bug_scanner";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "ubs";
  };
}
