{ config
, pkgs
, lib
, ...
}:

{
	imports = [
		./fonts.nix
	];

	sound.enable = true;

	hardware.pulseaudio = {
		enable = true;
		support32Bit = true;
	};

	services.xserver = {
		enable = true;
		useGlamor = true;
		desktopManager.pantheon.enable = true;
		displayManager.lightdm = {
			enable = true;
			greeters.pantheon.enable = true;
		};
		libinput.enable = true;
	};

	environment.pantheon.excludePackages = (with pkgs.pantheon; [
		elementary-calculator
		elementary-code
		elementary-files
		elementary-music
		elementary-photos
		elementary-terminal
		elementary-videos
	]) ++ (with pkgs.gnome; [
		epiphany
		geary
	]);
	programs.evince.enable = false; # atril

	services.gnome.gnome-keyring.enable = true;

	environment.systemPackages = with pkgs; [
		# Web & Net
		element-desktop
		palemoon
		# fallback
		firefox
		thunderbird
		networkmanagerapplet

		# Office & AV
		corrscope
		galculator
		gimp
		libreoffice
		mate.eom
		mate.atril
		mpv
		youtube-dl

		# System
		kitty
		pavucontrol
		pcmanfm
		xfce.mousepad
		# https://github.com/NixOS/nixpkgs/issues/120765
		xfce.xfce4-screenshooter

		# CLI-only protonmail bridge doesn't work for me, i need hydroxide :/
		hydroxide
	];
}
