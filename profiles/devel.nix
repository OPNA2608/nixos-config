{ pkgs
, ...
}:

{
	environment.systemPackages = with pkgs; [
		gitFull
		nix-index
		nixfmt-rfc-style
		nixpkgs-review
	];
}
