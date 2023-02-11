{ config
, pkgs
, lib
, ...
}:

###
### Pine64 PineBook Pro config
###

let
#	x64-katawa-shoujo = pkgs.pkgsCross.gnu64.callPackage ./packages/katawa-shoujo.nix { };
#	katawa-shoujo-deps = (pkgs.callPackage ./packages/katawa-shoujo.nix { }).buildInputs;
#	box64-wrapper = pkgs.callPackage ./packages/box-wrapper.nix {
#		x64-bash = pkgs.pkgsCross.gnu64.bash;
#	};
	grub = import ./profiles/grub.nix {
		supportEfi = true;
	};
in

{
	networking.hostName = "Crimvael";
	boot.kernelPackages = pkgs.linuxPackages_latest;

	# NixOS compatibility version
	system.stateVersion = "22.11";

	nix.maxJobs = 2;
	nix.buildCores = 2;

	imports = [
		./hardware-configuration.nix

		<nixos-hardware/pine64/pinebook-pro>

		./profiles/common.nix
		./profiles/desktop.nix

		grub
		./profiles/devel.nix

		./users/puna.nix
	];

	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"pinebookpro-ap6256-firmware"
		"corefonts"
		"input-fonts"
#		(x64-katawa-shoujo.pname)
	];

	boot.loader.generic-extlinux-compatible.enable = false;
	boot.loader.efi.canTouchEfiVariables = false;

	# Doesn't work?
	boot.plymouth.enable = lib.mkForce false;

	# waking from suspend is broken, remove one source of unintentional suspends
	services.logind.lidSwitch = "lock";

	console.keyMap = "us";
	services.xserver.layout = "us";
	services.chrony.serverOption = "offline";

	environment.systemPackages = with pkgs; [
#		(box64-wrapper {
#			pkg = x64-katawa-shoujo;
#			deps = [
#				zlib
#				SDL
#				SDL_image
#				SDL_ttf
#				libGLU
#				libGL
#				glew
#				util-linux
#			] ++ (with xorg; [
#				libX11
#				libXext
#				libXrandr
#				libXrender
#				libxcb
#				libXau
#				libXdmcp
#				libXi
#				libXmu
#				libXt
#				libSM
#				libICE
#			]);
#			# KS has a shell script that sets everything up,we'rehijacking that instead
#			entry = "${pkgs.bash}/bin/bash";
#			extraWrapperArgs = [
#				"--set RENPY_GDB ${pkgs.box64}/bin/box64"
#				"--set RENPY_PLATFORM linux-x86_64"
#			];
#		})

		grim
		waybar
		wbg
		synapse
	];

	nix.settings.extra-platforms = [
		"armv7l-linux"
	];

	programs.miriway = {
		enable = true;
		config = ''
			ctrl-alt=t:tym
			enable-x11=
			add-wayland-extensions=all

			shell-component=dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY

			shell-component=waybar
			shell-component=wbg Pictures/miriway-wallpaper

			shell-meta=a:synapse
		'';
	};
	fonts.fonts = with pkgs; [ font-awesome ];

	zramSwap.enable = true;
}

