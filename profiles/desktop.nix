{ screenIsSmall ? false
}:

{ config
, pkgs
, lib
, ...
}:

let
	preferOnX86 = pkg1: pkg2: if pkgs.stdenv.hostPlatform.isx86 then pkg1 else pkg2;
	whenAvailable = lib.lists.filter (x: lib.meta.availableOn pkgs.stdenv.hostPlatform x);
	tym-wrapped = pkgs.callPackage ../packages/tym-wrapper.nix {
		inherit screenIsSmall;
	};
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
		displayManager.lightdm = {
			enable = true;
			greeters.pantheon.enable = true;
		};
	};

	services.desktopManager.pantheon.enable = true;

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
		mpv

		tym-wrapped
		pavucontrol
		pcmanfm
		xfce.mousepad
		# https://github.com/NixOS/nixpkgs/issues/120765
		# also can't easily do the shortcut for builtin screenshooter on Crimvael
		xfce.xfce4-screenshooter
	] ++ (whenAvailable [
		palemoon-bin
	]);

	systemd.user.targets.graphical-session.wants = [
		"tym-daemon.service"
	];
}
