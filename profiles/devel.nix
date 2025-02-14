{ pkgs
, ...
}:

{
	environment.systemPackages = with pkgs; [
		gh
		gitFull
		nixfmt-rfc-style
		nixpkgs-review
	];

	programs.nix-index = {
		enable = true;
		enableBashIntegration = false;
		enableFishIntegration = false;
		enableZshIntegration = false;
	};
}
