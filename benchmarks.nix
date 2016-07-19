# TODO auto-generate this file
let
envs = import ./environments.nix;
in
{
  havlak = {
    go = envs.compileGo {
      benchmarkName = "havlak";
      file = ./benchmarks/kostya/havlak/havlak.go;
    };
  };
}
