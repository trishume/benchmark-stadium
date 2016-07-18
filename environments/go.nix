with import <nixpkgs> {};
import ./base.nix {
  buildInputs = [go];
  compileScript = ''
    go build -o $binFile $inFile
  '';
  runScript = ''
    ./$binFile
  '';
}
