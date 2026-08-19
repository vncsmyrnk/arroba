{ pathPreserve, pkgs }:

pathPreserve {
  pname = "sops-edit";
  script = ./script.sh;
  tools = [ pkgs.sops ];
  shimmed = [ "sops" ];
  extraWrap = ''--run 'export CONFIG_PATH="''${CONFIG_PATH:-$HOME/.config/utilities/sops}"' '';
}
