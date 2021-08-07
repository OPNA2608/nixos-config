{ python3Packages, lib, fetchFromGitLab
, meson, pkg-config, glib, ninja, desktop-file-utils, i2c-tools
, gobject-introspection, gtk3, libnotify, dbus, wrapGAppsHook
}:

let
  injector = python3Packages.buildPythonPackage rec {
    pname = "injector";
    version = "0.18.4";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "10miwi58g4b8rvdf1pl7s7x9j91qyxxv3kdn5idzkfc387hqxn6f";
    };

    propagatedBuildInputs = with python3Packages; [ typing-extensions ];

    doCheck = false;
  };
#   smbus = python3Packages.buildPythonPackage rec {
#     pname = "smbus";
#     version = "1.1.post2";
# 
#     src = python3Packages.fetchPypi {
#       inherit pname version;
#       sha256 = "1ijm13lpf5xp55vcxjm5dxjizfipvkqk8xliljl5605119g38vgr";
#     };
#   };
  pyi2c-tools = python3Packages.buildPythonPackage rec {
    inherit (i2c-tools) pname version src;

    buildInputs = [ i2c-tools ];

    preConfigure = "cd py-smbus";

    meta = with lib; {
      inherit (i2c-tools.meta) homepage platforms;

      description = "wrapper for i2c-tools' smbus stuff";
      # from py-smbus/smbusmodule.c
      license = [ licenses.gpl2Only ];
      maintainers = [ maintainers.evils ];
    };
  };
  liquidctl = python3Packages.buildPythonPackage rec {
    pname = "liquidctl";
    version = "1.6.1";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "0gw4nd4jjwlbr3mf6w3n1208zp7pklk0acc1m3czh12jwmdamdp3";
    };

    propagatedBuildInputs = with python3Packages; [ pyusb docopt pyi2c-tools hidapi ];

    doCheck = false;
  };
in
python3Packages.buildPythonApplication rec {
  pname = "gkraken";
  version = "1.1.5";

  src = fetchFromGitLab {
    owner = "leinardi";
    repo = "gkraken";
    rev = version;
    sha256 = "1d2qci59q88j1068ddbqmq9fl9qq2q9if5dy4xjg2z05lbxm1pzn";
  };

  format = "other";

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [ meson pkg-config glib ninja gtk3 desktop-file-utils wrapGAppsHook ];

  buildInputs = [ gobject-introspection glib gtk3 libnotify dbus ];

  propagatedBuildInputs = with python3Packages; [ pygobject3 peewee rx injector liquidctl pyxdg requests matplotlib dbus-python ];

  postInstall = ''
    mkdir -p $out/lib/udev/rules.d
    echo '
    # UDev rules that grant user access to GKraken for supported devices

    # Asetek 690LC (assuming NZXT Kraken X)
    # Asetek 690LC (assuming EVGA CLC)
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2433", ATTRS{idProduct}=="b200", MODE="0666"

    # NZXT Kraken X (X42, X52, X62 or X72)
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1e71", ATTRS{idProduct}=="170e", MODE="0666"

    # NZXT Kraken X (X53, X63 or X73)
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1e71", ATTRS{idProduct}=="2007", MODE="0666"

    # NZXT Kraken Z (Z53, Z63 or Z73)
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1e71", ATTRS{idProduct}=="3008", MODE="0666"
    ' > $out/lib/udev/rules.d/60-gkraken.rules
  '';
}
