{ config
, ...
}:

{
	console.keyMap = "de";
	i18n.defaultLocale = "de_DE.UTF-8";

	services.xserver = let xEnabled = config.services.xserver.enable; in {
		layout = (if xEnabled then "de" else null);
		xkbOptions = (if xEnabled then "eurosign:e" else null);
	};
}
