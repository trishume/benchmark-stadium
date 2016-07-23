# Benchmark Stadium

A collection of programming language benchmarks from various sources combined with scripts to run them and analyze the results.
Still very much a work in progress.

Currently contains some fancy [Nix](http://nixos.org/) files for deterministically building benchmark scripts in a variety of languages and wrap
all of them in a uniform runner interface so you can just directly run the built product and it will run the benchmark, regardless of the language
including if the language is interpreted or compiled. See `environments.nix` and `benchmarks.nix`.

## Current Sources
See the `LICENSE` files in the directories for the license of the files in that directory.

- <http://benchmarksgame.alioth.debian.org/> in `benchmarks/game` (revised BSD license)
- <https://github.com/kostya/benchmarks> in `benchmarks/kostya` (MIT license)
