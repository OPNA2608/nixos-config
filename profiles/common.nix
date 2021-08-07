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

	programs.less.enable = true;

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
		neofetch
		nkf
		service-wrapper
		tree
		unixtools.xxd
		wget
		zip unzip
	];
}

