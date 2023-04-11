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

	# May lose track of time when disconnected from power, can't get chrony to do huge date jumps
	services.chrony.enable = lib.mkForce false;
	services.timesyncd.enable = lib.mkForce true;

	hardware.raspberry-pi."4" = {
		fkms-3d.enable = true; # GPU accel
		audio.enable = true;
	};

	environment.systemPackages = with pkgs; [
		# Raspi-specific
		libraspberrypi
		raspberrypi-eeprom

		# Miriway
		grim
		waybar
		wbg
		synapse
		tym
	];

	services.xserver.enable = true;
	services.xserver.desktopManager.lxqt.enable = true;
	services.xserver.displayManager.sddm.enable = true;

	sound.enable = true;
	hardware.pulseaudio.enable = true;

	# Miriway
	programs.miriway.enable = true;
	fonts.fonts = with pkgs; [ font-awesome ];
	# ...but don't default to it, due to https://github.com/MirServer/mir/issues/2837
	services.xserver.displayManager.defaultSession = lib.mkForce "lxqt";
}
