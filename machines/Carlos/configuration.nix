{ config
, pkgs
, lib
, ...
}:

###
### Configuration for my tower pc at home
###

let
  nixpkgs-coolercontrol-src = builtins.fetchTarball {
    # https://github.com/codifryed/nixpkgs/tree/coolercontrol-0.17.0
    url = "https://github.com/codifryed/nixpkgs/archive/ed254575f639bc89d2b7856c603d46121f01bbc9.tar.gz";
    sha256 = "09jkms9a4yikipmzpvmy3ybisw0chpf8zlp0ss9sch3262y72wkc";
  };
  nixpkgs-coolercontrol = import nixpkgs-coolercontrol-src { };
in {
	networking.hostName = "Carlos";
	boot.kernelPackages = pkgs.linuxPackages_latest;
	# boot.kernelPackages = pkgs.linuxPackages_xanmod;

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
		(self: super: {
			inherit (nixpkgs-coolercontrol) coolercontrol;
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
		gkraken
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

	programs.coolercontrol.enable = true;

	# To-be-replaced by the above once merged
	hardware.gkraken.enable = true;

	programs.haguichi.enable = true;

	services.udev.packages = [
		(pkgs.callPackage ../../packages/grundig-hw.nix { })
	];
}
