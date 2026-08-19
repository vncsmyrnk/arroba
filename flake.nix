{
  description = "A simple collection of useful shell scripts and wrappers.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.rbackup.url = "github:vncsmyrnk/rbackup";

  outputs =
    {
      self,
      nixpkgs,
      rbackup,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            sudo = final.callPackage ./src/sudo { };

            cryptsetup = final.sudo prev.cryptsetup;
            mount = final.sudo prev.mount;
            umount = final.sudo prev.umount;
          })
        ];
      };

      pathPreserve = pkgs.callPackage ./src/path-preserve { };

      gitWorktreeCd = pkgs.callPackage ./src/git-worktree-cd { };
      sopsExecEnv = pkgs.callPackage ./src/sops-exec-env { inherit pathPreserve; };
      sopsEdit = pkgs.callPackage ./src/sops-edit { inherit pathPreserve; };
      tmuxJobRun = pkgs.callPackage ./src/tmux-job-run { };
      tmuxJobList = pkgs.callPackage ./src/tmux-job-list { };
      tmuxJobKill = pkgs.callPackage ./src/tmux-job-kill { };
      tmuxJobKillAll = pkgs.callPackage ./src/tmux-job-kill-all { };
      tmuxSplitPane = pkgs.callPackage ./src/tmux-split-pane { inherit pathPreserve; };
      oathtoolTotpGenerate = pkgs.callPackage ./src/oathtool-totp-generate { };
      oathtoolTotpList = pkgs.callPackage ./src/oathtool-totp-list { };
      cryptsetupMount = pkgs.callPackage ./src/cryptsetup-mount { };
      cryptsetupUmount = pkgs.callPackage ./src/cryptsetup-umount { };
      cryptsetupStow = pkgs.callPackage ./src/cryptsetup-stow { };
      gpgKeyBackup = pkgs.callPackage ./src/gpg-key-backup {
        rbackup = rbackup.packages.${system}.default;
      };

      utilities = pkgs.symlinkJoin {
        name = "collection";
        paths = [
          gitWorktreeCd
          sopsExecEnv
          sopsEdit
          tmuxJobRun
          tmuxJobList
          tmuxJobKill
          tmuxJobKillAll
          tmuxSplitPane
          oathtoolTotpGenerate
          oathtoolTotpList
          cryptsetupMount
          cryptsetupUmount
          cryptsetupStow
          gpgKeyBackup
        ];
      };

      devShell = pkgs.mkShell {
        packages = with pkgs; [
          coreutils
          wl-clipboard
          zsh
          bats
          utilities
        ];
      };
    in
    {
      packages.${system}.default = utilities;
      devShells.${system}.default = devShell;
    };
}
