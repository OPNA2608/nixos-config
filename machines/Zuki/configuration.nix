{ config
, pkgs
, lib
, ...
}:

###
### Configuration for my RPi4
###

{
	networking.hostName = "Zuki";
	# boot.kernelPackages handled by nixos-hardware

	# NixOS compatibility version
	system.stateVersion = "20.11";

	# Build cores and jobs
	nix.maxJobs    = 1;
	nix.buildCores = 2;

	imports = [
		./hardware-configuration.nix

		<nixos-hardware/raspberry-pi/4>

		./profiles/common.nix
		./profiles/devel.nix

		./users/puna.nix
	];

	# Firewall
	# networking.firewall.enable = true; # default

	hardware.raspberry-pi."4" = {
		fkms-3d.enable = true; # GPU accel
		audio.enable = true;
	};

	environment.systemPackages = with pkgs; [
		libraspberrypi
		raspberrypi-eeprom
	];

	services.xserver.enable = true;
	services.xserver.desktopManager.lxqt.enable = true;
	services.xserver.displayManager.sddm.enable = true;

	sound.enable = true;
	hardware.pulseaudio.enable = true;
}
