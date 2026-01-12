{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "spogo";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "steipete";
    repo = "spogo";
    rev = "v${version}";
    hash = "sha256-54l4hn9wm+AVGWpWZuIXQXBaNDVndDMVGKtRsQDp3iE=";
  };

  vendorHash = "sha256-ROlOn/55as4EBKqQr/wP5cVo1EBS4LnbHrrxCKF6VjU=";

  subPackages = [ "cmd/spogo" ];
}
