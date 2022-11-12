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
		# palemoon # not available everywhere
		networkmanagerapplet

		# fallback
		firefox
		thunderbird

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
		# kitty # not supported everywhere (OpenGL 3.3)
		pavucontrol
		pcmanfm
		xfce.mousepad
		# https://github.com/NixOS/nixpkgs/issues/120765
		# also can't easily do the shortcut for builtin screenshooter on Crimvael
		xfce.xfce4-screenshooter

		# CLI-only protonmail bridge doesn't work for me, i need hydroxide :/
		hydroxide
	]
	++ lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform palemoon)
		palemoon
	++ (if stdenv.hostPlatform.isx86 then
			kitty
		else
			sakura
	);
}
