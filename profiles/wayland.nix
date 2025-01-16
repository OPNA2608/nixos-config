{ config
, pkgs
, lib
, ...
}:

{
	imports = [
		./fonts.nix
	];

	/*
	hardware.pulseaudio = {
		enable = true;
		support32Bit = true;
	};
	*/

	security.pam.services.gtklock = {};

	services.xserver = {
		enable = true;
		displayManager.lightdm = {
			enable = true;
		};
	};

	services.libinput.enable = true;

	programs.miriway = {
		enable = true;
		config = ''
			keymap=de
			ctrl-alt=t:kitty
			enable-x11=
			add-wayland-extensions=all

			display-config=static=.config/miriway.display
			app-env=GDK_BACKEND=wayland,x11:QT_QPA_PLATFORM=wayland:SDL_VIDEODRIVER=wayland:-QT_QPA_PLATFORMTHEME:NO_AT_BRIDGE=1:QT_ACCESSIBILITY:QT_LINUX_ACCESSIBILITY_ALWAYS_ON:MOZ_ENABLE_WAYLAND=1:_JAVA_AWT_WM_NONREPARENTING=1:-GTK_MODULES:-OOO_FORCE_DESKTOP:-GNOME_ACCESSIBILITY:-QT_IM_MODULE:NIXOS_OZONE_WL=1

			shell-component=dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY

			shell-component=waybar
			shell-component=wbg Pictures/miriway-wallpaper

			shell-meta=a:synapse

			lockscreen-on-idle=1
			lockscreen-app=${lib.getExe (pkgs.callPackage ../packages/gtklock-wrapped.nix {
				gtklock-packages = with pkgs; [
					({
						pkg = gtklock-userinfo-module;
						module = "userinfo-module";
					})
				];
			})}

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

	fonts.packages= with pkgs; [ font-awesome ];

	environment.systemPackages = with pkgs; [
		grim
		waybar
		(wbg.overrideAttrs (oa: {
			patches = (oa.patches or []) ++ [
				(fetchpatch {
					url = "https://codeberg.org/dnkl/wbg/commit/d687493c7cbc3d112db6030ec786b4b719ba075d.patch";
					hash = "sha256-ZFrTA2ajy9kHfzEIaX7yqRlw1cFM/kMSUIGY46zmFf8=";
				})
			];
		}))
		synapse

		vanilla-dmz
	];

#	nixpkgs.overlays = [
#		# https://github.com/MirServer/mir/issues/2958
#		(final: prev: {
#			mir = prev.mir.overrideAttrs (oa: {
#				patches = (oa.patches or []) ++ [
#					(final.fetchpatch {
#						url = "https://github.com/MirServer/mir/pull/2961.patch";
#						hash = "sha256-zV9BbpQ5M2kvxtGsDXBWi9GK0NeXHyvH6nYNKbdyU/w=";
#					})
#				];
#				cmakeFlags = (oa.cmakeFlags or []) ++ [
#					"-DCMAKE_BUILD_TYPE=AddressSanitizer"
#				];
#				preBuild = (oa.preBuild or "") + ''
#					export VERBOSE=1
#				'';
#				doCheck = false;
#			});
#			miriway = prev.miriway.overrideAttrs (oa: {
#				nativeBuildInputs = (oa.nativeBuildInputs or []) ++ [
#					final.makeWrapper
#				];
#				preConfigure = (oa.preConfigure or "") + ''
#					export CXXFLAGS=-fsanitize=address
#				'';
#				preBuild = (oa.preBuild or "") + ''
#					export VERBOSE=1
#				'';
#				postInstall = (oa.postInstall or "") + ''
#					wrapProgram $out/bin/miriway \
#						--set WAYLAND_DEBUG server
#				'';
#			});
#		})
#	];
}
