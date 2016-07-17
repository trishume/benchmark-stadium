with import <nixpkgs> {};
import ./base.nix {
  buildInputs = [mono];
}
