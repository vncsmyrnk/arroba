{ pathPreserve, pkgs }:

pathPreserve {
  pname = "tmux-split-pane";
  script = ./script.sh;
  tools = [ pkgs.tmux ];
  shimmed = [ "tmux" ];
}
