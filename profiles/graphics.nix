{ type ? null
, useAlternative ? false
}:

{ lib
, pkgs
, ...
}:

assert lib.asserts.assertOneOf "type" type [ "amd" "novideo" "intel" ];

let
	drivers = {
		amd = {
			main = "amdgpu";
			alternate = "amdgpu-pro";
		};
		novideo = {
			main = "nv";
			alternate = "nvidiaBeta";
		};
		intel = {
			main = "intel";
			alternate = "modesetting";
		};
	};
	typeType = if useAlternative then "alternate" else "main";
in

{
	services.xserver.videoDrivers = [
		drivers.${type}.${typeType} # Selected driver
		"vesa" # Fallback
	];

	hardware.opengl.enable = true;

	hardware.opengl.extraPackages = lib.optionals (type == "amd") (with pkgs; [
		#amdvlk
	]);
	hardware.opengl.extraPackages32 = lib.optionals (type == "amd") (with pkgs; [
		#driversi686Linux.amdvlk
	]);
}
