{ writeTextDir
}:

writeTextDir "etc/udev/rules.d/60-grundig-hw.rules" ''
  # Allow access to Grundig control hardware

  # USB foot controller
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="15d8", ATTRS{idProduct}=="0024", MODE="0666"
''
