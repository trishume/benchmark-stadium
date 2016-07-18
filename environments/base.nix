{buildInputs, compileScript ? null, runScript ? null}:
let
extraInps = buildInputs;
scriptVars = ''
  local inFile="$1"
  local fileName="$(basename $inFile)"
  local extension="''${fileName##*.}"
  local binFile="''${fileName%.*}_$extension"
'';
compileFn = ''
  compile() {
    ${scriptVars}
    ${compileScript}
  }
'';
runFn = ''
  run() {
    ${scriptVars}
    ${runScript}
  }
'';
in
with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "benchmark-stadium";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = extraInps;
  COMPILE_SCRIPT = compileScript;
  RUN_SCRIPT = runScript;
  shellHook = ''
    ${if compileScript != null then compileFn else ""}
    ${if runScript != null then runFn else ""}
  '';
}
