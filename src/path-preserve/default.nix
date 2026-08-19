{
  stdenvNoCC,
  lib,
  makeWrapper,
  installShellFiles,
  shellcheck,
}:

{
  pname,
  version ? "0.1.0",
  script,
  tools ? [ ],
  shimmed ? [ ],
  extraWrap ? "",
  extraInstall ? "",
}:

let
  # For each shimmed tool, capture its (Nix store) path and shadow it with a
  # function that re-invokes the store binary with the caller's original PATH.
  shimPreamble = lib.concatMapStrings (
    tool:
    let
      var = builtins.replaceStrings [ "-" ] [ "_" ] tool;
    in
    ''
      _${var}="$(command -v ${tool})"
      ${tool}() {
        PATH="''${CURRENT_PATH:-"$PATH"}" "$_${var}" "$@"
      }
    ''
  ) shimmed;
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  doCheck = true;
  nativeCheckInputs = [ shellcheck ];

  buildPhase = ''
    {
      echo '#!/usr/bin/env bash'
      cat ${builtins.toFile "shim-preamble.sh" shimPreamble}
      tail -n +2 ${script}
    } > ${pname}
    chmod +x ${pname}
    patchShebangs ${pname}
  '';

  checkPhase = ''
    shellcheck ${pname}
  '';

  installPhase = ''
    install -Dm755 ${pname} $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --run 'export CURRENT_PATH="$PATH"' \
      ${extraWrap} \
      --set PATH ${lib.makeBinPath tools}
    ${extraInstall}
  '';
}
