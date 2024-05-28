{ config
, pkgs
, lib
, ...
}:

###
### Configuration for my tower pc at home
###

let
  nixpkgs-coolercontrol-src = <unstable>;
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

		(nixpkgs-coolercontrol-src + "/nixos/modules/programs/coolercontrol.nix")

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
				coolercontrol-gui = applySharedDetails (final.callPackage (nixpkgs-coolercontrol-src + "/pkgs/applications/system/coolercontrol/coolercontrol-gui.nix") { });
			};
			##inherit (nixpkgs-coolercontrol) coolercontrol;
			/*
			coolercontrol = {
				inherit (nixpkgs-coolercontrol.coolercontrol) coolercontrold coolercontrol-liqctld;
				coolercontrol-gui = nixpkgs-coolercontrol.coolercontrol.coolercontrol-gui.overrideAttrs (oa: {
					nativeBuildInputs = oa.nativeBuildInputs ++ (with pkgs; [
						makeWrapper
					]);
					postInstall = oa.postInstall + ''
						wrapProgram $out/bin/coolercontrol \
							--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with nixpkgs-coolercontrol; [ libappindicator ])}
					'';
				});
			};
			*/
		})

		(final: prev: {
			steam = prev.steam.override {
				extraLibraries = pkgs: with pkgs; [
					#gperftools
					pkgsi686Linux.gperftools
				];
			};
		})
	];

	# Firewall
	networking.firewall = {
		enable = true;
		allowedUDPPorts = [
			4230 # Cities: Skylines Multiplayer
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
			((pkgs.callPackage ../../packages/katawa-shoujo.nix {}).meta.description)
		]
	);

	# extra filesystems
	fileSystems = let
		fsOptions = [
			"rw" "async" "nofail" "nouser" "errors=remount-ro"
			"dmask=0003" "fmask=0113" "gid=${toString config.users.groups.users.gid}"
		];
	in {
		"/mnt/perm/D1" = {
			device = "/dev/disk/by-uuid/011621FA6BC2A92F";
			fsType = "ntfs";
			options = fsOptions;
		};
		"/mnt/perm/D2" = {
			device = "/dev/disk/by-uuid/7F0015800BEEA225";
			fsType = "ntfs";
			options = fsOptions;
		};
		"/mnt/perm/Win10" = {
			device = "/dev/disk/by-uuid/E09AF9689AF93C1A";
			fsType = "ntfs";
			options = fsOptions;
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

		(callPackage ../../packages/katawa-shoujo.nix {
			SDL = SDL_compat;
		})

		# CLI-only protonmail bridge doesn't work for me, i need hydroxide :/
		# hydroxide is now also broken <3
		# https://github.com/emersion/hydroxide/issues/235
		hydroxide
	];

	programs.coolercontrol = {
		enable = true;
	};

	programs.haguichi.enable = true;

	services.udev.packages = [
		(pkgs.callPackage ../../packages/grundig-hw.nix { })
	];
}
