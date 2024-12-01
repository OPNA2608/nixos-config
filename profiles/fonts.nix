{ pkgs
, lib
, ...
}:

{
	fonts = {
		# Don't want some of them
		enableDefaultPackages = false;
		packages = with pkgs; [
			corefonts # MS fonts
			openmoji-color openmoji-black # emojis
			mplus-outline-fonts.osdnRelease # japanese
			b612 # high legibility
			input-fonts # maybe new monospaced programming font, but unfree

			# defaults worth keeping
			dejavu_fonts
			freefont_ttf
			gyre-fonts
			liberation_ttf
			unifont
		];
		fontconfig = {
			enable = true;
			cache32Bit = true;
			defaultFonts = {
				serif = lib.mkForce [ "Input Serif Narrow" ];
				sansSerif = lib.mkForce [ "Input Sans Narrow" ];
				emoji = lib.mkForce [ "OpenMoji Color" "OpenMoji Black" ];
				monospace = lib.mkForce [ "Input Mono Narrow" ];
			};
		};
	};
	nixpkgs.config.input-fonts.acceptLicense = true;
}
