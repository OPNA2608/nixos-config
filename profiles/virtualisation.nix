{
  vfioIds ? null,
}:
{
  lib,
  pkgs,
  ...
}:

{
  boot = {
    blacklistedKernelModules = lib.optionals (vfioIds != null) [ "nouveau" ];
    extraModprobeConfig = lib.optionalString (vfioIds != null) ''
      options vfio-pci ids=${lib.strings.concatStringsSep "," vfioIds}
      softdep drm pre: vfio-pci
    '';
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
    };
  };

  # audio setup
  hardware.pulseaudio.extraConfig = ''
    load-module module-native-protocol-unix auth-group=qemu-libvirtd socket=/tmp/pulse-socket
  '';

  environment.systemPackages = with pkgs; [
    virt-manager
  ];
}
