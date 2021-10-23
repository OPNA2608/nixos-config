{ config
, lib
, ...
}:

{
	console.keyMap = lib.mkDefault "de";
	i18n.defaultLocale = "de_DE.UTF-8";

	services.xserver = let xEnabled = config.services.xserver.enable; in {
		layout = lib.mkDefault (if xEnabled then "de" else null);
		xkbOptions = (if (xEnabled && config.console.keyMap == "de") then "eurosign:e" else "terminate:ctrl_alt_bksp");
	};
}
