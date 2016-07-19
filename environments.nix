with import <nixpkgs> {};
let
compileScript = {langName, script, compilerInputs}:
  let
    langBuilder = writeScript "bench-stad-builder-${langName}.sh" ''
      source $stdenv/setup
      ${script}
    '';
  in
  {benchmarkName, file}: stdenv.mkDerivation {
    name = "bench-stad-${langName}-${benchmarkName}";
    inherit benchmarkName;
    buildInputs = compilerInputs;
    builder = langBuilder;
    src = file;
  };
identityCompiler = langName: compileScript {
  inherit langName;
  script = "cp $src $out";
  compilerInputs = [];
};
# runnerScript = {script, compiler}: {benchmarkName, file}: writeScript "runner-${langName}.sh" ''
#   runFile="${file}"
#   ${script}
# '';
# binaryRunner =
in
rec {
  compileRuby = identityCompiler "ruby";
  compileGo = compileScript {
    langName = "go";
    script = "go build -o $out $src";
    compilerInputs = [go];
  };
  # runGo = binaryRunner compileGo;
}
