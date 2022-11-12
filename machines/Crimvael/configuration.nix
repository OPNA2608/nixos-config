{ config
, pkgs
, lib
, ...
}:

###
### Pine64 PineBook Pro config
###

let
	grub = import ./profiles/grub.nix {
		supportEfi = true;
	};
in

{
	networking.hostName = "Crimvael";
	boot.kernelPackages = pkgs.linuxPackages_latest;

	# NixOS compatibility version
	system.stateVersion = "22.11";

	nix.maxJobs = 2;
	nix.buildCores = 2;

	imports = [
		./hardware-configuration.nix

		<nixos-hardware/pine64/pinebook-pro>
		#./nixos-hardware/pine64/pinebook-pro

		./profiles/common.nix
		./profiles/desktop.nix

		grub
		./profiles/devel.nix

		./users/puna.nix
	];

	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"pinebookpro-ap6256-firmware"
		"corefonts"
		"input-fonts"
	];

	boot.loader.generic-extlinux-compatible.enable = false;
	boot.loader.efi.canTouchEfiVariables = false;

#	networking.networkmanager.extraConfig = ''
#managed=false
#'';

	console.keyMap = "us";
	services.xserver.layout = "us";
	services.chrony.serverOption = "offline";
}

