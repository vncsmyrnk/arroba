{
  stdenvNoCC,
  lib,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "sops-edit";
  version = "0.1.0";

  src = ./.;
  nativeBuildInputs = with pkgs; [
    installShellFiles
    makeWrapper
  ];

  doCheck = true;
  checkInputs = with pkgs; [ shellcheck ];
  checkPhase = ''
    shellcheck ${./script.sh}
  '';

  installPhase = ''
    patchShebangs .
    install -Dm755 ${./script.sh} $out/bin/sops-edit
    wrapProgram $out/bin/sops-edit \
      --run 'export CURRENT_PATH="$PATH"' \
      --run 'export CONFIG_PATH="''${CONFIG_PATH:-$HOME/.config/utilities/sops}"' \
      --set PATH ${
        lib.makeBinPath [
          pkgs.sops
          pkgs.gnupg
        ]
      }
  '';
}
