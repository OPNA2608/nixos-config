{ config
, pkgs
, lib
, ...
}:

let
	# https://github.com/NixOS/nixpkgs/issues/126174
	# https://github.com/ProtonMail/proton-bridge/issues/176
	protonmail-bridge-updated = pkgs.callPackage (
		{ lib
		, buildGoModule
		, fetchFromGitHub
		, pkg-config
		, makeWrapper
		, libsecret
		, gnome3
		}:

		buildGoModule rec {
			pname = "protonmail-bridge";
			version = "1.8.7";

			src = fetchFromGitHub {
				owner = "ProtonMail";
				repo = "proton-bridge";
				rev = "br-${version}";
				sha256 = "1887qa59i4vj3q71sd48hdcrinq0gm235qync6qqapsy0ywcyabg";
			};

			vendorSha256 = "0lv4fwfmmqb7h8s9n801l1clx7dr2zdbnggr1wz6bbvi5gafasw3";

			nativeBuildInputs = [ pkg-config makeWrapper ];

			buildInputs = [ libsecret gnome3.gnome-keyring ];

			buildPhase = ''
				runHook preBuild

				patchShebangs ./utils/
				make BUILD_TIME= -j$NIX_BUILD_CORES build-nogui

				runHook postBuild
			'';

			installPhase = ''
				runHook preInstall

				install -Dm555 proton-bridge $out/bin/protonmail-bridge

				runHook postInstall
			'';

			postInstall = ''
				wrapProgram $out/bin/protonmail-bridge \
					--prefix PATH : ${lib.makeBinPath [ gnome3.gnome-keyring ]}
			'';

			meta = with lib; {
				homepage = "https://github.com/ProtonMail/proton-bridge";
				changelog = "https://github.com/ProtonMail/proton-bridge/blob/master/Changelog.md";
				downloadPage = "https://github.com/ProtonMail/proton-bridge/releases";
				license = licenses.gpl3Plus;
				maintainers = with maintainers; [ lightdiscord ];
				description = "Use your ProtonMail account with your local e-mail client";
				longDescription = ''
					An application that runs on your computer in the background and seamlessly encrypts
					and decrypts your mail as it enters and leaves your computer.

					To work, gnome-keyring service must be enabled.
				'';
			};
		}
	) { };
in
{
	imports = [
		./fonts.nix
	];

	sound.enable = true;

	hardware.pulseaudio = {
		enable = true;
		support32Bit = true;
	};

	services.xserver = {
		enable = true;
		useGlamor = true;
		desktopManager.pantheon.enable = true;
		displayManager.lightdm = {
			enable = true;
			greeters.pantheon.enable = true;
		};
		libinput.enable = true;
	};

	environment.pantheon.excludePackages = (with pkgs.pantheon; [
		elementary-calculator
		elementary-code
		elementary-files
		elementary-music
		elementary-photos
		elementary-terminal
		elementary-videos
	]) ++ (with pkgs.gnome; [
		epiphany
		geary
	]);
	programs.evince.enable = false; # atril

	services.gnome.gnome-keyring.enable = true;

	environment.systemPackages = with pkgs; [
		# Web & Net
		element-desktop
		palemoon
		# fallback
		firefox
		thunderbird
		networkmanagerapplet

		# Office & AV
		corrscope
		galculator
		gimp
		libreoffice
		mate.eom
		mate.atril
		mpv
		youtube-dl

		# System
		kitty
		pavucontrol
		pcmanfm
		xfce.mousepad
		# https://github.com/NixOS/nixpkgs/issues/120765
		xfce.xfce4-screenshooter

		# Overridden PM-bridge, failed attempt at fixing it
    # TODO replace with Hydroxide eventually
		protonmail-bridge-updated
	];
}
