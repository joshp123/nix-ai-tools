{ lib, stdenv, fetchFromGitHub, fetchurl, makeWrapper, nodejs_22, curl, git }:

let
  smaugSrc = fetchFromGitHub {
    owner = "alexknowshtml";
    repo = "smaug";
    rev = "180925814bc2076091bcfe7dcbf67c20045c4c90";
    hash = "sha256-DVQ4+zO6rtNc1XmwDCiocvo/C03NsJBa2KSga6fTRbo=";
  };
  dayjsSrc = fetchurl {
    url = "https://registry.npmjs.org/dayjs/-/dayjs-1.11.10.tgz";
    hash = "sha256-m7J05ha6A4B7i/Emv0r1t4AEUk6Cx1W/L41NpSeebQE=";
  };
  smaugRoot = "$HOME/code/knowledge/twitter-bookmarks";
  smaugLink = "$HOME/.clawdbot/workspace/bookmarks/smaug";

  smaug = stdenv.mkDerivation (finalAttrs: {
    pname = "smaug";
    version = "0.1.0";
    src = smaugSrc;

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/smaug $out/bin $out/lib/smaug/node_modules
      cp -R . $out/lib/smaug/
      tar -xzf ${dayjsSrc} -C $out/lib/smaug/node_modules
      mv $out/lib/smaug/node_modules/package $out/lib/smaug/node_modules/dayjs

      makeWrapper ${nodejs_22}/bin/node $out/bin/smaug \
        --add-flags "$out/lib/smaug/src/cli.js" \
        --prefix PATH : ${curl}/bin
      runHook postInstall
    '';

    meta = with lib; {
      description = "Archive Twitter/X bookmarks to markdown with categorization";
      homepage = "https://github.com/alexknowshtml/smaug";
      license = licenses.mit;
      platforms = platforms.unix;
      mainProgram = "smaug";
    };
  });

  smaug-clawdbot = stdenv.mkDerivation {
    name = "smaug-clawdbot";
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      cat > "$out/bin/smaug-clawdbot" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
PATH="${git}/bin:$PATH"

root="${""}"{SMAUG_ROOT:-${smaugRoot}}"
link="${""}"{SMAUG_LINK:-${smaugLink}}"

creds_file="$HOME/.clawdbot/credentials/smaug.env"
if [ -f "$creds_file" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$creds_file"
  set +a
fi

mkdir -p "$root/.state" "$root/knowledge/tools" "$root/knowledge/articles" "$root/knowledge/podcasts" "$root/knowledge/videos"

if [ ! -L "$link" ]; then
  if [ -e "$link" ]; then
    echo "smaug-clawdbot: $link exists and is not a symlink" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$link")"
  ln -s "$root" "$link"
fi

if [ ! -d "$root/.git" ]; then
  git init -q "$root" || true
  if [ ! -f "$root/.gitignore" ]; then
    printf '%s\n' ".state/" "smaug.config.json" > "$root/.gitignore"
  fi
fi

export ARCHIVE_FILE="$root/bookmarks.md"
export PENDING_FILE="$root/.state/pending-bookmarks.json"
export STATE_FILE="$root/.state/bookmarks-state.json"
export PROJECT_ROOT="$root"

cd "$root"
exec ${smaug}/bin/smaug "$@"
SCRIPT
      chmod +x "$out/bin/smaug-clawdbot"
      runHook postInstall
    '';

    meta = with lib; {
      description = "Wrapper for running smaug with Clawdbot paths";
      platforms = platforms.unix;
      mainProgram = "smaug-clawdbot";
    };
  };

in {
  inherit smaug smaug-clawdbot;
}
