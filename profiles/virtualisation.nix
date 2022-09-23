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
		binfmt.emulatedSystems = [ "aarch64-linux" "powerpc64-linux" ];
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
