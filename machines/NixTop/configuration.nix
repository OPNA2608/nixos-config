{ config
, pkgs
, lib
, ...
}:

###
### Configuration for my tower pc at home
###

let
	gpuDriver = import ./profiles/graphics.nix {
		type = "amd";
		useAlternative = false;
	};
	grub = import ./profiles/grub.nix {
		supportEfi = true;
	};
	virtualisation = import ./profiles/virtualisation.nix {
		vfioIds = [
			# novideo GT 710
			"10de:128b" "10de:0e0f"
			# novideo GTX 650
			"10de:0fc6" "10de:0e1b"
		];
	};
in

{
	networking.hostName = "NixTop";
	boot.kernelPackages = pkgs.linuxPackages_latest;
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
		gpuDriver
		grub
		./profiles/devel.nix
		./profiles/smart.nix
		virtualisation

		./users/bt1cn.nix
	];

	# Firewall
	# networking.firewall.enable = true; # default

	nixpkgs.config.allowUnfreePredicate = (pkg:
		builtins.elem pkg.meta.description [
			pkgs.corefonts.meta.description
			pkgs.discord.meta.description
			pkgs.input-fonts.meta.description
			pkgs.minecraft.meta.description
			pkgs.steam.meta.description
			pkgs.steamPackages.steam-runtime.meta.description
			pkgs.unrar.meta.description
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

	# https://github.com/NixOS/nixpkgs/issues/126428
	# https://github.com/NixOS/nixpkgs/pull/126435#issuecomment-902394425
	nixpkgs.config.packageOverrides = pkgs: {
		steam = pkgs.steam.override {
			extraProfile = ''
				unset VK_ICD_FILENAMES
				export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json:/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json:/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json:/run/opengl-driver-32/share/vulkan/icd.d/amd_icd32.json:/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.json:/run/opengl-driver/share/vulkan/icd.d/lvp_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/lvp_icd.i686.json
			'';
		};
	};

	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true;
	};

	# Extra packages
	environment.systemPackages = with pkgs; [
		(callPackage ./packages/gkraken.nix { })
		wineWowPackages.full
		mangohud
	];

	services.udev.packages = with pkgs; [
		(callPackage ./packages/gkraken.nix { })
	];
}
