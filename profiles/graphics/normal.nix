{ type ? null
, useAlternative ? false
}:

{ lib
, pkgs
, ...
}:

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
	chosenDriver = drivers.${type}.${typeType};
in

{
	services.xserver.videoDrivers = [
		chosenDriver # Selected driver
		"vesa" #Fallback
	];
	hardware.opengl.extraPackages = lib.optionals (type == "amd") (with pkgs; [
		amdvlk
	]);
	hardware.opengl.extraPackages32 = lib.optionals (type == "amd") (with pkgs; [
		driversi686Linux.amdvlk
	]);
}
