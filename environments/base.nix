{buildInputs}:
let
extraInps = buildInputs;
in
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "benchmark-stadium";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = extraInps;
}
