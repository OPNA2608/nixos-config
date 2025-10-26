{
  config,
  pkgs,
  lib,
  ...
}:

###
### Pine64 PineBook Pro config
###

let
  x64-katawa-shoujo =
    (pkgs.pkgsCross.gnu64.callPackage ../../packages/katawa-shoujo.nix {
      devendorImageLibs = false;
    }).overrideAttrs
      (oa: {
        buildInputs = [ ];
        dontAutoPatchelf = true;
      });
  katawa-shoujo-deps = (pkgs.callPackage ../../packages/katawa-shoujo.nix { }).buildInputs;
  box64-wrapper = pkgs.callPackage ../../packages/box-wrapper.nix {
    x64-bash = pkgs.pkgsCross.gnu64.bash;
  };
  desktop = import ../../profiles/desktop.nix {
    screenIsSmall = true;
  };
in

{
  imports = [
    ./base.nix

    desktop
    ../../profiles/wayland.nix
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "pinebookpro-ap6256-firmware"
      "corefonts"
      "input-fonts"
      (x64-katawa-shoujo.pname)
    ];

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

    gnome-calendar
    protonmail-bridge
  ];

  programs.miriway = {
    enable = true;
    # TODO: Make config from module suitable for laptop
    config = lib.mkForce ''
      idle-timeout=300
      ctrl-alt=t:tym
      enable-x11=
      add-wayland-extensions=all

      app-env-amend=${
        lib.strings.concatStringsSep ":" [
          "XDG_SESSION_TYPE=wayland"
          "GTK_USE_PORTAL=0"
          "XDG_CURRENT_DESKTOP=Miriway"
          "GTK_A11Y=none"
          "-GTK_IM_MODULE"
          "NIXOS_OZONE_WL=1"
        ]
      }
      shell-component=dbus-update-activation-environment --systemd ${
        lib.strings.concatStringsSep " " [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "XDG_SESSION_TYPE"
          "XDG_CURRENT_DESKTOP"
        ]
      }

      shell-component=waybar
      shell-component=wbg Pictures/miriway-wallpaper

      shell-component=protonmail-bridge --noninteractive

      meta=a:synapse
      meta=l:loginctl lock-session

      lockscreen-on-idle=1
      lockscreen-app=${
        lib.getExe (
          pkgs.callPackage ../../packages/gtklock-wrapped.nix {
            gtklock-packages = with pkgs; [
              ({
                pkg = gtklock-userinfo-module;
                module = "userinfo-module";
              })
            ];
          }
        )
      }

      meta=Space:@toggle-maximized
      meta=Page_Up:@workspace-up
      meta=Page_Down:@workspace-down
      ctrl-alt=BackSpace:@exit

      # Keyboard is dumb, meta + arrows don't work
      meta=Home:@dock-left
      meta=End:@dock-right
      meta=q:@dock-left
      meta=e:@dock-right
    '';
  };
  fonts.packages = with pkgs; [ font-awesome ];

  environment.variables = {
    # Experimental OpenGL 3.3 support in panfrost driver
    "PAN_MESA_DEBUG" = "gl3";
  };

  # Overriding profiles/desktop.nix, I want to try using Lomiri & Miriway
  services.desktopManager.lomiri.enable = true;
  services.desktopManager.pantheon.enable = lib.mkForce false;
  services.displayManager.defaultSession = lib.mkForce "lomiri";
  services.xserver.displayManager.lightdm.greeters = {
    pantheon.enable = lib.mkForce false;
    lomiri.enable = lib.mkForce true;
  };

  programs.nix-index.package = (import <nix-index-database> { inherit pkgs; }).nix-index-with-db;
}
