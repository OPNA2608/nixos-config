{ config
, pkgs
, lib
, ...
}:

###
### Configuration for my LaVie laptop
###

let
	gpuDriver = import ../../profiles/graphics.nix {
		type = "intel";
	};
in

{
	imports = [
		./base.nix

		./hardware-configuration.nix

		../../profiles/desktop.nix
		../../profiles/wayland.nix
		gpuDriver
	];

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

	# Overriding profiles/desktop.nix, I want to try using Lomiri & Miriway
	services.desktopManager.lomiri.enable = true;
	services.displayManager.defaultSession = lib.mkForce "lomiri";
	services.xserver.displayManager.lightdm.greeters = {
		pantheon.enable = lib.mkForce false;
		lomiri.enable = lib.mkForce true;
	};
}
