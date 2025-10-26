{ config
, pkgs
, lib
, ...
}:

###
### Configuration for my tower pc at home
###

let
	nixpkgs-unstable = import <unstable> { };
in {
	networking.hostName = "Carlos";
	boot.kernelPackages = pkgs.linuxPackages_latest;

	hardware.cpu.amd.updateMicrocode = true;

	# NixOS compatibility version
	system.stateVersion = "23.11";

	# Build cores and jobs
	nix.settings = {
		max-jobs = 4;
		cores = 6;
	};

	imports = [
		./hardware-configuration.nix
		../../profiles/common.nix

		(import ../../profiles/desktop.nix {})
		../../profiles/wayland.nix
		(import ../../profiles/graphics.nix {
			type = "amd";
		})
		(import ../../profiles/grub.nix {
			supportEfi = true;
		})
		../../profiles/devel.nix
		../../profiles/smart.nix
		(import ../../profiles/virtualisation.nix {
			vfioIds = [
				# novideo GT 710
				"10de:128b" "10de:0e0f"
				# novideo GTX 650
				"10de:0fc6" "10de:0e1b"
			];
		})

		# While working on ngipkgs
		../../profiles/ngipkgs-cachix.nix

		../../users/puna.nix
	];

	nixpkgs.overlays = [
		# 32-bit Valve game fix
		(final: prev: {
			steam = prev.steam.override {
				extraLibraries = pkgs: with pkgs; [
					pkgsi686Linux.gperftools
				];
			};
		})

		# ohmygod please make the dock just launch additional instances of applications again without any changes to every
		# individual desktop file
		(final: prev: {
			pantheon = prev.pantheon.overrideScope (gfinal: gprev: {
				elementary-dock = gprev.elementary-dock.overrideAttrs (oa: {
					# Treat undefined SingleMainWindow as set to false, to launching new instance of app can just be attempted
					postPatch = ''
						substituteInPlace src/AppSystem/App.vala \
							--replace-fail \
								'app_info.get_string ("SingleMainWindow")' \
								'app_info.get_boolean ("SingleMainWindow") ? "true" : "false"'
					'';
				});
			});
		})
	];

	# Firewall
	networking.firewall = {
		enable = true;
		allowedUDPPorts = [
			#4230 # Cities: Skylines Multiplayer
		];
	};

	# selectively allow unfree stuff
	nixpkgs.config.allowUnfreePredicate = (pkg:
		builtins.elem pkg.meta.description [
			pkgs.corefonts.meta.description
			pkgs.discord.meta.description
			pkgs.input-fonts.meta.description
			pkgs.steam-unwrapped.meta.description
			pkgs.steam.meta.description
			pkgs.steam.run.meta.description
			pkgs.unrar.meta.description
			pkgs.logmein-hamachi.meta.description
			#((pkgs.callPackage ../../packages/katawa-shoujo.nix {}).meta.description)
		]
	);

	# extra filesystems
	fileSystems = let
		fsOptions = fs:
			[
				"rw" "async" "nofail" "nouser"
			] ++ lib.optionals (fs == "ntfs") [
				"errors=remount-ro" "dmask=0003" "fmask=0113"
				"gid=${toString config.users.groups.users.gid}"
			];
	in {
		"/mnt/perm/D1" = rec {
			device = "/dev/disk/by-uuid/011621FA6BC2A92F";
			fsType = "ntfs";
			options = fsOptions fsType;
		};
		"/mnt/perm/D2" = rec {
			device = "/dev/disk/by-uuid/4356fecd-af37-4213-9826-ed5d01b5ff5e";
			fsType = "xfs";
			options = fsOptions fsType;
		};
		"/mnt/perm/Win10" = rec {
			device = "/dev/disk/by-uuid/E09AF9689AF93C1A";
			fsType = "ntfs";
			options = fsOptions fsType;
		};
	};

	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true;
	};

	# Extra packages
	environment.systemPackages = with pkgs; [
		discord
		wineWowPackages.full
		mangohud

		/*
		(callPackage ../../packages/katawa-shoujo.nix {
			SDL = SDL_compat;
		})
		*/

		protonmail-bridge

		rcu

		# For Lomiri upstream submissions
		# Clickable needs to be latest one
		nixpkgs-unstable.clickable
		xorg.xhost
	];

	# https://github.com/NixOS/nixpkgs/issues/274999 debugging
	environment.enableDebugInfo = true;

	programs.coolercontrol = {
		enable = true;
	};

	programs.haguichi.enable = true;

	services.desktopManager.lomiri.enable = true;
	services.displayManager.defaultSession = lib.mkForce "pantheon-wayland";
	services.xserver.displayManager.lightdm.greeters = {
		pantheon.enable = lib.mkForce false;
		lomiri.enable = lib.mkForce true;
	};

	# AusweisApp
	programs.ausweisapp.enable = true;
	services.pcscd.enable = true;

	# For clickable to work
	virtualisation.docker.enable = true;
	users.users.puna.extraGroups = [ "docker" ];
}
