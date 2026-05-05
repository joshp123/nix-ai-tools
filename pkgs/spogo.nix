{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "spogo";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "steipete";
    repo = "spogo";
    rev = "v${version}";
    hash = "sha256-zKoc8TmIhFD1KdyzQVYxNdBXobwuISYKnvuXfTNA5PI=";
  };

  vendorHash = "sha256-aUMu71ZIjM+87vneKNRXuaFZCW5IB5d2jAey/1itqYM=";

  subPackages = [ "cmd/spogo" ];
}
