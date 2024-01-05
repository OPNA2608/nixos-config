{ id
, name
}:

{ pkgs
, lib
, ...
}:

assert id != null;
assert name != null;

let
	passwordPath = id: "/etc/nixos/users/passwords/${id}";
	mkPasswordPath = id: if ! builtins.pathExists (/. + (passwordPath id)) then
		throw "${passwordPath id} doesn't exist! Did you forget to create it with `mkpasswd -m <crypt> > ${passwordPath id}`?"
	else
		(passwordPath id);
in
{
	users.users.${id} = {
		description = name;
		passwordFile = mkPasswordPath id;
		isNormalUser = true;
		shell = pkgs.fish;
		extraGroups = lib.mkDefault [ "wheel" "networkmanager" ];
	};
}
