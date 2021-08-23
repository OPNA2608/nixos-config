{ pkgs
, lib
, ...
}:

{
	users.users.puna = {
		description = "Puna";
		passwordFile = "/etc/nixos/users/passwords/puna";
		isNormalUser = true;
		shell = pkgs.fish;
		extraGroups = lib.mkDefault [ "wheel" "networkmanager" ];
	};
}
