{ config
, pkgs
, lib
, ...
}:

###
### Pine64 PineBook Pro config
###

let
	x64-katawa-shoujo = (pkgs.pkgsCross.gnu64.callPackage ../../packages/katawa-shoujo.nix {
		devendorImageLibs = false;
	}).overrideAttrs (oa: {
		buildInputs = [];
		dontAutoPatchelf = true;
	});
	katawa-shoujo-deps = (pkgs.callPackage ../../packages/katawa-shoujo.nix { }).buildInputs;
	box64-wrapper = pkgs.callPackage ../../packages/box-wrapper.nix {
		x64-bash = pkgs.pkgsCross.gnu64.bash;
	};
	grub = import ../../profiles/grub.nix {
		supportEfi = true;
	};
in

{
	networking.hostName = "Crimvael";
	boot.kernelPackages = pkgs.linuxPackages_latest;

	# NixOS compatibility version
	system.stateVersion = "22.11";

	nix.settings = {
		max-jobs = 2;
		cores = 1;
	};

	imports = [
		./hardware-configuration.nix

		<nixos-hardware/pine64/pinebook-pro>

		../../profiles/common.nix
		../../profiles/desktop.nix

		grub
		../../profiles/devel.nix

		../../users/puna.nix
	];

	# May lose track of time when disconnected from power, can't get chrony to do huge date jumps
	services.chrony.enable = lib.mkForce false;
	services.timesyncd.enable = lib.mkForce true;

	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"pinebookpro-ap6256-firmware"
		"corefonts"
		"input-fonts"
		(x64-katawa-shoujo.pname)
	];

	boot.loader.generic-extlinux-compatible.enable = false;
	boot.loader.efi.canTouchEfiVariables = false;
	# To avoid the missing symbol 'grub_is_shim_lock_enabled' error at boot time
	boot.loader.grub.efiInstallAsRemovable = true;

	# Doesn't work?
	boot.plymouth.enable = lib.mkForce false;

	# waking from suspend is broken, remove one source of unintentional suspends
	services.logind.lidSwitch = "lock";

	console.keyMap = "us";
	services.xserver.xkb.layout = "us";
	services.chrony.serverOption = "offline";

	environment.systemPackages = with pkgs; [
    /*
		(box64-wrapper {
			pkg = x64-katawa-shoujo;
			deps = [
				freetype
				zlib
				SDL_compat
				libGLU
				libGL
			] ++ (with xorg; [
				libX11
				libXext
				libXi
				libXmu
			]);
			# KS has a shell script that sets everything up, we're hijacking that instead
			entry = "${pkgs.bash}/bin/bash";
			extraWrapperArgs = [
				"--set RENPY_GDB ${pkgs.box64}/bin/box64"
			];
		})
    */
		duckstation

		grim
		waybar
		wbg
		synapse

		screen

		clickable
		xorg.xhost

		protonmail-bridge
	];

	nix.settings.extra-platforms = [
		"armv7l-linux"
	];

	programs.miriway = {
		enable = true;
		config = ''
			idle-timeout=300
			ctrl-alt=t:tym
			enable-x11=
			add-wayland-extensions=all

			app-env-amend=XDG_SESSION_TYPE=wayland:GTK_USE_PORTAL=0:XDG_CURRENT_DESKTOP=Miriway:GTK_A11Y=none:-GTK_IM_MODULE:NIXOS_OZONE_WL=1
			shell-component=dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP

			shell-component=waybar
			shell-component=wbg Pictures/miriway-wallpaper

			meta=a:synapse

			meta=Left:@dock-left
			meta=Right:@dock-right
			meta=Space:@toggle-maximized
			meta=Home:@workspace-begin
			meta=End:@workspace-end
			meta=Page_Up:@workspace-up
			meta=Page_Down:@workspace-down
			ctrl-alt=BackSpace:@exit
		'';
	};
	fonts.packages = with pkgs; [ font-awesome ];

	zramSwap.enable = true;

	environment.variables = {
		# Experimental OpenGL 3.3 support in panfrost driver
		"PAN_MESA_DEBUG" = "gl3";
	};

	# Overriding profiles/desktop.nix, I want to try using Lomiri & Miriway
	services.desktopManager.lomiri.enable = true;
	services.xserver.desktopManager.pantheon.enable = lib.mkForce false;
	services.displayManager.defaultSession = lib.mkForce "lomiri";
	services.xserver.displayManager.lightdm.greeters = {
		gtk.enable = lib.mkForce true;
		pantheon.enable = lib.mkForce false;
		lomiri.enable = lib.mkForce false;
	};

	hardware.alsa.enablePersistence = true;

	virtualisation.docker.enable = true;
	users.users.puna.extraGroups = [ "docker" ];
}

