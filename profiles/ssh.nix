{ lib
, ...
}:

{
	services.openssh = {
		enable = true;
		settings = {
			PasswordAuthentication = lib.mkDefault true;
			PermitRootLogin = "no";
			X11Forwarding = true;
		};
	};
}
