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

  environment.systemPackages = with pkgs; [
    virt-manager
  ];
}
