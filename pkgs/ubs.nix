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
  rev = "5fadcc302a82ad627d6fcd1d3296b24959c56f99";
  shortRev = builtins.substring 0 7 rev;
  version = "unstable-${shortRev}";
  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "ultimate_bug_scanner";
    rev = rev;
    hash = "sha256-HVrT0NnusftT1/Lr3YrZF0f2wFha4it8CWupOZ9C4RM=";
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
