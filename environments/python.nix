with import <nixpkgs> {};
import ./base.nix {
  buildInputs = [python];
}
