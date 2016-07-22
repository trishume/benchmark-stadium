with import <nixpkgs> {};
let
timerScript = "${time}/bin/time";
buildScript = {langName, compileScript, runScript ? null, runSetup ? ""}:
  let
    runScriptText = callPackage runScript {};
    compileScriptText = callPackage compileScript {};
    langRunner = writeScript "bench-stad-run-${langName}.sh" ''
      #!/bin/sh
      cd `dirname $0`/../
      ${runSetup}
      exec ${timerScript} ${runScriptText}
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
  {programName, src, extraFlags ? ""}: stdenv.mkDerivation {
    name = "bench-stad-${langName}-${programName}";
    inherit programName src extraFlags;
    builder = langBuilder;
  };
copyCompile = outFile: {}: "cp $src $out/${outFile}";
in
rec {
  ruby = buildScript {
    langName = "ruby";
    compileScript = copyCompile "run.rb";
    runScript = {ruby}: "${ruby}/bin/ruby $extraFlags run.rb \"$@\"";
  };
  python = buildScript {
    langName = "python";
    compileScript = copyCompile "run.py";
    runScript = {python}: "${python}/bin/python $extraFlags run.py \"$@\"";
  };
  nodejs = buildScript {
    langName = "nodejs";
    compileScript = copyCompile "run.js";
    runScript = {nodejs}: "${nodejs}/bin/node $extraFlags run.js \"$@\"";
  };
  go = buildScript {
    langName = "go";
    compileScript = {go}: "${go}/bin/go build $extraFlags -o $runFile $src";
  };
  gccgo = buildScript {
    langName = "gccgo";
    compileScript = {gccgo}: "${gccgo}/bin/gccgo -O3 $extraFlags -o $runFile $src";
  };
  dmd = buildScript {
    langName = "dmd";
    # D doesn't like the hashes in Nix file paths, so we need to copy it to something with a nice file name
    compileScript = {dmd}: ''
      cp $src ./bench.d
      ${dmd}/bin/dmd -O -release -inline $extraFlags -of$runFile ./bench.d
    '';
  };
  gcc-cpp = buildScript {
    langName = "g++";
    compileScript = {gcc}: "${gcc}/bin/g++ -O3 $extraFlags -o $runFile $src";
  };
  clang-cpp = buildScript {
    langName = "clang++";
    compileScript = {clang}: "${clang}/bin/clang++ -O3 $extraFlags -o $runFile $src";
  };
  nim-clang = buildScript {
    langName = "nim-clang";
    compileScript = {nim,clang}: ''
      PATH=${clang}/bin:$PATH
      cp $src ./bench.nim
      ${nim}/bin/nim c -d:release --cc:clang $extraFlags -o:$runFile ./bench.nim
    '';
  };
  mono = buildScript {
    langName = "mono";
    compileScript = {mono}: "${mono}/bin/mcs -debug- -optimize+ $extraFlags -out:$out/run.exe $src";
    runScript = {mono}: "${mono}/bin/mono -O=all --gc=sgen run.exe \"$@\"";
  };
  scala = buildScript {
    langName = "scala";
    compileScript = {scala}: "${scala}/bin/scalac -optimize $extraFlags -d $out $src";
    runSetup = ''
      runClassFile=$(ls | grep -F App.class)
      runClass=''${runClassFile%.class}
    '';
    runScript = {scala}: "${scala}/bin/scala -J-Xss100m $runClass \"$@\"";
  };
}
