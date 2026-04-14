{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./i18n.nix
    ./logrotate.nix
    ./rsyslogd.nix
    ./shell.nix
    ./ssh.nix
    ./time.nix
    ./vim.nix

    ../users/root.nix
  ];

  console = {
    earlySetup = true;
    font = "gohufont-uni-14";
    packages = with pkgs; [ gohufont ];
  };
  services.gpm.enable = true;
  services.getty.extraArgs =
    let
      colours = [
        {
          index = 0;
          rrggbb = "FFFFEA";
        }
        {
          index = 1;
          rrggbb = "966966";
        }
        {
          index = 2;
          rrggbb = "557A53";
        }
        {
          index = 3;
          rrggbb = "736D4E";
        }
        {
          index = 4;
          rrggbb = "5A7084";
        }
        {
          index = 5;
          rrggbb = "6B6A8F";
        }
        {
          index = 6;
          rrggbb = "507676";
        }
        {
          index = 7;
          rrggbb = "000000";
        }
        {
          index = 8;
          rrggbb = "757655";
        }
        {
          index = 9;
          rrggbb = "843530";
        }
        {
          index = 10;
          rrggbb = "235920";
        }
        {
          index = 11;
          rrggbb = "5A4F16";
        }
        {
          index = 12;
          rrggbb = "2A5175";
        }
        {
          index = 13;
          rrggbb = "4A488A";
        }
        {
          index = 14;
          rrggbb = "1F5757";
        }
        {
          index = 15;
          rrggbb = "FFFFEA";
        }
      ];
    in
    [
      "-I"
      "${lib.strings.concatMapStrings (
        colorData: "\\033]P${lib.trivial.toHexString colorData.index}${colorData.rrggbb}"
      ) colours}"
    ];

  programs.less = {
    enable = true;
    # Between 22.05 and 22.11, lesspipe got too dumb for me:
    # - missing `strings` from binutils in its wrapping: https://github.com/NixOS/nixpkgs/issues/216087
    # - sends SJIS files through `strings` which is *so* much worse than printing escapes within text
    lessopen = lib.mkForce null;
  };

  programs.gnupg.agent.enable = true;

  networking.networkmanager.enable = true;

  users.mutableUsers = false;

  system.copySystemConfiguration = true;

  environment.systemPackages = with pkgs; [
    curl
    file
    htop
    lhasa
    man-pages
    networkmanager
    hyfetch
    fastfetch # latter user by the former
    nixos-option
    nkf
    service-wrapper
    tree
    unixtools.xxd
    wget
    zip
    unzip
  ];

  nix = {
    package = pkgs.lixPackageSets.latest.lix;
    settings.trusted-users = [
      "@wheel"
    ];
  };
}
