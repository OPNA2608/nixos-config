{ supportEfi ? true
, device ? null
}:
{ config
, lib
, pkgs
, ...
}:

assert !supportEfi -> device;

let
	systemSetupEntry = ''
		menuentry 'System Setup' $menuentry_id_option 'uefi-firmware' {
			fwsetup
		}
	'';
in
{
	boot = {
		loader = {
			grub = {
				enable = true;
				# Only needed for BIOS iirc?
				device = if (!supportEfi && device != null) then device else "nodev";
				efiSupport = supportEfi;
				useOSProber = lib.mkDefault false;
				extraEntriesBeforeNixOS = supportEfi;
				extraEntries = (if supportEfi then systemSetupEntry else "");
				default = (if supportEfi then 1 else 0) + (if config.boot.loader.grub.memtest86.enable then 1 else 0);
				memtest86.enable = pkgs.stdenv.hostPlatform.isx86;
			};
			efi.canTouchEfiVariables = lib.mkDefault supportEfi;
		};
		plymouth.enable = config.services.xserver.enable;
	};
}
