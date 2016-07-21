with import <nixpkgs> {};
let
buildScript = {langName, compileScript, runScript ? null}:
  let
    runScriptText = callPackage runScript {};
    compileScriptText = callPackage compileScript {};
    langRunner = writeScript "bench-stad-run-${langName}.sh" ''
      #!/bin/sh
      cd `dirname $0`/../
      exec ${runScriptText}
    '';
    addRunner = if runScript != null then
        "ln -s ${langRunner} $runFile"
      else "";
    langBuilder = writeScript "bench-stad-build-${langName}.sh" ''
      source $stdenv/setup
      mkdir -p $out/bin
      runFile=$out/bin/run
      ${compileScriptText}
      ${addRunner}
    '';
  in
  {programName, file}: stdenv.mkDerivation {
    name = "bench-stad-${langName}-${programName}";
    inherit programName;
    builder = langBuilder;
    src = file;
  };
copyCompile = outFile: {}: "cp $src $out/${outFile}";
in
rec {
  ruby = buildScript {
    langName = "ruby";
    compileScript = copyCompile "run.rb";
    runScript = {ruby}: "${ruby}/bin/ruby run.rb \"$@\"";
  };
  python = buildScript {
    langName = "python";
    compileScript = copyCompile "run.py";
    runScript = {python}: "${python}/bin/python run.py \"$@\"";
  };
  go = buildScript {
    langName = "go";
    compileScript = {go}: "${go}/bin/go build -o $runFile $src";
  };
  # runGo = binaryRunner compileGo;
}
