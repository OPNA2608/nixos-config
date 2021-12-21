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
			# Crash-looping most of the time since 21.11 bump
			# https://github.com/NixOS/nixpkgs/issues/151609
			# https://github.com/elementary/greeter/issues/578
			# greeters.pantheon.enable = true;
			greeters.gtk.enable = lib.mkForce true;
			greeter.package = lib.mkForce pkgs.lightdm_gtk_greeter.xgreeters;
			greeter.name = lib.mkForce "lightdm-gtk-greeter";
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
		yt-dlp
		ffmpeg-full

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
