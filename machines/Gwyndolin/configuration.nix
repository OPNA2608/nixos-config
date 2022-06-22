{ config
, pkgs
, lib
, ...
}:

###
### Configuration for my tower pc at home
###

let
	gpuDriver = import ./profiles/graphics.nix {
		type = "intel";
	};
	grub = import ./profiles/grub.nix {
		supportEfi = true;
	};
in

{
	networking.hostName = "Gwyndolin";
	boot.kernelPackages = pkgs.linuxPackages_latest;

	# NixOS compatibility version
	system.stateVersion = "21.05";

	# Build cores and jobs
	nix.maxJobs    = 2;
	nix.buildCores = 2;

	imports = [
		./hardware-configuration.nix

		./profiles/common.nix
		./profiles/desktop.nix
		gpuDriver
		grub
		./profiles/devel.nix
		./profiles/smart.nix

		./users/puna.nix
	];

	# Firewall
	# networking.firewall.enable = true; # default

	nixpkgs.config.allowUnfreePredicate = (pkg:
		builtins.elem pkg.meta.description [
			pkgs.corefonts.meta.description
			pkgs.discord.meta.description
			pkgs.input-fonts.meta.description
			pkgs.unrar.meta.description
		]
	);

	# Extra packages
	environment.systemPackages = with pkgs; [
		wineWowPackages.full
    discord
	];

	console.keyMap = "jp106";
	services.xserver.layout = "jp";
	boot.loader.grub.gfxmodeEfi = "1366x768";
	services.chrony.serverOption = "offline";

  services.printing.enable = true;
}
