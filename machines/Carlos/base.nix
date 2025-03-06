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

		# https://github.com/NixOS/nixpkgs/issues/274999 debugging
		(final: prev: {
			gnome-session = prev.gnome-session.overrideAttrs (attrs: {
				separateDebugInfo = true;
			});
			gnome-shell = prev.gnome-shell.overrideAttrs (attrs: {
				separateDebugInfo = true;
			});
			mutter = prev.mutter.overrideAttrs (attrs: {
				separateDebugInfo = true;
			});
			mutter43 = prev.mutter43.overrideAttrs (attrs: {
				separateDebugInfo = true;
			});

			# Attempting to fix this with a patch
			pantheon = prev.pantheon.overrideScope (gfinal: gprev: {
				gala = gprev.gala.overrideAttrs (oa: {
					patches = (oa.patches or []) ++ [
						(prev.fetchpatch {
							name = "9991-gala-More-checks-in-notifications-stack.patch";
							url = "https://github.com/elementary/gala/commit/186e9a304a02bcef01a97a4336438c2969c57754.patch";
							hash = "sha256-aC0MH54InRj4MK7nxlEyAZxzsPh338V5P/gFuGkTfDc=";
						})
/*
						(prev.fetchpatch {
							name = "9992-gala-PanelWindow-Fix-possible-segfault.patch";
							url = "https://github.com/elementary/gala/commit/fdd5e440d43af570e32710d026164fc0683752c9.patch";
							hash = "sha256-fefOkkqGX6mo/NzykDdkTDz7oZha3jxzfBQ8piIGn9E=";
						})
						(prev.fetchpatch {
							name = "9993-gala-ShellClients-Fix-crash-when-positioning-window-while-unmanaging.patch";
							url = "https://github.com/elementary/gala/commit/48b716337f51a8d1c798015c8d677d2d5fa36e4d.patch";
							hash = "sha256-KVRG2C4i11L5o0ZpSoGsDHEqs2jjdPaXup2u9PYdHfo=";
						})
*/

						# https://github.com/elementary/gala/pull/2129
            /*
						(prev.fetchpatch {
							name = "9994-gala-WindowManager-Only-show-notifications-after-their-window-was-shown.patch";
							url = "https://github.com/elementary/gala/commit/719c2dbfe1975bc307892ddeb4e51fd9b8b784d4.patch";
							hash = "sha256-bTIXn8SLJwM5N2rwjSb9iDNwguvU+qLZWT4JV28+zrU=";
						})
            */
						../../packages/gala-0001-WindowManager-Only-show-notifications-after-their-wi.patch
					];
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

		# Connecting to my tablet
		# Older versions are harder to get
		(rcu.overrideAttrs (oa: rec {
			version = "2025.001s";
			src =
				let
					src-tarball = requireFile {
						name = "rcu-d${version}-source.tar.gz";
						hash = "sha256-QC9ieulYAmE9pwt1/eZmyI5MZfRV0f24Pe5oKtuXNok=";
						url = "https://www.davisr.me/projects/rcu/";
					};
				in
				runCommand "${src-tarball.name}-unpacked" { } ''
					gunzip -ck ${src-tarball} | tar -xvf-
					mv rcu $out
					ln -s ${src-tarball} $out/src
				'';

				# Update refs to older src
				installPhase =
					''
						runHook preInstall

						mkdir -p $out/{bin,share}
						cp -r src $out/share/rcu

					''
					+ lib.optionalString stdenv.hostPlatform.isLinux ''
						install -Dm644 package_support/gnulinux/50-remarkable.rules $out/etc/udev/rules.d/50-remarkable.rules
					''
					+ ''

						# Keep source from being GC'd by linking into it

						for icondir in $(find icons -type d -name '[0-9]*x[0-9]*'); do
							iconsize=$(basename $icondir)
							mkdir -p $out/share/icons/hicolor/$iconsize/apps
							ln -s ${src}/icons/$iconsize/rcu-icon-$iconsize.png $out/share/icons/hicolor/$iconsize/apps/rcu.png
						done

						mkdir -p $out/share/icons/hicolor/scalable/apps
						ln -s ${src}/icons/64x64/rcu-icon-64x64.svg $out/share/icons/hicolor/scalable/apps/rcu.svg

						mkdir -p $out/share/doc/rcu
						for docfile in {COPYING,manual.pdf}; do
							ln -s ${src}/manual/$docfile $out/share/doc/rcu/$docfile
						done

						mkdir -p $out/share/licenses/rcu
						ln -s ${src}/COPYING $out/share/licenses/rcu/COPYING

						runHook postInstall
					'';
		}))

		# For Lomiri upstream submissions
		# Clickable needs to be latest one
		nixpkgs-unstable.clickable
		xorg.xhost

		# https://github.com/NixOS/nixpkgs/issues/274999 debugging
		glib
		gnome-session
		mutter
		mutter43
		gnome-shell
	];

	# https://github.com/NixOS/nixpkgs/issues/274999 debugging
	environment.enableDebugInfo = true;

	programs.coolercontrol = {
		enable = true;
	};

	programs.haguichi.enable = true;

	services.desktopManager.lomiri.enable = true;
	services.displayManager.defaultSession = lib.mkForce "pantheon";
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
