{ pkgs
, lib
, ...
}:

{
	fonts = {
		enableDefaultFonts = true;
		fonts = with pkgs; [
			corefonts # MS fonts
			# eventually replace noto-fonts-emoji with openmoji
			mplus-outline-fonts # japanese
			b612 # high legibility
			input-fonts # maybe new monospaced programming font, but unfree
		];
		fontconfig = {
			enable = true;
			cache32Bit = true;
			defaultFonts = {
				serif = lib.mkForce [ "Input Serif Narrow" ];
				sansSerif = lib.mkForce [ "Input Sans Narrow" ];
				emoji = lib.mkForce [ "Noto Color Emoji" "Noto Emoji" ];
				monospace = lib.mkForce [ "Input Mono Narrow" ];
			};
		};
	};
	nixpkgs.config.input-fonts.acceptLicense = true;
}
