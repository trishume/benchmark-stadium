# TODO auto-generate this file
let
envs = import ./environments.nix;
in
{
  havlak = {
    go = envs.go {
      programName = "havlak";
      file = ./benchmarks/kostya/havlak/havlak.go;
    };
    python = envs.python {
      programName = "havlak";
      file = ./benchmarks/kostya/havlak/havlak.py;
    };
  };
}
