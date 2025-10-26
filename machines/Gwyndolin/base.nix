{
  config,
  pkgs,
  lib,
  ...
}:

###
### Configuration for my LaVie laptop
###

let
  grub = import ../../profiles/grub.nix {
    supportEfi = true;
  };
in

{
  networking.hostName = "Gwyndolin";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # NixOS compatibility version
  system.stateVersion = "21.05";

  # Build cores and jobs
  nix.settings = {
    max-jobs = 2;
    cores = 2;
  };

  imports = [
    ./hardware-configuration.nix

    ../../profiles/common.nix
    grub
    ../../profiles/devel.nix
    ../../profiles/smart.nix

    ../../users/puna.nix
  ];

  console.keyMap = "jp106";
  services.xserver.xkb.layout = "jp";
  boot.loader.grub.gfxmodeEfi = "1366x768";
  services.chrony.enable = lib.mkForce false;
  services.timesyncd.enable = lib.mkForce true;
}
