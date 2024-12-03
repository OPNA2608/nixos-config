{ config
, pkgs
, lib
, ...
}:

let
	preferOnX86 = pkg1: pkg2: if pkgs.stdenv.hostPlatform.isx86 then pkg1 else pkg2;
	whenAvailable = lib.lists.filter (x: lib.meta.availableOn pkgs.stdenv.hostPlatform x);
in
{
	imports = [
		./fonts.nix
	];

  /*
	hardware.pulseaudio = {
		enable = true;
		support32Bit = true;
	};
  */

	services.xserver = {
		enable = true;
		desktopManager.pantheon.enable = true;
		displayManager.lightdm = {
			enable = true;
			greeters.pantheon.enable = true;
		};
	};

	services.libinput.enable = true;

	environment.pantheon.excludePackages = (with pkgs.pantheon; [
		elementary-calculator
		elementary-code
		elementary-files
		elementary-music
		elementary-photos
		elementary-terminal
		elementary-videos
		epiphany
	]) ++ (with pkgs; [
		geary
	]);
	programs.evince.enable = false; # atril

	services.gnome.gnome-keyring.enable = true;

	environment.systemPackages = with pkgs; [
		# Web & Net
		element-desktop
		revolt-desktop
		networkmanagerapplet

		# fallback
		firefox
		# TB getting abit on the heavier side, claws-mail ugly but slimmer
		(preferOnX86 thunderbird claws-mail)

		# Office & AV
		corrscope
		galculator
		gimp
		libreoffice-qt
		mate.eom
		mate.atril
		yt-dlp
		ffmpeg-full
		# https://github.com/NixOS/nixpkgs/issues/212995
		# I didn't ask for pipewire to crash my party
		(mpv-unwrapped.wrapper {
			mpv = mpv-unwrapped.override { pipewireSupport = false; };
		})

		# System
		# Kitty not supported everywhere (needs OpenGL 3.3)
		# TODO tym dotfiles in VCS
		(preferOnX86 kitty tym)
		pavucontrol
		pcmanfm
		xfce.mousepad
		# https://github.com/NixOS/nixpkgs/issues/120765
		# also can't easily do the shortcut for builtin screenshooter on Crimvael
		xfce.xfce4-screenshooter
	] ++ (whenAvailable [
		palemoon-bin
  ]);
}
