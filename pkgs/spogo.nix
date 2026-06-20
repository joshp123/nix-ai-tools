{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "spogo";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "steipete";
    repo = "spogo";
    rev = "v${version}";
    hash = "sha256-hzgDjpxQCzJTy6jabjvS3vV+lavg3dGweLJ8/KE8rFU=";
  };

  vendorHash = "sha256-aUMu71ZIjM+87vneKNRXuaFZCW5IB5d2jAey/1itqYM=";

  subPackages = [ "cmd/spogo" ];
}
