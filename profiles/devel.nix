{ pkgs
, ...
}:

{
	environment.systemPackages = with pkgs; [
		gh
		gitFull
		nixfmt-rfc-style
		lixPackageSets.latest.nixpkgs-review
		screen
	];

	programs.nix-index = {
		enable = true;
		enableBashIntegration = true;
		enableFishIntegration = true;
		enableZshIntegration = false;
	};
}
