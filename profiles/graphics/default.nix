{ type ? null
, useAlternative ? false
}:

{ lib
, pkgs
, ...
}:

assert lib.asserts.assertOneOf "type" type [ "amd" "novideo" "intel" "rpi4" ];

{
	imports = [
		(import (if (type != "rpi4") then ./normal.nix else ./rpi4.nix) {
			inherit type useAlternative;
		})
	];
	hardware.opengl.enable = true;
}
