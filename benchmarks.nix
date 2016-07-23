# TODO auto-generate this file
let
envs = import ./environments.nix;
in
{
  havlak = {
    go = envs.go {
      programName = "havlak";
      src = ./benchmarks/kostya/havlak/havlak.go;
    };
    gccgo = envs.gccgo {
      programName = "havlak";
      src = ./benchmarks/kostya/havlak/havlak.go;
    };
    python = envs.python {
      programName = "havlak";
      src = ./benchmarks/kostya/havlak/havlak.py;
    };
    dmd = envs.dmd {
      programName = "havlak";
      src = ./benchmarks/kostya/havlak/havlak.d;
    };
    mono = envs.mono {
      programName = "havlak";
      src = ./benchmarks/kostya/havlak/havlak.cs;
    };
    scala = envs.scala {
      programName = "havlak";
      src = ./benchmarks/kostya/havlak/havlak.scala;
      runClass = "LoopTesterApp";
    };
    gcc-cpp = envs.gcc-cpp {
      programName = "havlak";
      src = ./benchmarks/kostya/havlak/havlak.cpp;
    };
    gcc-cpp-noopt = envs.gcc-cpp {
      programName = "havlak";
      src = ./benchmarks/kostya/havlak/havlak.cpp;
      extraFlags = "-O0";
    };
    clang-cpp = envs.clang-cpp {
      programName = "havlak";
      src = ./benchmarks/kostya/havlak/havlak.cpp;
    };
    nim-clang = envs.nim-clang {
      programName = "havlak";
      src = ./benchmarks/kostya/havlak/havlak.nim;
    };
  };
}
