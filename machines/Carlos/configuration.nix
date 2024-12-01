{ config
, pkgs
, lib
, ...
}:

###
### Configuration for my tower pc at home
###

let
	/*
	nixpkgs-coolercontrol-src = builtins.fetchTarball {
		# https://github.com/codifryed/nixpkgs/tree/coolercontrol
		url = "https://github.com/codifryed/nixpkgs/archive/22b1e2447b0e6d8075188c52e492f5542e3e319c.tar.gz";
		sha256 = "1f933r8946q1sqqd5cv3my77c5av66kgqdh0b56y7m3802aga4v5";
	};
	*/
	nixpkgs-coolercontrol-src = <unstable>;
	#nixpkgs-coolercontrol-src = /home/puna/Development/nixpkgs;
	nixpkgs-coolercontrol = import nixpkgs-coolercontrol-src { };
in {
	networking.hostName = "Carlos";
	#boot.kernelPackages = pkgs.linuxPackages_latest;
	# Black screen on 6.7.0
	boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

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

		../../profiles/desktop.nix
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
		(final: prev: {
			coolercontrol = let
				inherit (nixpkgs-coolercontrol.coolercontrol.coolercontrold) version src;
				meta = with final.lib; {
					description = "Monitor and control your cooling devices";
					homepage = "https://gitlab.com/coolercontrol/coolercontrol";
					license = licenses.gpl3Plus;
					platforms = [ "x86_64-linux" ];
					maintainers = with maintainers; [ codifryed OPNA2608 ];
				};
				applySharedDetails = drv: drv { inherit version src meta; };
			in {
				coolercontrol-ui-data = applySharedDetails (final.callPackage (nixpkgs-coolercontrol-src + "/pkgs/applications/system/coolercontrol/coolercontrol-ui-data.nix") { });
				inherit (nixpkgs-coolercontrol.coolercontrol) coolercontrold;
				coolercontrol-liqctld = applySharedDetails (final.callPackage (nixpkgs-coolercontrol-src + "/pkgs/applications/system/coolercontrol/coolercontrol-liqctld.nix") { });
				coolercontrol-gui = applySharedDetails (final.callPackage (nixpkgs-coolercontrol-src + "/pkgs/applications/system/coolercontrol/coolercontrol-gui.nix") {
					inherit (nixpkgs-coolercontrol) rustPlatform;
				});
			};
		})

		# 32-bit Valve game fix
		(final: prev: {
			steam = prev.steam.override {
				extraLibraries = pkgs: with pkgs; [
					pkgsi686Linux.gperftools
				];
			};
		})

		# https://github.com/NixOS/nixpkgs/issues/274999 debugging
		(final: prev: {
			gnome = prev.gnome.overrideScope' (gfinal: gprev: {
				gnome-session = gprev.gnome-session.overrideAttrs (attrs: {
					separateDebugInfo = true;
				});
				gnome-shell = gprev.gnome-shell.overrideAttrs (attrs: {
					separateDebugInfo = true;
				});
				mutter = gprev.mutter.overrideAttrs (attrs: {
					separateDebugInfo = true;
				});
				mutter43 = gprev.mutter43.overrideAttrs (attrs: {
					separateDebugInfo = true;
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
			pkgs.minecraft.meta.description
			pkgs.steam.meta.description
			pkgs.steamPackages.steam-runtime.meta.description
			pkgs.steamPackages.steam-fhsenv.run.meta.description
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

		# Connecting to my tablet
		rcu

		# For Lomiri upstream submissions, needs to be latest one
		nixpkgs-coolercontrol.clickable
		xorg.xhost

		# https://github.com/NixOS/nixpkgs/issues/274999 debugging
		glib
		gnome.gnome-session
		gnome.mutter
		gnome.mutter43
		gnome.gnome-shell
	];

	# https://github.com/NixOS/nixpkgs/issues/274999 debugging
	environment.enableDebugInfo = true;

	programs.coolercontrol = {
		enable = true;
	};

	programs.haguichi.enable = true;

	services.desktopManager.lomiri.enable = true;
	services.xserver.displayManager.defaultSession = lib.mkForce "pantheon";
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
