{ config
, lib
, ...
}:

let
	germanLocale = "de_DE.UTF-8";
in {
	console.keyMap = lib.mkDefault "de";
	i18n = {
		defaultLocale = germanLocale;
		supportedLocales = builtins.map (l: l + "/" + (lib.lists.last (lib.strings.splitString "." l))) [
			# This is kinda dumb, but we're gonna have to copy-paste the sane defaults here...
			# Alternative is to put them in a random locale setting that gets sent into the systemd settings & the global
			# envvars, which is equally silly. :/
			"C.UTF-8"
			"en_US.UTF-8"
			germanLocale

			# And now the additional ones
			"ja_JP.UTF-8"
			"ja_JP.EUC-JP"
		];
	};

	services.xserver.xkb = let xEnabled = config.services.xserver.enable; in {
		layout = lib.mkDefault (if xEnabled then "de" else null);
		options = (if (xEnabled && config.console.keyMap == "de") then "eurosign:e" else "terminate:ctrl_alt_bksp");
	};
}
