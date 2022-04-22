{ config, lib, pkgs, ... }:

with lib;

let
	cfg = config.programs.haguichi;
in {
	options.programs.haguichi = {
		enable = mkEnableOption "haguichi";
	};

	config = mkIf cfg.enable {
		services.logmein-hamachi.enable = true;
		environment.systemPackages = with pkgs; [
			(callPackage ./haguichi.nix {})
		];
	};
}
