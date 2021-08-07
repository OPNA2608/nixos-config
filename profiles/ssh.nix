{ lib
, ...
}:

{
	services.openssh = {
		enable = true;
		passwordAuthentication = lib.mkDefault true;
		permitRootLogin = "no";
		forwardX11 = true;
	};
}
