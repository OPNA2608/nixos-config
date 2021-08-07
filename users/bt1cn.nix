{ pkgs
, lib
, ...
}:

{
	users.users.bt1cn = {
		description = "Christoph N.";
		passwordFile = "/etc/nixos/users/passwords/bt1cn";
		isNormalUser = true;
		shell = pkgs.fish;
		extraGroups = lib.mkDefault [ "wheel" "networkmanager" ];
	};
}
