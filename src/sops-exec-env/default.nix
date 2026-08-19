{ pathPreserve, pkgs }:

pathPreserve {
  pname = "sops-exec-env";
  script = ./script.sh;
  tools = [ pkgs.sops ];
  shimmed = [ "sops" ];
  extraWrap = ''--run 'export CONFIG_PATH="''${CONFIG_PATH:-$HOME/.config/utilities/sops}"' '';
  extraInstall = ''
    cp ${./completions.zsh} ./sops-exec-env
    installShellCompletion --zsh ./sops-exec-env
  '';
}
