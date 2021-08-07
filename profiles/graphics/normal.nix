{ type ? null
, useAlternative ? false
}:

{ lib
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
}
