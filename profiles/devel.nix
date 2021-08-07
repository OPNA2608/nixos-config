{ pkgs
, ...
}:

{
	environment.systemPackages = with pkgs; [
		gitFull
		nix-index
		nixpkgs-fmt
		nixpkgs-review
	];
}
