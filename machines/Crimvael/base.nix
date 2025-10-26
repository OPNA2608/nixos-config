{
  config,
  pkgs,
  lib,
  ...
}:

###
### Pine64 PineBook Pro config
###

let
  grub = import ../../profiles/grub.nix {
    supportEfi = true;
  };
in

{
  networking.hostName = "Crimvael";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # NixOS compatibility version
  system.stateVersion = "22.11";

  nix.settings = {
    max-jobs = 2;
    cores = 1;
  };

  imports = [
    ./hardware-configuration.nix

    <nixos-hardware/pine64/pinebook-pro>

    ../../profiles/common.nix

    grub
    ../../profiles/devel.nix

    ../../users/puna.nix
  ];

  # May lose track of time when disconnected from power, can't get chrony to do huge date jumps
  services.chrony.enable = lib.mkForce false;
  services.timesyncd.enable = lib.mkForce true;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "pinebookpro-ap6256-firmware"
    ];

  boot.loader.generic-extlinux-compatible.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  # To avoid the missing symbol 'grub_is_shim_lock_enabled' error at boot time
  boot.loader.grub.efiInstallAsRemovable = true;

  # Doesn't work?
  boot.plymouth.enable = lib.mkForce false;

  # waking from suspend is broken, remove one source of unintentional suspends
  services.logind.lidSwitch = "lock";

  console.keyMap = "us";
  services.xserver.xkb.layout = "us";
  services.chrony.serverOption = "offline";

  environment.systemPackages = with pkgs; [
    screen

    clickable
    xorg.xhost
  ];

  nix.settings.extra-platforms = [
    "armv7l-linux"
  ];

  zramSwap.enable = true;

  virtualisation.docker.enable = true;
  users.users.puna.extraGroups = [ "docker" ];
}
