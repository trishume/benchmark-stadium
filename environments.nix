with import <nixpkgs> {};
let
timerScript = "${time}/bin/time";
buildScript = {langName, compileScript ? null, runScript ? null}:
  assert ((compileScript != null) || (runScript != null));
  let
    compileScriptText = callPackage compileScript {};
    langBuilder = writeScript "bench-build-${langName}.sh" ''
      source $stdenv/setup
      mkdir -p $out/bin
      runFile=$out/bin/run
      ${compileScriptText}
    '';
  in
    args@{programName, src, extraFlags ? "", ...}:
    let
      buildDrv = stdenv.mkDerivation {
        name = "bench-build-${langName}-${programName}";
        inherit programName src extraFlags;
        builder = langBuilder;
      };
      runScriptText = newScope ({
        runFile = if compileScript != null then "${buildDrv}" else src;
      } // args) runScript {};
      runText = if runScript != null then runScriptText else builtRunProduct;
    in
      writeScript "bench-run-${langName}-${programName}" ''
        #!/bin/sh
        ${if compileScript != null then "cd ${buildDrv}" else ""}
        exec ${timerScript} ${runText}
    '';
copyCompile = outFile: {}: "cp $src $out/${outFile}";
in
rec {
  ruby = buildScript {
    langName = "ruby";
    runScript = {ruby,runFile}: "${ruby}/bin/ruby \"${runFile}\" \"$@\"";
  };
  python = buildScript {
    langName = "python";
    runScript = {python,runFile}: "${python}/bin/python \"${runFile}\" \"$@\"";
  };
  nodejs = buildScript {
    langName = "nodejs";
    runScript = {nodejs,runFile}: "${nodejs}/bin/node \"${runFile}\" \"$@\"";
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
    runScript = {mono,runFile}: "${mono}/bin/mono -O=all --gc=sgen \"${runFile}/run.exe\" \"$@\"";
  };
  scala = buildScript {
    langName = "scala";
    compileScript = {scala}: "${scala}/bin/scalac -optimize $extraFlags -d $out $src";
    runScript = {scala,runClass}: "${scala}/bin/scala -J-Xss100m ${runClass} \"$@\"";
  };
}
