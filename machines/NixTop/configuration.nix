{ config
, pkgs
, lib
, ...
}:

###
### Configuration for my tower pc at home
###

{
	networking.hostName = "NixTop";
	# boot.kernelPackages = pkgs.linuxPackages_latest;
	boot.kernelPackages = pkgs.linuxPackages_xanmod;
	hardware.cpu.amd.updateMicrocode = true;

	# NixOS compatibility version
	system.stateVersion = "20.03";

	# Build cores and jobs
	nix.maxJobs    = 4;
	nix.buildCores = 6;

	imports = [
		./hardware-configuration.nix
		./profiles/common.nix

		./profiles/desktop.nix
		(import ./profiles/graphics.nix {
			type = "amd";
		})
		(import ./profiles/grub.nix {
			supportEfi = true;
		})
		./profiles/devel.nix
		./profiles/smart.nix
		(import ./profiles/virtualisation.nix {
			vfioIds = [
				# novideo GT 710
				"10de:128b" "10de:0e0f"
				# novideo GTX 650
				"10de:0fc6" "10de:0e1b"
			];
		})

		./users/bt1cn.nix

		./packages/haguichi-module.nix
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
			pkgs.unrar.meta.description
			pkgs.logmein-hamachi.meta.description
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
		gkraken
		wineWowPackages.full
		mangohud

		# CLI-only protonmail bridge doesn't work for me, i need hydroxide :/
		hydroxide
	];

	hardware.gkraken.enable = true;

	programs.haguichi.enable = true;
}
