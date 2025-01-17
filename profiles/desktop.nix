{ config
, pkgs
, lib
, ...
}:

let
	preferOnX86 = pkg1: pkg2: if pkgs.stdenv.hostPlatform.isx86 then pkg1 else pkg2;
	whenAvailable = lib.lists.filter (x: lib.meta.availableOn pkgs.stdenv.hostPlatform x);
	tym-wrapped = pkgs.callPackage ../packages/tym-wrapper.nix { };
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

		tym-wrapped
		pavucontrol
		pcmanfm
		xfce.mousepad
		# https://github.com/NixOS/nixpkgs/issues/120765
		# also can't easily do the shortcut for builtin screenshooter on Crimvael
		xfce.xfce4-screenshooter
	] ++ (whenAvailable [
		palemoon-bin
	]) ++ lib.optionals (stdenv.hostPlatform.isx86_64) [
		# Electron is currently timing out on aarch64 hydra, and I'm not sitting through those rebuilds on an ARM laptop
		element-desktop
		revolt-desktop
	];

	systemd.user.targets.graphical-session.wants = [
		"tym-daemon.service"
	];
}
