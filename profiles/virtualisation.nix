{ vfioIds ? null
}:
{ lib
, pkgs
, ...
}:

{
	boot = {
		blacklistedKernelModules = lib.optionals (vfioIds != null) [ "nouveau" ];
		extraModprobeConfig = lib.optionalString (vfioIds != null) ''
			optionals vfio.pci ids=${lib.strings.concatStringsSep "," vfioIds}
			softdep drm pre: vfio-pci
		'';
		binfmt.emulatedSystems = [ "aarch64-linux" ];
	};
	virtualisation.libvirtd = {
		enable = true;
		onBoot = "ignore";
		onShutdown = "shutdown";
		qemuPackage = pkgs.qemu_kvm;
	};
	environment.systemPackages = with pkgs; [
		virt-manager
	];
}
