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
		yt-dlp
		ffmpeg-full
		# https://github.com/NixOS/nixpkgs/issues/212995
		# I didn't ask for pipewire to crash my party
		(wrapMpv (mpv-unwrapped.override { pipewireSupport = false; }) { })

		# System
		(if pkgs.stdenv.hostPlatform.isx86 then
			# not supported everywhere (needs OpenGL 3.3)
			kitty
		else
			# fallback
			# TODO dotfiles in VCS
			tym
		)
		pavucontrol
		pcmanfm
		xfce.mousepad
		# https://github.com/NixOS/nixpkgs/issues/120765
		# also can't easily do the shortcut for builtin screenshooter on Crimvael
		xfce.xfce4-screenshooter
	] ++ lib.optionals (lib.meta.availableOn pkgs.stdenv.hostPlatform palemoon) [
		palemoon
	];
}
