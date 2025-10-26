{ config
, pkgs
, lib
, ...
}:

{
	imports = [
		./i18n.nix
		./logrotate.nix
		./rsyslogd.nix
		./shell.nix
		./ssh.nix
		./time.nix
		./vim.nix
	];

	console = {
		earlySetup = true;
		font = "gohufont-uni-14";
		packages = with pkgs; [ gohufont ];
	};
	services.gpm.enable = true;

	programs.less = {
		enable = true;
		# Between 22.05 and 22.11, lesspipe got too dumb for me:
		# - missing `strings` from binutils in its wrapping: https://github.com/NixOS/nixpkgs/issues/216087
		# - sends SJIS files through `strings` which is *so* much worse than printing escapes within text
		lessopen = lib.mkForce null;
	};

	networking.networkmanager.enable = true;

	users.mutableUsers = false;

	system.copySystemConfiguration = true;

	environment.systemPackages = with pkgs; [
		curl
		file
		htop
		lhasa
		man-pages
		networkmanager
		hyfetch fastfetch # latter user by the former
		nixos-option
		nkf
		service-wrapper
		tree
		unixtools.xxd
		wget
		zip unzip
	];

	nix.package = pkgs.lixPackageSets.latest.lix;
}

