{ useAlternative
, ...
}:

{ lib
, ...
}:

assert lib.assertIf useAlternative "No alternative settings for RPi4!";

{
	hardware.opengl.setLdLibraryPath = true;
	# Broken
	# https://github.com/NixOS/nixpkgs/pull/107637#issuecomment-753368078
	# https://github.com/NixOS/nixpkgs/pull/79370#issuecomment-757531597
	# hardware.deviceTree = {
	#   overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
	# };
	boot.loader.raspberryPi.firmwareConfig = ''
		gpu_mem=192
	'';
}
